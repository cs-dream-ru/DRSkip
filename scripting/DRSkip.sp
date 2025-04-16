#pragma semicolon 1
#pragma newdecls required

#include <sdkhooks>
#include <cstrike>
#include <multicolors>

Menu g_hMenu;
bool g_bIsSkipping;
ConVar drskip_time;

public Plugin myinfo = 
{
	name = "[DR] Skip",
	author = "vadrozh & who",
	description = "Функция пропуска для Террориста",
	version = "1.0.0",
	url = "hlmod.ru"
}

public void OnPluginStart()
{
	LoadTranslations("DRSkip.phrases.txt");

	drskip_time = CreateConVar("sm_DRSkip_Time", "15.0", "Время, в течении которого Т может пропустить CT.", _, true, 5.0, true, 120.0);

	AutoExecConfig(true, "DRSkip");
	
	HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);

	g_hMenu = new Menu(Handler_SkipMenu, MenuAction_Select|MenuAction_Display|MenuAction_DisplayItem|MenuAction_Cancel);
	g_hMenu.SetTitle("Skip CT?");
	g_hMenu.AddItem(NULL_STRING, "Yes");
	g_hMenu.AddItem(NULL_STRING, "No");
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(StrContains(classname, "button") != -1)
	{
		SDKHook(entity, SDKHook_Use, OnButtonUse);
	}
}

public void OnRoundStart(Event event, char[] name, bool dbc)
{
	g_bIsSkipping = false;

	for (int i = 1; i <= MaxClients; ++i)
	{
		if (IsClientInGame(i) && !IsFakeClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == CS_TEAM_T)
		{
			g_hMenu.Display(i, drskip_time.IntValue);
			return;
		}
	}
}

public int Handler_SkipMenu(Menu hMenu, MenuAction action, int iClient, int iItem)
{
	if(action == MenuAction_Display)
	{
		SetGlobalTransTarget(iClient);
 		char szBuffer[128];
		FormatEx(szBuffer, sizeof(szBuffer), "%t \n \n", "MenuTitle");

		Panel hPanel = view_as<Panel>(iItem);
		hPanel.SetTitle(szBuffer);		
	}
	else if(action == MenuAction_DisplayItem)
	{
		char szBuffer[128];
		SetGlobalTransTarget(iClient);

		FormatEx(szBuffer, sizeof(szBuffer), "%t", iItem == 0 ? "MenuYes" : "MenuNo"); 

		return RedrawMenuItem(szBuffer);		
	}
	else if(action == MenuAction_Select)
	{
		if(iItem == 0)
		{
			Skip();
		}
		else
		{
			CPrintToChat(iClient, "%t %t", "Prefix", "NotSkipping");
		}		
	}
	else if(action == MenuAction_Cancel && iItem == MenuCancel_Timeout)
	{
		CPrintToChat(iClient, "%t %t", "Prefix", "NotSkipping");
	}

	return 0;
}

public void Skip()
{
	g_bIsSkipping = true;
	CPrintToChatAll("%t %t", "Prefix", "Skip");
}

public Action OnButtonUse(int iEntity, int iActivator, int iClient, UseType type, float fValue)
{
	if(!iClient || !IsClientInGame(iClient) || GetClientTeam(iClient) != 2) 
	{
		return Plugin_Continue;
	}

	if(g_bIsSkipping)
	{
		CPrintToChat(iClient, "%t %t", "Prefix", "TryActivate");
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}