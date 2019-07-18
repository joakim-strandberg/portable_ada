with Ada.Unchecked_Deallocation;
package body Std.Containers.Unbounded_Memory_Pool is

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => Elements_Array,
      Name   => Elements_Array_Ptr);

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => Id_To_Elements_Array,
      Name   => Id_To_Elements_Array_Ptr);

   function Last_Index (This : Element_Preallocator) return Extended_Index_T is
      Zeroeth_Index : Extended_Array_Id := 0;
   begin
      for Id in Array_Id range
        Array_Id'First .. This.Last_Index - 1
      loop
         Zeroeth_Index := Zeroeth_Index + This.Items (Id).all'Last;
      end loop;
      return Zeroeth_Index + This.Next - 1;
   end Last_Index;

   procedure Append_Extra
     (This     : in out Element_Preallocator;
      New_Item : Elements_Array_Ptr);

   procedure Append_Extra
     (This     : in out Element_Preallocator;
      New_Item : Elements_Array_Ptr) is
   begin
      if This.Last_Index = Extended_Array_Id'First then
         This.Last_Index := Array_Id'First;
         This.Items (Array_Id'First) := New_Item;
      elsif
        This.Last_Index < This.Items.all'Last
      then
         This.Last_Index := This.Last_Index + 1;
         This.Items (Array_Id (This.Last_Index)) := New_Item;
      else
         declare
            Larger_Element_Preallocator : constant Id_To_Elements_Array_Ptr
              := new Id_To_Elements_Array
                (Array_Id'First .. Array_Id'First +
                   This.Items.all'Length * 2);
         begin
            for I in This.Items'Range loop
               Larger_Element_Preallocator (I) := This.Items (I);
            end loop;
            Free (This.Items);
            This.Items := Larger_Element_Preallocator;
         end;
         This.Last_Index
           := This.Last_Index + 1;
         This.Items (Array_Id (This.Last_Index)) := New_Item;
      end if;
   end Append_Extra;

   procedure Append
     (This     : in out Element_Preallocator;
      New_Item : out Element_Ptr) is
   begin
      if This.Items (This.Last_Index).all'Last < This.Next then
         declare
            A : constant Elements_Array_Ptr
              := new Elements_Array
                (1 .. 2 * This.Items (This.Last_Index).all'Length);
         begin
            Append_Extra (This, A);
            This.Next := 1;
         end;
      end if;

      New_Item := This.Items (This.Last_Index).all (This.Next)'Access;

      This.Next := This.Next + 1;
   end Append;

   function Element
     (This  : Element_Preallocator;
      Index : Index_T) return Element_Ptr
   is
      Zeroeth_Index : Extended_Array_Id := 0;
   begin
      for Id in Array_Id range Array_Id'First .. This.Last_Index loop
         if Index <= Zeroeth_Index + This.Items (Id).all'Last then
            return This.Items (Id).all (Index - Zeroeth_Index)'Access;
         end if;
         Zeroeth_Index := Zeroeth_Index + This.Items (Id).all'Last;
      end loop;
      raise Constraint_Error;
   end Element;

   procedure Initialize
     (This : out Element_Preallocator)
   is
      A : Elements_Array_Ptr;
   begin
      This.Items := new Id_To_Elements_Array
        (Array_Id'First .. Array_Id'First + 8 - 1);
      A := new Elements_Array (1 .. This.Initial_Elements_Count);
      Append_Extra
        (This     => This,
         New_Item => A);
   end Initialize;

   procedure Finalize (This : in out Element_Preallocator) is
   begin
      This.Last_Index := 0;

      for I in This.Items'Range loop
         if This.Items (I) /= null then
            Free (This.Items (I));
         end if;
      end loop;

      Free (This.Items);
   end Finalize;

   procedure Statistics
     (This   : Element_Preallocator;
      Result : out Statistics_Unbounded_Memory_Pool)
   is
      Preallocated_Count : Octet_Count := 0;
   begin
      Result.Used_Elements_Count := 0;

      for I in This.Items'Range loop
         if This.Items (I) /= null then
            if I = This.Last_Index then
               Result.Used_Elements_Count
                 := Result.Used_Elements_Count + Octet_Count (This.Next - 1);
            else
               Result.Used_Elements_Count
                 := Result.Used_Elements_Count + This.Items (I).all'Length;
            end if;

            Preallocated_Count
              := Preallocated_Count + This.Items (I).all'Length;
         end if;
      end loop;

      Result.Preallocated_Count := Preallocated_Count;
   end Statistics;

end Std.Containers.Unbounded_Memory_Pool;
