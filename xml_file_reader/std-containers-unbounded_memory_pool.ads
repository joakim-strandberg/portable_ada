with Std.Ada_Extensions; use Std.Ada_Extensions;

--  Has responsibility of all heap allocated objects.
generic
   type Element_Type is limited private;
   type Element_Ptr is access all Element_Type;
package Std.Containers.Unbounded_Memory_Pool is

   subtype Extended_Index_T is Int32 range Int32'First .. Int32'Last;

   subtype Index_T is
     Extended_Index_T range Int32'First + 1 .. Extended_Index_T'Last;

   type Element_Preallocator
     (Initial_Elements_Count : Pos32)
   is limited private;
   --  The type is limited to avoid unnecessary copies

   procedure Initialize
     (This : out Element_Preallocator);

   procedure Finalize (This : in out Element_Preallocator);

   procedure Append
     (This     : in out Element_Preallocator;
      New_Item : out Element_Ptr);

   function Last_Index (This : Element_Preallocator) return Extended_Index_T;

   function Element
     (This  : Element_Preallocator;
      Index : Index_T) return Element_Ptr;

   procedure Statistics
     (This   : Element_Preallocator;
      Result : out Statistics_Unbounded_Memory_Pool);

private

   type Elements_Array is array (Index_T range <>) of aliased Element_Type;

   type Elements_Array_Ptr is access all Elements_Array;

   subtype Extended_Array_Id is Pos32'Base range 0 .. Pos32'Last;

   subtype Array_Id is
     Extended_Array_Id range
       Extended_Array_Id'First + 1 .. Extended_Array_Id'Last;

   type Id_To_Elements_Array is
     array (Array_Id range <>) of Elements_Array_Ptr;

   type Id_To_Elements_Array_Ptr is access Id_To_Elements_Array;

   type Element_Preallocator
     (Initial_Elements_Count : Pos32)
   is record
      Items : Id_To_Elements_Array_Ptr;
      --
      --  Items is an array of arrays. Illustration:
      --
      --                         ---
      --                         | |
      --               ---  ---  ---
      --               | |  | |  | |
      --               ---  ---  ---
      --               | |  | |  | |
      --               ---  ---  ---
      --  Array index:  1    2    3
      --
      --  In this example Items is an array with three elements identified
      --  by Array index 1, 2 and 3. Each element is an array of elements
      --  where the first two arrays contains 2 elements and the third
      --  contains 3 elements.

      Last_Index : Extended_Array_Id := Extended_Array_Id'First;
      --  Specifies the index of the array where new elements
      --  can be taken from.
      Next           : Pos32 := 1;
   end record;

end Std.Containers.Unbounded_Memory_Pool;
