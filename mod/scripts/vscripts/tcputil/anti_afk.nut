global function AntiAFK_Init
global function AntiAFK_SetKickNeededPlayer
global function AntiAFK_SetIgnorePlayers
global function AntiAFK_SetKickWarningTime
global function AntiAFK_SetKickTime

array<string> noKickPlayers = []
int kickNeededPlayer = 0
int warnTime = 60
int kickTime = 90

void function AntiAFK_Init()
{
	AddCallback_OnClientConnected( OnClientConnected )
}

void function AntiAFK_SetKickNeededPlayer( int input )
{
	kickNeededPlayer = input
}
void function AntiAFK_SetIgnorePlayers( array<string> input )
{
	noKickPlayers = input
}
void function AntiAFK_SetKickWarningTime( int input )
{
	warnTime = input
}
void function AntiAFK_SetKickTime( int input )
{
	kickTime = input
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

		if( afkTime >= warnTime )
			thread SendKsGUI_Threaded( player, "!!!!!!!!请不要挂机!!!!!!!!", < 255, 0, 0 >, 1.1, 1, null, 0.4 )
		if( afkTime >= kickTime && GetPlayerArray().len() > kickNeededPlayer && !noKickPlayers.contains( player.GetUID() ) )
			ServerCommand( "kickid "+ player.GetUID() )
	}
}