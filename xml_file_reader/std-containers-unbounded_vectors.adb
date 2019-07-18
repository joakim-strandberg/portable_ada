with Ada.Unchecked_Deallocation;
package body Std.Containers.Unbounded_Vectors is

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => Elements_Array,
      Name   => Elements_Array_Ptr);

   function Last_Index (This : Vector) return Extended_Index is
   begin
      return This.Last_Index;
   end Last_Index;

   function Is_Empty (This : Vector) return Boolean is
   begin
      return This.Last_Index = Extended_Index'First;
   end Is_Empty;

   function Is_Full (This : Vector) return Boolean is
   begin
      return This.Last_Index = Extended_Index'Last;
   end Is_Full;

   function "=" (L, R : Vector) return Boolean is
      Result : Boolean := True;
   begin
      if Last_Index (L) = Last_Index (R) then
         for I in Index range Index'First .. Last_Index (L) loop
            if L.Items (I) /= R.Items (I) then
               Result := False;
               exit;
            end if;
         end loop;
      else
         Result := False;
      end if;

      return Result;
   end "=";

   procedure Append
     (This     : in out Vector;
      New_Item : Element_Type) is
   begin
      if This.Last_Index = Extended_Index'First then
         This.Last_Index := Index'First;
         This.Items (Index'First) := New_Item;
      elsif This.Last_Index < This.Items.all'Last then
         This.Last_Index := This.Last_Index + 1;
         This.Items (Index (This.Last_Index)) := New_Item;
      else
         declare
            Larger_Vector : constant Elements_Array_Ptr
              := new Elements_Array
                (Index'First .. Index'First + This.Items.all'Length * 2 - 1);
         begin
            for I in This.Items'Range loop
               Larger_Vector (I) := This.Items (I);
            end loop;
            Free (This.Items);
            This.Items := Larger_Vector;
         end;
         This.Last_Index := This.Last_Index + 1;
         This.Items (Index (This.Last_Index)) := New_Item;
      end if;
   end Append;

   function Contains
     (This    : Vector;
      Element : Element_Type) return Boolean
   is
      Result : Boolean := False;
   begin
      for I in Extended_Index range Index'First .. This.Last_Index loop
         if This.Items (I) = Element then
            Result := True;
            exit;
         end if;
      end loop;
      return Result;
   end Contains;

   function Element
     (This  : Vector;
      Idx   : Index) return Element_Type is
   begin
      return This.Items (Idx);
   end Element;

   function Element_Reference
     (This  : Vector;
      Idx   : Index) return Element_Ptr is
   begin
      return This.Items (Idx)'Access;
   end Element_Reference;

   function Last_Element (This : Vector) return Element_Type is
   begin
      return This.Items (Index (This.Last_Index));
   end Last_Element;

   function Last_Element_Reference
     (This  : Vector) return Element_Ptr is
   begin
      return This.Items (Index (This.Last_Index))'Access;
   end Last_Element_Reference;

   procedure Delete_Last (This : in out Vector) is
   begin
      This.Last_Index := This.Last_Index - 1;
   end Delete_Last;

   procedure Clear (This : in out Vector) is
   begin
      This.Last_Index := Extended_Index'First;
   end Clear;

   procedure Replace_Element
     (This        : in out Vector;
      Idx         : Index;
      New_Element : Element_Type) is
   begin
      This.Items (Idx) := New_Element;
   end Replace_Element;

   procedure Replace_Last_Element
     (This        : in out Vector;
      New_Element : Element_Type) is
   begin
      This.Items (Last_Index (This)) := New_Element;
   end Replace_Last_Element;

   function Elements_Reference (This : Vector) return Constant_Elements_Ptr is
   begin
      return This.Items.all'Access;
   end Elements_Reference;

   procedure Finalize (This : in out Vector) is
   begin
      This.Last_Index := 0;
      Free (This.Items);
   end Finalize;

   procedure Initialize (This : out Vector) is
   begin
      if Index'First /= 1 then
         raise Constraint_Error;
      end if;
      This.Items
        := new Elements_Array
          (Index'First .. Index'First + This.Initial_Elements_Count - 1);
   end Initialize;

   procedure Statistics
     (This   : Vector;
      Result : out Statistics_Unbounded_Vector) is
   begin
      Result.Used_Elements_Count
        := Octet_Count (This.Last_Index);
      Result.Preallocated_Count
        := This.Items'Length;
   end Statistics;

end Std.Containers.Unbounded_Vectors;
