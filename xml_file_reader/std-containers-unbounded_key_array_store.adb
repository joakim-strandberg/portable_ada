package body Std.Containers.Unbounded_Key_Array_Store is

   procedure Initialize (This : out Key_Array_Store) is
   begin
      Key_Vectors.Initialize (This.Keys);
      Linked_List_Vectors.Initialize (This.List);
   end Initialize;

   procedure Finalize (This : in out Key_Array_Store) is

      procedure Finalize_Linked_List;
      procedure Finalize_Keys;

      procedure Finalize_Keys is
      begin
         begin
            Finalize_Linked_List;
         exception
            when others =>
               Key_Vectors.Finalize (This.Keys);
               raise;
         end;
         Key_Vectors.Finalize (This.Keys);
      end Finalize_Keys;

      procedure Finalize_Linked_List is
      begin
         Linked_List_Vectors.Finalize (This.List);
      end Finalize_Linked_List;

   begin
      Finalize_Keys;
   end Finalize;

   function Create_Key
     (This : access Key_Array_Store) return Key_Type is
   begin
      Key_Vectors.Append (This.Keys, (First_Index => 0, Last_Index => 0));
      return Key_Vectors.Last_Index (This.Keys);
   end Create_Key;

   procedure Create_Key
     (This : in out Key_Array_Store;
      Key  : out Key_Type) is
   begin
      Key_Vectors.Append (This.Keys, (First_Index => 0, Last_Index => 0));
      Key := Key_Vectors.Last_Index (This.Keys);
   end Create_Key;

   procedure Add_To_Array
     (This    : in out Key_Array_Store;
      Key     : Key_Type;
      Element : Value_Type)
   is
   begin
      Linked_List_Vectors.Append
        (This     => This.List,
         New_Item => (Element => Element, Next => 0));
      declare
         Last_Index : constant Pos32
           := Linked_List_Vectors.Last_Index (This.List);
      begin
         if Key_Vectors.Element_Reference (This.Keys, Key).First_Index = 0 then
            Key_Vectors.Replace_Element
              (This        => This.Keys,
               Idx         => Key,
               New_Element =>
                 (First_Index => Last_Index,
                  Last_Index  => Last_Index));
         else
            Linked_List_Vectors.Element_Reference
              (This => This.List,
               Idx  => Key_Vectors.Element (This.Keys, Key).Last_Index).Next
                := Last_Index;
            Key_Vectors.Element_Reference
              (This => This.Keys,
               Idx  => Key).Last_Index := Last_Index;
         end if;
      end;
   end Add_To_Array;

   function Get_Array
     (This : Key_Array_Store;
      Key  : Key_Type) return Values_Array
   is
      function Items_Count return Pos32;

      function Items_Count return Pos32 is
         Index : Pos32 := Key_Vectors.Element (This.Keys, Key).First_Index;
         Count : Pos32 := 1;
      begin
         while Linked_List_Vectors.Element (This.List, Index).Next /= 0 loop
            Index := Linked_List_Vectors.Element (This.List, Index).Next;
            Count := Count + 1;
         end loop;
         return Count;
      end Items_Count;
   begin
      if Key_Vectors.Element_Reference (This.Keys, Key).First_Index = 0 then
         declare
            Empty_Array : Values_Array (1 .. 0);
         begin
            return Empty_Array;
         end;
      else
         declare
            Result : Values_Array (1 .. Items_Count);
            Result_Index : Pos32 := 1;
            Index : Pos32
              := Key_Vectors.Element_Reference (This.Keys, Key).First_Index;
         begin
            Result (1)
              := Linked_List_Vectors.Element (This.List, Index).Element;
            while Linked_List_Vectors.Element (This.List, Index).Next /= 0 loop
               Index := Linked_List_Vectors.Element (This.List, Index).Next;
               Result_Index := Result_Index + 1;
               Result (Result_Index)
                 := Linked_List_Vectors.Element (This.List, Index).Element;
            end loop;
            return Result;
         end;
      end if;
   end Get_Array;

   procedure Statistics
     (This   : Key_Array_Store;
      Result : out Statistics_Unbounded_Key_Array_Store) is
   begin
      Key_Vectors.Statistics
        (This   => This.Keys,
         Result => Result.Keys);
      Linked_List_Vectors.Statistics
        (This   => This.List,
         Result => Result.Values);
   end Statistics;

end Std.Containers.Unbounded_Key_Array_Store;
