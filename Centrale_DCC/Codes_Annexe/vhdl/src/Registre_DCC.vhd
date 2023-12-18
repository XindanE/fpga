----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 2023/03/27 22:32:36
-- Design Name:
-- Module Name: Registre_DCC - Behavioral
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


entity Registre_DCC is
 port
  (
    clk          : in  std_logic; -- Horloge à 100 Mhz
    reset        : in  std_logic; -- Reset asynchrone
    load         : in  std_logic; -- Commande pour le chargement de la trame
    shift        : in  std_logic; -- Commande pour le décalage de la trame
    data_in      : in  std_logic_vector(50 downto 0); -- Trame en entrée sur 51 bits
    START_TEMPO  : in  std_logic; -- Commande pour entamer le délai de temporisation de 6 ms
    trame        : out std_logic; -- Commande envoyé à la MAE pour indiquer qu'il y'a une trame en entrée
    bit_out      : out std_logic  -- bit MSB décaler envoyé à la machine à état
  );
end entity Registre_DCC;

architecture behavioral of Registre_DCC is
signal reg : std_logic_vector(50 downto 0);
begin
    -- Processus gérant le comportement du registre
    process (data_in, clk, START_TEMPO, reset)
    begin
        -- Si data_in est à 0 ou START_TEMPO est à 1, pas de trame en entrée
        if data_in = 0 then trame <= '0';elsif START_TEMPO = '1' then trame <= '0'; else trame <= '1'; end if;

         -- Si le reset est activé, le registre est réinitialisé à 0
        if reset = '1' then
            reg <= (others => '0');
        -- À la montée de l'horloge
        elsif rising_edge(clk) then
            -- Si la commande load est activée, on charge la trame en entrée dans le registre
            if load = '1' then
                reg <= data_in;
            -- Si la commande shift est activée, on décale tous les bits du registre d'un rang vers la droite
            elsif shift = '1' then
                reg <= reg(49 downto 0) & '0';
            -- Sinon, le registre reste inchangé
            else reg <= reg;
            end if;
        end if;
    end process;

    -- Le bit de sortie est le bit le plus significatif du registre bit MSB
    bit_out <= reg(50);
end architecture behavioral;
