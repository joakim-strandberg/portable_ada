with Std.Ada_Extensions;
use  Std.Ada_Extensions;
pragma Elaborate_All (Std.Ada_Extensions);

with Std.Bounded_Vectors;
pragma Elaborate_All (Std.Bounded_Vectors);

with Std.XML_UTF8_DOM_Parsers;
pragma Elaborate_All (Std.XML_UTF8_DOM_Parsers);

package EGL_Reader is

private

   Pool : aliased Std.XML_UTF8_DOM_Parsers.Memory_Pool;

   File_Contents : Octet_Array (1 .. 256 * 1024);

   Next_File_Index : Octet_Offset := 1;

   type Node_Iterator_Index is new Pos32;

   type Node_Iterator is record
      Element     : Std.XML_UTF8_DOM_Parsers.XML_Node_Const_Ptr;
      --  Should maybe be constant ptr?

      Child_Index : Nat32;
      --  Each node has a collection of children represented by an array
      --  with a positive index. This index specifies which child is
      --  currently analyzed. The value 0 represents that the children
      --  have not started to be traversed yet. If one misuses the value 0
      --  one is guaranteed to get an exception because the index of
      --  the children arrays is positive and there is thus no risk
      --  of misuse of the value 0.

      Parent_Index : Node_Iterator_Index;
   end record;

   type Node_Iterator_Array is
     array (Node_Iterator_Index range <>) of aliased Node_Iterator;

   package Node_Iterator_Vectors is new Std.Bounded_Vectors
     (Element_Type   => Node_Iterator,
      Index          => Node_Iterator_Index,
      Elements_Array => Node_Iterator_Array);

   Nodes : aliased Node_Iterator_Vectors.Vector (16);

end EGL_Reader;
