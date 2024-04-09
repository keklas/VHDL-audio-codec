library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ac_control is
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC; -- Enable signal for the audio processor
           audio_in : in STD_LOGIC_VECTOR(15 downto 0); -- Assuming 16-bit input
           amplified_audio_out : out STD_LOGIC_VECTOR(15 downto 0) -- 16-bit output
         );
end ac_control;

architecture Behavioral of ac_control is
    -- Define the gain factor
    constant gain_factor : integer := 2; 
    signal audio_sample_signed : signed(15 downto 0);
    signal amplified_audio_sample : signed(15 downto 0);
begin

end architecture;

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                -- Convert input to signed format for multiplication
                audio_sample_signed <= signed(audio_in);
                
                -- Amplify the audio signal
                amplified_audio_sample <= audio_sample_signed * gain_factor;
                
                -- Convert back to STD_LOGIC_VECTOR for output
                amplified_audio_out <= std_logic_vector(amplified_audio_sample);
            else
                -- If not enabled, pass the input audio directly to output
                amplified_audio_out <= audio_in;
            end if;
        end if;
    end process;
end Behavioral;