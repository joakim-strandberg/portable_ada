--  with Ada.Text_IO;
with Std.Containers.Text_IO;

package body Std.XML.DOM_Parser.Text_IO is

   procedure Put_Line
     (Name       : String;
      Statistics : Memory_Pool_Statistics) is
   begin
      --  Ada.Text_IO.Put_Line ("Statistics for: " & Name);
      Containers.Text_IO.Put_Line
        (Name       => Name & ".Pool_Nodes",
         Statistics => Statistics.Pool_Nodes);
      Containers.Text_IO.Put_Line
        (Name       => Name & ".Pool_Attributes",
         Statistics => Statistics.Pool_Attributes);
      Containers.Text_IO.Put_Line
        (Name       => Name & ".XML_Elements",
         Statistics => Statistics.XML_Elements);
      Containers.Text_IO.Put_Line
        (Name       => Name & ".Strings_Map",
         Statistics => Statistics.Strings_Map);
      Containers.Text_IO.Put_Line
        (Name       => Name & ".Component_Key_To_XML_Element",
         Statistics => Statistics.Component_Key_To_XML_Element);
      Containers.Text_IO.Put_Line
        (Name       => Name & ".Children_Id_To_Arrays",
         Statistics => Statistics.Children_Id_To_Arrays);
      Containers.Text_IO.Put_Line
        (Name       => Name & ".Attributes_Collection",
         Statistics => Statistics.Attributes_Collection);
   end Put_Line;

end Std.XML.DOM_Parser.Text_IO;
