global function NightSky_Init
global function SetPlayerToNightSky

void function NightSky_Init()
{
	AddCallback_OnClientConnected( OnClientConnected )
}

void function OnClientConnected( entity player )
{
	thread SetPlayerToNightSky( player )
}

void function SetPlayerToNightSky( entity player )
{
	player.EndSignal( "OnDestroy" )
	svGlobal.levelEnt.EndSignal( "NukeExplode" )
	player.SetSkyCamera( GetEnt( SKYBOXSPACE ) )

	for( ;; )
	{
		WaitFrame()
		Remote_CallFunction_NonReplay( player, "ServerCallback_SetMapSettings", 1.0, false, null, null, null, null, null, 0.0, 0.5 )
	}
}