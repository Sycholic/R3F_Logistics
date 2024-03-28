private ["_joueur", "_hangar", "_pos_avant_module", "_dir_avant_module", "_curr_step"];
private ["_uav", "_quad", "_camion", "_sac", "_mortier", "_caisse", "_hologramme"];

// Empêcher de lancer plusieurs modules en même temps
if (!isNil "R3F_LOG_TUTO_module_state" && {R3F_LOG_TUTO_module_state != "EXIT"}) exitWith
{
	systemChat "ERROR: A MODULE IS ALREADY RUNNING. ENDING IT.";
	R3F_LOG_TUTO_module_state = "END";
};

R3F_LOG_TUTO_num_exec_module = R3F_LOG_TUTO_num_exec_module + 1;

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
				
				_uav = ["B_UAV_01_F", _hangar, [0,-0.427617,0]] call R3F_LOG_TUTO_FNCT_creer_objet;
				_quad = ["B_Quadbike_01_F", _hangar, [0,0.440907,0]] call R3F_LOG_TUTO_FNCT_creer_objet;
				_camion = ["B_Truck_01_box_F", _hangar, [-0.552441,2.55248,0]] call R3F_LOG_TUTO_FNCT_creer_objet;
				
				_uav allowDamage false;
				
				sleep 1;
				_joueur setPos (_hangar modelToWorld [0 * R3F_LOG_TUTO_demi_largeur_hangar, -1 * R3F_LOG_TUTO_demi_longueur_hangar, R3F_LOG_TUTO_plancher_hangar]);
				_joueur setDir getDir _hangar;
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
				
				sleep 1;
				R3F_LOG_TUTO_module_state = "STEP1";
			}
			else
			{
				hintC "No free slot to do the module ! Wait that a player finish his module and try again.";
				R3F_LOG_TUTO_module_state = "EXIT";
			};
		};
		
		// Prendre le drone et le charger dans le quad, puis monter dedans
		case "STEP1":
		{
			[_uav] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
			["M2_S1_PrendreObjet", "Take the mini-uav."] call R3F_LOG_TUTO_FNCT_creer_tache;
			
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || R3F_LOG_joueur_deplace_objet == _uav || _uav in (_quad getVariable ["R3F_LOG_objets_charges", []])};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			
			["M2_S1_PrendreObjet"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			[_quad, [0, 0, -1.8]] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
			["M2_S1_ChargerDeplace", "Load the mini-uav in the quad bike."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			
			// Supprimer la possibilité d'être remorqué au quad
			waitUntil {!isNil {_quad getVariable "R3F_LOG_fonctionnalites"}};
			sleep 2;
			_fonctionnalites = _quad getVariable "R3F_LOG_fonctionnalites";
			_fonctionnalites set [R3F_LOG_IDX_can_be_towed, false];
			_quad setVariable ["R3F_LOG_fonctionnalites", _fonctionnalites];
			
			waitUntil
			{
				if (isNull R3F_LOG_joueur_deplace_objet && !(_uav in (_quad getVariable ["R3F_LOG_objets_charges", []]))) then
				{
					hintC "You didn't use the right action. Take again the mini-uav and use the ""load"" action while aiming the quad bike.";
					["M2_S1_ChargerDeplace"] call R3F_LOG_TUTO_FNCT_afficher_hint;
					waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull R3F_LOG_joueur_deplace_objet || _uav in (_quad getVariable ["R3F_LOG_objets_charges", []])};
				};
				
				R3F_LOG_TUTO_module_state != _curr_step || _uav in (_quad getVariable ["R3F_LOG_objets_charges", []])
			};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			
			["M2_S1_ChargerDeplace", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			
			["M2_S1_MonterQuad", "Get in the quad bike."] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || vehicle _joueur == _quad || _quad in (_camion getVariable ["R3F_LOG_objets_charges", []])};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			_quad setVariable ["R3F_LOG_TUTO_fleche_rebondissante", false, true];
			["M2_S1_MonterQuad"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			R3F_LOG_TUTO_module_state = "STEP2";
		};
		
		// Déplacer le quad, le sélectionner et le charger dans le camion
		case "STEP2":
		{
			[_camion, [0, -13.5, -4]] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
			["M2_S2_DeplacerQuad", "Move the quad bike behind the truck."] call R3F_LOG_TUTO_FNCT_creer_tache;
			
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || (_quad distance _camion < 12 && vectorMagnitude velocity _quad < 0.05) || _quad in (_camion getVariable ["R3F_LOG_objets_charges", []])};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			
			_camion setVariable ["R3F_LOG_TUTO_fleche_rebondissante", false, true];
			["M2_S2_DeplacerQuad"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			["M2_S2_DescendreQuad", "Get out of the quad bike."] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || vehicle _joueur == _joueur || _quad in (_camion getVariable ["R3F_LOG_objets_charges", []])};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M2_S2_DescendreQuad"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			["M2_S2_ChargerSelection", "Load the quad bike in the truck."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || _quad in (_camion getVariable ["R3F_LOG_objets_charges", []])};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			sleep 2.5;
			["M2_S2_ChargerSelection", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			
			R3F_LOG_TUTO_module_state = "STEP3";
		};
		
		// Charger les trois objets dans le camion puis partir avec (le camion se téléporte en zone dégagée)
		case "STEP3":
		{
			_sac = ["Land_BagFence_Round_F", _hangar, [0.156188,2.2623,0], 90] call R3F_LOG_TUTO_FNCT_creer_objet;
			_mortier = ["B_Mortar_01_F", _hangar, [0.365884,2.2691,0], -90] call R3F_LOG_TUTO_FNCT_creer_objet;
			_caisse = ["Box_NATO_AmmoOrd_F", _hangar, [0.411679,2.41551,0], -90] call R3F_LOG_TUTO_FNCT_creer_objet;
			
			["M2_S3_ChargerTous", "Load the three other objects in the truck.", getPos _mortier] call R3F_LOG_TUTO_FNCT_creer_tache;
			[_mortier] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || {_x in (_camion getVariable ["R3F_LOG_objets_charges", []])} count [_sac, _mortier, _caisse] == 3};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			sleep 2;
			["M2_S3_ChargerTous", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			
			["M2_S3_AvancerCamion", "Get in the truck and drive forward."] call R3F_LOG_TUTO_FNCT_creer_tache;
			
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || vehicle _joueur == _camion};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			_hologramme = ["Land_HelipadEmpty_F", _hangar, [-0.33, 5], 0, true, true] call R3F_LOG_TUTO_FNCT_creer_hologramme_objet;
			
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || vectorMagnitude velocity _camion > 5 || _camion distance _hologramme < 12};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			
			sleep 1.5;
			1010 cutText ["", "BLACK OUT", 0.5];
			sleep 0.5;
			
			[_hangar getVariable "R3F_LOG_TUTO_helipad_degage"] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
			["M2_S3_AvancerCamion", getPos (_hangar getVariable "R3F_LOG_TUTO_helipad_degage")] call R3F_LOG_TUTO_FNCT_set_destination_tache;
			
			_vitesse = vectorMagnitude velocity vehicle _joueur;
			vehicle _joueur setPos ((_hangar getVariable "R3F_LOG_TUTO_helipad_degage") modelToWorld [0, -60, 0]);
			vehicle _joueur setDir getDir (_hangar getVariable "R3F_LOG_TUTO_helipad_degage");
			sleep 0.02;
			vehicle _joueur setVelocity (vectorDir vehicle _joueur vectorMultiply _vitesse);
			
			sleep 0.5;
			1010 cutText ["", "BLACK IN", 0.5];
			
			if (vehicle _joueur != _camion) exitWith {R3F_LOG_TUTO_module_state = "ABORT";};
			
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || (vectorMagnitude velocity _camion < 0.05 && _camion distance (_hangar getVariable "R3F_LOG_TUTO_helipad_degage") < 20)};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			
			(_hangar getVariable "R3F_LOG_TUTO_helipad_degage") setVariable ["R3F_LOG_TUTO_fleche_rebondissante", false, true];
			["M2_S3_AvancerCamion"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			R3F_LOG_TUTO_module_state = "STEP4";
		};
		
		// Décharger tout le contenu du camion
		case "STEP4":
		{
			["M2_S4_DescendreCamion", "Get out of the truck."] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || vehicle _joueur == _joueur};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M2_S4_DescendreCamion"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			sleep 1;
			
			["M2_S4_Decharger", "Unload all the truck's cargo."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || {_x in (_camion getVariable ["R3F_LOG_objets_charges", []])} count [_sac, _mortier, _caisse, _quad] == 0};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M2_S4_Decharger", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			
			R3F_LOG_TUTO_module_state = "STEP5";
		};
		
		// Monter dans le quad, partir avec
		case "STEP5":
		{
			["M2_S5_MonterQuad", "Get in the quad bike."] call R3F_LOG_TUTO_FNCT_creer_tache;
			[_quad, [0, 0, -1.8]] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || vehicle _joueur == _quad};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			_quad setVariable ["R3F_LOG_TUTO_fleche_rebondissante", false, true];
			["M2_S5_MonterQuad"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			["M2_S5_AvancerQuad", "Move the quad bike to the destination.", (_hangar getVariable "R3F_LOG_TUTO_helipad_degage") modelToWorld [40, 90, 0]] call R3F_LOG_TUTO_FNCT_creer_tache;
			[_hangar getVariable "R3F_LOG_TUTO_helipad_degage", [40, 90, 0]] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || _quad distance _camion > 88};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			sleep 1;
			
			(_hangar getVariable "R3F_LOG_TUTO_helipad_degage") setVariable ["R3F_LOG_TUTO_fleche_rebondissante", false, true];
			["M2_S5_AvancerQuad"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			["M2_S5_DescendreQuad", "Get out of the quad bike."] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || vehicle _joueur == _joueur};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M2_S5_DescendreQuad"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			["M2_S5_Decharger", "Unload the mini-uav from the quad bike."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !(_uav in (_quad getVariable ["R3F_LOG_objets_charges", []]))};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M2_S5_Decharger"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			["M2_S5_ReposerUav", "Release the mini-uav on the ground."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || isNull R3F_LOG_joueur_deplace_objet};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M2_S5_ReposerUav", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			
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
			waitUntil {!isNull player && {alive player}};
			call R3F_LOG_TUTO_FNCT_vider_taches_hint;
			
			1010 cutText ["", "BLACK OUT"];
			sleep 1;
			player setPos _pos_avant_module;
			player setDir _dir_avant_module;
			sleep 1;
			1010 cutText ["", "BLACK IN"];
			
			[_joueur] call R3F_LOG_TUTO_FNCT_liberer_hangar;
			
			R3F_LOG_TUTO_module_state = "EXIT";
		};
		
		default
		{
			systemChat "UNKNOW STATE ! END OF THE MODULE.";
			R3F_LOG_TUTO_module_state = "END";
		};
	};
};