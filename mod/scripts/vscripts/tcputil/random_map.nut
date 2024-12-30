global function RandomMap_Init
global function RandomMap
global function ShowCustomTextOnPostmatch

const array<string> MAPS_ALL = [
	"mp_black_water_canal",
	"mp_complex3",
	"mp_crashsite3",
	"mp_drydock",
	"mp_eden",
	"mp_forwardbase_kodai",
	"mp_grave",
	"mp_homestead",
	"mp_thaw",
	"mp_angel_city",
	"mp_colony02",
	"mp_relic02",
	"mp_wargames",
	"mp_glitch",
	"mp_rise" ]

struct{
	array<string> mapPlaylist = []
	string customText = ""
}file

void function RandomMap_Init()
{
	file.mapPlaylist = GetStringArrayFromConVar( "random_map_playlist" )
	if( file.mapPlaylist.len() == 0 )
		return RandomMap( 0 )

	AddCallback_GameStateEnter( eGameState.Postmatch, GameStateEnter_Postmatch )
}

void function ShowCustomTextOnPostmatch( string text )
{
	file.customText = text
}

void function GameStateEnter_Postmatch()
{
	thread RandomMap( GAME_POSTMATCH_LENGTH - 0.1 )
}

void function RandomMap( float waitTime )
{
	int i = 0
	foreach( map in file.mapPlaylist )
	{
		if( GetMapName() == map )
			break
		i++
	}

	if( file.mapPlaylist.len() - 1 == i || file.mapPlaylist.len() == 0 )
	{
		file.mapPlaylist = RandomArrayElem( MAPS_ALL )
		i = 0
	}
	else
		i++

	string map = file.mapPlaylist[i]
	foreach( player in GetPlayerArray() )
		SendHudMessageWithPriority( player, 102, "下一局地图为："+ GetMapTitleName( map ) +"\n\n\n"+ file.customText, -1, 0.3, < 200, 200, 255 >, < 0.5, 10, 0 > )

	wait waitTime

	StoreStringArrayIntoConVar( file.mapPlaylist, "random_map_playlist" )
	ServerCommand( "map "+ map )
}

array<string> function RandomArrayElem( array<string> a )
{
	array<string> b = a
	array<string> c = []
	while( b.len() > 0 )
	{
		string randElem = b[ RandomInt( b.len() ) ]
		b.removebyvalue( randElem )
		c.append( randElem )
	}
	return c
}

string function GetMapTitleName( string map )
{
	switch( map )
	{
		case "mp_black_water_canal":
			return "黑水運河"
		case "mp_angel_city":
			return "天使城"
		case "mp_drydock":
			return "乾塢"
		case "mp_eden":
			return "伊甸"
		case "mp_colony02":
			return "殖民地"
		case "mp_relic02":
			return "遺跡"
		case "mp_grave":
			return "新興城鎮"
		case "mp_thaw":
			return "係外行星"
		case "mp_glitch":
			return "異常"
		case "mp_homestead":
			return "家園"
		case "mp_wargames":
			return "戰爭游戲"
		case "mp_forwardbase_kodai":
			return "虎大前進基地"
		case "mp_complex3":
			return "綜合設施"
		case "mp_rise":
			return "崛起"
		case "mp_crashsite3":
			return "墜機現場"
	}
	return "UNKNOWN"
}