call compile preprocessFile "tutorial\lib_creation.sqf";

if (isServer) then
{
	execVM "tutorial\init_server.sqf";
};

if (!isDedicated) then
{
	private ["_tableau"];
	
	// Ecran noir le temps que le serveur crée le décor et que le client charge la texture du tableau
	0 spawn
	{
		private ["_ctrl_precharger"];
		
		disableSerialization;
		waitUntil {!isNull findDisplay 46};
		
		1010 cutText ["", "BLACK OUT", 0.001];
		sleep 0.001;
		
		_ctrl_precharger = findDisplay 46 ctrlCreate ["RscPicture", -1];
		_ctrl_precharger ctrlSetPosition [0, 0, 0, 0];
		_ctrl_precharger ctrlSetText "tutorial\img\tableau_instruction.jpg";
		_ctrl_precharger ctrlCommit 0;
		sleep 10;
		ctrlDelete _ctrl_precharger;
	};
	
	call compile preprocessFile "tutorial\lib_module.sqf";
	
	waitUntil {!isNull player};
	[player] joinSilent grpNull;
	
	// Préchargement de la texture JPEG du tableau
	_tableau = "Land_MapBoard_F" createVehicleLocal [14184.9,16268.4,19.5878];
	_tableau setPosASL [14184.9,16268.4,19.5878];
	_tableau setDir 193.951;
	_tableau setVariable ["R3F_LOG_disabled", true];
	_tableau setObjectTexture [0, "tutorial\img\tableau_instruction.jpg"];
	
	// Ajoute les actions (appel à l'init et à chaque respawn)
	R3F_LOG_TUTO_FNCT_addAction_joueur =
	{
		player addAction [("<t color=""#cc0000"">Abort the module</t>"), {if (["Abort the module ?", "Confirm ?", true, true] call BIS_fnc_GUImessage) then {R3F_LOG_TUTO_module_state = "ABORT";};}, nil, 3, false, true, "", "vehicle _this == vehicle _target && (!isNil ""R3F_LOG_TUTO_module_state"" && {!(R3F_LOG_TUTO_module_state in [""ABORT"", ""SUCCESS"", ""END"", ""EXIT""])})"];
	};
	
	player addEventHandler ["Respawn", R3F_LOG_TUTO_FNCT_addAction_joueur];
	call R3F_LOG_TUTO_FNCT_addAction_joueur;
	call R3F_LOG_TUTO_FNCT_definir_taches_mission;
	
	player createDiaryRecord
	[
		"Diary",
		[
			"[R3F] Logistics tutorial",
			"Welcome to the [R3F] Logistics tutorial mission.<br />" +
			"<br />" +
			"Your drill sergeant will explain how to use logistics thanks to several thematic modules.<br />" +
			"<br />" +
			"When you will be trained, you could accomplish scenarios with your team.<br />" +
			"<br />" +
			"Scenarios are free : no ennemy, no trigger, no success condition.<br />" +
			"The ZEUS slot allows to make your own scenarios.<br />" +
			"Take your time, discover logistics."
		]
	];
	
	// Préchargement des topics. C'est le joueur qui parle à la place de l'instructeur pour des raisons de localité.
	player kbAddtopic ["R3F_LOG_TUTO_kb_hors_zone", getText (configfile >> "CfgSentences" >> "Zone_Restriction" >> "Warn_Has_Leader" >> "file")];
	player kbAddtopic ["R3F_LOG_TUTO_kb_intro", getText (configfile >> "CfgSentences" >> "BOOT_m02" >> "15_Introduction" >> "file")];
	player kbAddtopic ["R3F_LOG_TUTO_kb_succes", getText (configfile >> "CfgSentences" >> "BOOT_m02" >> "d01_Hello_World" >> "file")];
	
	waitUntil {!isNil "R3F_LOG_TUTO_AI_instructeur2" && {!isNull R3F_LOG_TUTO_AI_instructeur2}};
	
	["ContactInstructeur", "Join the drill sergeant", getPos R3F_LOG_TUTO_AI_instructeur2] call R3F_LOG_TUTO_FNCT_creer_tache;
	
	R3F_LOG_TUTO_AI_instructeur2 addAction [("<t color=""#00e900"">Choose what to do</t>"), {createDialog "R3F_LOG_TUTO_dlg_tableau";}, nil, 3, true, true, "", "_this distance _target < 5 && (isNil ""R3F_LOG_TUTO_module_state"" || {R3F_LOG_TUTO_module_state == ""EXIT""})"];
	_tableau addAction [("<t color=""#00e900"">Choose what to do</t>"), {createDialog "R3F_LOG_TUTO_dlg_tableau";}, nil, 3, true, true, "", "_this distance _target < 5 && (isNil ""R3F_LOG_TUTO_module_state"" || {R3F_LOG_TUTO_module_state == ""EXIT""})"];
	
	sleep 1;
	
	// Flèche rebondissante locale seulement
	R3F_LOG_TUTO_PV_animer_fleche_rebondissante = [R3F_LOG_TUTO_AI_instructeur2];
	["R3F_LOG_TUTO_PV_animer_fleche_rebondissante", R3F_LOG_TUTO_PV_animer_fleche_rebondissante] spawn R3F_LOG_TUTO_FNCT_PVEH_animer_fleche_rebondissante;
	sleep 2;
	
	// Attente de réception des hangars créés par le serveur
	waitUntil {sleep 0.1; !isNil "R3F_LOG_TUTO_tab_hangars"};
	
	/** Paramètres géométriques des hangars */
	R3F_LOG_TUTO_demi_largeur_hangar = boundingBoxReal (R3F_LOG_TUTO_tab_hangars select 0) select 1 select 0;
	R3F_LOG_TUTO_demi_longueur_hangar = boundingBoxReal (R3F_LOG_TUTO_tab_hangars select 0) select 1 select 1;
	R3F_LOG_TUTO_plancher_hangar = boundingBoxReal (R3F_LOG_TUTO_tab_hangars select 0) select 0 select 2;
	
	// Fin d'initialisation serveur et client, on lève le voile noir
	1010 cutText ["", "BLACK IN", 3];
	sleep 1.5;
	
	["ContactInstructeur"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
	["ContactInstructeurRefresh", "Join the drill sergeant.", getPos R3F_LOG_TUTO_AI_instructeur2] call R3F_LOG_TUTO_FNCT_creer_tache;
	
	// Objectif accompli et suppression de la flèche lorsque l'on s'approche de l'instructeur
	waitUntil {sleep 0.5; player distance R3F_LOG_TUTO_AI_instructeur2 < 3.5};
	sleep 0.5;
	R3F_LOG_TUTO_AI_instructeur2 setVariable ["R3F_LOG_TUTO_fleche_rebondissante", false];
	["ContactInstructeurRefresh"] call R3F_LOG_TUTO_FNCT_supprimer_tache;
	["R3F_LOG_TUTO_kb_intro", "boot_m02_15_introduction_ADA_0"] call R3F_LOG_TUTO_FNCT_kbTell_instructeur;
	
	// A chaque fois que l'on s'approche de l'instructeur, le menu s'ouvre
	while {true} do
	{
		sleep 0.5;
		["ChoixActivite", "Choose what to do", getPos R3F_LOG_TUTO_AI_instructeur2] call R3F_LOG_TUTO_FNCT_creer_tache;
		if (!dialog) then {createDialog "R3F_LOG_TUTO_dlg_tableau";};
		
		waitUntil {sleep 1; player distance R3F_LOG_TUTO_AI_instructeur2 > 5.5};
		waitUntil {sleep 1; player distance R3F_LOG_TUTO_AI_instructeur2 < 3.5};
		sleep 1.5;
		
		["R3F_LOG_TUTO_kb_succes", "boot_m02_d01_hello_world_ADA_0"] call R3F_LOG_TUTO_FNCT_kbTell_instructeur;
		sleep 0.5;
	};
};