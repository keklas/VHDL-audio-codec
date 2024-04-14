library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ac_control is
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC; -- Gain enable signal
           audio_in : in STD_LOGIC_VECTOR(15 downto 0);
           amplified_audio_out : out STD_LOGIC_VECTOR(15 downto 0)
         );
end ac_control;

architecture Behavioral of ac_control is
    constant gain_factor : integer := 1; -- Number of left shifts
    signal audio_sample : unsigned(15 downto 0);
    signal amplified_audio_sample : unsigned(15 downto 0);

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                audio_sample <= unsigned(audio_in);
                
                if audio_sample >= 2**(16-gain_factor) then
                    amplified_audio_sample <= (others => '1'); -- Maximum value
                else
                    amplified_audio_sample <= shift_left(audio_sample, gain_factor); -- Use shift_left
                end if;
                
                amplified_audio_out <= std_logic_vector(amplified_audio_sample);
            else
                amplified_audio_out <= audio_in; -- If enable = 0, pass the input audio directly to output
            end if;
        end if;
    end process;
end Behavioral;