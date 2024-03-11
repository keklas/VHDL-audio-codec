library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_tb is
end top_tb;

architecture arch of top_tb is

	component top is
		Port (
	        sysclk : in STD_LOGIC;
	        btn: in std_logic_vector(3 downto 0);
	        sw: in std_logic_vector(3 downto 0);
	        led : out std_logic_vector(3 downto 0);
	        led6_r: out std_logic
	    );
	end component;

	constant cc: time := 4ns;

	signal s_clk, s_led6_r: std_logic := '0';
	signal s_btn, s_sw, s_led : std_logic_vector(3 downto 0) := (others => '0');

begin
	clkGen: process
	begin
		s_clk <= not s_clk;
		wait for cc;
	end process;

	uut: top port map(
		sysclk => s_clk,
		btn => s_btn,
		sw => s_sw,
		led => s_led,
		led6_r => s_led6_r);

	tgen: process
	begin
		wait for 2*cc;
			s_sw <= "0000";
			s_btn <= "0000";

		wait for 2*cc;
			s_sw <= "0001";
			s_btn <= "0000";

		wait for 2*cc;
	        s_sw <= "0001";
        	s_btn <= "0001";

		wait for 2*cc;
	        s_sw <= "1111";
	        s_btn <= "0000";

		wait for 2*cc;
	        s_sw <= "1111";
	        s_btn <= "0001";

		wait for 2*cc;
	        s_sw <= "1111";
	        s_btn <= "1111";

		wait;
	end process;

end arch;
