package body Std.XML_UTF8_SAX_Parsers is

   use type UTF8.Code_Point;

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

   procedure Initialize
     (
      This         :    out Body_Parser;
      P            : in     Octet_Offset;
      CP           : in     UTF8.Code_Point;
      Call_Result  : in out Subprogram_Call_Result
     ) is
   begin
      This.Depth    := 0;
      This.State_Id := Expecting_NL_Sign_Or_Space_Or_Less_Sign;
      --  This.P        := Index_Offset;
      This.Prev_P   := P;

      This.Expected_Quotation_Symbol := Double_Quotes;

      if
        CP = UTF8.Code_Point (+Latin_1.LF) or
        CP = UTF8.Code_Point (+Latin_1.CR)
      then
         null; -- Normal
      elsif CP = UTF8.Code_Point (+'<') then
         This.State_Id := Init_Found_Less_Sign;
      else
         Call_Result:=
           (Has_Failed => True,
            Codes      => (1501261737, -1460557702));
      end if;
   end Initialize;

   function Is_Parsing_Finished (This : Body_Parser) return Boolean is
   begin
      return This.State_Id = Expecting_Only_Trailing_Spaces;
   end Is_Parsing_Finished;

   procedure Parse_Body
     (This          : in out SAX_Parser;
      Parser        : in out Body_Parser;
      Contents      : in     Octet_Array;
      P             : in     Octet_Offset;
      CP            : in     UTF8.Code_Point;
      Call_Result   : in out Subprogram_Call_Result) is
   begin
      --  Ada.Text_IO.Put ("Extracted:");
      --  Ada.Text_IO.Put (UTF8.Image (CP));
      --  Ada.Text_IO.Put (", state ");
      --  Ada.Text_IO.Put_Line (State_Id_Type'Image (State_Id));
      --  Ada.Text_IO.Put (UTF8.Image (CP));

      case Parser.State_Id is
      when Expecting_NL_Sign_Or_Space_Or_Less_Sign =>
         if
           CP = UTF8.Code_Point (+Latin_1.LF) or
           CP = UTF8.Code_Point (+Latin_1.CR)
         then
            null; -- Normal
         elsif CP = UTF8.Code_Point (+'<') then
            Parser.State_Id := Init_Found_Less_Sign;
         else
            Call_Result
              := (Has_Failed => True,
                  Codes      => (-0220363574, 0662000727));
         end if;
      when Init_Found_Less_Sign =>
         if CP = UTF8.Code_Point (+'!') then
            Parser.State_Id :=
              Init_Found_Less_Followed_By_Excl_Sign;
         elsif CP = UTF8.Code_Point (+'/') then
            if Parser.Depth = 0 then
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (-1257694268, -2112592695));
            else
               if P > Contents'Last then
                  Call_Result
                    := (Has_Failed => True,
                        Codes      => (-0929795332, 0193766410));
               else
                  Text (This, +"", Call_Result);

                  if not Call_Result.Has_Failed then
                     Parser.State_Id := Extracting_End_Tag_Name;
                     Parser.End_Tag_Name_First_Index := P;
                  end if;
               end if;
            end if;
         elsif not Is_Special_Symbol (CP) then
            Parser.State_Id := Extracting_Start_Tag_Name;
            Parser.Start_Tag_Name_First_Index := Parser.Prev_P;
         else
            Call_Result
              := (Has_Failed => True,
                  Codes      => (0218310192, -1344536484));
         end if;
      when Init_Found_Less_Followed_By_Excl_Sign =>
         if CP = UTF8.Code_Point (+'-') then
            Parser.State_Id :=
              Init_Found_Less_Followed_By_Excl_And_Dash_Sign;
         else
            Call_Result
              := (Has_Failed => True,
                  Codes      => (0993658621, 0982639814));
         end if;
      when Init_Found_Less_Followed_By_Excl_And_Dash_Sign =>
         if CP = UTF8.Code_Point (+'-') then
            Parser.State_Id := Init_Extracting_Comment;

            if P <= Contents'Last then
               Parser.Comment_First_Index := P;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (-1328266379, -0274766857));
            end if;
         else
            Call_Result
              := (Has_Failed => True,
                  Codes      => (0473117530, -0541753044));
         end if;
      when Extracting_Start_Tag_Name =>
         if CP = UTF8.Code_Point (+' ') then
            Parser.Start_Tag_Name_Last_Index := Parser.Prev_Prev_P;

            Start_Tag
              (This,
               Contents
                 (Parser.Start_Tag_Name_First_Index ..
                      Parser.Start_Tag_Name_Last_Index),
               Call_Result);

            if not Call_Result.Has_Failed then
               if Parser.Depth < Int32'Last then
                  Parser.Depth := Parser.Depth + 1;
                  Parser.State_Id := Expecting_G_Sign_Or_Attributes;
               else
                  Call_Result
                    := (Has_Failed => True,
                        Codes      => (-1181908864, -0747101082));
               end if;
            end if;
         elsif CP = UTF8.Code_Point (+'>') then
            Parser.Start_Tag_Name_Last_Index := Parser.Prev_Prev_P;

            Start_Tag
              (This,
               Contents (Parser.Start_Tag_Name_First_Index ..
                     Parser.Start_Tag_Name_Last_Index),
               Call_Result);

            if not Call_Result.Has_Failed then
               if Parser.Depth < Int32'Last then
                  Parser.Depth := Parser.Depth + 1;

                  if P <= Contents'Last then
                     Parser.Tag_Value_First_Index := P;
                     Parser.State_Id :=
                       Expecting_New_Tag_Or_Extracting_Tag_Value;
                  else
                     Call_Result
                       := (Has_Failed => True,
                           Codes      => (-1108135245, 0009346785));
                  end if;
               else
                  Call_Result
                    := (Has_Failed => True,
                        Codes      => (-1064425179, -1548059736));
               end if;
            end if;
         elsif CP = UTF8.Code_Point (+'/') then
            Parser.Start_Tag_Name_Last_Index := Parser.Prev_Prev_P;

            Start_Tag
              (This,
               Contents
                 (Parser.Start_Tag_Name_First_Index ..
                      Parser.Start_Tag_Name_Last_Index),
               Call_Result);

            if not Call_Result.Has_Failed then
               if Parser.Depth < Int32'Last then
                  Parser.Depth := Parser.Depth + 1;

                  Parser.State_Id :=
                    Expecting_G_Sign_Or_Attributes_And_Found_Slash;
               else
                  Call_Result
                    := (Has_Failed => True,
                        Codes      => (0016103532, -1072471573));
               end if;
            end if;
         elsif Is_Special_Symbol (CP) then
            Call_Result
              := (Has_Failed => True,
                  Codes      => (0175636358, -0993996303));
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
            Parser.State_Id :=
              Expecting_New_Tag_Or_Extracting_Tag_Value;

            if P > Contents'Last then
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (1631876148, 1445349781));
            else
               Parser.Tag_Value_First_Index := P;
            end if;
         elsif CP = UTF8.Code_Point (+'/') then
            Parser.State_Id :=
              Expecting_G_Sign_Or_Attributes_And_Found_Slash;
         elsif not Is_Special_Symbol (CP) then
            Parser.Attribute_First_Index := Parser.Prev_P;
            Parser.State_Id              := Extracting_Attribute_Name;
         else
            Call_Result
              := (Has_Failed => True,
                  Codes      => (-0820728822, -1954112046));
         end if;
      when Expecting_G_Sign_Or_Attributes_And_Found_Slash =>
         if CP = UTF8.Code_Point (+'>') then
            Parser.State_Id
              := Expecting_New_Tag_Or_Extracting_Tag_Value;

            Text (This, +"", Call_Result);

            if not Call_Result.Has_Failed then
               End_Tag
                 (This,
                  Contents (Parser.Start_Tag_Name_First_Index ..
                        Parser.Start_Tag_Name_Last_Index),
                  Call_Result);

               if not Call_Result.Has_Failed then
                  if Parser.Depth > 0 then
                     Parser.Depth := Parser.Depth - 1;

                     if P <= Contents'Last then
                        Parser.Tag_Value_First_Index := P;
                     else
                        Call_Result
                          := (Has_Failed => True,
                              Codes      => (1426957090, -1585952265));
                     end if;
                  else
                     Call_Result
                       := (Has_Failed => True,
                           Codes      => (-1628495447, 2036006743));
                  end if;
               end if;
            end if;
         else
            Call_Result
              := (Has_Failed => True,
                  Codes      => (-0464941396, 0880131948));
         end if;
      when Extracting_Attribute_Name =>
         if CP = UTF8.Code_Point (+'=') then
            Parser.Attribute_Last_Index := Parser.Prev_Prev_P;
            Parser.State_Id             :=
              Expecting_Attribute_Value_Quotation_Mark;
         elsif CP =
           UTF8.Code_Point (+Latin_1.LF)
         then
            Call_Result
              := (Has_Failed => True,
                  Codes      => (-0209983264, -1729179731));
         elsif not Is_Special_Symbol (CP) then
            null; -- Normal
         else
            Call_Result
              := (Has_Failed => True,
                  Codes      => (-1717807413, -1486938619));
         end if;
      when Expecting_Attribute_Value_Quotation_Mark =>
         if CP = UTF8.Code_Point (+'"') then
            Parser.Expected_Quotation_Symbol := Double_Quotes;

            if P <= Contents'Last then
               Parser.Attribute_Value_First_Index := P;
            else
               Parser.Attribute_Value_First_Index := Contents'Last;
            end if;
            Parser.State_Id := Extracting_Attribute_Value;
         elsif CP = UTF8.Code_Point (+''') then
            Parser.Expected_Quotation_Symbol := Single_Quotes;

            if P <= Contents'Last then
               Parser.Attribute_Value_First_Index := P;
            else
               Parser.Attribute_Value_First_Index := Contents'Last;
            end if;

            Parser.State_Id := Extracting_Attribute_Value;
         else
            Call_Result
              := (Has_Failed => True,
                  Codes      => (1311446946, 0430154116));
         end if;
      when Extracting_Attribute_Value =>
         if
           (CP = UTF8.Code_Point (+'"') and
                Parser.Expected_Quotation_Symbol = Double_Quotes) or
             (CP = UTF8.Code_Point (+''') and
                    Parser.Expected_Quotation_Symbol = Single_Quotes)
         then
            Parser.Attribute_Value_Last_Index := Parser.Prev_Prev_P;
            Parser.State_Id
              := Expecting_G_Sign_Or_Attributes;
            declare
               Name : constant Octet_Array
                 := Contents (Parser.Attribute_First_Index ..
                                Parser.Attribute_Last_Index);
               Value : constant Octet_Array
                 := Contents (Parser.Attribute_Value_First_Index ..
                                Parser.Attribute_Value_Last_Index);
            begin
               Handle_Attribute
                 (This,
                  Name,
                  Value,
                  Call_Result);
            end;
         elsif CP =
           UTF8.Code_Point (+Latin_1.LF)
         then
            Call_Result
              := (Has_Failed => True,
                  Codes      => (-0846218131, 1984049987));
         end if;
      when Expecting_New_Tag_Or_Extracting_Tag_Value =>
         if CP = UTF8.Code_Point (+'<') then
            Parser.State_Id :=
              New_Tag_Or_Tag_Value_And_Found_L;
            Parser.Tag_Value_Last_Index := Parser.Prev_Prev_P;

            Text
              (This,
               Contents (Parser.Tag_Value_First_Index ..
                     Parser.Tag_Value_Last_Index),
               Call_Result);
         end if;
      when New_Tag_Or_Tag_Value_And_Found_L =>
         if CP = UTF8.Code_Point (+'/') then
            if P > Contents'Last then
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (0952221716, -1424188925));
            else
               Parser.State_Id := Extracting_End_Tag_Name;

               Parser.End_Tag_Name_First_Index := P;
            end if;
         elsif CP = UTF8.Code_Point (+'!') then
            Parser.State_Id :=
              New_Tag_Or_Tag_Value_And_Found_L_And_Exclamation;
         elsif Is_Special_Symbol (CP) then
            Call_Result
              := (Has_Failed => True,
                  Codes      => (1584399066, 0904407776));
         else
            --  Will start parsing child tag!
            Parser.State_Id := Extracting_Start_Tag_Name;
            Parser.Start_Tag_Name_First_Index := Parser.Prev_P;
         end if;
      when New_Tag_Or_Tag_Value_And_Found_L_And_Exclamation =>
         if CP = UTF8.Code_Point (+'[') then
            Parser.State_Id :=
              New_Tag_Or_Tag_Value_But_Expecting_C;
         elsif CP = UTF8.Code_Point (+'-') then
            Parser.State_Id :=
              New_Tag_Or_Tag_Value_And_L_And_Excl_And_Dash;
         else
            Parser.State_Id :=
              Expecting_New_Tag_Or_Extracting_Tag_Value;
         end if;
      when New_Tag_Or_Tag_Value_But_Expecting_C =>
         if CP = UTF8.Code_Point (+'C') then
            Parser.State_Id :=
              New_Tag_Or_Tag_Value_But_Expecting_CD;
         else
            Parser.State_Id :=
              Expecting_New_Tag_Or_Extracting_Tag_Value;
         end if;
      when New_Tag_Or_Tag_Value_But_Expecting_CD =>
         if CP = UTF8.Code_Point (+'D') then
            Parser.State_Id :=
              New_Tag_Or_Tag_Value_But_Expecting_CDA;
         else
            Parser.State_Id :=
              Expecting_New_Tag_Or_Extracting_Tag_Value;
         end if;
      when New_Tag_Or_Tag_Value_But_Expecting_CDA =>
         if CP = UTF8.Code_Point (+'A') then
            Parser.State_Id :=
              New_Tag_Or_Tag_Value_But_Expecting_CDAT;
         else
            Parser.State_Id :=
              Expecting_New_Tag_Or_Extracting_Tag_Value;
         end if;
      when New_Tag_Or_Tag_Value_But_Expecting_CDAT =>
         if CP = UTF8.Code_Point (+'T') then
            Parser.State_Id :=
              New_Tag_Or_Tag_Value_But_Expecting_CDATA;
         else
            Parser.State_Id :=
              Expecting_New_Tag_Or_Extracting_Tag_Value;
         end if;
      when New_Tag_Or_Tag_Value_But_Expecting_CDATA =>
         if CP = UTF8.Code_Point (+'A') then
            Parser.State_Id :=
              New_Tag_Or_Tag_Value_But_Expecting_CDATA_And_SB;
         else
            Parser.State_Id :=
              Expecting_New_Tag_Or_Extracting_Tag_Value;
         end if;
      when New_Tag_Or_Tag_Value_But_Expecting_CDATA_And_SB =>
         if CP = UTF8.Code_Point (+'[') then
            Parser.State_Id              := Extracting_CDATA;

            if P <= Contents'Last then
               Parser.Tag_Value_First_Index := P;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (0746916249, 0647029709));
            end if;
         else
            Parser.State_Id :=
              Expecting_New_Tag_Or_Extracting_Tag_Value;
         end if;
      when Extracting_CDATA =>
         if CP = UTF8.Code_Point (+']') then
            Parser.Tag_Value_Last_Index := Parser.Prev_Prev_P;
            Parser.State_Id := Extracting_CDATA_Found_Square_Bracket;
         end if;
      when Extracting_CDATA_Found_Square_Bracket =>
         if CP = UTF8.Code_Point (+']') then
            Parser.State_Id :=
              Extracting_CDATA_Found_Two_Square_Brackets;
         else
            Parser.State_Id := Extracting_CDATA;
         end if;
      when Extracting_CDATA_Found_Two_Square_Brackets =>
         if CP = UTF8.Code_Point (+'>') then
            CDATA
              (This,
               Contents (Parser.Tag_Value_First_Index ..
                     Parser.Tag_Value_Last_Index),
               Call_Result);

            if not Call_Result.Has_Failed then
               if P <= Contents'Last then
                  Parser.Tag_Value_First_Index := P;
                  Parser.State_Id :=
                    Expecting_New_Tag_Or_Extracting_Tag_Value;
               else
                  Call_Result
                    := (Has_Failed => True,
                        Codes      => (-0452812427, -0193423924));
               end if;
            end if;
         else
            Parser.State_Id := Extracting_CDATA;
         end if;
      when Extracting_End_Tag_Name =>
         if CP = UTF8.Code_Point (+'>') then
            Parser.End_Tag_Name_Last_Index := Parser.Prev_Prev_P;

            End_Tag
              (This,
               Contents (Parser.End_Tag_Name_First_Index ..
                     Parser.End_Tag_Name_Last_Index),
               Call_Result);

            if not Call_Result.Has_Failed then
               if Parser.Depth > 0 then
                  Parser.Depth := Parser.Depth - 1;

                  if Parser.Depth = 0 then
                     Parser.State_Id := Expecting_Only_Trailing_Spaces;
                  else
                     Parser.State_Id :=
                       Expecting_New_Tag_Or_Extracting_Tag_Value;
                  end if;

                  if P <= Contents'Last then
                     Parser.Tag_Value_First_Index := P;
                  end if;
               else
                  Call_Result
                    := (Has_Failed => True,
                        Codes      => (0732511655, -1496189046));
               end if;
            end if;
         elsif CP =
           UTF8.Code_Point (+Latin_1.LF)
         then
            Call_Result
              := (Has_Failed => True,
                  Codes      => (-0639636331, -0602633765));
         elsif Is_Special_Symbol (CP) then
            Call_Result
              := (Has_Failed => True,
                  Codes      => (-0319834221, 0769151931));
         end if;
      when New_Tag_Or_Tag_Value_And_L_And_Excl_And_Dash =>
         if CP = UTF8.Code_Point (+'-') then
            if P <= Contents'Last then
               Parser.Comment_First_Index := P;
            else
               Parser.Comment_First_Index := Contents'Last;
            end if;
            Parser.State_Id := Extracting_Comment;
         else
            Parser.State_Id :=
              Expecting_New_Tag_Or_Extracting_Tag_Value;
         end if;
      when Init_Extracting_Comment =>
         if CP = UTF8.Code_Point (+'-') then
            Parser.State_Id := Init_Extracting_Comment_And_Found_Dash;
         end if;
      when Init_Extracting_Comment_And_Found_Dash =>
         if CP = UTF8.Code_Point (+'-') then
            Parser.State_Id :=
              Init_Extracting_Comment_And_Found_Dash_Dash;
         else
            Parser.State_Id := Init_Extracting_Comment;
         end if;
      when Init_Extracting_Comment_And_Found_Dash_Dash =>
         if CP = UTF8.Code_Point (+'>') then
            Comment
              (This,
               Contents (Parser.Comment_First_Index .. P - 4),
               Call_Result);

            if not Call_Result.Has_Failed then
               if P <= Contents'Last then
                  Parser.Tag_Value_First_Index := P;
                  Parser.State_Id
                    := Expecting_NL_Sign_Or_Space_Or_Less_Sign;
               else
                  Call_Result
                    := (Has_Failed => True,
                        Codes      => (-1570158921, -1680892190));
               end if;
            end if;
         else
            Parser.State_Id := Init_Extracting_Comment;
         end if;
      when Extracting_Comment =>
         if CP = UTF8.Code_Point (+'-') then
            Parser.State_Id := Extracting_Comment_And_Found_Dash;
         end if;
      when Extracting_Comment_And_Found_Dash =>
         if CP = UTF8.Code_Point (+'-') then
            Parser.State_Id := Extracting_Comment_And_Found_Dash_Dash;
         else
            Parser.State_Id := Extracting_Comment;
         end if;
      when Extracting_Comment_And_Found_Dash_Dash =>
         if CP = UTF8.Code_Point (+'>') then
            Comment
              (This,
               Contents (Parser.Comment_First_Index .. P - 4),
               Call_Result);

            if not Call_Result.Has_Failed then
               if P <= Contents'Last then
                  Parser.Tag_Value_First_Index := P;
                  Parser.State_Id :=
                    Expecting_New_Tag_Or_Extracting_Tag_Value;
               else
                  Call_Result
                    := (Has_Failed => True,
                        Codes      => (1891627650, 2055344407));
               end if;
            end if;
         else
            Parser.State_Id := Init_Extracting_Comment;
         end if;
      when Expecting_Only_Trailing_Spaces =>
         if
           CP = UTF8.Code_Point (+' ') or
           CP = UTF8.Code_Point (+Latin_1.LF) or
           CP = UTF8.Code_Point (+Latin_1.CR)
         then
            null; -- Trailing spaces are OK
         else
            Call_Result
              := (Has_Failed => True,
                  Codes      => (-1239181029, 1698286444));
         end if;
      end case;

      Parser.Prev_Prev_P := Parser.Prev_P;

      Parser.Prev_P := P;
   end Parse_Body;

end Std.XML_UTF8_SAX_Parsers;
