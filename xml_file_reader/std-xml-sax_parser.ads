with Std.Ada_Extensions; use Std.Ada_Extensions;

package Std.XML.SAX_Parser is

   type SAX_Parser is tagged limited null record;

   procedure Start_Tag
     (This        : in out SAX_Parser;
      Tag_Name    : in     Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result);

   procedure End_Tag
     (This        : in out SAX_Parser;
      Tag_Name    : in     Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result);
   --  It is the responsibility of the implementor of End_Tag to verify
   --  that the tag name corresponds to the expected tag name.

   procedure Text
     (This        : in out SAX_Parser;
      Value       : in     Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result);

   procedure Handle_Attribute
     (This            : in out SAX_Parser;
      Attribute_Name  : in     Octet_Array;
      Attribute_Value : in     Octet_Array;
      Call_Result     : in out Extended_Subprogram_Call_Result);

   procedure Comment
     (This        : in out SAX_Parser;
      Value       : in     Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result);

   procedure CDATA
     (This        : in out SAX_Parser;
      Value       : in     Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result);

   procedure Parse
     (This        : in out SAX_Parser'Class;
      Contents    : in     Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result);

end Std.XML.SAX_Parser;
