with Std.UTF8;
pragma Elaborate_All (Std.UTF8);

with Std.XML_UTF8_SAX_Parsers;
pragma Elaborate_All (Std.XML_UTF8_SAX_Parsers);

with Std.XML_Header_Parsers;
pragma Elaborate_All (Std.XML_Header_Parsers);

package body Std.XML_UTF8_DOM_Parsers is

   use Node_Vectors;
   use type Std.XML_Header_Parsers.XML_Document_Kind;

   procedure Create_Key
     (This : in out Children_Key_Array_Store;
      Key  : out Node_Children_Key) is
   begin
      This.Last_Key_Index := This.Last_Key_Index + 1;
      This.Keys (This.Last_Key_Index)
        := (First_Index => 0, Last_Index => 0);
      Key := This.Last_Key_Index;
   end Create_Key;

   procedure Add_To_Array
     (This    : in out Children_Key_Array_Store;
      Key     : Node_Children_Key;
      Element : XML_Node_Const_Ptr)
   is
   begin
      This.Last_List_Index := This.Last_List_Index + 1;
      This.List (This.Last_List_Index)
        := (Element => Element, Next => 0);
      if This.Keys (Key).First_Index = 0 then
         This.Keys (Key) := (First_Index => This.Last_List_Index,
                             Last_Index  => This.Last_List_Index);
      else
         This.List (This.Keys (Key).Last_Index).Next
           := This.Last_List_Index;
         This.Keys (Key).Last_Index := This.Last_List_Index;
      end if;
   end Add_To_Array;

   function Get_Array
     (This : Children_Key_Array_Store;
      Key  : Node_Children_Key) return Node_Const_Ptr_Array
   is
      function Items_Count return Pos32;

      function Items_Count return Pos32 is
         Index : Pos32 := This.Keys (Key).First_Index;
         Count : Pos32 := 1;
      begin
         while This.List (Index).Next /= 0 loop
            Index := This.List (Index).Next;
            Count := Count + 1;
         end loop;
         return Count;
      end Items_Count;
   begin
      if This.Keys (Key).First_Index = 0 then
         declare
            Empty_Array : constant Node_Const_Ptr_Array (1 .. 0)
              := (others => Default_Node'Access);
         begin
            return Empty_Array;
         end;
      else
         declare
            Result : Node_Const_Ptr_Array (1 .. Items_Count)
              := (others => Default_Node'Access);
            Result_Index : Pos32 := 1;
            Index : Pos32 := This.Keys (Key).First_Index;
         begin
            Result (1) := This.List (Index).Element;
            while This.List (Index).Next /= 0 loop
               Index                 := This.List (Index).Next;
               Result_Index          := Result_Index + 1;
               Result (Result_Index) := This.List (Index).Element;
            end loop;
            return Result;
         end;
      end if;
   end Get_Array;

   procedure Create_Key
     (This : in out Attributes_Key_Array_Store;
      Key  : out Tag_Attributes_Key) is
   begin
      This.Last_Key_Index := This.Last_Key_Index + 1;
      This.Keys (This.Last_Key_Index)
        := (First_Index => 0, Last_Index => 0);
      Key := This.Last_Key_Index;
   end Create_Key;

   procedure Add_To_Array
     (This    : in out Attributes_Key_Array_Store;
      Key     : Tag_Attributes_Key;
      Element : XML_Attribute_Const_Ptr)
   is
   begin
      This.Last_List_Index := This.Last_List_Index + 1;
      This.List (This.Last_List_Index)
        := (Element => Element, Next => 0);
      if This.Keys (Key).First_Index = 0 then
         This.Keys (Key) := (First_Index => This.Last_List_Index,
                             Last_Index  => This.Last_List_Index);
      else
         This.List (This.Keys (Key).Last_Index).Next
           := This.Last_List_Index;
         This.Keys (Key).Last_Index := This.Last_List_Index;
      end if;
   end Add_To_Array;

   function Get_Array
     (This : Attributes_Key_Array_Store;
      Key  : Tag_Attributes_Key) return Attribute_Ptr_Array
   is
      function Items_Count return Pos32;

      function Items_Count return Pos32 is
         Index : Pos32 := This.Keys (Key).First_Index;
         Count : Pos32 := 1;
      begin
         while This.List (Index).Next /= 0 loop
            Index := This.List (Index).Next;
            Count := Count + 1;
         end loop;
         return Count;
      end Items_Count;
   begin
      if This.Keys (Key).First_Index = 0 then
         declare
            Empty_Array : constant Attribute_Ptr_Array (1 .. 0)
              := (others => Default_Attribute'Access);
         begin
            return Empty_Array;
         end;
      else
         declare
            Result : Attribute_Ptr_Array (1 .. Items_Count)
              := (others => Default_Attribute'Access);
            Result_Index : Pos32 := 1;
            Index : Pos32 := This.Keys (Key).First_Index;
         begin
            Result (1) := This.List (Index).Element;
            while This.List (Index).Next /= 0 loop
               Index                 := This.List (Index).Next;
               Result_Index          := Result_Index + 1;
               Result (Result_Index) := This.List (Index).Element;
            end loop;
            return Result;
         end;
      end if;
   end Get_Array;
   function "+"(Right : UTF8_Text) return Octet_Array is
   begin
      return Bounded_Strings_Map.Value (Right.Map.all.Strings_Map, Right.Key);
   end "+";

   function "+" (Right : XML_Element_Attributes) return Attribute_Ptr_Array is
   begin
      return Get_Array
        (This => Right.Map.all.Key_To_Attributes_Store,
         Key  => Right.Key);
   end "+";

   function "+" (Right : XML_Element_Children) return Node_Const_Ptr_Array is
   begin
      return Get_Array
        (This => Right.Map.all.Children_Id_To_Array,
         Key  => Right.Key);
   end "+";

   type State_T is
     (
      Expecting_Object_Start,
      --  seems to only apply to the root start tag

      Expecting_Default,
      --  Attribute_Or_Text_Or_Comment_Or_CDATA_Or_Object_Start_Or_Object_End

      End_State
     );

   type DOM_Parser
     (Pool     : Memory_Pool_Ptr)
   is limited record
      Root_Node     : XML_Node_Ptr := null;
      State         : State_T := Expecting_Object_Start;
   end record;

   procedure Start_Tag
     (This        : in out DOM_Parser;
      Tag_Name    : Octet_Array;
      Call_Result : in out Subprogram_Call_Result);

   procedure End_Tag
     (This        : in out DOM_Parser;
      Tag_Name    : Octet_Array;
      Call_Result : in out Subprogram_Call_Result);

   procedure Text
     (This        : in out DOM_Parser;
      Value       : Octet_Array;
      Call_Result : in out Subprogram_Call_Result);

   procedure Handle_Attribute
     (This            : in out DOM_Parser;
      Attribute_Name  : Octet_Array;
      Attribute_Value : Octet_Array;
      Call_Result     : in out Subprogram_Call_Result);

   procedure Comment
     (This        : in out DOM_Parser;
      Value       : Octet_Array;
      Call_Result : in out Subprogram_Call_Result);

   procedure CDATA
     (This        : in out DOM_Parser;
      Value       : Octet_Array;
      Call_Result : in out Subprogram_Call_Result);

   procedure SAX_Parser_Body is new Std.XML_UTF8_SAX_Parsers.Parse_Body
     (SAX_Parser       => DOM_Parser,
      Start_Tag        => Start_Tag,
      End_Tag          => End_Tag,
      Text             => Text,
      Handle_Attribute => Handle_Attribute,
      Comment          => Comment,
      CDATA            => CDATA);

   procedure New_Node
     (Pool        : Memory_Pool_Ptr;
      Kind_Id     : Node_Kind_Id;
      Node        : out XML_Node_Ptr;
      Call_Result : in out Subprogram_Call_Result);

   procedure Start_Tag
     (This        : in out DOM_Parser;
      Tag_Name    : Octet_Array;
      Call_Result : in out Subprogram_Call_Result) is
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
                  New_Node (This.Pool,
                            Node_Kind_Tag,
                            Current_Node,
                            Call_Result);

                  if Call_Result.Has_Failed then
                     return;
                  end if;

                  declare
                     Key : Bounded_String_Key;
                  begin
                     Bounded_Strings_Map.Append
                       (This        => This.Pool.Strings_Map,
                        Value       => Tag_Name,
                        Key         => Key,
                        Call_Result => Call_Result);

                     if Call_Result.Has_Failed then
                        return;
                     end if;

                     Current_Node.Element.Name
                       := (Key => Key,
                           Map => This.Pool);
                  end;

                  Append (This.Pool.Current_Nodes, Current_Node);
                  This.Root_Node := Current_Node;
               end;
               This.State := Expecting_Default;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => -2132671123,
                                    Code_2 => 1966624808));
            end if;
         when Expecting_Default =>
            if
              Tag_Name'Length > 0
            then
               declare
                  Current_Node : XML_Node_Ptr;
                  Const_Current_Node : XML_Node_Const_Ptr;
               begin
                  New_Node (This.Pool,
                            Node_Kind_Tag,
                            Current_Node,
                            Call_Result);

                  if Call_Result.Has_Failed then
                     return;
                  end if;

                  Const_Current_Node := Current_Node.all'Access;

                  declare
                     Key : Bounded_String_Key;
                  begin
                     Bounded_Strings_Map.Append
                       (This        => This.Pool.Strings_Map,
                        Value       => Tag_Name,
                        Key         => Key,
                        Call_Result => Call_Result);

                     if Call_Result.Has_Failed then
                        return;
                     end if;

                     Current_Node.Element.Name
                       := (Key => Key,
                           Map => This.Pool);
                  end;

                  if Element
                    (This.Pool.Current_Nodes,
                     Last_Index (This.Pool.Current_Nodes)).all.Id
                      = Node_Kind_Tag
                  then
                     declare
                        Key : constant Node_Children_Key
                          := Node_Vectors.Last_Element
                            (This.Pool.Current_Nodes).Element.Children.Key;
                     begin
                        Add_To_Array
                          (This    => This.Pool.Children_Id_To_Array,
                           Key     => Key,
                           Element => Const_Current_Node);
                     end;

                     Append (This.Pool.Current_Nodes, Current_Node);
                  else
                     Call_Result
                       := (Has_Failed => True,
                           Codes      => (1695756105, 1714042669));
                  end if;
               end;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (-0416079960, -1464855808));
            end if;
         when End_State =>
            Call_Result
              := (Has_Failed => True,
                  Codes      => (0561631589, 0761077416));
      end case;
   end Start_Tag;

   procedure End_Tag
     (This        : in out DOM_Parser;
      Tag_Name    : Octet_Array;
      Call_Result : in out Subprogram_Call_Result) is
   begin
      --  Ada.Text_IO.Put_Line ("End: " & UTF8.Image (Tag_Name));
      case This.State is
         when Expecting_Default =>
            if not Is_Empty (This.Pool.Current_Nodes) and then
              Element
                (This.Pool.Current_Nodes,
                 Last_Index (This.Pool.Current_Nodes)).Id =
                  Node_Kind_Tag
            then
               if
                 (+Last_Element (This.Pool.Current_Nodes).Element.Name) = Tag_Name
               then
                  Delete_Last (This.Pool.Current_Nodes);
                  if Is_Empty (This.Pool.Current_Nodes) then
                     This.State := End_State;
                  end if;
               else
                  Call_Result
                    := (Has_Failed => True,
                        Codes      => (-0316487383, -2063296151));
               end if;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (-1355522791, 1675536860));
            end if;
         when Expecting_Object_Start |
              End_State =>
            Call_Result
              := (Has_Failed => True,
                  Codes      => (-0728861922, -0299445966));
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
      Call_Result : in out Subprogram_Call_Result) is
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
                  Const_Current_Node : XML_Node_Const_Ptr;
                  Text_Key : Bounded_String_Key;
               begin
                  New_Node
                    (This.Pool,
                     Node_Kind_Text,
                     Current_Node,
                     Call_Result);

                  if Call_Result.Has_Failed then
                     return;
                  end if;

                  Const_Current_Node := Current_Node.all'Access;

                  Bounded_Strings_Map.Append
                    (This        => This.Pool.Strings_Map,
                     Value       => Value,
                     Key         => Text_Key,
                     Call_Result => Call_Result);

                  if Call_Result.Has_Failed then
                     return;
                  end if;

                  Current_Node.Text := (Key => Text_Key,
                                        Map => This.Pool);

                  if
                    Element
                      (This.Pool.Current_Nodes,
                       Last_Index (This.Pool.Current_Nodes)).Id =
                        Node_Kind_Tag
                  then
                     Add_To_Array
                       (This    => This.Pool.Children_Id_To_Array,
                        Key     => (+Last_Element
                                    (
                                         This.Pool.Current_Nodes
                                        ).Element.Children.Key),
                        Element => Const_Current_Node);
                  else
                     Call_Result
                       := (Has_Failed => True,
                           Codes      => (-0944309962, -0212130363));
                  end if;
               end;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (0536156601, 0921613311));
            end if;
         when Expecting_Object_Start |
              End_State =>
            Call_Result
              := (Has_Failed => True,
                  Codes      => (0240750889, 1723362921));
      end case;
   end Text;

   procedure Handle_Attribute
     (This            : in out DOM_Parser;
      Attribute_Name  : Octet_Array;
      Attribute_Value : Octet_Array;
      Call_Result     : in out Subprogram_Call_Result) is
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
                     Attribute : XML_Attribute_Ptr;
                     Constant_Attribute : XML_Attribute_Const_Ptr;
                  begin
                     if This.Pool.Next_Attribute < This.Pool.Attribute'Last then
                        This.Pool.Next_Attribute
                          := This.Pool.Next_Attribute + 1;
                        Attribute := This.Pool.Attribute
                          (This.Pool.Next_Attribute)'Access;
                        Constant_Attribute := This.Pool.Attribute
                          (This.Pool.Next_Attribute)'Access;
                     else
                        Call_Result
                          := (Has_Failed => True,
                              Codes      => (1570324728, -0541661184));
                        return;
                     end if;

                     declare
                        Key : Bounded_String_Key;
                     begin
                        Bounded_Strings_Map.Append
                          (This        => This.Pool.Strings_Map,
                           Value       => Attribute_Name,
                           Key         => Key,
                           Call_Result => Call_Result);

                        if Call_Result.Has_Failed then
                           return;
                        end if;

                        Attribute.Name
                          := (Key => Key,
                              Map => This.Pool);
                     end;

                     declare
                        Key : Bounded_String_Key;
                     begin
                        Bounded_Strings_Map.Append
                          (This        => This.Pool.Strings_Map,
                           Value       => Attribute_Value,
                           Key         => Key,
                           Call_Result => Call_Result);

                        if Call_Result.Has_Failed then
                           return;
                        end if;

                        Attribute.Value
                          := (Key => Key,
                              Map => This.Pool);
                     end;

                     if
                       Element
                         (This.Pool.Current_Nodes,
                          Last_Index (This.Pool.Current_Nodes)).Id
                           = Node_Kind_Tag
                     then
                        Add_To_Array
                          (This    => This.Pool.Key_To_Attributes_Store,
                           Key     =>
                             Node_Vectors.Last_Element
                               (This.Pool.Current_Nodes).Element.Attributes.Key,
                           Element => Constant_Attribute);
                     else
                        Call_Result
                          := (Has_Failed => True,
                              Codes      => (0612916249, -0250963769));
                     end if;
                  end;
               else
                  Call_Result
                    := (Has_Failed => True,
                        Codes      => (-1091502024, -1483543078));
               end if;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (-0372407662, -1139199208));
            end if;
         when Expecting_Object_Start |
              End_State =>
            Call_Result
              := (Has_Failed => True,
                  Codes      => (1103012185, 0319457400));
      end case;
   end Handle_Attribute;

   procedure Comment
     (This        : in out DOM_Parser;
      Value       : Octet_Array;
      Call_Result : in out Subprogram_Call_Result) is
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
                     Text_Key : Bounded_String_Key;
                     Const_Current_Node : XML_Node_Const_Ptr;
                  begin
                     New_Node
                       (This.Pool,
                        Node_Kind_Comment,
                        Node,
                        Call_Result);

                     if Call_Result.Has_Failed then
                        return;
                     end if;

                     Const_Current_Node := Node.all'Access;

                     Bounded_Strings_Map.Append
                       (This        => This.Pool.Strings_Map,
                        Value       => Value,
                        Key         => Text_Key,
                        Call_Result => Call_Result);

                     if Call_Result.Has_Failed then
                        return;
                     end if;

                     Node.Text := (Key => Text_Key,
                                   Map => This.Pool);
                     if
                       Element
                         (This.Pool.Current_Nodes,
                          Last_Index (This.Pool.Current_Nodes)).Id
                           = Node_Kind_Tag
                     then
                        Add_To_Array
                          (This    => This.Pool.Children_Id_To_Array,
                           Key     =>
                             Last_Element
                               (This.Pool.Current_Nodes).Element.Children.Key,
                           Element => Const_Current_Node);
                     else
                        Call_Result
                          := (Has_Failed => True,
                              Codes      => (2066772500, 1193932906));
                     end if;
                  end;
               else
                  Call_Result
                    := (Has_Failed => True,
                        Codes      => (1366102371, 1421674126));
               end if;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (0845969060, 0639006566));
            end if;
         when Expecting_Object_Start |
              End_State =>
            Call_Result
              := (Has_Failed => True,
                  Codes      => (-1373186804, -0874315849));
      end case;
   end Comment;

   procedure CDATA
     (This        : in out DOM_Parser;
      Value       : Octet_Array;
      Call_Result : in out Subprogram_Call_Result) is
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
                     Text_Key : Bounded_String_Key;
                     Const_Current_Node : XML_Node_Const_Ptr;
                  begin
                     New_Node
                       (This.Pool,
                        Node_Kind_CDATA,
                        Node,
                        Call_Result);

                     if Call_Result.Has_Failed then
                        return;
                     end if;

                     Const_Current_Node := Node.all'Access;

                     Bounded_Strings_Map.Append
                       (This        => This.Pool.Strings_Map,
                        Value       => Value,
                        Key         => Text_Key,
                        Call_Result => Call_Result);

                     if Call_Result.Has_Failed then
                        return;
                     end if;

                     Node.Text := (Key => Text_Key,
                                   Map => This.Pool);

                     if
                       Element
                         (This.Pool.Current_Nodes,
                          Last_Index (This.Pool.Current_Nodes)).Id
                           = Node_Kind_Tag
                     then
                        Add_To_Array
                          (This    => This.Pool.Children_Id_To_Array,
                           Key     =>
                             Last_Element
                               (This.Pool.Current_Nodes).
                               Element.Children.Key,
                           Element => Const_Current_Node);
                     else
                        Call_Result
                          := (Has_Failed => True,
                              Codes      => (-2021174626, -1403249390));
                     end if;
                  end;
               else
                  Call_Result
                    := (Has_Failed => True,
                        Codes      => (1915730777, 1973598725));
               end if;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (-0076965217, 0193355440));
            end if;
         when Expecting_Object_Start |
              End_State =>
            Call_Result
              := (Has_Failed => True,
                  Codes      => (0698504230, -0963685542));
      end case;
   end CDATA;

   procedure Parse
     (Pool        : Memory_Pool_Ptr;
      XML_Message : in     Octet_Array;
      Call_Result : in out Subprogram_Call_Result;
      Root_Node   :    out XML_Node_Const_Ptr)
   is
      This : DOM_Parser (Pool.all'Access);
      --  Janus/Ada compiler generates faulty code when using instead:
      --  This : DOM_Parser (Pool);

      P : Octet_Offset := XML_Message'First;

      Kind : XML_Header_Parsers.XML_Document_Kind
        := XML_Header_Parsers.Not_Yet_Detetrmined;
   begin
      declare
         CP : Octet;
         Header_Parser : XML_Header_Parsers.Header_Parser;
      begin
         XML_Header_Parsers.Initialize (This     => Header_Parser);
         while P <= XML_Message'Last and not Call_Result.Has_Failed loop
            exit when Kind /= XML_Header_Parsers.Not_Yet_Detetrmined;

            CP := XML_Message (P);
            P := P + 1;

            XML_Header_Parsers.Parse_Header
              (This          => Header_Parser,
               CP            => CP,
               Document_Kind => Kind,
               Call_Result   => Call_Result);
         end loop;
      end;

      declare
         CP : UTF8.Code_Point;
         Body_Parser : XML_UTF8_SAX_Parsers.Body_Parser;
      begin
         if not Call_Result.Has_Failed then
            if Kind = XML_Header_Parsers.Document_Kind_UTF8 then
               if
                 UTF8.Is_Valid_UTF8_Code_Point
                   (Source => XML_Message, Pointer => P)
               then
                  UTF8.Get (Source => XML_Message, Pointer => P, Value => CP);

                  XML_UTF8_SAX_Parsers.Initialize
                    (This         => Body_Parser,
                     P            => P,
                     CP           => CP,
                     Call_Result  => Call_Result);

                  if not Call_Result.Has_Failed then
                     while
                       P <= XML_Message'Last and not Call_Result.Has_Failed
                     loop
                        if not UTF8.Is_Valid_UTF8_Code_Point
                          (Source => XML_Message, Pointer => P)
                        then
                           Call_Result
                             := (Has_Failed => True,
                                 Codes      => (0917933704, 1893541713));
                           exit;
                        end if;

                        UTF8.Get
                          (Source => XML_Message, Pointer => P, Value => CP);

                        SAX_Parser_Body
                          (This        => This,
                           Parser      => Body_Parser,
                           Contents    => XML_Message,
                           P           => P,
                           CP          => CP,
                           Call_Result => Call_Result);
                     end loop;

                     if
                       not Call_Result.Has_Failed
                     then
                        if
                          XML_UTF8_SAX_Parsers.Is_Parsing_Finished (Body_Parser)
                        then
                           Root_Node := This.Root_Node.all'Access;
                        else
                           Call_Result
                             := (Has_Failed => True,
                                 Codes      => (-2068412437, -0002457258));
                        end if;
                     end if;
                  end if;
               else
                  Call_Result
                    := (Has_Failed => True,
                        Codes      => (-1969620808, -0689239741));
               end if;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (0251026934, 0210354515));
            end if;
         end if;
      end;
   end Parse;

   procedure New_Node
     (Pool        : Memory_Pool_Ptr;
      Kind_Id     : Node_Kind_Id;
      Node        : out XML_Node_Ptr;
      Call_Result : in out Subprogram_Call_Result) is
   begin
      if Pool.Next_Node < Pool.Node'Last then
         Pool.Next_Node := Pool.Next_Node + 1;
         Node := Pool.Node (Pool.Next_Node)'Access;
      else
         Call_Result
           := (Has_Failed => True,
               Codes      => (-1277651768, 2021278481));
         return;
      end if;

      case Kind_Id is
         when Node_Kind_Tag =>
            declare
               Children_Key : Node_Children_Key;
               Attributes_Key : Tag_Attributes_Key;
            begin
               Create_Key
                 (This => Pool.Children_Id_To_Array,
                  Key  => Children_Key);

               Create_Key
                 (This => Pool.Key_To_Attributes_Store,
                  Key  => Attributes_Key);

               Pool.Node (Pool.Next_Node)
                 := (Id      => Node_Kind_Tag,
                     Element => (Children => (Key => Children_Key,
                                              Map => Pool),
                                 Attributes => (Key => Attributes_Key,
                                                Map => Pool),
                                 Name       => (Key => 1,
                                                Map => null)));
            end;
         when Node_Kind_Comment =>
            Pool.Node (Pool.Next_Node)
              := (Id => Node_Kind_Comment,
                  Text => (Key => 1,
                           Map => null));
         when Node_Kind_CDATA =>
            Pool.Node (Pool.Next_Node)
              := (Id => Node_Kind_CDATA,
                  Text => (Key => 1,
                           Map => null));
         when Node_Kind_Text =>
            Pool.Node (Pool.Next_Node)
              := (Id => Node_Kind_Text,
                  Text => (Key => 1,
                           Map => null));
      end case;
   end New_Node;

--     function Node_Children
--       (Pool    : Memory_Pool;
--        Element : XML_Element) return Node_Ptr_Array is
--     begin
--        return Children_Id_To_Arrays.Get_Array
--          (This => Pool.Children_Id_To_Array,
--           Key  => Element.Children_Id);
--     end Node_Children;
--
--     function Text
--       (Pool : Memory_Pool;
--        Key  : UTF8_Key) return Octet_Array is
--     begin
--        return UTF8_Store.Value
--          (This  => Pool.Strings_Map,
--           Index => Key);
--     end Text;
--
--     function Element
--       (Pool : Memory_Pool;
--        Key  : Node_Component_Key) return XML_Element_Ptr is
--     begin
--        return Elements_Store.Value
--          (Pool.Component_Key_To_XML_Element,
--           Key);
--     end Element;

--     procedure Statistics
--       (This   : Memory_Pool;
--        Result : out Memory_Pool_Statistics) is
--     begin
--        UTF8_Store.Statistics
--          (This   => This.Strings_Map,
--           Result => Result.Strings_Map);
--        Elements_Store.Statistics
--          (This   => This.Component_Key_To_XML_Element,
--           Result => Result.Component_Key_To_XML_Element);
--        Children_Id_To_Arrays.Statistics
--          (This   => This.Children_Id_To_Array,
--           Result => Result.Children_Id_To_Arrays);
--     end Statistics;

end Std.XML_UTF8_DOM_Parsers;
