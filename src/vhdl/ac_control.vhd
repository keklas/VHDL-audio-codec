library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ac_control is
    Port ( clk : in STD_LOGIC;
           enable : in STD_LOGIC; -- Gain enable signal
           audio_in : in STD_LOGIC;
           amplified_audio_out : out STD_LOGIC
         );
end ac_control;

architecture Behavioral of ac_control is
    constant gain_factor : integer := 1; -- Number of left shifts
    signal audio_sample : std_logic_vector(15 downto 0);
    signal amplified_audio_sample : std_logic_vector(15 downto 0);
    signal bit_counter : integer range 0 to 15 := 0; -- Counter for the current bit
    signal enable_prev : std_logic := '0'; -- Previous value of enable

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' and enable_prev = '0' then
                bit_counter <= 0; -- Reset the counter when enable changes from '0' to '1'
            end if;
            
            if enable = '1' then
                audio_sample(bit_counter) <= audio_in;
                
                if unsigned(audio_sample) >= 2**(16-gain_factor) then
                    amplified_audio_sample <= (others => '1'); -- Maximum value
                else
                    amplified_audio_sample <= std_logic_vector(shift_left(unsigned(audio_sample), gain_factor)); -- Use shift_left
                end if;
                
                amplified_audio_out <= amplified_audio_sample(bit_counter); -- Send out bit by bit
                bit_counter <= (bit_counter + 1) mod 16; -- Increment the counter
            else
                amplified_audio_out <= audio_in; -- If enable = 0, pass the input audio directly to output
            end if;
            
            enable_prev <= enable; -- Store the current value of enable for the next clock cycle
        end if;
    end process;
end Behavioral;