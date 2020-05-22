with HAC_Pack;
use  HAC_Pack;

procedure Std_Conf_Main is
   
   procedure Copy_Big_Integers_32bit_Spec_File is
      s : VString;
      f1, f2 : File_Type;
   begin
      Open (f1, "zzz-big_integers_32bits.spc");
      Create (f2, "zzz-big_integers.ads");
      while not End_Of_File (f1) loop
         Get_Line (f1, s);
         Put_Line (f2, s);
      end loop;
      Close (f1);
      Close (f2);
   end Copy_Big_Integers_32bit_Spec_File;

   procedure Copy_Big_Integers_32bit_Body_File is
      s : VString;
      f1, f2 : File_Type;
   begin
      Open (f1, "zzz-big_integers_32bits.bdy");
      Create (f2, "zzz-big_integers.adb");
      while not End_Of_File (f1) loop
         Get_Line (f1, s);
         Put_Line (f2, s);
      end loop;
      Close (f1);
      Close (f2);
   end Copy_Big_Integers_32bit_Body_File;
   
   procedure Copy_Big_Integers_64bit_Spec_File is
      s : VString;
      f1, f2 : File_Type;
   begin
      Open (f1, "zzz-big_integers_64bits.spc");
      Create (f2, "zzz-big_integers.ads");
      while not End_Of_File (f1) loop
         Get_Line (f1, s);
         Put_Line (f2, s);
      end loop;
      Close (f1);
      Close (f2);
   end Copy_Big_Integers_64bit_Spec_File;

   procedure Copy_Big_Integers_64bit_Body_File is
      s : VString;
      f1, f2 : File_Type;
   begin
      Open (f1, "zzz-big_integers_64bits.bdy");
      Create (f2, "zzz-big_integers.adb");
      while not End_Of_File (f1) loop
         Get_Line (f1, s);
         Put_Line (f2, s);
      end loop;
      Close (f1);
      Close (f2);
   end Copy_Big_Integers_64bit_Body_File;   
   
   type Architecture_Type is
     (Hardware_32_Bits,
      Hardware_64_Bits);
      
   Found_Operating_System : Boolean := False;
   Found_Architecture     : Boolean := False;
   
   Arch : Architecture_Type;   
   
   Searched_For_Index : Integer;
   
   File : File_Type;
   
   Text  : VString;   
   Key   : VString;
   Value : VString;
begin
   Open (File, "std_conf.txt");
   
   while not End_Of_File (File) loop
      Get_Line (File, Text);

      Searched_For_Index := Index (Text, ":");
      if Searched_For_Index > 1 then
         Key   := Trim_Both (Slice (Text, 1, Searched_For_Index - 1));
         Value := Trim_Both (Slice (Text, Searched_For_Index + 1, Length (Text)));
         if To_Lower (Key) = "operating system" then
            Found_Operating_System := True;
         elsif To_Lower (Key) = "architecture" then
            if Value = "32" then
               Arch := Hardware_32_Bits;
               Found_Architecture := True;
            elsif Value = "64" then
               Arch := Hardware_64_Bits;
               Found_Architecture := True;               
            end if;
         end if;
      end if;
   end loop;
   Close (File);
   
   if not Found_Operating_System then
      Put_Line ("Operating system not specified!?");
      Put_Line ("Ignored at the moment.");
   elsif not Found_Architecture then
      Put_Line ("Architecture not specified!?");
      Put_Line ("Is either 32 or 64.");
   else
      case Arch is
         when Hardware_32_Bits =>
            Put_Line ("Will configure the Std library for 32-bit architecture");
            Copy_Big_Integers_32bit_Spec_File;
            Copy_Big_Integers_32bit_Body_File;
         when Hardware_64_Bits =>
            Put_Line ("Will configure the Std library for 64-bit architecture");
            Copy_Big_Integers_64bit_Spec_File;
            Copy_Big_Integers_64bit_Body_File;
      end case;
   end if;
end Std_Conf_Main;
