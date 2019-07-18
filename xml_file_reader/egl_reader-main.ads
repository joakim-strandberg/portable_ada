--  Static code analysis should check:
--
--   - All type declarations are uniquely defined by having the package
--     names explicitly specified.
--   - It's possible to use use-statements for subprograms where the first
--     argument is a type defined in the same package as the subprogram,
--     or the subprogram is defined in a child-package of the package
--     where the type of the first argument is defined.
--   - While loops should be avoided.
procedure EGL_Reader.Main;
