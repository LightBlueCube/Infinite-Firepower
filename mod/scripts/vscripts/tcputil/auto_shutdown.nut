global function AutoShutdown_Init
global function ShutdownServer

void function AutoShutdown_Init()
{
	RegisterSignal( "AutoShutdownNewCountdown" )
	AddCallback_OnClientConnecting( StopCountdown )
	AddCallback_OnClientDisconnected( OnClientDisconnected )
	if( GetConVarString( "is_server_frist_start" ) == "1" )
	{
		SetConVarString( "is_server_frist_start", "0" )
		thread ShutdownCountdown( 6 * 60 * 60 )	// 6 hours
		return
	}

	thread ShutdownCountdown( 60 )	// 1 minutes, wait for player connect
}

void function ShutdownCountdown( int time )
{
	svGlobal.levelEnt.Signal( "AutoShutdownNewCountdown" )
	svGlobal.levelEnt.EndSignal( "AutoShutdownNewCountdown" )

	wait time
	thread ShutdownServerWhenEmpty()
}

void function OnClientDisconnected( entity client )
{
	thread ShutdownServerWhenEmpty( client )
}

void function ShutdownServerWhenEmpty( entity client = null )
{
	foreach( player in GetPlayerArray() )
	{
		if( player == client || !IsValid( player ) )
			continue
		return
	}
	printt( "[AutoShutdown] server is empty! shutdowning!" )
	ShutdownServer()
}

void function ShutdownServer()
{
	printt( "[ShutdownServer()] ShutdownServer() has been called, starting shutdown sequence" )
	SavingUsageData()
	ServerCommand( "quit" )
}

void function StopCountdown( entity client )
{
	svGlobal.levelEnt.Signal( "AutoShutdownNewCountdown" )
}