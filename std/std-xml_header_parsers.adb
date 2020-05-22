package body Std.XML_Header_Parsers is

   XML_IDENTIFIER_ERROR_1 : constant Int32 := 0564906783;
   XML_IDENTIFIER_ERROR_2 : constant Int32 := -1253063082;

   procedure Initialize
     (This : out Header_Parser) is
   begin
      This.State_Id := Less_Sign;
   end Initialize;

   procedure Parse_Header
     (This          : in out Header_Parser;
      CP            : in     Octet;
      Document_Kind : in out XML_Document_Kind;
      Call_Result   : in out Subprogram_Call_Result) is
   begin
      --  Ada.Text_IO.Put ("Extracted:");
      --  Ada.Text_IO.Put (Image (CP));
      --  Ada.Text_IO.Put (", state ");
      --  Ada.Text_IO.Put_Line
      --     (String_T (Initial_State_Id_T'Image (Initial_State_Id)));
      --  Ada.Text_IO.Put (Image (CP));

      case This.State_Id is
         when End_State =>
            null;
         when Less_Sign =>
            if CP = +' ' then
               null;
            elsif CP = +'<' then
               This.State_Id := Initial_State_Expecting_Question_Mark;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when Initial_State_Expecting_Question_Mark =>
            if CP = +'?' then
               This.State_Id := X;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when X =>
            if CP = +'x' then
               This.State_Id := XM;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XM =>
            if CP = +'m' then
               This.State_Id := XML;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML =>
            if CP = +'l' then
               This.State_Id := XML_S;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S =>
            if CP = +' ' then
               This.State_Id := XML_S_V;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_V =>
            if CP = +'v' then
               This.State_Id := XML_S_VE;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VE =>
            if CP = +'e' then
               This.State_Id := XML_S_VER;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VER =>
            if CP = +'r' then
               This.State_Id := XML_S_VERS;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERS =>
            if CP = +'s' then
               This.State_Id := XML_S_VERSI;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSI =>
            if CP = +'i' then
               This.State_Id := XML_S_VERSIO;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSIO =>
            if CP = +'o' then
               This.State_Id := XML_S_VERSION;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION =>
            if CP = +'n' then
               This.State_Id := XML_S_VERSION_E;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E =>
            if CP = +'=' then
               This.State_Id :=
                 XML_S_VERSION_E_Q;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q =>
            if CP = +'"' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1 =>
            if CP = +'1' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P =>
            if CP = +'.' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0 =>
            if CP = +'0' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q =>
            if CP = +'"' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S =>
            if CP = +' ' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_E;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_E =>
            if CP = +'e' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_EN;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_EN =>
            if CP = +'n' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENC;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENC =>
            if CP = +'c' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENCO;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCO =>
            if CP = +'o' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENCOD;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCOD =>
            if CP = +'d' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODI;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODI =>
            if CP = +'i' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODIN;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODIN =>
            if CP = +'n' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING =>
            if CP = +'g' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E =>
            if CP = +'=' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q =>
            if CP = +'"' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q_U;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q_U =>
            if CP = +'u' or
              CP = +'U'
            then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q_UT;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q_UT =>
            if CP = +'t' or
              CP = +'T'
            then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF =>
            if CP = +'f' or
              CP = +'F'
            then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D =>
            if CP = +'-' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8 =>
            if CP = +'8' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q =>
            if CP = +'"' then
               This.State_Id :=
                 XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q_QM;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q_QM =>
            if CP = +'?' then
               This.State_Id
                 := XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q_QM_L;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
         when XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q_QM_L =>
            if CP = +'>' then
               This.State_Id := End_State;
               Document_Kind := Document_Kind_UTF8;
            else
               Call_Result
                 := (Has_Failed => True,
                     Codes      => (Code_1 => XML_IDENTIFIER_ERROR_1,
                                    Code_2 => XML_IDENTIFIER_ERROR_2));
            end if;
      end case;
   end Parse_Header;

end Std.XML_Header_Parsers;
