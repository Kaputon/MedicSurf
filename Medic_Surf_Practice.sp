#include <sourcemod>
#include <tf2_stocks>
// ^ tf2_stocks.inc itself includes sdktools.inc and tf2.inc

#pragma semicolon 1
#pragma newdecls required

#define PLUGIN_VERSION "0.00"

ConVar g_randSpeed;
ConVar g_autoShoot;
ConVar g_rocketSpeed;

int auto_shoot_client;
int indicator = 0;
float orb_pos[3];

public Plugin myinfo = 
{
	name = "Medic Surf Training [BETA]",
	author = "Kaputon",
	description = "<>",
	version = PLUGIN_VERSION,
	url = "Your website URL/AlliedModders profile URL"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	// No need for the old GetGameFolderName setup.
	EngineVersion g_engineversion = GetEngineVersion();
	if (g_engineversion != Engine_TF2)
	{
		SetFailState("This plugin was made for use with Team Fortress 2 only.");
	}
} 


public void OnPluginStart()
{
	RegConsoleCmd("fire_rocket", Rocket_Test);
	RegConsoleCmd("set_origin", Set_Origin);
	RegConsoleCmd("ms_random_speed", ToggleRandomSpeed);
	RegConsoleCmd("ms_rocket_speed", SetRocketSpeed);
	RegConsoleCmd("ms_auto_shoot", ToggleAutoShoot);
	g_randSpeed = CreateConVar("g_randSpeed", "1.0", "If true rocket speed will be randomized.");
	g_autoShoot = CreateConVar("g_autoShoot", "0.0", "Toggles auto shooting.");
	g_rocketSpeed = CreateConVar("g_rocketSpeed", "1100.0", "Sets the speed of the rockets if they're not randomized. (1100.0 is stock speed)", _, true, 100.0, true, 5000.0);
	CreateTimer(2.0, AutoShoot_Timer, _, TIMER_REPEAT);
}

bool OrbAlive()
{
	if (orb_pos[0] == 0.0 && orb_pos[1] == 0.0 && orb_pos[2] == 0.0)
	{
		return false;
	}
	else
	{
		return true;
	}
}

Action AutoShoot_Timer(Handle timer)
{
	if (g_autoShoot.FloatValue == 1.0)
	{
		if (OrbAlive())
		{
			SpawnRocket(auto_shoot_client);
		}
	}
	return Plugin_Handled;
}

Action ToggleAutoShoot(int client, int args)
{
	char arg[128];
	
	for (int i = 1; i<= args; i++)
	{
		GetCmdArg(i, arg, sizeof(arg));
		int value = StringToInt(arg);
		
		if (value == 0)
		{
			g_autoShoot.FloatValue = 0.0;
			return Plugin_Handled;
		}
		if (value == 1)
		{
			g_autoShoot.FloatValue = 1.0;
			auto_shoot_client = client;
			return Plugin_Handled;
		}
	}
	
	return Plugin_Handled;
}

Action SetRocketSpeed(int client, int args)
{
	char arg[128];
	
	for (int i = 1; i <= args; i++)
	{
		GetCmdArg(i, arg, sizeof(arg));
		float value = StringToFloat(arg);
		
		if ((value > 100.0) && (value < 5000.1))
		{
			g_rocketSpeed.FloatValue = value;
			return Plugin_Handled;
		}
	}
	
	return Plugin_Handled;
}

Action ToggleRandomSpeed(int client, int args)
{
	char arg[128];
	
	for (int i = 1; i <= args; i++)
	{
		GetCmdArg(i, arg, sizeof(arg));
		int value = StringToInt(arg);
		
		if (value == 0)
		{
			g_randSpeed.FloatValue = 0.0;
			
			return Plugin_Handled;
		}
		
		if(value == 1)
		{
			g_randSpeed.FloatValue = 1.0;
			
			return Plugin_Handled;
		}
		
	}
	return Plugin_Handled;
}

public Action Set_Origin(int client, int args)
{
	if (client)
	{
		float ind_pos[3];
		GetClientAbsOrigin(client, orb_pos);
		
		ind_pos = orb_pos;
		ind_pos[2] += 12.0;
		
		if (!(indicator == 0))
		{
			RemoveEntity(indicator);
		}
		indicator = CreateEntityByName("tf_projectile_spellfireball");
		SetEntityMoveType(indicator, MOVETYPE_FLY);
		TeleportEntity(indicator, ind_pos, NULL_VECTOR, NULL_VECTOR);
		DispatchSpawn(indicator);
		
		return Plugin_Continue;
	}
	
	return Plugin_Handled;
}

public void SpawnRocket(int client) 
{ 	
	int rocket_entity = CreateEntityByName("tf_projectile_rocket"); //"tf_projectile_rocket"
	
	DispatchSpawn(rocket_entity); //spawns the rocket 
    
	float angles[3];
	float newpos[3];
	float velocity[3];
	
	
	GetClientAbsOrigin(client, newpos);
	
	SubtractVectors(newpos, orb_pos, angles);
	GetVectorAngles(angles, angles);
    
    //Get the distance between the client and the rocket, and find the angle.
	SubtractVectors(orb_pos, newpos, velocity);
	NormalizeVector(velocity, velocity);
	NegateVector(velocity);
	
	if (g_randSpeed.IntValue == 1)
	{
		float rFloat = GetRandomFloat(1100.0, 2100.0);
		velocity[0] *= rFloat;
		velocity[1] *= rFloat;
		velocity[2] *= rFloat;
	}
	else
	{
		for (int i = 0; i < 3; i++)
		{
			velocity[i] *= g_rocketSpeed.FloatValue;
		}
	}
    
    //1100 is the velocity of a normal rocket
    //1980 is the velocity of a direct hit rocket
	TeleportEntity(rocket_entity, orb_pos, angles, velocity); //sets the position, angle and velocity of the rocket so it flies to where you want. 
     
	SetEntPropEnt(rocket_entity, Prop_Send, "m_hOwnerEntity", client); //sets the owner of the rocket 
	SetEntProp(rocket_entity, Prop_Send, "m_iTeamNum", 3); //sets the team value of the rocket 
	SetEntDataFloat(rocket_entity, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected") + 4, 100.0, true); //not sure why, but this is required in order for it to do damage. 
    //SetEntData(rocket_entity, FindSendPropInfo(rocket_class_name, "m_bCritical"), 1, 1, true); //set it to be critical
} 

public Action Rocket_Test(int client, int args)
{

	if (client && !(orb_pos[0] == 0.0))
	{
		SpawnRocket(client);
	}
	else
	{
		PrintToChatAll("[SM] Place an origin down with the 'set_origin' command.");
	}
	
	return Plugin_Handled;
}

public void OnMapStart()
{
	/**
	 * @note Precache your models, sounds, etc. here!
	 * Not in OnConfigsExecuted! Doing so leads to issues.
	 */
}
