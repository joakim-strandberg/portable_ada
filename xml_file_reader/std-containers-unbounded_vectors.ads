generic
   type Element_Type is private;
   type Index is range <>;
   type Elements_Array is array (Index range <>) of aliased Element_Type;
   --  The array type is aliased to allow references to individual
   --  elements in the array.
package Std.Containers.Unbounded_Vectors is

   subtype Extended_Index is Index'Base range 0 .. Index'Last;

   type Element_Ptr is access all Element_Type;

   type Vector
     (
      Initial_Elements_Count : Index
     )
   is limited private;
   --  The vector type is limited to avoid unnecessary copies

   procedure Initialize (This : out Vector);

   procedure Finalize (This : in out Vector);

   function "=" (L, R : Vector) return Boolean;

   procedure Append
     (This     : in out Vector;
      New_Item : Element_Type);

   function Contains
     (This    : Vector;
      Element : Element_Type) return Boolean;

   --  function First_Index (This : Vector) return Index;

   function Last_Index (This : Vector) return Extended_Index;

   function Element
     (This  : Vector;
      Idx   : Index) return Element_Type;

   function Element_Reference
     (This  : Vector;
      Idx   : Index) return Element_Ptr;
   --  It might be controversial with returning an access type value in
   --  this function, what if somebody would do Unchecked_Deallocation on
   --  the access type? One strategy is to minimize the number of packages
   --  that make use of Unchecked_Deallocation by using AdaControl that
   --  may forbid usage of Unchecked_Deallocation except for a number
   --  of specified exceptions (list of packages
   --  allowed to use unchedked deallocation). In addition,
   --  what if some global variable stores the access type value beyond
   --  the life-time of the element? Again, static code analysis by
   --  AdaControl can forbid global access type variables.
   --  Therefore, it is here attempted to allow the existence of this function.
   --  Maybe the test of time will prove this vector design decision wrong.

   procedure Replace_Element
     (This        : in out Vector;
      Idx         : Index;
      New_Element : Element_Type);

   procedure Replace_Last_Element
     (This        : in out Vector;
      New_Element : Element_Type);

   function Is_Empty (This : Vector) return Boolean;

   function Is_Full (This : Vector) return Boolean;

   function Last_Element (This : Vector) return Element_Type;

   function Last_Element_Reference (This : Vector) return Element_Ptr;

   procedure Delete_Last (This : in out Vector);

   procedure Clear (This : in out Vector);

   type Constant_Elements_Ptr is access constant Elements_Array;

   function Elements_Reference (This : Vector) return Constant_Elements_Ptr;

   procedure Statistics
     (This   : Vector;
      Result : out Statistics_Unbounded_Vector);

private

   type Elements_Array_Ptr is access Elements_Array;

   type Vector
     (
      Initial_Elements_Count : Index
     )
   is limited record
      Items : Elements_Array_Ptr;
      Last_Index : Extended_Index := Extended_Index'First;
   end record;

end Std.Containers.Unbounded_Vectors;
