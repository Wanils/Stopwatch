----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 09.08.2021 14:05:40
-- Design Name: Counter_10m
-- Module Name: Debounce - rtl
-- Target Devices: Basys3 Board
-- Notes: Module based on the one created by Nandaland
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Debounce is
    port (
        clk 		: in std_logic;
        button_in	: in std_logic;
        button_out	: out std_logic);
end Debounce;

architecture rtl of Debounce is
	constant DEBOUNCE_MAX : integer := 10e5; -- 1000000 clocks ticks -> 10 ms
	signal Count          : integer range 0 to DEBOUNCE_MAX := 0;
	signal button_State   : std_logic := '0';
   
begin

p_Debounce : process (clk) is
begin
	if rising_edge(clk) then
      	if (button_in /= button_State and Count < DEBOUNCE_MAX) then
        	Count <= Count + 1;
      	elsif Count = DEBOUNCE_MAX then
        	button_State <= button_in;
        	Count <= 0;
      	else
        	Count <= 0;
      	end if;
    end if;
  end process p_Debounce;
 
  button_out <= button_State;
 
end rtl;
