----------------------------------------------------------------------------------
-- Engineer: Filip Rydzewski (Wanils)
-- Create Date: 09.08.2021 14:05:40
-- Design Name: Counter_10m
-- Module Name: Counter_10m_TOP - rtl
-- Target Devices: Basys3 Board
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Counter_10m_TOP is
    Port ( 
	clk 	: in std_logic;
	rst 	: in std_logic;
	Stp 	: in std_logic;
	Switch  : in std_logic;
	display : out std_logic_vector (6 downto 0);
    enable  : out std_logic_vector (3 downto 0));
end Counter_10m_TOP;


architecture rtl of Counter_10m_TOP is

	type t_State is (StopCount,CountUp,CountDown);
	signal State 		 : t_State;
	signal counter		 : integer := 0;
	signal refresh_cnt   : integer := 0;
	constant maxcount	 : integer := 10000000; -- 10 Hz
	constant refresh_max : integer := 200000; -- 500 Hz
	-- Button registers
	signal Stp_reg 		 : std_logic := '0';
	signal Stp_reg2 	 : std_logic := '0';
	signal Switch_reg    : std_logic;
	-- Flag informing whether counting has been stopped
	signal stopped 		 : boolean := true;
	-- Counters
	signal Milisec		 : integer;
	signal Sec0		     : integer;
	signal Sec1		     : integer;
	signal Min		     : integer;
	-- Counters: logic type
	signal Milisec_l	 : std_logic_vector(3 downto 0);
	signal Sec0_l		 : std_logic_vector(3 downto 0);
	signal Sec1_l		 : std_logic_vector(3 downto 0);
	signal Min_l		 : std_logic_vector(3 downto 0);
	-- Signals for 7-SEG DISPLAY
	signal Seg_0, Seg_1, Seg_2, Seg_3 : std_logic_vector (6 downto 0);
	signal toggle		              : std_logic_vector(3 downto 0) := "1110";

	component hex2seg
        Port ( 
		hex : in std_logic_vector(3 downto 0);
		seg : out std_logic_vector(6 downto 0));
    end component;
	
	component Debounce
		port (
		clk 		: in std_logic;
		button_in	: in std_logic;
		button_out	: out std_logic);
	end component;

	-- Increment procedure
	procedure Increment(
		signal   Counter_pr     : inout integer;
        	constant MaxValue   : in    integer;
        	variable Wrapped    : out   boolean) is
    	begin
            if Counter_pr = MaxValue - 1 then
                Wrapped := true;
                Counter_pr <= 0;
            else
                Wrapped := false;
                Counter_pr <= Counter_pr + 1;
            end if;
    end procedure;
	
	-- Decrement procedure
	procedure Decrement(
		signal   Counter_pr     : inout integer;
        	constant MaxValue   : in    integer;
        	variable Wrapped    : out   boolean) is
    	begin
            if Counter_pr = 0 then
                Wrapped := true;
                Counter_pr <= MaxValue - 1;
            else
                Wrapped := false;
                Counter_pr <= Counter_pr - 1;
            end if;
    end procedure;
	
begin
	-- OUTPUT assignments
	Milisec_l	<= std_logic_vector(to_unsigned(Milisec,4));
	Sec0_l		<= std_logic_vector(to_unsigned(Sec0,4));		
	Sec1_l		<= std_logic_vector(to_unsigned(Sec1,4));		
	Min_l		<= std_logic_vector(to_unsigned(Min,4));
	enable 		<= toggle;

	-- hex2seg components instantiations
	seg3 : hex2seg
       	port map(Min_l,Seg_3);
    seg2 : hex2seg
        port map(Sec1_l,Seg_2);
    seg1 : hex2seg
        port map(Sec0_l,Seg_1);
    seg0 : hex2seg
        port map(Milisec_l,Seg_0);

	-- Debounce instantiations
	deb_stp    : Debounce
		port map(clk,Stp,Stp_reg2);
	deb_switch : Debounce
		port map(clk,Switch,Switch_reg);

	
	-- Process for stp button => detecting rising edges only
	button_press: process(clk)
	variable clicked : boolean := false;
	begin
		if rising_edge(clk) then
			Stp_reg <= Stp_reg2;
			if Stp_reg2 = '1' and Stp_reg = '0' and not clicked then
				clicked := true;
			elsif (Stp_reg2 = '0') then
				clicked := false;
			elsif (clicked) then
				Stp_reg <= '0';
			end if;
		end if;
	end process button_press;


	-- Counter process	
	counter_proc: process(clk)
	variable Wrap : boolean;
    	begin
        if(rising_edge(clk)) then
            if(rst = '1') then
                counter <= 0;
		        Milisec <= 0;
		        Sec0 	<= 0;
		        Sec1 	<= 0;
		        Min 	<= 0;
            else
		case State is
			when StopCount =>
				-- Do nothing
			when CountUp =>
				Increment(counter,maxcount,Wrap);
				if(Wrap) then
					Increment(Milisec,10,Wrap);
					if(Wrap) then
						Increment(Sec0,10,Wrap);
						if(Wrap) then
							Increment(Sec1,6,Wrap);
							if(Wrap) then
								Increment(Min,10,Wrap);
							end if;
						end if;
					end if;
				end if;
			when CountDown =>
				Increment(counter,maxcount,Wrap);
				if(Wrap) then
					Decrement(
						Milisec,10,Wrap);
					if(Wrap) then
						Decrement(
							Sec0,10,Wrap);
						if(Wrap) then
							Decrement(
								Sec1,6,Wrap);
							if(Wrap) then
								Decrement(
									Min,10,Wrap);
							end if;
						end if;
					end if;
				end if;
			end case;
		end if;
	end if;
    end process counter_proc;
	
	-- Changing states process
	state_change: process(clk)
	begin
		if(rising_edge(clk)) then
			if(rst='1') then
				State <= StopCount;
			else
				if(stopped) then
					State <= StopCount;
					if(Stp_reg = '1') then
						stopped <= not stopped;
					end if;
				else
					if(Stp_reg = '1') then
						stopped <= not stopped;
					end if;
					if(Switch_reg = '1') then
						State <= CountUp;
					elsif(Switch_reg = '0') then
						State <= CountDown;
					else
						State <= StopCount;
					end if;
				end if;
			end if;
		end if;
	end process state_change;

 	-- HEX 7 - SEGMENT DISPLAY processes
	refresh_counter: process(clk)
	begin
		if(rising_edge(clk)) then
			if(refresh_cnt = refresh_max - 1) then
				refresh_cnt <= 0;
			else 
				refresh_cnt <= refresh_cnt + 1;
			end if;
		end if;
	end process refresh_counter;

	toggle_count_proc: process(clk)
	begin
		if(rising_edge(clk)) then
			if(rst = '1') then
				toggle <= toggle;
			elsif(refresh_cnt = refresh_max - 1) then
				toggle <=  toggle(2 downto 0) & toggle(3);
			end if;
		end if;
	end process toggle_count_proc;
		
		
	toggle_proc: process(toggle,Seg_0,Seg_1,Seg_2,Seg_3)
	begin
			if(toggle(0) = '0') then
				display <= Seg_0;
			elsif(toggle(1) = '0') then
				display <= Seg_1;
			elsif(toggle(2) = '0') then
				display <= Seg_2;
			elsif(toggle(3) = '0') then
				display <= Seg_3;
			else
				display <= (others => '0');
			end if;
	end process toggle_proc;

end rtl;

