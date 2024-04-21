library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ac_control is
    Port ( clk : in std_logic;
           channel_clk : in std_logic; -- Playback Left/Right Clock
           enable : in std_logic; -- Gain enable signal
           audio_in : in signed(29 downto 0);
           audio_out : out std_logic           
    );
end ac_control;

architecture Behavioral of ac_control is
    constant gain_factor : integer := 1; -- Number of left shifts
    signal audio_sample : signed(29 downto 0);
    signal amplified_audio_sample : signed(29 downto 0);
    signal bit_counter : integer range 0 to 31 := 31; -- Counter for the current bit
    signal enable_prev : std_logic := '0'; -- Previous value of enable
    signal channel_clk_prev : std_logic := '0'; -- Previous value of pblrc
begin
    process(clk)
    begin
        if falling_edge(clk) then
            if enable = '1' and enable_prev = '0' then
                bit_counter <= 31; -- Reset the counter to 31 when enable changes from 0 to 1
            end if;
            
            if enable = '1' then
                audio_sample <= audio_in;
                
                if channel_clk /= channel_clk_prev then
                    bit_counter <= 31;
                else
                    if audio_sample >= 2**(29-gain_factor) then
                        amplified_audio_sample <= (0 => '0', others => '1'); -- Maximum positive value, '0' at the MSB followed by '1's 
                    elsif audio_sample < -2**(29-gain_factor) then
                        amplified_audio_sample <= (0 => '1', others => '0'); -- Maximum negative value, '1' at the MSB followed by '0's
                    else
                        if audio_in > 0 then
                            amplified_audio_sample <= shift_left(audio_sample, gain_factor); -- Use shift_left
                         elsif audio_in < 0 then
                            amplified_audio_sample <= shift_left(audio_sample, gain_factor); -- Use shift_left
                        end if;
                    end if;
                    
--                    if amplified_audio_sample(29) /= audio_sample(29) then
--                        if audio_sample(29) = '0' then
--                            amplified_audio_sample <= (0 => '0', others => '1'); -- Maximum positive value, '0' at the MSB followed by '1's
--                        else
--                            amplified_audio_sample <= (0 => '1', others => '0'); -- Maximum negative value, '1' at the MSB followed by '0's
--                        end if;
--                    end if;

                    if bit_counter > 0 and bit_counter < 31 then
                        audio_out <= amplified_audio_sample(bit_counter-1); -- Send out bit by bit
                    end if;
                    if bit_counter > 0 then
                        bit_counter <= bit_counter - 1; -- Decrement the counter
                    end if;                
                end if;                

            else
                if channel_clk /= channel_clk_prev then
                    bit_counter <= 31;
                else
                    if bit_counter > 0 and bit_counter < 31 then
                        audio_out <= audio_in(bit_counter-1); -- If enable = 0, pass the input audio directly to output
                    end if;
                    if bit_counter > 0 then
                        bit_counter <= bit_counter - 1; -- Decrement the counter
                    end if;
                end if;
            end if;
            
            enable_prev <= enable; -- Store the current value of enable
            channel_clk_prev <= channel_clk;   -- Store the current value of pblrc
        end if;
    end process;
end Behavioral;