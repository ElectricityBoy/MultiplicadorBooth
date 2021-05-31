-- Code your testbench here
library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

entity tb is
--ENTIDADE VAZIA
end tb;

architecture multiplica of tb is
	component booth
      port(mult: in std_logic_vector(4 downto 0);--Multiplicador
            multc: in std_logic_vector(4 downto 0);--Multiplicando
            produto: out std_logic_vector(7 downto 0);
            clear,start,clk: in std_logic);--Sinais logicos
    end component;
    
    signal clk: std_logic;
    signal start: std_logic;
    signal clear: std_logic;
    signal mult: std_logic_vector(4 downto 0);
    signal multc : std_logic_vector(4 downto 0);
    signal produto: std_logic_vector(7 downto 0);
    constant PERIOD: time:= 7.5 ns;
    
    begin
    	uut: booth PORT MAP(
        	clk=>clk,
            produto=>produto,
            multc=>multc,
            mult=>mult,
            start=>start,
            clear=>clear
        );
-----------------------       
  	clock : PROCESS
	BEGIN
	
		clk <= '1';
		WAIT FOR PERIOD/2;
		clk <= '0';
		WAIT FOR PERIOD/2;

	END PROCESS;
---------------------------------
    tb: process
    begin
    	clear <='0';
        start <='1';
        multc <= "00010";
        mult <=  "11000";
        wait for 300 ns;
        start<='0';
        clear<='1';
        wait;
    end process;
    
 end;