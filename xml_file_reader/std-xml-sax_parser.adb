with Std.UTF8;
--    with Ada.Text_IO;

package body Std.XML.SAX_Parser is

   use type UTF8.Code_Point;

   procedure Start_Tag
     (This        : in out SAX_Parser;
      Tag_Name    : in Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result)
   is
   begin
      null;
   end Start_Tag;

   procedure End_Tag
     (This        : in out SAX_Parser;
      Tag_Name    : in Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result)
   is
   begin
      null;
   end End_Tag;

   procedure Text
     (This        : in out SAX_Parser;
      Value       : in Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result)
   is
   begin
      null;
   end Text;

   procedure Handle_Attribute
     (This            : in out SAX_Parser;
      Attribute_Name  : in Octet_Array;
      Attribute_Value : in Octet_Array;
      Call_Result     : in out Extended_Subprogram_Call_Result)
   is
   begin
      null;
   end Handle_Attribute;

   procedure Comment
     (This        : in out SAX_Parser;
      Value       : in Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result)
   is
   begin
      null;
   end Comment;

   procedure CDATA
     (This        : in out SAX_Parser;
      Value       : in Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result)
   is
   begin
      null;
   end CDATA;

   --  Known unsupported issues: Escaping of text (for example &amp;)
   --  The stack roof may be hit if the comments and texts in the XML are HUGE.
   --  It should not be an issue in general.
   procedure Parse
     (This        : in out SAX_Parser'Class;
      Contents    : Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result)
   is
      type Initial_State_Id is
        (
         Less_Sign,
         Initial_State_Expecting_Question_Mark,
         X,
         XM,
         XML,
         XML_S,
         XML_S_V,
         XML_S_VE,
         XML_S_VER,
         XML_S_VERS,
         XML_S_VERSI,
         XML_S_VERSIO,
         XML_S_VERSION,
         XML_S_VERSION_E,
         XML_S_VERSION_E_Q,
         XML_S_VERSION_E_Q_1,
         XML_S_VERSION_E_Q_1_P,
         XML_S_VERSION_E_Q_1_P_0,
         XML_S_VERSION_E_Q_1_P_0_Q,
         XML_S_VERSION_E_Q_1_P_0_Q_S,
         XML_S_VERSION_E_Q_1_P_0_Q_S_E,
         XML_S_VERSION_E_Q_1_P_0_Q_S_EN,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENC,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENCO,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENCOD,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODI,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODIN,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q_U,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q_UT,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q,
         XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q_QM,
         End_State
        );

      type State_Id_Type is
        (Expecting_NL_Sign_Or_Space_Or_Less_Sign, -- NL = New Line
         Init_Found_Less_Sign,
         --  First start tag has not yet been found

         Init_Found_Less_Followed_By_Excl_Sign,
         --  First start tag has not yet been found

         Init_Found_Less_Followed_By_Excl_And_Dash_Sign,
         --  First start tag has not yet been found

         Extracting_Start_Tag_Name,
         Expecting_G_Sign_Or_Attributes,
         Expecting_G_Sign_Or_Attributes_And_Found_Slash,
         Extracting_Attribute_Name,
         Expecting_Attribute_Value_Quotation_Mark,
         Extracting_Attribute_Value,
         Expecting_New_Tag_Or_Extracting_Tag_Value,
         --  Or start of comment or start- tag or end-tag

         New_Tag_Or_Tag_Value_And_Found_L,
         Expecting_Only_Trailing_Spaces,
         Extracting_End_Tag_Name,
         New_Tag_Or_Tag_Value_And_L_And_Excl_And_Dash,

         --  Enumeration values introduced to handle <!CDATA[--]]>
         New_Tag_Or_Tag_Value_And_Found_L_And_Exclamation,
         New_Tag_Or_Tag_Value_But_Expecting_C,
         New_Tag_Or_Tag_Value_But_Expecting_CD,
         New_Tag_Or_Tag_Value_But_Expecting_CDA,
         New_Tag_Or_Tag_Value_But_Expecting_CDAT,
         New_Tag_Or_Tag_Value_But_Expecting_CDATA,
         New_Tag_Or_Tag_Value_But_Expecting_CDATA_And_SB,
         --  SB is short for Square bracket
         Extracting_CDATA,
         Extracting_CDATA_Found_Square_Bracket,
         Extracting_CDATA_Found_Two_Square_Brackets,
         Init_Extracting_Comment,
         --  First start tag has not yet been found

         Init_Extracting_Comment_And_Found_Dash,
         --  First start tag has not yet been found

         Init_Extracting_Comment_And_Found_Dash_Dash,
         --  First start tag has not yet been found

         Extracting_Comment,
         Extracting_Comment_And_Found_Dash,
         Extracting_Comment_And_Found_Dash_Dash
        );

      type Expected_Quotation_Symbol_T is
        (
         Single_Quotes, -- Example: 'hello'
         Double_Quotes  -- Example: "hello"
        );

      function Is_Special_Symbol (CP : UTF8.Code_Point) return Boolean;

      function Is_Special_Symbol (CP : UTF8.Code_Point) return Boolean is
      begin
         if CP = UTF8.Code_Point (+'<') then
            return True;
         elsif CP = UTF8.Code_Point (+'>') then
            return True;
         elsif CP = UTF8.Code_Point (+'/') then
            return True;
         elsif CP = UTF8.Code_Point (+'"') then
            return True;
         else
            return False;
         end if;
      end Is_Special_Symbol;

      XML_IDENTIFIER_ERROR_1 : constant Int32 := 0564906783;
      XML_IDENTIFIER_ERROR_2 : constant Int32 := -1253063082;

      subtype P_T is
        Octet_Offset range Contents'First .. Contents'Last + 4;

      subtype Prev_P_T is
        Octet_Offset range Contents'First + 1 .. Contents'Last;

      procedure Analyze_XML (P : in out P_T);

      procedure Analyze_XML (P : in out P_T) is
         Depth : Nat32 := 0;

         State_Id : State_Id_Type := Expecting_NL_Sign_Or_Space_Or_Less_Sign;

         subtype Prev_Prev_P_T is
           Octet_Offset range Contents'First + 0 .. Contents'Last;

         subtype Contents_Index_T is
           Octet_Offset range Contents'First .. Contents'Last;

         CP : UTF8.Code_Point;

         Prev_P      : Prev_P_T := P;
         Prev_Prev_P : Prev_Prev_P_T; -- := Prev_P;

         Start_Tag_Name_First_Index : Contents_Index_T := Prev_P;
         Start_Tag_Name_Last_Index  : Contents_Index_T := Prev_P;

         Tag_Value_First_Index : Contents_Index_T := Contents'First;
         Tag_Value_Last_Index  : Contents_Index_T := Contents'First;

         End_Tag_Name_First_Index : Contents_Index_T := Contents'First;
         End_Tag_Name_Last_Index  : Contents_Index_T;

         Attribute_First_Index : Contents_Index_T := Prev_P;
         Attribute_Last_Index  : Contents_Index_T := Prev_P;

         Attribute_Value_First_Index : Contents_Index_T := Prev_P;
         Attribute_Value_Last_Index  : Contents_Index_T;

         Comment_First_Index : Contents_Index_T := Prev_P;

         --  Shall_Ignore_Tag_Value : Boolean := False;
         --  Shall_Ignore_Tag_Value : Boolean;

         --  Shall_Ignore_Until_Next_Quotation_Mark : Boolean := False;

         Expected_Quotation_Symbol : Expected_Quotation_Symbol_T
           := Double_Quotes;
      begin
         if UTF8.Is_Valid_UTF8_Code_Point (Source => Contents, Pointer => P)
         then
            UTF8.Get (Source => Contents, Pointer => P, Value => CP);

            if CP = UTF8.Code_Point (+'>') then
               while P <= Contents'Last loop
                  Prev_Prev_P := Prev_P;

                  Prev_P := P;

                  if not UTF8.Is_Valid_UTF8_Code_Point
                    (Source => Contents, Pointer => P)
                  then
                     Initialize (Call_Result, 0917933704, 1893541713);
                     exit;
                  end if;

                  UTF8.Get (Source => Contents, Pointer => P, Value => CP);

                  --  Ada.Text_IO.Put ("Extracted:");
                  --  Ada.Text_IO.Put (UTF8.Image (CP));
                  --  Ada.Text_IO.Put (", state ");
                  --  Ada.Text_IO.Put_Line (State_Id_Type'Image (State_Id));
                  --  Ada.Text_IO.Put (UTF8.Image (CP));

                  case State_Id is
                     when Expecting_NL_Sign_Or_Space_Or_Less_Sign =>
                        if
                          CP = UTF8.Code_Point (+Latin_1.LF) or
                          CP = UTF8.Code_Point (+Latin_1.CR)
                        then
                           null; -- Normal
                        elsif CP = UTF8.Code_Point (+'<') then
                           State_Id := Init_Found_Less_Sign;
                        else
                           Initialize (Call_Result, -0220363574, 0662000727);
                           exit;
                        end if;
                     when Init_Found_Less_Sign =>
                        if CP = UTF8.Code_Point (+'!') then
                           State_Id :=
                             Init_Found_Less_Followed_By_Excl_Sign;
                        elsif CP = UTF8.Code_Point (+'/') then
                           if Depth = 0 then
                              Initialize
                                (Call_Result, -1257694268, -2112592695);
                              exit;
                           end if;

                           if P > Contents'Last then
                              Initialize
                                (Call_Result, -0929795332, 0193766410);
                              exit;
                           end if;

                           Text (This, +"", Call_Result);

                           if Has_Failed (Call_Result) then
                              exit;
                           end if;

                           State_Id                 := Extracting_End_Tag_Name;
                           End_Tag_Name_First_Index := P;
                        elsif not Is_Special_Symbol (CP) then
                           State_Id := Extracting_Start_Tag_Name;
                           Start_Tag_Name_First_Index := Prev_P;
                        else
                           Initialize (Call_Result, 0218310192, -1344536484);
                           exit;
                        end if;
                     when Init_Found_Less_Followed_By_Excl_Sign =>
                        if CP = UTF8.Code_Point (+'-') then
                           State_Id :=
                             Init_Found_Less_Followed_By_Excl_And_Dash_Sign;
                        else
                           Initialize (Call_Result, 0993658621, 0982639814);
                           exit;
                        end if;
                     when Init_Found_Less_Followed_By_Excl_And_Dash_Sign =>
                        if CP = UTF8.Code_Point (+'-') then
                           State_Id := Init_Extracting_Comment;

                           if P <= Contents'Last then
                              Comment_First_Index := P;
                           else
                              Comment_First_Index := Contents'Last;
                           end if;
                        else
                           Initialize (Call_Result, 0473117530, -0541753044);
                           exit;
                        end if;
                     when Extracting_Start_Tag_Name =>
                        if CP = UTF8.Code_Point (+' ') then
                           Start_Tag_Name_Last_Index := Prev_Prev_P;

                           Start_Tag
                             (This,
                              Contents
                                (Start_Tag_Name_First_Index ..
                                     Start_Tag_Name_Last_Index),
                              Call_Result);

                           if Has_Failed (Call_Result) then
                              exit;
                           end if;

                           if Depth < Int32'Last then
                              Depth := Depth + 1;
                           else
                              Initialize
                                (Call_Result, -1181908864, -0747101082);
                              exit;
                           end if;

                           State_Id :=
                             Expecting_G_Sign_Or_Attributes;
                        elsif CP = UTF8.Code_Point (+'>') then
                           Start_Tag_Name_Last_Index := Prev_Prev_P;

                           Start_Tag
                             (This,
                              Contents (Start_Tag_Name_First_Index ..
                                    Start_Tag_Name_Last_Index),
                              Call_Result);

                           if Has_Failed (Call_Result) then
                              exit;
                           end if;

                           if Depth < Int32'Last then
                              Depth := Depth + 1;
                           else
                              Initialize
                                (Call_Result, -1064425179, -1548059736);
                              exit;
                           end if;

                           if P <= Contents'Last then
                              Tag_Value_First_Index := P;
                           else
                              Tag_Value_First_Index := Contents'Last;
                           end if;

                           State_Id :=
                             Expecting_New_Tag_Or_Extracting_Tag_Value;
                        elsif CP = UTF8.Code_Point (+'/') then
                           Start_Tag_Name_Last_Index := Prev_Prev_P;

                           Start_Tag
                             (This,
                              Contents
                                (Start_Tag_Name_First_Index ..
                                     Start_Tag_Name_Last_Index),
                              Call_Result);

                           if Has_Failed (Call_Result) then
                              exit;
                           end if;

                           if Depth < Int32'Last then
                              Depth := Depth + 1;
                           else
                              Initialize
                                (Call_Result, 0016103532, -1072471573);
                              exit;
                           end if;

                           State_Id :=
                             Expecting_G_Sign_Or_Attributes_And_Found_Slash;
                        elsif Is_Special_Symbol (CP) then
                           Initialize (Call_Result, 0175636358, -0993996303);
                           exit;
                        end if;
                     when Expecting_G_Sign_Or_Attributes =>
                        if
                          CP = UTF8.Code_Point (+' ') or
                          CP = UTF8.Code_Point (+Latin_1.LF) or
                          CP = UTF8.Code_Point (+Latin_1.CR) or
                          CP = UTF8.Code_Point (+Latin_1.HT)
                        then
                           null; -- Normal
                        elsif CP = UTF8.Code_Point (+'>') then
                           State_Id :=
                             Expecting_New_Tag_Or_Extracting_Tag_Value;

                           if P > Contents'Last then
                              Initialize (Call_Result, 1631876148, 1445349781);
                              exit;
                           end if;

                           Tag_Value_First_Index := P;
                        elsif CP = UTF8.Code_Point (+'/') then
                           State_Id :=
                             Expecting_G_Sign_Or_Attributes_And_Found_Slash;
                        elsif not Is_Special_Symbol (CP) then
                           Attribute_First_Index := Prev_P;
                           State_Id              := Extracting_Attribute_Name;
                        else
                           Initialize (Call_Result, -0820728822, -1954112046);
                           exit;
                        end if;
                     when Expecting_G_Sign_Or_Attributes_And_Found_Slash =>
                        if CP = UTF8.Code_Point (+'>') then
                           State_Id
                             := Expecting_New_Tag_Or_Extracting_Tag_Value;

                           Text (This, +"", Call_Result);

                           if Has_Failed (Call_Result) then
                              exit;
                           end if;

                           End_Tag
                             (This,
                              Contents (Start_Tag_Name_First_Index ..
                                    Start_Tag_Name_Last_Index),
                              Call_Result);

                           if Has_Failed (Call_Result) then
                              exit;
                           end if;

                           if Depth > 0 then
                              Depth := Depth - 1;
                           else
                              Initialize
                                (Call_Result, -1628495447, 2036006743);
                              exit;
                           end if;

                           if P <= Contents'Last then
                              Tag_Value_First_Index := P;
                           else
                              Tag_Value_First_Index := Contents'Last;
                           end if;
                        else
                           Initialize (Call_Result, -0464941396, 0880131948);
                           exit;
                        end if;
                     when Extracting_Attribute_Name =>
                        if CP = UTF8.Code_Point (+'=') then
                           Attribute_Last_Index := Prev_Prev_P;
                           State_Id             :=
                             Expecting_Attribute_Value_Quotation_Mark;
                        elsif CP =
                          UTF8.Code_Point (+Latin_1.LF)
                        then
                           Initialize (Call_Result, -0209983264, -1729179731);
                           exit;
                        elsif not Is_Special_Symbol (CP) then
                           null; -- Normal
                        else
                           Initialize (Call_Result, -1717807413, -1486938619);
                           exit;
                        end if;
                     when Expecting_Attribute_Value_Quotation_Mark =>
                        if CP = UTF8.Code_Point (+'"') then
                           Expected_Quotation_Symbol := Double_Quotes;

                           if P <= Contents'Last then
                              Attribute_Value_First_Index := P;
                           else
                              Attribute_Value_First_Index := Contents'Last;
                           end if;
                           State_Id := Extracting_Attribute_Value;
                        elsif CP = UTF8.Code_Point (+''') then
                           Expected_Quotation_Symbol   := Single_Quotes;

                           if P <= Contents'Last then
                              Attribute_Value_First_Index := P;
                           else
                              Attribute_Value_First_Index := Contents'Last;
                           end if;

                           State_Id := Extracting_Attribute_Value;
                        else
                           Initialize (Call_Result, 1311446946, 0430154116);
                           exit;
                        end if;
                     when Extracting_Attribute_Value =>
                        if
                          (CP = UTF8.Code_Point (+'"') and
                           Expected_Quotation_Symbol = Double_Quotes) or
                          (CP = UTF8.Code_Point (+''') and
                           Expected_Quotation_Symbol = Single_Quotes)
                        then
                           Attribute_Value_Last_Index := Prev_Prev_P;
                           State_Id                   :=
                             Expecting_G_Sign_Or_Attributes;
                           declare
                              Name : constant Octet_Array
                                := Contents (Attribute_First_Index ..
                                               Attribute_Last_Index);
                              Value : constant Octet_Array
                                := Contents (Attribute_Value_First_Index ..
                                               Attribute_Value_Last_Index);
                           begin
                              Handle_Attribute
                                (This,
                                 Name,
                                 Value,
                                 Call_Result);
                           end;

                           if Has_Failed (Call_Result) then
                              exit;
                           end if;
                        elsif CP =
                          UTF8.Code_Point (+Latin_1.LF)
                        then
                           Initialize (Call_Result, -0846218131, 1984049987);
                           exit;
                        end if;
                     when Expecting_New_Tag_Or_Extracting_Tag_Value =>
                        if CP = UTF8.Code_Point (+'<') then
                           State_Id :=
                             New_Tag_Or_Tag_Value_And_Found_L;
                           Tag_Value_Last_Index := Prev_Prev_P;

                           Text
                             (This,
                              Contents (Tag_Value_First_Index ..
                                    Tag_Value_Last_Index),
                              Call_Result);

                           if Has_Failed (Call_Result) then
                              exit;
                           end if;
                        end if;
                     when New_Tag_Or_Tag_Value_And_Found_L =>
                        if CP = UTF8.Code_Point (+'/') then
                           if P > Contents'Last then
                              Initialize
                                (Call_Result, 0952221716, -1424188925);
                              exit;
                           end if;

                           State_Id := Extracting_End_Tag_Name;

                           End_Tag_Name_First_Index := P;
                        elsif CP = UTF8.Code_Point (+'!') then
                           State_Id :=
                             New_Tag_Or_Tag_Value_And_Found_L_And_Exclamation;
                        elsif Is_Special_Symbol (CP) then
                           Initialize (Call_Result, 1584399066, 0904407776);
                           exit;
                        else
                           --  Will start parsing child tag!
                           State_Id := Extracting_Start_Tag_Name;
                           Start_Tag_Name_First_Index := Prev_P;
                        end if;
                     when New_Tag_Or_Tag_Value_And_Found_L_And_Exclamation =>
                        if CP = UTF8.Code_Point (+'[') then
                           State_Id :=
                             New_Tag_Or_Tag_Value_But_Expecting_C;
                        elsif CP = UTF8.Code_Point (+'-') then
                           State_Id :=
                             New_Tag_Or_Tag_Value_And_L_And_Excl_And_Dash;
                        else
                           State_Id :=
                             Expecting_New_Tag_Or_Extracting_Tag_Value;
                        end if;
                     when New_Tag_Or_Tag_Value_But_Expecting_C =>
                        if CP = UTF8.Code_Point (+'C') then
                           State_Id :=
                             New_Tag_Or_Tag_Value_But_Expecting_CD;
                        else
                           State_Id :=
                             Expecting_New_Tag_Or_Extracting_Tag_Value;
                        end if;
                     when New_Tag_Or_Tag_Value_But_Expecting_CD =>
                        if CP = UTF8.Code_Point (+'D') then
                           State_Id :=
                             New_Tag_Or_Tag_Value_But_Expecting_CDA;
                        else
                           State_Id :=
                             Expecting_New_Tag_Or_Extracting_Tag_Value;
                        end if;
                     when New_Tag_Or_Tag_Value_But_Expecting_CDA =>
                        if CP = UTF8.Code_Point (+'A') then
                           State_Id :=
                             New_Tag_Or_Tag_Value_But_Expecting_CDAT;
                        else
                           State_Id :=
                             Expecting_New_Tag_Or_Extracting_Tag_Value;
                        end if;
                     when New_Tag_Or_Tag_Value_But_Expecting_CDAT =>
                        if CP = UTF8.Code_Point (+'T') then
                           State_Id :=
                             New_Tag_Or_Tag_Value_But_Expecting_CDATA;
                        else
                           State_Id :=
                             Expecting_New_Tag_Or_Extracting_Tag_Value;
                        end if;
                     when New_Tag_Or_Tag_Value_But_Expecting_CDATA =>
                        if CP = UTF8.Code_Point (+'A') then
                           State_Id :=
                             New_Tag_Or_Tag_Value_But_Expecting_CDATA_And_SB;
                        else
                           State_Id :=
                             Expecting_New_Tag_Or_Extracting_Tag_Value;
                        end if;
                     when New_Tag_Or_Tag_Value_But_Expecting_CDATA_And_SB =>
                        if CP = UTF8.Code_Point (+'[') then
                           State_Id              := Extracting_CDATA;

                           if P <= Contents'Last then
                              Tag_Value_First_Index := P;
                           else
                              Tag_Value_First_Index := Contents'Last;
                           end if;
                        else
                           State_Id :=
                             Expecting_New_Tag_Or_Extracting_Tag_Value;
                        end if;
                     when Extracting_CDATA =>
                        if CP = UTF8.Code_Point (+']') then
                           Tag_Value_Last_Index := Prev_Prev_P;
                           State_Id := Extracting_CDATA_Found_Square_Bracket;
                        end if;
                     when Extracting_CDATA_Found_Square_Bracket =>
                        if CP = UTF8.Code_Point (+']') then
                           State_Id :=
                             Extracting_CDATA_Found_Two_Square_Brackets;
                        else
                           State_Id := Extracting_CDATA;
                        end if;
                     when Extracting_CDATA_Found_Two_Square_Brackets =>
                        if CP = UTF8.Code_Point (+'>') then
                           CDATA
                             (This,
                              Contents (Tag_Value_First_Index ..
                                    Tag_Value_Last_Index),
                              Call_Result);

                           if Has_Failed (Call_Result) then
                              exit;
                           end if;

                           if P <= Contents'Last then
                              Tag_Value_First_Index := P;
                           else
                              Tag_Value_First_Index := Contents'Last;
                           end if;

                           State_Id :=
                             Expecting_New_Tag_Or_Extracting_Tag_Value;
                        else
                           State_Id := Extracting_CDATA;
                        end if;
                     when Extracting_End_Tag_Name =>
                        if CP = UTF8.Code_Point (+'>') then

                           End_Tag_Name_Last_Index := Prev_Prev_P;

                           End_Tag
                             (This,
                              Contents (End_Tag_Name_First_Index ..
                                    End_Tag_Name_Last_Index),
                              Call_Result);

                           if Has_Failed (Call_Result) then
                              exit;
                           end if;

                           if Depth > 0 then
                              Depth := Depth - 1;
                           else
                              Initialize
                                (Call_Result, 0732511655, -1496189046);
                              exit;
                           end if;

                           if Depth = 0 then
                              State_Id := Expecting_Only_Trailing_Spaces;
                           else
                              State_Id :=
                                Expecting_New_Tag_Or_Extracting_Tag_Value;
                           end if;

                           if P <= Contents'Last then
                              Tag_Value_First_Index := P;
                           else
                              Tag_Value_First_Index := Contents'Last;
                           end if;
                        elsif CP =
                          UTF8.Code_Point (+Latin_1.LF)
                        then
                           Initialize (Call_Result, -0639636331, -0602633765);
                           exit;
                        elsif Is_Special_Symbol (CP) then
                           Initialize (Call_Result, -0319834221, 0769151931);
                           exit;
                        end if;
                     when New_Tag_Or_Tag_Value_And_L_And_Excl_And_Dash =>
                        if CP = UTF8.Code_Point (+'-') then

                           if P <= Contents'Last then
                              Comment_First_Index := P;
                           else
                              Comment_First_Index := Contents'Last;
                           end if;
                           State_Id := Extracting_Comment;
                        else
                           State_Id :=
                             Expecting_New_Tag_Or_Extracting_Tag_Value;
                        end if;
                     when Init_Extracting_Comment =>
                        if CP = UTF8.Code_Point (+'-') then
                           State_Id := Init_Extracting_Comment_And_Found_Dash;
                        end if;
                     when Init_Extracting_Comment_And_Found_Dash =>
                        if CP = UTF8.Code_Point (+'-') then
                           State_Id :=
                             Init_Extracting_Comment_And_Found_Dash_Dash;
                        else
                           State_Id := Init_Extracting_Comment;
                        end if;
                     when Init_Extracting_Comment_And_Found_Dash_Dash =>
                        if CP = UTF8.Code_Point (+'>') then
                           Comment
                             (This,
                              Contents (Comment_First_Index .. P - 4),
                              Call_Result);

                           if Has_Failed (Call_Result) then
                              exit;
                           end if;

                           if P <= Contents'Last then
                              Tag_Value_First_Index := P;
                           else
                              Tag_Value_First_Index := Contents'Last;
                           end if;
                           State_Id := Expecting_NL_Sign_Or_Space_Or_Less_Sign;
                        else
                           State_Id := Init_Extracting_Comment;
                        end if;
                     when Extracting_Comment =>
                        if CP = UTF8.Code_Point (+'-') then
                           State_Id := Extracting_Comment_And_Found_Dash;
                        end if;
                     when Extracting_Comment_And_Found_Dash =>
                        if CP = UTF8.Code_Point (+'-') then
                           State_Id := Extracting_Comment_And_Found_Dash_Dash;
                        else
                           State_Id := Extracting_Comment;
                        end if;
                     when Extracting_Comment_And_Found_Dash_Dash =>
                        if CP = UTF8.Code_Point (+'>') then
                           Comment
                             (This,
                              Contents (Comment_First_Index .. P - 4),
                              Call_Result);

                           if Has_Failed (Call_Result) then
                              exit;
                           end if;

                           if P <= Contents'Last then
                              Tag_Value_First_Index := P;
                           else
                              Tag_Value_First_Index := Contents'Last;
                           end if;
                           State_Id :=
                             Expecting_New_Tag_Or_Extracting_Tag_Value;
                        else
                           State_Id := Init_Extracting_Comment;
                        end if;
                     when Expecting_Only_Trailing_Spaces =>
                        if
                          CP = UTF8.Code_Point (+' ') or
                          CP = UTF8.Code_Point (+Latin_1.LF) or
                          CP = UTF8.Code_Point (+Latin_1.CR)
                        then
                           null; -- Trailing spaces are OK
                        else
                           Initialize (Call_Result, -1239181029, 1698286444);
                           exit;
                        end if;
                  end case;
               end loop;

               if
                 (not Has_Failed (Call_Result))
                 and then State_Id /= Expecting_Only_Trailing_Spaces
               then
                  Initialize (Call_Result, -2068412437, -0002457258);
               end if;
            else
               Initialize
                 (Call_Result, XML_IDENTIFIER_ERROR_1, XML_IDENTIFIER_ERROR_2);
            end if;
         else
            Initialize (Call_Result, -1969620808, -0689239741);
         end if;
      end Analyze_XML;

      State_Id : Initial_State_Id :=
        Less_Sign;

      P : P_T := Contents'First;

      CP : UTF8.Code_Point;
   begin
      while P <= Contents'Last loop
         exit when State_Id = End_State;

         if not UTF8.Is_Valid_UTF8_Code_Point
           (Source => Contents, Pointer => P)
         then
            Initialize (Call_Result, -0106955593, 0277648992);
            exit;
         end if;

         UTF8.Get (Source => Contents, Pointer => P, Value => CP);

         --  Ada.Text_IO.Put ("Extracted:");
         --  Ada.Text_IO.Put (Image (CP));
         --  Ada.Text_IO.Put (", state ");
         --  Ada.Text_IO.Put_Line
         --     (String_T (Initial_State_Id_T'Image (Initial_State_Id)));
         --  Ada.Text_IO.Put (Image (CP));

         case State_Id is
            when End_State =>
               null;
            when Less_Sign =>
               if CP = UTF8.Code_Point (+' ') then
                  null;
               elsif CP = UTF8.Code_Point (+'<') then
                  State_Id := Initial_State_Expecting_Question_Mark;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when Initial_State_Expecting_Question_Mark =>
               if CP = UTF8.Code_Point (+'?') then
                  State_Id := X;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when X =>
               if CP = UTF8.Code_Point (+'x') then
                  State_Id := XM;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XM =>
               if CP = UTF8.Code_Point (+'m') then
                  State_Id := XML;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML =>
               if CP = UTF8.Code_Point (+'l') then
                  State_Id := XML_S;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S =>
               if CP = UTF8.Code_Point (+' ') then
                  State_Id := XML_S_V;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_V =>
               if CP = UTF8.Code_Point (+'v') then
                  State_Id := XML_S_VE;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VE =>
               if CP = UTF8.Code_Point (+'e') then
                  State_Id := XML_S_VER;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VER =>
               if CP = UTF8.Code_Point (+'r') then
                  State_Id := XML_S_VERS;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERS =>
               if CP = UTF8.Code_Point (+'s') then
                  State_Id := XML_S_VERSI;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSI =>
               if CP = UTF8.Code_Point (+'i') then
                  State_Id := XML_S_VERSIO;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSIO =>
               if CP = UTF8.Code_Point (+'o') then
                  State_Id := XML_S_VERSION;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION =>
               if CP = UTF8.Code_Point (+'n') then
                  State_Id := XML_S_VERSION_E;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E =>
               if CP = UTF8.Code_Point (+'=') then
                  State_Id :=
                    XML_S_VERSION_E_Q;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q =>
               if CP = UTF8.Code_Point (+'"') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1 =>
               if CP = UTF8.Code_Point (+'1') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P =>
               if CP = UTF8.Code_Point (+'.') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0 =>
               if CP = UTF8.Code_Point (+'0') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q =>
               if CP = UTF8.Code_Point (+'"') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S =>
               if CP = UTF8.Code_Point (+' ') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_E;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_E =>
               if CP = UTF8.Code_Point (+'e') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_EN;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_EN =>
               if CP = UTF8.Code_Point (+'n') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENC;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENC =>
               if CP = UTF8.Code_Point (+'c') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENCO;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCO =>
               if CP = UTF8.Code_Point (+'o') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENCOD;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCOD =>
               if CP = UTF8.Code_Point (+'d') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODI;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODI =>
               if CP = UTF8.Code_Point (+'i') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODIN;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODIN =>
               if CP = UTF8.Code_Point (+'n') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING =>
               if CP = UTF8.Code_Point (+'g') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E =>
               if CP = UTF8.Code_Point (+'=') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q =>
               if CP = UTF8.Code_Point (+'"') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q_U;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q_U =>
               if CP = UTF8.Code_Point (+'u') or
                 CP = UTF8.Code_Point (+'U')
               then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q_UT;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q_UT =>
               if CP = UTF8.Code_Point (+'t') or
                 CP = UTF8.Code_Point (+'T')
               then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF =>
               if CP = UTF8.Code_Point (+'f') or
                 CP = UTF8.Code_Point (+'F')
               then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D =>
               if CP = UTF8.Code_Point (+'-') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8 =>
               if CP = UTF8.Code_Point (+'8') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q =>
               if CP = UTF8.Code_Point (+'"') then
                  State_Id :=
                    XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q_QM;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
            when XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q_QM =>
               if CP = UTF8.Code_Point (+'?') then
                  if P <= Contents'Last then
                     State_Id := End_State;

                     Analyze_XML (P);
                  else
                     Initialize (Call_Result, 0279374352, 1601495668);
                     exit;
                  end if;
               else
                  Initialize
                    (Call_Result, XML_IDENTIFIER_ERROR_1,
                     XML_IDENTIFIER_ERROR_2);
                  exit;
               end if;
         end case;
      end loop;
   end Parse;

end Std.XML.SAX_Parser;
