package body Std.Big_Endian is

   use type Interfaces.Integer_32;
   use type Interfaces.Unsigned_32;
   use type Octet;

   procedure To_Octets
     (Octets : in out Octet_Array;
      Value  : Int32;
      Index  : in out Octet_Offset) is
   begin
      if Value >= 0 then
         declare
            A : constant Interfaces.Unsigned_32
              := Interfaces.Unsigned_32 (Value);
            B : constant Interfaces.Unsigned_32
              := A and Interfaces.Unsigned_32'(255);
            C : constant Interfaces.Unsigned_32
              := Interfaces.Shift_Right
                (Value  => A,
                 Amount => 8) and Interfaces.Unsigned_32'(255);
            D : constant Interfaces.Unsigned_32
              := Interfaces.Shift_Right
                (Value  => A,
                 Amount => 16) and Interfaces.Unsigned_32'(255);
            E : constant Interfaces.Unsigned_32
              := Interfaces.Shift_Right
                (Value  => A,
                 Amount => 24) and Interfaces.Unsigned_32'(255);
         begin
            Octets.Items (Index + 0) := Octet (E);
            Octets.Items (Index + 1) := Octet (D);
            Octets.Items (Index + 2) := Octet (C);
            Octets.Items (Index + 3) := Octet (B);
         end;
      else
         declare
            A : constant Interfaces.Unsigned_32
              := Interfaces.Unsigned_32 ((Int32'Last + Value) + 1);
            B : constant Interfaces.Unsigned_32
              := A and Interfaces.Unsigned_32'(255);
            C : constant Interfaces.Unsigned_32
              := Interfaces.Shift_Right
                (Value  => A,
                 Amount => 8) and Interfaces.Unsigned_32'(255);
            D : constant Interfaces.Unsigned_32
              := Interfaces.Shift_Right
                (Value  => A,
                 Amount => 16) and Interfaces.Unsigned_32'(255);
            E : constant Interfaces.Unsigned_32
              := Interfaces.Shift_Right
                (Value  => A,
                 Amount => 24) and Interfaces.Unsigned_32'(255);
         begin
            Octets.Items (Index + 0) := Octet (E or 2#1000_0000#);
            Octets.Items (Index + 1) := Octet (D);
            Octets.Items (Index + 2) := Octet (C);
            Octets.Items (Index + 3) := Octet (B);
         end;
      end if;
      Index := Index + 4;
   end To_Octets;

   procedure To_Integer_32
     (Octets : in     Octet_Array;
      Value  :    out Interfaces.Integer_32;
      Index  : in out Octet_Offset)
   is
      Is_Negative : constant Boolean := Octets.Items (Index + 0) >= 128;
      Temp   : Interfaces.Unsigned_32;
   begin
      if Is_Negative then
         declare
            A : constant Interfaces.Unsigned_32
              := Interfaces.Unsigned_32 (Octets.Items (Index + 0));
            B : Interfaces.Unsigned_32
              := A and 2#0111_1111#;
         begin
            B := Interfaces.Shift_Left
              (Value  => B,
               Amount => 8);
            B := B + Interfaces.Unsigned_32 (Octets.Items (Index + 1));
            B := Interfaces.Shift_Left
              (Value  => B,
               Amount => 8);
            B := B + Interfaces.Unsigned_32 (Octets.Items (Index + 2));
            B := Interfaces.Shift_Left
              (Value  => B,
               Amount => 8);
            B := B + Interfaces.Unsigned_32 (Octets.Items (Index + 3));
            Value := Interfaces.Integer_32 (B);
            Value := Value - Interfaces.Integer_32 (Int32'Last) - 1;
         end;
      else
         Temp := Interfaces.Unsigned_32 (Octets.Items (Index + 0));
         Temp := Interfaces.Shift_Left
           (Value  => Temp,
            Amount => 8);
         Temp := Temp + Interfaces.Unsigned_32 (Octets.Items (Index + 1));
         Temp := Interfaces.Shift_Left
           (Value  => Temp,
            Amount => 8);
         Temp := Temp + Interfaces.Unsigned_32 (Octets.Items (Index + 2));
         Temp := Interfaces.Shift_Left
           (Value  => Temp,
            Amount => 8);
         Temp := Temp + Interfaces.Unsigned_32 (Octets.Items (Index + 3));
         Value := Interfaces.Integer_32 (Temp);
      end if;
      Index := Index + 4;
   end To_Integer_32;

end Std.Big_Endian;
