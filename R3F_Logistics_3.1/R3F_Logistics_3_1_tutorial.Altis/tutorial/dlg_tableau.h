/*
 * Définition de la boîte de dialogue du tableau
 */

#include "dlg_constantes_tableau.h"

// ArmA interface coordinates of the largest 4/3-format GUI area possible
#define _gui_max_dim (safeZoneW min safeZoneH)
#define _gui_start_x (0.5 - 0.5*_gui_max_dim)
#define _gui_start_y (0.5 - 0.5*_gui_max_dim)
#define _gui_w _gui_max_dim
#define _gui_h _gui_max_dim

// Macros to convert the GUI coordinates to arma interface coordinates
#define _get_gui_x(X) (_gui_start_x + (X)*_gui_w)
#define _get_gui_y(Y) (_gui_start_y + (Y)*_gui_h)
#define _get_gui_w(W) ((W)*_gui_w)
#define _get_gui_h(H) ((H)*_gui_h)

// ArmA interface coordinates of the virtual screen taking into account the GUI area
#define _screen_x _get_gui_x(0.05)
#define _screen_y _get_gui_y(0.05)
#define _screen_w _get_gui_w(0.9)
#define _screen_h _get_gui_h(0.9)

// Macros to convert virtual screen coordinates to arma interface coordinates
#define _get_screen_x(X) (_screen_x + (X)*_screen_w)
#define _get_screen_y(Y) (_screen_y + (Y)*_screen_h)
#define _get_screen_w(W) ((W)*_screen_w)
#define _get_screen_h(H) ((H)*_screen_h)

#define _largeur_bouton 0.50245
#define _hauteur_bouton 0.08749
#define _debut_x_bouton 0.2275

#define _debut_y_module 0.25
#define _delta_y_module 0.75*_hauteur_bouton

#define _debut_y_mission (_debut_y_module + 6*_delta_y_module)
#define _delta_y_mission 0.75*_hauteur_bouton

class R3F_LOG_TUTO_dlg_tableau
{
	idd = R3F_LOG_TUTO_IDD_dlg_tableau;
	name = "R3F_LOG_TUTO_dlg_tableau";
	
	movingEnable = 0;
	enableSimulation = 1;
	fadein = 0;
	fadeout = 0;
	duration = 1000000;
	objects[] = {};
	onLoad = "";
	onUnload = "";
	
	controlsBackground[] = 
	{
		R3F_LOG_TUTO_dlg_TAB_fond_tableau
	};
	
	controls[] =
	{
		R3F_LOG_TUTO_dlg_TAB_btn1,
		R3F_LOG_TUTO_dlg_TAB_fond_btn1,
		R3F_LOG_TUTO_dlg_TAB_btn2,
		R3F_LOG_TUTO_dlg_TAB_fond_btn2,
		R3F_LOG_TUTO_dlg_TAB_btn3,
		R3F_LOG_TUTO_dlg_TAB_fond_btn3,
		R3F_LOG_TUTO_dlg_TAB_btn4,
		R3F_LOG_TUTO_dlg_TAB_fond_btn4,
		R3F_LOG_TUTO_dlg_TAB_btn5,
		R3F_LOG_TUTO_dlg_TAB_fond_btn5,
		R3F_LOG_TUTO_dlg_TAB_btn6,
		R3F_LOG_TUTO_dlg_TAB_fond_btn6,
		R3F_LOG_TUTO_dlg_TAB_btn7,
		R3F_LOG_TUTO_dlg_TAB_fond_btn7,
		R3F_LOG_TUTO_dlg_TAB_btn8,
		R3F_LOG_TUTO_dlg_TAB_fond_btn8
	};
	
	// Définition des classes de base
	class R3F_LOG_TUTO_dlg_TAB_texte_basique
	{
		idc = -1;
		type = CT_STATIC;
		style = ST_LEFT;
		colorText[] = {0, 0, 0, 1};
		colorBackground[] = {0.784, 0.784, 0.784, 1};
		font = "PuristaSemibold";
		sizeEx = _get_screen_h(0.028);
		h = _get_screen_h(0.028);
		text = "";
	};
	
	class R3F_LOG_TUTO_dlg_TAB_bouton
	{
		idc = -1;
		type = CT_SHORTCUT_BUTTON;
		style = ST_CENTER;
		
		onMouseEnter = "[""enter"", _this select 0] call R3F_LOG_TUTO_FNCT_EH_ctrl_bouton;";
		onMouseExit = "[""exit"", _this select 0] call R3F_LOG_TUTO_FNCT_EH_ctrl_bouton;";
		onButtonClick = "[""click"", _this select 0] call R3F_LOG_TUTO_FNCT_EH_ctrl_bouton;";
		
		text = "";
		action = "";
		
		x = _get_screen_x(_debut_x_bouton); w =_get_screen_w(_largeur_bouton);
		y = _get_screen_y(0); h = _get_screen_h(_hauteur_bouton);
		
		font = "PuristaLight";
		size = _get_screen_h(0);
		sizeEx = _get_screen_h(0);
		
		animTextureNormal = "#(argb,8,8,3)color(0,0,0,0)";
		animTextureDisabled = "#(argb,8,8,3)color(0,0,0,0)";
		animTextureOver = "#(argb,8,8,3)color(0,0,0,0)";
		animTextureFocused = "#(argb,8,8,3)color(0,0,0,0)";
		animTexturePressed = "#(argb,8,8,3)color(0,0,0,0)";
		animTextureDefault = "#(argb,8,8,3)color(0,0,0,0)";
		textureNoShortcut = "#(argb,8,8,3)color(0,0,0,0)";
		colorBackground[] = {0,0,0,1};
		colorBackground2[] = {0,0,0,1};
		colorBackgroundFocused[] = {0,0,0,1};
		color[] = {0,0,0,1};
		color2[] = {0,0,0,1};
		colorText[] = {0,0,0,1};
		colorFocused[] = {0,0,0,1};
		colorDisabled[] = {0,0,0,1};
		period = 0.6;
		periodFocus = 0.6;
		periodOver = 0.6;
		shadow = 0;
		class HitZone {left = 0; top = 0; right = 0; bottom = 0;};
		class ShortcutPos {left = 0; top = 0; right = 0; bottom = 0; w = 0; h = 0;};
		class TextPos {left = 0; top = 0; right = 0; bottom = 0;};
		soundEnter[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEnter",0.09,1};
		soundPush[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundPush",0.09,1};
		soundClick[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundClick",0.09,1};
		soundEscape[] = {"\A3\ui_f\data\sound\RscButtonMenu\soundEscape",0.09,1};
		class Attributes 
		{
			font = "PuristaLight";
			color = "#E5E5E5";
			align = "left";
			shadow = "false";
		};
		class AttributesImage 
		{
			font = "PuristaLight";
			color = "#E5E5E5";
			align = "left";
		};
	};
	
	class R3F_LOG_TUTO_dlg_TAB_fond_bouton
	{
		idc = -1;
		type = CT_STATIC;
		style = ST_PICTURE;
		
		x = _get_screen_x(_debut_x_bouton); w =_get_screen_w(_largeur_bouton);
		y = _get_screen_y(0); h = _get_screen_h(_hauteur_bouton);
		colorText[] = {1,1,1,1};
		colorBackground[] = {1,0,0,1};
		
		font = "PuristaSemibold";
		sizeEx = _get_screen_h(0.028);
	};
	
	// Définition dans contrôles de l'interface
	class R3F_LOG_TUTO_dlg_TAB_fond_tableau : R3F_LOG_TUTO_dlg_TAB_fond_bouton
	{
		x = _get_screen_x(0); w = _get_screen_w(1);
		y = _get_screen_y(0); h = _get_screen_h(1);
		text = "tutorial\img\fond_tableau.jpg";
	};
	
	class R3F_LOG_TUTO_dlg_TAB_btn1 : R3F_LOG_TUTO_dlg_TAB_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_btn1;
		y = _get_screen_y(_debut_y_module + 0 * _delta_y_module);
	};
	
	class R3F_LOG_TUTO_dlg_TAB_fond_btn1 : R3F_LOG_TUTO_dlg_TAB_fond_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_fond_btn1;
		y = _get_screen_y(_debut_y_module + 0 * _delta_y_module);
		text = "tutorial\img\btn1.paa";
	};
	
	class R3F_LOG_TUTO_dlg_TAB_btn2 : R3F_LOG_TUTO_dlg_TAB_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_btn2;
		y = _get_screen_y(_debut_y_module + 1 * _delta_y_module);
	};
	class R3F_LOG_TUTO_dlg_TAB_fond_btn2 : R3F_LOG_TUTO_dlg_TAB_fond_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_fond_btn2;
		y = _get_screen_y(_debut_y_module + 1 * _delta_y_module);
		text = "tutorial\img\btn2.paa";
	};
	
	class R3F_LOG_TUTO_dlg_TAB_btn3 : R3F_LOG_TUTO_dlg_TAB_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_btn3;
		y = _get_screen_y(_debut_y_module + 2 * _delta_y_module);
	};
	class R3F_LOG_TUTO_dlg_TAB_fond_btn3 : R3F_LOG_TUTO_dlg_TAB_fond_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_fond_btn3;
		y = _get_screen_y(_debut_y_module + 2 * _delta_y_module);
		text = "tutorial\img\btn3.paa";
	};
	
	class R3F_LOG_TUTO_dlg_TAB_btn4 : R3F_LOG_TUTO_dlg_TAB_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_btn4;
		y = _get_screen_y(_debut_y_module + 3 * _delta_y_module);
	};
	class R3F_LOG_TUTO_dlg_TAB_fond_btn4 : R3F_LOG_TUTO_dlg_TAB_fond_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_fond_btn4;
		y = _get_screen_y(_debut_y_module + 3 * _delta_y_module);
		text = "tutorial\img\btn4.paa";
	};
	
	class R3F_LOG_TUTO_dlg_TAB_btn5 : R3F_LOG_TUTO_dlg_TAB_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_btn5;
		y = _get_screen_y(_debut_y_module + 4 * _delta_y_module);
	};
	class R3F_LOG_TUTO_dlg_TAB_fond_btn5 : R3F_LOG_TUTO_dlg_TAB_fond_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_fond_btn5;
		y = _get_screen_y(_debut_y_module + 4 * _delta_y_module);
		text = "tutorial\img\btn5.paa";
	};
	
	class R3F_LOG_TUTO_dlg_TAB_btn6 : R3F_LOG_TUTO_dlg_TAB_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_btn6;
		y = _get_screen_y(_debut_y_mission + 0 * _delta_y_mission);
	};
	class R3F_LOG_TUTO_dlg_TAB_fond_btn6 : R3F_LOG_TUTO_dlg_TAB_fond_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_fond_btn6;
		y = _get_screen_y(_debut_y_mission + 0 * _delta_y_mission);
		text = "tutorial\img\btn6.paa";
	};
	
	class R3F_LOG_TUTO_dlg_TAB_btn7 : R3F_LOG_TUTO_dlg_TAB_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_btn7;
		y = _get_screen_y(_debut_y_mission + 1 * _delta_y_mission);
	};
	class R3F_LOG_TUTO_dlg_TAB_fond_btn7 : R3F_LOG_TUTO_dlg_TAB_fond_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_fond_btn7;
		y = _get_screen_y(_debut_y_mission + 1 * _delta_y_mission);
		text = "tutorial\img\btn7.paa";
	};
	
	class R3F_LOG_TUTO_dlg_TAB_btn8 : R3F_LOG_TUTO_dlg_TAB_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_btn8;
		y = _get_screen_y(_debut_y_mission + 2 * _delta_y_mission);
	};
	class R3F_LOG_TUTO_dlg_TAB_fond_btn8 : R3F_LOG_TUTO_dlg_TAB_fond_bouton
	{
		idc = R3F_LOG_TUTO_IDC_dlg_TAB_fond_btn8;
		y = _get_screen_y(_debut_y_mission + 2 * _delta_y_mission);
		text = "tutorial\img\btn8.paa";
	};
};