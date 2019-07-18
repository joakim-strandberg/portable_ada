--  with Ada.Text_IO;
--  with UTF8;
package body Std.XML.DOM_Parser is

   use Node_Vectors;

   procedure Start_Tag
     (This        : in out DOM_Parser;
      Tag_Name    : Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result) is
   begin
      --  Ada.Text_IO.Put_Line ("Start: " & UTF8.Image (Tag_Name));
      case This.State is
         when Expecting_Object_Start =>
            if
              Tag_Name'Length > 0 and
              Is_Empty (This.Pool.Current_Nodes)
            then
               declare
                  Current_Node : XML_Node_Ptr;
               begin
                  New_Node (This.Pool.all,
                            Node_Kind_Tag,
                            Current_Node);
                  UTF8_Store.Append
                    (This  => This.Pool.Strings_Map,
                     Value => Tag_Name,
                     Key   =>
                       Elements_Store.Value
                         (This.Pool.Component_Key_To_XML_Element,
                          Current_Node.Component_Key).all.Name);
                  Append (This.Pool.Current_Nodes, Current_Node);
                  This.Root_Node := Current_Node;
               end;
               This.State := Expecting_Default;
            else
               Ada_Extensions.Initialize
                 (Call_Result, -2132671123, 1966624808);
            end if;
         when Expecting_Default =>
            if
              Tag_Name'Length > 0
            then
               declare
                  Current_Node : XML_Node_Ptr;
               begin
                  New_Node (This.Pool.all,
                            Node_Kind_Tag,
                            Current_Node);
                  UTF8_Store.Append
                    (This  => This.Pool.Strings_Map,
                     Value => Tag_Name,
                     Key   =>
                       Elements_Store.Value
                         (This.Pool.Component_Key_To_XML_Element,
                          Current_Node.Component_Key).Name);

                  if Element
                    (This.Pool.Current_Nodes,
                     Last_Index (This.Pool.Current_Nodes)).all.Id
                      = Node_Kind_Tag
                  then
                     Children_Id_To_Arrays.Add_To_Array
                       (This    => This.Pool.Children_Id_To_Array,
                        Key     =>
                          Elements_Store.Value
                            (
                             This.Pool.Component_Key_To_XML_Element,
                             Node_Vectors.Last_Element
                               (
                                This.Pool.Current_Nodes
                               ).Component_Key
                            ).Children_Id,
                        Element => Current_Node);

                     Append (This.Pool.Current_Nodes, Current_Node);
                  else
                     Ada_Extensions.Initialize
                       (Call_Result, 1695756105, 1714042669);
                  end if;
               end;
            else
               Ada_Extensions.Initialize
                 (Call_Result, -0416079960, -1464855808);
            end if;
         when End_State =>
            Ada_Extensions.Initialize
              (Call_Result, 0561631589, 0761077416);
      end case;
   end Start_Tag;

   procedure End_Tag
     (This        : in out DOM_Parser;
      Tag_Name    : Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result) is
   begin
      --  Ada.Text_IO.Put_Line ("End: " & UTF8.Image (Tag_Name));
      case This.State is
         when Expecting_Default =>
            if not Is_Empty (This.Pool.Current_Nodes) and then
              Element (This.Pool.Current_Nodes,
                  Last_Index (This.Pool.Current_Nodes)).Id = Node_Kind_Tag
            then
               if
                 UTF8_Store.Value
                   (This  => This.Pool.Strings_Map,
                    Index =>
                      Elements_Store.Value
                        (
                         This.Pool.Component_Key_To_XML_Element,
                         Last_Element
                           (This.Pool.Current_Nodes).Component_Key
                        ).Name) = Tag_Name
               then
                  Delete_Last (This.Pool.Current_Nodes);
                  if Is_Empty (This.Pool.Current_Nodes) then
                     This.State := End_State;
                  end if;
               else
                  Ada_Extensions.Initialize
                    (Call_Result, -0316487383, -2063296151);
               end if;
            else
               Ada_Extensions.Initialize
                 (Call_Result, -1355522791, 1675536860);
            end if;
         when Expecting_Object_Start |
              End_State =>
            Ada_Extensions.Initialize
              (Call_Result, -0728861922, -0299445966);
      end case;
   end End_Tag;

   function Contains_Spaces_And_Newlines (Text : Octet_Array) return Boolean;

   function Contains_Spaces_And_Newlines (Text : Octet_Array) return Boolean is
      Result : Boolean := True;
   begin
      for I in Octet_Offset range Text'First .. Text'Last loop
         if
           Text (I) = Octet (Latin_1.To_Int32 (' ')) or
           Text (I) = Octet (Latin_1.To_Int32 (Latin_1.LF)) or
           Text (I) = Octet (Latin_1.To_Int32 (Latin_1.CR))
         then
            null;
         else
            Result := False;
            exit;
         end if;
      end loop;
      return Result;
   end Contains_Spaces_And_Newlines;

   procedure Text
     (This        : in out DOM_Parser;
      Value       : Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result) is
   begin
      --  Ada.Text_IO.Put_Line ("Text: " & UTF8.Image (Value));
      case This.State is
         when Expecting_Default =>
            if
              Value'Length = 0 or
              (Value'Length > 0 and then
               Contains_Spaces_And_Newlines (Value))
            then
               null;
            elsif
              not Is_Empty (This.Pool.Current_Nodes)
            then
               declare
                  Current_Node : XML_Node_Ptr;
               begin
                  New_Node (This.Pool.all, Node_Kind_Text, Current_Node);
                  UTF8_Store.Append
                    (This  => This.Pool.Strings_Map,
                     Value => Value,
                     Key   => Current_Node.Component_Key);

                  if
                    Element
                      (This.Pool.Current_Nodes,
                       Last_Index (This.Pool.Current_Nodes)).Id = Node_Kind_Tag
                  then
                     Children_Id_To_Arrays.Add_To_Array
                       (This    => This.Pool.Children_Id_To_Array,
                        Key     =>
                          Elements_Store.Value
                            (
                             This.Pool.Component_Key_To_XML_Element,
                             Last_Element
                               (
                                This.Pool.Current_Nodes
                               ).Component_Key).Children_Id,
                        Element => Current_Node);
                  else
                     Ada_Extensions.Initialize
                       (Call_Result, -0944309962, -0212130363);
                  end if;
               end;
            else
               Ada_Extensions.Initialize (Call_Result, 0536156601, 0921613311);
            end if;
         when Expecting_Object_Start |
              End_State =>
            Ada_Extensions.Initialize (Call_Result, 0240750889, 1723362921);
      end case;
   end Text;

   procedure Handle_Attribute
     (This            : in out DOM_Parser;
      Attribute_Name  : Octet_Array;
      Attribute_Value : Octet_Array;
      Call_Result     : in out Extended_Subprogram_Call_Result) is
   begin
      --  Ada.Text_IO.Put_Line ("Attr. Name : " & UTF8.Image(Attribute_Name));
      --  Ada.Text_IO.Put_Line ("Attr. Value: " & UTF8.Image(Attribute_Value));
      case This.State is
         when Expecting_Default =>
            if not Is_Empty (This.Pool.Current_Nodes) then
               if
                 Attribute_Name'Length > 0 and Attribute_Value'Length > 0
               then
                  declare
                     Attribute : constant Attribute_Ptr
                       := New_Attribute (This.Pool);
                  begin
                     UTF8_Store.Append
                       (This.Pool.Strings_Map,
                        Attribute_Name,
                        Attribute.Name);
                     UTF8_Store.Append
                       (This.Pool.Strings_Map,
                        Attribute_Value,
                        Attribute.Value);

                     if
                       Element
                         (This.Pool.Current_Nodes,
                          Last_Index (This.Pool.Current_Nodes)).Id
                           = Node_Kind_Tag
                     then
                        Attributes_Collections.Add_To_Array
                          (This    => This.Pool.Attributes_Collection,
                           Key     =>
                             Elements_Store.Value
                               (This => This.Pool.Component_Key_To_XML_Element,
                                Key  =>
                                  Element
                                    (
                                     This.Pool.Current_Nodes,
                                     Last_Index (This.Pool.Current_Nodes)
                                    ).Component_Key
                               ).Attributes_Key,
                           Element => Attribute);
                     else
                        Ada_Extensions.Initialize
                          (Call_Result, 0612916249, -0250963769);
                     end if;
                  end;
               else
                  Ada_Extensions.Initialize
                    (Call_Result, -1091502024, -1483543078);
               end if;
            else
               Ada_Extensions.Initialize
                 (Call_Result, -0372407662, -1139199208);
            end if;
         when Expecting_Object_Start |
              End_State =>
            Ada_Extensions.Initialize (Call_Result, 1103012185, 0319457400);
      end case;
   end Handle_Attribute;

   procedure Comment
     (This        : in out DOM_Parser;
      Value       : Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result) is
   begin
      --  Ada.Text_IO.Put_Line ("Comment: " & UTF8.Image (Value));
      case This.State is
         when Expecting_Default =>
            if
              not Is_Empty (This.Pool.Current_Nodes)
            then
               if
                 Value'Length > 0
               then
                  declare
                     Node : XML_Node_Ptr;
                  begin
                     New_Node (This.Pool.all, Node_Kind_Comment, Node);
                     UTF8_Store.Append
                       (This  => This.Pool.Strings_Map,
                        Value => Value,
                        Key   => Node.Component_Key);

                     if
                       Element
                         (This.Pool.Current_Nodes,
                          Last_Index (This.Pool.Current_Nodes)).Id
                           = Node_Kind_Tag
                     then
                        Children_Id_To_Arrays.Add_To_Array
                          (This    => This.Pool.Children_Id_To_Array,
                           Key     =>
                             Elements_Store.Value
                               (
                                This => This.Pool.Component_Key_To_XML_Element,
                                Key  =>
                                  Last_Element
                                    (This.Pool.Current_Nodes).Component_Key
                               ).Children_Id,
                           Element => Node);
                     else
                        Ada_Extensions.Initialize
                          (Call_Result, 2066772500, 1193932906);
                     end if;
                  end;
               else
                  Ada_Extensions.Initialize
                    (Call_Result, 1366102371, 1421674126);
               end if;
            else
               Ada_Extensions.Initialize (Call_Result, 0845969060, 0639006566);
            end if;
         when Expecting_Object_Start |
              End_State =>
            Ada_Extensions.Initialize (Call_Result, -1373186804, -0874315849);
      end case;
   end Comment;

   procedure CDATA
     (This        : in out DOM_Parser;
      Value       : Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result) is
   begin
      --  Ada.Text_IO.Put_Line ("CDATA: " & UTF8.Image (Value));
      case This.State is
         when Expecting_Default =>
            if
              not Is_Empty (This.Pool.Current_Nodes)
            then
               if
                 Value'Length > 0
               then
                  declare
                     Node : XML_Node_Ptr;
                  begin
                     New_Node (This.Pool.all, Node_Kind_CDATA, Node);
                     UTF8_Store.Append
                       (This  => This.Pool.Strings_Map,
                        Value => Value,
                        Key   => Node.Component_Key);

                     if
                       Element
                         (This.Pool.Current_Nodes,
                          Last_Index (This.Pool.Current_Nodes)).Id
                           = Node_Kind_Tag
                     then
                        Children_Id_To_Arrays.Add_To_Array
                          (This    => This.Pool.Children_Id_To_Array,
                           Key     =>
                             Elements_Store.Value
                               (
                                This => This.Pool.Component_Key_To_XML_Element,
                                Key  =>
                                  Last_Element
                                    (This.Pool.Current_Nodes).Component_Key
                               ).Children_Id,
                           Element => Node);
                     else
                        Ada_Extensions.Initialize
                          (Call_Result, -2021174626, -1403249390);
                     end if;
                  end;
               else
                  Ada_Extensions.Initialize
                    (Call_Result, 1915730777, 1973598725);
               end if;
            else
               Ada_Extensions.Initialize
                 (Call_Result, -0076965217, 0193355440);
            end if;
         when Expecting_Object_Start |
              End_State =>
            Ada_Extensions.Initialize (Call_Result, 0698504230, -0963685542);
      end case;
   end CDATA;

   procedure Parse
     (Pool        : access Memory_Pool;
      XML_Message : Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result;
      Root_Node   :    out XML_Node_Ptr)
   is
      This : DOM_Parser (Pool.all'Access);
      --  Janus/Ada compiler generates faulty code when using instead:
      --  This : DOM_Parser (Pool);
   begin
      XML.SAX_Parser.Parse
        (XML.SAX_Parser.SAX_Parser'Class (This),
         XML_Message,
         Call_Result);

      Root_Node := This.Root_Node;
   end Parse;

   procedure New_Node
     (Pool    : in out Memory_Pool;
      Kind_Id : Node_Kind_Id;
      Node    : out XML_Node_Ptr) is
   begin
      Pool_Node_Vectors.Append
        (This          => Pool.Pool_Nodes,
         New_Item      => Node);
      Node.Id := Kind_Id;
      case Kind_Id is
         when Node_Kind_Tag =>
            Elements_Store.Create_Key
              (Pool.Component_Key_To_XML_Element, Node.Component_Key);
         when Node_Kind_Comment |
              Node_Kind_CDATA |
              Node_Kind_Text =>
            null;
      end case;

      if Kind_Id = Node_Kind_Tag then
         declare
            Tag : XML_Element_Ptr;
         begin
            XML_Tag_Vectors.Append
              (This          => Pool.XML_Tags,
               New_Item      => Tag);
            Elements_Store.Set_Value
              (This  => Pool.Component_Key_To_XML_Element,
               Key   => Node.Component_Key,
               Value => Tag);

            Children_Id_To_Arrays.Create_Key
              (Pool.Children_Id_To_Array, Tag.Children_Id);

            Attributes_Collections.Create_Key
              (Pool.Attributes_Collection, Tag.Attributes_Key);
         end;
      end if;
   end New_Node;

   function New_Attribute (Pool : access Memory_Pool) return Attribute_Ptr is
      A : Attribute_Ptr;
   begin
      Pool_Attribute_Vectors.Append
        (This     => Pool.Pool_Attributes,
         New_Item => A);
      return A;
   end New_Attribute;

   function Node_Children
     (Pool    : Memory_Pool;
      Element : XML_Element) return Node_Ptr_Array is
   begin
      return Children_Id_To_Arrays.Get_Array
        (This => Pool.Children_Id_To_Array,
         Key  => Element.Children_Id);
   end Node_Children;

   function Text
     (Pool : Memory_Pool;
      Key  : UTF8_Key) return Octet_Array is
   begin
      return UTF8_Store.Value
        (This  => Pool.Strings_Map,
         Index => Key);
   end Text;

   function Tag_Attributes
     (Pool : Memory_Pool;
      Key  : Tag_Attributes_Key) return Attribute_Ptr_Array is
   begin
      return Attributes_Collections.Get_Array
        (This => Pool.Attributes_Collection,
         Key  => Key);
   end Tag_Attributes;

   function Element
     (Pool : Memory_Pool;
      Key  : Node_Component_Key) return XML_Element_Ptr is
   begin
      return Elements_Store.Value
        (Pool.Component_Key_To_XML_Element,
         Key);
   end Element;

   procedure Initialize (This : out Memory_Pool) is
      procedure Initialize_Tags_Store;
      procedure Initialize_Children_Container;
      procedure Initialize_Strings_Map;
      procedure Initialize_Current_Nodes;
      procedure Initialize_Attributes;
      procedure Initialize_Pool_Attributes;
      procedure Initialize_XML_Tags;
      procedure Initialize_Pool_Nodes;

      procedure Initialize_Tags_Store is
      begin
         Elements_Store.Initialize (This.Component_Key_To_XML_Element);
         Initialize_Children_Container;
      end Initialize_Tags_Store;

      procedure Initialize_Children_Container is
      begin
         XML.DOM_Parser.Children_Id_To_Arrays.Initialize
           (This.Children_Id_To_Array);
         Initialize_Strings_Map;
      end Initialize_Children_Container;

      procedure Initialize_Strings_Map is
      begin
         XML.DOM_Parser.UTF8_Store.Initialize (This.Strings_Map);
         Initialize_Current_Nodes;
      end Initialize_Strings_Map;

      procedure Initialize_Current_Nodes is
      begin
         Node_Vectors.Initialize (This.Current_Nodes);
         Initialize_Attributes;
      end Initialize_Current_Nodes;

      procedure Initialize_Attributes is
      begin
         Attributes_Collections.Initialize (This.Attributes_Collection);
         Initialize_Pool_Attributes;
      end Initialize_Attributes;

      procedure Initialize_Pool_Attributes is
      begin
         Pool_Attribute_Vectors.Initialize (This.Pool_Attributes);
         Initialize_XML_Tags;
      end Initialize_Pool_Attributes;

      procedure Initialize_XML_Tags is
      begin
         XML_Tag_Vectors.Initialize (This.XML_Tags);
         Initialize_Pool_Nodes;
      end Initialize_XML_Tags;

      procedure Initialize_Pool_Nodes is
      begin
         Pool_Node_Vectors.Initialize (This.Pool_Nodes);
      end Initialize_Pool_Nodes;

   begin
      Initialize_Tags_Store;
   end Initialize;

   procedure Finalize (This : in out Memory_Pool) is
      procedure Finalize_Tags_Store;
      procedure Finalize_Children_Container;
      procedure Finalize_Strings_Map;
      procedure Finalize_Current_Nodes;
      procedure Finalize_Attributes;
      procedure Finalize_Pool_Attributes;
      procedure Finalize_XML_Tags;
      procedure Finalize_Pool_Nodes;

      procedure Finalize_Tags_Store is
      begin
         begin
            Finalize_Children_Container;
         exception
            when others =>
               Elements_Store.Finalize (This.Component_Key_To_XML_Element);
               raise;
         end;
         Elements_Store.Finalize (This.Component_Key_To_XML_Element);
      end Finalize_Tags_Store;

      procedure Finalize_Children_Container is
      begin
         begin
            Finalize_Strings_Map;
         exception
            when others =>
               XML.DOM_Parser.Children_Id_To_Arrays.Finalize
                 (This.Children_Id_To_Array);
               raise;
         end;
         XML.DOM_Parser.Children_Id_To_Arrays.Finalize
           (This.Children_Id_To_Array);
      end Finalize_Children_Container;

      procedure Finalize_Strings_Map is
      begin
         begin
            Finalize_Current_Nodes;
         exception
            when others =>
               XML.DOM_Parser.UTF8_Store.Finalize (This.Strings_Map);
               raise;
         end;
         XML.DOM_Parser.UTF8_Store.Finalize (This.Strings_Map);
      end Finalize_Strings_Map;

      procedure Finalize_Current_Nodes is
      begin
         begin
            Finalize_Attributes;
         exception
            when others =>
               Node_Vectors.Finalize (This.Current_Nodes);
               raise;
         end;
         Node_Vectors.Finalize (This.Current_Nodes);
      end Finalize_Current_Nodes;

      procedure Finalize_Attributes is
      begin
         begin
            Finalize_Pool_Attributes;
         exception
            when others =>
               Attributes_Collections.Finalize (This.Attributes_Collection);
               raise;
         end;
         Attributes_Collections.Finalize (This.Attributes_Collection);
      end Finalize_Attributes;

      procedure Finalize_Pool_Attributes is
      begin
         begin
            Finalize_XML_Tags;
         exception
            when others =>
               Pool_Attribute_Vectors.Finalize (This.Pool_Attributes);
               raise;
         end;
         Pool_Attribute_Vectors.Finalize (This.Pool_Attributes);
      end Finalize_Pool_Attributes;

      procedure Finalize_XML_Tags is
      begin
         begin
            Finalize_Pool_Nodes;
         exception
            when others =>
               XML_Tag_Vectors.Finalize (This.XML_Tags);
               raise;
         end;
         XML_Tag_Vectors.Finalize (This.XML_Tags);
      end Finalize_XML_Tags;

      procedure Finalize_Pool_Nodes is
      begin
         Pool_Node_Vectors.Finalize (This.Pool_Nodes);
      end Finalize_Pool_Nodes;

   begin
      Finalize_Tags_Store;
   end Finalize;

   procedure Statistics
     (This   : Memory_Pool;
      Result : out Memory_Pool_Statistics) is
   begin
      Pool_Node_Vectors.Statistics
        (This   => This.Pool_Nodes,
         Result => Result.Pool_Nodes);
      Pool_Attribute_Vectors.Statistics
        (This   => This.Pool_Attributes,
         Result => Result.Pool_Attributes);
      XML_Tag_Vectors.Statistics
        (This   => This.XML_Tags,
         Result => Result.XML_Elements);
      UTF8_Store.Statistics
        (This   => This.Strings_Map,
         Result => Result.Strings_Map);
      Elements_Store.Statistics
        (This   => This.Component_Key_To_XML_Element,
         Result => Result.Component_Key_To_XML_Element);
      Children_Id_To_Arrays.Statistics
        (This   => This.Children_Id_To_Array,
         Result => Result.Children_Id_To_Arrays);
      Attributes_Collections.Statistics
        (This   => This.Attributes_Collection,
         Result => Result.Attributes_Collection);
   end Statistics;

end Std.XML.DOM_Parser;
