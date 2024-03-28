private ["_data_obj_ref", "_data_obj_fils", "_obj_crees", "_preau", "_table_instructeur"];

removeAllWeapons R3F_LOG_TUTO_AI_instructeur;
removeGoggles R3F_LOG_TUTO_AI_instructeur;
removeHeadgear R3F_LOG_TUTO_AI_instructeur;
removeVest R3F_LOG_TUTO_AI_instructeur;
R3F_LOG_TUTO_AI_instructeur addHeadgear "H_Cap_tan_specops_US";

removeAllWeapons R3F_LOG_TUTO_AI_instructeur2;
removeGoggles R3F_LOG_TUTO_AI_instructeur2;
removeHeadgear R3F_LOG_TUTO_AI_instructeur2;
removeVest R3F_LOG_TUTO_AI_instructeur2;
R3F_LOG_TUTO_AI_instructeur2 addHeadgear "H_Cap_tan_specops_US";

_data_obj_ref = ["Land_Shed_Small_F", [14181.9,16269.2,19.5943], 313.543];
_data_obj_fils = [];
_obj_crees = [_data_obj_ref, _data_obj_fils] call R3F_LOG_TUTO_FNCT_creer_decor_complexe;
_preau = _obj_crees select 0;

_data_obj_ref = ["Land_HBarrier_3_F", [14170.9,16272.8,19.5533], 226.657];
_data_obj_fils = [];
_obj_crees = [_data_obj_ref, _data_obj_fils] call R3F_LOG_TUTO_FNCT_creer_decor_complexe;

_data_obj_ref = ["Land_CampingTable_F", [14183.3,16271.1,19.3951], 222.352];
_data_obj_fils = [];
_data_obj_fils pushBack ["Land_Suitcase_F", [1.1709,0.0664063,-0.161043], 277.591];
_data_obj_fils pushBack ["Land_Laptop_unfolded_F", [0.520508,0.056953,0.56], 1.89976];
_data_obj_fils pushBack ["Land_File2_F", [-0.412109,0.0351563,0.412], 175.311];
_data_obj_fils pushBack ["Land_PortableLongRangeRadio_F", [-0.725586,-0.142578,0.422], 177.475];
_data_obj_fils pushBack ["Land_Notepad_F", [-0.708008,0.115234,0.417], 80.9108];
_data_obj_fils pushBack ["Land_PencilBlue_F", [-0.722656,0.125,0.417], -18.6786];
_data_obj_fils pushBack ["Land_CampingChair_V2_F", [-0.601563,1.46094,0.0999928], -13.3316];
_data_obj_fils pushBack ["Land_CampingChair_V2_F", [0.644531,1.30469,0.0999889], 8.4992];
_obj_crees = [_data_obj_ref, _data_obj_fils] call R3F_LOG_TUTO_FNCT_creer_decor_complexe;
_table_instructeur = _obj_crees select 0;

_data_obj_ref = ["Land_CampingTable_small_F", [14211.4,16290.7,19.3951], 142.702];
_data_obj_fils = [];
_data_obj_fils pushBack ["Land_CampingChair_V2_F", [-0.078125,-1.02637,0.0999298], 196.573];
_data_obj_fils pushBack ["Land_CampingChair_V2_F", [-0.0820313,1.28516,0.10224], -7.58188];
_data_obj_fils pushBack ["Land_Map_F", [0.275391,-0.158203,0.415], -129.053];
_data_obj_fils pushBack ["Land_BottlePlastic_V2_F", [-0.308594,-0.0449219,0.538], -47.5856];
_obj_crees = [_data_obj_ref, _data_obj_fils, true, _preau modelToWorld [1.56836,5,-1.66972], (_data_obj_ref select 2)+175] call R3F_LOG_TUTO_FNCT_creer_decor_complexe;

_data_obj_ref = ["Land_ShelvesWooden_khaki_F", [14212.1,16293.8,19.3878], 325.366];
_data_obj_fils = [];
_data_obj_fils pushBack ["Land_GasCooker_F", [0.015625,0.319824,0.565], -213.879];
_data_obj_fils pushBack ["Land_FoodContainer_01_F", [0.00390625,-0.2,0.67], -248.192];
_data_obj_fils pushBack ["Land_Ammobox_rounds_F", [-0.0449219,-0.1,0.2], -10.1164185];
_data_obj_fils pushBack ["Land_Camping_Light_off_F", [0.015625,0.219824,0.24], -262.405];
_obj_crees = [_data_obj_ref, _data_obj_fils, true, _preau modelToWorld [-0.996094,3,-1.58122], (_data_obj_ref select 2)+175] call R3F_LOG_TUTO_FNCT_creer_decor_complexe;

_data_obj_ref = ["Box_NATO_AmmoVeh_F", [14175.2,16273.2,19.6113], 227.798];
_data_obj_fils = [];
_data_obj_fils pushBack ["Land_CanisterPlastic_F", [-1.26367,0.0390625,-0.472255], 102.691];
_data_obj_fils pushBack ["Land_Pallets_F", [2.27441,-0.205078,-0.485657], 117.331];
_data_obj_fils pushBack ["Land_CanisterFuel_F", [1.68652,-1.27344,-0.547992], 70.2247];
_data_obj_fils pushBack ["Land_FireExtinguisher_F", [1.23926,-0.923828,-0.435779], 28.9766];
_obj_crees = [_data_obj_ref, _data_obj_fils] call R3F_LOG_TUTO_FNCT_creer_decor_complexe;

R3F_LOG_TUTO_AI_instructeur setDir 14.56;
R3F_LOG_TUTO_AI_instructeur setPos (_table_instructeur modelToWorld [-1.42285,0.853516,-0.405306]);
R3F_LOG_TUTO_AI_instructeur addEventHandler ["HandleDamage", {0}];
R3F_LOG_TUTO_AI_instructeur disableAI "MOVE";
R3F_LOG_TUTO_AI_instructeur disableAI "TARGET";
R3F_LOG_TUTO_AI_instructeur disableAI "AUTOTARGET";

R3F_LOG_TUTO_AI_instructeur2 setDir 42.1029;
R3F_LOG_TUTO_AI_instructeur2 setPosASL (_table_instructeur modelToWorld [-0.572266,0.853516,-0.405203]);
R3F_LOG_TUTO_AI_instructeur2 addEventHandler ["HandleDamage", {0}];
R3F_LOG_TUTO_AI_instructeur2 disableAI "MOVE";
R3F_LOG_TUTO_AI_instructeur2 disableAI "TARGET";
R3F_LOG_TUTO_AI_instructeur2 disableAI "AUTOTARGET";

sleep 0.5;