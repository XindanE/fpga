----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 2023/04/04 11:47:56
-- Design Name:
-- Module Name: simu_top - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- Cette testbench sert à tester l'entité TOP
entity simu_top is
end simu_top;

architecture Behavioral of simu_top is

-------Déclaration des signaux qui seront utilisés pour simuler l'entité à tester--------
signal    Interrupteur	: STD_LOGIC_VECTOR(7 downto 0) := x"00"; -- Entrée Interrupteur pour l'entité TOP
signal    Reset 	: STD_LOGIC := '0'; -- Reset Asynchrone
signal    Clk_In 	: STD_LOGIC := '0'; -- Horloge 100 MHz
signal    Sortie_DCC  : std_logic;      -- Sortie DCC

begin
    uut: entity work.TOP port map(
        Interrupteur    => Interrupteur,
        Reset           => Reset,
        Clk_In          => Clk_In,
        Sortie_DCC      => Sortie_DCC
    );

    -- Génération des signaux de test--
    Clk_In <= not Clk_In after 5 ns; -- Génère un signal d'horloge de 100 MHz
    Reset <= '1', '0' after 10 ns;   -- Génère un signal de réinitialisation
    Interrupteur <= x"00", x"01" after 20 ms, x"04" after 40 ms;-- Changer l'état de l'interrupteur pour simuler les différentes fonctions



end Behavioral;
