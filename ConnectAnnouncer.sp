#include <sourcemod>
#include <steamworks>

#pragma newdecls required

#define SEARCH_URL_ZH "https://irelia.me/searchip/?ip="
#define SEARCH_URL_EN "https://irelia.me/searchip/ip_en.php?ip="

#define ZH_CN

public Plugin myinfo = 
{
	name = " Connect Announcer ",
	author = "maoling ( xQy )",
	description = "",
	version = "1.0",
	url = "https://irelia.me"
};

public void OnClientPostAdminCheck(int client)
{
	char m_szIpAdr[16], m_szUrl[128];
	GetClientIP(client, m_szIpAdr, 16);

#if defined ZH_CN
	Format(m_szUrl, 128, "%s%s", SEARCH_URL_ZH, m_szIpAdr);
#else
	Format(m_szUrl, 128, "%s%s", SEARCH_URL_EN, m_szIpAdr);
#endif

	Handle hHandle = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, m_szUrl);
	if(!hHandle || !SteamWorks_SetHTTPCallbacks(hHandle, OnHttpQueryCB) || !SteamWorks_SetHTTPRequestContextValue(hHandle, client) || !SteamWorks_SendHTTPRequest(hHandle))
		CloseHandle(hHandle);
}

public int OnHttpQueryCB(Handle hHandle, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, int client)
{
	if(!IsClientInGame(client) || bFailure || !bRequestSuccessful || eStatusCode != k_EHTTPStatusCode200OK)
	{
		CloseHandle(hHandle);
		return;
	}
	else
	{
		LogError("SteamWorks: %sbFailure && %sbRequestSuccessful && eStatusCode[%d] Error Client: %N", bFailure ? "" : "!", bRequestSuccessful ? "" : "!", view_as<int>(eStatusCode), client);
	}
	
	SteamWorks_GetHTTPResponseBodyCallback(hHandle, OnGetClientLocation, client);
}

public int OnGetClientLocation(char[] szLoc, int client)
{
	if(!IsClientInGame(client))
		return;

#if defined ZH_CN
	ReplaceString(szLoc, 256, "中国", "", false);
	PrintToChatAll("[\x04CG\x01]\x01 \x04欢迎 \x0C%N \x05来自:%s", client, szLoc);
#else
	PrintToChatAll("[\x04CG\x01]\x01 \x04welcome \x0C%N \x05From:%s", client, szLoc);
#endif
}