# Link step of egl_reader.
move .\Object\%1.Obj .
link  -subsystem:console -entry:mainCRTStartup -out:%1.exe %1.obj "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.17763.0\um\x86\kernel32.lib" "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.21.27702\lib\x86\libcmt.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.17763.0\um\x86\user32.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.17763.0\um\x86\kernel32.lib" "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.21.27702\lib\x86\libvcruntime.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.17763.0\ucrt\x86\libucrt.lib" "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.17763.0\um\x86\uuid.lib" -map:%1.map /NODEFAULTLIB:"libc.lib"
del %1.obj
del %1.map
move %1.exe egl_reader.exe
