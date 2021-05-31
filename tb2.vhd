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
    constant PERIOD: time:= 7.5 ns; --PERIODO PARA O CLOCK
    type dados is array ( integer range 0 to 14) of std_logic_vector( 4 downto 0); -- CRIANDO UM VETOR DE 15 ELEMENTOS, CADA UM COM TAMANHO DE 5 BITS
---------------DETERMINANDO OS SINAIS ATRAVES DO PORT MAP----   
    begin
    	uut: booth PORT MAP(
        	clk=>clk,
            produto=>produto,
            multc=>multc,
            mult=>mult,
            start=>start,
            clear=>clear
        );
----------PROCESSO DO CLOCK-----------       
  	clock : PROCESS
	BEGIN
	
		clk <= '1';
		WAIT FOR PERIOD/2;
		clk <= '0';
		WAIT FOR PERIOD/2;

	END PROCESS;
---------------------------------
    tb: process
    variable amostras: dados;
    
    begin
    	amostras := ("00001","00010","00011","00100","00101","00110","00111","11000","11001","11010","11011","11100","11101","11110","11111"); --VETOR COM TODAS AS --POSSIBILIDADES

       for i in 0 to 14 loop
           for u in 0 to 14 loop
           	   wait for 200 ns;
               clear<='1','0' after PERIOD;
               start<='0','1' after PERIOD;
               multc <= amostras(u);
               mult <=  amostras(i);
               wait for 300 ns;
               clear<='0','1' after PERIOD;
               start<='1','0' after PERIOD;
               if (produto /= multc*mult) then
                      report "Erro na multiplicação" severity warning;
               end if;
          end loop;
       end loop;
     wait;
    end process;
  end;
        