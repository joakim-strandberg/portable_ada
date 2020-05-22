with Ada.Strings.Unbounded;
with Std.UTF8.Categorizations;
with Std.UTF8.Category_Ranges;

package body Std.UTF8 is

   procedure Put
     (Destination : in out Octet_Array;
      Pointer     : in out Octet_Offset;
      Value       : Code_Point) is
   begin
      if Value <= 16#7F# then
         Destination (Pointer) := Octet (Value);
         Pointer := Pointer + 1;
      elsif Value <= 16#7FF# then
         Destination (Pointer)     := Octet (16#C0# or Value / 2**6);
         Destination (Pointer + 1) := Octet (16#80# or (Value and 16#3F#));
         Pointer := Pointer + 2;
      elsif Value <= 16#FFFF# then
         Destination (Pointer)
           := Octet (16#E0# or Value / 2**12);
         Destination (Pointer + 1)
           := Octet (16#80# or (Value / 2**6 and 16#3F#));
         Destination (Pointer + 2)
           := Octet (16#80# or (Value and 16#3F#));
         Pointer := Pointer + 3;
      else
         Destination (Pointer)
           := Octet (16#F0# or Value / 2**18);
         Destination (Pointer + 1)
           := Octet (16#80# or (Value / 2**12 and 16#3F#));
         Destination (Pointer + 2)
           := Octet (16#80# or (Value / 2**6 and 16#3F#));
         Destination (Pointer + 3)
           := Octet (16#80# or (Value and 16#3F#));
         Pointer := Pointer + 4;
      end if;
   end Put;

   function Image (Value : Code_Point) return Octet_Array is
      Result  : Octet_Array (1 .. 4);
      Pointer : Octet_Offset := 1;
   begin
      UTF8.Put (Result, Pointer, Value);
      return Result (1 .. Pointer - 1);
   end Image;

   function Image (Value : Code_Point) return String is
      Temp   : constant Octet_Array := Image (Value);
      Result : String (Natural (Temp'First) .. Natural (Temp'Last));
   begin
      for I in Temp'Range loop
         Result (Natural (I)) := Character'Val (Temp (I));
      end loop;
      return Result;
   end Image;

   function Image (Value : Octet_Array) return String is
      Result : Ada.Strings.Unbounded.Unbounded_String;
      P : Octet_Offset := Value'First;

      CP : Code_Point;
   begin
      while P <= Value'Last loop
         if
           (not UTF8.Is_Valid_UTF8_Code_Point
              (Source => Value,
               Pointer => P))
         then
            raise Constraint_Error;
         end if;

         Get (Source  => Value,
              Pointer => P,
              Value   => CP);
         Ada.Strings.Unbounded.Append (Result, Image (CP));
      end loop;
      return Ada.Strings.Unbounded.To_String (Result);
   end Image;

   --  The Find procedure can be formally verified
   --  by SPARK GPL 2016, Level=None and it takes around 20 seconds:
   --
   procedure Find (Code  : Code_Point;
                   Found : out Boolean;
                   Index : in out Categorization_Index);

   procedure Find (Code  : Code_Point;
                   Found : out Boolean;
                   Index : in out Categorization_Index)
   is
      From    : Categorization_Index'Base := Categorization_Index'First;
      To      : Categorization_Index'Base := Categorization_Index'Last;
      This    : Categorization_Index;
      Current : Code_Point;
   begin
      while From <= To loop
         This    := From + (To - From) / 2;
         Current := Categorizations.Mapping (This).Code;

         if Current < Code then
            From := This + 1;
         elsif Current > Code then
            To := This - 1;
         elsif Current = Code then
            Found := True;
            Index := This;
            return;
         else
            Found := False;
            return;
         end if;
      end loop;
      Found := False;
   end Find;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Uppercase (Value : Code_Point) return Boolean is
      Index : Categorization_Index := Categorization_Index'First;
      Found : Boolean;
   begin
      Find (Value, Found, Index);
      if Found then
         return Categorizations.Mapping (Index).Upper = Value;
      else
         return False;
      end if;
   end Is_Uppercase;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Has_Case (Value : Code_Point) return Boolean is
      Index : Categorization_Index := Categorization_Index'First;
      Found : Boolean;
   begin
      Find (Value, Found, Index);
      if Found then
         return
           (Categorizations.Mapping (Index).Lower = Value
            or else Categorizations.Mapping (Index).Upper = Value);
      else
         return False;
      end if;
   end Has_Case;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Lowercase (Value : Code_Point) return Boolean is
      Index : Categorization_Index := Categorization_Index'First;
      Found : Boolean;
   begin
      Find (Value, Found, Index);
      if Found then
         return Categorizations.Mapping (Index).Lower = Value;
      else
         return False;
      end if;
   end Is_Lowercase;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function To_Lowercase (Value : Code_Point) return Code_Point is
      Index : Categorization_Index := Categorization_Index'First;
      Found : Boolean;
   begin
      Find (Value, Found, Index);
      if Found then
         return Categorizations.Mapping (Index).Lower;
      else
         return Value;
      end if;
   end To_Lowercase;

   function To_Uppercase (Value : Code_Point) return Code_Point is
      Index : Categorization_Index := Categorization_Index'First;
      Found : Boolean;
   begin
      Find (Value, Found, Index);
      if Found then
         return Categorizations.Mapping (Index).Upper;
      else
         return Value;
      end if;
   end To_Uppercase;

   function Category (Value : Code_Point) return General_Category is
      From    : Range_Index := Range_Index'First;
      To      : Range_Index := Range_Index'Last;
      This    : Range_Index;
      Current : Points_Range;
   begin
      loop
         This    := (From + To) / 2;
         Current := Category_Ranges.Mapping (This);
         if Current.From > Value then
            exit when This = From;
            To := This - 1;
         elsif Current.To < Value then
            exit when This = To;
            From := This + 1;
         else
            return Current.Category;
         end if;
      end loop;
      return Co;
   end Category;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Alphanumeric (Value : in Code_Point) return Boolean is
   begin
      case Category (Value) is
         when Letter | Nd =>
            return True;
         when others =>
            return False;
      end case;
   end Is_Alphanumeric;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Control (Value : in Code_Point) return Boolean is
   begin
      return Category (Value) = Cc;
   end Is_Control;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Identifier_Extend (Value : in Code_Point) return Boolean is
   begin
      case Category (Value) is
         when Mn | Mc | Nd | Pc | Cf =>
            return True;
         when others =>
            return False;
      end case;
   end Is_Identifier_Extend;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Identifier_Start (Value : in Code_Point) return Boolean is
   begin
      case Category (Value) is
         when Letter | Nl =>
            return True;
         when others =>
            return False;
      end case;
   end Is_Identifier_Start;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_ISO_646 (Value : in Code_Point) return Boolean is
   begin
      return Value <= 16#7F#;
   end Is_ISO_646;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Letter (Value : in Code_Point) return Boolean is
   begin
      return Category (Value) in Letter;
   end Is_Letter;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Lower (Value : in Code_Point) return Boolean is
   begin
      return Category (Value) = Ll;
   end Is_Lower;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Digit (Value : in Code_Point) return Boolean is
   begin
      return Category (Value) = Nd;
   end Is_Digit;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Other_Format (Value : in Code_Point) return Boolean is
   begin
      return Category (Value) = Cf;
   end Is_Other_Format;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Space (Value : in Code_Point) return Boolean is
   begin
      return Category (Value) = Zs;
   end Is_Space;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Subscript_Digit (Value : in Code_Point) return Boolean is
   begin
      return Value in 16#2080# .. 16#208A#;
   end Is_Subscript_Digit;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Superscript_Digit (Value : in Code_Point) return Boolean is
   begin
      case Value is
         when 16#B2# .. 16#B3# | 16#B9# | 16#2070# .. 16#2079# =>
            return True;
         when others =>
            return False;
      end case;
   end Is_Superscript_Digit;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Title (Value : in Code_Point) return Boolean is
   begin
      return Category (Value) = Lt;
   end Is_Title;

   --  Verified by: SPARK GPL 2016
   --  Level: None
   --  Elapsed time: 12 seconds
   function Is_Upper (Value : in Code_Point) return Boolean is
   begin
      return Category (Value) = Lu;
   end Is_Upper;

   function Is_Valid_UTF8_Code_Point
     (Source  : Octet_Array;
      Pointer : Octet_Offset) return Boolean is
   begin
      if (Source'First <= Pointer and Pointer <= Source'Last) then
         if (Source (Pointer) in 0 .. 16#7F#) then
            return Pointer < Octet_Offset'Last;
         elsif Pointer < Source'Last then
            if
              Source (Pointer + 0) in 16#C2# .. 16#DF# and
              Source (Pointer + 1) in 16#80# .. 16#BF#
            then
               return Pointer < Octet_Offset'Last - 1;
            elsif Pointer < Source'Last - 1 then
               if
                 Source (Pointer + 0) = 16#E0# and
                 Source (Pointer + 1) in 16#A0# .. 16#BF# and
                 Source (Pointer + 2) in 16#80# .. 16#BF#
               then
                  return Pointer < Octet_Offset'Last - 2;
               elsif
                 Source (Pointer + 0) in 16#E1# .. 16#EF# and
                 Source (Pointer + 1) in 16#80# .. 16#BF# and
                 Source (Pointer + 2) in 16#80# .. 16#BF#
               then
                  return Pointer < Octet_Offset'Last - 2;
               elsif Pointer < Source'Last - 2 then
                  if
                    Source (Pointer + 0) = 16#F0# and
                    Source (Pointer + 1) in 16#90# .. 16#BF# and
                    Source (Pointer + 2) in 16#80# .. 16#BF# and
                    Source (Pointer + 3) in 16#80# .. 16#BF#
                  then
                     return Pointer < Octet_Offset'Last - 3;
                  elsif
                    Source (Pointer + 0) in 16#F1# .. 16#F3# and
                    Source (Pointer + 1) in 16#80# .. 16#BF# and
                    Source (Pointer + 2) in 16#80# .. 16#BF# and
                    Source (Pointer + 3) in 16#80# .. 16#BF#
                  then
                     return Pointer < Octet_Offset'Last - 3;
                  elsif
                    Source (Pointer + 0) = 16#F4# and
                    Source (Pointer + 1) in 16#80# .. 16#8F# and
                    Source (Pointer + 2) in 16#80# .. 16#BF# and
                    Source (Pointer + 3) in 16#80# .. 16#BF#
                  then
                     return Pointer < Octet_Offset'Last - 3;
                  else
                     return False;
                  end if;
               else
                  return False;
               end if;
            else
               return False;
            end if;
         else
            return False;
         end if;
      else
         return False;
      end if;
   end Is_Valid_UTF8_Code_Point;

   procedure Get
     (Source  : Octet_Array;
      Pointer : in out Octet_Offset;
      Value   : out Code_Point)
   is
      Accum : Code_Point'Base;
      Code  : Code_Point'Base;
   begin
      Code := Code_Point (Source (Pointer));

      case Code is
         when 0 .. 16#7F# => -- 1 byte (ASCII)
            Value   := Code;
            Pointer := Pointer + 1;
         when 16#C2# .. 16#DF# => -- 2 bytes
            Accum := (Code and 16#1F#) * 2**6;
            Code := Code_Point (Source (Pointer + 1));
            Value   := Accum or (Code and 16#3F#);
            Pointer := Pointer + 2;
         when 16#E0# => -- 3 bytes
            Code := Code_Point (Source (Pointer + 1));
            Accum := (Code and 16#3F#) * 2**6;
            Code := Code_Point (Source (Pointer + 2));
            Value   := Accum or (Code and 16#3F#);
            Pointer := Pointer + 3;
         when 16#E1# .. 16#EF# => -- 3 bytes
            Accum := (Code and 16#0F#) * 2**12;
            Code := Code_Point (Source (Pointer + 1));
            Accum := Accum or (Code and 16#3F#) * 2**6;
            Code := Code_Point (Source (Pointer + 2));
            Value   := Accum or (Code and 16#3F#);
            Pointer := Pointer + 3;
         when 16#F0# => -- 4 bytes
            Code := Code_Point (Source (Pointer + 1));
            Accum := (Code and 16#3F#) * 2**12;
            Code := Code_Point (Source (Pointer + 2));
            Accum := Accum or (Code and 16#3F#) * 2**6;
            Code := Code_Point (Source (Pointer + 3));
            Value   := Accum or (Code and 16#3F#);
            Pointer := Pointer + 4;
         when 16#F1# .. 16#F3# => -- 4 bytes
            Accum := (Code and 16#07#) * 2**18;
            Code := Code_Point (Source (Pointer + 1));
            Accum := Accum or (Code and 16#3F#) * 2**12;
            Code := Code_Point (Source (Pointer + 2));
            Accum := Accum or (Code and 16#3F#) * 2**6;
            Code := Code_Point (Source (Pointer + 3));
            Value   := Accum or (Code and 16#3F#);
            Pointer := Pointer + 4;
         when 16#F4# => -- 4 bytes
            Accum := (Code and 16#07#) * 2**18;
            Code := Code_Point (Source (Pointer + 1));
            Accum := Accum or (Code and 16#3F#) * 2**12;
            Code := Code_Point (Source (Pointer + 2));
            Accum := Accum or (Code and 16#3F#) * 2**6;
            Code := Code_Point (Source (Pointer + 3));
            Value   := Accum or (Code and 16#3F#);
            Pointer := Pointer + 4;
         when others =>
            raise Constraint_Error;
            --  This exception will never be raised if pre-conditions are met.
      end case;
   end Get;

   function Is_Valid_UTF8 (Source : Octet_Array) return Boolean is
      Accum : Code_Point;

      Index : Octet_Offset := Source'First;
   begin
      while Index <= Source'Last loop
         if Is_Valid_UTF8_Code_Point (Source, Index) then
            Get (Source, Index, Accum);
         else
            exit;
         end if;
      end loop;
      return Index = Source'Last + 1;
   end Is_Valid_UTF8;

   function Length (Source : Octet_Array) return Nat32 is
      Count : Nat32 := 0;
      Accum : Code_Point;

      Index : Octet_Offset := Source'First;
   begin
      while Index <= Source'Last loop
         if Is_Valid_UTF8_Code_Point (Source, Index) then
            Get (Source, Index, Accum);
            Count := Count + 1;
         else
            exit;
         end if;
      end loop;
      return Count;
   end Length;

   function To_Lowercase (Value : Octet_Array) return Octet_Array is
      Result : Octet_Array (1 .. Value'Length);
      From   : Octet_Offset := Value'First;
      To     : Octet_Offset := 1;
      Code   : Code_Point;
   begin
      while From <= Value'Last loop
         UTF8.Get (Value, From, Code);
         Code := To_Lowercase (Code);
         UTF8.Put (Result, To, Code);
      end loop;
      return Result (1 .. To - 1);
   end To_Lowercase;

   function To_Uppercase (Value : Octet_Array) return Octet_Array is
      Result : Octet_Array (1 .. Value'Length);
      From   : Octet_Offset := Value'First;
      To     : Octet_Offset := 1;
      Code   : Code_Point;
   begin
      while From <= Value'Last loop
         UTF8.Get (Value, From, Code);
         Code := To_Uppercase (Code);
         UTF8.Put (Result, To, Code);
      end loop;
      return Result (1 .. To - 1);
   end To_Uppercase;

end Std.UTF8;
