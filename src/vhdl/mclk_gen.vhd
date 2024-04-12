library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

-- Master clock generator
-- 125 Mhz -> 12 MHz master clock -> 48 kHz ADC-DAC sample rate
-- can the internal clock be set to 100 MHz instead???

entity mclk_gen is
    Port ( sysclk : in  STD_LOGIC;
           mclk_out : out STD_LOGIC
         );
end mclk_gen;

architecture Behavioral of mclk_gen is
    -- Division here is not exact
    -- A division of 10 on a 125 MHz signal gives  6.3 MHz
    -- A division of  9 on a 125 MHz signal gives  6.9 MHz
    -- A division of  8 on a 125 MHz signal gives  7.8 MHz
    -- A division of  7 on a 125 MHz signal gives  8.9 MHz
    -- A division of  6 on a 125 MHz signal gives 10.4 MHz
    -- A division of  5 on a 125 MHz signal gives 12.5 MHz
    -- A division of  4 on a 125 MHz signal gives 15.6 MHz
    -- A division of  3 on a 125 MHz signal gives 20.8 MHz
    -- A division of  2 on a 125 MHz signal gives 31.3 MHz
    constant DIVISOR : natural := 5;
    signal counter : natural range 0 to DIVISOR-1 := 0;
    signal mclk : STD_LOGIC := '0';
begin
    process(sysclk)
    begin
        if rising_edge(sysclk) then
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
