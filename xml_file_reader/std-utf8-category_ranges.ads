private package Std.UTF8.Category_Ranges is
   pragma Elaborate_Body;

   function Mapping (Index : Range_Index) return Points_Range;

private

   M : Range_Array;

end Std.UTF8.Category_Ranges;
