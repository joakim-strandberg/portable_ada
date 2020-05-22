with Ada.Streams;

package Std.Ada_Extensions is

   type Int32 is range -2**31 + 1 .. (2**31 - 1);
   --  This type is defined to make the value -2*31 invalid
   --  in order to easily find usage of uninitialized variables
   --  through pragma Normalize_Scalars (..).

   subtype Pos32 is Int32 range 1 .. Int32'Last;

   subtype Nat32 is Int32 range 0 .. Int32'Last;

   type Hash32 is mod 2**32;

   subtype Octet is Ada.Streams.Stream_Element;
   --  Introducing short hand names for the byte concept was hard and took
   --  some thinking. The idea is to introduce a byte variable like this:
   --
   --    Byte : Octet;
   --
   --  The reason Ada.Streams.Stream_Element array is used for bytes is
   --  because in the package Ada.Directories introduced in Ada 2005
   --  the size of a file is given as number of stream elements.

   subtype Octet_Offset is
     Ada.Streams.Stream_Element_Offset range
       1 .. Ada.Streams.Stream_Element_Offset'Last;

   subtype Extended_Octet_Offset is
     Ada.Streams.Stream_Element_Offset range
       0 .. Ada.Streams.Stream_Element_Offset'Last;
   --  Same as Octet_Offset but also includes zero.
   --  Incidentially, it is also the same as Octet_Count,
   --  maybe one equivalent subtype declaration too many?

   subtype Octet_Count is Ada.Streams.Stream_Element_Count;

   subtype Octet_Array is Ada.Streams.Stream_Element_Array;
   --  It is assumed that Octet_Array'First = 1, but it is not possible
   --  to express this using Ada 95, right?
   --
   --  Well, it would be possible but then we would need to define a wrapper
   --  type:
   --
   --  type Safe_Octet_Array (Max : Extended_Octet_Offset) is record
   --     Items : Octet_Array (1 .. Max);
   --  end record;
   --
   --  However, this has not turned out to be a good idea.
   --  Especially for making byte array slices of byte arrays
   --  which cannot be done without unnecessary copying.

   subtype UTF8_String is Octet_Array;
   --  Should be used when it is known that a byte array is in fact
   --  a UTF8-encoded unicode string. The subprograms for dealing
   --  with UTF8 encoded strings are to be found in the Std.UTF8 package.
   --  This subtype definition is defined here in order to define
   --  AScii encoded strings.

   subtype ASCII_String is UTF8_String;
   --  Should be used when it is known that a byte array is an ASCII-encoded
   --  text string. An ASCII string is always a UTF8 string but a UTF8 string
   --  may not be an ASciI string. The set of ASCII strings is a true subset
   --  of the set of all UTF8 strings.

   function "+" (Left, Right : Octet_Offset) return Octet_Offset renames
     Ada.Streams."+";

   function "-" (Left, Right : Octet_Offset) return Octet_Offset renames
     Ada.Streams."-";

   function "*" (Left, Right : Octet_Offset) return Octet_Offset renames
     Ada.Streams."*";

   function "=" (Left, Right : Octet_Offset) return Boolean renames
     Ada.Streams."=";

   function "<" (Left, Right : Octet_Offset) return Boolean renames
     Ada.Streams."<";

   function "<=" (Left, Right : Octet_Offset) return Boolean renames
     Ada.Streams."<=";

   function ">" (Left, Right : Octet_Offset) return Boolean renames
     Ada.Streams.">";

   function ">=" (Left, Right : Octet_Offset) return Boolean renames
     Ada.Streams.">=";

   function "=" (Left, Right : Octet) return Boolean renames
     Ada.Streams."=";

   function "=" (Left, Right : Octet_Array) return Boolean;

   function "&" (Left, Right : Octet_Array) return Octet_Array;
   --  TODO: Needs review. This cannot always guarantuee result array
   --  always start index is 1.

   function "+" (Value : Character) return Octet;
   --  Converts a character enumeration value into an integer according to
   --  Latin_1 character encoding.
   --
   --  Further down in this file is the nested package Latin_1 defined,
   --  and this operator is an example of a function that depends on
   --  the Latin_1 package.

   function "+" (Text : String) return Octet_Array;
   --  Converts an array of character enumeration values into corresponding
   --  integer values according to Latin_1 character encoding.
   --
   --  Further down in this file is the nested package Latin_1 defined,
   --  and this operator is an example of a function that depends on
   --  the Latin_1 package.

   function To_Char (This : Int32) return Character;
   --  with
   --  Global => null,
   --  Pre    => This >= 0 and This <= 9;

   function "+" (This : Int32) return String;
   --  The plus operator is often used to convert an object of "standard type"
   --  into another type. The types in the package Standard and types defined
   --  in this package is considered to be standard types.
   --
   --  Converts an Int32 value into a String representation.
   --
   --  with
   --  Global => null,
   --  Post   =>
   --    (if This < 0 then
   --       To_String'Result'Length >= 2 and To_String'Result'Length <= 11
   --         else
   --       To_String'Result'Length >= 1 and To_String'Result'Length <= 10);

   type Ada_Code_Location is record
      Code_1 : Int32;
      Code_2 : Int32;
   end record;
   --  Is intended to be used in situations where caller of a subprogram
   --  may want to act differently depending on what issue has arisen
   --  when calling a subprogram.

   function "+" (This : Ada_Code_Location) return String;

   type Subprogram_Call_Result
     (
      Has_Failed : Boolean := False
     )
   is record
      case Has_Failed is
         when True  => Codes : Ada_Code_Location;
         when False => null;
      end case;
   end record;

   function Message (This : Subprogram_Call_Result) return String;

   --  Originates from Jacob Sparre Andersen's HTTP server implementation
   --  called Black 2014.
   --
   --  This package definition touches upon the important lack of optional
   --  types in the Ada language. The word 'optional' has been preferred over
   --  'nullable'.
   --
   --  In Ada95, beware of optional types on heap allocated objects
   --  (the values will be fixed at object creation and not possible to change
   --  afterwards). It is possible to change the value on
   --  stack allocated objects and objects defined on library level.
--     generic
--        type Content_Type is private;
--     package Generic_Optional is
--
--        type Instance (Exists : Boolean := False) is
--           record
--              case Exists is
--              when True =>
--                 Value : Content_Type;
--              when False =>
--                 null;
--              end case;
--           end record;
--
--        function "+" (Item : in Content_Type) return Instance;
--
--        function "="
--          (Left  : in Content_Type;
--           Right : in Instance) return Boolean;
--
--        function "="
--          (Left  : in Instance;
--           Right : in Content_Type) return Boolean;
--
--     end Generic_Optional;

   --  Originates from the Ada95 Reference Manual.
   --
   --  The reason this package exists is because Ada.Characters.Latin_1
   --  is not implemented in the JanusAda compiler, and in addition
   --  removes the need to use Character'Pos (..) to convert a character
   --  into an integer value which means it is possible to ban
   --  all usage of the 'Pos attribute using GNATCheck
   --  (rule POS_On_Enumeration_Types).
   --
   --  One may question why the Latin_1 package should be defined here,
   --  because if one doesn't use Latin 1, why should there be a dependency
   --  upon this package then? The reason is that the Ada_Extensions
   --  package should contain conversion routines between the standard
   --  types (i.e. Int32, ...) and uses subprograms in Latin_1 to do it.
   --  If one has an application that uses the Ada_Extensions package,
   --  one also has a dependency upon the Latin_1 package and why would
   --  it then not be sufficient to "with Ada_Extensions;" but also
   --  be forced to "with Latin_1;" to use the Latin_1 package?
   --  Taking these considerations into account, the Latin_1 package
   --  is therefore defined as a nested package inside
   --  the Ada_Extensions package.
   package Latin_1 is

      subtype Character_As_Int32 is Int32 range 0 .. 255;

      function To_Int32 (Value : Character) return Character_As_Int32;

      function Is_Graphic_Character (C : Character_As_Int32) return Boolean;

      --
      --  Control characters
      --

      NUL                  : constant Character := Character'Val (0);
      SOH                  : constant Character := Character'Val (1);
      STX                  : constant Character := Character'Val (2);
      ETX                  : constant Character := Character'Val (3);
      EOT                  : constant Character := Character'Val (4);
      ENQ                  : constant Character := Character'Val (5);
      ACK                  : constant Character := Character'Val (6);
      BEL                  : constant Character := Character'Val (7);
      BS                   : constant Character := Character'Val (8);
      HT                   : constant Character := Character'Val (9);
      LF                   : constant Character := Character'Val (10);
      VT                   : constant Character := Character'Val (11);
      FF                   : constant Character := Character'Val (12);
      CR                   : constant Character := Character'Val (13);
      SO                   : constant Character := Character'Val (14);
      SI                   : constant Character := Character'Val (15);

      DLE                  : constant Character := Character'Val (16);
      DC1                  : constant Character := Character'Val (17);
      DC2                  : constant Character := Character'Val (18);
      DC3                  : constant Character := Character'Val (19);
      DC4                  : constant Character := Character'Val (20);
      NAK                  : constant Character := Character'Val (21);
      SYN                  : constant Character := Character'Val (22);
      ETB                  : constant Character := Character'Val (23);
      CAN                  : constant Character := Character'Val (24);
      EM                   : constant Character := Character'Val (25);
      SUB                  : constant Character := Character'Val (26);
      ESC                  : constant Character := Character'Val (27);
      FS                   : constant Character := Character'Val (28);
      GS                   : constant Character := Character'Val (29);
      RS                   : constant Character := Character'Val (30);
      US                   : constant Character := Character'Val (31);

      --
      --  ISO 646 graphic characters
      --

      Space                : constant Character := ' ';  -- Character'Val(32)
      Exclamation          : constant Character := '!';  -- Character'Val(33)
      Quotation            : constant Character := '"';  -- Character'Val(34)
      Number_Sign          : constant Character := '#';  -- Character'Val(35)
      Dollar_Sign          : constant Character := '$';  -- Character'Val(36)
      Percent_Sign         : constant Character := '%';  -- Character'Val(37)
      Ampersand            : constant Character := '&';  -- Character'Val(38)
      Apostrophe           : constant Character := ''';  -- Character'Val(39)
      Left_Parenthesis     : constant Character := '(';  -- Character'Val(40)
      Right_Parenthesis    : constant Character := ')';  -- Character'Val(41)
      Asterisk             : constant Character := '*';  -- Character'Val(42)
      Plus_Sign            : constant Character := '+';  -- Character'Val(43)
      Comma                : constant Character := ',';  -- Character'Val(44)
      Hyphen               : constant Character := '-';  -- Character'Val(45)
      Minus_Sign           : Character renames Hyphen;
      Full_Stop            : constant Character := '.';  -- Character'Val(46)
      Solidus              : constant Character := '/';  -- Character'Val(47)

      --
      --  Decimal digits '0' though '9' are at positions 48 through 57
      --

      Colon                : constant Character := ':';  -- Character'Val(58)
      Semicolon            : constant Character := ';';  -- Character'Val(59)
      Less_Than_Sign       : constant Character := '<';  -- Character'Val(60)
      Equals_Sign          : constant Character := '=';  -- Character'Val(61)
      Greater_Than_Sign    : constant Character := '>';  -- Character'Val(62)
      Question             : constant Character := '?';  -- Character'Val(63)
      Commercial_At        : constant Character := '@';  -- Character'Val(64)

      --
      --  Letters 'A' through 'Z' are at positions 65 through 90
      --

      Left_Square_Bracket  : constant Character := '[';  -- Character'Val(91)
      Reverse_Solidus      : constant Character := '\';  -- Character'Val(92)
      Right_Square_Bracket : constant Character := ']';  -- Character'Val(93)
      Circumflex           : constant Character := '^';  -- Character'Val(94)
      Low_Line             : constant Character := '_';  -- Character'Val(95)

      Grave                : constant Character := '`';  -- Character'Val(96)
      LC_A                 : constant Character := 'a';  -- Character'Val(97)
      LC_B                 : constant Character := 'b';  -- Character'Val(98)
      LC_C                 : constant Character := 'c';  -- Character'Val(99)
      LC_D                 : constant Character := 'd';  -- Character'Val(100)
      LC_E                 : constant Character := 'e';  -- Character'Val(101)
      LC_F                 : constant Character := 'f';  -- Character'Val(102)
      LC_G                 : constant Character := 'g';  -- Character'Val(103)
      LC_H                 : constant Character := 'h';  -- Character'Val(104)
      LC_I                 : constant Character := 'i';  -- Character'Val(105)
      LC_J                 : constant Character := 'j';  -- Character'Val(106)
      LC_K                 : constant Character := 'k';  -- Character'Val(107)
      LC_L                 : constant Character := 'l';  -- Character'Val(108)
      LC_M                 : constant Character := 'm';  -- Character'Val(109)
      LC_N                 : constant Character := 'n';  -- Character'Val(110)
      LC_O                 : constant Character := 'o';  -- Character'Val(111)
      LC_P                 : constant Character := 'p';  -- Character'Val(112)
      LC_Q                 : constant Character := 'q';  -- Character'Val(113)
      LC_R                 : constant Character := 'r';  -- Character'Val(114)
      LC_S                 : constant Character := 's';  -- Character'Val(115)
      LC_T                 : constant Character := 't';  -- Character'Val(116)
      LC_U                 : constant Character := 'u';  -- Character'Val(117)
      LC_V                 : constant Character := 'v';  -- Character'Val(118)
      LC_W                 : constant Character := 'w';  -- Character'Val(119)
      LC_X                 : constant Character := 'x';  -- Character'Val(120)
      LC_Y                 : constant Character := 'y';  -- Character'Val(121)
      LC_Z                 : constant Character := 'z';  -- Character'Val(122)
      Left_Curly_Bracket   : constant Character := '{';  -- Character'Val(123)
      Vertical_Line        : constant Character := '|';  -- Character'Val(124)
      Right_Curly_Bracket  : constant Character := '}';  -- Character'Val(125)
      Tilde                : constant Character := '~';  -- Character'Val(126)
      DEL                  : constant Character := Character'Val (127);

      --
      --  ISO 6429 control characters
      --

      IS4                  : Character renames FS;
      IS3                  : Character renames GS;
      IS2                  : Character renames RS;
      IS1                  : Character renames US;

      Reserved_128         : constant Character := Character'Val (128);
      Reserved_129         : constant Character := Character'Val (129);
      BPH                  : constant Character := Character'Val (130);
      NBH                  : constant Character := Character'Val (131);
      Reserved_132         : constant Character := Character'Val (132);
      NEL                  : constant Character := Character'Val (133);
      SSA                  : constant Character := Character'Val (134);
      ESA                  : constant Character := Character'Val (135);
      HTS                  : constant Character := Character'Val (136);
      HTJ                  : constant Character := Character'Val (137);
      VTS                  : constant Character := Character'Val (138);
      PLD                  : constant Character := Character'Val (139);
      PLU                  : constant Character := Character'Val (140);
      RI                   : constant Character := Character'Val (141);
      SS2                  : constant Character := Character'Val (142);
      SS3                  : constant Character := Character'Val (143);
      DCS                  : constant Character := Character'Val (144);
      PU1                  : constant Character := Character'Val (145);
      PU2                  : constant Character := Character'Val (146);
      STS                  : constant Character := Character'Val (147);
      CCH                  : constant Character := Character'Val (148);
      MW                   : constant Character := Character'Val (149);
      SPA                  : constant Character := Character'Val (150);
      EPA                  : constant Character := Character'Val (151);
      SOS                  : constant Character := Character'Val (152);
      Reserved_153         : constant Character := Character'Val (153);
      SCI                  : constant Character := Character'Val (154);
      CSI                  : constant Character := Character'Val (155);
      ST                   : constant Character := Character'Val (156);
      OSC                  : constant Character := Character'Val (157);
      PM                   : constant Character := Character'Val (158);
      APC                  : constant Character := Character'Val (159);

      --
      --  Other graphic characters:
      --

      --
      --  Character positions 160 (16#A0#) .. 175 (16#AF#):
      --

      No_Break_Space              : constant Character := Character'Val (160);
      NBSP                        : Character renames No_Break_Space;
      Inverted_Exclamation        : constant Character := Character'Val (161);
      Cent_Sign                   : constant Character := Character'Val (162);
      Pound_Sign                  : constant Character := Character'Val (163);
      Currency_Sign               : constant Character := Character'Val (164);
      Yen_Sign                    : constant Character := Character'Val (165);
      Broken_Bar                  : constant Character := Character'Val (166);
      Section_Sign                : constant Character := Character'Val (167);
      Diaeresis                   : constant Character := Character'Val (168);
      Copyright_Sign              : constant Character := Character'Val (169);
      Feminine_Ordinal_Indicator  : constant Character := Character'Val (170);
      Left_Angle_Quotation        : constant Character := Character'Val (171);
      Not_Sign                    : constant Character := Character'Val (172);
      Soft_Hyphen                 : constant Character := Character'Val (173);
      Registered_Trade_Mark_Sign  : constant Character := Character'Val (174);
      Macron                      : constant Character := Character'Val (175);

      --
      --  Character positions 176 (16#B0#) .. 191 (16#BF#):
      --

      Degree_Sign                 : constant Character := Character'Val (176);
      Ring_Above                  : Character renames Degree_Sign;
      Plus_Minus_Sign             : constant Character := Character'Val (177);
      Superscript_Two             : constant Character := Character'Val (178);
      Superscript_Three           : constant Character := Character'Val (179);
      Acute                       : constant Character := Character'Val (180);
      Micro_Sign                  : constant Character := Character'Val (181);
      Pilcrow_Sign                : constant Character := Character'Val (182);
      Paragraph_Sign              : Character renames Pilcrow_Sign;
      Middle_Dot                  : constant Character := Character'Val (183);
      Cedilla                     : constant Character := Character'Val (184);
      Superscript_One             : constant Character := Character'Val (185);
      Masculine_Ordinal_Indicator : constant Character := Character'Val (186);
      Right_Angle_Quotation       : constant Character := Character'Val (187);
      Fraction_One_Quarter        : constant Character := Character'Val (188);
      Fraction_One_Half           : constant Character := Character'Val (189);
      Fraction_Three_Quarters     : constant Character := Character'Val (190);
      Inverted_Question           : constant Character := Character'Val (191);

      --
      --  Character positions 192 (16#C0#) .. 207 (16#CF#):
      --

      UC_A_Grave                  : constant Character := Character'Val (192);
      UC_A_Acute                  : constant Character := Character'Val (193);
      UC_A_Circumflex             : constant Character := Character'Val (194);
      UC_A_Tilde                  : constant Character := Character'Val (195);
      UC_A_Diaeresis              : constant Character := Character'Val (196);
      UC_A_Ring                   : constant Character := Character'Val (197);
      UC_AE_Diphthong             : constant Character := Character'Val (198);
      UC_C_Cedilla                : constant Character := Character'Val (199);
      UC_E_Grave                  : constant Character := Character'Val (200);
      UC_E_Acute                  : constant Character := Character'Val (201);
      UC_E_Circumflex             : constant Character := Character'Val (202);
      UC_E_Diaeresis              : constant Character := Character'Val (203);
      UC_I_Grave                  : constant Character := Character'Val (204);
      UC_I_Acute                  : constant Character := Character'Val (205);
      UC_I_Circumflex             : constant Character := Character'Val (206);
      UC_I_Diaeresis              : constant Character := Character'Val (207);

      --
      --  Character positions 208 (16#D0#) .. 223 (16#DF#):
      --

      UC_Icelandic_Eth            : constant Character := Character'Val (208);
      UC_N_Tilde                  : constant Character := Character'Val (209);
      UC_O_Grave                  : constant Character := Character'Val (210);
      UC_O_Acute                  : constant Character := Character'Val (211);
      UC_O_Circumflex             : constant Character := Character'Val (212);
      UC_O_Tilde                  : constant Character := Character'Val (213);
      UC_O_Diaeresis              : constant Character := Character'Val (214);
      Multiplication_Sign         : constant Character := Character'Val (215);
      UC_O_Oblique_Stroke         : constant Character := Character'Val (216);
      UC_U_Grave                  : constant Character := Character'Val (217);
      UC_U_Acute                  : constant Character := Character'Val (218);
      UC_U_Circumflex             : constant Character := Character'Val (219);
      UC_U_Diaeresis              : constant Character := Character'Val (220);
      UC_Y_Acute                  : constant Character := Character'Val (221);
      UC_Icelandic_Thorn          : constant Character := Character'Val (222);
      LC_German_Sharp_S           : constant Character := Character'Val (223);

      --
      --  Character positions 224 (16#E0#) .. 239 (16#EF#):
      --

      LC_A_Grave                  : constant Character := Character'Val (224);
      LC_A_Acute                  : constant Character := Character'Val (225);
      LC_A_Circumflex             : constant Character := Character'Val (226);
      LC_A_Tilde                  : constant Character := Character'Val (227);
      LC_A_Diaeresis              : constant Character := Character'Val (228);
      LC_A_Ring                   : constant Character := Character'Val (229);
      LC_AE_Diphthong             : constant Character := Character'Val (230);
      LC_C_Cedilla                : constant Character := Character'Val (231);
      LC_E_Grave                  : constant Character := Character'Val (232);
      LC_E_Acute                  : constant Character := Character'Val (233);
      LC_E_Circumflex             : constant Character := Character'Val (234);
      LC_E_Diaeresis              : constant Character := Character'Val (235);
      LC_I_Grave                  : constant Character := Character'Val (236);
      LC_I_Acute                  : constant Character := Character'Val (237);
      LC_I_Circumflex             : constant Character := Character'Val (238);
      LC_I_Diaeresis              : constant Character := Character'Val (239);

      --
      --  Character positions 240 (16#F0#) .. 255 (16#FF#):
      --

      LC_Icelandic_Eth            : constant Character := Character'Val (240);
      LC_N_Tilde                  : constant Character := Character'Val (241);
      LC_O_Grave                  : constant Character := Character'Val (242);
      LC_O_Acute                  : constant Character := Character'Val (243);
      LC_O_Circumflex             : constant Character := Character'Val (244);
      LC_O_Tilde                  : constant Character := Character'Val (245);
      LC_O_Diaeresis              : constant Character := Character'Val (246);
      Division_Sign               : constant Character := Character'Val (247);
      LC_O_Oblique_Stroke         : constant Character := Character'Val (248);
      LC_U_Grave                  : constant Character := Character'Val (249);
      LC_U_Acute                  : constant Character := Character'Val (250);
      LC_U_Circumflex             : constant Character := Character'Val (251);
      LC_U_Diaeresis              : constant Character := Character'Val (252);
      LC_Y_Acute                  : constant Character := Character'Val (253);
      LC_Icelandic_Thorn          : constant Character := Character'Val (254);
      LC_Y_Diaeresis              : constant Character := Character'Val (255);

   end Latin_1;

end Std.Ada_Extensions;
