with Ada.Streams.Stream_IO;

package body Std.File_IO is

   use Ada.Streams.Stream_IO;
   use Std.Containers.Unbounded_Octet_Vectors;

   procedure Initialize
     (This        :    out File_Reader;
      Call_Result : in out Subprogram_Call_Result)
   is
      procedure Initialize_File_Buffer;
      procedure Open_Input_File;
      procedure Read_All_Contents_Of_Input_File;

      procedure Initialize_File_Buffer is
      begin
         Initialize (This.File_Buffer);
         Open_Input_File;
      end Initialize_File_Buffer;

      procedure Open_Input_File is
      begin
         Open (File => This.Input_File,
               Mode => Ada.Streams.Stream_IO.In_File,
               Name => This.Name.all);
         Read_All_Contents_Of_Input_File;
      end Open_Input_File;

      procedure Read_All_Contents_Of_Input_File is

         procedure Read_File;

         Is_End_Of_File_Reached : Boolean := False;

         procedure Read_File is
            Buffer : Octet_Array (1 .. 1024);
            Count  : Octet_Offset;
         begin
            for I in Pos32'Range loop
               if End_Of_File (This.Input_File) then
                  Is_End_Of_File_Reached := True;
                  exit;
               end if;
               Read (File => This.Input_File,
                     Item => Buffer,
                     Last => Count);
               for I in Buffer'First .. Count loop
                  Append (This.File_Buffer, Buffer (I));
               end loop;
            end loop;
         end Read_File;

      begin
         Read_File;

         if not Is_End_Of_File_Reached then
            Ada_Extensions.Initialize (Call_Result, 1200128260, -1400763670);
         end if;
      end Read_All_Contents_Of_Input_File;

   begin
      Initialize_File_Buffer;
   end Initialize;

   procedure Finalize (This : in out File_Reader) is

      procedure Finalize_File_Buffer;
      procedure Close_File;

      procedure Finalize_File_Buffer is
      begin
         Close_File;
         Finalize (This.File_Buffer);
      exception
         when others =>
            Finalize (This.File_Buffer);
            raise;
      end Finalize_File_Buffer;

      procedure Close_File is
      begin
         if Is_Open (This.Input_File) then
            Close (This.Input_File);
         end if;
      end Close_File;

   begin
      Finalize_File_Buffer;
   end Finalize;

   function File_Contents
     (
      This : File_Reader
     ) return Std.Containers.Unbounded_Octet_Vectors.Constant_Elements_Ptr is
   begin
      return Elements_Reference (This.File_Buffer);
   end File_Contents;

   function Last_Index
     (
      This : File_Reader
     ) return Std.Containers.Unbounded_Octet_Vectors.Extended_Index is
   begin
      return Last_Index (This.File_Buffer);
   end Last_Index;

end Std.File_IO;
