with Std.Ada_Extensions; use Std.Ada_Extensions;

package Std.Containers is

   type Statistics_Unbounded_Vector is limited record
      Used_Elements_Count : Octet_Count;
      Preallocated_Count  : Octet_Count;
   end record;

   type Statistics_Unbounded_Memory_Pool is limited record
      Used_Elements_Count : Octet_Count;
      Preallocated_Count  : Octet_Count;
   end record;

   type Statistics_Unbounded_Pos32_To_Octet_Array_Map is limited record
      Used_Characters_Count         : Octet_Count;
      Preallocated_Characters_Count : Octet_Count;
      Used_Substrings_Count         : Octet_Count;
      Preallocated_Substrings_Count : Octet_Count;
   end record;

   type Statistics_Unbounded_Key_Value_Store is limited record
      Used_Elements_Count : Octet_Count;
      Preallocated_Count  : Octet_Count;
   end record;

   type Statistics_Unbounded_Key_Array_Store is limited record
      Used_Keys_Count         : Octet_Count;
      Preallocated_Keys_Count : Octet_Count;
      Used_Values_Count         : Octet_Count;
      Preallocated_Values_Count : Octet_Count;
      Keys   : Statistics_Unbounded_Vector;
      Values : Statistics_Unbounded_Vector;
   end record;

end Std.Containers;
