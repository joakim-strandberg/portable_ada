package body Std.Bounded_Key_Array_Store is

--     function Create_Key
--       (This : access Key_Array_Store) return Key_Type is
--     begin
--        This.Last_Key_Index := This.Last_Key_Index + 1;
--        This.Keys (This.Last_Key_Index)
--          := (First_Index => 0, Last_Index => 0);
--        return This.Last_Key_Index;
--     end Create_Key;

   procedure Create_Key
     (This : in out Key_Array_Store;
      Key  : out Key_Type) is
   begin
      This.Last_Key_Index := This.Last_Key_Index + 1;
      This.Keys (This.Last_Key_Index)
        := (First_Index => 0, Last_Index => 0);
      Key := This.Last_Key_Index;
   end Create_Key;

   procedure Add_To_Array
     (This    : in out Key_Array_Store;
      Key     : Key_Type;
      Element : Value_Const_Ptr)
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
     (This : Key_Array_Store;
      Key  : Key_Type) return Values_Array
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
            Empty_Array : constant Values_Array (1 .. 0)
              := (others => Default_Const_Ptr_Value);
         begin
            return Empty_Array;
         end;
      else
         declare
            Result : Values_Array (1 .. Items_Count)
              := (others => Default_Const_Ptr_Value);
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

end Std.Bounded_Key_Array_Store;
