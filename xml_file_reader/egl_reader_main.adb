with EGL_Reader.Main;
pragma Elaborate_All (EGL_Reader.Main);

--  This file exists because Corder (part of the Janus/Ada compiler toolkit)
--  doesn't support nested subprograms.

--  To run corder in src/ directory:
--
--  Then run cgate.bat to produce main.exe
--
--  Initial state before minimizing heap-allocations:
--  HEAP SUMMARY:
--      in use at exit: 0 bytes in 0 blocks
--    total heap usage: 20,210 allocs, 20,210 frees, 5,660,260 bytes allocated
--
--  All heap blocks were freed -- no leaks are possible
--
--
--  Today:
--  HEAP SUMMARY:
--      in use at exit: 0 bytes in 0 blocks
--    total heap usage: 26 allocs, 26 frees, 1,108,364 bytes allocated
procedure EGL_Reader_Main is
begin
   EGL_Reader.Main;
end EGL_Reader_Main;
