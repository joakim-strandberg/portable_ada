with Interfaces;

package body Zzz.Big_Integers is

   function Shift_Left
     (Value  : Block_type;
      Amount : Natural) return Block_type is
   begin
      return Block_type
        (Interfaces.Shift_Left (Interfaces.Unsigned_16 (Value),
         Amount));
   end Shift_Left;

   function Shift_Right
     (Value  : Block_type;
      Amount : Natural) return Block_type is
   begin
      return Block_type
        (Interfaces.Shift_Right (Interfaces.Unsigned_16 (Value),
         Amount));
   end Shift_Right;

   function Shift_Right
     (Value  : Long_Block_type;
      Amount : Natural) return Long_Block_type is
   begin
      return Long_Block_type
        (Interfaces.Shift_Right
           (Interfaces.Unsigned_32 (Value),
            Amount));
   end Shift_Right;

   function Shift_Left
     (Value  : Long_Block_type;
      Amount : Natural) return Long_Block_type is
   begin
      return Long_Block_type
        (Interfaces.Shift_Left (Interfaces.Unsigned_32 (Value),
         Amount));
   end Shift_Left;

end Zzz.Big_Integers;
