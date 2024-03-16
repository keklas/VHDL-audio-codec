library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_tb is
end entity;

architecture Behavioral of top_tb is

signal s_btn: std_logic_vector(3 downto 0) := (others => '0');
signal s_sw: std_logic_vector(3 downto 0) := (others => '0');
signal s_r_led : std_logic;
         
signal s_sysclk, s_ac_bclk, s_ac_mclk, s_ac_muten, s_ac_pbdat, s_ac_pblrc, s_ac_recdat, s_ac_reclrc, s_ac_scl, s_ac_sda : std_logic := 'Z';   

begin

uut: entity work.top port map(
    btn => s_btn,
    sw => s_sw,
    led6_r => s_r_led,
    sysclk => s_sysclk,
    ac_bclk => s_ac_bclk,
    ac_mclk => s_ac_mclk,
    ac_muten => s_ac_muten,
    ac_pbdat => s_ac_pbdat,
    ac_pblrc => s_ac_pblrc,
    ac_recdat => s_ac_recdat,
    ac_reclrc => s_ac_reclrc,
    ac_scl => s_ac_scl,
    ac_sda => s_ac_sda
    );

s_ac_scl <= 'H';
s_ac_sda <= 'H';

s_sw(0) <= '1';

clkGen: process begin
    s_sysclk <= '0';
    wait for 4ns;
    s_sysclk <= '1';
    wait for 4ns;
end process;

rstGen: process begin
    s_btn(0) <= '1';
    wait for 10ns;
    s_btn(0) <= '0';
    wait;
end process;


end Behavioral;