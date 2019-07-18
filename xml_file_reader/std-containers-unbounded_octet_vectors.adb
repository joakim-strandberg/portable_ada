with Ada.Unchecked_Deallocation;

package body Std.Containers.Unbounded_Octet_Vectors is

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => Octet_Array,
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
         for I in Octet_Offset range
           Octet_Offset'First .. Last_Index (L)
         loop
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
      New_Item : Octet) is
   begin
      if This.Last_Index = Extended_Index'First then
         This.Last_Index := Octet_Offset'First;
         This.Items (Octet_Offset'First) := New_Item;
      elsif This.Last_Index < This.Items.all'Last then
         This.Last_Index := This.Last_Index + 1;
         This.Items (Octet_Offset (This.Last_Index)) := New_Item;
      else
         declare
            Larger_Vector : constant Elements_Array_Ptr
              := new Octet_Array
                (Octet_Offset'First ..
                   Octet_Offset'First + This.Items.all'Length * 2);
         begin
            for I in This.Items'Range loop
               Larger_Vector (I) := This.Items (I);
            end loop;
            Free (This.Items);
            This.Items := Larger_Vector;
         end;
         This.Last_Index := This.Last_Index + 1;
         This.Items (Octet_Offset (This.Last_Index)) := New_Item;
      end if;
   end Append;

   function Contains
     (This    : Vector;
      Element : Octet) return Boolean
   is
      Result : Boolean := False;
   begin
      for I in Extended_Index range Octet_Offset'First .. This.Last_Index loop
         if This.Items (I) = Element then
            Result := True;
            exit;
         end if;
      end loop;
      return Result;
   end Contains;

   function Element
     (This  : Vector;
      Idx   : Octet_Offset) return Octet is
   begin
      return This.Items (Idx);
   end Element;

   function Element_Reference
     (This  : Vector;
      Idx   : Octet_Offset) return Element_Ptr is
   begin
      return This.Items (Idx)'Access;
   end Element_Reference;

   function Last_Element (This : Vector) return Octet is
   begin
      return This.Items (Octet_Offset (This.Last_Index));
   end Last_Element;

   function Last_Element_Reference
     (This  : Vector) return Element_Ptr is
   begin
      return This.Items (Octet_Offset (This.Last_Index))'Access;
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
      Idx         : Octet_Offset;
      New_Element : Octet) is
   begin
      This.Items (Idx) := New_Element;
   end Replace_Element;

   procedure Replace_Last_Element
     (This        : in out Vector;
      New_Element : Octet) is
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
      This.Items
        := new Octet_Array (Octet_Offset'First .. This.Initial_Elements_Count);
   end Initialize;

end Std.Containers.Unbounded_Octet_Vectors;
