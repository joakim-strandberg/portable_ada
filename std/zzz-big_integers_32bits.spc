--  This is the 32-bit hardware version of this package.
package Zzz.Big_Integers is

   type Huge_int is mod 2 ** 32;

   type Long_Block_type is mod 2 ** 32;

   type Block_type is mod 2 ** (Long_Block_type'Size / 2);

   function Shift_Left
     (Value  : Block_type;
      Amount : Natural) return Block_type;

   function Shift_Right
     (Value  : Block_type;
      Amount : Natural) return Block_type;

   function Shift_Left
     (Value  : Long_Block_type;
      Amount : Natural) return Long_Block_type;

   function Shift_Right
     (Value  : Long_Block_type;
      Amount : Natural) return Long_Block_type;

end Zzz.Big_Integers;
