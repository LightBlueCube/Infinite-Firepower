untyped
global function AntiInsult_Init

const float FAR_CHECK_RANGE = 75
const float NEAR_CHECK_RANGE = 1
const float TITAN_CHECK_RANGE_MULTIPLIER = 2.0	// only multiple FAR_CHECK_RANGE and NEAR_CHECK_RANGE, not work for MAX_CHECK_RANGE
const float MAX_CHECK_RANGE = 1000
const float THRESHLOD = 1.6

void function AntiInsult_Init()
{
	RegisterSignal( "NewDuckCheck" )
	RegisterSignal( "FuckUpPlayer" )
	RegisterWeaponDamageSource( "anti_insult", "喜歡蹲起" )

	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddCallback_OnClientConnected( OnClientConnected )
}

void function OnClientConnected( entity player )
{
	player.s.validDuckNum <- 0.0
	player.s.nearDuckNum <- 0.0
	player.s.duckOriginSave <- < 0, 0, 0 >
	player.s.dontShowTips <- false
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
	player.Signal( "NewDuckCheck" )
	player.EndSignal( "NewDuckCheck" )

	OnThreadEnd(
		function() : ( player )
		{
			RemoveButtonPressedPlayerInputCallback( player, IN_DUCK, OnPlayerDuckHeld )
			RemoveButtonPressedPlayerInputCallback( player, IN_DUCKTOGGLE, OnPlayerDuckToggle )
			if( !IsValid( player ) )
				return
			player.s.validDuckNum = 0
			player.s.nearDuckNum = 0
		}
	)

	AddButtonPressedPlayerInputCallback( player, IN_DUCK, OnPlayerDuckHeld )
	AddButtonPressedPlayerInputCallback( player, IN_DUCKTOGGLE, OnPlayerDuckToggle )

	player.s.validDuckNum = 0.0
	player.s.nearDuckNum = 0.0
	vector origin = player.GetOrigin()
	float savedValidDuck = 0
	for( int i = 35; i > 0; i-- )
	{
		WaitFrame()
		if( Distance( origin, player.GetOrigin() ) > MAX_CHECK_RANGE )
			return
		if( player.s.validDuckNum > savedValidDuck )
		{
			savedValidDuck = expect float( player.s.validDuckNum )
			if( i <= 5 )
				i += 5
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
	float distance2d = Distance2D( player.s.duckOriginSave, player.GetOrigin() )
	player.s.duckOriginSave = player.GetOrigin()
	float far = FAR_CHECK_RANGE
	float near = NEAR_CHECK_RANGE
	if( player.IsTitan() )
	{
		far *= TITAN_CHECK_RANGE_MULTIPLIER
		near *= TITAN_CHECK_RANGE_MULTIPLIER
	}

	bool shouldReset = !IsAlive( player ) || distance2d > far || IsValid( player.GetParent() ) || player.Anim_IsActive() || player.IsPhaseShifted() || player.IsWallRunning() || player.IsWallHanging()
	bool invalidDuck = shouldReset || !player.IsOnGround()
	if( distance2d > near || shouldReset )
		player.s.nearDuckNum = 0.0
	if( invalidDuck )
	{
		if( shouldReset )
			player.s.validDuckNum = 0
		return
	}

	player.s.validDuckNum += num
	if( distance2d <= near )
	{
		player.s.nearDuckNum += num
		if( player.s.nearDuckNum > 0.5 )
			player.s.validDuckNum = THRESHLOD
	}
	if( player.s.validDuckNum < THRESHLOD )
		return

	printt( "[AntiInsult] Name "+ player.GetPlayerName() +" UID "+ player.GetUID() )
	thread FuckUpPlayer( player )
}

void function FuckUpPlayer( entity player )
{
	player.Signal( "NewDuckCheck" )
	player.Signal( "FuckUpPlayer" )
	player.EndSignal( "FuckUpPlayer" )
	player.EndSignal( "OnDestroy" )
	SendHudMessage( player, "喜欢蹲起？", -1, 0.4, 255, 0, 0, 255, 0, 5, 1 )
	wait 0.5
	if( player.IsTitan() )
	{
		entity titan = CreateAutoTitanForPlayer_ForTitanBecomesPilot( player )
		DispatchSpawn( titan )
		TitanBecomesPilot( player, titan )
		if( IsValid( titan ) )
			titan.Destroy()
	}

	player.s.dontShowTips <- true
	for( int i = 25; i > 0; i-- )
	{
		WaitFrame()
		SendHudMessage( player, "喜欢蹲起？", -1, 0.4, 255, 0, 0, 255, 0, 5, 1 )
		if( !IsAlive( player ) )
			player.RespawnPlayer( null )
		if( IsAlive( player ) )
		{
			player.Die( null, null, { damageSourceId = eDamageSourceId.anti_insult } )
			player.AddToPlayerGameStat( PGS_DEATHS, -1 )
		}
	}
	player.s.dontShowTips <- false
	WaitFrame()
	DeployAndEnableWeapons( player )
}