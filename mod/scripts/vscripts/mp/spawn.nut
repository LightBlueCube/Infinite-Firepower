untyped

global function InitRatings // temp for testing

global function Spawn_Init
global function SetRespawnsEnabled
global function RespawnsEnabled
global function SetSpawnpointGamemodeOverride
global function GetSpawnpointGamemodeOverride
global function AddSpawnpointValidationRule
global function CreateNoSpawnArea
global function DeleteNoSpawnArea

global function FindSpawnPoint

global function RateSpawnpoints_Generic
global function RateSpawnpoints_Frontline

global function SetSpawnZoneRatingFunc
global function SetShouldCreateMinimapSpawnZones
global function CreateTeamSpawnZoneEntity
global function RateSpawnpoints_SpawnZones
global function DecideSpawnZone_Generic
global function DecideSpawnZone_CTF

// modified: make a new function so ai gamemodes don't have to re-decide for each spawn
global function GetCurrentSpawnZoneForTeam
//global function FindSpawnPoint_ForDropPod

//global function GetAllValidSpawnPointsInSpawnZone

//global function FindSpawnPoint_WithCustomSpawnPointRule

// generic no-spawn areas for IsSpawnpointValid() to use
const float PLAYER_NOSPAWN_RADIUS = 1500
const float PROJECTILE_NOSPAWN_RADIUS = 800
const float NPC_NOSPAWN_RADIUS = 1000

// modified: prevent spawning in friendly's deadly area
const float DEADLY_AREA_DURATION = 20.0
const int DEADLY_AREA_RADIUS = 1500 // try to spawn away from player's max damage range
// ffa specifics
const float DEADLY_AREA_DURATION_FFA = 10.0
const int DEADLY_AREA_RADIUS_FFA = 1000

// modified:  spawnpoint rating think
const float FRIENDLY_SPAWN_RADIUS = 1000
const float ENEMY_NOSPAWN_RADIUS = 2000 // most weapon's outer range, cause it less dangrous for player

// modified: in ffa, try to spawn in fight areas, don't make players run across maps to have a fight
const float FFA_NOSPAWN_RADIUS = 1000 // still don't too close to an enemy
const float FFA_SPAWN_RADIUS = 2500

struct NoSpawnArea
{
	string id
	int blockedTeam
	int blockOtherTeams
	vector position
	float lifetime
	float radius
}

struct
{
	bool respawnsEnabled = true
	string spawnpointGamemodeOverride
	array< bool functionref( entity, int ) > customSpawnpointValidationRules

	table<string, NoSpawnArea> noSpawnAreas
} file

void function Spawn_Init()
{
	AddSpawnCallback( "info_spawnpoint_human", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_human_start", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_titan", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_titan_start", InitSpawnpoint )

	// callbacks for generic spawns
	AddCallback_EntitiesDidLoad( InitPreferSpawnNodes )

	// callbacks for spawnzone spawns
	AddCallback_GameStateEnter( eGameState.Prematch, ResetSpawnzones )
	AddSpawnCallbackEditorClass( "trigger_multiple", "trigger_mp_spawn_zone", AddSpawnZoneTrigger )

	// modified: prevent spawning in friendly's deadly area
	AddCallback_OnPlayerKilled( AddNoSpawnAreaForBeingKilled )
}

// modified: prevent spawning in friendly's deadly area
void function AddNoSpawnAreaForBeingKilled( entity victim, entity attacker, var damageInfo )
{
	// not suicide
	if ( attacker != victim )
	{
		if ( IsFFAGame() )
		{
			// don't let any players spawn nearby, area is smaller than 2-team mode
			// TEAM_INVALID means blocking all teams
			CreateNoSpawnArea( victim.GetTeam(), TEAM_INVALID, victim.GetOrigin(), DEADLY_AREA_DURATION_FFA, DEADLY_AREA_RADIUS_FFA )
		}
		else
		{
			// don't let friendly players spawn nearby
			CreateNoSpawnArea( victim.GetTeam(), victim.GetTeam(), victim.GetOrigin(), DEADLY_AREA_DURATION, DEADLY_AREA_RADIUS )
		}
	}
}

// modified: try to make spawnpoints near teammates and bit far from enemy
bool function HasEnemyNearSpawnPoint( int team, entity spawnpoint, bool checkFFa = false )
{
	float noSpawnRadius = ENEMY_NOSPAWN_RADIUS
	if ( checkFFa )
		noSpawnRadius = FFA_NOSPAWN_RADIUS
	foreach ( entity player in GetPlayerArrayOfEnemies_Alive( team ) )
	{
		if ( Distance2D( player.GetOrigin(), spawnpoint.GetOrigin() ) <= noSpawnRadius )
			return true
	}

	// no enemy in area!
	return false
}

bool function HasFriendlyNearSpawnPoint( int team, entity spawnpoint )
{
	foreach ( entity player in GetPlayerArrayOfTeam( team ) )
	{
		if ( Distance2D( player.GetOrigin(), spawnpoint.GetOrigin() ) <= FRIENDLY_SPAWN_RADIUS )
			return true
	}

	// no friendly in area!
	return false
}

// modified: in ffa, try to spawn in fight areas, don't make players run across maps to have a fight
bool function FFA_IsGoodSpawnPoint( int team, entity spawnpoint )
{
	foreach ( entity player in GetPlayerArrayOfEnemies_Alive( team ) )
	{
		if ( Distance2D( player.GetOrigin(), spawnpoint.GetOrigin() ) < FFA_SPAWN_RADIUS
			 && Distance2D( player.GetOrigin(), spawnpoint.GetOrigin() ) >= FFA_NOSPAWN_RADIUS )
			return true
	}

	// no enemy nearby!
	return false
}

// modified: prevent player spawn in places enemies can see!
bool function EnemyCanSeeSpawnPoint( int team, entity spawnpoint )
{
	foreach ( entity player in GetPlayerArrayOfEnemies_Alive( team ) )
	{
		if ( PlayerCanSeePos( player, spawnpoint.GetOrigin(), true, 135 ) )
			return true
	}

	// no enemy can see!
	return false
}


void function InitSpawnpoint( entity spawnpoint )
{
	if ( !( "lastUsedTime" in spawnpoint.s ) )
		spawnpoint.s.lastUsedTime <- -999
}

void function SetRespawnsEnabled( bool enabled )
{
	file.respawnsEnabled = enabled
}

bool function RespawnsEnabled()
{
	return file.respawnsEnabled
}

void function AddSpawnpointValidationRule( bool functionref( entity spawn, int team ) rule )
{
	file.customSpawnpointValidationRules.append( rule )
}

string function CreateNoSpawnArea( int blockSpecificTeam, int blockEnemiesOfTeam, vector position, float lifetime, float radius )
{
	NoSpawnArea noSpawnArea
	noSpawnArea.blockedTeam = blockSpecificTeam
	noSpawnArea.blockOtherTeams = blockEnemiesOfTeam
	noSpawnArea.position = position
	noSpawnArea.lifetime = lifetime
	noSpawnArea.radius = radius

	// generate an id
	noSpawnArea.id = UniqueString( "noSpawnArea" )

	// northstar didn't append current created noSpawnArea to file.noSpawnAreas
	// didn't tested yet, guess if we don't add this, noSpawnAreas will never work
	file.noSpawnAreas[ noSpawnArea.id ] <- noSpawnArea
	//

	thread NoSpawnAreaLifetime( noSpawnArea )

	return noSpawnArea.id
}

void function NoSpawnAreaLifetime( NoSpawnArea noSpawnArea )
{
	wait noSpawnArea.lifetime
	DeleteNoSpawnArea( noSpawnArea.id )
}

void function DeleteNoSpawnArea( string noSpawnIdx )
{
	if ( noSpawnIdx in file.noSpawnAreas )
		delete file.noSpawnAreas[ noSpawnIdx ]
}

void function SetSpawnpointGamemodeOverride( string gamemode )
{
	file.spawnpointGamemodeOverride = gamemode
}

string function GetSpawnpointGamemodeOverride()
{
	if ( file.spawnpointGamemodeOverride != "" )
		return file.spawnpointGamemodeOverride
	return GetGamemodeSpawnpointName()
}

string function GetGamemodeSpawnpointName()
{
	string gameMode = GameRules_GetGameMode()
	switch ( gameMode )
	{
		// These game modes have checkboxes in leveled
		case LAST_TITAN_STANDING:
		case TEAM_DEATHMATCH:
		case ATTRITION:
		case CAPTURE_POINT:
		case CAPTURE_THE_FLAG:
		case FORT_WAR:
		case FFA:
		case FD:
			break

		// These game modes use tdm spawns
		case PILOT_SKIRMISH:
		case WINGMAN_PILOT_SKIRMISH:
		case MARKED_FOR_DEATH_PRO:
		case MARKED_FOR_DEATH:
		case T_DAY:
		case AI_TDM:
		case BOMB:
		case HARDCORE_TDM:
		case COLISEUM:
		case HUNTED:
		case DON:
		case TITAN_BRAWL:
		case SPEEDBALL:
			gameMode = TEAM_DEATHMATCH
			break

		case RAID:
		case ATCOOP:
		case CONQUEST:
		case PVE_SANDBOX:
			gameMode = ATTRITION
			break

		case LTS_BOMB:
		case WINGMAN_LAST_TITAN_STANDING:
			gameMode = LAST_TITAN_STANDING
			break

		case FREE_AGENCY:
			gameMode = FFA
			break

		default:
			// If a game mode is not handled in here, spawnpoints won't have checkboxes that correspond to it, so all spawnpoints will be used in that mode, which is probably bad.
			Assert( false, "Game mode " + gameMode + " not handled in GameModeRemove()" )
	}

	return gameMode
}

void function InitRatings( entity player, int team )
{
	if ( player != null )
		SpawnPoints_InitRatings( player, team ) // no idea what the second arg supposed to be lol
}

entity function FindSpawnPoint( entity player, bool isTitan, bool useStartSpawnpoint )
{
	int team = player.GetTeam()
	if ( ( IsSwitchSidesBased() && HasSwitchedSides() == 1 ) )
		team = GetOtherTeam( team )

	array<entity> spawnpoints
	if ( useStartSpawnpoint )
		spawnpoints = isTitan ? SpawnPoints_GetTitanStart( team ) : SpawnPoints_GetPilotStart( team )
	else
		spawnpoints = isTitan ? SpawnPoints_GetTitan() : SpawnPoints_GetPilot()

	InitRatings( player, player.GetTeam() )

	// don't think this is necessary since we call discardratings
	//foreach ( entity spawnpoint in spawnpoints )
	//	spawnpoint.CalculateRating( isTitan ? TD_TITAN : TD_PILOT, team, 0.0, 0.0 )

	void functionref( int, array<entity>, int, entity ) ratingFunc = isTitan ? GameMode_GetTitanSpawnpointsRatingFunc( GAMETYPE ) : GameMode_GetPilotSpawnpointsRatingFunc( GAMETYPE )
	ratingFunc( isTitan ? TD_TITAN : TD_PILOT, spawnpoints, team, player )

	if ( isTitan )
	{
		if ( useStartSpawnpoint )
			SpawnPoints_SortTitanStart()
		else
			SpawnPoints_SortTitan()

		spawnpoints = useStartSpawnpoint ? SpawnPoints_GetTitanStart( team ) : SpawnPoints_GetTitan()
	}
	else
	{
		if ( useStartSpawnpoint )
			SpawnPoints_SortPilotStart()
		else
			SpawnPoints_SortPilot()

		spawnpoints = useStartSpawnpoint ? SpawnPoints_GetPilotStart( team ) : SpawnPoints_GetPilot()
	}

	entity spawnpoint = GetBestSpawnpoint( player, spawnpoints )

	spawnpoint.s.lastUsedTime = Time()
	//player.SetLastSpawnPoint( spawnpoint )
	player.p.lastSpawnPoint = spawnpoint // handled by DoRespawnPlayer(), but it's not enough

	return spawnpoint
}

entity function GetBestSpawnpoint( entity player, array<entity> spawnpoints )
{
	// not really 100% sure on this randomisation, needs some thought
	array<entity> validSpawns
	foreach ( entity spawnpoint in spawnpoints )
	{
		if ( player.p.lastSpawnPoint == spawnpoint ) // don't spawn on the same point as we last spawn!
			continue
		if ( IsSpawnpointValid( spawnpoint, player.GetTeam() ) )
			validSpawns.append( spawnpoint )
	}

	if( validSpawns.len() == 0 && SvmPredictEnable() )
	{
		printt( "found no valid spawns! trying get valid points without svm predict" )
		SetSvmPredictEnable( false )
		foreach ( entity spawnpoint in spawnpoints )
		{
			if ( player.p.lastSpawnPoint == spawnpoint ) // don't spawn on the same point as we last spawn!
				continue
			if ( IsSpawnpointValid( spawnpoint, player.GetTeam() ) )
				validSpawns.append( spawnpoint )
		}
		SetSvmPredictEnable( true )
	}

	if ( validSpawns.len() == 0 )
	{
		// no valid spawns, very bad, so dont care about spawns being valid anymore
		print( "found no valid spawns! spawns may be subpar!" )
		validSpawns = spawnpoints
	}

	// last resort
	if ( validSpawns.len() == 0 )
	{
		print( "map has literally 0 spawnpoints, as such everything is fucked probably, attempting to use info_player_start if present" )
		entity start = GetEnt( "info_player_start" )

		if ( IsValid( start ) )
		{
			if ( !( "lastUsedTime" in start.s ) )
				start.s.lastUsedTime <- -999
			validSpawns.append( start )
		}
	}

	if( BetterRespawnPointEnable() )
		return GetBetterSpawnPoint( player.GetTeam(), validSpawns )
	else
		return validSpawns[ RandomInt( min( 3, validSpawns.len() ) ) ]
}

bool function IsSpawnpointValid( entity spawnpoint, int team )
{
	// was testing making ffa use normal points, don't do debug print if so! will delay the server
	if ( !spawnpoint.HasKey( "ignoreGamemode" ) || ( spawnpoint.HasKey( "ignoreGamemode" ) && spawnpoint.kv.ignoreGamemode == "0" ) ) // used by script-spawned spawnpoints
	{
		if ( file.spawnpointGamemodeOverride != "" )
		{
			string gamemodeKey = "gamemode_" + file.spawnpointGamemodeOverride
			if ( spawnpoint.HasKey( gamemodeKey ) && ( spawnpoint.kv[ gamemodeKey ] == "0" || spawnpoint.kv[ gamemodeKey ] == "" ) )
				return false
		}
		else
		{
			if ( IsFFAGame() )
			{
				string gamemodeKey = "gamemode_tdm" // some map don't have enough ffa points, maybe this will be better
				if ( spawnpoint.HasKey( gamemodeKey ) && (spawnpoint.kv[gamemodeKey] == "0" || spawnpoint.kv[gamemodeKey] == "") )
				{
					gamemodeKey = "gamemode_ffa" // also save ffa spawnpoints
					if ( spawnpoint.HasKey( gamemodeKey ) && (spawnpoint.kv[gamemodeKey] == "0" || spawnpoint.kv[gamemodeKey] == "") )
					{
						// printt( "Removing ent " + ent.GetClassName() + " with " + gamemodeKey + " = \"" + ent.kv[gamemodeKey] + "\" at " + ent.GetOrigin() )
						spawnpoint.Destroy()
						return false
					}
				}
			}
			else
			{
				if ( GameModeRemove( spawnpoint ) )
					return false
			}
		}
	}
	/*
	if ( !spawnpoint.HasKey( "ignoreGamemode" ) || ( spawnpoint.HasKey( "ignoreGamemode" ) && spawnpoint.kv.ignoreGamemode == "0" ) ) // used by script-spawned spawnpoints
	{
		if ( file.spawnpointGamemodeOverride != "" )
		{
			string gamemodeKey = "gamemode_" + file.spawnpointGamemodeOverride
			if ( spawnpoint.HasKey( gamemodeKey ) && ( spawnpoint.kv[ gamemodeKey ] == "0" || spawnpoint.kv[ gamemodeKey ] == "" ) )
				return false
		}
		else
		{
			if ( GameModeRemove( spawnpoint ) )
				return false
		}
	}
	*/

	int compareTeam = spawnpoint.GetTeam()
	if ( ( IsSwitchSidesBased() && HasSwitchedSides() == 1 ) && ( compareTeam == TEAM_MILITIA || compareTeam == TEAM_IMC ) )
		compareTeam = GetOtherTeam( compareTeam )

	foreach ( bool functionref( entity, int ) customValidationRule in file.customSpawnpointValidationRules )
		if ( !customValidationRule( spawnpoint, team ) )
			return false

	if ( spawnpoint.GetTeam() > 0 && compareTeam != team && !IsFFAGame() )
		return false

	if ( spawnpoint.IsOccupied() )
		return false

	if ( Time() - spawnpoint.s.lastUsedTime <= 10.0 )
		return false

	// noSpawnArea think
	// only do it when RespawnsEnabled
	if ( RespawnsEnabled() )
	{
		foreach ( k, NoSpawnArea noSpawnArea in file.noSpawnAreas )
		{
			if ( Distance( noSpawnArea.position, spawnpoint.GetOrigin() ) > noSpawnArea.radius )
				continue

			if ( noSpawnArea.blockedTeam != TEAM_INVALID && noSpawnArea.blockedTeam == team )
				return false

			// blockOtherTeams == TEAM_INVALID may means "blocking all teams"?
			//if ( noSpawnArea.blockOtherTeams != TEAM_INVALID && noSpawnArea.blockOtherTeams != team )
			if ( noSpawnArea.blockOtherTeams == TEAM_INVALID || noSpawnArea.blockOtherTeams != team )
				return false
		}
	}

	// in rsquirrel extend returns null unlike in vanilla squirrel
	// check no spawn areas
    array< entity > spawnBlockers = GetPlayerArrayEx( "any", TEAM_ANY, TEAM_ANY, spawnpoint.GetOrigin(), PLAYER_NOSPAWN_RADIUS )
    spawnBlockers.extend( GetProjectileArrayEx( "any", TEAM_ANY, TEAM_ANY, spawnpoint.GetOrigin(), PROJECTILE_NOSPAWN_RADIUS ) )
	spawnBlockers.extend( GetNPCArrayEx( "any", TEAM_ANY, TEAM_ANY, spawnpoint.GetOrigin(), NPC_NOSPAWN_RADIUS ) )
	foreach ( entity blocker in spawnBlockers )
	{
		if ( blocker.GetTeam() != team )
			return false
	}

	// los check
	return !spawnpoint.IsVisibleToEnemies( team )
}


// SPAWNPOINT RATING FUNCS BELOW

// generic
struct {
	array<vector> preferSpawnNodes
} spawnStateGeneric

void function RateSpawnpoints_Generic( int checkClass, array<entity> spawnpoints, int team, entity player )
{
	if ( checkClass == TD_TITAN && !IsFFAGame() ) // spawn as titan
	{
		//print( "respawning as titan!" )
		// use frontline spawns in 2-team modes
		RateSpawnpoints_Frontline( checkClass, spawnpoints, team, player )
		return
	}

	// now testing: use ffa points in 2-team modes
	// modified checks...
	array<float> preferSpawnNodeRatings
	foreach ( vector preferSpawnNode in spawnStateGeneric.preferSpawnNodes )
	{
		float currentRating

		// modified checks...
		foreach ( entity nodePlayer in GetPlayerArray() )
		{
			float currentChange = 0.0

			bool sameTeam = nodePlayer.GetTeam() == player.GetTeam()
			float maxFriendlyDist = FRIENDLY_SPAWN_RADIUS
			float maxEnemyDist = ENEMY_NOSPAWN_RADIUS
			if ( IsFFAGame() )
				maxEnemyDist = FFA_SPAWN_RADIUS

			// the closer a player is to a node the more they matter
			float dist = Distance2D( preferSpawnNode, nodePlayer.GetOrigin() )
			if ( dist > maxFriendlyDist && sameTeam && !IsFFAGame() ) // only check friendlyDist if not ffa
				continue
			else if ( dist > maxEnemyDist && !sameTeam )
				continue

			float currentDist = sameTeam ? maxFriendlyDist : maxEnemyDist
			currentChange = ( currentDist - dist ) / 5
			if ( player == nodePlayer )
				currentChange *= -3 // always try to stay away from places we've already spawned
			else if ( !IsAlive( nodePlayer ) ) // dead players mean activity which is good, but they're also dead so they don't matter as much as living ones
				currentChange *= 0.6

			if( !sameTeam )  // if someone isn't on our team and alive they're probably bad
			{
				if ( IsFFAGame() ) // in ffa everyone is on different teams, want to make players spawn near a battle area
				{
					if ( dist >= FFA_NOSPAWN_RADIUS && dist < FFA_SPAWN_RADIUS )
						currentChange *= 2.0 // safe and battle zone, add more chance
					else
						currentChange *= -0.6 // try not to spawn too far or too close
				}
				else
					currentChange *= -0.6
			}
			else // friendly team
				currentChange *= 2.0 // try to spawn near a friendly player

			currentRating += currentChange
		}

		preferSpawnNodeRatings.append( currentRating )
	}

	foreach ( entity spawnpoint in spawnpoints )
	{
		float currentRating
		float petTitanModifier
		// scale how much a given spawnpoint matters to us based on how far it is from each node
		bool spawnHasRecievedInitialBonus = false
		for ( int i = 0; i < spawnStateGeneric.preferSpawnNodes.len(); i++ )
		{
			// bonus if autotitan is nearish
			if ( IsAlive( player.GetPetTitan() ) && Distance( player.GetPetTitan().GetOrigin(), spawnStateGeneric.preferSpawnNodes[ i ] ) < 1200.0 )
				petTitanModifier += 10.0

			float dist = Distance2D( spawnpoint.GetOrigin(), spawnStateGeneric.preferSpawnNodes[ i ] )
			if ( dist > 5000.0 ) // really should set this extramely high to receive InitialBonus
				continue

			if ( dist < 4000.0 && !spawnHasRecievedInitialBonus )
			{
				currentRating += 10.0
				spawnHasRecievedInitialBonus = true // should only get a bonus for simply being by a node once to avoid over-rating
			}

			currentRating += ( preferSpawnNodeRatings[ i ] * ( ( 5000.0 - dist ) / 5000 ) ) * max( RandomFloat( 1.25 ), 0.9 )
			if ( dist < 500.0 ) // shouldn't get TOO close to an active node
				currentRating *= 0.7

			if ( spawnpoint.s.lastUsedTime < 10.0 )
				currentRating *= 0.7
		}

		// modified condition
		if ( IsFFAGame() )
		{
			if ( FFA_IsGoodSpawnPoint( team, spawnpoint ) )
			{
				if ( currentRating > 0 )
					currentRating *= 2.0
			}
			else if ( HasEnemyNearSpawnPoint( team, spawnpoint, true ) )
				currentRating *= 0.0 // try not to spawn too close to enemy
		}
		else
		{
			if ( HasEnemyNearSpawnPoint( team, spawnpoint ) )
				currentRating *= 0.0 // try not to spawn too close to enemy
			else if ( HasFriendlyNearSpawnPoint( team, spawnpoint ) )
			{
				if ( currentRating > 0 ) // no rating yet
					currentRating *= 2.0 // and mostly spawn near a friendly
			}
		}

		if ( currentRating != 0 ) // check this or server will calculate too much
		{
			float rating = spawnpoint.CalculateRating( checkClass, team, currentRating, currentRating + petTitanModifier )
			//print( "spawnpoint at " + spawnpoint.GetOrigin() + " has rating: " + rating )

			//if ( rating != 0.0 || currentRating != 0.0 )
				//print( "rating = " + rating + ", internal rating = " + currentRating )
		}
		//else
		//	print( "spawnpoint at " + spawnpoint.GetOrigin() + " has no rating" )
	}
}

void function InitPreferSpawnNodes()
{
	foreach ( entity hardpoint in GetEntArrayByClass_Expensive( "info_hardpoint" ) )
	{
		if ( !hardpoint.HasKey( "hardpointGroup" ) )
			continue

		if ( hardpoint.kv.hardpointGroup != "A" && hardpoint.kv.hardpointGroup != "B" && hardpoint.kv.hardpointGroup != "C" )
			continue

		spawnStateGeneric.preferSpawnNodes.append( hardpoint.GetOrigin() )
	}

	//foreach ( entity frontline in GetEntArrayByClass_Expensive( "info_frontline" ) )
	//	spawnStateGeneric.preferSpawnNodes.append( frontline.GetOrigin() )
}

// frontline
void function RateSpawnpoints_Frontline( int checkClass, array<entity> spawnpoints, int team, entity player )
{
	foreach ( entity spawnpoint in spawnpoints )
	{
		float rating = spawnpoint.CalculateFrontlineRating()
		spawnpoint.CalculateRating( checkClass, player.GetTeam(), rating, rating > 0 ? rating * 0.25 : rating )
	}
}

// spawnzones
struct {
	array<entity> mapSpawnzoneTriggers
	entity functionref( array<entity>, int ) spawnzoneRatingFunc
	bool shouldCreateMinimapSpawnzones = false

	// for DecideSpawnZone_Generic
	table<int, entity> activeTeamSpawnzones
	table<int, entity> activeTeamSpawnzoneMinimapEnts
} spawnStateSpawnzones

void function ResetSpawnzones()
{
	spawnStateSpawnzones.activeTeamSpawnzones.clear()

	foreach ( int team, entity minimapEnt in spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts )
		if ( IsValid( minimapEnt ) )
			minimapEnt.Destroy()

	spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts.clear()
}

void function AddSpawnZoneTrigger( entity trigger )
{
	trigger.s.spawnzoneRating <- 0.0
	spawnStateSpawnzones.mapSpawnzoneTriggers.append( trigger )
}

void function SetSpawnZoneRatingFunc( entity functionref( array<entity>, int ) ratingFunc )
{
	spawnStateSpawnzones.spawnzoneRatingFunc = ratingFunc
}

void function SetShouldCreateMinimapSpawnZones( bool shouldCreateMinimapSpawnzones )
{
	spawnStateSpawnzones.shouldCreateMinimapSpawnzones = shouldCreateMinimapSpawnzones
}

entity function CreateTeamSpawnZoneEntity( entity spawnzone, int team )
{
	entity minimapObj = CreatePropScript( $"models/dev/empty_model.mdl", spawnzone.GetOrigin() )
	SetTeam( minimapObj, team )
	//minimapObj.Minimap_SetObjectScale( Distance2D( < 0, 0, 0 >, spawnzone.GetBoundingMaxs() ) / 20000.0 )
	minimapObj.Minimap_SetObjectScale( 0.05 ) // proper map icon. though vanilla doesn't seem like this
	minimapObj.Minimap_SetAlignUpright( true )
	minimapObj.Minimap_SetClampToEdge( false ) // vanilla doesn't seem like you can see enemy's spawnpoint across map
	minimapObj.Minimap_AlwaysShow( TEAM_IMC, null )
	minimapObj.Minimap_AlwaysShow( TEAM_MILITIA, null )
	minimapObj.Minimap_SetHeightTracking( true )
	minimapObj.Minimap_SetZOrder( MINIMAP_Z_OBJECT )

	if ( team == TEAM_IMC )
		minimapObj.Minimap_SetCustomState( eMinimapObject_prop_script.SPAWNZONE_IMC )
	else
		minimapObj.Minimap_SetCustomState( eMinimapObject_prop_script.SPAWNZONE_MIL )

	minimapObj.DisableHibernation()
	return minimapObj
}

void function RateSpawnpoints_SpawnZones( int checkClass, array<entity> spawnpoints, int team, entity player )
{
	if ( spawnStateSpawnzones.spawnzoneRatingFunc == null )
		spawnStateSpawnzones.spawnzoneRatingFunc = DecideSpawnZone_Generic

	// don't use spawnzones if we're using start spawns
	if ( ShouldStartSpawn( player ) )
	{
		RateSpawnpoints_Generic( checkClass, spawnpoints, team, player )
		return
	}

	entity spawnzone = spawnStateSpawnzones.spawnzoneRatingFunc( spawnStateSpawnzones.mapSpawnzoneTriggers, player.GetTeam() )
	if ( !IsValid( spawnzone ) ) // no spawn zone, use generic algo
	{
		RateSpawnpoints_Generic( checkClass, spawnpoints, team, player )
		return
	}

	// rate spawnpoints
	foreach ( entity spawn in spawnpoints )
	{
		float rating = 0.0
		float distance = Distance2D( spawn.GetOrigin(), spawnzone.GetOrigin() )
		float radius = Distance2D( < 0, 0, 0 >, spawnzone.GetBoundingMaxs() )
		//print( "spawnzone radius:" + string( radius ) )
		if ( distance < radius )
			rating = 100.0
		else // max 35 rating if not in zone, rate by closest
			rating = 35.0 * ( 1 - ( distance / 5000.0 ) )

		// modified over here
		if ( HasEnemyNearSpawnPoint( team, spawn ) )
		{
			if ( rating > 0 )
				rating *= -0.6 // try not to spawn too close to enemy
		}
		else if ( HasFriendlyNearSpawnPoint( team, spawn ) )
		{
			if ( rating > 0 )
				rating = fabs ( rating * 2.0 ) // and mostly spawn near a friendly
		}

		if ( rating != 0 )
		{
			float calcedRating = spawn.CalculateRating( checkClass, player.GetTeam(), rating, rating )
			//print( "spawnpoint at " + spawn.GetOrigin() + " has rating: " + calcedRating )
		}
		//else
			//print( "spawnpoint at " + spawn.GetOrigin() + " has no rating" )
	}
}

entity function DecideSpawnZone_Generic( array<entity> spawnzones, int team )
{
	if ( spawnzones.len() == 0 )
		return null

	// get average team startspawn positions
	int spawnCompareTeam = team
	if ( ( IsSwitchSidesBased() && HasSwitchedSides() == 1 ) )
		spawnCompareTeam = GetOtherTeam( team )

	array<entity> startSpawns = SpawnPoints_GetPilotStart( spawnCompareTeam )
	array<entity> enemyStartSpawns = SpawnPoints_GetPilotStart( GetOtherTeam( spawnCompareTeam ) )

	if ( startSpawns.len() == 0 || enemyStartSpawns.len() == 0 ) // ensure we don't crash
		return null

	// get average startspawn position and max dist between spawns
	// could probably cache this, tbh, not like it should change outside of halftimes
	vector averageFriendlySpawns
	foreach ( entity spawn in startSpawns )
		averageFriendlySpawns += spawn.GetOrigin()

	averageFriendlySpawns /= startSpawns.len()

	// get average enemy startspawn position
	vector averageEnemySpawns
	foreach ( entity spawn in enemyStartSpawns )
		averageEnemySpawns += spawn.GetOrigin()

	averageEnemySpawns /= enemyStartSpawns.len()

	float baseDistance = Distance2D( averageFriendlySpawns, averageEnemySpawns )

	bool needNewZone = true
	if ( team in spawnStateSpawnzones.activeTeamSpawnzones )
	{
		foreach ( entity player in GetPlayerArray() )
		{
			// couldn't get IsTouching, GetTouchingEntities or enter callbacks to work in testing, so doing this
			if ( player.GetTeam() != team && spawnStateSpawnzones.activeTeamSpawnzones[ team ].ContainsPoint( player.GetOrigin() ) )
				break
		}

		int numDeadInZone = 0
		array<entity> teamPlayers = GetPlayerArrayOfTeam( team )
		foreach ( entity player in teamPlayers )
		{
			// check if they died in the zone recently, get a new zone if too many died
			if ( Time() - player.p.postDeathThreadStartTime < 15.0 && spawnStateSpawnzones.activeTeamSpawnzones[ team ].ContainsPoint( player.p.deathOrigin ) )
				numDeadInZone++
		}

		// cast to float so result is float
		if ( float( numDeadInZone ) / teamPlayers.len() <= 0.1 )
			needNewZone = false
	}

	if ( needNewZone )
	{
		// find new zone
		array<entity> possibleZones
		foreach ( entity spawnzone in spawnStateSpawnzones.mapSpawnzoneTriggers )
		{
			// don't remember if you can do a "value in table.values" sorta thing in squirrel so doing manual lookup
			bool spawnzoneTaken = false
			foreach ( int otherTeam, entity otherSpawnzone in spawnStateSpawnzones.activeTeamSpawnzones )
			{
				if ( otherSpawnzone == spawnzone )
				{
					spawnzoneTaken = true
					break
				}
			}

			if ( spawnzoneTaken )
				continue

			// check zone validity
			bool spawnzoneEvil = false
			foreach ( entity player in GetPlayerArray() )
			{
				// couldn't get IsTouching, GetTouchingEntities or enter callbacks to work in testing, so doing this
				if ( player.GetTeam() != team && spawnzone.ContainsPoint( player.GetOrigin() ) )
				{
					spawnzoneEvil = true
					break
				}
			}

			// don't choose spawnzones that are closer to enemy base than friendly base
			// note: vanilla spawns might not necessarily require this, worth checking
			//if ( !spawnzoneEvil && Distance2D( spawnzone.GetOrigin(), averageFriendlySpawns ) > Distance2D( spawnzone.GetOrigin(), averageEnemySpawns ) )
			//	spawnzoneEvil = true

			if ( spawnzoneEvil )
				continue

			// rate spawnzone based on distance to frontline
			Frontline frontline = GetFrontline( team )

			// prefer spawns close to base pos
			float rating = 10 * ( 1.0 - Distance2D( averageFriendlySpawns, spawnzone.GetOrigin() ) / baseDistance )

			if ( frontline.friendlyCenter != < 0, 0, 0 > )
			{
				// rate based on distance to frontline, and then prefer spawns in the same dir from the frontline as the combatdir
				rating += rating * ( 1.0 - ( Distance2D( spawnzone.GetOrigin(), frontline.friendlyCenter ) / baseDistance ) )
				rating *= fabs( frontline.combatDir.y - Normalize( spawnzone.GetOrigin() - averageFriendlySpawns ).y )
			}

			spawnzone.s.spawnzoneRating = rating
			possibleZones.append( spawnzone )
		}

		if ( possibleZones.len() == 0 )
			return null

		possibleZones.sort( int function( entity a, entity b )
		{
			if ( a.s.spawnzoneRating > b.s.spawnzoneRating )
				return -1

			if ( b.s.spawnzoneRating > a.s.spawnzoneRating )
				return 1

			return 0
		} )
		entity chosenZone = possibleZones[ minint( RandomInt( 3 ), possibleZones.len() - 1 ) ]

		if ( spawnStateSpawnzones.shouldCreateMinimapSpawnzones )
		{
			entity oldEnt
			if ( team in spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts )
				oldEnt = spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts[ team ]

			spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts[ team ] <- CreateTeamSpawnZoneEntity( chosenZone, team )
			if ( IsValid( oldEnt ) )
				oldEnt.Destroy()
		}

		spawnStateSpawnzones.activeTeamSpawnzones[ team ] <- chosenZone
	}

	return spawnStateSpawnzones.activeTeamSpawnzones[ team ]
}

// ideally this should be in the gamemode_ctf file, but would need refactors to expose more stuff that's not available there rn
entity function DecideSpawnZone_CTF( array<entity> spawnzones, int team )
{
	if ( spawnzones.len() == 0 )
		return null

	int otherTeam = GetOtherTeam( team )
	array<entity> enemyPlayers = GetPlayerArrayOfTeam( otherTeam )

	// get average team startspawn positions
	int spawnCompareTeam = team
	if ( ( IsSwitchSidesBased() && HasSwitchedSides() == 1 ) )
		spawnCompareTeam = GetOtherTeam( team )

	array<entity> startSpawns = SpawnPoints_GetPilotStart( spawnCompareTeam )
	array<entity> enemyStartSpawns = SpawnPoints_GetPilotStart( GetOtherTeam( spawnCompareTeam ) )

	if ( startSpawns.len() == 0 || enemyStartSpawns.len() == 0 ) // ensure we don't crash
		return null

	// get average startspawn position and max dist between spawns
	// could probably cache this, tbh, not like it should change outside of halftimes
	vector averageFriendlySpawns
	foreach ( entity spawn in startSpawns )
		averageFriendlySpawns += spawn.GetOrigin()

	averageFriendlySpawns /= startSpawns.len()

	// get average enemy startspawn position
	vector averageEnemySpawns
	foreach ( entity spawn in enemyStartSpawns )
		averageEnemySpawns += spawn.GetOrigin()

	averageEnemySpawns /= enemyStartSpawns.len()

	float baseDistance = Distance2D( averageFriendlySpawns, averageEnemySpawns )

	// find new zone
	array<entity> possibleZones
	foreach ( entity spawnzone in spawnStateSpawnzones.mapSpawnzoneTriggers )
	{
		// can't choose zone if another team has it
		if ( otherTeam in spawnStateSpawnzones.activeTeamSpawnzones && spawnStateSpawnzones.activeTeamSpawnzones[ otherTeam ] == spawnzone )
			continue

		// check zone validity
		bool spawnzoneEvil = false
		foreach ( entity player in enemyPlayers )
		{
			// couldn't get IsTouching, GetTouchingEntities or enter callbacks to work in testing, so doing this
			if ( spawnzone.ContainsPoint( player.GetOrigin() ) )
			{
				spawnzoneEvil = true
				break
			}
		}

		// don't choose spawnzones that are closer to enemy base than friendly base
		if ( !spawnzoneEvil && Distance2D( spawnzone.GetOrigin(), averageFriendlySpawns ) > Distance2D( spawnzone.GetOrigin(), averageEnemySpawns ) )
			spawnzoneEvil = true

		if ( spawnzoneEvil )
			continue

		// rate spawnzone based on distance to frontline
		Frontline frontline = GetFrontline( team )

		// prefer spawns close to base pos
		float rating = 10 * ( 1.0 - Distance2D( averageFriendlySpawns, spawnzone.GetOrigin() ) / baseDistance )

		if ( frontline.friendlyCenter != < 0, 0, 0 > )
		{
			// rate based on distance to frontline, and then prefer spawns in the same dir from the frontline as the combatdir
			rating += rating * ( 1.0 - ( Distance2D( spawnzone.GetOrigin(), frontline.friendlyCenter ) / baseDistance ) )
			rating *= fabs( frontline.combatDir.y - Normalize( spawnzone.GetOrigin() - averageFriendlySpawns ).y )

			// reduce rating based on players that can currently see the zone
			bool hasAppliedInitialLoss = false
			foreach ( entity player in enemyPlayers )
			{
				// don't trace here, just do an angle check
				if ( PlayerCanSee( player, spawnzone, false, 65 ) && Distance2D( player.GetOrigin(), spawnzone.GetOrigin() ) <= 2000.0 )
				{
					float distFrac = TraceLineSimple( player.GetOrigin(), spawnzone.GetOrigin(), player )

					if ( distFrac >= 0.65 )
					{
						// give a fairly large loss if literally anyone can see it
						if ( !hasAppliedInitialLoss )
						{
							rating *= 0.8
							hasAppliedInitialLoss = true
						}

						rating *= ( 1.0 / enemyPlayers.len() ) * distFrac
					}
				}
			}
		}

		spawnzone.s.spawnzoneRating = rating
		possibleZones.append( spawnzone )
	}

	if ( possibleZones.len() == 0 )
		return null

	possibleZones.sort( int function( entity a, entity b )
	{
		if ( a.s.spawnzoneRating > b.s.spawnzoneRating )
			return -1

		if ( b.s.spawnzoneRating > a.s.spawnzoneRating )
			return 1

		return 0
	} )
	entity chosenZone = possibleZones[ minint( RandomInt( 3 ), possibleZones.len() - 1 ) ]

	if ( spawnStateSpawnzones.shouldCreateMinimapSpawnzones )
	{
		entity oldEnt
		if ( team in spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts )
			oldEnt = spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts[ team ]

		spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts[ team ] <- CreateTeamSpawnZoneEntity( chosenZone, team )
		if ( IsValid( oldEnt ) )
			oldEnt.Destroy()
	}

	spawnStateSpawnzones.activeTeamSpawnzones[ team ] <- chosenZone

	return spawnStateSpawnzones.activeTeamSpawnzones[ team ]
}

// modified: make a new function so ai gamemodes don't have to re-decide for each spawn
entity function GetCurrentSpawnZoneForTeam( int team )
{
	if ( !( team in spawnStateSpawnzones.activeTeamSpawnzones ) )
		return null
	return spawnStateSpawnzones.activeTeamSpawnzones[ team ]
}