with Std.Ada_Extensions; use Std.Ada_Extensions;

--  This package exists becaue there is some reason it isn't convenient
--  to instantiate the unbounded vectors package where the elements are octets.
package Std.Containers.Unbounded_Octet_Vectors is

   subtype Extended_Index is Octet_Offset'Base range 0 .. Octet_Offset'Last;

   type Element_Ptr is access all Octet;

   type Vector
     (
      Initial_Elements_Count : Octet_Offset
     )
   is limited private;
   --  The vector type is limited to avoid unnecessary copies

   procedure Initialize (This : out Vector);

   procedure Finalize (This : in out Vector);

   function "=" (L, R : Vector) return Boolean;

   procedure Append
     (This     : in out Vector;
      New_Item : Octet);

   function Contains
     (This    : Vector;
      Element : Octet) return Boolean;

   function Last_Index (This : Vector) return Extended_Index;
   --  The First_Index is Octet_Offset'First

   function Element
     (This  : Vector;
      Idx   : Octet_Offset) return Octet;

   function Element_Reference
     (This  : Vector;
      Idx   : Octet_Offset) return Element_Ptr;
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
      Idx         : Octet_Offset;
      New_Element : Octet);

   procedure Replace_Last_Element
     (This        : in out Vector;
      New_Element : Octet);

   function Is_Empty (This : Vector) return Boolean;

   function Is_Full (This : Vector) return Boolean;

   function Last_Element (This : Vector) return Octet;

   function Last_Element_Reference (This : Vector) return Element_Ptr;

   procedure Delete_Last (This : in out Vector);

   procedure Clear (This : in out Vector);

   type Constant_Elements_Ptr is access constant Octet_Array;

   function Elements_Reference (This : Vector) return Constant_Elements_Ptr;

private

   type Elements_Array_Ptr is access Octet_Array;

   type Vector
     (
      Initial_Elements_Count : Octet_Offset
     )
   is limited record
      Items : Elements_Array_Ptr;
      Last_Index : Extended_Index := Extended_Index'First;
   end record;

end Std.Containers.Unbounded_Octet_Vectors;
