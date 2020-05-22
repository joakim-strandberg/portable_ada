with Std.Ada_Extensions;
use  Std.Ada_Extensions;
pragma Elaborate_All (Std.Ada_Extensions);

generic
   type Map_Key is range <>;
package Std.Bounded_Pos32_To_Octet_Array_Map is

   type Map
     (
      Max_Octet_Count      : Octet_Offset;
      Max_Substrings_Count : Map_Key
     )
   is limited private;

   --  procedure Initialize
   --    (This                  : out Map;
   --     Initial_Chars_Count   : Octet_Offset;
   --     Initial_Strings_Count : Map_Key);
   --  procedure Finalize (This : in out Map);

   procedure Append
     (This        : in out Map;
      Value       : Octet_Array;
      Key         : out Map_Key;
      Call_Result : in out Subprogram_Call_Result);

   function Value
     (This  : Map;
      Index : Map_Key) return Octet_Array;

   procedure Clear (M : out Map);

private

   type Substring_T is record
      From : Octet_Offset := 1;
      To   : Extended_Octet_Offset := 0;
   end record;

   type Substring_Indexes is array (Map_Key range <>) of Substring_T;

   type Map
     (
      Max_Octet_Count      : Octet_Offset;
      Max_Substrings_Count : Map_Key
     )
   is record
      My_Huge_Text  : Octet_Array (1 .. Max_Octet_Count);
      My_Next       : Octet_Offset := 1;
      My_Next_Index : Map_Key := 1;
      My_Substrings : Substring_Indexes (1 .. Max_Substrings_Count);
   end record;

end Std.Bounded_Pos32_To_Octet_Array_Map;
