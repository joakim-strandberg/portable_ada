with Ada.Unchecked_Deallocation;

package body Std.Containers.Unbounded_Pos32_To_Octet_Array_Map is

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => Octet_Array,
      Name   => Octet_Array_Ptr);

   procedure Free is new Ada.Unchecked_Deallocation
     (Object => Substring_Indexes,
      Name   => Substring_Indexes_Ptr);

   procedure Append
     (This  : in out Map;
      Value : Octet_Array;
      Key   : out Map_Key)
   is
      First_Index : constant Octet_Offset := This.My_Next;
      Last_Index  : constant Octet_Offset := This.My_Next + Value'Length - 1;
   begin
      if Last_Index > This.My_Huge_Text.all'Last then
         declare
            New_Last_Index : Octet_Offset := This.My_Huge_Text.all'Last * 2;
            New_Text : Octet_Array_Ptr;
         begin
            while (New_Last_Index < Last_Index) loop
               New_Last_Index := New_Last_Index * 2;
            end loop;
            New_Text := new Octet_Array (1 .. New_Last_Index);
            New_Text.all (This.My_Huge_Text'Range) := This.My_Huge_Text.all;
            Free (This.My_Huge_Text);
            This.My_Huge_Text := New_Text;
         end;
      end if;

      if This.My_Next_Index > This.My_Substrings.all'Last then
         declare
            New_Last_Index : constant Map_Key
              := This.My_Substrings.all'Last * 2;
            New_Substrings : constant Substring_Indexes_Ptr
              := new Substring_Indexes (1 .. New_Last_Index);
         begin
            New_Substrings (This.My_Substrings.all'Range)
              := This.My_Substrings.all;
            Free (This.My_Substrings);
            This.My_Substrings := New_Substrings;
         end;
      end if;

      This.My_Huge_Text (First_Index .. Last_Index) := Value;

      This.My_Substrings (This.My_Next_Index)
        := (From => First_Index,
            To   => Last_Index);
      Key := This.My_Next_Index;

      This.My_Next := This.My_Next + Value'Length;
      This.My_Next_Index := This.My_Next_Index + 1;
   end Append;

   procedure Clear (M : out Map) is
   begin
      M.My_Huge_Text.all  := (others => Octet (Latin_1.To_Int32 (' ')));
      M.My_Next       := 1;
      M.My_Next_Index := 1;
      M.My_Substrings.all := (others => (From => 1, To => 0));
   end Clear;

   function Value
     (This  : Map;
      Index : Map_Key) return Octet_Array is
   begin
      return
        (This.My_Huge_Text
           (This.My_Substrings (Index).From .. This.My_Substrings (Index).To));
   end Value;

   procedure Initialize (This : out Map) is
   begin
      This.My_Huge_Text := new Octet_Array (1 .. This.Initial_Chars_Count);
      This.My_Substrings
        := new Substring_Indexes (1 .. This.Initial_Strings_Count);
   end Initialize;

   procedure Finalize (This : in out Map) is
      procedure Finalize_Huge_Text;
      procedure Finalize_Substrings;

      procedure Finalize_Huge_Text is
      begin
         begin
            Finalize_Substrings;
         exception
            when others =>
               Free (This.My_Huge_Text);
               raise;
         end;
         Free (This.My_Huge_Text);
      end Finalize_Huge_Text;

      procedure Finalize_Substrings is
      begin
         Free (This.My_Substrings);
      end Finalize_Substrings;

   begin
      Finalize_Huge_Text;
   end Finalize;

   procedure Statistics
     (This   : Map;
      Result : out Statistics_Unbounded_Pos32_To_Octet_Array_Map) is
   begin
      Result.Used_Characters_Count := This.My_Next - 1;
      Result.Preallocated_Characters_Count := This.My_Huge_Text.all'Length;
      Result.Used_Substrings_Count := Octet_Count (This.My_Next_Index - 1);
      Result.Preallocated_Substrings_Count := This.My_Substrings.all'Length;
   end Statistics;

end Std.Containers.Unbounded_Pos32_To_Octet_Array_Map;
