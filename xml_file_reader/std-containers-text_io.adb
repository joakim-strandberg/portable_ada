with Ada.Text_IO;

package body Std.Containers.Text_IO is

   procedure Put_Line
     (Name       : String;
      Statistics : Statistics_Unbounded_Vector) is
   begin
      Ada.Text_IO.Put_Line ("Statistics for: " & Name);
      Ada.Text_IO.Put_Line
        ("Used:" & Octet_Count'Image
           (Statistics.Used_Elements_Count));
      Ada.Text_IO.Put_Line
        ("Pre-allocated:" & Octet_Count'Image
           (Statistics.Preallocated_Count));
   end Put_Line;

   procedure Put_Line
     (Name       : String;
      Statistics : Statistics_Unbounded_Memory_Pool) is
   begin
      Ada.Text_IO.Put_Line ("Statistics for: " & Name);
      Ada.Text_IO.Put_Line
        ("Used:" & Octet_Count'Image
           (Statistics.Used_Elements_Count));
      Ada.Text_IO.Put_Line
        ("Pre-allocated:" & Octet_Count'Image
           (Statistics.Preallocated_Count));
   end Put_Line;

   procedure Put_Line
     (Name       : String;
      Statistics : Statistics_Unbounded_Pos32_To_Octet_Array_Map) is
   begin
      Ada.Text_IO.Put_Line ("Statistics for: " & Name);
      Ada.Text_IO.Put_Line
        ("Used characters:" & Octet_Count'Image
           (Statistics.Used_Characters_Count));
      Ada.Text_IO.Put_Line
        ("Pre-allocated characters:" & Octet_Count'Image
           (Statistics.Preallocated_Characters_Count));
      Ada.Text_IO.Put_Line
        ("Used substrings:" & Octet_Count'Image
           (Statistics.Used_Substrings_Count));
      Ada.Text_IO.Put_Line
        ("Pre-allocated substrings:" & Octet_Count'Image
           (Statistics.Preallocated_Substrings_Count));
   end Put_Line;

   procedure Put_Line
     (Name       : String;
      Statistics : Statistics_Unbounded_Key_Value_Store) is
   begin
      Ada.Text_IO.Put_Line ("Statistics for: " & Name);
      Ada.Text_IO.Put_Line
        ("Used values:" & Octet_Count'Image
           (Statistics.Used_Elements_Count));
      Ada.Text_IO.Put_Line
        ("Pre-allocated values:" & Octet_Count'Image
           (Statistics.Preallocated_Count));
   end Put_Line;

   procedure Put_Line
     (Name       : String;
      Statistics : Statistics_Unbounded_Key_Array_Store) is
   begin
      Put_Line (Name & ".Keys", Statistics.Keys);
      Put_Line (Name & ".Values", Statistics.Values);
   end Put_Line;

end Std.Containers.Text_IO;
