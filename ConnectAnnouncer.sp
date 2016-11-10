#include <sourcemod>
#include <steamworks>

#pragma newdecls required

#define SEARCH_URL_CN "https://csgogamers.com/searchip/?ip="
#define SEARCH_URL_HK "https://irelia.me/ip.php?ip="

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
	Format(m_szUrl, 128, "%s%s", SEARCH_URL_HK, m_szIpAdr);

	Handle hHandle = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, m_szUrl);
	if(!hHandle || !SteamWorks_SetHTTPCallbacks(hHandle, OnHttpQueryCB) || !SteamWorks_SetHTTPRequestContextValue(hHandle, client) || !SteamWorks_SendHTTPRequest(hHandle))
		delete(hHandle);
}

public int OnHttpQueryCB(Handle hHandle, bool bFailure, bool bRequestSuccessful, EHTTPStatusCode eStatusCode, int client)
{
	if(!IsClientInGame(client) || bFailure || !bRequestSuccessful || eStatusCode != k_EHTTPStatusCode200OK)
	{
		delete(hHandle);
		return;
	}
	
	SteamWorks_GetHTTPResponseBodyCallback(hHandle, OnGetClientLocation, client);
}

public int OnGetClientLocation(char[] szLoc, int client)
{
	if(!IsClientInGame(client))
		return;

	ReplaceString(szLoc, 256, "中国", "", false);
	PrintToChatAll("[\x04CG\x01]\x01 \x04欢迎 \x0C%N \x05来自:%s", client, szLoc);
}