LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY testbench IS
END testbench;

ARCHITECTURE behavior OF testbench IS 

	COMPONENT booth_mult
		Generic(
		W : integer  := 4					
	);
	PORT(
		clk : IN std_logic;
		start : IN std_logic;
		n_reset : IN std_logic;
		mcand : IN std_logic_vector(3 downto 0);
		mplier : IN std_logic_vector(3 downto 0);          
		done : OUT std_logic;
		product : OUT std_logic_vector(7 downto 0)
		);
	END COMPONENT;

	SIGNAL clk :  std_logic;
	SIGNAL start :  std_logic;
	SIGNAL n_reset :  std_logic;
	SIGNAL mcand :  std_logic_vector(3 downto 0);
	SIGNAL mplier :  std_logic_vector(3 downto 0);
	SIGNAL done :  std_logic;
	SIGNAL product :  std_logic_vector(7 downto 0);
	constant PERIOD : time := 25 ns;
	type dados is array ( integer range 0 to 14) of std_logic_vector( 3 downto 0);
BEGIN

  --ESTABELECENDO OS SINAIS DO BOOTH_MULT
	uut: booth_mult PORT MAP(
		clk => clk,
		start => start,
		n_reset => n_reset,
		mcand => mcand,
		mplier => mplier,
		done => done,
		product => product
	);


    --FUNCIONAMENTO DO CLOCK
	clock : PROCESS
	BEGIN
	
		clk <= '1';
		WAIT FOR PERIOD/2;
		clk <= '0';
		WAIT FOR PERIOD/2;

	END PROCESS;


   tb : PROCESS
   variable amostras: dados;
   BEGIN
   
   		amostras := ("0001","0010",,"0011","0100","0101","0110","0111","1000","1001","1010","1011","1100","1101","1110","1111"); --VETOR COM TODAS AS POSSIBILIDADES
		start <= '0';		
		n_reset <= '0';
		
        for i in 0 to 14 loop
        		WAIT FOR 40 NS;
                n_reset <= '1';
            	mplier<= amostras(i);
                mcand<= amostras(i);
                start <= '1';		
                WAIT FOR 20 NS;
                start <= '0';
                WAIT FOR 40 NS;
                
            end loop;	
      wait;
   END PROCESS;

END;