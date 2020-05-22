with Std.Ada_Extensions;
use  Std.Ada_Extensions;
pragma Elaborate_All (Std.Ada_Extensions);

with Std.UTF8;
pragma Elaborate_All (Std.UTF8);

package Std.XML_UTF8_SAX_Parsers is

   type Body_Parser is limited private;
   --  Contains the internal state when parsing an XML body.

   procedure Initialize
     (
      This         :    out Body_Parser;
      P            : in     Octet_Offset;
      CP           : in     UTF8.Code_Point;
      Call_Result  : in out Subprogram_Call_Result
     );

   function Is_Parsing_Finished (This : Body_Parser) return Boolean;

   generic
      type SAX_Parser (<>) is limited private;

      with procedure Start_Tag
        (This        : in out SAX_Parser;
         Tag_Name    : in     Octet_Array;
         Call_Result : in out Subprogram_Call_Result);

      with procedure End_Tag
        (This        : in out SAX_Parser;
         Tag_Name    : in     Octet_Array;
         Call_Result : in out Subprogram_Call_Result);
      --  It is the responsibility of the implementor of End_Tag to verify
      --  that the tag name corresponds to the expected tag name.

      with procedure Text
        (This        : in out SAX_Parser;
         Value       : in     Octet_Array;
         Call_Result : in out Subprogram_Call_Result);

      with procedure Handle_Attribute
        (This            : in out SAX_Parser;
         Attribute_Name  : in     Octet_Array;
         Attribute_Value : in     Octet_Array;
         Call_Result     : in out Subprogram_Call_Result);

      with procedure Comment
        (This        : in out SAX_Parser;
         Value       : in     Octet_Array;
         Call_Result : in out Subprogram_Call_Result);

      with procedure CDATA
        (This        : in out SAX_Parser;
         Value       : in     Octet_Array;
         Call_Result : in out Subprogram_Call_Result);
   procedure Parse_Body
     (This          : in out SAX_Parser;
      --  Only passed to subprograms provided when instantiating this package.
      --  Nothing is known of the contents of this object.

      Parser        : in out Body_Parser;
      Contents      : in     Octet_Array;
      P             : in     Octet_Offset;
      CP            : in     UTF8.Code_Point;
      Call_Result   : in out Subprogram_Call_Result);

private

   type Expected_Quotation_Symbol_T is
     (
      Single_Quotes, -- Example: 'hello'
      Double_Quotes  -- Example: "hello"
     );

   type State_Id_Type is
     (
      Expecting_NL_Sign_Or_Space_Or_Less_Sign, -- NL = New Line
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

   type Body_Parser is limited record
      Depth : Nat32;
      State_Id : State_Id_Type;

      --  P           : Octet_Offset;
      Prev_P      : Octet_Offset;
      Prev_Prev_P : Octet_Offset; -- := Prev_P;

      Start_Tag_Name_First_Index : Octet_Offset;
      Start_Tag_Name_Last_Index  : Octet_Offset;

      Tag_Value_First_Index : Octet_Offset;
      Tag_Value_Last_Index  : Octet_Offset;

      End_Tag_Name_First_Index : Octet_Offset;
      End_Tag_Name_Last_Index  : Octet_Offset;

      Attribute_First_Index : Octet_Offset;
      Attribute_Last_Index  : Octet_Offset;

      Attribute_Value_First_Index : Octet_Offset;
      Attribute_Value_Last_Index  : Octet_Offset;

      Comment_First_Index : Octet_Offset;

      --  Shall_Ignore_Tag_Value : Boolean := False;
      --  Shall_Ignore_Tag_Value : Boolean;

      --  Shall_Ignore_Until_Next_Quotation_Mark : Boolean := False;

      Expected_Quotation_Symbol : Expected_Quotation_Symbol_T;
   end record;

   function Is_Special_Symbol (CP : UTF8.Code_Point) return Boolean;

end Std.XML_UTF8_SAX_Parsers;
