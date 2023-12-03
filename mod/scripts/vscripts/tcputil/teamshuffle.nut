untyped
global function TeamShuffle_Init

const array<string> SHUFFLE_DISABLED_GAMEMODES = ["private_match", "lts", "cp", "fw", "at"] // gamemodes that can't update it's team-colored rui shouldn't have shuffle
const array<string> SWITCH_DISABLED_GAMEMODES = ["private_match", "lts", "cp", "fw", "at"] // gamemodes that can't update it's team-colored rui shouldn't have shuffle
const array<string> DISABLED_MAPS = ["mp_lobby"]

const array<string> MANUAL_SWITCH_COMMANDS = // chat command will append a "!"
[
	"switch",
	"!switch",
	"！switch",

	"SWITCH",
	"!SWITCH",
	"！SWITCH",

	"Switch",
	"!Switch",
	"！Switch",
]

const int BALANCE_ALLOWED_TEAM_DIFFERENCE = 1
const bool BALANCE_ON_DEATH = true

const string ANSI_COLOR_ERROR = "\x1b[38;5;196m"
const string ANSI_COLOR_TEAM = "\x1b[38;5;81m"
const string ANSI_COLOR_ENEMY = "\x1b[38;5;208m"

struct
{
	bool hasShuffled = false
	float unBalanceTime = -1
} file

void function TeamShuffle_Init()
{
	AddCallback_GameStateEnter( eGameState.Prematch, ShuffleTeams )
	AddCallback_GameStateEnter( eGameState.Postmatch, GameStateEnter_Postmatch )
	AddCallback_OnClientDisconnected( CheckPlayerDisconnect )
	if ( BALANCE_ON_DEATH )
		AddCallback_OnPlayerKilled( CheckTeamBalance )

	// manual team switch
	foreach ( string command in MANUAL_SWITCH_COMMANDS )
	{
		AddClientCommandCallback( command, CC_TrySwitchTeam )
		AddChatCommandCallback( command, CC_TrySwitchTeam )
	}
}

bool function CC_TrySwitchTeam( entity player, array<string> args )
{
	// Check if the gamemode or map are on the blacklist
	bool gamemodeDisable = SWITCH_DISABLED_GAMEMODES.contains(GAMETYPE) || IsFFAGame();
	bool mapDisable = DISABLED_MAPS.contains(GetMapName());

	// Blacklist guards
  	if ( gamemodeDisable )
	{
		Chat_ServerPrivateMessage( player, ANSI_COLOR_ERROR + "当前模式不可切换队伍", false ) // chathook has been fucked up
		return true
	}

  	if ( mapDisable )
	{
		Chat_ServerPrivateMessage( player, ANSI_COLOR_ERROR + "当前地图不可切换队伍", false ) // chathook has been fucked up
		return true
	}

	if ( player.isSpawning )
	{
		Chat_ServerPrivateMessage( player, ANSI_COLOR_ERROR + "作为泰坦复活途中，不可切换队伍", false ) // chathook has been fucked up
		return true
	}

	if ( player.GetParent() )
	{
		Chat_ServerPrivateMessage( player, ANSI_COLOR_ERROR + "有被绑定的父级实体，不可切换队伍", false ) // chathook has been fucked up
		return true
	}

	if ( GetPlayerArray().len() == 1 )
	{
		Chat_ServerPrivateMessage( player, ANSI_COLOR_ERROR + "人数不足，不可切换队伍", false ) // chathook has been fucked up
		return true
	}

	// Check if difference is smaller than 2 ( dont balance when it is 0 or 1 )
	if( abs ( GetPlayerArrayOfTeam( TEAM_IMC ).len() - GetPlayerArrayOfTeam( TEAM_MILITIA ).len() ) <= BALANCE_ALLOWED_TEAM_DIFFERENCE )
	{
		Chat_ServerPrivateMessage( player, ANSI_COLOR_ERROR + "队伍已平衡，不可切换队伍", false ) // chathook has been fucked up
		return true
	}

	if( !IsAlive( player ) )
	{
		PlayerTrySwitchTeam( player, true ) // we fix respawn
		Chat_ServerPrivateMessage( player, ANSI_COLOR_TEAM + "已切换队伍", false )
		return true
	}
	PlayerTrySwitchTeam( player, true ) // we fix respawn
	Chat_ServerPrivateMessage( player, ANSI_COLOR_TEAM + "已切换队伍，此次死亡不会丢失连杀", false )
	player.s.DontRestore <- true

	return true
}

ClServer_MessageStruct function Chat_TrySwitchTeam( ClServer_MessageStruct msgStruct )
{
	entity sender = msgStruct.player
	CC_TrySwitchTeam( sender, [] )
	msgStruct.shouldBlock = true // always block the message
	return msgStruct
}

void function CheckPlayerDisconnect( entity player )
{
	// since this player may not being destroyed, should do a new check here
	bool playerStillValid = IsValid( player )
	int team = -1
	if ( playerStillValid )
		team = player.GetTeam()
	// Check if the gamemode or map are on the blacklist
	bool gamemodeDisable = SWITCH_DISABLED_GAMEMODES.contains(GAMETYPE) || IsFFAGame()
	bool mapDisable = DISABLED_MAPS.contains(GetMapName())

	// Blacklist guards
  	if ( gamemodeDisable )
		return

  	if ( mapDisable )
		return

	if ( GetPlayerArray().len() == 1 )
		return

	// Check if difference is smaller than 2 ( dont balance when it is 0 or 1 )
	int imcTeamSize = GetPlayerArrayOfTeam( TEAM_IMC ).len()
	int mltTeamSize = GetPlayerArrayOfTeam( TEAM_MILITIA ).len()
	if ( playerStillValid ) // disconnecting player still valid
	{
		// do reduced teamsize
		if ( team == TEAM_IMC )
			imcTeamSize -= 1
		if ( team == TEAM_MILITIA )
			mltTeamSize -= 1
	}
	if( abs ( imcTeamSize - mltTeamSize ) <= BALANCE_ALLOWED_TEAM_DIFFERENCE )
		return

	if( file.unBalanceTime == -1 )
		file.unBalanceTime = Time()

	int weakTeam = imcTeamSize > mltTeamSize ? TEAM_MILITIA : TEAM_IMC
	foreach ( entity player in GetPlayerArrayOfTeam( GetOtherTeam( weakTeam ) ) )
		Chat_ServerPrivateMessage( player, ANSI_COLOR_ENEMY + "队伍当前不平衡，可通过输入 !switch 切换队伍。", false )
}

void function GameStateEnter_Postmatch()
{
	thread ShuffleTeams_Waiting()
}
void function ShuffleTeams_Waiting()
{
	wait GAME_POSTMATCH_LENGTH - 0.2
	TeamShuffleThink()
}

void function ShuffleTeams()
{
	bool gamemodeDisable = SWITCH_DISABLED_GAMEMODES.contains(GAMETYPE) || IsFFAGame()
	bool mapDisable = DISABLED_MAPS.contains(GetMapName())

	// Blacklist guards
  	if ( gamemodeDisable )
		return

  	if ( mapDisable )
		return

	file.hasShuffled = false
	TeamShuffleThink()
}

void function TeamShuffleThink()
{
	if( file.hasShuffled )
		return
 	if ( GetPlayerArray().len() == 0 )
		return

  	// Set team to TEAM_UNASSIGNED
  	foreach ( player in GetPlayerArray() )
		SetTeam ( player, TEAM_UNASSIGNED )

  	int maxTeamSize = GetPlayerArray().len() / 2

  	// Assign teams
  	foreach ( player in GetPlayerArray() )
  	{
		if( !IsValid( player ) )
	  		continue

		// Get random team
		int team = RandomIntRange( TEAM_IMC, TEAM_MILITIA + 1 )
		// Gueard for team size
		if ( GetPlayerArrayOfTeam( team ).len() >= maxTeamSize )
		{
	  		SetTeam( player, GetOtherTeam( team ) )
	  			continue
		}
	//
		SetTeam( player, team )
	}
	FixShuffle()
	file.hasShuffled = true
}

void function FixShuffle()
{
	int mltTeamSize = GetPlayerArrayOfTeam( TEAM_MILITIA ).len()
	int imcTeamSize = GetPlayerArrayOfTeam( TEAM_IMC ).len()
	int teamSizeDifference = abs( mltTeamSize - imcTeamSize )
  	if( teamSizeDifference <= BALANCE_ALLOWED_TEAM_DIFFERENCE )
		return

	if ( GetPlayerArray().len() == 1 )
		return

	int timeShouldBeDone = teamSizeDifference - BALANCE_ALLOWED_TEAM_DIFFERENCE
	int largerTeam = imcTeamSize > mltTeamSize ? TEAM_IMC : TEAM_MILITIA
	array<entity> largerTeamPlayers = GetPlayerArrayOfTeam( largerTeam )

	int largerTeamIndex = 0
	entity poorGuy
	int oldTeam
	// fix shuffle is done before match start, no need to use PlayerTrySwitchTeam()
	for( int i = 0; i < timeShouldBeDone; i ++ )
	{
		poorGuy = largerTeamPlayers[ largerTeamIndex ]
		largerTeamIndex += 1

		int oldTeam = poorGuy.GetTeam()
		SetTeam( poorGuy, GetOtherTeam( largerTeam ) )
	}
}

void function RespawnAsPilotInAfterFrame( entity poorGuy )
{
	WaitFrame()
	if( IsValid( poorGuy ) )
		if( !IsAlive( poorGuy ) )
			RespawnAsPilot( poorGuy )
}

void function WaitForPlayerRespawnThenNotify( entity player )
{
	player.EndSignal( "OnDestroy" )

	player.WaitSignal( "OnRespawned" )
	SendHudMessage( player, "由于队伍人数不平衡，你已被重新分队", -1, 0.4, 200, 200, 225, 0, 0.15, 3.5, 0.5 )
}

void function CheckTeamBalance( entity victim, entity attacker, var damageInfo )
{
	if( file.unBalanceTime + 90 > Time() )
		return
	// general check
  	if ( !CanChangeTeam() )
		return

	// Compare victims teams size
	if ( GetPlayerArrayOfTeam( victim.GetTeam() ).len() < GetPlayerArrayOfTeam( GetOtherTeam( victim.GetTeam() ) ).len() )
		return


	// We passed all checks, balance the teams
	PlayerTrySwitchTeam( victim )
	Chat_ServerPrivateMessage( victim, ANSI_COLOR_TEAM + "由于队伍人数不平衡，你已被重新分队", false )
	thread WaitForPlayerRespawnThenNotify( victim )
}

bool function CanChangeTeam()
{
	// Check if the gamemode or map are on the blacklist
	bool gamemodeDisable = SWITCH_DISABLED_GAMEMODES.contains(GAMETYPE) || IsFFAGame();
	bool mapDisable = DISABLED_MAPS.contains(GetMapName());

	// Blacklist guards
  	if ( gamemodeDisable )
		return false

  	if ( mapDisable )
		return false

	// Check if difference is smaller than 2 ( dont balance when it is 0 or 1 )
	// May be too aggresive ??
	if( abs ( GetPlayerArrayOfTeam( TEAM_IMC ).len() - GetPlayerArrayOfTeam( TEAM_MILITIA ).len() ) <= BALANCE_ALLOWED_TEAM_DIFFERENCE )
		return false

	if ( GetPlayerArray().len() == 1 )
		return false

	return true
}

// main utility
bool function PlayerTrySwitchTeam( entity player, bool fixRespawn = false )
{
	//string playerFaction = GetFactionChoice( player )
	//string enemyFaction = GetEnemyFaction( player )

	int oldTeam = player.GetTeam()
	SetTeam( player, GetOtherTeam( player.GetTeam() ) )
	NotifyClientsOfTeamChange( player, oldTeam, player.GetTeam() )

	if( IsAlive( player ) ) // poor guy
	{
		player.Die( null, null, { damageSourceId = eDamageSourceId.team_switch } ) // better
		if ( player.GetPlayerGameStat( PGS_DEATHS ) >= 1 ) // reduce the death count
			player.AddToPlayerGameStat( PGS_DEATHS, -1 )
	}

	if( fixRespawn && !RespawnsEnabled() ) // do need respawn the guy if respawnsdisabled
		thread RespawnAsPilotInAfterFrame( player )

	// re-assign faction
	//player.SetPersistentVar( "factionChoice", enemyFaction )
	//player.SetPersistentVar( "enemyFaction", playerFaction )

	// change pet titan's team
	entity titan = player.GetPetTitan()
	if ( IsValid( titan ) )
		SetTeam( titan, player.GetTeam() )
	// destroy all leeched npcs so server won't crash on next leeching
	foreach ( entity npc in GetLeechedEnts( player ) )
		npc.Die()

	if ( !CanChangeTeam() )
		file.unBalanceTime = -1

	return true
}

/* // pandora version
bool function ClientCommand_SwitchTeam( entity player, array<string> args )
{
	if( !IsValid( player ) )
		return false

	int PlayerTeam = player.GetTeam()
	int EnemyTeam = GetEnemyTeam( PlayerTeam )
	entity PetTitan = player.GetPetTitan()
	string PlayerFaction = GetFactionChoice( player )
	string EnemyFaction = GetEnemyFaction( player )
	int PlayerTeamCount = GetPlayerArrayOfTeam( PlayerTeam ).len()
		int EnemyTeamCount = GetPlayerArrayOfTeam( EnemyTeam ).len()
	int MaxPlayers = GetGamemodeVarOrUseValue( GetConVarString( "ns_private_match_last_mode" ), "max_players", "12" ).tointeger()

	if( PlayerTeam != TEAM_MILITIA && PlayerTeam != TEAM_IMC )
	{
		SendHudMessage( player, "#PATCH_BLANK", -1, 0.33, 192, 255, 0, 255, 0.0, 3.0, 0.0 )
		return false
	}

	if( PlayerTeamCount + EnemyTeamCount >= MaxPlayers )
	{
		SendHudMessage( player, "#PRIVATE_MATCH_NOT_READY_TEAMS", -1, 0.33, 192, 255, 0, 255, 0.0, 3.0, 0.0 )
		return false
	}

	if( EnemyTeamCount - PlayerTeamCount > 1 )
	{
		SendHudMessage( player, "#PRIVATE_MATCH_NOT_READY_TEAMS", -1, 0.33, 192, 255, 0, 255, 0.0, 3.0, 0.0 )
		return false
	}

	if( IsAlive( player ) )
	{
		SendHudMessage( player, "#CONVO_S2S_WELLIMNOTDEAD", -1, 0.33, 192, 255, 0, 255, 0.0, 3.0, 0.0 )
		return false
		/ayer.Die( svGlobal.worldspawn, svGlobal.worldspawn, { damageSourceId = eDamageSourceId.team_switch } )
	}

	if( IsValid( PetTitan ) && player.IsTitan() )
	{
		SendHudMessage( player, "#CONVO_S2S_WELLIMNOTDEAD", -1, 0.33, 192, 255, 0, 255, 0.0, 3.0, 0.0 )
		return false
	}
	else if( IsValid( PetTitan ) && !player.IsTitan() )
	{
		//Kill that auto titan
		PetTitan.Die( svGlobal.worldspawn, svGlobal.worldspawn, { damageSourceId = eDamageSourceId.team_switch } )
	}

	if( PlayerTeam == TEAM_IMC )
	{
		SetTeam( player, TEAM_MILITIA )
	}
	else if( PlayerTeam == TEAM_MILITIA )
	{
		SetTeam( player, TEAM_IMC )
	}

	player.SetPersistentVar( "factionChoice", EnemyFaction )
	player.SetPersistentVar( "enemyFaction", PlayerFaction )

	SendHudMessage( player, "#SWITCH_TEAMS", -1, 0.33, 192, 255, 0, 255, 0.0, 3.0, 0.0 )
	return true
}
*/