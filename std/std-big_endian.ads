with Interfaces;

with Std.Ada_Extensions;
use  Std.Ada_Extensions;
pragma Elaborate_All (Std.Ada_Extensions);

--       Signed     Signed One's   Signed Two's
--      Magnitude    Complement     Complement
--  +7    0111          0111          0111
--  +6    0110          0110          0110
--  +5    0101          0101          0101
--  +4    0100          0100          0100
--  +3    0011          0011          0011
--  +2    0010          0010          0010
--  +1    0001          0001          0001
--  +0    0000          0000          0000
--  -0    1000          1111          -
--  -1    1001          1110          1111
--  -2    1010          1101          1110
--  -3    1011          1100          1101
--  -4    1100          1011          1100
--  -5    1101          1010          1011
--  -6    1110          1001          1010
--  -7    1111          1000          1001

package Std.Big_Endian is

   procedure To_Octets
     (Octets : in out Octet_Array;
      Value  : Int32;
      Index  : in out Octet_Offset);

   procedure To_Integer_32
     (Octets : in     Octet_Array;
      Value  :    out Interfaces.Integer_32;
      Index  : in out Octet_Offset);
   --  The code that calls this function can use the result of type
   --  Integer_32 to convert the value to Int32 if possible to do the
   --  type case without raising Constraint_Error exception.

end Std.Big_Endian;
