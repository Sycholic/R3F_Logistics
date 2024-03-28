class CfgHints
{
	class R3F_LOG_TUTO_Hints
	{
		displayName = "[R3F] Logistics tutorial";
		
		class M1_S1_PrendreObjet
		{
			displayName = "Take an object";
			description = "Aim the object then use the action [<t color=""#00eeff"">%11</t>] in your mouse wheel menu.";
			arguments[] = {"format [STR_R3F_LOG_action_deplacer_objet, getText (configFile >> ""CfgVehicles"" >> ""Box_NATO_Wps_F"" >> ""displayName"")]"};
			tip = "You must be close to the object to get the action.";
		};
		
		class M1_S1_RelacherObjet
		{
			displayName = "Release the object";
			description = "You can walk with the object in your hands.%1%1To release the object on the ground, use the action [<t color=""#ee0000"">%11</t>] in your mouse wheel menu.";
			arguments[] = {"format [STR_R3F_LOG_action_relacher_objet, getText (configFile >> ""CfgVehicles"" >> ""Box_NATO_Wps_F"" >> ""displayName"")]"};
		};
		
		class M1_S2_OrienterObjet
		{
			displayName = "Orient the object";
			description = "Use the ""X"" and ""C"" keys to rotate the object. You can also use ""F"" and ""R"" to move it closer/further.";
			tip = "If you don't remember of the keys, don't worry, check your mouse wheel menu to remind you.";
		};
		
		class M2_S1_ChargerDeplace
		{
			displayName = "Load in cargo";
			description = "While moving an object, aim a vehicle or a cargo and use the action [<t color=""#dddd00"">%11</t>] to load it in.";
			arguments[] = {"format [STR_R3F_LOG_action_charger_deplace]"};
		};
		
		class M2_S2_ChargerSelection
		{
			displayName = "Load in cargo";
			description = "To load an object in a vehicle or a cargo, aim it and use the action [<t color=""#dddd00"">%11</t>].%1Then aim the vehicle or the cargo where to load it in, and use the action [<t color=""#dddd00"">%12</t>]";
			arguments[] =
			{
				"format [STR_R3F_LOG_action_selectionner_objet_charge, getText (configFile >> ""CfgVehicles"" >> ""B_Quadbike_01_F"" >> ""displayName"")]",
				"format [STR_R3F_LOG_action_charger_selection, getText (configFile >> ""CfgVehicles"" >> ""B_Truck_01_box_F"" >> ""displayName"")]"
			};
		};
		
		class M2_S4_Decharger
		{
			displayName = "Unload cargo";
			description = "To unload objects from a vehicle or cargo, aim it and use the action [<t color=""#dddd00"">%11</t>]. Select your item, then click on [<t color=""#dddd00"">%12</t>].";
			arguments[] =
			{
				"format [STR_R3F_LOG_action_contenu_vehicule]",
				"format [STR_R3F_LOG_dlg_CV_btn_decharger]"
			};
			tip = "You can see the number of places taken by each item, and the global loading of the cargo.";
		};
		
		class M3_S1_OuvrirUsine
		{
			displayName = "Open the factory";
			description = "Aim the creation factory and use the action [<t color=""#ff9600"">%11</t>].";
			arguments[] = {"format [STR_R3F_LOG_action_ouvrir_usine]"};
			tip = "You must be close to the factory to get the action.";
		};
		
		class M3_S1_CreerObjet
		{
			displayName = "Create an object";
			description = "Choose the object in the list at left, then click on [<t color=""#ff9600"">%11</t>].";
			arguments[] = {"format [STR_R3F_LOG_dlg_LO_btn_creer]"};
			tip = "The factory's credits will be debited of the creation cost.";
		};
		
		class M3_S2_SelectionnerCategorie
		{
			displayName = "Select the category";
			description = "Expand the list at top left to browse the available categories.";
			tip = "The categories are exactly the same as in the mission editor.";
		};
		
		class M3_S4_RevendreDeplace
		{
			displayName = "Send back to the factory";
			description = "While moving the object, aim the factory and use the action [<t color=""#ff9600"">%11</t>].";
			arguments[] = {"format [STR_R3F_LOG_action_revendre_usine_deplace]"};
		};
		
		class M3_S4_RevendreDirect
		{
			displayName = "Send back to the factory";
			description = "To send back a non movable object, aim it and use the action [<t color=""#ff9600"">%11</t>].";
			arguments[] = {"format [STR_R3F_LOG_action_revendre_usine_direct, getText (configFile >> ""CfgVehicles"" >> ""MRAP_01_base_F"" >> ""displayName"")]"};
			tip = "The object to send back must be closed to the factory.";
		};
		
		class M4_S2_Heliporter
		{
			displayName = "Lift an object";
			description = "Stabilize the helicopter over the object and use the action [<t color=""#00dd00"">%11</t>].";
			arguments[] = {"format [STR_R3F_LOG_action_heliporter]"};
			tip = "You can activate the auto-hover during the operation.";
		};
		
		class M4_S2_Larguer
		{
			displayName = "Drop the object";
			description = "To drop the lifted object, slow down, fly low and use the action [<t color=""#00dd00"">%11</t>].";
			arguments[] = {"format [STR_R3F_LOG_action_heliport_larguer]"};
			tip = "The drop action is available only if you are enough slow and at low altitude.";
		};
		
		class M5_S1_Remorquer
		{
			displayName = "Tow a vehicle";
			description = "You have to move the rear of the towing vehicle near of the front of the vehicle to tow.%1Then get out of the vehicle, aim the vehicle to tow and use the action [<t color=""#00dd00"">%11</t>].";
			arguments[] = {"format [STR_R3F_LOG_action_remorquer_direct, getText (configFile >> ""CfgVehicles"" >> ""B_Plane_CAS_01_F"" >> ""displayName"")]"};
		};
		
		class M5_S2_Detacher
		{
			displayName = "Untow the vehicle";
			description = "To detach the towed vehicle, get out of the vehicle, then aim the towed vehicle and use the action [<t color=""#00dd00"">%11</t>].";
			arguments[] = {"format [STR_R3F_LOG_action_detacher]"};
		};
	};
};