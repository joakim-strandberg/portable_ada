with Std.Ada_Extensions; use Std.Ada_Extensions;

with Std.Containers.Unbounded_Vectors;
--  Should be "private with" but Corder doesn't like it.

pragma Elaborate_All (Std.Ada_Extensions);
pragma Elaborate_All (Std.Containers.Unbounded_Vectors);

generic
   type Key_Type is range <>;
   --  type Key_Type is new Pos32; --  is not supported by Janus/Ada

   type Value_Type is private;
   type Values_Array is array (Pos32 range <>) of aliased Value_Type;
   --  This array is made aliased to be compatible with arrays
   --  used in other containers.
package Std.Containers.Unbounded_Key_Array_Store is

   type Key_Array_Store
     (
      Initial_Keys_Count : Key_Type;
      --  Specifies the number of keys to preallocate memory for.
      --  This variable can be interpreted as the expected number of objects
      --  that has a collection of items.

      Initial_Values_Count : Nat32
      --  Specifies the total number of values in all the collections.
     )
   is limited private;

   procedure Initialize (This : out Key_Array_Store);

   procedure Finalize (This : in out Key_Array_Store);

   function Create_Key
     (This : access Key_Array_Store) return Key_Type;
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
     (This : in out Key_Array_Store;
      Key  : out Key_Type);

   procedure Add_To_Array
     (This    : in out Key_Array_Store;
      Key     : Key_Type;
      Element : Value_Type);

   function Get_Array
     (This : Key_Array_Store;
      Key  : Key_Type) return Values_Array;
   --  This function is named Get_Array instead of Array because array is
   --  a reserved word in Ada. The motivation for naming this function
   --  Array is that it would be analogous to the naming convention used
   --  in the key-value store Generic_Unbounded_Key_Value where the
   --  corresponding function is called Value.

   procedure Statistics
     (This   : Key_Array_Store;
      Result : out Statistics_Unbounded_Key_Array_Store);

private

   type Linked_List_Node is record
      Element : Value_Type;
      Next    : Nat32;
      --  Specifies the index for the next element in the collection.
      --  The value zero means there are no more elements in the collection.
   end record;

   type Linked_List_Node_Array is
     array (Pos32 range <>) of aliased Linked_List_Node;

   package Linked_List_Vectors is
     new Containers.Unbounded_Vectors
       (Linked_List_Node, Pos32, Linked_List_Node_Array);

   type Key_Item is record
      First_Index : Nat32;
      Last_Index  : Nat32;
   end record;

   type Key_Item_Array is
     array (Key_Type range <>) of aliased Key_Item;

   package Key_Vectors is
     new Containers.Unbounded_Vectors
       (Element_Type   => Key_Item,
        Index          => Key_Type,
        Elements_Array => Key_Item_Array);

   type Key_Array_Store
     (
      Initial_Keys_Count : Key_Type;
      Initial_Values_Count : Nat32
     )
   is limited record
      List : aliased Linked_List_Vectors.Vector (Initial_Values_Count);
      Keys : aliased Key_Vectors.Vector (Initial_Keys_Count);
      Next_Available_List_Index : Pos32 := 1;
   end record;

end Std.Containers.Unbounded_Key_Array_Store;
