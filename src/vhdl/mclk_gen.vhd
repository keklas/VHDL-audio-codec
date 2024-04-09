library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Master clock generator
-- 12 MHz master clock -> 48 kHz ADC-DAC sample rate

entity mclk_gen is
    Port ( sys_clk : in  STD_LOGIC;
           mclk_out : out STD_LOGIC
         );
end mclk_gen;

architecture Behavioral of mclk_gen is
    -- Assuming a division factor to approximate 12 MHz, modify as needed
    constant DIVISOR : natural := 10; -- This is a placeholder value
    signal counter : natural range 0 to DIVISOR-1 := 0;
    signal mclk : STD_LOGIC := '0';
begin
    process(sys_clk)
    begin
        if rising_edge(sys_clk) then
            if counter = DIVISOR-1 then
                counter <= 0;
                mclk <= not mclk; -- Toggle the clock output
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
    mclk_out <= mclk;
end Behavioral;
