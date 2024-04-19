library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ac_control is
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC; -- Gain enable signal
           audio_in : in SIGNED(15 downto 0);
           audio_out : out STD_LOGIC;
           pblrc : in STD_LOGIC -- Playback Left/Right Clock
         );
end ac_control;

architecture Behavioral of ac_control is
    constant gain_factor : integer := 1; -- Number of left shifts
    signal audio_sample : SIGNED(15 downto 0);
    signal amplified_audio_sample : SIGNED(15 downto 0);
    signal bit_counter : integer range 0 to 15 := 15; -- Counter for the current bit
    signal enable_prev : std_logic := '0'; -- Previous value of enable
    signal pblrc_prev : std_logic := '0'; -- Previous value of pblrc

begin
    process(clk, pblrc)
    begin
        if falling_edge(clk) and pblrc /= pblrc_prev then
            if enable = '1' and enable_prev = '0' then
                bit_counter <= 15; -- Reset the counter to 15 when enable changes from 0 to 1
            end if;
            
            if enable = '1' then
                audio_sample <= audio_in;
                
                if audio_sample >= 2**(15-gain_factor) then
                    amplified_audio_sample <= "0111111111111111"; -- Maximum positive value
                elsif audio_sample < -2**(15-gain_factor) then
                    amplified_audio_sample <= "1000000000000000"; -- Maximum negative value
                else
                    amplified_audio_sample <= shift_left(audio_sample, gain_factor); -- Use shift_left
                end if;
                
                if amplified_audio_sample(15) /= audio_sample(15) then
                    if audio_sample(15) = '0' then
                        amplified_audio_sample <= "0111111111111111"; -- Maximum positive value
                    else
                        amplified_audio_sample <= "1000000000000000"; -- Maximum negative value
                    end if;
                end if;

                audio_out <= amplified_audio_sample(bit_counter); -- Send out bit by bit
                
                if bit_counter = 0 then
                    bit_counter <= 15; -- Reset the counter to 15 when it reaches 0
                else
                    bit_counter <= bit_counter - 1; -- Decrement the counter
                end if;
            else
                audio_out <= audio_in(bit_counter); -- If enable = 0, pass the input audio directly to output
                
                if bit_counter = 0 then
                    bit_counter <= 15; -- Reset the counter to 15 when it reaches 0
                else
                    bit_counter <= bit_counter - 1; -- Decrement the counter
                end if;
            end if;
            
            enable_prev <= enable; -- Store the current value of enable
            pblrc_prev <= pblrc; -- Store the current value of pblrc
        end if;
    end process;
end Behavioral;