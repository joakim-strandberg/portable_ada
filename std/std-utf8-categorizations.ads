private package Std.UTF8.Categorizations is
   pragma Elaborate_Body;

   function Mapping (Index : Categorization_Index) return Categorization;

private

   M : Categorization_Array;

end Std.UTF8.Categorizations;
