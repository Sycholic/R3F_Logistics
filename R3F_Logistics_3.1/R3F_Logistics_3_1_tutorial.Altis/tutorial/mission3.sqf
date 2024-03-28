private ["_pos_mer", "_helipad", "_bateau", "_canot", "_civil", "_tab_civils", "_time_debut_ralli_PRG"];

_pos_mer = getMarkerPos "mission3";

_helipad = "Land_HelipadEmpty_F" createVehicle _pos_mer;
_helipad setPosASL [_pos_mer select 0, _pos_mer select 1, getTerrainHeightASL _pos_mer];

_bateau = "C_Boat_Civil_04_F" createVehicle _pos_mer;
_bateau attachTo [_helipad, [0, 0, -2-getTerrainHeightASL _pos_mer]];
_bateau setVectorDirAndUp [vectorNormalized [-0.151959,0.22035,-0.9635], vectorNormalized [-0.200744,0.899038,0.38915]];

_canot = "B_Lifeboat" createVehicle [14396.3, 15338.8, 0];
_canot addEventHandler ["HandleDamage", {0}];
_canot setFuel 0;
sleep 1;

// Création des civils et embarquement dfans le canot
{
	_civil = (createGroup west) createUnit [_x, getPos _canot, [], 0, "NONE"];
	_civil setCaptive true;
	sleep 1;
	removeHeadgear _civil;
	sleep 0.25;
	_civil moveInAny _canot;
	sleep 0.25;
} forEach
[
	"C_man_p_beggar_F_afro",
	"C_man_p_shorts_1_F_afro",
	"C_man_polo_1_F_asia",
	"C_man_polo_4_F_afro",
	"C_man_polo_6_F_euro"
];

_canot setPos (getMarkerPos "mission3" vectorAdd [55, 55, 0]);
_canot setDir 110;

// Attendre le retour sur la terre ferme
waitUntil
{
	sleep 3;
	!surfaceIsWater getPos _canot &&
	{
		isNull (_canot getVariable ["R3F_LOG_est_transporte_par", objNull]) &&
		_canot distance getMarkerPos "PRG_mission3" < 500 &&
		getPosATL _canot select 2 < 0.4 &&
		vectorMagnitude velocity _canot < 0.1
	}
};
sleep 30;

// Sortir du canot et rejoindre le PRG
_tab_civils = [];
{
	_x forceWalk true;
	unassignVehicle _x;
	_x leaveVehicle _canot;
	doGetOut _x;
	_x doMove getMarkerPos "PRG_mission3";
	_tab_civils pushBack _x;
	sleep 0.2;
} forEach crew _canot;

_time_debut_ralli_PRG = time;
while {count _tab_civils > 0} do
{
	// Suppression des civils lorsqu'ils arrivent au PRG (ou meurt ou sont trop long)
	{
		if (_x distance getMarkerPos "PRG_mission3" < 6 || time > _time_debut_ralli_PRG + 420) then
		{
			deleteVehicle _x;
			_tab_civils = _tab_civils - [_x];
			sleep (0.3 + random 0.7);
		};
	} forEach _tab_civils;
	
	sleep 3;
};

deleteVehicle _canot;
deleteVehicle _bateau;
deleteVehicle _helipad;

// Réinitialiser la mission
execVM "tutorial\mission3.sqf";