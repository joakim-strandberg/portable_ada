with Ada.Text_IO.Text_Streams;
with Ada.Streams.Stream_IO;

with Std.Ada_Extensions;
use  Std.Ada_Extensions;
pragma Elaborate_All (Std.Ada_Extensions);

procedure EGL_Reader.Main is

   use Node_Iterator_Vectors;

   use type Std.XML_UTF8_DOM_Parsers.UTF8_Text;
   use type Std.XML_UTF8_DOM_Parsers.XML_Element_Attributes;
   use type Std.XML_UTF8_DOM_Parsers.XML_Element_Children;

   Egl_XML_Filename : constant String := "egl.xml";

   Root_Node : Std.XML_UTF8_DOM_Parsers.XML_Node_Const_Ptr;

   procedure Read_Egl_XML_File;
   procedure Parse_XML;
   procedure Create_Output_File;
   procedure Initialize_Nodes;
   procedure Use_File;

   procedure Read_Egl_XML_File is
      File : Ada.Streams.Stream_IO.File_Type;

      Call_Result : Subprogram_Call_Result;

      procedure Open_Input_File;
      procedure Read_All_Contents_Of_Input_File;

      procedure Open_Input_File is
      begin
         Ada.Streams.Stream_IO.Open
           (File => File,
            Mode => Ada.Streams.Stream_IO.In_File,
            Name => Egl_XML_Filename);
         Read_All_Contents_Of_Input_File;
      end Open_Input_File;

      procedure Read_All_Contents_Of_Input_File is

         procedure Read_File;

         Is_End_Of_File_Reached : Boolean := False;

         procedure Read_File is
            Buffer : Octet_Array (1 .. 1024);
            Count  : Octet_Offset;
         begin
            for I in Pos32'Range loop
               if Ada.Streams.Stream_IO.End_Of_File (File) then
                  Is_End_Of_File_Reached := True;
                  exit;
               end if;
               Ada.Streams.Stream_IO.Read
                 (File => File,
                  Item => Buffer,
                  Last => Count);
               for I in Buffer'First .. Count loop
                  File_Contents (Next_File_Index) := Buffer (I);
                  Next_File_Index := Next_File_Index + 1;
               end loop;
            end loop;
         end Read_File;

      begin
         Read_File;

         if not Is_End_Of_File_Reached then
            Call_Result := (Has_Failed => True,
                            Codes      => (1200128260, -1400763670));
         end if;
      end Read_All_Contents_Of_Input_File;

   begin
      Open_Input_File;
      if not Call_Result.Has_Failed then
         Parse_XML;
      else
         Ada.Text_IO.Put_Line (Message (Call_Result));
      end if;
   end Read_Egl_XML_File;

   procedure Parse_XML is
      Call_Result : Subprogram_Call_Result;
   begin
      Std.XML_UTF8_DOM_Parsers.Parse
        (Pool        => Pool'Access,
         XML_Message =>
           File_Contents (1 .. Next_File_Index - 1),
         Call_Result => Call_Result,
         Root_Node   => Root_Node);
      if Call_Result.Has_Failed then
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

   procedure Initialize_Nodes is
   begin
      Stream := Ada.Text_IO.Text_Streams.Stream (File);
      Use_File;
   end Initialize_Nodes;

   procedure Use_File is

      procedure Do_Work;

      procedure Do_Work is

         procedure Handle_Node;

         procedure Handle_Node is
            N : constant Node_Iterator_Vectors.Element_Ptr
              := Node_Iterator_Vectors.Last_Element_Reference (Nodes'Access);
            Parent : constant Node_Iterator_Index := Last_Index (Nodes);

            Children : constant Std.XML_UTF8_DOM_Parsers.Node_Const_Ptr_Array
              := (+N.Element.Element.Children);

            procedure Handle_XML_Tag;

            procedure Handle_XML_Tag is

               procedure Print_Attributes;

               procedure Print_Attributes is
                  Depth : constant Extended_Octet_Offset
                    := Extended_Octet_Offset
                      (Node_Iterator_Vectors.Last_Index (Nodes));
                  Attributes : constant
                    Std.XML_UTF8_DOM_Parsers.Attribute_Ptr_Array
                      := +N.Element.Element.Attributes;
               begin
                  for I in Attributes'Range loop
                     Ada.Streams.Write
                       (Stream.all, ((1 .. Depth => +(' '))));
                     Ada.Streams.Write
                       (Stream.all,
                        (+"Attribute name: ") & (+Attributes (I).Name));
                     Ada.Text_IO.New_Line (File);
                     Ada.Streams.Write
                       (Stream.all, ((1 .. Depth => +(' '))));
                     Ada.Streams.Write
                       (Stream.all,
                        (+"Attribute value: ") & (+Attributes (I).Value));
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
                  (+"Tag name: ") & (+N.Element.Element.Name));
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
                  when Std.XML_UTF8_DOM_Parsers.Node_Kind_Tag =>
                     declare
                        Item : constant Node_Iterator
                          := (Element => Children (I),
                              Child_Index  => 0,
                              Parent_Index => Parent);
                     begin
                        Append (This     => Nodes,
                                New_Item => Item);
                     end;

                     N.Child_Index := I + 1;
                     Shall_Delete := False;
                     Shall_Continue_Loop := False;
                  when Std.XML_UTF8_DOM_Parsers.Node_Kind_Comment =>
                     Ada.Streams.Write (Stream.all, ((1 .. Depth => +(' '))));
                     Ada.Streams.Write
                       (Stream.all,
                        (+"Comment: ") & (+Children (I).Text));
                     Ada.Text_IO.New_Line (File);
                  when Std.XML_UTF8_DOM_Parsers.Node_Kind_CDATA =>
                     Ada.Streams.Write (Stream.all, ((1 .. Depth => +(' '))));
                     Ada.Streams.Write
                       (Stream.all,
                        (+"CDATA: ") & (+Children (I).Text));
                     Ada.Text_IO.New_Line (File);
                  when Std.XML_UTF8_DOM_Parsers.Node_Kind_Text =>
                     Ada.Streams.Write
                       (Stream.all, ((1 .. Depth => +(' '))));
                     Ada.Streams.Write
                       (Stream.all,
                        (+"Text: ") & (+Children (I).Text));
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
         when Std.XML_UTF8_DOM_Parsers.Node_Kind_Tag =>
            declare
               Item : constant Node_Iterator
                 := (Element => Root_Node,
                     Child_Index  => 0,
                     Parent_Index => 1);
            begin
               Append (This     => Nodes,
                       New_Item => Item);
            end;

            Do_Work;
         when Std.XML_UTF8_DOM_Parsers.Node_Kind_Comment |
              Std.XML_UTF8_DOM_Parsers.Node_Kind_CDATA |
              Std.XML_UTF8_DOM_Parsers.Node_Kind_Text =>
            Ada.Text_IO.Put_Line
              ("Root node in xml file is of wrong type");
      end case;
   end Use_File;

begin
   Read_Egl_XML_File;
end EGL_Reader.Main;
