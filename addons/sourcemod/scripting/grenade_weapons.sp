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


bool g_bAccess[MAXPLAYERS + 1];
Handle sm_enable_gweapon = INVALID_HANDLE;
Handle sm_grenade_w = INVALID_HANDLE;

char g_sGrenadeType[45];

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
	RegConsoleCmd("sm_grenadeweapon", Molotov_Weapon, "Change your weapon to a molotov weapon", ADMFLAG_ROOT);
	RegConsoleCmd("sm_gw", Molotov_Weapon, "Change your weapon to a molotov weapon", ADMFLAG_ROOT);
	
	//Event Hooks
	HookEvent("bullet_impact", Event_BulletImpact);
	
	//Cvars
	CreateConVar("sm_gw_version", PLUGIN_VERSION, "Plugin Version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	sm_enable_gweapon = CreateConVar("sm_enable_gweapon", "1", "Enable the plugin");
	sm_grenade_w = CreateConVar("sm_grenade_w", "molotov", "Accepted grenade types: flash, heg, molotov");
	
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
	g_bAccess[client] = false;

}

public Action Molotov_Weapon(int client, int args)
{
	if (GetConVarBool(sm_enable_gweapon))
	{	
		
		if (g_bAccess[client] == false)
		{
			g_bAccess[client] = true;
			PrintToChat(client, "[SM]\01 You \04enabled\01 Grenade bullets!");
	
		} 
		else 
		{
			g_bAccess[client] = false;
			PrintToChat(client, "[SM]\01 You \02disabled\01 Grenade bullets!");	

		}
	}
	else
	{
		ReplyToCommand(client, "[SM] This plugin is \02disabled.");
	}
}

public Action Event_BulletImpact(Event event, const char[] name, bool dontBroadcast)
{
	
	int client = GetClientOfUserId(event.GetInt("userid"));
	if (g_bAccess[client] == true)
	{
		//int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
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
	GetConVarString(sm_grenade_w, g_sGrenadeType, sizeof(g_sGrenadeType));
	
	if (StrEqual(g_sGrenadeType, "heg", true))
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
	
	else if (StrEqual(g_sGrenadeType, "molotov", true))
	{
		int fire = CreateEntityByName("molotov_projectile");
		SetEntPropEnt(fire, Prop_Data, "m_hThrower", client);
		SetEntPropEnt(fire, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(fire, Prop_Data, "m_iTeamNum", GetClientTeam(client));
		TeleportEntity(fire, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(fire);
		AcceptEntityInput(fire, "InitializeSpawnFromWorld");

	}
	
	else if (StrEqual(g_sGrenadeType, "flash", true))
	{
		int flash = CreateEntityByName("flashbang_projectile");
		SetEntPropEnt(flash, Prop_Data, "m_hThrower", client);
		SetEntPropEnt(flash, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(flash, Prop_Data, "m_iTeamNum", GetClientTeam(client));
		TeleportEntity(flash, pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(flash);
		AcceptEntityInput(flash, "InitializeSpawnFromWorld");

	}
	
	/*else if (StrEqual(g_sGrenadeType, "smoke", true))
	{ 
		int smoke = CreateEntityByName("smokegrenade_projectile");
		SetEntPropEnt(smoke, Prop_Data, "m_hThrower", client);
		SetEntPropEnt(smoke, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(smoke, Prop_Data, "m_iTeamNum", GetClientTeam(client)); 
		TeleportEntity(smoke, pos, NULL_VECTOR, NULL_VECTOR);
		SetEntProp(smoke, Prop_Data, "m_nNextThinkTick", 9999); 
		DispatchSpawn(smoke);
		
	}*/
	else 
	{
		LogError("Cvar: sm_grenade_w Error: Invalid Entity name \"%s\"", g_sGrenadeType);
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