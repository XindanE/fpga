----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 2023/03/28 00:00:14
-- Design Name:
-- Module Name: simu_registre - Behavioral
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity Registre_DCC_tb is
end entity Registre_DCC_tb;

architecture sim of Registre_DCC_tb is
-- Déclaration des signaux qui seront utilisés pour simuler l'entité à tester.--

    signal clk          : std_logic := '0';-- Horloge de simulation
    signal reset        : std_logic := '0';-- Signal de réinitialisation
    signal load         : std_logic := '0';-- Signal de chargement des données
    signal shift        : std_logic := '0';-- Signal de décalage des données
    signal data_in      : std_logic_vector(50 downto 0) := (others => '0');
    signal trame        : std_logic := '0';-- Signal trame de sortie pour la MAE
    signal bit_out      : std_logic;-- Signal de la donnée de sortie pour la MAE

------- Décalartion du composant à Tester Registre_DCC----------

    component Registre_DCC is
        port (
            clk          : in  std_logic;
            reset        : in  std_logic;
            load         : in  std_logic;
            shift        : in  std_logic;
            data_in      : in  std_logic_vector(50 downto 0);
            trame        : out std_logic;
            bit_out      : out std_logic
        );
    end component Registre_DCC;

begin
-- Instanciation de l'entité Registre_DCC avec le label uut
    uut: Registre_DCC
        port map (
            clk          => clk,
            reset        => reset,
            load         => load,
            shift        => shift,
            data_in      => data_in,
            trame        => trame,
            bit_out      => bit_out
        );

     -- Génération de l'horloge et du signal de réinitialisation
     Clk <= not Clk after 5 ns;
     Reset <= '1', '0' after 2 ns;

        -- Chargement des données dans le registre
        data_in <= "111" & x"FFF0F6E001BE",  "000"& x"000000000000" after 580 ns;
        load <= '1', '0'after 20 ns;
        shift <= '1',  '0'after 550 ns;
        -- Assert pour mettre fin à la simulation
        assert false
            report "End of simulation"
            severity note;

end architecture sim;
