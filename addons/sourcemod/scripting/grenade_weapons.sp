#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "Levi2288"
#define PLUGIN_VERSION "0.00"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <sdkhooks>
//#include <sdkhooks>

#pragma newdecls required

//PARTICLES
#define EXPLOSION_AIR "explosion_molotov_air"
#define EXPLOSION_AIR_CORE "explosion_molotov_air_core"
#define EXPLOSION_AIR_DOWN "explosion_molotov_air_down"
#define EXPLOSION_AIR_SMOKE "explosion_molotov_air_smoke"
#define EXPLOSION_AIR_SPLASH01 "explosion_molotov_air_splash01a"
#define EXPLOSION_AIR_SPLASH07 "explosion_molotov_air_splash07a"

//FLAME PARTICLES
#define FLAME1A "molotov_child_flame01a"
#define FLAME1B "molotov_child_flame01b"
#define FLAME1C "molotov_child_flame01c"
#define FLAME2A "molotov_child_flame02a"
#define FLAME2B "molotov_child_flame02b"
#define FLAME2C "molotov_child_flame02c"
#define FLAME3A "molotov_child_flame03a"
#define FLAME3B "molotov_child_flame03b"
#define FLAME3C "molotov_child_flame03c"
#define FLAME4A "molotov_child_flame04a"
#define FLAME4B "molotov_child_flame04c"
#define FLAME4C "molotov_child_flame05a"

//SOUNDS
#define SOUND1 "weapons/molotov/fire_idle_loop_1"
#define SOUND2 "weapons/molotov/fire_ignite_1"
#define SOUND3 "weapons/molotov/fire_ignite_2"
#define SOUND4 "weapons/molotov/fire_ignite_4"
#define SOUND5 "weapons/molotov/fire_ignite_5"

//DETONATE
#define SOUND6 "weapons/molotov/molotov_detonate_1"
#define SOUND7 "weapons/molotov/molotov_detonate_2"
#define SOUND8 "weapons/molotov/molotov_detonate_3"
#define SOUND9 "weapons/molotov/molotov_detonate_1"

//LOOP
#define SOUND10 "weapons/molotov/fire_loop_1"


bool gb_Molotov[MAXPLAYERS+1];
bool gb_Flash[MAXPLAYERS+1];
bool gb_Heg[MAXPLAYERS+1];
bool gb_Enabled[MAXPLAYERS+1];


Menu g_GrenadeMain = null;


public Plugin myinfo = 
{
	name = "Grenade weapon",
	author = PLUGIN_AUTHOR,
	description = "Give your weapon an ability to fire grenades",
	version = PLUGIN_VERSION,
	url = "https://github.com/Bufika2288"
};

public void OnPluginStart()
{
	//Commands
	RegConsoleCmd("sm_grenadeweapon", Grenade_Chooser, "Change your weapon to a molotov weapon", ADMFLAG_ROOT);
	RegConsoleCmd("sm_gw", Grenade_Chooser, "Enable/Disable grenade shooting", ADMFLAG_ROOT);
	RegConsoleCmd("sm_gc", Grenade_Chooser, "Choose Grenade to shoot", ADMFLAG_ROOT);
	
	//Event Hooks
	HookEvent("bullet_impact", Event_BulletImpact);
	
	//Cvars
	CreateConVar("sm_gw_version", PLUGIN_VERSION, "Plugin Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
}
public void OnMapStart()
{
	PrecacheEffect("ParticleEffect");
	PrecacheParticleEffect(EXPLOSION_AIR);
	PrecacheParticleEffect(EXPLOSION_AIR_CORE);
	PrecacheParticleEffect(EXPLOSION_AIR_DOWN);
	PrecacheParticleEffect(EXPLOSION_AIR_SMOKE);
	PrecacheParticleEffect(EXPLOSION_AIR_SPLASH01);
	PrecacheParticleEffect(EXPLOSION_AIR_SPLASH07);
	
	
	PrecacheParticleEffect(FLAME1A);
	PrecacheParticleEffect(FLAME1B);
	PrecacheParticleEffect(FLAME1C);
	
	PrecacheParticleEffect(FLAME2A);
	PrecacheParticleEffect(FLAME2B);
	PrecacheParticleEffect(FLAME2C);
	
	PrecacheParticleEffect(FLAME3A);
	PrecacheParticleEffect(FLAME3B);
	PrecacheParticleEffect(FLAME3C);
	
	PrecacheParticleEffect(FLAME4A);
	PrecacheParticleEffect(FLAME4B);
	PrecacheParticleEffect(FLAME4C);
	
	PrecacheSound(SOUND1);
	PrecacheSound(SOUND2);
	PrecacheSound(SOUND3);
	PrecacheSound(SOUND4);
	PrecacheSound(SOUND5);
	PrecacheSound(SOUND6);
	PrecacheSound(SOUND7);
	PrecacheSound(SOUND8);
	PrecacheSound(SOUND9);
	PrecacheSound(SOUND10);
}

public void OnClientPostAdminCheck(int client)
{
	gb_Enabled[client] = false;
	g_GrenadeMain = BuildGrenadeMenu(client);
	gb_Molotov[client] = false;
	gb_Heg[client] = false;
	gb_Flash[client] = false;
}


public Action Grenade_Chooser(int client, int args)
{
	g_GrenadeMain.Display(client, MENU_TIME_FOREVER);

}
	
public Action Event_BulletImpact(Event event, const char[] name, bool dontBroadcast)
{
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (gb_Enabled[client] == true)
	{
		float pos[3];
		pos[0] = event.GetFloat("x");
		pos[1] = event.GetFloat("y");
		pos[2] = event.GetFloat("z") + 10;
	
		Spawn_Molotov(pos, client);
		
	}
	
}



public void Hook_WeaponSwitch(int client, int weapon)
{
	if (weapon == -1)
		return;
		
	char weaponname[32];
	GetEntityClassname(weapon, weaponname, sizeof(weaponname));
}

void Spawn_Molotov(float pos[3],int client)
{
	
	if (gb_Heg[client] == true)
	{
		int heg = CreateEntityByName("hegrenade_projectile");
		SetEntPropEnt(heg, Prop_Data, "m_hThrower", client);
		SetEntPropEnt(heg, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(heg, Prop_Data, "m_iTeamNum", GetClientTeam(client));
		SetEntPropFloat(heg, Prop_Data, "m_flDamage", 99.0);
		SetEntPropFloat(heg, Prop_Data, "m_DmgRadius", 350.0); 
		TeleportEntity(heg, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(heg);
		AcceptEntityInput(heg, "InitializeSpawnFromWorld");

	}
	
	else if (gb_Molotov[client] == true)
	{
		int fire = CreateEntityByName("molotov_projectile");
		SetEntPropEnt(fire, Prop_Data, "m_hThrower", client);
		SetEntPropEnt(fire, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(fire, Prop_Data, "m_iTeamNum", GetClientTeam(client));
		TeleportEntity(fire, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(fire);
		AcceptEntityInput(fire, "InitializeSpawnFromWorld");

	}
	
	else if (gb_Flash[client] == true)
	{
		int flash = CreateEntityByName("flashbang_projectile");
		SetEntPropEnt(flash, Prop_Data, "m_hThrower", client);
		SetEntPropEnt(flash, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(flash, Prop_Data, "m_iTeamNum", GetClientTeam(client));
		TeleportEntity(flash, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(flash);
		AcceptEntityInput(flash, "InitializeSpawnFromWorld");

	}
	
	else 
	{
		LogError("Unknown error");
	}
	
}

Menu BuildGrenadeMenu(int client)
{
	char buffer[128];
	char buffer2[128];
	char buffer3[128];
	Menu menu = new Menu(GrenadeMenu);

	Format(buffer, sizeof(buffer), "Molotov");
	Format(buffer2, sizeof(buffer2), "%s", gb_Molotov[client] ? "[X]":"");
	Format(buffer3, sizeof(buffer3), "%s %s", buffer, buffer2);
	menu.AddItem("Molotov", buffer3);
	
	Format(buffer, sizeof(buffer), "Heg");
	Format(buffer2, sizeof(buffer2), "%s", gb_Heg[client] ? "[X]":"");
	Format(buffer3, sizeof(buffer3), "%s %s", buffer, buffer2);
	menu.AddItem("Heg", buffer3);
	
	
	Format(buffer, sizeof(buffer), "Flash");
	Format(buffer2, sizeof(buffer2), "%s", gb_Flash[client] ? "[X]":"");
	Format(buffer3, sizeof(buffer3), "%s %s", buffer, buffer2);
	menu.AddItem("Flash", buffer3);
	
	
	
	Format(buffer, sizeof(buffer), "Grenade Shooting");
	Format(buffer2, sizeof(buffer2), "%s", gb_Enabled[client] ? "On":"Off");
	Format(buffer3, sizeof(buffer3), "%s %s", buffer, buffer2);
	menu.AddItem("Grenade Shooting", buffer3);
	
	
	
	menu.SetTitle("Grenade Weapon");
	menu.Pagination = 8;
	
	return menu;
}

public int GrenadeMenu(Menu menu, MenuAction action, int client, int param2)
{
	if(action == MenuAction_Select)
	{
		char items[32];	
		menu.GetItem(param2, items, sizeof(items));
		
		if (StrEqual(items, "Molotov")) 
		{
			gb_Molotov[client] = true;
			gb_Heg[client] = false;
			gb_Flash[client] = false;
		}
		
		if (StrEqual(items, "Heg")) 
		{
			gb_Molotov[client] = false;
			gb_Heg[client] = true;
			gb_Flash[client] = false;
		}
		
		if (StrEqual(items, "Flash")) 
		{
			gb_Molotov[client] = false;
			gb_Heg[client] = false;
			gb_Flash[client] = true;
		}
		
		if (StrEqual(items, "Grenade Shooting")) 
		{
			if (gb_Enabled[client] == false)
			{
				gb_Enabled[client] = true;
				PrintToChat(client, "[SM]\01 You \04enabled\01 Grenade bullets!");
		
			} 
			else 
			{
				gb_Enabled[client] = false;
				gb_Molotov[client] = false;
				gb_Heg[client] = false;
				gb_Flash[client] = false;
				PrintToChat(client, "[SM]\01 You \02disabled\01 Grenade bullets!");	
	
			}
		}
		g_GrenadeMain = BuildGrenadeMenu(client);
		g_GrenadeMain.Display(client, MENU_TIME_FOREVER);
	}
}
		
		
		
		
		
		

//Prechache particles
stock void PrecacheEffect(const char[] sEffectName)
{
    static int table = INVALID_STRING_TABLE;
    
    if (table == INVALID_STRING_TABLE)
    {
        table = FindStringTable("EffectDispatch");
    }
    bool save = LockStringTables(false);
    AddToStringTable(table, sEffectName);
    LockStringTables(save);
}
stock void PrecacheParticleEffect(const char[] sEffectName)
{
    static int table = INVALID_STRING_TABLE;
    
    if (table == INVALID_STRING_TABLE)
    {
        table = FindStringTable("ParticleEffectNames");
    }
    bool save = LockStringTables(false);
    AddToStringTable(table, sEffectName);
    LockStringTables(save);
} 