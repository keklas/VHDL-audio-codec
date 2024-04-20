library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
entity ac_audio is
    Port (
        clk: in std_logic;
        channel_clk: in std_logic;
        ac_recdat : in std_logic;
        int_sample : out signed(29 downto 0):= (others => '0')
    );
end ac_audio;
architecture Behavioral of ac_audio is
signal i : integer := 0;
signal last_channel_clk : std_logic := '0';  -- To detect edges on channel_clk
signal tmp_sample : signed(29 downto 0) := (others => '0');
begin
    process(clk)
    begin    
        if falling_edge(clk) then
            if last_channel_clk /= channel_clk then
                i <= 0;
                tmp_sample <= (others => '0');
                last_channel_clk <= channel_clk;
            else
                if i < 32 and i /= 31 then
                    if i = 0 then -- The first and 32nd bits are 'don't care'
                        i <= i + 1;
                    elsif i = 30 then
                        tmp_sample(29 - i +1) <= ac_recdat;
                        int_sample <= tmp_sample;
                        i <= i + 1;
                    else
                        tmp_sample(29 - i +1) <= ac_recdat;
                        i <= i + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;