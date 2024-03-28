private ["_joueur", "_hangar", "_pos_avant_module", "_dir_avant_module", "_curr_step"];
private ["_camion", "_avion"];

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
				
				_camion = [
					"B_Truck_01_mover_F",
					_hangar,
					(_hangar getVariable "R3F_LOG_TUTO_helipad_degage") modelToWorld [0, -95, 0],
					getDir (_hangar getVariable "R3F_LOG_TUTO_helipad_degage"),
					false
				] call R3F_LOG_TUTO_FNCT_creer_objet;
				
				sleep 1;
				player setPos (_camion modelToWorld [-8, -10, 0]);
				player setDir (45+getDir _camion);
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
		
		// Monter dans le camion, approcher l'avion et le remorquer
		case "STEP1":
		{
			["M5_S1_MonterCamion", "Get in the truck."] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || vehicle _joueur == _camion};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M5_S1_MonterCamion"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			_avion = [
				"B_Plane_CAS_01_F",
				_hangar,
				(_hangar getVariable "R3F_LOG_TUTO_helipad_degage") modelToWorld [0, 95, 0],
				60 + getDir (_hangar getVariable "R3F_LOG_TUTO_helipad_degage"),
				false
			] call R3F_LOG_TUTO_FNCT_creer_objet;
			_avion setDamage 0.75;
			[_avion] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
			
			["M5_S1_RejoindreAvion", "Go to the damaged airplane.", getPos _avion] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || _camion distance _avion < 75};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M5_S1_RejoindreAvion"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			_avion setVariable ["R3F_LOG_TUTO_fleche_rebondissante", false, true];
			
			["M5_S1_Remorquer", "Tow the airplane."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil
			{
				if (
					_avion getVariable ["R3F_LOG_est_transporte_par", objNull] != _camion &&
					vehicle _joueur == _joueur && cursorTarget == _avion &&
					{
						private ["_delta_pos"];
						
						_delta_pos =
						(
							_avion modelToWorld
							[
								boundingCenter _avion select 0,
								boundingBoxReal _avion select 1 select 1,
								boundingBoxReal _avion select 0 select 2
							]
						) vectorDiff (
							_camion modelToWorld
							[
								boundingCenter _camion select 0,
								boundingBoxReal _camion select 0 select 1,
								boundingBoxReal _camion select 0 select 2
							]
						);
						
						// L'arrière du remorqueur n'est PAS proche de l'avant de l'objet pointé
						!(abs (_delta_pos select 0) < 3 && abs (_delta_pos select 1) < 5)
					}
				) then
				{
					sleep 2.25;
					hintC "As you can see, the airplane is misaligned. Get in the truck to align it.";
					waitUntil {R3F_LOG_TUTO_module_state != _curr_step || vehicle _joueur == _camion || _avion getVariable ["R3F_LOG_est_transporte_par", objNull] == _camion};
				};
				
				R3F_LOG_TUTO_module_state != _curr_step || _avion getVariable ["R3F_LOG_est_transporte_par", objNull] == _camion
			};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			sleep 8;
			["M5_S1_Remorquer", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			
			sleep 2;
			R3F_LOG_TUTO_module_state = "STEP2";
		};
		
		// Remonter dans le camion et l'amener au point de départ et le décrocher
		case "STEP2":
		{
			["M5_S2_MonterCamion", "Get in the truck."] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || vehicle _joueur == _camion};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M5_S2_MonterCamion"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			[_hangar getVariable "R3F_LOG_TUTO_helipad_degage"] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
			
			["M5_S2_RejoindreDepart", "Go back to the start position.", getPos (_hangar getVariable "R3F_LOG_TUTO_helipad_degage")] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || _camion distance (_hangar getVariable "R3F_LOG_TUTO_helipad_degage") < 25};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M5_S2_RejoindreDepart"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			(_hangar getVariable "R3F_LOG_TUTO_helipad_degage") setVariable ["R3F_LOG_TUTO_fleche_rebondissante", false, true];
			
			["M5_S2_Detacher", "Detach the airplane."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || isNull (_avion getVariable ["R3F_LOG_est_transporte_par", objNull])};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			sleep 8;
			["M5_S2_Detacher", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			
			sleep 2;
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
			systemChat "ERROR: UNKNOW STATE ! END OF THE MODULE.";
			R3F_LOG_TUTO_module_state = "END";
		};
	};
};