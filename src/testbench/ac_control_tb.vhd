library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ac_control_tb is
end ac_control_tb;

architecture Behavioral of ac_control_tb is
    signal clk : std_logic := '0';
    signal enable : std_logic := '0';
    signal audio_in : std_logic_vector(15 downto 0) := (others => '0');
    signal amplified_audio_out : std_logic_vector(15 downto 0);

    -- Instantiate the Unit Under Test (UUT)
    component ac_control is
        Port ( clk : in STD_LOGIC;
               enable : in STD_LOGIC;
               audio_in : in STD_LOGIC_VECTOR(15 downto 0);
               amplified_audio_out : out STD_LOGIC_VECTOR(15 downto 0)
             );
    end component;

begin
    UUT: ac_control Port Map (
        clk => clk,
        enable => enable,
        audio_in => audio_in,
        amplified_audio_out => amplified_audio_out
    );

    clk_process :process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    stim_proc: process
    begin
        -- hold reset state for 100 ns.
        wait for 100 ns;  

        enable <= '1'; -- enable the audio processor
        audio_in <= "0110011001100110"; -- provide some audio input
        wait for 100 ns;

        enable <= '0'; -- disable the audio processor
        wait for 100 ns;

        enable <= '1'; -- enable the audio processor
        audio_in <= "1001100110011001"; -- provide some audio input
        wait for 100 ns;

        enable <= '0'; -- disable the audio processor
        wait for 100 ns;

        enable <= '1'; -- enable the audio processor
        audio_in <= "1100110011001100"; -- provide some audio input
        wait for 100 ns;

        enable <= '0'; -- disable the audio processor
        wait for 100 ns;

        wait;
    end process;

end Behavioral;