with Std.Ada_Extensions; use Std.Ada_Extensions;

--  What is XML? XML is acronym for Extensible Markup Language.
--
--  A bunch of bytes make up an XML document if it contains an
--  optional XML declaration followed by an XML element.
--  An XML element consists of a start tag, closing tag and some content.
--  For example: <age>12</age>
--  In this example <age> is the start tag, </age> is the closing tag
--  and 12 is the content. In XML content can be plain text,
--  other XML elements, XML entities and comments.
--
--  The first line in a XML document is the XML declaration.
--  It is optional but its presence indicates that the collection of bytes
--  is an XML document and to which version of XML it conforms.
--
--  Elements, Tags or Nodes?
--
--   - An XML element consists of an opening tag, its attributes, any content,
--     and a closing tag.
--   - An XML tag - either opening or closing - is used to mark the start
--     or end of an element.
--   - An XML node is a part of the hierarchical/tree structure that makes
--     up an XML document. "Node" is a generic term that applies to any
--     type of XML document object, including elements, attributes,
--     comments, processing instructions and plain text.
--
--  Entities
--
--  An entity allows you to define special characters for insertion
--  into your documents. If you've worked with HTML, you know that
--  the &lt; entity inserts a literal < character into a document.
--  You can't use the actual character because it would be treated
--  as the start of a tag, so you replace it with
--  the appropriate entity instead.
--
--  XML, true to its extensible nature, allows you to create your own entities.
--  Let's say that your company's copyright notice has to go on
--  every single document. Instead of typing this notice over and over again,
--  you could create an entity reference called copyright_notice with
--  the proper text, then use it in your XML documents as &copyright_notice;.
--
--  This package exists mainly as a place to store documentation about
--  what XML is. Hence, the documentation above.
package Std.XML_Header_Parsers is

   type XML_Document_Kind is
     (
      Not_Yet_Detetrmined,
      --  The header has not yet been fully parsed.

      Document_Kind_UTF8
     );

   type Header_Parser is limited private;

   procedure Initialize
     (This : out Header_Parser);

   procedure Parse_Header
     (This          : in out Header_Parser;
      CP            : in     Octet;
      Document_Kind : in out XML_Document_Kind;
      Call_Result   : in out Subprogram_Call_Result);

private

   type Initial_State_Id is
     (
      Less_Sign,
      Initial_State_Expecting_Question_Mark,
      X,
      XM,
      XML,
      XML_S,
      XML_S_V,
      XML_S_VE,
      XML_S_VER,
      XML_S_VERS,
      XML_S_VERSI,
      XML_S_VERSIO,
      XML_S_VERSION,
      XML_S_VERSION_E,
      XML_S_VERSION_E_Q,
      XML_S_VERSION_E_Q_1,
      XML_S_VERSION_E_Q_1_P,
      XML_S_VERSION_E_Q_1_P_0,
      XML_S_VERSION_E_Q_1_P_0_Q,
      XML_S_VERSION_E_Q_1_P_0_Q_S,
      XML_S_VERSION_E_Q_1_P_0_Q_S_E,
      XML_S_VERSION_E_Q_1_P_0_Q_S_EN,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENC,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENCO,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENCOD,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODI,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODIN,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q_U,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENCODING_E_Q_UT,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q_QM,
      XML_S_VERSION_E_Q_1_P_0_Q_S_ENC_E_Q_UTF_D_8_Q_QM_L,
      End_State
     );

   type Header_Parser is limited record
      State_Id : Initial_State_Id;
   end record;

end Std.XML_Header_Parsers;
