global function AntiAFK_Init

array<string> noKickPlayers = []
int kickNeededPlayers = 0

void function AntiAFK_Init( int i = 0, array<string> uids = [] )
{
	kickNeededPlayers = i
	noKickPlayers = uids
    AddCallback_OnClientConnected( OnClientConnected )
}

void function OnClientConnected( entity player )
{
	if( noKickPlayers.contains( player.GetUID() ) )
		return
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
        if( lastOrigin == player.GetOrigin() )
            afkTime += 1
        else
            afkTime = 0

		if( player.GetPlayerSettings() == "spectator" )
		{
			afkTime = 0
			continue
		}

        if( afkTime >= 60 )
            Chat_ServerPrivateMessage( player, "\x1b[31m!!!!!!!!请不要挂机!!!!!!!!", false )
        if( afkTime >= 90 && GetPlayerArray().len() > 10 )
            ServerCommand( "kickid "+ player.GetUID() )
    }
}