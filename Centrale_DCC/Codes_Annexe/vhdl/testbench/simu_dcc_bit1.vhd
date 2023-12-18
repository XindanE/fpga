----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 2023/03/21 12:08:39
-- Design Name:
-- Module Name: simu_dcc_bit1 - Behavioral
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
-- Cette testbench est utilis�e pour tester et simuler les comportements de l'entit� DCC_Bit1.

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity simu_dcc_bit1 is
--  Port ( );
end simu_dcc_bit1;

architecture Behavioral of simu_dcc_bit1 is

-- D�claration des signaux qui seront utilis�s pour simuler les entit�s � tester
signal Clk 			: STD_LOGIC := '0';		-- Horloge 100 MHz
signal Reset 		: STD_LOGIC := '0';		-- Reset Asynchrone
signal Clk1M 		: STD_LOGIC := '0';		-- Horloge 1 MHz
signal GO_1         : STD_LOGIC := '0';    -- entr�e de la MAE
signal FIN_1        : STD_LOGIC;   -- sortie vers la MAE
signal DCC_1        : STD_LOGIC;  -- sortie vers la porte OU

begin
    -- Instanciation de l'entit� DCC_Bit1 avec le label l0
    l0: entity work.DCC_Bit1
    port map(
            Clk => Clk,
            Reset => Reset,
            Clk1M => Clk1M,
            GO_1 => GO_1,
            FIN_1 => FIN_1,
            DCC_1 => DCC_1);

    -- G�n�ration des signaux de test
    Clk <= not Clk after 5 ns;          -- G�n�re un signal d'horloge de 100 MHz
    Clk1M <= not Clk1M after  500 ns;   -- G�n�re un signal d'horloge de 1 MHz
    Reset <= '1', '0' after 2 ns;       -- G�n�re un signal de r�initialisation
    GO_1 <= '0', '1' after 100 us, '0' after 700 us, '1' after 1200 us; -- G�n�re un signal de commande pour l'entit� DCC_Bit1


end Behavioral;
