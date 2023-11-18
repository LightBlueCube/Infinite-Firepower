global function RandomMap_Init
global function RandomMap

void function RandomMap_Init()
{
	AddCallback_GameStateEnter( eGameState.Postmatch, GameStateEnter_Postmatch )
	if( [ "mp_rise", "mp_eden" ].contains( GetMapName() ) || RandomInt( 3 ) == 0 )
		AddCallback_OnClientConnected( OnClientConnected )
}

void function OnClientConnected( entity player )
{
    thread SetPlayerToNightSky( player )
}

void function GameStateEnter_Postmatch()
{
	thread RandomMapWaiting()
}
void function RandomMapWaiting()
{
	wait GAME_POSTMATCH_LENGTH - 0.1
	RandomMap()
}
void function RandomMap()
{
	int RandomInt = RandomInt( 15 )
	switch( RandomInt )
	{
		case 0:
			if( GetMapName() == "mp_black_water_canal" )
				return RandomMap()
			ServerCommand( "map mp_black_water_canal" )
			break
		case 1:
			if( GetMapName() == "mp_complex3" )
				return RandomMap()
			ServerCommand( "map mp_complex3" )
			break
		case 2:
			if( GetMapName() == "mp_crashsite3" )
				return RandomMap()
			ServerCommand( "map mp_crashsite3" )
			break
		case 3:
			if( GetMapName() == "mp_drydock" )
				return RandomMap()
			ServerCommand( "map mp_drydock" )
			break
		case 4:
			if( GetMapName() == "mp_eden" )
				return RandomMap()
			ServerCommand( "map mp_eden" )
			break
		case 5:
			if( GetMapName() == "mp_forwardbase_kodai" )
				return RandomMap()
			ServerCommand( "map mp_forwardbase_kodai" )
			break
		case 6:
			if( GetMapName() == "mp_grave" )
				return RandomMap()
			ServerCommand( "map mp_grave" )
			break
		case 7:
			if( GetMapName() == "mp_homestead" )
				return RandomMap()
			ServerCommand( "map mp_homestead" )
			break
		case 8:
			if( GetMapName() == "mp_thaw" )
				return RandomMap()
			ServerCommand( "map mp_thaw" )
			break
		case 9:
			if( GetMapName() == "mp_angel_city" )
				return RandomMap()
			ServerCommand( "map mp_angel_city" )
			break
		case 10:
			if( GetMapName() == "mp_colony02" )
				return RandomMap()
			ServerCommand( "map mp_colony02" )
			break
		case 11:
			if( GetMapName() == "mp_relic02" )
				return RandomMap()
			ServerCommand( "map mp_relic02" )
			break
		case 12:
			if( GetMapName() == "mp_wargames" )
				return RandomMap()
			ServerCommand( "map mp_wargames" )
			break
		case 13:
			if( GetMapName() == "mp_glitch" )
				return RandomMap()
			ServerCommand( "map mp_glitch" )
			break
		case 14:
			if( GetMapName() == "mp_rise" )
				return RandomMap()
			ServerCommand( "map mp_rise" )
			break
		default:
			break
	}
}