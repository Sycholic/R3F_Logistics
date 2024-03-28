private ["_joueur", "_hangar", "_pos_avant_module", "_dir_avant_module", "_curr_step"];
private ["_usine", "_hunter", "_statique", "_sac_sable"];

// Empêcher de lancer plusieurs modules en même temps
if (!isNil "R3F_LOG_TUTO_module_state" && {R3F_LOG_TUTO_module_state != "EXIT"}) exitWith
{
	systemChat "ERROR: A MODULE IS ALREADY RUNNING. ENDING IT.";
	R3F_LOG_TUTO_module_state = "END";
};

R3F_LOG_TUTO_num_exec_module = R3F_LOG_TUTO_num_exec_module + 1;

#include "dlg_constantes_usine.h"

_joueur = player;
_hangar = objNull;
_pos_avant_module = getPos _joueur;
_dir_avant_module = getDir _joueur;
R3F_LOG_TUTO_module_state = "INIT";

// Machine à état gérant les différentes étapes du module
while {R3F_LOG_TUTO_module_state != "EXIT"} do
{
	_curr_step = R3F_LOG_TUTO_module_state;
	
	switch (R3F_LOG_TUTO_module_state) do
	{
		case "INIT":
		{
			private ["_idx_hangar_libre"];
			
			_idx_hangar_libre = [_joueur] call R3F_LOG_TUTO_FNCT_reserver_hangar;
			
			// Si un hangar est libre, on y va et initialise le décor
			if (_idx_hangar_libre != -1) then
			{
				private ["_data_obj_fils", "_data_obj_ref", "_pos_decor", "_obj_crees"];
				
				_hangar = R3F_LOG_TUTO_tab_hangars select _idx_hangar_libre;
				
				1010 cutText ["", "BLACK OUT"];
				
				_usine = [
					"Land_Cargo20_military_green_F",
					_hangar,
					getPos (_hangar getVariable "R3F_LOG_TUTO_helipad_degage"),
					getDir (_hangar getVariable "R3F_LOG_TUTO_helipad_degage"),
					false
				] call R3F_LOG_TUTO_FNCT_creer_objet;
				_usine setVariable ["R3F_LOG_disabled", true, true];
				[_usine, 300000, side group _joueur] execVM "R3F_LOG\USER_FUNCT\init_creation_factory.sqf";
				
				sleep 1;
				player setPos ((_hangar getVariable "R3F_LOG_TUTO_helipad_degage") modelToWorld [-9, -9, 0]);
				player setDir (45+getDir (_hangar getVariable "R3F_LOG_TUTO_helipad_degage"));
				sleep 1;
				1010 cutText ["", "BLACK IN"];
				
				// Fil de surveillance des conditions générales mettant fin au module
				[_joueur, _hangar] spawn
				{
					private ["_joueur", "_hangar"];
					
					_joueur = _this select 0;
					_hangar = _this select 1;
					
					while {R3F_LOG_TUTO_module_state != "EXIT"} do
					{
						if !(R3F_LOG_TUTO_module_state in ["ABORT", "SUCCESS", "END"]) then
						{
							if (!alive _joueur) then
							{
								waitUntil {!isNull player && {alive player}};
								if (!isNull _joueur) then {deleteVehicle _joueur;};
								
								["MODULE FAILED", 3] spawn R3F_LOG_TUTO_FNCT_afficher_centre;
								
								R3F_LOG_TUTO_module_state = "END";
							};
							
							_pos_rel_joueur = _hangar worldToModel (_joueur modelToWorld [0,0,0]);
							
							// Vérification que le joueur ne s'éloigne pas de la zone du hangar
							if (
								!(
									-(25+R3F_LOG_TUTO_demi_largeur_hangar) < (_pos_rel_joueur select 0) && (_pos_rel_joueur select 0) < 25+R3F_LOG_TUTO_demi_largeur_hangar &&
									-(25+R3F_LOG_TUTO_demi_longueur_hangar) < (_pos_rel_joueur select 1) && (_pos_rel_joueur select 1) < 25+4.5*R3F_LOG_TUTO_demi_longueur_hangar
								) && _joueur distance (_hangar getVariable ["R3F_LOG_TUTO_helipad_degage", _joueur]) > 150
							) then
							{
								if (
									!(
										-(40+R3F_LOG_TUTO_demi_largeur_hangar) < (_pos_rel_joueur select 0) && (_pos_rel_joueur select 0) < 40+R3F_LOG_TUTO_demi_largeur_hangar &&
										-(40+R3F_LOG_TUTO_demi_longueur_hangar) < (_pos_rel_joueur select 1) && (_pos_rel_joueur select 1) < 40+4.5*R3F_LOG_TUTO_demi_longueur_hangar
									) && _joueur distance (_hangar getVariable ["R3F_LOG_TUTO_helipad_degage", _joueur]) > 200
								) then
								{
									["MODULE FAILED", 3] call R3F_LOG_TUTO_FNCT_afficher_centre;
									R3F_LOG_TUTO_module_state = "END";
								}
								else
								{
									cutText ["Come back !", "PLAIN", 1];
									
									player kbTell [player, "R3F_LOG_TUTO_kb_hors_zone", format ["zone_restriction_warn_has_leader_ADA_%1", floor random 2]];
									sleep 6;
								};
							};
						};
						
						sleep 1;
					};
				};
				
				player reveal _usine;
				
				
				// Quand l'interface de l'usine sera ouvert, les propriétés logistiques seront masquées si un hint est affiché
				0 spawn
				{
					disableSerialization;
					while {R3F_LOG_TUTO_module_state != "EXIT"} do
					{
						if !(isNull (findDisplay R3F_LOG_IDD_dlg_liste_objets)) then
						{
							if (isNil "RscAdvancedHint_close" || {RscAdvancedHint_close}) then
							{
								findDisplay R3F_LOG_IDD_dlg_liste_objets displayCtrl R3F_LOG_IDC_dlg_LO_infos ctrlSetFade 0;
							}
							else
							{
								findDisplay R3F_LOG_IDD_dlg_liste_objets displayCtrl R3F_LOG_IDC_dlg_LO_infos ctrlSetFade 0.95;
							};
							findDisplay R3F_LOG_IDD_dlg_liste_objets displayCtrl R3F_LOG_IDC_dlg_LO_infos ctrlCommit 1;
						};
						sleep 1;
					};
				};
				
				sleep 1;
				R3F_LOG_TUTO_module_state = "STEP1";
			}
			else
			{
				hintC "No free slot to do the module ! Wait that a player finish his module and try again.";
				R3F_LOG_TUTO_module_state = "EXIT";
			};
		};
		
		// Ouvrir l'interface de création et créer un Hunter HMG ("B_MRAP_01_hmg_F")
		case "STEP1":
		{
			["M3_S1_OuvrirUsine", "Open the creation factory interface."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M3_S1_OuvrirUsine"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			["M3_S1_CreerObjet", format ["Create a ""%1"".", getText (configFile >> "CfgVehicles" >> "B_MRAP_01_hmg_F" >> "displayName")]] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil
			{
				if (isNull findDisplay R3F_LOG_IDD_dlg_liste_objets) then
				{
					sleep 2;
					if ({_x getVariable ["R3F_LOG_CF_depuis_usine", false]} count nearestObjects [_usine, ["MRAP_01_base_F"], 200] == 0) then
					{
						["M3_S1_CreerObjet"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
						
						["M3_S1_OuvrirUsine", "Open the creation factory interface."] call R3F_LOG_TUTO_FNCT_creer_tache;
						waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
						if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
						["M3_S1_OuvrirUsine"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
						
						["M3_S1_CreerObjet", format ["Create a ""%1"".", getText (configFile >> "CfgVehicles" >> "B_MRAP_01_hmg_F" >> "displayName")]] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
						waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
					};
				};
				
				R3F_LOG_TUTO_module_state != _curr_step ||
				(
					isNull findDisplay R3F_LOG_IDD_dlg_liste_objets &&
					{_x getVariable ["R3F_LOG_CF_depuis_usine", false]} count nearestObjects [_usine, ["MRAP_01_base_F"], 200] != 0
				)
			};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M3_S1_CreerObjet", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			
			_hunter = (nearestObjects [_usine, ["MRAP_01_base_F"], 200]) select 0;
			
			R3F_LOG_TUTO_module_state = "STEP2";
		};
		
		// Ouvrir l'usine, sélectionner la catégorie "Static", créer un mortier ("B_Mortar_01_F"), le poser par terre
		case "STEP2":
		{
			["M3_S2_OuvrirUsine", "Open the creation factory interface."] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M3_S2_OuvrirUsine"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			["M3_S2_SelectionnerCategorie", format ["Select the category ""%1"".", getText (configFile >> "CfgVehicleClasses" >> "Static" >> "displayName")]] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil
			{
				if (isNull findDisplay R3F_LOG_IDD_dlg_liste_objets) then
				{
					["M3_S2_SelectionnerCategorie"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
					
					["M3_S2_OuvrirUsine", "Open the creation factory interface."] call R3F_LOG_TUTO_FNCT_creer_tache;
					waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
					if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
					["M3_S2_OuvrirUsine"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
					
					["M3_S2_SelectionnerCategorie", format ["Select the category ""%1"".", getText (configFile >> "CfgVehicleClasses" >> "Static" >> "displayName")]] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
					waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
				};
				
				R3F_LOG_TUTO_module_state != _curr_step ||
				(
					!isNull findDisplay R3F_LOG_IDD_dlg_liste_objets && !isNil {_usine getVariable "R3F_LOG_CF_cfgVehicles_categories"} &&
					{
						(_usine getVariable "R3F_LOG_CF_cfgVehicles_categories") select
						(
							lbCurSel (findDisplay R3F_LOG_IDD_dlg_liste_objets displayCtrl R3F_LOG_IDC_dlg_LO_liste_categories)
						) == "Static"
					}
				)
			};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M3_S2_SelectionnerCategorie"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			["M3_S2_CreerObjet", format ["Create a ""%1"".", getText (configFile >> "CfgVehicles" >> "B_Mortar_01_F" >> "displayName")]] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil
			{
				if (isNull findDisplay R3F_LOG_IDD_dlg_liste_objets) then
				{
					sleep 2;
					if ({_x getVariable ["R3F_LOG_CF_depuis_usine", false]} count nearestObjects [_usine, ["Mortar_01_base_F"], 200] == 0) then
					{
						["M3_S2_CreerObjet"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
						
						["M3_S2_OuvrirUsine", "Open the creation factory interface."] call R3F_LOG_TUTO_FNCT_creer_tache;
						waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
						if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
						["M3_S2_OuvrirUsine"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
						
						["M3_S2_CreerObjet", format ["Create a ""%1"".", getText (configFile >> "CfgVehicles" >> "B_Mortar_01_F" >> "displayName")]] call R3F_LOG_TUTO_FNCT_creer_tache;
						waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
					};
				};
				
				R3F_LOG_TUTO_module_state != _curr_step ||
				(
					isNull findDisplay R3F_LOG_IDD_dlg_liste_objets &&
					{_x getVariable ["R3F_LOG_CF_depuis_usine", false]} count nearestObjects [_usine, ["Mortar_01_base_F"], 200] != 0
				)
			};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			_statique = nearestObjects [_usine, ["Mortar_01_base_F"], 200] select 0;
			["M3_S2_CreerObjet"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			["M3_S2_ReposerObjet", "Release the mortar on the ground."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || isNull R3F_LOG_joueur_deplace_objet};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M3_S2_ReposerObjet"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			sleep 1;
			
			R3F_LOG_TUTO_module_state = "STEP3";
		};
		
		// Sélectionner la catégorie "Fortifications", créer un mur de sacs de sable ("Land_BagFence_Long_F")
		case "STEP3":
		{
			["M3_S3_OuvrirUsine", "Open the creation factory interface."] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M3_S3_OuvrirUsine"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			["M3_S3_SelectionnerCategorie", format ["Select the category ""%1"".", getText (configFile >> "CfgVehicleClasses" >> "Fortifications" >> "displayName")]] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil
			{
				if (isNull findDisplay R3F_LOG_IDD_dlg_liste_objets) then
				{
					["M3_S3_SelectionnerCategorie"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
					
					["M3_S3_OuvrirUsine", "Open the creation factory interface."] call R3F_LOG_TUTO_FNCT_creer_tache;
					waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
					if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
					["M3_S3_OuvrirUsine"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
					
					["M3_S3_SelectionnerCategorie", format ["Select the category ""%1"".", getText (configFile >> "CfgVehicleClasses" >> "Fortifications" >> "displayName")]] call R3F_LOG_TUTO_FNCT_creer_tache;
					waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
				};
				
				R3F_LOG_TUTO_module_state != _curr_step ||
				(
					!isNull findDisplay R3F_LOG_IDD_dlg_liste_objets && !isNil {_usine getVariable "R3F_LOG_CF_cfgVehicles_categories"} &&
					{
						(_usine getVariable "R3F_LOG_CF_cfgVehicles_categories") select
						(
							lbCurSel (findDisplay R3F_LOG_IDD_dlg_liste_objets displayCtrl R3F_LOG_IDC_dlg_LO_liste_categories)
						) == "Fortifications"
					}
				)
			};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M3_S3_SelectionnerCategorie"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			["M3_S3_CreerObjet", format ["Create a ""%1"".", getText (configFile >> "CfgVehicles" >> "Land_BagFence_Long_F" >> "displayName")]] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil
			{
				if (isNull findDisplay R3F_LOG_IDD_dlg_liste_objets) then
				{
					sleep 2;
					if ({_x getVariable ["R3F_LOG_CF_depuis_usine", false]} count nearestObjects [_usine, ["BagFence_base_F", "HBarrier_base_F"], 200] == 0) then
					{
						["M3_S3_CreerObjet"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
						
						["M3_S3_OuvrirUsine", "Open the creation factory interface."] call R3F_LOG_TUTO_FNCT_creer_tache;
						waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
						if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
						["M3_S3_OuvrirUsine"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
						
						["M3_S3_CreerObjet", format ["Create a ""%1"".", getText (configFile >> "CfgVehicles" >> "HMG_01_base_F" >> "displayName")]] call R3F_LOG_TUTO_FNCT_creer_tache;
						waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
					};
				};
				
				R3F_LOG_TUTO_module_state != _curr_step ||
				(
					isNull findDisplay R3F_LOG_IDD_dlg_liste_objets &&
					{_x getVariable ["R3F_LOG_CF_depuis_usine", false]} count nearestObjects [_usine, ["BagFence_base_F", "HBarrier_base_F"], 200] != 0
				)
			};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M3_S3_CreerObjet"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			waitUntil {!isNull R3F_LOG_joueur_deplace_objet};
			_sac_sable = R3F_LOG_joueur_deplace_objet;
			
			R3F_LOG_TUTO_module_state = "STEP4";
		};
		
		// Revendre le sac de sable, puis revendre le reste
		case "STEP4":
		{
			["M3_S4_RevendreDeplace", "Send back the bag fence to the factory."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || isNull _sac_sable};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M3_S4_RevendreDeplace", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			
			["M3_S4_RevendreDirect", "Send back the hunter to the factory."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || isNull _hunter};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M3_S4_RevendreDirect", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			
			["M3_S4_RevendreStatique", "Send back the mortar to the factory."] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || isNull _statique};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M3_S4_RevendreStatique"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			sleep 1;
			R3F_LOG_TUTO_module_state = "SUCCESS";
		};
		
		case "ABORT":
		{
			["MODULE ABORTED", 2] call R3F_LOG_TUTO_FNCT_afficher_centre;
			R3F_LOG_TUTO_module_state = "END";
		};
		
		case "SUCCESS":
		{
			player kbTell [player, "R3F_LOG_TUTO_kb_succes", "boot_m02_d01_hello_world_LAC_0"];
			["MODULE ACCOMPLISHED", 3] call R3F_LOG_TUTO_FNCT_afficher_centre;
			R3F_LOG_TUTO_module_state = "END";
		};
		
		case "END":
		{
			// Forcer la fermeture de l'interface de l'usine
			_usine setVariable ["R3F_LOG_CF_disabled", true];
			waitUntil {isNull findDisplay R3F_LOG_IDD_dlg_liste_objets};
			
			waitUntil {!isNull player && {alive player}};
			call R3F_LOG_TUTO_FNCT_vider_taches_hint;
			
			1010 cutText ["", "BLACK OUT"];
			sleep 1;
			player setPos _pos_avant_module;
			player setDir _dir_avant_module;
			sleep 1;
			1010 cutText ["", "BLACK IN"];
			
			// Suppression des créations faites avec l'usine
			{
				if (_x getVariable ["R3F_LOG_CF_depuis_usine", false]) then
				{
					deleteVehicle _x;
				};
			} forEach nearestObjects [_usine, ["All"], 200];
			
			[_joueur] call R3F_LOG_TUTO_FNCT_liberer_hangar;
			
			R3F_LOG_TUTO_module_state = "EXIT";
		};
		
		default
		{
			systemChat "ERROR: UNKNOW STATE ! END OF THE MODULE.";
			R3F_LOG_TUTO_module_state = "END";
		};
	};
};