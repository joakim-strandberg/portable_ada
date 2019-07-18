package Std.Containers.Text_IO is

   procedure Put_Line
     (Name       : String;
      Statistics : Statistics_Unbounded_Vector);

   procedure Put_Line
     (Name       : String;
      Statistics : Statistics_Unbounded_Memory_Pool);

   procedure Put_Line
     (Name       : String;
      Statistics : Statistics_Unbounded_Pos32_To_Octet_Array_Map);

   procedure Put_Line
     (Name       : String;
      Statistics : Statistics_Unbounded_Key_Value_Store);

   procedure Put_Line
     (Name       : String;
      Statistics : Statistics_Unbounded_Key_Array_Store);

end Std.Containers.Text_IO;
