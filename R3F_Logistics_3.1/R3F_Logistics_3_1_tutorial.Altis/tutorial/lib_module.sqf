/** Compteur incrémental identifiant de manière unique l'exécution courante du module, dans le but de générer des noms de tâches uniques. */
R3F_LOG_TUTO_num_exec_module = 0;

/** Instant du dernier kbTell effectué par l'instructeur parmi tous les joueurs */
R3F_LOG_TUTO_time_dernier_kbTell = -1E39;
/** Réception de l'information qu'un kbTell est réalisé par l'instructeur */
"R3F_LOG_TUTO_PV_nouveau_kbTell" addPublicVariableEventHandler {R3F_LOG_TUTO_time_dernier_kbTell = time;};

/**
 * Réception de l'information de lancement d'une mission
 * @param 1 valeur de la PV représentant le numéro de la mission lancée
 */
R3F_LOG_TUTO_FNCT_PVEH_nouvelle_mission =
{
	private ["_num_mission"];
	
	_num_mission = _this select 1;
	
	// Si pas de module en cours, le joueur est invité à rejoindre la mission
	if (isNil "R3F_LOG_TUTO_module_state" || {R3F_LOG_TUTO_module_state == "EXIT"}) then
	{
		[format ["R3F_LOG_TUTO_mission%1_%2_%3", _num_mission, R3F_LOG_TUTO_num_exec_module, getPlayerUID player], "ASSIGNED", true] call BIS_fnc_taskSetState;
		[format ["MISSION %1 STARTED", _num_mission], 3] spawn R3F_LOG_TUTO_FNCT_afficher_centre;
	};
};
"R3F_LOG_TUTO_PV_nouvelle_mission" addPublicVariableEventHandler R3F_LOG_TUTO_FNCT_PVEH_nouvelle_mission;

/**
 * Fait parler l'instructeur, uniquement s'il n'a pas parlé récemment
 * @param 0 le topic
 * @param 1 la phrase
 */
R3F_LOG_TUTO_FNCT_kbTell_instructeur =
{
	private ["_topic", "_phrase"];
	
	_topic = _this select 0;
	_phrase = _this select 1;
	
	// Si le dernier kbTell de l'instructeur remonte à plus de 12 secondes
	if (time > R3F_LOG_TUTO_time_dernier_kbTell + 12) then
	{
		// Faire parler l'instructeur et partager l'information
		player kbTell [player, _topic, _phrase];
		R3F_LOG_TUTO_time_dernier_kbTell = time;
		R3F_LOG_TUTO_PV_nouveau_kbTell = random 1;
		publicVariable "R3F_LOG_TUTO_PV_nouveau_kbTell";
	};
};

/**
 * Sélectionne et réserve un hangar libre
 * @param 0 l'unité souhaitant réserver un hangar
 * @return l'index du hangar réservé dans R3F_LOG_TUTO_tab_hangars, ou -1 si aucun hangar libre
 */
R3F_LOG_TUTO_FNCT_reserver_hangar =
{
	private ["_unite", "_idx_hangar"];
	
	_unite = _this select 0;
	_idx_hangar = -1;
	
	{
		if (isNull (_x getVariable "R3F_LOG_TUTO_reserve_par") || {!alive (_x getVariable "R3F_LOG_TUTO_reserve_par")})
		exitWith
		{
			_idx_hangar = _forEachIndex;
			_x setVariable ["R3F_LOG_TUTO_reserve_par", _unite, true];
			
			// On nettoie le hangar de tous les éventuels objets résiduels de l'exercice précédent
			{
				deleteVehicle _x;
				sleep 0.02;
			} forEach (_x getVariable ["R3F_LOG_TUTO_tab_objets", []]);
			_x setVariable ["R3F_LOG_TUTO_tab_objets", [], true];
			
			_x setVariable ["R3F_LOG_TUTO_fleche_rebondissante", false, true];
			(_x getVariable "R3F_LOG_TUTO_helipad_degage") setVariable ["R3F_LOG_TUTO_fleche_rebondissante", false, true];
		};
	} forEach R3F_LOG_TUTO_tab_hangars;
	
	_idx_hangar
};

/**
 * Libère le hangar réservé par l'unité
 * @param 0 l'unité libérant le hangar
 */
R3F_LOG_TUTO_FNCT_liberer_hangar =
{
	private ["_unite"];
	
	_unite = _this select 0;
	
	{
		if (_x getVariable "R3F_LOG_TUTO_reserve_par" == _unite) then
		{
			// On nettoie le hangar de tous les éventuels objets résiduels
			{
				deleteVehicle _x;
				sleep 0.02;
			} forEach (_x getVariable ["R3F_LOG_TUTO_tab_objets", []]);
			_x setVariable ["R3F_LOG_TUTO_tab_objets", [], true];
			
			_x setVariable ["R3F_LOG_TUTO_fleche_rebondissante", false, true];
			(_x getVariable "R3F_LOG_TUTO_helipad_degage") setVariable ["R3F_LOG_TUTO_fleche_rebondissante", false, true];
			
			_x setVariable ["R3F_LOG_TUTO_reserve_par", objNull, true];
		};
	} forEach R3F_LOG_TUTO_tab_hangars;
};

R3F_LOG_TUTO_FNCT_EH_ctrl_bouton =
{
	#include "dlg_constantes_tableau.h"
	
	private ["_evenement", "_control"];
	
	_evenement = _this select 0;
	_control = _this select 1;
	
	_num_bouton = 0.5 * (ctrlIDC _control - R3F_LOG_TUTO_IDC_dlg_TAB_btn1) + 1;
	
	switch (_evenement) do
	{
		case "enter": {findDisplay R3F_LOG_TUTO_IDD_dlg_tableau displayCtrl (ctrlIDC _control+1) ctrlSetText format ["tutorial\img\btn%1_hover.paa", _num_bouton];};
		case "exit": {findDisplay R3F_LOG_TUTO_IDD_dlg_tableau displayCtrl (ctrlIDC _control+1) ctrlSetText format ["tutorial\img\btn%1.paa", _num_bouton];};
		case "click":
		{
			["ChoixActivite"] spawn R3F_LOG_TUTO_FNCT_supprimer_tache;
			closeDialog 0;
			
			if (_num_bouton <= 5) then
			{
				execVM format ["tutorial\module%1.sqf", _num_bouton];
			}
			else
			{
				R3F_LOG_TUTO_PV_nouvelle_mission = _num_bouton - 5;
				publicVariable "R3F_LOG_TUTO_PV_nouvelle_mission";
				["R3F_LOG_TUTO_PV_nouvelle_mission", R3F_LOG_TUTO_PV_nouvelle_mission] spawn R3F_LOG_TUTO_FNCT_PVEH_nouvelle_mission;
			};
		};
	};
};

/**
 * Crée et affecte une tâche au joueur
 * @param 0 le nom de la tâche (identifiant)
 * @param 1 la description de la tâche
 * @param 2 (optionnel) objet ou position de la destination
 */
R3F_LOG_TUTO_FNCT_creer_tache =
{
	private ["_nom", "_description", "_destination"];
	
	_nom = _this select 0;
	_description = _this select 1;
	
	[
		format ["R3F_LOG_TUTO_%1_%2_%3", _nom, R3F_LOG_TUTO_num_exec_module, getPlayerUID player],
		player,
		[
			_description,
			_description,
			""
		],
		nil,
		true,
		0,
		true,
		false
	] call BIS_fnc_setTask;
	
	if (count _this > 2) then
	{
		_destination = _this select 2;
		[_nom, _destination] call R3F_LOG_TUTO_FNCT_set_destination_tache;
	};
};

/**
 * Crée et affecte une tâche au joueur puis affiche l'astuce associée
 * @param 0 le nom de la tâche (identifiant)
 * @param 1 la description de la tâche
 * @param 2 (optionnel) objet ou position de la destination
 */
R3F_LOG_TUTO_FNCT_creer_tache_hint =
{
	_this call R3F_LOG_TUTO_FNCT_creer_tache;
	[_this select 0] call R3F_LOG_TUTO_FNCT_afficher_hint;
};

/**
 * Valide l'accomplissement de la tâche
 * @param 0 le nom de la tâche (identifiant)
 * @param 1 le nouveau statut de la tâche ("SUCCEEDED", "CANCELED", "FAILED")
 */
R3F_LOG_TUTO_FNCT_set_statut_tache =
{
	private ["_nom", "_statut"];
	
	_nom = _this select 0;
	_statut = _this select 1;
	
	[format ["R3F_LOG_TUTO_%1_%2_%3", _this select 0, R3F_LOG_TUTO_num_exec_module, getPlayerUID player], _statut, true] call BIS_fnc_taskSetState;
	
	// Suppression du hint
	if (toUpper _statut == "SUCCEEDED") then {RscAdvancedHint_close = true;};
	
	sleep 1;
};

/**
 * Défini la destination de la tâche
 * @param 0 le nom de la tâche (identifiant)
 * @param 1 objet ou position de la destination
 */
R3F_LOG_TUTO_FNCT_set_destination_tache =
{
	private ["_nom", "_destination"];
	
	_nom = _this select 0;
	_destination = _this select 1;
	
	[format ["R3F_LOG_TUTO_%1_%2_%3", _this select 0, R3F_LOG_TUTO_num_exec_module, getPlayerUID player], _destination] call BIS_fnc_taskSetDestination;
};

/**
 * Valide l'accomplissement de la tâche
 * @param 0 le nom de la tâche (identifiant)
 */
R3F_LOG_TUTO_FNCT_supprimer_tache =
{
	[format ["R3F_LOG_TUTO_%1_%2_%3", _this select 0, R3F_LOG_TUTO_num_exec_module, getPlayerUID player]] call BIS_fnc_deleteTask;
	sleep 0.5;
};

/**
 * Affiche une astuce (hint) défini dans le CfgHints de la mission
 * @param 0 le nom de classe du CfgHints de l'astuce à afficher
 */
R3F_LOG_TUTO_FNCT_afficher_hint =
{
	[["R3F_LOG_TUTO_Hints", _this select 0], 60, "false", 60, "false", true, true, false, true] call BIS_fnc_advHint;
};

/**
 * Supprime toutes les tâches et masque l'éventuel hint
 */
R3F_LOG_TUTO_FNCT_vider_taches_hint =
{
	{player removeSimpleTask _x} forEach simpleTasks player;
	RscAdvancedHint_close = true;
	
	call R3F_LOG_TUTO_FNCT_definir_taches_mission;
};

/**
 * Crée une tâche pour une mission libre
 * @param 0 le nom de la tâche (identifiant)
 * @param 1 la description courte de la tâche
 * @param 2 la description longue de la tâche
 * @param 3 la position de la destination
 */
R3F_LOG_TUTO_FNCT_creer_tache_mission =
{
	private ["_nom", "_description_courte", "_description_longue", "_destination"];
	
	_nom = _this select 0;
	_description_courte = _this select 1;
	_description_longue = _this select 2;
	_destination = _this select 3;
	
	[
		format ["R3F_LOG_TUTO_%1_%2_%3", _nom, R3F_LOG_TUTO_num_exec_module, getPlayerUID player],
		player,
		[
			_description_courte,
			_description_longue,
			""
		],
		_destination,
		"CREATED",
		0,
		false,
		false
	] call BIS_fnc_setTask;
};

/**
 * Défini les tâches pour les missions libres
 */
R3F_LOG_TUTO_FNCT_definir_taches_mission =
{
	[
		"mission1",
		"Create a road checkpoint to control the trafic.<br/>" +
		"<br/>" +
		"You can place bag fences or any other obstacles to force the vehicles to slow down. Install machine guns and fortifications to protect your team.<br/>" +
		"<br/>" +
		"You can airlift a mobile creation factory or a preloaded vehicle to help you to set up the checkpoint.",
		"Mission: Create checkpoint",
		getMarkerPos "mission1"
	] call R3F_LOG_TUTO_FNCT_creer_tache_mission;
	
	[
		"mission2",
		"Build a combat outpost (COP) near Rodopoli.<br/>" +
		"This COP will allow your team to control the district.<br/>" +
		"<br/>" +
		"You can airlift a mobile creation factory or a preloaded vehicle to help you to set up the COP.<br />",
		"Mission: Build a COP",
		getMarkerPos "mission2"
	] call R3F_LOG_TUTO_FNCT_creer_tache_mission;
	
	[
		"mission3",
		"A civilian boat is being shipwrecked ! We received a SOS radio call.<br/>" +
		"The crew of the boat succeeded to embark in their lifeboat.<br/>" +
		"<br/>" +
		"Search the lifeboat and airlift it to the base.",
		"Mission: Sea rescue",
		getMarkerPos "mission3"
	] call R3F_LOG_TUTO_FNCT_creer_tache_mission;
};

/**
 * Affiche un message au centre de l'écran pendant une durée définie
 * La fonction bloque l'exécution pendant l'affichage.
 * Pour un affichage non bloquant, utilisez "spawn" au lieu de "call".
 * 
 * @param 0 le texte à afficher
 * @param 1 (optionnel) la durée d'affichage en secondes (défaut : 5)
 * @param 2 (optionnel) la couleur du texte au format [r, g, b, a] (défaut : blanc)
 * @param 3 (optionnel) la couleur de fond au format [r, g, b, a] (défaut : noir)
 * @param 4 (optionnel) la taille de la police (défaut : 3.25)
 * @param 5 (optionnel) la durée en secondes du fondu d'apparition (défaut : 1.5)
 * @param 6 (optionnel) la durée en secondes du fondu de disparition (défaut : 1.5)
 * 
 * @usage ["message"] call R3F_LOG_TUTO_FNCT_afficher_centre; // appel bloquant
 * @usage ["message"] spawn R3F_LOG_TUTO_FNCT_afficher_centre; // appel non-bloquant
 * @usage ["message", 10, [1, 0, 0, 1], [0, 1, 0, 1], 4, 2, 2] call R3F_LOG_TUTO_FNCT_afficher_centre;
 */
R3F_LOG_TUTO_FNCT_afficher_centre =
{
	private ["_texte", "_duree", "_couleur_texte", "_couleur_fond", "_taille_police", "_duree_fondu_debut", "_duree_fondu_fin", "_ctrl_texte"];
	
	_texte = _this select 0;
	_duree = if (count _this > 1) then {_this select 1} else {5};
	_couleur_texte = if (count _this > 2) then {_this select 2} else {[1, 1, 1, 1]};
	_couleur_fond = if (count _this > 3) then {_this select 3} else {[0, 0, 0, 1]};
	_taille_police = if (count _this > 4) then {_this select 4} else {3.25};
	_duree_fondu_debut = if (count _this > 5) then {_this select 5} else {1.5};
	_duree_fondu_fin = if (count _this > 6) then {_this select 6} else {1.5};
	
	disableSerialization;
	
	_ctrl_texte = (findDisplay 46) ctrlCreate ["RscStructuredText", -1];
	_ctrl_texte ctrlSetPosition [0, 0.5 - 0.5*(0.04375*_taille_police), 1, 0.04375*_taille_police];
	_ctrl_texte ctrlSetBackgroundColor _couleur_fond;
	_ctrl_texte ctrlSetTextColor _couleur_texte;
	_ctrl_texte ctrlSetStructuredText parseText format ["<t align=""center""><t size=""%1""><t shadow=""0"">%2</t></t></t>", _taille_police, _texte];
	_ctrl_texte ctrlSetFade 1;
	_ctrl_texte ctrlCommit 0;
	
	_ctrl_texte ctrlSetFade 0;
	_ctrl_texte ctrlCommit _duree_fondu_debut;
	
	sleep (_duree + _duree_fondu_debut);
	
	_ctrl_texte ctrlSetFade 1;
	_ctrl_texte ctrlCommit _duree_fondu_fin;
	sleep _duree_fondu_fin;
	
	ctrlDelete _ctrl_texte;
};