with Std.Ada_Extensions; use Std.Ada_Extensions;

pragma Elaborate_All (Std.Ada_Extensions);

generic
   type Key_Type is range <>;
   type Value_Type is private;
package Std.Containers.Unbounded_Key_Value_Store is

   type Key_Value_Store
     (
      Initial_Values_Count : Key_Type
      --  Specifies the total number of items in all the collections
      --  at initialization time.
     )
   is limited private;

   procedure Initialize (This : out Key_Value_Store);

   procedure Finalize (This : in out Key_Value_Store);

   function Create_Key
     (This : access Key_Value_Store) return Key_Type;
   --  The signature of this function should have been
   --  function Create_Key (This : in out Key_Value_Store) ...
   --  but in-out function parameters were introduced in Ada 2012.
   --
   --  It can happen that this function cannot be used by the rules of the
   --  Ada language (the GNAT compiler complains "illegal attribute for
   --  discriminant-dependend component" and Janus/Ada complains
   --  "*ERROR* A field which depends on a discriminant may
   --  not be renamed (6.4.19) [RM 3.10.2(26)]". In this case use
   --  the procedure version of this function instead.

   procedure Create_Key
     (This : in out Key_Value_Store;
      Key  : out Key_Type);

   procedure Set_Value
     (This    : in out Key_Value_Store;
      Key     : Key_Type;
      Value   : Value_Type);

   function Value
     (This : Key_Value_Store;
      Key  : Key_Type) return Value_Type;

   function Keys_In_Use_Count (This : Key_Value_Store) return Nat32;

   procedure Statistics
     (This   : Key_Value_Store;
      Result : out Statistics_Unbounded_Key_Value_Store);

private

   subtype Extended_Index is Key_Type'Base range 0 .. Key_Type'Last;

   subtype Index is
     Extended_Index range Extended_Index'First + 1 .. Extended_Index'Last;

   type Elements_Array is array (Index range <>) of aliased Value_Type;
   --  The array type is aliased to allow references to individual
   --  elements in the array.

   type Elements_Array_Ptr is access Elements_Array;

   type Key_Value_Store
     (
      Initial_Values_Count : Key_Type
     )
   is limited record
      Elements                  : Elements_Array_Ptr;
      Next_Available_List_Index : Key_Type;
      Last_Index                : Extended_Index;
   end record;
   --  The components of this record do not have default values.
   --- They are to be initialized before instances of this type is to be used
   --  in an application.

end Std.Containers.Unbounded_Key_Value_Store;
