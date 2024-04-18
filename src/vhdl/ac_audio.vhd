library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity ac_audio is
    Port (
        clk: in std_logic;
        ac_recdat : in std_logic;
        int_sample : out std_logic_vector(15 downto 0)
    );
end ac_audio;

architecture Behavioral of ac_audio is

begin
    process(clk)
    variable i: integer := 0;
    begin    
        if falling_edge(clk) then
            if i < 18 and i /= 17 then
                if i = 0 then -- The first and 18th bits are 'don't care'
                    i := i + 1;
                else
                    int_sample(i - 1) <= ac_recdat;
                    i := i + 1;
                end if;
            else
                i := 0;
            end if;
        end if;
    end process;
end Behavioral;
