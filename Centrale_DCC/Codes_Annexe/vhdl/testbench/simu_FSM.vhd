----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 2023/03/28 09:52:18
-- Design Name:
-- Module Name: simu_FSM - Behavioral
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

-- Testbench pour la Macchine à état
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity simu_FSM is
--  Port ( );
end simu_FSM;

architecture Behavioral of simu_FSM is

------------ Déclaration des signaux de test-------------
    signal clk       : std_logic := '0';         -- Horloge de simulation
    signal reset     : std_logic := '0';         -- Signal de réinitialisation
    signal data      : std_logic ;               -- Signal de données d'entrée
    signal FIN_TEMPO : std_logic := '0';         -- Signal indiquant la fin de la temporisation
    signal FIN_0     : std_logic := '0';         -- Signal indiquant la fin de la transmission du bit '0'
    signal FIN_1     : std_logic := '0';         -- Signal indiquant la fin de la transmission du bit '1'
    signal trame     : std_logic := '0';         -- Signal trame d'entrée

    -- Signaux de sortie de l'entité FSM
    signal START_TEMPO : std_logic;              -- Signal de démarrage de la temporisation
    signal GO_0        : std_logic;              -- Signal d'autorisation pour la génération du bit '0'
    signal GO_1        : std_logic;              -- Signal d'autorisation pour la génération du bit '1'
    signal load        : std_logic;              -- Signal de chargement des données
    signal shift       : std_logic;              -- Signal de décalage des données

    -- Signal de données d'entrée (vector de 51 bits)
    signal data_in     : std_logic_vector(50 downto 0) ;
-- Instanciation de l'entité FSM avec le label uut
begin
    uut: entity work.FSM
        port map (
            clk       => clk,
            reset     => reset,
            data      => data,
            FIN_TEMPO => FIN_TEMPO,
            FIN_0     => FIN_0,
            FIN_1     => FIN_1,
            trame     => trame,

            START_TEMPO => START_TEMPO,
            GO_0        => GO_0,
            GO_1        => GO_1,
            load        => load,
            shift       => shift
        );

    -- Génération de l'horloge et des signaux de test
    Clk <= not Clk after 5 ns;
    Reset <= '1', '0' after 2 ns;
    -- Normalement la trame et la data_in sont fournis automatiquement par les autres entités
    -- On les définit indépendament ici pour tester
    trame <= '0', '1'after 25 ns ,'0' after 1 ms,'1' after 13.0001 ms, '0' after 13.1 ms;
    data_in <= "111" & x"FFF0F6E001BE", "101"&x"FFE123456789" after 12.9 ms;

    -- Processus de simulation
    process
    begin

        data <= data_in(50);
        -- Boucle pour simuler la transmission de chaque bit de la trame
        for i in 0 to 50 loop
            wait for 30 ns; FIN_0 <= '0'; FIN_1 <= '0';
            data <= data_in(50 - i);
            -- Simulation de la fin de la transmission d'un bit
            if data = '1' then wait for 106 us; FIN_1 <= '1';
            elsif data = '0' then wait for 190 us; FIN_0 <= '1';
            else report "data error ";
            end if;
        end loop;

        -- Indication de la fin de la transmission de la première trame
        FIN_0 <= '1';
        wait for 30 ns; FIN_1 <= '0';FIN_0 <= '0';
        wait for 6 ms; FIN_TEMPO <= '1';
        -- Simulation d'une temporisation après la fin de la transmission
        wait for 10 ns; FIN_TEMPO <= '0';
        wait for 10 ns;

        -- Boucle pour simuler la transmission de la trame suivante
        for i in 0 to 50 loop
            wait for 30 ns; FIN_0 <= '0'; FIN_1 <= '0';
            data <= data_in(50 - i);
            if data = '1' then wait for 106 us; FIN_1 <= '1';
            elsif data = '0' then wait for 190 us; FIN_0 <= '1';
            else report "data error ";
            end if;
        end loop;
    end process;
end Behavioral;
