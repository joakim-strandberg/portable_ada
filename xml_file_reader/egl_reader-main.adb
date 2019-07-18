with Ada.Text_IO.Text_Streams;
with Ada.Streams.Stream_IO;
with Std.Ada_Extensions; use Std.Ada_Extensions;
with Std.XML.DOM_Parser.Text_IO;
with Std.Containers.Unbounded_Octet_Vectors;
with Std.Containers.Text_IO;
with Std.File_IO;

procedure EGL_Reader.Main is

   use Std.XML.DOM_Parser;
   use Std.File_IO;
   use Node_Iterator_Vectors;
   use Ada.Streams.Stream_IO;

   Shall_Print_Debug_Info : constant Boolean := False;

   Egl_XML_Filename : aliased String := "egl.xml";

   Egl_XML_File_Reader : Std.File_IO.File_Reader
     (Name                   => Egl_XML_Filename'Access,
      Initial_Elements_Count => 256 * 1024);

   Pool : aliased Std.XML.DOM_Parser.Memory_Pool;

   Root_Node : Std.XML.DOM_Parser.XML_Node_Ptr;

   procedure Read_Egl_XML_File;
   procedure Initialize_Memory_Pool;
   procedure Parse_XML;
   procedure Create_Output_File;
   procedure Initialize_Nodes;
   procedure Use_File;
   procedure Print_Statistics;

   procedure Read_Egl_XML_File is
      Call_Result : Subprogram_Call_Result;
   begin
      Initialize (Egl_XML_File_Reader, Call_Result);
      if Is_Success (Call_Result) then
         Initialize_Memory_Pool;
      else
         Ada.Text_IO.Put_Line (Message (Call_Result));
      end if;
      Finalize (Egl_XML_File_Reader);
   exception
      when others =>
         Finalize (Egl_XML_File_Reader);
         raise;
   end Read_Egl_XML_File;

   Input_File : Ada.Streams.Stream_IO.File_Type;

   procedure Initialize_Memory_Pool is
   begin
      begin
         Initialize (Pool);
         Parse_XML;
      exception
         when others =>
            Finalize (Pool);
            raise;
      end;
      Finalize (Pool);
   end Initialize_Memory_Pool;

   procedure Parse_XML is
      Call_Result : Extended_Subprogram_Call_Result;
   begin
      Parse
        (Pool        => Pool'Access,
         XML_Message =>
           File_Contents
             (Egl_XML_File_Reader).all
             (1 .. Last_Index (Egl_XML_File_Reader)),
         Call_Result => Call_Result,
         Root_Node   => Root_Node);
      if Has_Failed (Call_Result) then
         Ada.Text_IO.Put_Line (Message (Call_Result));
      else
         Ada.Text_IO.Put_Line
           ("Success reading egl.xml and parsing contents.");
         Ada.Text_IO.Put_Line ("Will create output.txt file.");
         Create_Output_File;
      end if;
   end Parse_XML;

   File : Ada.Text_IO.File_Type;

   Stream : Ada.Text_IO.Text_Streams.Stream_Access;

   procedure Create_Output_File is
   begin
      Ada.Text_IO.Create
        (File => File,
         Mode => Ada.Text_IO.Out_File,
         Name => "output.txt");
      begin
         Initialize_Nodes;
      exception
         when others =>
            Ada.Text_IO.Close (File);
            raise;
      end;
      Ada.Text_IO.Close (File);
   end Create_Output_File;

   Nodes : Node_Iterator_Vectors.Vector (8);

   procedure Initialize_Nodes is
   begin
      Stream := Ada.Text_IO.Text_Streams.Stream (File);
      Initialize (Nodes);
      Use_File;
      Finalize (Nodes);
   exception
      when others =>
         Finalize (Nodes);
         raise;
   end Initialize_Nodes;

   procedure Use_File is

      procedure Do_Work;

      procedure Do_Work is

         procedure Handle_Node;

         procedure Handle_Node is
            N : constant Node_Iterator_Vectors.Element_Ptr
              := Last_Element_Reference (Nodes);
            Parent : constant Node_Iterator_Index := Last_Index (Nodes);

            Children : constant Std.XML.DOM_Parser.Node_Ptr_Array
              := Std.XML.DOM_Parser.Node_Children
                (Pool    => Pool,
                 Element => N.Element.all);

            procedure Handle_XML_Tag;

            procedure Handle_XML_Tag is

               procedure Print_Attributes;

               procedure Print_Attributes is
                  Depth : constant Extended_Octet_Offset
                    := Extended_Octet_Offset
                      (Node_Iterator_Vectors.Last_Index (Nodes));
                  Attributes : constant Std.XML.DOM_Parser.Attribute_Ptr_Array
                    := Std.XML.DOM_Parser.Tag_Attributes
                      (Pool => Pool,
                       Key  => N.Element.Attributes_Key);
               begin
                  for I in Attributes'Range loop
                     Ada.Streams.Write
                       (Stream.all, ((1 .. Depth => +(' '))));
                     Ada.Streams.Write
                       (Stream.all,
                        (+"Attribute name: ") &
                          Std.XML.DOM_Parser.Text
                          (Pool, Attributes (I).Name));
                     Ada.Text_IO.New_Line (File);
                     Ada.Streams.Write
                       (Stream.all, ((1 .. Depth => +(' '))));
                     Ada.Streams.Write
                       (Stream.all,
                        (+"Attribute value: ") &
                          Std.XML.DOM_Parser.Text
                          (Pool, Attributes (I).Value));
                     Ada.Text_IO.New_Line (File);
                  end loop;
               end Print_Attributes;

               Depth : constant Extended_Octet_Offset
                 := Extended_Octet_Offset
                   (Node_Iterator_Vectors.Last_Index (Nodes)) - 1;
            begin
               Ada.Streams.Write (Stream.all, ((1 .. Depth => +(' '))));
               Ada.Streams.Write
                 (Stream.all,
                  (+"Tag name: ") & Text (Pool, N.Element.Name));
               Ada.Text_IO.New_Line (File);

               Print_Attributes;
            end Handle_XML_Tag;

            Depth : Extended_Octet_Offset;

            Shall_Delete : Boolean := True;

            procedure Handle_Loop_Iteration
              (I                   : Pos32;
               Shall_Continue_Loop : in out Boolean);

            procedure Handle_Loop_Iteration
              (I                   : Pos32;
               Shall_Continue_Loop : in out Boolean) is
            begin
               case Children (I).Id is
                  when Node_Kind_Tag =>
                     declare
                        Item : constant Node_Iterator
                          := (Element =>
                                Std.XML.DOM_Parser.Element
                                  (Pool, Children (I).Component_Key),
                              Child_Index  => 0,
                              Parent_Index => Parent);
                     begin
                        Append (This     => Nodes,
                                New_Item => Item);
                     end;

                     N.Child_Index := I + 1;
                     Shall_Delete := False;
                     Shall_Continue_Loop := False;
                  when Node_Kind_Comment =>
                     Ada.Streams.Write (Stream.all, ((1 .. Depth => +(' '))));
                     Ada.Streams.Write
                       (Stream.all,
                        (+"Comment: ") &
                          Text (Pool, Children (I).Component_Key));
                     Ada.Text_IO.New_Line (File);
                  when Node_Kind_CDATA =>
                     Ada.Streams.Write (Stream.all, ((1 .. Depth => +(' '))));
                     Ada.Streams.Write
                       (Stream.all,
                        (+"CDATA: ") &
                          Text (Pool, Children (I).Component_Key));
                     Ada.Text_IO.New_Line (File);
                  when Node_Kind_Text =>
                     Ada.Streams.Write
                       (Stream.all, ((1 .. Depth => +(' '))));
                     Ada.Streams.Write
                       (Stream.all,
                        (+"Text: ") &
                          Text (Pool, Children (I).Component_Key));
                     Ada.Text_IO.New_Line (File);
               end case;
            end Handle_Loop_Iteration;

            Shall_Continue_Loop : Boolean := True;

         begin
            if Children'Length > 0 then
               if
                 N.Child_Index = 0
               then
                  Handle_XML_Tag;
                  Depth := Extended_Octet_Offset
                    (Node_Iterator_Vectors.Last_Index (Nodes));
                  for I in Children'Range loop
                     Handle_Loop_Iteration (I, Shall_Continue_Loop);
                     if not Shall_Continue_Loop then
                        exit;
                     end if;
                  end loop;
                  if Shall_Delete then
                     Delete_Last (Nodes);
                  end if;
               elsif N.Child_Index <= Children'Last then
                  Depth := Extended_Octet_Offset
                    (Node_Iterator_Vectors.Last_Index (Nodes));
                  for I in N.Child_Index .. Children'Last loop
                     Handle_Loop_Iteration (I, Shall_Continue_Loop);
                     if not Shall_Continue_Loop then
                        exit;
                     end if;
                  end loop;
                  if Shall_Delete then
                     Delete_Last (Nodes);
                  end if;
               else
                  Delete_Last (Nodes);
               end if;
            else
               Handle_XML_Tag;
               Delete_Last (Nodes);
            end if;
         end Handle_Node;

      begin
         while not Is_Empty (Nodes) loop
            Handle_Node;
         end loop;
      end Do_Work;

   begin
      case Root_Node.Id is
         when Node_Kind_Tag =>
            declare
               Item : constant Node_Iterator
                 := (Element =>
                       Std.XML.DOM_Parser.Element
                         (Pool, Root_Node.Component_Key),
                     Child_Index  => 0,
                     Parent_Index => 1);
            begin
               Append (This     => Nodes,
                       New_Item => Item);
            end;

            Do_Work;
            if Shall_Print_Debug_Info then
               Print_Statistics;
            end if;
         when Node_Kind_Comment |
              Node_Kind_CDATA |
              Node_Kind_Text =>
            Ada.Text_IO.Put_Line
              ("Root node in xml file is of wrong type");
      end case;
   end Use_File;

   procedure Print_Statistics is
      Statistics : Std.Containers.Statistics_Unbounded_Vector;

      Pool_Statistics : Std.XML.DOM_Parser.Memory_Pool_Statistics;
   begin
      Node_Iterator_Vectors.Statistics (Nodes, Statistics);
      Std.XML.DOM_Parser.Statistics (Pool, Pool_Statistics);
      Std.Containers.Text_IO.Put_Line
        (Name       => "Nodes (used for iterating through the egl.xml)",
         Statistics => Statistics);
      Std.XML.DOM_Parser.Text_IO.Put_Line
        ("Memory_Pool", Pool_Statistics);
   end Print_Statistics;

begin
   Read_Egl_XML_File;
end EGL_Reader.Main;
