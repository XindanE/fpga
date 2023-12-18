#include "xparameters.h"
#include "xgpio.h"
#include "dcc.h"
#include <stdint.h>

#define BOUTTON_DROIT 0x1
#define BOUTTON_CENTRE 0x2
#define BOUTTON_GAUCHE 0x4

int main() {

	//GPIO
    XGpio Gpio_LED, Gpio_Btn;
    int Btn_Data;

    // Variables
    uint8_t train_adresse = 0; // adresse du train
    uint8_t direction = 0; // direction du train 0: Forward, 1: Backward
    uint8_t vitesse = 0;   // vitesse du train
    int fonction = -1;	// fonction , initialis? ? -1 si aucun fonction est choisi
    uint8_t state_fonction = 0; // ?tat de la focntion, 1 pour ON et 0 pour OFF
    uint8_t vitesse_direction;  //variable pour combiner les informations de la vitesse et de la direction
    uint8_t commande_fonction;  // 1er octet pour la commande
    uint8_t commande_fonction2; // 2?me octet pour la commande
    uint8_t controle = 0; // champ de contr?le (xor)
    uint64_t trame = 0; // trame ? envoyer
    int i;
    uint16_t leds;		// valeur des LEDs ? afficher
    uint32_t reg0_val;  // valeur lu par registre 0 de DCC
    uint32_t reg1_val;  // valeur lu par registre 1 de DCC
    uint64_t full_val;  // valeur compl?te
    int display_part = 0;  // on affiche la valeur en 4 fois ( 51 bits / 16 leds = 4 )

	// On d?finit les ?tats
	//STATE_ADRESSE		-- pour s?lectionner un train par son adresse
	//STATE_COMMANDE	-- pour choisir entre changement de la vitesse du train et choix d'une fonction
	//STATE_DIRECTION	-- pour choisir une direction
	//STATE_VITESSE     -- pour s?lectionner une vitesse
	//STATE_FONCTION	-- pour s?lectionner une fonction
	//STATE_ON_OFF		-- pour s?lectionner l'?tat de la fonction
	//STATE_VALIDE		-- pour valider la trame
	//STATE_HOLD		-- pour afficher le contenu des registres

    typedef enum {
        STATE_ADRESSE,
		STATE_COMMANDE,
		STATE_DIRECTION,
		STATE_VITESSE,
		STATE_FONCTION,
		STATE_ON_OFF,
		STATE_VALIDE,
		STATE_HOLD
    } State;
    State current_state = STATE_ADRESSE;


    // Initialisation
    XGpio_Initialize(&Gpio_LED, XPAR_LED_DEVICE_ID);
    XGpio_Initialize(&Gpio_Btn, XPAR_BOUTONS_DEVICE_ID);

    // Configuration
    XGpio_SetDataDirection(&Gpio_LED, 1, 0x0000); //leds en sortie
    XGpio_SetDataDirection(&Gpio_Btn, 1, 0xFFFF); //boutons en entree

    while (1) {

    	switch (current_state)
    	        {
    	        case STATE_ADRESSE:
					//leds 12 - 14 pour afficher le numéro d'état
    	        	leds = XGpio_DiscreteRead(&Gpio_LED,1);
    	        	XGpio_DiscreteWrite(&Gpio_LED,1,0x1000|leds);
    	        	Btn_Data = XGpio_DiscreteRead(&Gpio_Btn, 1);
					// Si bouton droit est appuyé
    	        	if (Btn_Data & BOUTTON_DROIT){
						for(i=0;i<3000000;i++){} // delay pour éviter le rebond du bouton
						if (train_adresse > 3){
							train_adresse = 1;
						}
						// incrémenter  l'adresse à chaque fois
						else train_adresse ++;
						// afficher l'adresse du train en leds 0 - 2
						XGpio_DiscreteWrite(&Gpio_LED,1,(0x1000 | train_adresse));
					}
					// 	bouton centre pour valider l'adresse
					// On passe à l'état STATE_COMMANDE aprés la validation
    	            if (Btn_Data & BOUTTON_CENTRE){
    	            	for(i=0;i<3000000;i++){}
						// led 15 allumer pour dire changement d'état
    	            	XGpio_DiscreteWrite(&Gpio_LED,1,0x8000);
    	                current_state = STATE_COMMANDE;
    	            }
    	            break;

    	        case STATE_COMMANDE: //vitesse ou fonction
					//leds 12 - 14 pour afficher le numéro d'état
    	        	XGpio_DiscreteWrite(&Gpio_LED,1,(2<<12));

    	        	Btn_Data = XGpio_DiscreteRead(&Gpio_Btn, 1);
					// si bouton gauche est appuyé
					// on va contrôler la direction puis la vitesse
					// On passe à l'état STATE_DIRECTION
    	        	if (Btn_Data & BOUTTON_GAUCHE){
						// led 8 allume pour dire changement d'état
    	        		XGpio_DiscreteWrite(&Gpio_LED,1,0x0100);
    	        		for(i=0;i<3000000;i++){}
    	        		current_state = STATE_DIRECTION;
    	        	}
					// si bouton droit est appuyé
					// on va choisir une fonction
					// On passe à l'état STATE_FONCTION
    	        	else if (Btn_Data & BOUTTON_DROIT){
						// led 9 allume pour dire changement d'état
    	        		XGpio_DiscreteWrite(&Gpio_LED,1,0x0200);
						for(i=0;i<3000000;i++){}
						current_state = STATE_FONCTION;
					}
    	            break;

    	        case STATE_DIRECTION:
					//leds 12 - 14 pour afficher le numéro d'état
    	        	XGpio_DiscreteWrite(&Gpio_LED,1,(3<<12));
    	        	Btn_Data = XGpio_DiscreteRead(&Gpio_Btn, 1);
					// si bouton gauche est appuyé
					// le train va marcher en arriére
    	        	if (Btn_Data & BOUTTON_GAUCHE){
						// led 11 allumée pour dire qu'on va allez en marche arriére
    	        		XGpio_DiscreteWrite(&Gpio_LED,1,0x0800);
						for(i=0;i<3000000;i++){}
						direction = 0;
					}
					//sinon le train reste en marche avant
    	        	else{
    	        		direction = 1; // marche avant
						// led 10 allumée pour dire qu'on va marcher en arriére
    	        		XGpio_DiscreteWrite(&Gpio_LED,1,0x0400);
    	        	}
    	        	XGpio_DiscreteWrite(&Gpio_LED,1,direction);

					// On appuie sur le bouton centre pour passer à l'état STATE_VITESSE aprés la validation de la direction
    	        	if (Btn_Data & BOUTTON_CENTRE){
						// led 15 allumée pour dire changement d'état
    	        		XGpio_DiscreteWrite(&Gpio_LED,1,0x8000);
						for(i=0;i<3000000;i++){}
						current_state = STATE_VITESSE;
					}
    	        	break;


    	        case STATE_VITESSE:
					//leds 12 - 14 pour afficher le numéro d'état
    	        	leds = XGpio_DiscreteRead(&Gpio_LED,1);
    	        	XGpio_DiscreteWrite(&Gpio_LED,1,(0x4000|leds)&(0x7FFF));
    	        	Btn_Data = XGpio_DiscreteRead(&Gpio_Btn, 1);

					// A chaque fois on appuie sur le bouton droit
					// on incrémente la valeur de la vitesse
					if (Btn_Data & BOUTTON_DROIT){
						for(i=0;i<3000000;i++){}

						if (vitesse > 30){
							vitesse = 0;
						}
						else vitesse ++;
						//leds 0 - 4 pour afficher la valeur de vitesse
						XGpio_DiscreteWrite(&Gpio_LED,1,(0x4000| vitesse));
					}

					// On appuie sur le bouton centre pour passer à l'état STATE_VALIDE aprés la validation de la vitesse
					Btn_Data = XGpio_DiscreteRead(&Gpio_Btn, 1);
					if (Btn_Data & BOUTTON_CENTRE){
						for(i=0;i<3000000;i++){}
						// led 15 allumée pour dire changement d'état
						XGpio_DiscreteWrite(&Gpio_LED,1,0x8000);
						current_state = STATE_VALIDE;
					}
    	            break;

    	        case STATE_FONCTION:
					//leds 12 - 14 pour afficher le numéro d'état
    	        	leds = XGpio_DiscreteRead(&Gpio_LED,1);
    	        	XGpio_DiscreteWrite(&Gpio_LED,1,0x5000|leds);
					Btn_Data = XGpio_DiscreteRead(&Gpio_Btn, 1);
					// A chaque fois on appuie sur le bouton droit
					// on incrémente le numéro de fonction
					if (Btn_Data & BOUTTON_DROIT){
						for(i=0;i<3000000;i++){}

						if (fonction > 20){
							fonction = 0;
						}
						else fonction ++;
						//leds 0 - 4 pour afficher le numéro de fonction
						XGpio_DiscreteWrite(&Gpio_LED,1,(0x5000 |fonction));
					}
					// On appuie sur le bouton centre pour passer à l'état STATE_ON_OFF aprés la validation de la fonction
					Btn_Data = XGpio_DiscreteRead(&Gpio_Btn, 1);
					if (Btn_Data & BOUTTON_CENTRE){
						for(i=0;i<3000000;i++){}
						// led 15 allumée pour dire changement d'état
						XGpio_DiscreteWrite(&Gpio_LED,1,0x8000);
						current_state = STATE_ON_OFF;
					}
					break;

    	        case STATE_ON_OFF :
					//leds 12 - 14 pour afficher le numéro d'état
    	        	leds = XGpio_DiscreteRead(&Gpio_LED,1);
    	        	XGpio_DiscreteWrite(&Gpio_LED,1,((6<<12)|leds) & 0x7FFF);
					// si bouton gauche est appuyé la fonction est en état ON
    	        	if (Btn_Data & BOUTTON_GAUCHE){
						// led 8 allumée pour dire que la fonction est en état ON
    	        		XGpio_DiscreteWrite(&Gpio_LED,1,0x0100);
    	        		for(i=0;i<3000000;i++){}
    	        		state_fonction = 1; //fonction_ON
    	        	}
					//sinon état OFF
    	        	else{
						// led 9 allumée pour dire que la fonction est en état OFF
    	        		XGpio_DiscreteWrite(&Gpio_LED,1,0x0200); //fonction OFF
    	        	}

					// On appuie sur le bouton centre pour passer à l'état STATE_VALIDE aprés la validation de l'état de fonction
    	        	Btn_Data = XGpio_DiscreteRead(&Gpio_Btn, 1);
    	        	if (Btn_Data & BOUTTON_CENTRE){
    	        		for(i=0;i<3000000;i++){}
						// led 15 allumée pour dire changement d'état
    	        		XGpio_DiscreteWrite(&Gpio_LED,1,0x8000);
						current_state = STATE_VALIDE;
					}
					break;

    	        case STATE_VALIDE:
					//leds 12 - 14 pour afficher le numéro d'état
    	        	leds = XGpio_DiscreteRead(&Gpio_LED,1);
    	        	XGpio_DiscreteWrite(&Gpio_LED,1, ((7<<12)|leds));

					// dans cet état on va former la trame en utilisant les informations d'avant
					// si la fonction n'égale pas -1, on a fait le choix d'une fonction
    	        	if (fonction != -1){ //fonction
    	        		leds = XGpio_DiscreteRead(&Gpio_LED,1);
						// on allume les leds pour afficher le numéro et l'état de fonction
    	        		XGpio_DiscreteWrite(&Gpio_LED,1,(leds|fonction)|(state_fonction<<8));
    	        		if (fonction >= 0 && fonction <= 4){ //fonction 0 - 4
    	        			//commande_fonction
    	        			commande_fonction = 0b10000000; // les 3 premiers bits sont fixés
							//F0
							if (fonction == 0) {
								commande_fonction |= (state_fonction << 4);
							}
							// F1 to F4
							else if (fonction >= 1 && fonction <= 4) {
								commande_fonction &= ~(1 << 4); // Clear le bit 4
								commande_fonction |= (state_fonction << (fonction - 1));
							}
							// trame
    	        			trame |= ((uint64_t)0x7FFFFF << 28); // 23 bit a 1

							trame |= ((uint64_t)0 << 27); // 1 bit a 0

							trame |= ((uint64_t)train_adresse << 19); // 8 bit d'adresse

							trame |= ((uint64_t)0 << 18); // 1 bit a 0

							trame |= ((uint64_t)commande_fonction << 10); // 8 bit de commande

							trame |= ((uint64_t)0 << 9); // 1 bit a 0

							controle = train_adresse ^ commande_fonction;
							trame |= ((uint64_t)controle << 1); // 8 bit de contrôle

							trame |= ((uint64_t)1); // 1 bit a 1
    	        		}

    	        		//fonction 5 -12
    	        		if (fonction >= 5 && fonction <= 12){ //fonction 5 -12
							//commande_fonction
							commande_fonction = 0b10100000; // les 3 premiers bits sont fixés
							//F5-8
							if (fonction >= 5 && fonction <= 8) {
								commande_fonction |= (1 << 4);
								commande_fonction |= (state_fonction << (fonction - 5));
							}
							// F9 to F12
							else if (fonction >= 9 && fonction <= 12) {
								commande_fonction &= ~(1 << 4); // Clear the 4th bit
								commande_fonction |= (state_fonction << (fonction - 9));
							}
							// trame
							trame |= ((uint64_t)0x7FFFFF << 28); // 23 bit a 1

							trame |= ((uint64_t)0 << 27); // 1 bit a 0

							trame |= ((uint64_t)train_adresse << 19); // 8 bit d'adresse

							trame |= ((uint64_t)0 << 18); // 1 bit a 0

							trame |= ((uint64_t)commande_fonction << 10); // 8 bit de commande

							trame |= ((uint64_t)0 << 9); // 1 bit a 0

							controle = train_adresse ^ commande_fonction;
							trame |= ((uint64_t)controle << 1); // 8 bit de controle

							trame |= ((uint64_t)1); // 1 bit a 1
						}

    	        		//fonction 13 -20
    	        		else if (fonction >= 13 && fonction <= 20){
    	        			commande_fonction = 0b11011110; // les 8 premiers bits sont fixés
    	        			commande_fonction2 = 00000000;
							commande_fonction2 |= (state_fonction << (fonction - 13));

							trame |= ((uint64_t)0x3FFF << 37); // 14 bit a 1

							trame |= ((uint64_t)0 << 36); // 1 bit a 0

							trame |= ((uint64_t)train_adresse << 28); // 8 bit d'adresse

							trame |= ((uint64_t)0 << 27); // 1 bit a 0

							trame |= ((uint64_t)commande_fonction << 19);

							trame |= ((uint64_t)0 << 18); // 1 bit a 0

							trame |= ((uint64_t)commande_fonction2 << 10); // 16 bit de commande

							trame |= ((uint64_t)0 << 9); // 1 bit a 0

							controle = train_adresse ^ commande_fonction  ^ commande_fonction2;
							trame |= ((uint64_t)controle << 1); // 8 bit de contrôle

							trame |= ((uint64_t)1); // 1 bit a 1
    	        		}

    	        	}

					// si la fonction égale toujours à -1 c'est à dire l'utilisateur veut modifier la vitesse
    	        	else { //vitesse
    	        		leds = XGpio_DiscreteRead(&Gpio_LED,1);
    	        		XGpio_DiscreteWrite(&Gpio_LED,1,(leds|vitesse));

    	        		trame |= ((uint64_t)0x7FFFFF << 28); // 23 bit a 1

    	        		trame |= ((uint64_t)0 << 27); // 1 bit a 0

    	        		trame |= ((uint64_t)train_adresse << 19); // 8 bit d'adresse

    	        		trame |= ((uint64_t)0 << 18); // 1 bit a 0

    	        		vitesse_direction = (0b01 << 6) | (direction << 5) | vitesse;
    	        		trame |= ((uint64_t)vitesse_direction << 10); // 8 bit de commande

    	        		trame |= ((uint64_t)0 << 9); // 1 bit a 0

    	        		controle = train_adresse ^ vitesse_direction;
    	        		trame |= ((uint64_t)controle << 1); // 8 bit de controle

    	        		trame |= ((uint64_t)1); // 1 bit a 1

    	        	}

					//allumé la led 15 si la trame est préte
    	        	leds = XGpio_DiscreteRead(&Gpio_LED,1);
    	        	XGpio_DiscreteWrite(&Gpio_LED,1,0x8000|leds);
    	        	Btn_Data = XGpio_DiscreteRead(&Gpio_Btn, 1);
    	        	if (Btn_Data & BOUTTON_CENTRE){
						for(i=0;i<3000000;i++){}
						// // toutes les leds sont éteintes pour dire changement d'état
						XGpio_DiscreteWrite(&Gpio_LED,1,0);
						// écriure de la trame dans les deux registres REG0 et 1
						DCC_mWriteReg(XPAR_DCC_0_S00_AXI_BASEADDR, DCC_S00_AXI_SLV_REG0_OFFSET, (uint32_t)trame);
						DCC_mWriteReg(XPAR_DCC_0_S00_AXI_BASEADDR, DCC_S00_AXI_SLV_REG1_OFFSET, (uint32_t)(trame >> 32));
						current_state = STATE_HOLD;
    	        	}

    	        	break;
    	        case STATE_HOLD:
					//XGpio_DiscreteWrite(&Gpio_LED,1,0xFFFF); // Ecriture de l'état des LEDs
					Btn_Data = XGpio_DiscreteRead(&Gpio_Btn, 1);

					// lecture du contenue des deux registres pour vérifier
					reg0_val = DCC_mReadReg(XPAR_DCC_0_S00_AXI_BASEADDR, DCC_S00_AXI_SLV_REG0_OFFSET);
					reg1_val = DCC_mReadReg(XPAR_DCC_0_S00_AXI_BASEADDR, DCC_S00_AXI_SLV_REG1_OFFSET);
					// trame complète
					full_val = ((uint64_t)reg1_val << 32) | reg0_val;

					// on affiche 16 bits à la fois du à l'appuie sur bouton droit
					// il faut appuyer 4 fois pour afficher la trame compléte
					Btn_Data = XGpio_DiscreteRead(&Gpio_Btn, 1);
					if (Btn_Data & BOUTTON_DROIT){
						for(i=0;i<3000000;i++){}
						leds = (full_val >> (16 * display_part)) & 0xFFFF;
						if (display_part > 2){
							display_part = 0;
						}
						else display_part ++;
						XGpio_DiscreteWrite(&Gpio_LED,1, leds );

					}

					// Pour retourner à l'état initiale on appuie sur le bouton centre
					// on initialise toutes les variables
					if (Btn_Data & BOUTTON_CENTRE){
						for(i=0;i<3000000;i++){}
						XGpio_DiscreteWrite(&Gpio_LED,1,0); // éteintdre toutes les leds
						train_adresse = 0;
						direction = 0;
						vitesse = 0;
						fonction = -1;
						state_fonction = 0;
						controle = 0;
						trame = 0;
						current_state = STATE_ADRESSE;
    	        	}
    	        	break;
    	        }

    	    }

    return 0;
}
