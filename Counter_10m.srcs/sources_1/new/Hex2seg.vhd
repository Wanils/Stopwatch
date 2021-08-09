----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 09.08.2021 14:05:40
-- Design Name: Counter_10m
-- Module Name: Hex2seg - rtl
-- Target Devices: Basys3 Board
-- Notes: Module based on the one created by Jordan Christman
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Hex2seg is
    Port(
    hex : in std_logic_vector(3 downto 0);
    seg : out std_logic_vector(6 downto 0));
end Hex2seg;

architecture rtl of hex2seg is
    signal seg_out : std_logic_vector(6 downto 0);
    
begin
    seg <= not seg_out;

	-- 7 segment display Mapping
--
--			   0
--			 -----
--			|     |
--		  5 |     | 1
--			|  6  |
--			 -----
--			|     |
--		  4 |     | 2
--			|     |
--			 -----
--			   3
--
--			   A
--			 -----
--			|     |
--		  F |     | B
--			|  G  |
--			 -----
--			|     |
--		  E |     | C
--			|     |
--			 -----
--			   D
-------------------------------------------------------------------------------	

    seg_proc : process(hex)
    begin
        case hex is
            when x"0" => seg_out <= "0111111"; -- 0
            when x"1" => seg_out <= "0000110"; -- 1
            when x"2" => seg_out <= "1011011"; -- 2
            when x"3" => seg_out <= "1001111"; -- 3
            when x"4" => seg_out <= "1100110"; -- 4
            when x"5" => seg_out <= "1101101"; -- 5
            when x"6" => seg_out <= "1111101"; -- 6
            when x"7" => seg_out <= "0000111"; -- 7
            when x"8" => seg_out <= "1111111"; -- 8
            when x"9" => seg_out <= "1101111"; -- 9
            when x"A" => seg_out <= "1110111"; -- A
            when x"B" => seg_out <= "1111100"; -- B
            when x"C" => seg_out <= "0111001"; -- C
            when x"D" => seg_out <= "1011110"; -- D
            when x"E" => seg_out <= "1111001"; -- E
            when x"F" => seg_out <= "1110001"; -- F
            when others => seg_out <= (others => 'X');
        end case;
    end process seg_proc;
end rtl;

