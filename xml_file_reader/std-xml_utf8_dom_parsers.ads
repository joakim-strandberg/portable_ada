with Std.Ada_Extensions;
use  Std.Ada_Extensions;
pragma Elaborate_All (Std.Ada_Extensions);

with Std.Bounded_Vectors;
pragma Elaborate_All (Std.Bounded_Vectors);

with Std.Bounded_Pos32_To_Octet_Array_Map;
pragma Elaborate_All (Std.Bounded_Pos32_To_Octet_Array_Map);

package Std.XML_UTF8_DOM_Parsers is

   Attributes_Keys_Count        : constant :=   4 * 1024;
   Attributes_Values_Count      : constant :=   4 * 1024;
   Strings_Map_Characters_Count : constant := 128 * 1024;
   Strings_Map_Substrings_Count : constant :=  16 * 1024;
   Children_Keys_Count          : constant :=   4 * 1024;
   Children_Values_Count        : constant :=   8 * 1024;
   Attributes_Count             : constant :=   8 * 1024;
   Nodes_Count                  : constant :=   5 * 1024;
   Nodes_Depth                  : constant :=         16;

   type UTF8_Text is private;

   function "+" (Right : UTF8_Text) return Octet_Array;

   type XML_Attribute is record
      Name  : UTF8_Text;
      Value : UTF8_Text;
   end record;
   --  An XML tag can have zero or more attributes. An example of an XML tag
   --  with one attribute is:
   --    <person age="3"> ... </person>
   --  Here the name of the attribute is "age" and the value is "3".

   type XML_Attribute_Const_Ptr is access constant XML_Attribute;

   type Attribute_Ptr_Array is
     array (Pos32 range <>) of aliased XML_Attribute_Const_Ptr;

   type XML_Element_Attributes is private;

   function "+" (Right : XML_Element_Attributes) return Attribute_Ptr_Array;

   type XML_Element_Children is private;

   type XML_Element is record
      Children       : XML_Element_Children;
      Attributes     : XML_Element_Attributes;
      Name           : UTF8_Text;
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

   type XML_Node (Id : Node_Kind_Id := Node_Kind_Text) is record
      case Id is
         when Node_Kind_Tag =>
            Element : XML_Element;
         when Node_Kind_Comment |
              Node_Kind_CDATA |
              Node_Kind_Text =>
            Text : UTF8_Text;
      end case;
   end record;

   type XML_Node_Const_Ptr is access constant XML_Node;

   type Node_Const_Ptr_Array is
     array (Pos32 range <>) of not null XML_Node_Const_Ptr;

   function "+" (Right : XML_Element_Children) return Node_Const_Ptr_Array;

   type Memory_Pool is limited private;

   type Memory_Pool_Ptr is access all Memory_Pool;

   procedure Parse
     (Pool        : in     Memory_Pool_Ptr;
      XML_Message : in     Octet_Array;
      Call_Result : in out Subprogram_Call_Result;
      Root_Node   :    out XML_Node_Const_Ptr);
   --  This subprogram is used if the whole XML Document is stored in the
   --  byte array XML_Message.

private

   type Node_Children_Key is new Pos32;

   type XML_Node_Ptr is access all XML_Node;

   type Node_Ptr_Array is array (Pos32 range <>) of aliased XML_Node_Ptr;

   package Node_Vectors is new Bounded_Vectors
     (Element_Type   => XML_Node_Ptr,
      Index          => Pos32,
      Elements_Array => Node_Ptr_Array);

   type XML_Attribute_Ptr is access all XML_Attribute;

   type Bounded_String_Key is new Pos32;

   package Bounded_Strings_Map is new Std.Bounded_Pos32_To_Octet_Array_Map
     (Map_Key => Bounded_String_Key);

   type Bounded_Strings_Map_Ptr is access all Bounded_Strings_Map.Map;

   type UTF8_Text is record
      Key : Bounded_String_Key;
      Map : Memory_Pool_Ptr;
   end record;

   type Tag_Attributes_Key is new Pos32;
   --  A value of this type is a positive number that uniquely identifies
   --  a collection of XML attributes.

   type XML_Element_Attributes is record
      Key : Tag_Attributes_Key;
      Map : Memory_Pool_Ptr;
   end record;

   type XML_Element_Children is record
      Key : Node_Children_Key;
      Map : Memory_Pool_Ptr;
   end record;

   Default_Node : aliased constant XML_Node
     := (Id   => Node_Kind_Text,
         Text => (Key => 1,
                  Map => null));

   type Children_Linked_List_Node is record
      Element : XML_Node_Const_Ptr;
      Next    : Nat32;
      --  Specifies the index for the next element in the collection.
      --  The value zero means there are no more elements in the collection.
   end record;

   type Children_Linked_List_Node_Array is
     array (Pos32 range <>) of aliased Children_Linked_List_Node;

   type Children_Key_Item is record
      First_Index : Nat32;
      Last_Index  : Nat32;
   end record;

   type Children_Key_Item_Array is
     array (Node_Children_Key range <>) of aliased Children_Key_Item;

   subtype Children_Extended_Key_Type is
     Node_Children_Key'Base range 0 .. Node_Children_Key'Last;

   type Children_Key_Array_Store
     (
      Initial_Keys_Count   : Node_Children_Key;
      Initial_Values_Count : Nat32
     )
   is limited record
      List : aliased Children_Linked_List_Node_Array (1 .. Initial_Values_Count);
      Last_List_Index : Nat32 := 0;
      Keys : aliased Children_Key_Item_Array (1 .. Initial_Keys_Count)
        := (others => (First_Index => 0, Last_Index => 0));
      Last_Key_Index : Children_Extended_Key_Type
        := Children_Extended_Key_Type'First;
      Next_Available_List_Index : Pos32 := 1;
   end record;

   Default_Attribute : aliased constant XML_Attribute
     := (Name  => (Key => 1,
                   Map => null),
         Value => (Key => 1,
                   Map => null));

   type Attributes_Linked_List_Node is record
      Element : XML_Attribute_Const_Ptr;
      Next    : Nat32;
      --  Specifies the index for the next element in the collection.
      --  The value zero means there are no more elements in the collection.
   end record;

   type Attributes_Linked_List_Node_Array is
     array (Pos32 range <>) of aliased Attributes_Linked_List_Node;

   type Attributes_Key_Item is record
      First_Index : Nat32;
      Last_Index  : Nat32;
   end record;

   type Attributes_Key_Item_Array is
     array (Tag_Attributes_Key range <>) of aliased Attributes_Key_Item;

   subtype Attributes_Extended_Key_Type is
     Tag_Attributes_Key'Base range 0 .. Tag_Attributes_Key'Last;

   type Attributes_Key_Array_Store
     (
      Initial_Keys_Count   : Tag_Attributes_Key;
      Initial_Values_Count : Nat32
     )
   is limited record
      List : aliased Attributes_Linked_List_Node_Array
        (1 .. Initial_Values_Count);
      Last_List_Index : Nat32 := 0;
      Keys : aliased Attributes_Key_Item_Array (1 .. Initial_Keys_Count)
        := (others => (First_Index => 0, Last_Index => 0));
      Last_Key_Index : Attributes_Extended_Key_Type
        := Attributes_Extended_Key_Type'First;
      Next_Available_List_Index : Pos32 := 1;
   end record;

   type Extended_Attribute_Index is new Nat32 range 0 .. Attributes_Count;

   subtype Attribute_Index is Extended_Attribute_Index range
     Extended_Attribute_Index'First + 1 .. Extended_Attribute_Index'Last;

   type Attribute_Array is array (Attribute_Index) of aliased XML_Attribute;

   type Extended_Node_Index is new Nat32 range 0 .. Nodes_Count;

   subtype Node_Index is Extended_Node_Index range
     Extended_Node_Index'First + 1 .. Extended_Node_Index'Last;

   type Node_Array is array (Node_Index) of aliased XML_Node;

   type Memory_Pool is limited record
      Strings_Map : Bounded_Strings_Map.Map
        (Strings_Map_Characters_Count, Strings_Map_Substrings_Count);

      Key_To_Attributes_Store : aliased Attributes_Key_Array_Store
        (Attributes_Keys_Count, Attributes_Values_Count);

      Children_Id_To_Array : aliased Children_Key_Array_Store
        (Children_Keys_Count, Children_Values_Count);

      Current_Nodes : Node_Vectors.Vector (Nodes_Depth);
      --  The current node is the last Node pointed to in the vector

      Attribute : Attribute_Array;
      Next_Attribute : Extended_Attribute_Index := 0;

      Node : Node_Array;
      Next_Node : Extended_Node_Index := 0;
   end record;

end Std.XML_UTF8_DOM_Parsers;
