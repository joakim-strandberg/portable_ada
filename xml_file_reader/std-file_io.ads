with Ada.Streams.Stream_IO;
with Std.Ada_Extensions; use Std.Ada_Extensions;
with Std.Containers.Unbounded_Octet_Vectors;

package Std.File_IO is

   type File_Reader
     (
      Name : access String;
      Initial_Elements_Count : Octet_Offset
     )
   is limited private;
   --  Reads the whole file specified by Name into memory.
   --  It uses the pre-allocated memory specified by Initial_Elements_Count
   --  and allocates more memory if needed.

   procedure Initialize
     (This        : out File_Reader;
      Call_Result : in out Subprogram_Call_Result);

   procedure Finalize (This : in out File_Reader);

   function File_Contents
     (
      This : File_Reader
     ) return Std.Containers.Unbounded_Octet_Vectors.Constant_Elements_Ptr;

   function Last_Index
     (
      This : File_Reader
     ) return Std.Containers.Unbounded_Octet_Vectors.Extended_Index;

private

   type File_Reader
     (
      Name : access String;
      Initial_Elements_Count : Octet_Offset
     )
   is limited record
      File_Buffer : Std.Containers.Unbounded_Octet_Vectors.Vector
        (Initial_Elements_Count);
      Input_File : Ada.Streams.Stream_IO.File_Type;
   end record;

end Std.File_IO;
