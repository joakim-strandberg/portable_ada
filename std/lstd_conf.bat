# Link step of for std_conf_janus.exe
cd janus
link  -subsystem:console -entry:mainCRTStartup -out:%1.exe %1.obj libcmt.lib kernel32.lib user32.lib -map:%1.map /NODEFAULTLIB:"libc.lib"
move %1.exe ..\std_conf_janus.exe
cd ..
