global function DisableAimAssist_Init

void function DisableAimAssist_Init()
{
	AddCallback_OnClientConnected( OnClientConnected )
}

void function OnClientConnected( entity player )
{
	thread DisableAimAssist_LifeLong( player )
}

void function DisableAimAssist_LifeLong( entity player )
{
	player.EndSignal( "OnDestroy" )

	for( ;; )
	{
		if( IsAlive( player ) )
			player.SetAimAssistAllowed( false )
		WaitFrame()
	}
}