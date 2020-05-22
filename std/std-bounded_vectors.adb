package body Std.Bounded_Vectors is

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
      return This.Last_Index = This.Capacity;
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
      This.Last_Index := This.Last_Index + 1;
      This.Items (Index (This.Last_Index)) := New_Item;
   end Append;

   function Contains
     (This         : Vector;
      Searched_For : Element_Type) return Boolean
   is
      Result : Boolean := False;
   begin
      for I in Extended_Index range Index'First .. This.Last_Index loop
         if This.Items (I) = Searched_For then
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
     (This  : access Vector;
      Idx   : Index) return Element_Ptr is
   begin
      return This.Items (Idx)'Access;
   end Element_Reference;

   function Last_Element (This : Vector) return Element_Type is
   begin
      return This.Items (Index (This.Last_Index));
   end Last_Element;

   function Last_Element_Reference
     (This : access Vector) return Element_Ptr is
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

   --  function Elements_Reference
   --    (This : access Vector) return Constant_Elements_Ptr is
   --  begin
   --     return This.all.Items'Access;
   --  end Elements_Reference;

end Std.Bounded_Vectors;
