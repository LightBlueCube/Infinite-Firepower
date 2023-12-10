untyped
global function AntiInsult_Init

const int FAR_CHECK_RANGE = 100
const int CLOSE_CHECK_RANGE = 20
const int MAX_CHECK_RANGE = 1000
const float THRESHLOD = 2.5

void function AntiInsult_Init()
{
	RegisterWeaponDamageSource( "anti_insult", "喜歡蹲起" )
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddCallback_OnClientConnected( OnClientConnected )
}

void function OnClientConnected( entity player )
{
	player.s.validDuckNum <- 0.0
	player.s.duckOriginSave <- < 0, 0, 0 >
	player.s.hasDuckChecked <- false
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if( !IsValid( attacker ) || !IsValid( victim ) )
		return

	if( !attacker.IsPlayer() || !victim.IsPlayer() )
		return

	if( attacker == victim || attacker.GetTeam() == victim.GetTeam() )
		return

	if( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.anti_insult )
		return

	thread PlayerDuckCheck( attacker )
}

void function PlayerDuckCheck( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( player )
		{
			RemoveButtonPressedPlayerInputCallback( player, IN_DUCK, OnPlayerDuckHeld )
			RemoveButtonPressedPlayerInputCallback( player, IN_DUCKTOGGLE, OnPlayerDuckToggle )
			player.s.validDuckNum = 0.0
		}
	)

	AddButtonPressedPlayerInputCallback( player, IN_DUCK, OnPlayerDuckHeld )
	AddButtonPressedPlayerInputCallback( player, IN_DUCKTOGGLE, OnPlayerDuckToggle )

	vector origin = player.GetOrigin()
	float savedValidDuck = 0
	for( int i = 40; i > 0; i-- )
	{
		WaitFrame()
		if( Distance( origin, player.GetOrigin() ) > MAX_CHECK_RANGE )
			return
		if( player.s.validDuckNum > savedValidDuck )
		{
			savedValidDuck = expect float( player.s.validDuckNum )
			i += 10
		}
	}
}

void function OnPlayerDuckHeld( entity player )
{
	OnPlayerDuck( player, 1 )
}

void function OnPlayerDuckToggle( entity player )
{
	OnPlayerDuck( player, 0.5 )
}

void function OnPlayerDuck( entity player, float num )
{
	if( player.s.validDuckNum == 0 || Distance2D( player.s.duckOriginSave, player.GetOrigin() ) >= FAR_CHECK_RANGE )
	{
		player.s.duckOriginSave = player.GetOrigin()
		player.s.validDuckNum += num
		return
	}
	if( Distance2D( player.s.duckOriginSave, player.GetOrigin() ) < FAR_CHECK_RANGE )
		player.s.validDuckNum += num
	if( Distance2D( player.s.duckOriginSave, player.GetOrigin() ) < CLOSE_CHECK_RANGE )
		player.s.validDuckNum += num
	if( player.s.validDuckNum < THRESHLOD )
		return
	printt( "[AntiInsult] Name "+ player.GetPlayerName() +" UID "+ player.GetUID() )
	if( player.s.hasDuckChecked )
		thread KillAndRespawnPlayer( player )
	player.s.validDuckNum = 0
	player.s.hasDuckChecked = true
}

void function KillAndRespawnPlayer( entity player )
{
	player.EndSignal( "OnDestroy" )
	wait 0.5

	for( int i = 40; i > 0; i-- )
	{
		WaitFrame()
		thread SendKsGUI_Threaded( player, "\n喜欢蹲起?", < 255, 0, 0 >, 5, 1 )
		if( !IsAlive( player ) )
			RespawnAsPilot( player )
		if( IsAlive( player ) )
			player.Die( null, null, { damageSourceId = eDamageSourceId.anti_insult } )
	}
	WaitFrame()
	DeployAndEnableWeapons( player )
}