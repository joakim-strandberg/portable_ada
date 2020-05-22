package body Std.Ada_Extensions is

   function "+" (Text : String) return Octet_Array is
   begin
      if Text = "" then
         declare
            Result : Octet_Array (1 .. 0);
         begin
            return Result;
         end;
      else
         declare
            Result : Octet_Array (1 .. Text'Length);
         begin
            for I in Text'First .. Text'Last loop
               Result (Octet_Offset (I - Text'First + 1))
                 := Octet (Latin_1.To_Int32 (Text (Text'First + (I - 1))));
            end loop;
            return Result;
         end;
      end if;
   end "+";

   function "+" (Value : Character) return Octet is
   begin
      return Octet (Latin_1.To_Int32 (Value));
   end "+";

   function To_Char (This : Int32) return Character is
   begin
      case This is
         when Int32'First .. 0 => return '0';
         when 1                => return '1';
         when 2                => return '2';
         when 3                => return '3';
         when 4                => return '4';
         when 5                => return '5';
         when 6                => return '6';
         when 7                => return '7';
         when 8                => return '8';
         when 9 .. Int32'Last  => return '9';
      end case;
   end To_Char;

   function "+" (This : Int32) return String is
      Result : constant String := Int32'Image (This);
   begin
      if This >= 0 then
         return Result;
      else
         return Result (Result'First + 1 .. Result'Last);
      end if;
   end "+";

   function "+" (This : Ada_Code_Location) return String is
      subtype Index_T is Positive range 1 .. 24;

      Text : String (Index_T'Range) := (others => '0');

      Max : Index_T;
   begin
      if This.Code_1 >= 0 then
         if This.Code_2 >= 0 then
            Max := 22;

            declare
               Text2 : constant String := +This.Code_1;
            begin
               Text (10 - Text2'Length + 1 .. 10) := Text2;
            end;

            Text (11 .. 12) := ", ";

            declare
               Text2 : constant String := +This.Code_2;
            begin
               Text (23 - Text2'Length .. 22) := Text2;
            end;
         else
            Max := 23;

            declare
               Text2 : constant String := +This.Code_1;
            begin
               Text (11 - Text2'Length .. 10) := Text2;
            end;

            Text (11 .. 12) := ", ";

            declare
               Text2 : constant String := +This.Code_2;
            begin
               Text (13) := '-';
               Text (25 - Text2'Length .. 23)
                 := Text2 (Text2'First + 1 .. Text2'Last);
            end;
         end if;
      else
         if This.Code_2 >= 0 then
            Max := 23;

            declare
               Text2 : constant String := +This.Code_1;
            begin
               Text (1) := '-';
               Text (13 - Text2'Length .. 11)
                 := Text2 (Text2'First + 1 .. Text2'Last);
            end;

            Text (12 .. 13) := ", ";

            declare
               Text2 : constant String := +This.Code_2;
            begin
               Text (24 - Text2'Length .. 23) := Text2;
            end;
         else
            Max := 24;

            declare
               Text2 : constant String := +This.Code_1;
            begin
               Text (1) := '-';
               Text (13 - Text2'Length .. 11)
                 := Text2 (Text2'First + 1 .. Text2'Last);
            end;

            Text (12 .. 13) := ", ";

            declare
               Text2 : constant String := +This.Code_2;
            begin
               Text (14) := '-';
               Text (26 - Text2'Length .. 24)
                 := Text2 (Text2'First + 1 .. Text2'Last);
            end;
         end if;
      end if;

      return Text (1 .. Max);
   end "+";

   function Message (This : Subprogram_Call_Result) return String is
   begin
      return +This.Codes;
   end Message;

--     package body Generic_Optional is
--
--        function "+" (Item : in Content_Type) return Instance is
--        begin
--           return (Exists => True,
--                   Value  => Item);
--        end "+";
--
--        function "="
--          (Left  : in Content_Type;
--           Right : in Instance) return Boolean is
--        begin
--           return Right.Exists and then Left = Right.Value;
--        end "=";
--
--        function "="
--          (Left  : in Instance;
--           Right : in Content_Type) return Boolean is
--        begin
--           return Left.Exists and then Left.Value = Right;
--        end "=";
--
--     end Generic_Optional;

   package body Latin_1 is

      function To_Int32 (Value : Character) return Character_As_Int32 is
         Result : Character_As_Int32;
      begin
         case Value is
         when NUL =>
            Result := 0;
         when SOH =>
            Result := 1;
         when STX =>
            Result := 2;
         when ETX =>
            Result := 3;
         when EOT =>
            Result := 4;
         when ENQ =>
            Result := 5;
         when ACK =>
            Result := 6;
         when BEL =>
            Result := 7;
         when BS  =>
            Result := 8;
         when HT  =>
            Result := 9;
         when LF  =>
            Result := 10;
         when VT  =>
            Result := 11;
         when FF  =>
            Result := 12;
         when CR  =>
            Result := 13;
         when SO  =>
            Result := 14;
         when SI  =>
            Result := 15;
         when DLE =>
            Result := 16;
         when DC1 =>
            Result := 17;
         when DC2 =>
            Result := 18;
         when DC3 =>
            Result := 19;
         when DC4 =>
            Result := 20;
         when NAK =>
            Result := 21;
         when SYN =>
            Result := 22;
         when ETB =>
            Result := 23;
         when CAN =>
            Result := 24;
         when EM  =>
            Result := 25;
         when SUB =>
            Result := 26;
         when ESC =>
            Result := 27;
         when FS  =>
            Result := 28;
         when GS  =>
            Result := 29;
         when RS  =>
            Result := 30;
         when US  =>
            Result := 31;
         when Space        =>
            Result := 32;
         when Exclamation  =>
            Result := 33;
         when Quotation    =>
            Result := 34;
         when Number_Sign  =>
            Result := 35;
         when Dollar_Sign  =>
            Result := 36;
         when Percent_Sign =>
            Result := 37;
         when Ampersand    =>
            Result := 38;
         when Apostrophe   =>
            Result := 39;
         when Left_Parenthesis  =>
            Result := 40;
         when Right_Parenthesis =>
            Result := 41;
         when Asterisk  =>
            Result := 42;
         when Plus_Sign =>
            Result := 43;
         when Comma     =>
            Result := 44;
         when Hyphen    =>
            Result := 45;
         when Full_Stop =>
            Result := 46;
         when Solidus   =>
            Result := 47;
         when '0' =>
            Result := 48;
         when '1' =>
            Result := 49;
         when '2' =>
            Result := 50;
         when '3' =>
            Result := 51;
         when '4' =>
            Result := 52;
         when '5' =>
            Result := 53;
         when '6' =>
            Result := 54;
         when '7' =>
            Result := 55;
         when '8' =>
            Result := 56;
         when '9' =>
            Result := 57;
         when Colon             =>
            Result := 58;
         when Semicolon         =>
            Result := 59;
         when Less_Than_Sign    =>
            Result := 60;
         when Equals_Sign       =>
            Result := 61;
         when Greater_Than_Sign =>
            Result := 62;
         when Question          =>
            Result := 63;
         when Commercial_At     =>
            Result := 64;
         when 'A' =>
            Result := 65;
         when 'B' =>
            Result := 66;
         when 'C' =>
            Result := 67;
         when 'D' =>
            Result := 68;
         when 'E' =>
            Result := 69;
         when 'F' =>
            Result := 70;
         when 'G' =>
            Result := 71;
         when 'H' =>
            Result := 72;
         when 'I' =>
            Result := 73;
         when 'J' =>
            Result := 74;
         when 'K' =>
            Result := 75;
         when 'L' =>
            Result := 76;
         when 'M' =>
            Result := 77;
         when 'N' =>
            Result := 78;
         when 'O' =>
            Result := 79;
         when 'P' =>
            Result := 80;
         when 'Q' =>
            Result := 81;
         when 'R' =>
            Result := 82;
         when 'S' =>
            Result := 83;
         when 'T' =>
            Result := 84;
         when 'U' =>
            Result := 85;
         when 'V' =>
            Result := 86;
         when 'W' =>
            Result := 87;
         when 'X' =>
            Result := 88;
         when 'Y' =>
            Result := 89;
         when 'Z' =>
            Result := 90;
         when Left_Square_Bracket  =>
            Result := 91;
         when Reverse_Solidus      =>
            Result := 92;
         when Right_Square_Bracket =>
            Result := 93;
         when Circumflex           =>
            Result := 94;
         when Low_Line             =>
            Result := 95;
         when Grave               =>
            Result := 96;
         when LC_A                =>
            Result := 97;
         when LC_B                =>
            Result := 98;
         when LC_C                =>
            Result := 99;
         when LC_D                =>
            Result := 100;
         when LC_E                =>
            Result := 101;
         when LC_F                =>
            Result := 102;
         when LC_G                =>
            Result := 103;
         when LC_H                =>
            Result := 104;
         when LC_I                =>
            Result := 105;
         when LC_J                =>
            Result := 106;
         when LC_K                =>
            Result := 107;
         when LC_L                =>
            Result := 108;
         when LC_M                =>
            Result := 109;
         when LC_N                =>
            Result := 110;
         when LC_O                =>
            Result := 111;
         when LC_P                =>
            Result := 112;
         when LC_Q                =>
            Result := 113;
         when LC_R                =>
            Result := 114;
         when LC_S                =>
            Result := 115;
         when LC_T                =>
            Result := 116;
         when LC_U                =>
            Result := 117;
         when LC_V                =>
            Result := 118;
         when LC_W                =>
            Result := 119;
         when LC_X                =>
            Result := 120;
         when LC_Y                =>
            Result := 121;
         when LC_Z                =>
            Result := 122;
         when Left_Curly_Bracket  =>
            Result := 123;
         when Vertical_Line       =>
            Result := 124;
         when Right_Curly_Bracket =>
            Result := 125;
         when Tilde               =>
            Result := 126;
         when DEL                 =>
            Result := 127;
         when Reserved_128 =>
            Result := 128;
         when Reserved_129 =>
            Result := 129;
         when BPH          =>
            Result := 130;
         when NBH          =>
            Result := 131;
         when Reserved_132 =>
            Result := 132;
         when NEL          =>
            Result := 133;
         when SSA          =>
            Result := 134;
         when ESA          =>
            Result := 135;
         when HTS          =>
            Result := 136;
         when HTJ          =>
            Result := 137;
         when VTS          =>
            Result := 138;
         when PLD          =>
            Result := 139;
         when PLU          =>
            Result := 140;
         when RI           =>
            Result := 141;
         when SS2          =>
            Result := 142;
         when SS3          =>
            Result := 143;
         when DCS          =>
            Result := 144;
         when PU1          =>
            Result := 145;
         when PU2          =>
            Result := 146;
         when STS          =>
            Result := 147;
         when CCH          =>
            Result := 148;
         when MW           =>
            Result := 149;
         when SPA          =>
            Result := 150;
         when EPA          =>
            Result := 151;
         when SOS          =>
            Result := 152;
         when Reserved_153 =>
            Result := 153;
         when SCI          =>
            Result := 154;
         when CSI          =>
            Result := 155;
         when ST           =>
            Result := 156;
         when OSC          =>
            Result := 157;
         when PM           =>
            Result := 158;
         when APC          =>
            Result := 159;
         when No_Break_Space =>
            Result := 160;
         when Inverted_Exclamation        =>
            Result := 161;
         when Cent_Sign                   =>
            Result := 162;
         when Pound_Sign                  =>
            Result := 163;
         when Currency_Sign               =>
            Result := 164;
         when Yen_Sign                    =>
            Result := 165;
         when Broken_Bar                  =>
            Result := 166;
         when Section_Sign                =>
            Result := 167;
         when Diaeresis                   =>
            Result := 168;
         when Copyright_Sign              =>
            Result := 169;
         when Feminine_Ordinal_Indicator  =>
            Result := 170;
         when Left_Angle_Quotation        =>
            Result := 171;
         when Not_Sign                    =>
            Result := 172;
         when Soft_Hyphen                 =>
            Result := 173;
         when Registered_Trade_Mark_Sign  =>
            Result := 174;
         when Macron                      =>
            Result := 175;
         when Degree_Sign                 =>
            Result := 176;
         when Plus_Minus_Sign             =>
            Result := 177;
         when Superscript_Two             =>
            Result := 178;
         when Superscript_Three           =>
            Result := 179;
         when Acute                       =>
            Result := 180;
         when Micro_Sign                  =>
            Result := 181;
         when Pilcrow_Sign                =>
            Result := 182;
         when Middle_Dot                  =>
            Result := 183;
         when Cedilla                     =>
            Result := 184;
         when Superscript_One             =>
            Result := 185;
         when Masculine_Ordinal_Indicator =>
            Result := 186;
         when Right_Angle_Quotation       =>
            Result := 187;
         when Fraction_One_Quarter        =>
            Result := 188;
         when Fraction_One_Half           =>
            Result := 189;
         when Fraction_Three_Quarters     =>
            Result := 190;
         when Inverted_Question           =>
            Result := 191;
         when UC_A_Grave                  =>
            Result := 192;
         when UC_A_Acute                  =>
            Result := 193;
         when UC_A_Circumflex             =>
            Result := 194;
         when UC_A_Tilde                  =>
            Result := 195;
         when UC_A_Diaeresis              =>
            Result := 196;
         when UC_A_Ring                   =>
            Result := 197;
         when UC_AE_Diphthong             =>
            Result := 198;
         when UC_C_Cedilla                =>
            Result := 199;
         when UC_E_Grave                  =>
            Result := 200;
         when UC_E_Acute                  =>
            Result := 201;
         when UC_E_Circumflex             =>
            Result := 202;
         when UC_E_Diaeresis              =>
            Result := 203;
         when UC_I_Grave                  =>
            Result := 204;
         when UC_I_Acute                  =>
            Result := 205;
         when UC_I_Circumflex             =>
            Result := 206;
         when UC_I_Diaeresis              =>
            Result := 207;
         when UC_Icelandic_Eth            =>
            Result := 208;
         when UC_N_Tilde                  =>
            Result := 209;
         when UC_O_Grave                  =>
            Result := 210;
         when UC_O_Acute                  =>
            Result := 211;
         when UC_O_Circumflex             =>
            Result := 212;
         when UC_O_Tilde                  =>
            Result := 213;
         when UC_O_Diaeresis              =>
            Result := 214;
         when Multiplication_Sign         =>
            Result := 215;
         when UC_O_Oblique_Stroke         =>
            Result := 216;
         when UC_U_Grave                  =>
            Result := 217;
         when UC_U_Acute                  =>
            Result := 218;
         when UC_U_Circumflex             =>
            Result := 219;
         when UC_U_Diaeresis              =>
            Result := 220;
         when UC_Y_Acute                  =>
            Result := 221;
         when UC_Icelandic_Thorn          =>
            Result := 222;
         when LC_German_Sharp_S           =>
            Result := 223;
         when LC_A_Grave                  =>
            Result := 224;
         when LC_A_Acute                  =>
            Result := 225;
         when LC_A_Circumflex             =>
            Result := 226;
         when LC_A_Tilde                  =>
            Result := 227;
         when LC_A_Diaeresis              =>
            Result := 228;
         when LC_A_Ring                   =>
            Result := 229;
         when LC_AE_Diphthong             =>
            Result := 230;
         when LC_C_Cedilla                =>
            Result := 231;
         when LC_E_Grave                  =>
            Result := 232;
         when LC_E_Acute                  =>
            Result := 233;
         when LC_E_Circumflex             =>
            Result := 234;
         when LC_E_Diaeresis              =>
            Result := 235;
         when LC_I_Grave                  =>
            Result := 236;
         when LC_I_Acute                  =>
            Result := 237;
         when LC_I_Circumflex             =>
            Result := 238;
         when LC_I_Diaeresis              =>
            Result := 239;
         when LC_Icelandic_Eth            =>
            Result := 240;
         when LC_N_Tilde                  =>
            Result := 241;
         when LC_O_Grave                  =>
            Result := 242;
         when LC_O_Acute                  =>
            Result := 243;
         when LC_O_Circumflex             =>
            Result := 244;
         when LC_O_Tilde                  =>
            Result := 245;
         when LC_O_Diaeresis              =>
            Result := 246;
         when Division_Sign               =>
            Result := 247;
         when LC_O_Oblique_Stroke         =>
            Result := 248;
         when LC_U_Grave                  =>
            Result := 249;
         when LC_U_Acute                  =>
            Result := 250;
         when LC_U_Circumflex             =>
            Result := 251;
         when LC_U_Diaeresis              =>
            Result := 252;
         when LC_Y_Acute                  =>
            Result := 253;
         when LC_Icelandic_Thorn          =>
            Result := 254;
         when LC_Y_Diaeresis              =>
            Result := 255;
         end case;
         return Result;
      end To_Int32;

      function Is_Graphic_Character (C : Character_As_Int32) return Boolean is
      begin
         if
           C >= To_Int32 (Latin_1.Space) and C <= To_Int32 (Latin_1.Tilde)
         then
            return True;
         else
            return False;
         end if;
      end Is_Graphic_Character;

   end Latin_1;

   function "=" (Left, Right : Octet_Array) return Boolean is
   begin
      if Left'Length = Right'Length then
         declare
            Result : Boolean := True;
         begin
            for I in Left'Range loop
               if Left (I) /= Right (I - Left'First + Right'First) then
                  Result := False;
                  exit;
               end if;
            end loop;
            return Result;
         end;
      else
         return False;
      end if;
   end "=";

   function "&" (Left, Right : Octet_Array) return Octet_Array is
      Result : Octet_Array (1 .. Left'Length + Right'Length);
   begin
      for I in Left'Range loop
         Result (I - Left'First + 1) := Left (I);
      end loop;
      for I in Right'Range loop
         Result (I - Right'First + Left'Length + 1) := Right (I);
      end loop;
      return Result;
   end "&";

end Std.Ada_Extensions;
