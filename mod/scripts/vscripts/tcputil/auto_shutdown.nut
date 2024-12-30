global function AutoShutdown_Init
global function StartShutdownSequence
global function StopShutdownSequence
global function ShutdownServer

void function AutoShutdown_Init()
{
	RegisterSignal( "AutoShutdownSequence" )
	AddCallback_OnClientConnecting( OnClientConnecting )

	if( GetConVarString( "is_server_frist_start" ) == "1" )
	{
		SetConVarString( "is_server_frist_start", "0" )
		thread StartShutdownSequence( 1 * 60 * 60 )	// 1 hours
		return
	}

	thread WaitForPlayerConnect()
}

void function OnClientConnecting( entity client )
{
	StopShutdownSequence()
	thread StartShutdownSequence()
}

void function WaitForPlayerConnect()
{
	float endTime = Time() + 30	// give 30 sec wait for player connect
	while( Time() < endTime )
	{
		wait 1
		if( GetPlayerArray().len() != 0 )
			break
	}

	thread StartShutdownSequence()
}

void function StartShutdownSequence( float time = 0 )
{
	svGlobal.levelEnt.Signal( "AutoShutdownSequence" )
	svGlobal.levelEnt.EndSignal( "AutoShutdownSequence" )

	wait time
	for( ;; )
	{
		wait 5
		if( GetPlayerArray().len() == 0 )
			return ShutdownServer()
	}
}

void function StopShutdownSequence()
{
	svGlobal.levelEnt.Signal( "AutoShutdownSequence" )
}

void function ShutdownServer()
{
	printt( "[ShutdownServer()] ShutdownServer() has been called, starting shutdown sequence" )
	SavingUsageData()
	thread ShutdownServer_Threaded()
}

void function ShutdownServer_Threaded()
{
	// give server a sec to let it finish all of the jobs (no idea but still wait a second)
	wait 1
	ServerCommand( "quit" )
}