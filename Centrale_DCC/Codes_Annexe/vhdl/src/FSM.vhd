----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 2023/03/28 08:41:21
-- Design Name:
-- Module Name: FSM - Behavioral
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

entity FSM is
Port
  (
    clk          : in  std_logic; -- Horloge 100 Mhz
    reset        : in  std_logic; -- Reset asynchrone
    data         : in  std_logic; -- sortie bit_0 du regsitre à décalage
    FIN_TEMPO    : in  std_logic; -- Fin du délai de temporisation de 6 ms
    FIN_0        : in  std_logic; -- Fin de la génération du bit à 0
    FIN_1        : in  std_logic; -- Fin de la génération du bit à 1
    trame        : in  std_logic; -- Sortie du registre à décalge pour indiquer la présence d'une trame
    START_TEMPO  : out std_logic; -- pour indiquer le début de comptage du délai de temporisation 6 ms entre deux trames
    GO_0         : out std_logic; -- demande de génération du bit à 0
    GO_1         : out std_logic; -- demande de génération du bit à 1
    load         : out std_logic; -- sortie du registre à décalage pour indiquer le chargement de la trame
    shift        : out std_logic  -- sortie du registre à décalage pour indiquer le décalage d'un bit MSB de la trame
  );
end FSM;

architecture Behavioral of FSM is

-------------------------------Déclaration des signaux------------------------------
signal cpt : integer range 0 to 50 := 0;        -- size
type etat is (s0, s1,s2,s3,s4,s5,s6,s7,s8);		-- Etats de la MAE
signal EP,EF: etat;							-- Etat Present, Etat Futur

begin
  process(clk,reset)
	begin
	-- Reset Asynchrone
		if Reset='1' then cpt <= 0;
		-- Si on a un Front d'Horloge
		elsif rising_edge(clk) then
			--cpt à 0 au début
			if (EP = s0) then cpt <= 0;
			--reset de cpt à 0 si dépasse 51 bits
			elsif (EP = s2) or (EP = s5) then if cpt > 50 then cpt <= 0; end if;
			--incrémenter du cpt
			elsif (EP = s7) then cpt <= cpt + 1;
			end if;
		end if;
	end process;

	-- MAE - Registre d'Etat --
	process(clk,reset)
	begin
		-- Reset Asynchrone
		if Reset = '1' then EP <= s0;
		-- Si on a un Front d'Horloge
		elsif rising_edge (Clk) then
			EP <= EF; -- Mise a Jour du Registre d'Etat
		end if;
	end process;

	process(clk,cpt,EP,data,trame,FIN_TEMPO,FIN_0,FIN_1)
	begin

        -- s0 : état initial
		-- s1 : chargement de la trame
		-- s2 : décalage de la trame
        -- s3 : génération du bit 0
		-- s4 : génération du bit 1
        -- s5 : attente de la fin de la génération du bit 0
        -- s6 : attente de la fin de la génération du bit 1
        -- s7 : vérification du compteur après la génération d'un bit
        -- s8 : attente de la fin du délai de temporisation entre deux trames

	   case(EP)is
	       when s0 =>  load <= '0'; shift <= '0'; GO_0 <='0'; GO_1 <= '0'; START_TEMPO <= '0';
	                   if trame = '1' then EF <= s1; else EF <= s0; end if;
	       when s1 =>  load <= '1'; shift <= '0'; GO_0 <='0'; GO_1 <= '0'; START_TEMPO <= '0';
	                   EF <= s2;
	       when s2 =>  load <= '0'; shift <= '1'; GO_0 <='0'; GO_1 <= '0'; START_TEMPO <= '0';
	                   if data <= '0' then EF <=s3;
	                   elsif data <= '1' then EF <=s4;
	                   else EF <= s2;
	                   end if;
	       when s3 =>  load <= '0'; shift <= '0'; GO_0 <= '1'; GO_1 <= '0'; START_TEMPO <= '0';
	                   EF <= s5;
	       when s4 =>  load <= '0'; shift <= '0'; GO_0 <= '0'; GO_1 <= '1'; START_TEMPO <= '0';
	                   EF <= s6;
	       when s5 =>  load <= '0'; shift <= '0'; GO_0 <= '0'; GO_1 <= '0'; START_TEMPO <= '0';
	                   if cpt > 50 then EF <= s8;
	                   elsif FIN_0 = '1'then EF <= s7; else EF <= s5; end if;
	       when s6 =>  load <= '0'; shift <= '0'; GO_0 <= '0'; GO_1 <= '0'; START_TEMPO <= '0';
	                   if cpt > 50 then EF <= s8;
	                   elsif FIN_1 = '1'then EF <= s7; else EF <= s6; end if;
	       when s7 =>  load <= '0'; shift <= '0'; GO_0 <= '0'; GO_1 <= '0'; START_TEMPO <= '0';
	                   if cpt >= 50 then EF <= s8; else EF <= s2; end if;
	       when s8 =>  load <= '0'; shift <= '0'; GO_0 <= '0'; GO_1 <= '0'; START_TEMPO <= '1';
	                   if FIN_TEMPO = '1' then EF <= s0;
	                   else EF <= s8;
	                   end if;
	    end case;
	end process;

end Behavioral;
