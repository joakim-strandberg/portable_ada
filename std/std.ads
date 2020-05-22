--  According to Rational guide for Ada from the 90's, it is good practise
--  to group packages to avoid naming collisions.
--
--  Std is short for Standard and a nod to the standard library in C++ :)
package Std is

   type Any_Task_Id is range 1 .. 1_000;
   --  It's good practice to be able to uniquely identify tasks
   --  when logging information (which task is reporting error messages).

end Std;
