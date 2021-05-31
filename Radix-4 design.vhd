-- ELDER PEREIRA
-- 2 AVALIAÇÃO ELETRONICA DIGITAL

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;

--ARQUITETURA
entity booth_mult is
	Generic(
		W : integer  := 4); -- ESPECIFICANDO A QUANTIDADE DE BITS 
  port(
    clk				: in std_logic;
    start			: in std_logic;
    n_reset	: in std_logic;
    mcand		: in std_logic_vector(W-1 downto 0);
    mplier		: in std_logic_vector(W-1 downto 0);
    done 		: out std_logic;
	product	: out std_logic_vector(2*W-1 downto 0)
	);
end booth_mult;

architecture arch of booth_mult is
	type state_type is(IDLE, BUSY);
	attribute ENUM_ENCODING	: string;				--						
	attribute ENUM_ENCODING of state_type: type is "01 10"; -- ATRIBUINDO VALORES AS ESTADOS
	signal state_reg, state_next: state_type;
	signal q_reg, q_next: unsigned(6 downto 0);
	signal mcand_reg: std_logic_vector(W-1 downto 0);--REGISTRADOR PARA O MULTIPLICANDO				
	signal prod_reg, prod_next: std_logic_vector(2*W downto 0);
	signal result_reg, result_next: std_logic_vector(2*W downto 0);  -- GUARDA O RESULTADO ANTES DO DESLOCAMENTO			
	signal q_add, q_reset: std_logic;
	
begin
	sync_update :
	process(clk, n_reset)						
	begin -- LOGICA SEQUENCIAL DO CLOCK
		if rising_edge(clk) then
			if n_reset = '0' then
				state_reg <= IDLE;
				q_reg <= (others => '0');
				prod_reg <= (others => '0');
			else
				q_reg <= q_next;
				state_reg <= state_next;
				prod_reg <= prod_next(2*W) & prod_next(2*W downto 1);  
				result_reg <= prod_next;
			end if;	
		end if;
	end process;
		
	control_logic :	
	process(state_reg, q_reg, result_reg, start, prod_reg, mplier, mcand )					
		begin
			
			q_add <= '0';
			q_reset <= '0';
			done <= '0';
			state_next <= state_reg  ;
			prod_next <= prod_reg ;
			result_next <= result_reg;	
			case state_reg is
				when IDLE => 
					if (start = '1') then   
						mcand_reg <= mcand; --CARREGAMENTO
						prod_next(2*W downto W+1) <= (others => '0');  -- PREENCHE O PROD_NEXT REG COM ZEROS
						prod_next(W downto 1) <= mplier;
						prod_next(0) <= '0';
						state_next <= BUSY;
					end if;
					
				when BUSY =>
					q_add <= '1';
					if (q_reg = '0' & conv_unsigned(W, 7)(6 downto 1)  and start /= '1') then  -- DEPOIS DE W/2 CICLOS DE CLOCK A MULTIPLICAÇÃO ESTÁ FEITA
						product <= prod_next(2*W) & prod_next(2*W  downto 2);
						done <= '1' ;
						q_add <= '0';
						q_reset <= '1';
						state_next <= IDLE;
					end if;
					
					-- DECODIFICADOR BOOTH E OPERAÇÕES
					case result_reg(2 downto 0) is     
						when "001" | "010" => 	-- ADIÇÃO MCAND
							prod_next <= ((prod_reg(2*W) & prod_reg(2*W downto W+1)) + (mcand_reg(W - 1) & mcand_reg)) & prod_reg(W downto 1);
						when "011" => 			--ADIÇÃO 2*MCAND		
							prod_next <= ((prod_reg(2*W) & prod_reg(2*W downto W+1)) + (mcand_reg & '0' )) & prod_reg(W downto 1);
						when "100" => 			--SUBTRAÇÃO 2*MCAND
							prod_next <= ((prod_reg(2*W) & prod_reg(2*W downto W+1)) - (mcand_reg & '0' )) & prod_reg(W downto 1);
						when "101" | "110" => 	--SUBTRAÇÃO MCAND
							prod_next <= ((prod_reg(2*W) & prod_reg(2*W downto W+1)) - (mcand_reg(W - 1) & mcand_reg)) & prod_reg(W downto 1); 
						when others => 				-- DESLOCAMENTO
							prod_next <= prod_reg(2*W) & prod_reg(2*W downto 1);
					end case;
	

				end case;

	end process;
	
	
	--TIMER/COUNTER
    q_next <= (others => '0') when q_reset = '1' else  -- RESETA q_next SE q_reset for igual a 1     	
			        q_reg + 1 when q_add = '1' else    -- INCREMENTA 1 EM q_reg se q_add  FOR IGUAL A 1     					
			        q_reg;   
					

end arch;				