private ["_joueur", "_hangar", "_pos_avant_module", "_dir_avant_module", "_curr_step"];
private ["_destination_statique", "_caisse", "_statique", "_hologramme"];

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
				
				// Création du décor de sac de sable pour le STEP2
				_data_obj_ref = ["Land_BagFence_Round_F", [14219.2,16227.8,19.8479], 282.738];
				_data_obj_fils = [];
				_data_obj_fils pushBack ["Land_HelipadEmpty_F", [-0.232422,1.0332,1.59094], -184.506]; // _destination_statique (B_HMG_01_high_F)
				_data_obj_fils pushBack ["Land_BagFence_Round_F", [0.0390625,0.0898438,0.697067], -2.36108];
				_data_obj_fils pushBack ["Land_BagFence_Short_F", [-2.08594,0.530273,0.244858], -170.415];
				_data_obj_fils pushBack ["Land_BagFence_Short_F", [-2.03906,0.476563,1.07166], 9.59543];
				_data_obj_fils pushBack ["Land_BagFence_Short_F", [2.05078,0.418945,0.256897], -5.06717];
				_data_obj_fils pushBack ["Land_BagFence_Short_F", [2.00391,0.445313,1.02057], -187.321];
				_data_obj_fils pushBack ["Land_Ammobox_rounds_F", [1.78906,1.31348,-3.05176e-005], -280.897];
				_data_obj_fils pushBack ["Land_Ammobox_rounds_F", [1.99414,1.34082,-0.00482178], -277.259];
				_data_obj_fils pushBack ["Land_Ammobox_rounds_F", [1.91797,1.32227,0.21], -59.828];
				_data_obj_fils pushBack ["Land_CampingChair_V2_F", [-1.45313,1.53223,0.44], -121.84];
				_data_obj_fils pushBack ["Land_PortableLongRangeRadio_F", [-1.38969,1.74184,0.46], -102.459];
				_data_obj_fils pushBack ["Land_Canteen_F", [-1.27625,1.54184,0.59], -157.136];
				_data_obj_fils pushBack ["Land_PowderedMilk_F", [-1.48625,1.55043,0.47], -221.997];
				
				_pos_decor = _hangar modelToWorld [0 * R3F_LOG_TUTO_demi_largeur_hangar, 2.3 * R3F_LOG_TUTO_demi_longueur_hangar, 0];
				_pos_decor set [2, 0];
				
				_obj_crees = [_data_obj_ref, _data_obj_fils, true, _pos_decor, getDir _hangar + 180] call R3F_LOG_TUTO_FNCT_creer_decor_complexe;
				_hangar setVariable ["R3F_LOG_TUTO_tab_objets", ((_hangar getVariable ["R3F_LOG_TUTO_tab_objets", []]) + _obj_crees), true];
				
				_destination_statique = _obj_crees select 1;
				
				_caisse = ["Box_NATO_Wps_F", _hangar, [0, -0.3]] call R3F_LOG_TUTO_FNCT_creer_objet;
				
				sleep 1;
				player setPos (_hangar modelToWorld [0 * R3F_LOG_TUTO_demi_largeur_hangar, -1 * R3F_LOG_TUTO_demi_longueur_hangar, R3F_LOG_TUTO_plancher_hangar]);
				player setDir getDir _hangar;
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
		
		// Prendre une caisse de munition et la reposer plus loin
		case "STEP1":
		{
			[_caisse] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
			
			["M1_S1_PrendreObjet", "Take the ammunition crate in front of you."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || R3F_LOG_joueur_deplace_objet == _caisse};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			
			_hologramme = ["Box_NATO_Wps_F", _hangar, [0, 0.6], 0, true, true] call R3F_LOG_TUTO_FNCT_creer_hologramme_objet;
			["M1_S1_PrendreObjet", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			sleep 3;
			["M1_S1_RelacherObjet", "Bring the crate to the hologram and release it."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || (isNull R3F_LOG_joueur_deplace_objet && _caisse distance _hologramme < 2.5)};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			
			_caisse setVariable ["R3F_LOG_disabled", true];
			deleteVehicle _hologramme;
			["M1_S1_RelacherObjet", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			
			R3F_LOG_TUTO_module_state = "STEP2";
		};
		
		// Prendre une mitrailleuse fixe et l'orienter correctement sur une fortification
		case "STEP2":
		{
			_statique = ["B_HMG_01_high_F", _hangar, [0, 1.2]] call R3F_LOG_TUTO_FNCT_creer_objet;
			_statique setDir (160 + getDir _hangar);
			[_statique, [0, 0, -1.8]] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
			
			waitUntil {R3F_LOG_TUTO_module_state != _curr_step || R3F_LOG_joueur_deplace_objet == _statique};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			
			[_destination_statique, [0, 0, -0.15]] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
			["M1_S2_OrienterObjet", "Place the machine gun behind the bags fence."] call R3F_LOG_TUTO_FNCT_creer_tache_hint;
			
			waitUntil
			{
				// Si le joueur a relaché la statique au bon endroit mais mal orienté
				if (
					isNull R3F_LOG_joueur_deplace_objet &&
					{
						_statique distance _destination_statique < 1 &&
						((vectorDir _statique) vectorDotProduct (vectorDir _destination_statique)) <= 0.65
					}
				) then
				{
					hintC format ["You must orient the machine gun toward to %1°.", 10 * round (0.1*getDir _hangar)];
					["M1_S2_OrienterObjet"] call R3F_LOG_TUTO_FNCT_afficher_hint;
					waitUntil {R3F_LOG_TUTO_module_state != _curr_step || !isNull R3F_LOG_joueur_deplace_objet};
				};
				
				R3F_LOG_TUTO_module_state != _curr_step ||
				(
					isNull R3F_LOG_joueur_deplace_objet &&
					{
						_statique distance _destination_statique < 1 &&
						((vectorDir _statique) vectorDotProduct (vectorDir _destination_statique)) > 0.65
					}
				)
			};
			if (R3F_LOG_TUTO_module_state != _curr_step) exitWith {};
			
			_destination_statique setVariable ["R3F_LOG_TUTO_fleche_rebondissante", false, true];
			["M1_S2_OrienterObjet", "SUCCEEDED"] call R3F_LOG_TUTO_FNCT_set_statut_tache;
			
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