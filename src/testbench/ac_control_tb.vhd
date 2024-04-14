library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ac_control_tb is
end ac_control_tb;

architecture Behavioral of ac_control_tb is
    component ac_control
    Port (
        clk : in STD_LOGIC;
        enable : in STD_LOGIC;
        audio_in : in STD_LOGIC_VECTOR(15 downto 0);
        amplified_audio_out : out STD_LOGIC_VECTOR(15 downto 0)
    );
    end component;

    -- Inputs
    signal clk : STD_LOGIC := '0';
    signal enable : STD_LOGIC := '0';
    signal audio_in : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    -- Outputs
    signal amplified_audio_out : STD_LOGIC_VECTOR(15 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;
    
    -- Define a constant for the maximum value
    constant max_value : std_logic_vector(15 downto 0) := (others => '1');

begin
    uut: ac_control Port Map (
        clk => clk,
        enable => enable,
        audio_in => audio_in,
        amplified_audio_out => amplified_audio_out
    );

    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    stim_proc: process -- In Vivado run the sim for 14ms so that both test-loops are finished
    begin
        wait for 100 ns;  

        -- Test all possible states with enable = 1
        for i in 0 to 2**16-1 loop
            enable <= '1';
            audio_in <= std_logic_vector(to_unsigned(i, 16));
            wait for clk_period*10;

            if unsigned(audio_in) >= 2**(16-1) then
                assert (amplified_audio_out = max_value) report "Test failed: output does not match expected value" severity error;
            else
                assert (amplified_audio_out = std_logic_vector(shift_left(unsigned(audio_in), 1))) report "Test failed: output does not match expected value" severity error;
            end if;
        end loop;

        report "All tests with enable=1 passed successfully";

        -- Test all possible states with enable = 0
        for i in 0 to 2**16-1 loop
            enable <= '0';
            audio_in <= std_logic_vector(to_unsigned(i, 16));
            wait for clk_period*10;

            assert (amplified_audio_out = audio_in) report "Test failed: output does not match expected value" severity error;
        end loop;

report "All tests with enable=0 passed successfully";

        wait;
    end process;

end Behavioral;