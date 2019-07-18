with Ada.Unchecked_Deallocation;
package body Std.Containers.Unbounded_Key_Value_Store is

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => Elements_Array,
      Name   => Elements_Array_Ptr);

   procedure Initialize (This : out Key_Value_Store) is
   begin
      This.Elements
        := new Elements_Array
          (Index'First .. Index'First + This.Initial_Values_Count - 1);
      This.Next_Available_List_Index := 1;
      This.Last_Index := Extended_Index'First;
   end Initialize;

   procedure Finalize (This : in out Key_Value_Store) is
   begin
      Free (This.Elements);
   end Finalize;

   function Create_Key
     (This : access Key_Value_Store) return Key_Type
   is
      Result : Key_Type;
   begin
      Create_Key (This.all, Result);
      return Result;
   end Create_Key;

   procedure Create_Key
     (This : in out Key_Value_Store;
      Key  : out Key_Type) is
   begin
      Key := This.Next_Available_List_Index;

      if This.Last_Index = Extended_Index'First then
         This.Last_Index := Index'First;
      elsif This.Last_Index < This.Elements.all'Last then
         This.Last_Index := This.Last_Index + 1;
      else
         declare
            Larger_Vector : constant Elements_Array_Ptr
              := new Elements_Array
                (Index'First ..
                   Index'First + This.Elements.all'Length * 2 - 1);
         begin
            for I in This.Elements'Range loop
               Larger_Vector (I) := This.Elements (I);
            end loop;
            Free (This.Elements);
            This.Elements := Larger_Vector;
         end;
         This.Last_Index := This.Last_Index + 1;
      end if;

      This.Next_Available_List_Index := This.Next_Available_List_Index + 1;
   end Create_Key;

   procedure Set_Value
     (This  : in out Key_Value_Store;
      Key   : Key_Type;
      Value : Value_Type)
   is
   begin
      This.Elements (Key) := Value;
   end Set_Value;

   function Value
     (This : Key_Value_Store;
      Key  : Key_Type) return Value_Type
   is
   begin
      return This.Elements (Key);
   end Value;

   function Keys_In_Use_Count (This : Key_Value_Store) return Nat32 is
   begin
      return Nat32 (This.Last_Index);
   end Keys_In_Use_Count;

   procedure Statistics
     (This   : Key_Value_Store;
      Result : out Statistics_Unbounded_Key_Value_Store) is
   begin
      Result.Used_Elements_Count := Octet_Count (This.Last_Index);
      Result.Preallocated_Count  := This.Elements.all'Length;
   end Statistics;

end Std.Containers.Unbounded_Key_Value_Store;
