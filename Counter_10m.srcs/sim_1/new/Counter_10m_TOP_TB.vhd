----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 09.08.2021 14:05:40
-- Design Name: Counter_10m
-- Module Name: Counter_10m_TOP_TB - sim
-- Target Devices: Basys3 Board
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Counter_10m_TOP_TB is
end Counter_10m_TOP_TB;

architecture sim of Counter_10m_TOP_TB is
	constant ClockFrequencyHz : integer := 100000000; -- 100 MHz
    constant ClockPeriod      : time := 1000 ms / ClockFrequencyHz;
	constant maxcount	      : integer := 10000000;
	signal clk 		          : std_logic := '1';
	signal rst 		          : std_logic := '1';
	signal stp      	      : std_logic := '0';
	signal Switch   	      : std_logic := '1';
	signal display  	      : std_logic_vector (6 downto 0);
    signal enable   	      : std_logic_vector (3 downto 0);
	
begin
	 
	 UUT : entity work.Counter_10m_TOP(rtl)
	 port map(
		clk 	=> clk,
		rst 	=> rst,
		stp	    => stp,
		Switch  => Switch,
		display => display,
		enable  => enable);
		
	clk <= not clk after ClockPeriod / 2;

	process is
	begin
        wait until rising_edge(clk);
       	wait until rising_edge(clk);
        rst <= '0';
		wait until rising_edge(clk);
		stp <= '1';
		wait for 15 ms;
		stp <= '0';
        wait;
    end process;
   
end sim;
