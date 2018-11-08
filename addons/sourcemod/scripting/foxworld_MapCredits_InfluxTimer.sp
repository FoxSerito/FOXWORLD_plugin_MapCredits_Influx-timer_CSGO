#include <sourcemod>
#include <sdktools>
#include <shop>
#include <vip_core>
#include <shavit>

public Plugin myinfo =
{
	name = "[FOXWORLD] Map finish credits for Influx timer",
	author = "FoxSerito",
	description = "Gives Shop credits when you finish a map",
	version = "1.0",
	url = ""
};

char currentMap[64];
int currentMap_credits = 0;
new Handle:fox_kv;

public void OnPluginStart()
{
	fox_kv = CreateKeyValues("FOXWORLD_Map_Credits");
	if (!FileToKeyValues(fox_kv, "cfg/shop/shop_mapcredits.txt"))
	{
		SetFailState("BAD LOAD cfg/shop/shop_mapcredits.txt");
	}

	RegAdminCmd("sm_mapcr", set_map_credits, ADMFLAG_RCON, "Set mapfinish credits");
	RegConsoleCmd("sm_cr", check_map_credits, "Check mapfinish credits on this map");
	// RegAdminCmd("sm_delete_shop_map", delete_shop_map_config, ADMFLAG_RCON, "Check map credits config");

	GetCurrentMap(currentMap, 64);
	LOAD_CREDITS();
}

public OnMapStart()
{
	GetCurrentMap(currentMap, 64);
	LOAD_CREDITS();
}

// if by Influx player finish the map
//

//	if (currentMap_credits > 0)
//	{
//		int credits = currentMap_credits;
//		int credits_x2 = credits + credits;
//		if (VIP_IsClientVIP(client))
//		{
//			// выдать игроку кредиты x2
//			PrintToChatAll("[FOXWORLD SHOP] %N заработал %d кредита(ов) за прохождение карты. (VIP x2)", client, credits_x2);
//		}
//		else
//		{
//			// выдать игроку кредиты
//			PrintToChatAll("[FOXWORLD SHOP] %N заработал %d кредита(ов) за прохождение карты.", client, credits);
//		}
//	}
//	else
//	{
//		PrintToChat(client, "Ошибка: Не настроены кредиты за прохождение! (%s)", currentMap);
//	}


public Action set_map_credits(client, args)
{
	if (args == 1){
		new String: arg1[32];
		GetCmdArg(1, arg1, sizeof(arg1) );

		KvJumpToKey(fox_kv, currentMap, true);
		KvSetString(fox_kv, "credits", arg1);
		KvRewind(fox_kv);

		KeyValuesToFile(fox_kv, "cfg/shop/shop_mapcredits.txt");

		PrintToConsole(client, "Установленно %s кредит(ов/а) на карте %s", arg1, currentMap);
		PrintToChatAll("[FOXWORLD SHOP] Теперь за прохождение этой карты (%s) будет даваться %s кредит(ов/а)", currentMap, arg1);
		LOAD_CREDITS();
	}
	else
	{
		PrintToConsole(client, "ОШИБКА: Нужно указать число кредитов");
		PrintToChat(client, "ОШИБКА: Нужно указать число кредитов");
	}
}

public Action check_map_credits(client, args)
{
	LOAD_CREDITS();
	if (currentMap_credits != 0)
	{
		PrintToChat(client, "[FOXWORLD SHOP] За эту карту (%s) дают %i кредит(ов/а)", currentMap, currentMap_credits);
	}
	else
	{
		PrintToChat(client, "Ошибка: Не настроены кредиты, либо карта не на прохождение! (%s)", currentMap);
	}
}

LOAD_CREDITS()
{
	if (KvJumpToKey(fox_kv, currentMap, false))
	{
		decl String:map_credits[64];
		KvGetString(fox_kv, "credits", map_credits, 64);
		KvRewind(fox_kv);
		currentMap_credits = StringToInt(map_credits,10);
	}
	else
	{
		currentMap_credits = 0;
	}
}

