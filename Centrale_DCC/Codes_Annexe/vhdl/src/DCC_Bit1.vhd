----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 2023/03/21 10:48:01
-- Design Name:
-- Module Name: DCC_Bit1 - Behavioral
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

entity DCC_Bit1 is

  Port
   (
	Clk 		: in STD_LOGIC;	   -- Horloge 100 MHz
    Reset 		: in STD_LOGIC;	   -- Reset Asynchrone
    Clk1M 		: in STD_LOGIC;	   -- Horloge 1 MHz
    GO_1        : in STD_LOGIC;    -- entrée de la MAE
    FIN_1       : out STD_LOGIC;   -- sortie fin de bit vers la MAE
    DCC_1       : out STD_LOGIC    -- sortie vers la porte OU
   );
end DCC_Bit1;

architecture Behavioral of DCC_Bit1 is

----------------Déclaration des signaux-------------------

signal cpt : std_logic_vector(7 downto 0) := (others => '0');
signal dcc_out : std_logic := '0';
signal fin  : std_logic := '0';
signal fin_tri : std_logic := '0';
signal fin_cpt : std_logic := '0';
type etat is (s0,s1);    -- Etats de la MAE
signal EP,EF : etat;	 -- Etat Présent, Etat Futur


begin
FIN_1 <= fin;
   ---- MAE - Registre d'Etat --
  process(Clk,Reset)
	begin
        -- Reset Asynchrone
		if Reset = '1' then EP <= s0; fin <= '0'; fin_tri <= '0';
		-- Si on a un Front d'Horloge
		elsif rising_edge (Clk) then
			EP <= EF; -- Mise a Jour du Registre d'Etat
			if (fin_cpt = '1' and fin_tri = '0') then fin <= '1'; fin_tri <= '1'; else fin <= '0'; end if;
			if (not(cpt = 0)) and (not(cpt = 115)) then fin_tri <= '0'; end if;
		end if;
	end process;
    -- machine a etat
    process(Clk, Reset, fin, EP, GO_1, dcc_out)
    begin
        case (EP) is
            when s0 => DCC_1<='0';  if GO_1 = '1' then EF <= s1; else EF <= s0; end if;
            when s1 => DCC_1 <= dcc_out;  -- mise à 0 de DCC_1
-------------------------en repart vers l'état initial si on a générer le bit à 1 ( 58 us à 0 puis 58 us à 1)----------------------------
                       if (GO_1 = '0' and fin = '1' ) then EF <= s0;
-------------------------si fin!=1 on continu d'incrémenter le compteur pour générer le bit à 1------------------------------------------
                       else if (GO_1 = '1' and fin = '0') then EF <= s1;
                       else EF <= EP; end if;
                       end if;
            when others => DCC_1 <= '0';
                            EF <= EP;
        end case;
    end process;

---------------------Process Compteur--------------------------------
-----------cpt_max=115 us car on commence de 0-----------------------
    process(Clk1M,Reset)
    begin
        -- Reset Asynchrone
        if Reset='1' then cpt <= (others => '0'); dcc_out <='0';
        -- Si on a un Front montant d'Horloge...
        elsif rising_edge(Clk1M) then
            if (EP = s0) then cpt <= (others => '0'); dcc_out <='0'; end if; -- état initial réinitialisation du compteur --
            if (EP = s1) then
                 cpt <= cpt + 1; -- incrémentation du compteur
                 if (cpt = 115) then  dcc_out <='0'; cpt <= (others => '0');  fin_cpt <= '1';
                 elsif (cpt >= 57) then dcc_out <='1'; fin_cpt <= '0';-- génération d'une impulsion à 1 pendant 58 us
                 else dcc_out <='0'; fin_cpt <= '0'; -- génération d'une impulsion à 0 pendant 58 us
                 end if;
            end if;
        end if;

    end process;




end Behavioral;
