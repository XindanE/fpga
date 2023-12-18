----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 2023/04/04 10:41:01
-- Design Name:
-- Module Name: TOP - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP is
 Port
  (
    Interrupteur	: in STD_LOGIC_VECTOR(7 downto 0); -- Interrupteur de la carte
    Reset 	: in STD_LOGIC;                            -- Reset asynchrone
    Clk_In 	: in STD_LOGIC;                            -- Horloge 100 Mhz
    Sortie_DCC  :out std_logic                         -- Sortie Dcc vers les trains
  );
end TOP;

architecture Behavioral of TOP is

-----------------------------------Déclaration des signaux---------------------------------
signal  Clk_Out : STD_LOGIC;
signal  Trame_DCC : STD_LOGIC_VECTOR(50 downto 0);
signal  Start_Tempo	: STD_LOGIC;
signal  Fin_Tempo	: STD_LOGIC;
signal  GO_1 : STD_LOGIC;
signal  FIN_1 : STD_LOGIC;
signal  DCC_1 : STD_LOGIC;
signal  GO_0 : STD_LOGIC;
signal  FIN_0 : STD_LOGIC;
signal  DCC_0 : STD_LOGIC;
signal  load : std_logic;
signal  shift : std_logic;
signal  trame : std_logic;
signal  reg_data : std_logic;


begin

-------------Diviseur d'horloge 100 Mhz à 1 Mhz---------------
horloge :   entity work.CLK_DIV PORT MAP(
             Reset      =>  Reset,
             Clk_In     =>  Clk_In,
             Clk_Out    =>  Clk_Out
            );
---------------------Générateur de trames---------------------
generator: entity work.DCC_FRAME_GENERATOR PORT MAP(
           Interrupteur	 =>     Interrupteur,	-- Interrupteurs de la Carte
           Trame_DCC 	 =>     Trame_DCC
           );
--------------------Compteur de temporisation-----------------
tempo :     entity work.COMPTEUR_TEMPO PORT MAP(
            Clk 		=>    Clk_In,
            Reset 		=>    Reset,
            Clk1M 		=>    Clk_Out,
            Start_Tempo	=>    Start_Tempo,
            Fin_Tempo	=>    Fin_Tempo
		    );
------------------Générateur de bit à '1' DCC_1---------------
dcc1 :      entity work.DCC_Bit1 PORT MAP (
            Clk 		=>    Clk_In,		-- Horloge 100 MHz
            Reset 		=>    Reset,		-- Reset Asynchrone
            Clk1M 		=>    Clk_Out,	-- Horloge 1 MHz
            GO_1        =>    GO_1, -- entr¨¦e du MAE
            FIN_1       =>    FIN_1,    -- sortie vers MAE
            DCC_1       =>    DCC_1
            );
------------------Générateur de bit à '0' DCC_0---------------
dcc0 :      entity work.DCC_Bit0 PORT MAP (
            Clk 		=>    Clk_In,		-- Horloge 100 MHz
            Reset 		=>    Reset,		-- Reset Asynchrone
            Clk1M 		=>    Clk_Out,	-- Horloge 1 MHz
            GO_0        =>    GO_0, -- entr¨¦e du MAE
            FIN_0       =>    FIN_0,    -- sortie vers MAE
            DCC_0       =>    DCC_0
            );
------------------Porte OU ------------------------
OU :    entity work.Porte_OU PORT MAP(
        CLK_1M         =>     CLK_Out,
        RESET          =>     RESET,
        DCCo_1         =>     DCC_1,
        DCCo_0         =>     DCC_0,
        Sortie_DCC     =>     Sortie_DCC
        );

------------------Registre à décalage-----------------
registre : entity work.Registre_DCC PORT MAP(
            clk          =>     Clk_In,
            reset        =>     reset,
            load         =>     load,
            shift        =>     shift,
            data_in      =>     Trame_DCC,
            START_TEMPO  =>     START_TEMPO,
            trame        =>     trame,
            bit_out      =>     reg_data
    );

------------------Machine à état globale---------------
MAE :   entity work.FSM PORT MAP(
        clk          =>     Clk_In,
        reset        =>     reset,
        data         =>     reg_data,
        FIN_TEMPO    =>     FIN_TEMPO,
        FIN_0        =>     FIN_0,
        FIN_1        =>     FIN_1,
        trame        =>     trame,

        START_TEMPO  =>     START_TEMPO,
        GO_0         =>     GO_0,
        GO_1         =>     GO_1,
        load         =>     load,
        shift        =>     shift
);

end Behavioral;
