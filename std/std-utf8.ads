with Std.Ada_Extensions; use Std.Ada_Extensions;

package Std.UTF8 is
   --
   --  General_Category of a code point according to the  Unicode  character
   --  database. The names of the enumeration correspond to the names in the
   --  database.
   --
   type General_Category is
     (Lu, --  Letter, Uppercase
      Ll, --         Lowercase
      Lt, --         Titlecase
      Lm, --         Modifier
      Lo, --         Other

      Mn, -- Mark, Nonspacing
      Mc, --       Spacing Combining
      Me, --       Enclosing

      Nd, -- Number, Decimal Digit
      Nl, --         Letter
      No, --         Other

      Pc, -- Punctuation, Connector
      Pd, --              Dash
      Ps, --              Open
      Pe, --              Close
      Pi, --              Initial quote
      Pf, --              Final quote
      Po, --              Other

      Sm, -- Symbol, Math
      Sc, --         Currency
      Sk, --         Modifier
      So, --         Other

      Zs, -- Separator, Space
      Zl, --            Line
      Zp, --            Paragraph

      Cc, -- Other, Control
      Cf, --        Format
      Cs, --        Surrogate
      Co, --        Private Use
      Cn  --        Not Assigned
     );
   --
   --  Classes of categories
   --
   subtype Letter      is General_Category range Lu .. Lo;
   subtype Mark        is General_Category range Mn .. Me;
   subtype Mumber      is General_Category range Nd .. No;
   subtype Punctuation is General_Category range Pc .. Po;
   subtype Symbol      is General_Category range Sm .. So;
   subtype Separator   is General_Category range Zs .. Zp;
   subtype Other       is General_Category range Cc .. Cn;

   type Code_Point_Base is mod 2**32;
   subtype Code_Point is Code_Point_Base range 0  .. 16#10FFFF#;
   --  Here a new numerical type is introduced and
   --  for the first 127 code points it corresponds to ASCII characters.
   --  One will want to have an easy way to compare code points with
   --  ASCII characters.

   subtype Code_Point_Str32_Length is Pos32 range 1 .. 4;
   --  Length of a Str32 corresponding to a specific code point.

   --
   --  Image -- Of an UTF-8 code point
   --
   --    Value - The code point
   --
   --  Returns :
   --
   --    UTF-8 encoded equivalent
   --
   function Image (Value : Code_Point) return Octet_Array;

   function Image (Value : Code_Point) return String;

   function Image (Value : Octet_Array) return String;

   --
   --  Has_Case -- Case test
   --
   --    Value - Code point
   --
   --  Returns :
   --
   --    True if Value has either an  upper  or  a  lower  case  equivalent
   --    different from Code.
   --
   function Has_Case (Value : Code_Point) return Boolean;
   --
   --  Is_Lowercase -- Case test
   --
   --    Value - Code point
   --
   --  Returns :
   --
   --    True if Value is a lower case point
   --
   function Is_Lowercase (Value : Code_Point) return Boolean;

   --
   --  Is_Uppercase -- Case test
   --
   --    Value - Code point
   --
   --  Returns :
   --
   --    True if Value is a lower case point
   --
   function Is_Uppercase (Value : Code_Point) return Boolean;

   --
   --  To_Lowercase -- Convert to lower case
   --
   --    Value - Code point or UTF-8 encoded Str32
   --
   --  Returns :
   --
   --    The lower case eqivalent or else Value itself
   --
   function To_Lowercase (Value : Code_Point) return Code_Point;

   --
   --  To_Uppercase -- Convert to upper case
   --
   --    Value - Code point or UTF-8 encoded Str32
   --
   --  Returns :
   --
   --    The upper case eqivalent or else Value itself
   --
   function To_Uppercase (Value : Code_Point) return Code_Point;

   --
   --  Category -- Get category of a code point
   --
   --    Value - Code point
   --
   --  Returns :
   --
   --    The category of value
   --
   function Category (Value : Code_Point) return General_Category;

   --
   --  Is_* -- Category tests
   --
   function Is_Alphanumeric (Value : in Code_Point) return Boolean;
   function Is_Digit        (Value : in Code_Point) return Boolean;
   function Is_Control      (Value : in Code_Point) return Boolean;
   function Is_ISO_646      (Value : in Code_Point) return Boolean;
   function Is_Letter       (Value : in Code_Point) return Boolean;
   function Is_Lower        (Value : in Code_Point) return Boolean;
   function Is_Other_Format (Value : in Code_Point) return Boolean;
   function Is_Space        (Value : in Code_Point) return Boolean;
   function Is_Title        (Value : in Code_Point) return Boolean;
   function Is_Upper        (Value : in Code_Point) return Boolean;

   --
   --  Special digits
   --
   function Is_Subscript_Digit (Value : in Code_Point) return Boolean;

   function Is_Superscript_Digit (Value : in Code_Point) return Boolean;

   --
   --  Ada 2005 identifier sets
   --
   --    identifier_start,  see ARM 2.3(3/2)
   --    identifier_extend, see ARM 2.3(3.1/2)
   --
   function Is_Identifier_Start  (Value : in Code_Point) return Boolean;
   function Is_Identifier_Extend (Value : in Code_Point) return Boolean;

   procedure Put
     (Destination : in out Octet_Array;
      Pointer     : in out Octet_Offset;
      Value       : Code_Point);
   --
   --  Put -- Put one UTF-8 code point
   --
   --    Destination - The target Str32
   --    Pointer     - The position where to place the character
   --    Value       - The code point to put
   --
   --  This  procedure  puts  one  UTF-8  code  point into the Str32 Source
   --  starting from the position Source (Pointer). Pointer is then advanced
   --  to the first character following the output.
   --

   function Is_Valid_UTF8_Code_Point
     (Source  : Octet_Array;
      Pointer : Octet_Offset) return Boolean;

   --
   --  Get -- Get one UTF-8 code point
   --
   --    Source  - The source Str32
   --    Pointer - The Str32 position to start at
   --    Value   - The result
   --
   --   This  procedure  decodes one UTF-8 code point from the Str32 Source.
   --   It starts at Source (Pointer). After successful completion Pointer is
   --   advanced to the first character following the input.  The  result  is
   --   returned through the parameter Value.
   --
   procedure Get
     (Source  : Octet_Array;
      Pointer : in out Octet_Offset;
      Value   : out Code_Point);

   function Is_Valid_UTF8 (Source : Octet_Array) return Boolean;

   --
   --  Length -- The length of an UTF-8 Str32
   --
   --    Source - The Str32 containing UTF-8 encoded code points
   --
   --  Returns :
   --
   --    The number of UTF-8 encoded code points in Source
   --
   function Length (Source : Octet_Array) return Nat32;

   function To_Lowercase (Value : Octet_Array) return Octet_Array;

   function To_Uppercase (Value : Octet_Array) return Octet_Array;

private

   pragma Inline (Is_Alphanumeric);
   pragma Inline (Is_Control);
   pragma Inline (Is_Digit);
   pragma Inline (Is_ISO_646);
   pragma Inline (Is_Letter);
   pragma Inline (Is_Lower);
   pragma Inline (Is_Title);
   pragma Inline (Is_Upper);
   pragma Inline (Is_Subscript_Digit);
   pragma Inline (Is_Superscript_Digit);
   pragma Inline (Is_Identifier_Start);
   pragma Inline (Is_Identifier_Extend);

   type Categorization is record
      Code  : Code_Point;
      Upper : Code_Point;
      Lower : Code_Point;
   end record;
   type Categorization_Index is range 1 .. 3070;
   type Categorization_Array is
     array (Categorization_Index) of Categorization;

   type Points_Range is record
      From     : Code_Point;
      To       : Code_Point;
      Category : General_Category;
   end record;
   type Range_Index is range 1 .. 2077;
   type Range_Array is array (Range_Index) of Points_Range;

end Std.UTF8;
