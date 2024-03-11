library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.Numeric_Std.all; -- ieee.std_logic_arith not recommended for new designs

package utils is
    
    -- A new type (example taken from lecture slides).
    -- This is an integer array, which can be of any length. 
    type inf_array is array (integer range <>) of integer;

    -- function "prototype". It has one IN-type argument, and one return value.
    function IntegerArraySum ( arr: in inf_array ) return integer;
    
    -- procedure "prototype". It does not return anything, but in its parameters there is
    -- one value which direction is OUT.
    procedure DualStdLogicToIntArray (
	in1: in std_logic_vector;
	in2: in std_logic_vector;
	arr: out inf_array(1 downto 0)
	); 
    
end package;


package body utils is

    -- Calculate sum of integers in an array. Note the array can be any length with this function.
    function IntegerArraySum ( arr: in inf_array ) return integer is
        variable s: integer := 0;
    begin
        for i in arr'range LOOP
            s := s + arr(i);
        end loop;
        return s;
    end;
    
    -- This procedure takes two std_logic_vectors, converts them to integers and assigns them
    -- to integer array.
    procedure DualStdLogicToIntArray (
	in1: in std_logic_vector;
	in2: in std_logic_vector;
	arr: out inf_array(1 downto 0)) is
    begin
        arr(0) := to_integer(unsigned(in1));
        arr(1) := to_integer(unsigned(in2));
    end procedure;


end package body utils;
