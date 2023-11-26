global function AutoShutdown_Init

void function AutoShutdown_Init()
{
	RegisterSignal( "AutoShutdownCountdown" )
	AddCallback_OnClientConnecting( StopCountdown )
	AddCallback_OnClientDisconnected( OnClientDisconnected )
	if( GetConVarString( "is_server_frist_start" ) == "1" )
	{
		SetConVarString( "is_server_frist_start", "0" )
		thread WaitBeforeStartCountdown( 60 * 60 )	// 60 minutes
		return
	}

	thread StartCountdown( null )
}

void function WaitBeforeStartCountdown( int time )
{
	wait time
	thread StartCountdown( null )
}

void function OnClientDisconnected( entity client )
{
	thread StartCountdown( client )
}

void function StartCountdown( entity client )
{
	foreach( player in GetPlayerArray() )
	{
		if( player == client || !IsValid( player ) )
			continue
		return
	}

	svGlobal.levelEnt.Signal( "AutoShutdownCountdown" )
	svGlobal.levelEnt.EndSignal( "AutoShutdownCountdown" )
	wait 60
	foreach( player in GetPlayerArray() )
	{
		if( player == client || !IsValid( player ) )
			continue
		return
	}

	printt( "[AutoShutdown] server is empty! shutdowning!" )
	ServerCommand( "quit" )	// say goodbye lol
}

void function StopCountdown( entity client )
{
	svGlobal.levelEnt.Signal( "AutoShutdownCountdown" )
}