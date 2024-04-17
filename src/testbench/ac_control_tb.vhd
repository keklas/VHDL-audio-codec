library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ac_control_tb is
end ac_control_tb;

architecture Behavioral of ac_control_tb is
    constant gain_factor : integer := 1; -- Number of left shifts
    signal clk : std_logic := '0';
    signal enable : std_logic := '0';
    signal audio_in : std_logic_vector(15 downto 0) := (others => '0');
    signal audio_out : std_logic;
    signal expected_output : std_logic_vector(15 downto 0); -- Declare expected_output as a signal
    signal bit_counter : integer range 0 to 15 := 0; -- Counter for the current bit
    
    constant clk_period : time := 10 ns;
    constant sample_period : integer := 16; -- Number of clock cycles per audio sample
    signal sample_counter : integer range 0 to sample_period-1 := 0; -- Counter for the current sample

begin
    uut: entity work.ac_control(Behavioral)
        port map (
            clk => clk,
            enable => enable,
            audio_in => audio_in,
            audio_out => audio_out
        );

    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process
    begin
        enable <= '0';
        for i in 0 to 65535 loop
            if sample_counter = 0 then
                audio_in <= std_logic_vector(to_unsigned(i, 16));
            end if;
            wait for clk_period;
            assert audio_in(bit_counter) = audio_out
                report "Test failed for input " & integer'image(i)
                severity error;
            bit_counter <= (bit_counter + 1) mod 16; -- Increment the counter
            sample_counter <= (sample_counter + 1) mod sample_period; -- Increment the sample counter
        end loop;
        
        wait for 500 ns;
        
        enable <= '1';
        bit_counter <= 0; -- Reset the counter
        sample_counter <= 0; -- Reset the sample counter
        for i in 0 to 65535 loop
            if sample_counter = 0 then
                audio_in <= std_logic_vector(to_unsigned(i, 16));
            end if;
            wait for clk_period;
            if unsigned(audio_in) >= 2**(16-gain_factor) then
                expected_output <= (others => '1'); -- Maximum value
            else
                expected_output <= std_logic_vector(shift_left(unsigned(audio_in), gain_factor)); -- Use shift_left
            end if;
            -- Compare the audio_out with the expected amplified output
            assert audio_out = expected_output(bit_counter)
                report "Test failed for input " & integer'image(i)
                severity error;
            bit_counter <= (bit_counter + 1) mod 16; -- Increment the counter
            sample_counter <= (sample_counter + 1) mod sample_period; -- Increment the sample counter
        end loop;
        
        wait;
    end process;
end Behavioral;