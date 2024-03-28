/**
 * Crée un décor complexe composé d'un objet de référence et d'objets fils positionnés relativement à ce dernier.
 * @param 0 tableau d'informations sur l'objet de référence au format [classe, pos ASL, dir]
 * @param 1 liste des objets fils décrit par des tableaux d'informations au format [classe, pos relative, dir relative]
 * @param 2 (optionnel) true pour relocaliser le décor, false pour le créer sur la position de référence (défaut : false)
 * @param 3 (optionnel) position ATL où relocaliser le décor (défaut : 10m devant le joueur)
 * @param 4 (optionnel) nouvelle direction du décor (défaut : direction de référence)
 * @return tableau des objets créés contenant en premier l'objet de référence suivi des fils dans l'ordre
 */
R3F_LOG_TUTO_FNCT_creer_decor_complexe =
{
	private ["_data_obj_ref", "_data_obj_fils", "_relocaliser", "_nouvelle_position", "_obj_ref", "_tab_objets"];
	
	_data_obj_ref = _this select 0;
	_data_obj_fils = _this select 1;
	_relocaliser = if (count _this > 2) then {_this select 2} else {false};
	_nouvelle_position = if (count _this > 3) then {_this select 3} else {player modelToWorld [0, 10, 0]};
	_nouvelle_direction = if (count _this > 4) then {_this select 4} else {_data_obj_ref select 2};
	
	_tab_objets = [];
	
	if (_relocaliser) then
	{
		private ["_dh"];
		
		_dh = (_data_obj_ref select 1 select 2) - getTerrainHeightASL (_data_obj_ref select 1);
		_data_obj_ref set [1, ATLtoASL _nouvelle_position];
		(_data_obj_ref select 1) set [2, (_data_obj_ref select 1 select 2) + _dh];
		
		_data_obj_ref set [2, _nouvelle_direction];
	};
	
	_obj_ref = (_data_obj_ref select 0) createVehicle (_data_obj_ref select 1);
	_obj_ref setPosASL (_data_obj_ref select 1);
	_obj_ref setDir (_data_obj_ref select 2);
	_obj_ref setVectorUp [0, 0, 1];
	_obj_ref setVariable ["R3F_LOG_disabled", true, true];
	_tab_objets pushBack _obj_ref;
	sleep 0.02;
	
	{
		_classe = _x select 0;
		_rel_pos = _x select 1;
		_rel_dir = _x select 2;
		
		_obj_fils = _classe createVehicle getPos _obj_ref;
		_obj_fils attachTo [_obj_ref, _rel_pos];
		_obj_fils setDir _rel_dir;
		_obj_fils setVariable ["R3F_LOG_disabled", true, true];
		
		_tab_objets pushBack _obj_fils;
		
		sleep 0.02;
	} forEach _data_obj_fils;
	
	_tab_objets
};

/**
 * Crée un objet local pour le tutoriel (invicible et reconnu rapidement par la logistique)
 * @param 0 le nom de classe de l'objet à créer
 * @param 1 le hangar dans lequel créer l'objet
 * @param 2 la position relative au hangar ou absolue (voir param 4)
 * @param 3 (optionnel) la direction relative ou absolue (voir param 4)
 * @param 4 (optionnel) true si param 2 est une pos relative au hangar, false si pos absolue (défaut : true)
 * @return l'objet créé
 */
R3F_LOG_TUTO_FNCT_creer_objet =
{
	private ["_classe", "_hangar", "_pos_abs_rel", "_dir_abs_rel", "_objet", "_pos_abs", "_dir_abs"];
	
	_classe = _this select 0;
	_hangar = _this select 1;
	_pos_abs_rel = _this select 2;
	_dir_abs_rel = if (count _this > 3) then {_this select 3} else {0};
	_mode_abs_rel = if (count _this > 4) then {_this select 4} else {true};
	
	if (_mode_abs_rel) then
	{
		_pos_abs = _hangar modelToWorld [(_pos_abs_rel select 0) * R3F_LOG_TUTO_demi_largeur_hangar, (_pos_abs_rel select 1) * R3F_LOG_TUTO_demi_longueur_hangar, 0];
		_pos_abs set [2, 0];
		_dir_abs = _dir_abs_rel + getDir _hangar;
	}
	else
	{
		_pos_abs = _pos_abs_rel;
		_dir_abs = _dir_abs_rel;
	};
	
	_objet = _classe createVehicle _pos_abs;
	_objet setDir _dir_abs;
	_objet setPos _pos_abs;
	R3F_LOG_PUBVAR_nouvel_objet_a_initialiser = true;
	player reveal _objet;
	
	_hangar setVariable ["R3F_LOG_TUTO_tab_objets", ((_hangar getVariable ["R3F_LOG_TUTO_tab_objets", []]) + [_objet]), true];
	sleep 0.02;
	_objet
};

/**
 * Crée un flèche qui rebondit au dessus d'un objet pour le désigner
 * @param 0 l'objet au dessus duquel faire rebondir la flèche
 * @param 1 (optionnel) offset 3D de la flèche (défaut [0,0,0])
 */
R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante =
{
	// Demander une animation de la couleur chez tous les clients
	R3F_LOG_TUTO_PV_animer_fleche_rebondissante = _this;
	publicVariable "R3F_LOG_TUTO_PV_animer_fleche_rebondissante";
	["R3F_LOG_TUTO_PV_animer_fleche_rebondissante", R3F_LOG_TUTO_PV_animer_fleche_rebondissante] spawn R3F_LOG_TUTO_FNCT_PVEH_animer_fleche_rebondissante;
	waitUntil {(_this select 0) getVariable ["R3F_LOG_TUTO_fleche_rebondissante", false]};
};

/**
 * Fonction PVEH d'animation de la flèche rebondissante
 * @param 1 valeur de la PV
 * @param 1 select 0 l'objet au dessus duquel faire rebondir la flèche
 * @param 1 select 1 (optionnel) offset 3D de la flèche (défaut [0,0,0])
 */
R3F_LOG_TUTO_FNCT_PVEH_animer_fleche_rebondissante =
{
	if (!isDedicated) then
	{
		private ["_param"];
		
		_param = _this select 1;
		
		_param spawn
		{
			private ["_objet", "_fleche", "_x0", "_y0", "_h0", "_offset"];
			
			_objet = _this select 0;
			_offset = if (count _this > 1) then {_this select 1} else {[0,0,0]};
			
			_x0 = -(boundingCenter _objet select 0) + (_offset select 0);
			_y0 = -(boundingCenter _objet select 1) + (_offset select 1);
			_h0 = (boundingBoxReal _objet select 1 select 2) + (_offset select 2);
			
			_fleche = "Sign_Arrow_F" createVehicleLocal (_objet modelToWorld [_x0, _y0, _h0]);
			_h1 = boundingBoxReal _fleche select 1 select 2;
			
			_objet setVariable ["R3F_LOG_TUTO_fleche_rebondissante", true];
			
			while {!isNull _objet &&
				{
					_objet getVariable "R3F_LOG_TUTO_fleche_rebondissante" &&
					isNull (_objet getVariable ["R3F_LOG_est_deplace_par", objNull]) &&
					isNull (_objet getVariable ["R3F_LOG_est_transporte_par", objNull])
				}
			} do
			{
				_fleche setPos (_objet modelToWorld [_x0, _y0, _h0 + 0.7*_h1 * (1 + cos (220*time))]);
				_fleche setDir (getDir _fleche + 2);
				
				sleep 0.0125;
			};
			
			deleteVehicle _fleche;
		};
	};
};
"R3F_LOG_TUTO_PV_animer_fleche_rebondissante" addPublicVariableEventHandler R3F_LOG_TUTO_FNCT_PVEH_animer_fleche_rebondissante;

/**
 * Crée un objet hologramme d'objet local pour le tutoriel
 * @param 0 le nom de classe de l'objet à créer
 * @param 1 le hangar dans lequel créer l'objet
 * @param 2 la position relative dans le hangar
 * @param 3 (optionnel) la direction relative ou absolue (voir param 4)
 * @param 4 (optionnel) true si param 2 est une pos relative au hangar, false si pos absolue (défaut : true)
 * @param 5 (optionnel) true pour animer une flèche au dessus de l'objet (défaut : false)
 * @param 6 (optionnel) éventuel offset 3D de la flèche animée (défaut : [0,0,0])
 * @return l'objet créé
 */
R3F_LOG_TUTO_FNCT_creer_hologramme_objet =
{
	private ["_classe", "_hangar", "_objet", "_animer_fleche", "_offset"];
	
	_classe = _this select 0;
	_hangar = _this select 1;
	_animer_fleche = if (count _this > 5) then {_this select 5} else {false};
	_offset = if (count _this > 6) then {_this select 6} else {[0,0,0]};
	
	_objet = _this call R3F_LOG_TUTO_FNCT_creer_objet;
	_objet enableSimulation false;
	_objet setVariable ["R3F_LOG_disabled", true];
	sleep 0.02;
	_objet attachTo [_hangar, _hangar worldToModel (_objet modelToWorld [0,0,0])];
	
	// Demander une animation de la couleur chez tous les clients
	R3F_LOG_TUTO_PV_animer_hologramme = _objet;
	publicVariable "R3F_LOG_TUTO_PV_animer_hologramme";
	["R3F_LOG_TUTO_PV_animer_hologramme", R3F_LOG_TUTO_PV_animer_hologramme] spawn R3F_LOG_TUTO_FNCT_PVEH_animer_hologramme;
	
	if (_animer_fleche) then
	{
		[_objet, _offset] call R3F_LOG_TUTO_FNCT_creer_fleche_rebondissante;
	};
	
	_objet
};

/**
 * Fonction PVEH d'animation de la couleur d'un hologramme
 * @param 1 l'objet à animer (valeur de la PV)
 */
R3F_LOG_TUTO_FNCT_PVEH_animer_hologramme =
{
	if (!isDedicated) then
	{
		private ["_objet"];
		
		_objet = _this select 1;
		
		_objet spawn
		{
			while {!isNull _this} do
			{
				private ["_couleur", "_i"];
				
				_couleur = if (floor (2*diag_tickTime) % 2 == 0) then {"0.42,0.74,0.46,1.00"} else {"0.76,0.21,0.00,1.00"};
				
				for [{_i = 0}, {_i < 4}, {_i = _i+1}] do
				{
					_this setObjectTexture [_i, format ["#(rgb,8,8,3)color(%1)", _couleur]];
				};
				
				sleep 0.1;
			};
		};
	};
};
"R3F_LOG_TUTO_PV_animer_hologramme" addPublicVariableEventHandler R3F_LOG_TUTO_FNCT_PVEH_animer_hologramme;