with Std.Ada_Extensions; use Std.Ada_Extensions;
with Std.Containers.Unbounded_Key_Value_Store;
with Std.Containers.Unbounded_Key_Array_Store;
with Std.Containers.Unbounded_Vectors;
with Std.Containers.Unbounded_Memory_Pool;
with Std.Containers.Unbounded_Pos32_To_Octet_Array_Map;
with Std.XML.SAX_Parser;

pragma Elaborate_All (Std.Ada_Extensions);
pragma Elaborate_All (Std.Containers.Unbounded_Key_Value_Store);
pragma Elaborate_All (Std.Containers.Unbounded_Key_Array_Store);
pragma Elaborate_All (Std.Containers.Unbounded_Vectors);
pragma Elaborate_All (Std.Containers.Unbounded_Memory_Pool);
pragma Elaborate_All (Std.Containers.Unbounded_Pos32_To_Octet_Array_Map);
pragma Elaborate_All (Std.XML.SAX_Parser);

package Std.XML.DOM_Parser is

   type UTF8_Key is new Pos32;
   --  A positive number that uniquely identifies a UTF8 encoded string.

   type Attribute is limited record
      Name  : UTF8_Key;
      Value : UTF8_Key;
   end record;
   --  An XML tag can have zero or more attributes. An example of an XML tag
   --  with one attribute is:
   --    <person age="3"> ... </person>
   --  Here the name of the attribute is "age" and the value is "3".

   type Attribute_Ptr is access all Attribute;

   type Attribute_Ptr_Array is array (Pos32 range <>) of aliased Attribute_Ptr;

   type Node_Kind_Id is
     (
      Node_Kind_Tag,
      --  The node is actually an XML element that consists of a start tag,
      --  closing tag, the start tag attribues and the contents.

      Node_Kind_Comment,
      --  The node is a comment.

      Node_Kind_CDATA,
      Node_Kind_Text
     );

   type Tag_Attributes_Key is new Pos32;
   --  A value of this type is a positive number that uniquely identifies
   --  a collection of XML attributes.

   type Node_Children_Key is new Pos32;

   package Attributes_Collections is
     new Containers.Unbounded_Key_Array_Store
       (Key_Type     => Tag_Attributes_Key,
        Value_Type   => Attribute_Ptr,
        Values_Array => Attribute_Ptr_Array);

   type XML_Element is limited record
      Children_Id    : Node_Children_Key;
      Attributes_Key : Tag_Attributes_Key;
      Name           : UTF8_Key;
   end record;
   --  An XML element consists of a start tag, closing tag and some content.
   --  For example: <age>12</age>
   --  In this example <age> is the start tag, </age> is the closing tag
   --  and 12 is the content. In XML content can be plain text,
   --  other XML elements, XML entities and comments.
   --
   --  Rules for XML tags
   --  ------------------
   --  Rule 1.
   --  XML tags are case-sensitive.
   --
   --  Rule 2.
   --  XML tags must be closed in an appropriate order.

   type XML_Element_Ptr is access all XML_Element;

   subtype Node_Component_Key is UTF8_Key;
   --  This key can be interpreted as an identifier for a UTF8 text,
   --  but can also be interpreted as a tag identifier.

   type XML_Node is record
      Id : Node_Kind_Id := Node_Kind_Text;
      Component_Key : Node_Component_Key;
   end record;

   type XML_Node_Ptr is access all XML_Node;

   package Elements_Store is new Containers.Unbounded_Key_Value_Store
     (Key_Type   => Node_Component_Key,
      Value_Type => XML_Element_Ptr);

   type Node_Ptr_Array is array (Pos32 range <>) of aliased XML_Node_Ptr;

   package Children_Id_To_Arrays is
     new Containers.Unbounded_Key_Array_Store
       (Key_Type     => Node_Children_Key,
        Value_Type   => XML_Node_Ptr,
        Values_Array => Node_Ptr_Array);

   package Node_Vectors is new Containers.Unbounded_Vectors
     (Element_Type   => XML_Node_Ptr,
      Index          => Pos32,
      Elements_Array => Node_Ptr_Array);

   package UTF8_Store is new Containers.Unbounded_Pos32_To_Octet_Array_Map
     (Map_Key => UTF8_Key);

   type Memory_Pool_Statistics is limited record
      Pool_Nodes      : Containers.Statistics_Unbounded_Memory_Pool;
      Pool_Attributes : Containers.Statistics_Unbounded_Memory_Pool;
      XML_Elements    : Containers.Statistics_Unbounded_Memory_Pool;
      Strings_Map : Containers.Statistics_Unbounded_Pos32_To_Octet_Array_Map;
      Component_Key_To_XML_Element : Containers.
        Statistics_Unbounded_Key_Value_Store;
      Children_Id_To_Arrays : Containers.Statistics_Unbounded_Key_Array_Store;
      Attributes_Collection : Containers.Statistics_Unbounded_Key_Array_Store;
   end record;
   --  The names of the fields in this type has been chosen to correspond
   --  to the fields in the memory pool type.

   type Memory_Pool
     (
      Initial_Attributes_Keys_Count        : Tag_Attributes_Key :=   4 * 1024;
      Initial_Attributes_Values_Count      : Pos32              :=   4 * 1024;
      Initial_Children_Keys_Count          : Node_Children_Key  :=   4 * 1024;
      Initial_Children_Values_Count        : Pos32              :=   8 * 1024;
      Initial_XML_Element_Values_Count     : UTF8_Key           :=   4 * 1024;
      Initial_Strings_Map_Characters_Count : Octet_Offset       := 128 * 1024;
      Initial_Strings_Map_Substrings_Count : UTF8_Key           :=  16 * 1024;
      Initial_Pool_Attributes_Count        : Pos32              :=   4 * 1024;
      Initial_XML_Elements_Count           : Pos32              :=   4 * 1024;
      Initial_Pool_Nodes_Count             : Pos32              :=   8 * 1024
     )
   is limited private;
   --  Heap allocation of this type should be forbidden.

   procedure Initialize (This : out Memory_Pool);

   procedure Finalize (This : in out Memory_Pool);

   procedure Parse
     (Pool        : access Memory_Pool;
      XML_Message : Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result;
      Root_Node   :    out XML_Node_Ptr);

   function Node_Children
     (Pool    : Memory_Pool;
      Element : XML_Element) return Node_Ptr_Array;

   function Text
     (Pool : Memory_Pool;
      Key  : UTF8_Key) return Octet_Array;

   function Tag_Attributes
     (Pool : Memory_Pool;
      Key  : Tag_Attributes_Key) return Attribute_Ptr_Array;

   function Element
     (Pool : Memory_Pool;
      Key  : Node_Component_Key) return XML_Element_Ptr;

   procedure Statistics
     (This   : Memory_Pool;
      Result : out Memory_Pool_Statistics);

private

   package Pool_Node_Vectors is new Containers.Unbounded_Memory_Pool
     (Element_Type        => XML_Node,
      Element_Ptr         => XML_Node_Ptr);

   package XML_Tag_Vectors is new Containers.Unbounded_Memory_Pool
     (Element_Type        => XML_Element,
      Element_Ptr         => XML_Element_Ptr);

   package Pool_Attribute_Vectors is new Containers.Unbounded_Memory_Pool
     (Element_Type => Attribute,
      Element_Ptr  => Attribute_Ptr);

   type State_T is
     (
      Expecting_Object_Start,
      --  seems to only apply to the root start tag

      Expecting_Default,
      --  Attribute_Or_Text_Or_Comment_Or_CDATA_Or_Object_Start_Or_Object_End

      End_State
     );

   type DOM_Parser (Pool : access Memory_Pool) is
     new XML.SAX_Parser.SAX_Parser with record
      Root_Node     : XML_Node_Ptr := null;
      State         : State_T := Expecting_Object_Start;
   end record;

   procedure Start_Tag
     (This        : in out DOM_Parser;
      Tag_Name    : Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result);

   procedure End_Tag
     (This        : in out DOM_Parser;
      Tag_Name    : Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result);

   procedure Text
     (This        : in out DOM_Parser;
      Value       : Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result);

   procedure Handle_Attribute
     (This            : in out DOM_Parser;
      Attribute_Name  : Octet_Array;
      Attribute_Value : Octet_Array;
      Call_Result     : in out Extended_Subprogram_Call_Result);

   procedure Comment
     (This        : in out DOM_Parser;
      Value       : Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result);

   procedure CDATA
     (This        : in out DOM_Parser;
      Value       : Octet_Array;
      Call_Result : in out Extended_Subprogram_Call_Result);

   type Memory_Pool
     (
      Initial_Attributes_Keys_Count        : Tag_Attributes_Key :=   4 * 1024;
      Initial_Attributes_Values_Count      : Pos32              :=   4 * 1024;
      Initial_Children_Keys_Count          : Node_Children_Key  :=   4 * 1024;
      Initial_Children_Values_Count        : Pos32              :=   8 * 1024;
      Initial_XML_Element_Values_Count     : UTF8_Key           :=   4 * 1024;
      Initial_Strings_Map_Characters_Count : Octet_Offset       := 128 * 1024;
      Initial_Strings_Map_Substrings_Count : UTF8_Key           :=  16 * 1024;
      Initial_Pool_Attributes_Count        : Pos32              :=   4 * 1024;
      Initial_XML_Elements_Count           : Pos32              :=   4 * 1024;
      Initial_Pool_Nodes_Count             : Pos32              :=   8 * 1024
     )
   is limited record
      Component_Key_To_XML_Element : Elements_Store.Key_Value_Store
        (Initial_Values_Count => Initial_XML_Element_Values_Count);
      Children_Id_To_Array : Children_Id_To_Arrays.Key_Array_Store
        (Initial_Keys_Count   => Initial_Children_Keys_Count,
         Initial_Values_Count => Initial_Children_Values_Count);
      Strings_Map : UTF8_Store.Map
        (Initial_Strings_Map_Characters_Count,
         Initial_Strings_Map_Substrings_Count);
      Pool_Nodes : Pool_Node_Vectors.Element_Preallocator
        (Initial_Pool_Nodes_Count);
      Pool_Attributes : Pool_Attribute_Vectors.Element_Preallocator
        (Initial_Pool_Attributes_Count);
      XML_Tags : XML_Tag_Vectors.Element_Preallocator
        (Initial_XML_Elements_Count);

      Current_Nodes : Node_Vectors.Vector (32);
      --  The current node is the last Node pointed to in the vector

      Attributes_Collection : aliased
        Attributes_Collections.Key_Array_Store
          (Initial_Keys_Count   => Initial_Attributes_Keys_Count,
           Initial_Values_Count => Initial_Attributes_Values_Count);
   end record;

   procedure New_Node
     (Pool    : in out Memory_Pool;
      Kind_Id : Node_Kind_Id;
      Node : out XML_Node_Ptr);
   --  The pool is referenced by an access type because in out parameters
   --  are not allowed for functions.

   function New_Attribute (Pool : access Memory_Pool) return Attribute_Ptr;
   --  The pool is referenced by an access type because in out parameters
   --  are not allowed for functions.

end Std.XML.DOM_Parser;
