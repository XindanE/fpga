----------------------------------------------------------------------------------
-- Company: SORBONNE UNIVERSITE
-- Designed by: J.DENOULET, Winter 2021
--
-- Module Name: DCC_FRAME_GENERATOR - Behavioral
-- Project Name: Centrale DCC
-- Target Devices: NEXYS 4 DDR
--
--	G�n�rateur de Trames de Test pour la Centrale DCC
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity DCC_FRAME_GENERATOR is
  Port
	 (
	   Interrupteur	: in STD_LOGIC_VECTOR(7 downto 0);	-- Interrupteurs de la Carte
       Trame_DCC 	: out STD_LOGIC_VECTOR(50 downto 0));-- Trame DCC de Test
end DCC_FRAME_GENERATOR;

architecture Behavioral of DCC_FRAME_GENERATOR is

begin

-- G�n�ration d'une Trame selon l'Interrupteur Tir� vers le Haut
-- Si Plusieurs Interupteurs Sont Tir�s, Celui de Gauche Est Prioritaire

-- Compl�ter les Trames pour R�aliser les Tests Voulus

process(Interrupteur)
begin

	-- Interrupteur 7 Activ�
		--> Trame Marche Avant du Train d'Adresse 2
	if Interrupteur(7)='1' then

		Trame_DCC <= "11111111111111111111111"	-- Pr�ambule
					& '0'				-- Start Bit
					& x"02"				-- Champ Adresse locomotive num�ro 2
					& '0'				-- Start Bit
					& "01100111"		-- Champ Commande
					& '0'				-- Start Bit
					& (x"02" xor "01100111")	-- Champ Controle
					& '1'	;			-- Stop Bit

	-- Interrupteur 6 Activ�
		--> Trame Marche Arri��re du Train d'Adresse 2
	elsif Interrupteur(6)='1' then

		Trame_DCC <= "11111111111111111111111"	-- Pr�ambule
					& '0'				-- Start Bit
					& x"02"				-- Champ Adresse locomotive num�ro 2
					& '0'				-- Start Bit
					& "01000111"		-- Champ Commande
					& '0'				-- Start Bit
					& (x"02" xor "01000111")	-- Champ Controle
					& '1'	;			-- Stop Bit


	-- Interrupteur 5 Activ�
		--> Allumage des Phares du Train d'Adresse 2
	elsif Interrupteur(5)='1' then

		Trame_DCC <= "11111111111111111111111"	-- Pr�ambule
					& '0'				-- Start Bit
					& x"02"				-- Champ Adresse locomotive num�ro 2
					& '0'				-- Start Bit
					& "10010000"		-- Champ Commande
					& '0'				-- Start Bit
					& (x"02" xor "10010000")	-- Champ Controle
					& '1'	;			-- Stop Bit

	-- Interrupteur 4 Activ�
		--> Extinction des Phares du Train d'Adresse 2
	elsif Interrupteur(4)='1' then

		Trame_DCC <= "11111111111111111111111"	-- Pr�ambule
					& '0'				-- Start Bit
					& x"02"				-- Champ Adresse locomotive num�ro 2
					& '0'				-- Start Bit
					& "10000000"		-- Champ Commande
					& '0'				-- Start Bit
					& (x"02" xor "10000000")	-- Champ Controle
					& '1'	;			-- Stop Bit

	-- Interrupteur 3 Activ�
		--> Activation du Klaxon (Fonction F11) du Train d'Adresse 2
	elsif Interrupteur(3)='1' then

		Trame_DCC <= "11111111111111111111111"	-- Pr�ambule
					& '0'				-- Start Bit
					& x"02"				-- Champ Adresse locomotive num�ro 2
					& '0'				-- Start Bit
					& "10100100"		-- Champ Commande
					& '0'				-- Start Bit
					& (x"02" xor "10100100")	-- Champ Controle
					& '1'	;			-- Stop Bit

	-- Interrupteur 2 Activ�
		--> R�amor�age du Klaxon (Fonction F11) du Train d'Adresse 2
	elsif Interrupteur(2)='1' then

		Trame_DCC <= "11111111111111111111111"	-- Pr�ambule
					& '0'				-- Start Bit
					& x"02"				-- Champ Adresse locomotive num�ro 2
					& '0'				-- Start Bit
					& "10100000"		-- Champ Commande
					& '0'				-- Start Bit
					& (x"02" xor "10100000")	-- Champ Controle
					& '1'	;			-- Stop Bit

	-- Interrupteur 1 Activ�
		--> Annonce SNCF (Fonction F13) du Train d'Adresse 2
	elsif Interrupteur(1)='1' then

		Trame_DCC <= "11111111111111"	-- Pr�ambule
					& '0'				-- Start Bit
					& x"02"				-- Champ Adresse locomotive num�ro 2
					& '0'				-- Start Bit
					& "11011110"		-- Champ Commande
					& '0'				-- Start Bit
					& "00000001"		-- Champ Commande (2eme octet)
					& '0'				-- Start Bit
					& (x"02" xor "11011110" xor "00000001")		-- Champ Contr�le
					& '1'	;			-- Stop Bit

	-- Interrupteur 0 Activ�
		--> Annonce SNCF (Fonction F13) du Train d'Adresse 2
	elsif Interrupteur(0)='1' then

		Trame_DCC <= "11111111111111"	-- Pr�ambule
					& '0'				-- Start Bit
					& x"02"				-- Champ Adresse locomotive num�ro 2
					& '0'				-- Start Bit
					& "11011110"		-- Champ Commande
					& '0'				-- Start Bit
					& "00000000"		-- Champ Commande (2eme octet)
					& '0'				-- Start Bit
					& (x"02" xor "11011110" xor "00000000")		-- Champ Controle
					& '1'	;			-- Stop Bit

	-- Aucun Interrupteur Activ�
		--> Arr��t du Train d'Adresse 2
	else

		Trame_DCC <= "11111111111111111111111"	-- Pr�ambule
					& 	'0'			-- Start Bit
					& x"02"			-- Champ Adresse locomotive num�ro 2
					& 	'0'			-- Start Bit
					&	"01100000"	-- Champ Commande
					& 	'0'			-- Start Bit
					& (x"02" xor "01100000")	-- Champ Controle
					& 	'1';		-- Stop Bit
	end if;

end process;

end Behavioral;