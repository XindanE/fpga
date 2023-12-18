----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 23.03.2023 11:27:09
-- Design Name:
-- Module Name: Porte_OU - Behavioral
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

entity Porte_OU is
Port
  (
    CLK_1M     : in std_logic; -- Horloge à 1 Mhz
    RESET      : in std_logic; -- Reset Asynchrone
    DCCo_1     : in std_logic; -- Sortie DCC_1
    DCCo_0     : in std_logic; -- Sortie DCC_0
    Sortie_DCC :out std_logic  -- Sortie porte OR
  );
end Porte_OU;

architecture Behavioral of Porte_OU is

    ------------Déclaration des signaux-----------
signal DCC_out : std_logic;

begin

process(CLK_1M,Reset)
begin
    if reset='1' then DCC_out<='0';
    elsif rising_edge(CLK_1M) then
        DCC_out <=DCCo_0 or DCCo_1;  -- OR entre DCC_0 et DCC_1
    end if;
end process;

Sortie_DCC<=DCC_OUT;  -- Sortie DCC envoyé sur la locomotive

end Behavioral;
