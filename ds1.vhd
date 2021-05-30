-- BIBLIOTECA-------------------------------------------------------
library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
USE ieee.numeric_std.ALL;

---------------ENTIDADE---------------------------------------------------
entity booth is
	Port( mult: in std_logic_vector(4 downto 0);--Multiplicador
    	  multc: in std_logic_vector(4 downto 0);--Multiplicando
          produto: out std_logic_vector(7 downto 0);
          clear,start,clk: in std_logic);--Sinais logicos
end booth;
---------------------ARQUITETURA---------------------------------------------
architecture comp of booth is

  type type_state is(espera,teste,E1,E2,cabo);  
  signal estado, nxt_state : type_state;
  signal A,S: std_logic_vector(4 downto 0); -- A: MULTIPLICANDO, S: NEGATIVO DO MULTIPLICANDO
  signal Af,Sf: std_logic_vector(9 downto 0):= (others=>'0');
  signal P,P_n: std_logic_vector(9 downto 0):= (others=>'0');
  signal count: std_logic_vector(1 downto 0);--CONTADOR ATÉ 100
  signal comparador: std_logic_vector(1 downto 0);
  signal done: std_logic;
----------------SINAIS DEFAULT------------------------------------------------

  begin
     done<= count(1) nor count(0); -- QUANDO O CONTADOR ZERA                
    
 -----------FUNCIONAMENTO SEQUENCIAL DO CLOCK-----------------------------------  
   clock: process(clk,clear)
   begin
      if clear = '1' then
          estado <= espera;
      elsif rising_edge(clk) then --SUBIDA DA BORDA DE CLOCK
           estado <= nxt_state;
      end if;	
      
   end process;
 ---------------MAQUINA DE ESTADOS------------------------------------- 
   FSM: process(estado,start,done)
   begin
   	case estado is
    	when espera =>
        	if start= '1' then
            	nxt_state<= teste;
             else
             	nxt_state<= espera;
             end if;
        when teste =>
        	nxt_state<= E1;
        when E1 =>
        	nxt_state<= E2;
        when E2 =>
        	if done ='1' then
            	nxt_state<= cabo;
            else
            	nxt_state<= teste;
            end if;
        when cabo =>
        	if (start= '0' or done ='0') then
            	nxt_state<= cabo;
            else
            	nxt_state<= espera;
            end if;
     end case;
   end process;
 -------------------BOOTH----------------------------------   
   algoritmo: process(clk)
   begin
   	if rising_edge(clk) then
    	case estado is
        	when espera =>
            	count<= "11"; --CONTADOR INICIAL
                comparador<="00"; --ZERANDO O COMPARADOR
                
                if( start='1' and clear='0') then
                    A(4 downto 0)<= multc; -- Multiplicando 
                    S(4 downto 0)<=  (not multc ) + "00001" ;-- O negativo do multiplicano
                    P(5 downto 1)<= mult; -- Multiplicador 9| 8 7 6 5 4 3 2 1| 0
           
                end if;
               
             when teste =>
             	comparador <= P(1 downto 0);
                
             when E1 =>
             	if comparador = "01" then
         			P_n<=P;
                	P(9 downto 5) <= P( 9 downto 5) + A; -- SOMA
      
                    
                elsif comparador ="10" then
					P_n<=P;
                	P(9 downto 5) <= P( 9 downto 5) + S;  -- SUBTRAÇÃO
                    
                 else
                
                	P<= P;
               
               	end if;
               
             when E2 =>
                 P <= P(9) & P(9 downto 1); --DESLOCAMENTO
                 count <= count - "01"; -- DIMINUTI O CONTADOR
                
             when cabo=>
             	--if (mult= "11000") then
             	--	produto<= -P(8 downto 1) +"00000001";-- 9 |8 7 6 5 4 3 2 1 |0
                --else
                if( mult(4)='1' or multc(4)='1') then
                	produto<= P(8 downto 1) - "00000001";
                else
                	produto<= P(8 downto 1);-- "00000001";
                end if;
                    
        end case;
    end if;
 end process;
    
end comp;
    
        