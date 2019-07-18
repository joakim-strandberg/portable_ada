with Std.Ada_Extensions; use Std.Ada_Extensions;
with Std.Containers.Unbounded_Vectors;
with Std.XML.DOM_Parser;

pragma Elaborate_All (Std.Ada_Extensions);
pragma Elaborate_All (Std.Containers.Unbounded_Vectors);
pragma Elaborate_All (Std.XML.DOM_Parser);

package EGL_Reader is

private

   type Node_Iterator_Index is new Pos32;

   type Node_Iterator is record
      Element     : Std.XML.DOM_Parser.XML_Element_Ptr;
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

   package Node_Iterator_Vectors is new
     Std.Containers.Unbounded_Vectors
       (Element_Type   => Node_Iterator,
        Index          => Node_Iterator_Index,
        Elements_Array => Node_Iterator_Array);

end EGL_Reader;
