private ["_tab_hangars"];

// Suppression des cadavres des joueurs déconnectés
addMissionEventHandler ["HandleDisconnect", {deleteVehicle (_this select 0); false}];

call compile preprocessFile "tutorial\creation_decors.sqf";

_tab_hangars = [];

// Initialisation des hangars générés entre _pos_debut et _pos_fin
{
	private ["_pos", "_dir", "_pos_degagee", "_hangar"];
	
	_pos = _x select 0;
	_dir = _x select 1;
	_pos_degagee = _x select 2;
	
	_hangar = "Land_Shed_Big_F" createVehicle _pos;
	_hangar setDir _dir;
	_hangar setPos _pos;
	_hangar setVectorUp [0, 0, 1];
	_hangar setVariable ["R3F_LOG_disabled", true, true];
	
	_pos2 = _hangar modelToWorld
	[
		0,
		(boundingBoxReal _hangar select 1 select 1) - (boundingBoxReal _hangar select 0 select 1) - 0.4,
		boundingBoxReal _hangar select 0 select 2
	];
	_hangar2 = "Land_Shed_Big_F" createVehicle _pos2;
	_hangar2 setDir _dir;
	_pos2 set [2, getPosASL _hangar select 2];
	_hangar2 setPosASL _pos2;
	_hangar2 setVectorUp [0, 0, 1];
	_hangar2 setVariable ["R3F_LOG_disabled", true, true];
	
	_helipad_degage = "Land_HelipadEmpty_F" createVehicle _pos_degagee;
	_helipad_degage setDir 0;
	_helipad_degage setPos _pos_degagee;
	_helipad_degage setVectorUp [0, 0, 1];
	_helipad_degage setVariable ["R3F_LOG_disabled", true, true];
	
	/** Référence vers l'hélipad au centre de la position dégagée associée au hangar */
	_hangar setVariable ["R3F_LOG_TUTO_helipad_degage", _helipad_degage, true];
	
	/** Joueur ayant réservé l'accès au hangar, objNull si libre */
	_hangar setVariable ["R3F_LOG_TUTO_reserve_par", objNull, true];
	
	/** Liste des objets créés dans le hangar pour le module */
	_hangar setVariable ["R3F_LOG_TUTO_tab_objets", [], true];
	
	_tab_hangars pushBack _hangar;
} forEach [
	// [pos, dir, pos dégagée]
	[[13980.6,16233.60,0.0014801], 323, [23300, 17500, 0]],
	[[13919.00,16155.40,0.271690], 321, [23300, 17900, 0]],
	[[13864.2,15936.40,-0.137161], 315, [23300, 18300, 0]],
	[[14004.2,15960.40,-0.112938], 322, [23300, 18700, 0]],
	[[14009.4,15750.5,0.00149345], 320, [23700, 17500, 0]],
	[[13672.4,15943.8,0.00393486], 352, [23700, 17900, 0]],
	[[13528.3,15837.6,0.00117874], 350, [23700, 18300, 0]],
	[[15516.9,16910.9,0.00143433], 322, [23700, 18700, 0]],
	[[11748.8,14518.7,0.00131798], 316, [24100, 18700, 0]]
];

/** Liste publique des objets invisibles positionnées au centre de chaque hangar et stockant ses données associées */
R3F_LOG_TUTO_tab_hangars = + _tab_hangars;

// Partage des hangars aux joueurs
publicVariable "R3F_LOG_TUTO_tab_hangars";

execVM "tutorial\mission3.sqf";