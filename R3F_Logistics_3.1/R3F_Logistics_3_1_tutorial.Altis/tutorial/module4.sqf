private ["_joueur", "_hangar", "_pos_avant_module", "_dir_avant_module", "_curr_step"];
private ["_helipad", "_helico", "_data_obj_ref", "_data_obj_fils", "_obj_crees", "_sous_marin", "_pos_mer"];

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
				
				_helipad = [
					"Land_HelipadCircle_F",
					_hangar,
					(_hangar getVariable "R3F_LOG_TUTO_helipad_degage") modelToWorld [0, -60, 0],
					getDir (_hangar getVariable "R3F_LOG_TUTO_helipad_degage"),
					false
				] call R3F_LOG_TUTO_FNCT_creer_objet;
				
				_helico = [
					"B_Heli_Transport_01_F",
					_hangar,
					getPos _helipad,
					getDir _helipad,
					false
				] call R3F_LOG_TUTO_FNCT_creer_objet;
				
				sleep 1;
				player setPos (_helico modelToWorld [-10, 2.5, 0]);
				player setDir (90+getDir _helico);
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
								) && _joueur distance (_hangar getVariable ["R3F_LOG_TUTO_helipad_degage", _joueur]) > 2200
							) then
							{
								if (
									!(
										-(40+R3F_LOG_TUTO_demi_largeur_hangar) < (_pos_rel_joueur select 0) && (_pos_rel_joueur select 0) < 40+R3F_LOG_TUTO_demi_largeur_hangar &&
										-(40+R3F_LOG_TUTO_demi_longueur_hangar) < (_pos_rel_joueur select 1) && (_pos_rel_joueur select 1) < 40+4.5*R3F_LOG_TUTO_demi_longueur_hangar
									) && _joueur distance (_hangar getVariable ["R3F_LOG_TUTO_helipad_degage", _joueur]) > 3000
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
		
		// Monter dans l'hélico et décoller
		case "STEP1":
		{
			["M4_S1_MonterHelico", "Get in the helicopter."] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || vehicle _joueur == _helico};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M4_S1_MonterHelico"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			_data_obj_ref = [
				"Land_HelipadEmpty_F",
				getPosASL (_hangar getVariable "R3F_LOG_TUTO_helipad_degage"),
				getDir (_hangar getVariable "R3F_LOG_TUTO_helipad_degage")
			];
			_data_obj_fils = [];
			_data_obj_fils pushBack ["B_SDV_01_F", [0,0,2.23], 0]; // _sous_marin
			_data_obj_fils pushBack ["Land_WoodenBox_F", [0,0.910156,-0.06], 0];
			_data_obj_fils pushBack ["Land_WoodenBox_F", [0,-2.28125,0], 0];
			
			_obj_crees = [_data_obj_ref, _data_obj_fils] call R3F_LOG_TUTO_FNCT_creer_decor_complexe;
			_hangar setVariable ["R3F_LOG_TUTO_tab_objets", ((_hangar getVariable ["R3F_LOG_TUTO_tab_objets", []]) + _obj_crees), true];
			
			_sous_marin = _obj_crees select 1;
			_sous_marin setVariable ["R3F_LOG_disabled", false, true];
			[_sous_marin, [0,0,-2.15]] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
			
			["M4_S1_Decoller", "Take off."] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil
			{
				if (vehicle _joueur != _helico) then
				{
					["M4_S1_Decoller"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
					["M4_S1_MonterHelico", "Get in the helicopter."] call R3F_LOG_TUTO_FNCT_creer_tache;
					waitUntil {R3F_LOG_TUTO_module_state != _curr_step || vehicle _joueur == _helico};
					if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
					["M4_S1_MonterHelico"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
					["M4_S1_Decoller", "Take off."] call R3F_LOG_TUTO_FNCT_creer_tache;
				};
				
				R3F_LOG_TUTO_module_state != _curr_step || (vehicle _joueur == _helico && getPosATL _helico select 2 > 2)
			};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M4_S1_Decoller"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			R3F_LOG_TUTO_module_state = "STEP2";
		};
		
		// Lifter le sous-marin
		case "STEP2":
		{
			["M4_S2_Heliporter", "Lift the submarine.", getPos _sous_marin] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || _helico getVariable ["R3F_LOG_heliporte", objNull] == _sous_marin};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M4_S2_Heliporter"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			// Recherche de la position de la plage dans la direction E-S-E
			for
			[
				{_pos_mer = getPos (_hangar getVariable "R3F_LOG_TUTO_helipad_degage")},
				{!surfaceIsWater _pos_mer},
				{_pos_mer = _pos_mer vectorAdd [15, -12, 0]}
			] do {};
			_pos_mer = _pos_mer vectorAdd [30, -24, 0];
			
			["M4_S2_RejoindreMer", "Go to the sea (south-east).", _pos_mer] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil
			{
				if (vehicle _joueur != _helico) then {R3F_LOG_TUTO_module_state = "ABORT";};
				
				if (isNull (_sous_marin getVariable ["R3F_LOG_est_transporte_par", objNull])) then
				{
					["M4_S2_RejoindreMer"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
					["M4_S2_Heliporter", "Lift the submarine.", getPos _sous_marin] call R3F_LOG_TUTO_FNCT_creer_tache;
					waitUntil {R3F_LOG_TUTO_module_state != _curr_step || _helico getVariable ["R3F_LOG_heliporte", objNull] == _sous_marin};
					if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
					["M4_S2_Heliporter"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
					["M4_S2_RejoindreMer", "Go to the sea (south-east).", _pos_mer] call R3F_LOG_TUTO_FNCT_creer_tache;
				};
				
				R3F_LOG_TUTO_module_state != _curr_step || surfaceIsWater getPos _helico
			};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			sleep 3;
			["M4_S2_RejoindreMer"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			["M4_S2_Larguer", "Drop the submarine in the sea.", _pos_mer] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			waitUntil
			{
				if (vehicle _joueur != _helico) then {R3F_LOG_TUTO_module_state = "ABORT";};
				R3F_LOG_TUTO_module_state != _curr_step || isNull (_sous_marin getVariable ["R3F_LOG_est_transporte_par", objNull])
			};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M4_S2_Larguer", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			
			["M4_S2_RejoindreHelipad", "Go back to the helipad.", getPos _helipad] call R3F_LOG_TUTO_FNCT_creer_tache;
			waitUntil
			{
				if (vehicle _joueur != _helico) then {R3F_LOG_TUTO_module_state = "ABORT";};
				R3F_LOG_TUTO_module_state != _curr_step || !surfaceIsWater getPos _helico
			};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			["M4_S2_RejoindreHelipad"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
			
			sleep 6;
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