with Std.Ada_Extensions; use Std.Ada_Extensions;

generic
   type Map_Key is range <>;
package Std.Containers.Unbounded_Pos32_To_Octet_Array_Map is

   type Map
     (
      Initial_Chars_Count   : Octet_Offset;
      Initial_Strings_Count : Map_Key
     )
   is limited private;

   procedure Initialize (This : out Map);

   procedure Finalize (This : in out Map);

   procedure Append
     (This  : in out Map;
      Value : Octet_Array;
      Key   : out Map_Key);

   function Value
     (This  : Map;
      Index : Map_Key) return Octet_Array;

   procedure Clear (M : out Map);

   procedure Statistics
     (This   : Map;
      Result : out Statistics_Unbounded_Pos32_To_Octet_Array_Map);

private

   type Substring_T is record
      From : Octet_Offset := 1;
      To   : Extended_Octet_Offset := 0;
   end record;

   type Substring_Indexes is array (Map_Key range <>) of Substring_T;

   type Substring_Indexes_Ptr is access Substring_Indexes;

   type Octet_Array_Ptr is access Octet_Array;

   type Map
     (
      Initial_Chars_Count   : Octet_Offset;
      Initial_Strings_Count : Map_Key
     )
   is record
      My_Huge_Text  : Octet_Array_Ptr;
      My_Next       : Octet_Offset := 1;
      My_Next_Index : Map_Key := 1;
      My_Substrings : Substring_Indexes_Ptr;
   end record;

end Std.Containers.Unbounded_Pos32_To_Octet_Array_Map;
