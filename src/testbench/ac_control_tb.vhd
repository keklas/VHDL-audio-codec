library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ac_control_tb is
end ac_control_tb;

architecture Behavioral of ac_control_tb is
    signal clk : std_logic := '0';
    signal enable : std_logic := '0';
    signal audio_in : std_logic := '0';
    signal amplified_audio_out : std_logic;
    
    constant clk_period : time := 10 ns;

begin
    -- Instantiate the unit under test (UUT)
    uut: entity work.ac_control(Behavioral)
        port map (
            clk => clk,
            enable => enable,
            audio_in => audio_in,
            amplified_audio_out => amplified_audio_out
        );

    -- Clock process
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        enable <= '0';
        for i in 0 to 65535 loop
            for j in 0 to 15 loop
                audio_in <= std_logic(to_unsigned(i, 16)(j));
                wait for clk_period;
                assert audio_in = amplified_audio_out
                    report "Test failed for input " & integer'image(i)
                    severity error;
            end loop;
        end loop;
        
        enable <= '1';
        for i in 0 to 65535 loop
            for j in 0 to 15 loop
                audio_in <= std_logic(to_unsigned(i, 16)(j));
                wait for clk_period;
                assert audio_in = amplified_audio_out
                    report "Test failed for input " & integer'image(i)
                    severity error;
            end loop;
        end loop;
        
        wait;
    end process;
end Behavioral;