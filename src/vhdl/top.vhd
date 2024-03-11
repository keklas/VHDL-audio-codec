library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- For type conversions, we are going to use this package.
use ieee.numeric_std.all;

-- here we are telling the toolchain to include our own package 'utils' to the project from library
-- called xil_defaultlib. It is the default library name used in Xilinx Vivado.
library xil_defaultlib;
use xil_defaultlib.utils.all;

entity top is
    Port (
        sysclk : in STD_LOGIC;
        btn: in std_logic_vector(3 downto 0);
        sw: in std_logic_vector(3 downto 0);
        led : out std_logic_vector(3 downto 0);
        led6_r: out std_logic -- overflow
    );
end top;

architecture Behavioral of top is

begin

process(sysclk)

    -- define a variable. Notice the type inf_array is not a standard, but defined in utils.vhd-package
    variable btns: inf_array(1 downto 0);

    variable s: integer := 0;

    -- this constant holds a maximum value what four bits can have, which is "1111" == 15
    constant maxLeds: std_logic_vector(led'range) := (others => '1');

    begin
        -- Take the two std_logic_vectors, convert them to integer array 
        DualStdLogicToIntArray(btn, sw, btns);

        -- Calculate the sum of integer array, and save the result to variable s
        s := IntegerArraySum(btns);

        -- convert the integer s to 4-bit long unsigned number and convert that to std_logic_vector
        led <= std_logic_vector(to_unsigned(s, led'length));
        
        -- If our sum was larger than 15, turn on led6_r to indicate overflow
        if s > to_integer(unsigned(maxLeds)) then
            led6_r <= '1';
        else
            led6_r <= '0';
        end if;    
    end process;

end Behavioral;
