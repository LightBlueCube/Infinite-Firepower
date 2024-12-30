global function AntiAFK_Init
global function AntiAFK_SetKickNeededPlayer
global function AntiAFK_SetIgnorePlayers
global function AntiAFK_SetKickWarningTime
global function AntiAFK_SetKickTime
global function AntiAFK_SetKickNotice

struct{
	array<string> ignorePlayers = []
	string kickNotice = "因长时间挂机而被踢出"
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

void function AntiAFK_SetKickNotice( string input )
{
	file.kickNotice = input
}

void function OnClientConnected( entity player )
{
	thread CheckPlayerMovement( player )
}

void function CheckPlayerMovement( entity player )
{
	player.EndSignal( "OnDestroy" )

	WaitFrame()
	int afkTime = 0
	for( ;; )
	{
		vector lastOrigin = player.GetOrigin()
		wait 1

		if( player.GetPlayerSettings() == "spectator" || IsValid( player.GetParent() ) || player.Anim_IsActive() )
			continue

		if( lastOrigin == player.GetOrigin() )
			afkTime += 1
		else
			afkTime = 0

		if( afkTime >= file.warnTime )
			SendHudMessageWithPriority( player, 95, "!!!!请不要挂机!!!!", -1, 0.3, < 255, 0, 0 >, < 0.0, 0.7, 1 > )
		if( afkTime >= file.kickTime && GetPlayerArray().len() >= file.kickNeededPlayer && !file.ignorePlayers.contains( player.GetUID() ) )
			NSDisconnectPlayer( player, file.kickNotice )
	}
}