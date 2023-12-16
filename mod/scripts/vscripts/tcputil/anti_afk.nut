global function AntiAFK_Init
global function AntiAFK_SetKickNeededPlayer
global function AntiAFK_SetIgnorePlayers
global function AntiAFK_SetKickWarningTime
global function AntiAFK_SetKickTime

struct{
	array<string> ignorePlayers = []
	int kickNeededPlayer = 0
	int warnTime = 60
	int kickTime = 90
}file

void function AntiAFK_Init()
{
	AddCallback_OnClientConnected( OnClientConnected )
}

void function AntiAFK_SetKickNeededPlayer( int input )
{
	file.kickNeededPlayer = input
}
void function AntiAFK_SetIgnorePlayers( array<string> input )
{
	file.ignorePlayers = input
}
void function AntiAFK_SetKickWarningTime( int input )
{
	file.warnTime = input
}
void function AntiAFK_SetKickTime( int input )
{
	file.kickTime = input
}

void function OnClientConnected( entity player )
{
	thread CheckPlayerMove( player )
}

void function CheckPlayerMove( entity player )
{
	player.EndSignal( "OnDestroy" )

	WaitFrame()
	int afkTime = 0
	for( ;; )
	{
		vector lastOrigin = player.GetOrigin()
		wait 1
		if( player.GetPlayerSettings() == "spectator" || player.GetParent() )
			continue
		if( lastOrigin == player.GetOrigin() )
			afkTime += 1
		else
			afkTime = 0

		if( afkTime >= file.warnTime )
			SendHudMessage( player, "!!!!请不要挂机!!!!", -1, 0.4, 255, 0, 0, 255, 0, 0.5, 1 )
		if( afkTime >= file.kickTime && GetPlayerArray().len() > file.kickNeededPlayer && !file.ignorePlayers.contains( player.GetUID() ) )
			ServerCommand( "kickid "+ player.GetUID() )
	}
}