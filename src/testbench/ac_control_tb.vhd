library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ac_control_tb is
end ac_control_tb;

architecture Behavioral of ac_control_tb is
    constant gain_factor : integer := 1;
    signal clk : std_logic := '0';
    signal enable : std_logic := '0';
    signal audio_in : signed(15 downto 0) := (others => '0');
    signal audio_out : std_logic;
    signal expected_output : std_logic;
    signal bit_counter : integer range 0 to 15 := 15;
    
    constant clk_period : time := 10 ns;
    constant sample_period : integer := 16;
    signal sample_counter : integer range 0 to sample_period-1 := 0;

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
        for i in -32768 to 32767 loop
            if sample_counter = 0 then
                audio_in <= to_signed(i, 16);
            end if;
            wait for clk_period;
            assert audio_in(bit_counter) = audio_out
                report "Test failed for input " & integer'image(i)
                severity error;
            if bit_counter = 0 then
                bit_counter <= 15;
            else
                bit_counter <= bit_counter - 1;
            end if;
            sample_counter <= (sample_counter + 1) mod sample_period;
        end loop;
        
        wait for 500 ns;
        
        enable <= '1';
        bit_counter <= 15;
        sample_counter <= 0;
        for i in -32768 to 32767 loop
            if sample_counter = 0 then
                audio_in <= to_signed(i, 16);
            end if;
            wait for clk_period;
            if (audio_in >= 0 and audio_in * gain_factor < audio_in) or (audio_in < 0 and audio_in * gain_factor > audio_in) then
                if audio_in >= 0 then
                    expected_output <= '0';
                else
                    expected_output <= '1';
                end if;
            else
                expected_output <= std_logic(audio_in(bit_counter));
            end if;
            
            assert audio_out = expected_output
                report "Test failed for input " & integer'image(i)
                severity error;
            if bit_counter = 0 then
                bit_counter <= 15;
            else
                bit_counter <= bit_counter - 1;
            end if;
            sample_counter <= (sample_counter + 1) mod sample_period;
        end loop;
        
        wait;
    end process;
end Behavioral;