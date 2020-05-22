package body Std.Bounded_Pos32_To_Octet_Array_Map is

   procedure Append
     (This        : in out Map;
      Value       : Octet_Array;
      Key         : out Map_Key;
      Call_Result : in out Subprogram_Call_Result)
   is
      First_Index : constant Octet_Offset := This.My_Next;
      Last_Index  : constant Octet_Offset := This.My_Next + Value'Length - 1;
   begin
      if Last_Index > This.My_Huge_Text'Last then
         Call_Result
           := (Has_Failed => True,
               Codes      => (-0364719789, 1141534358));
         Key := Map_Key'First;
         return;
      end if;

      if This.My_Next_Index > This.My_Substrings'Last then
         Call_Result
           := (Has_Failed => True,
               Codes      => (1762793202, -0889986837));
         Key := Map_Key'First;
         return;
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
      M.My_Huge_Text  := (others => Octet (Latin_1.To_Int32 (' ')));
      M.My_Next       := 1;
      M.My_Next_Index := 1;
      M.My_Substrings := (others => (From => 1, To => 0));
   end Clear;

   function Value
     (This  : Map;
      Index : Map_Key) return Octet_Array is
   begin
      return
        (This.My_Huge_Text
           (This.My_Substrings (Index).From .. This.My_Substrings (Index).To));
   end Value;

end Std.Bounded_Pos32_To_Octet_Array_Map;
