global function DevTrackUsage_Init
global function SavingUsageData

string HTTP_IO_URL = "192.168.50.2:1145"

table<string,asset> TITAN_ID = {	// the key only can use type string, its sucks

	// vanilla titan //
	v1 = $"models/titans/medium/titan_medium_ajax.mdl"
	v2 = $"models/titans/heavy/titan_heavy_ogre.mdl"
	v3 = $"models/titans/light/titan_light_raptor.mdl"
	v4 = $"models/titans/light/titan_light_locust.mdl"
	v5 = $"models/titans/medium/titan_medium_wraith.mdl"
	v6 = $"models/titans/heavy/titan_heavy_deadbolt.mdl"
	v7 = $"models/titans/medium/titan_medium_vanguard.mdl"

	/*
	离子
	烈焰
	北极星
	浪人
	强力
	军团
	帝王
	*/

	// modify titan //
	m1 = $"models/titans/medium/titan_medium_ion_prime.mdl"
	m2 = $"models/titans/heavy/titan_heavy_scorch_prime.mdl"
	m3 = $"models/titans/light/titan_light_northstar_prime.mdl"
	m4 = $"models/titans/light/titan_light_ronin_prime.mdl"
	m5 = $"models/titans/medium/titan_medium_tone_prime.mdl"
	m6 = $"models/titans/heavy/titan_heavy_legion_prime.mdl"
}

table<string,int> USAGE_DATA = {

	v1 = 0
	v1_gd = 0
	v1_td = 0
	v1_k = 0
	v1_d = 0
	v2 = 0
	v2_gd = 0
	v2_td = 0
	v2_k = 0
	v2_d = 0
	v3 = 0
	v3_gd = 0
	v3_td = 0
	v3_k = 0
	v3_d = 0
	v4 = 0
	v4_gd = 0
	v4_td = 0
	v4_k = 0
	v4_d = 0
	v5 = 0
	v5_gd = 0
	v5_td = 0
	v5_k = 0
	v5_d = 0
	v6 = 0
	v6_gd = 0
	v6_td = 0
	v6_k = 0
	v6_d = 0
	v7 = 0
	v7_gd = 0
	v7_td = 0
	v7_k = 0
	v7_d = 0

	m1 = 0
	m1_gd = 0
	m1_td = 0
	m1_k = 0
	m1_d = 0
	m2 = 0
	m2_gd = 0
	m2_td = 0
	m2_k = 0
	m2_d = 0
	m3 = 0
	m3_gd = 0
	m3_td = 0
	m3_k = 0
	m3_d = 0
	m4 = 0
	m4_gd = 0
	m4_td = 0
	m4_k = 0
	m4_d = 0
	m5 = 0
	m5_gd = 0
	m5_td = 0
	m5_k = 0
	m5_d = 0
	m6 = 0
	m6_gd = 0
	m6_td = 0
	m6_k = 0
	m6_d = 0
	m7 = 0
	m7_gd = 0
	m7_td = 0
	m7_k = 0
	m7_d = 0
}

void function DevTrackUsage_Init()
{
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddCallback_OnNPCKilled( OnPlayerKilled )
	AddCallback_GameStateEnter( eGameState.Postmatch, SavingUsageData )
	AddDamageFinalCallback( "player", OnPlayerFinalDamaged )
	thread TrackUsageTime()
}

void function OnPlayerFinalDamaged( entity victim, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	foreach( entity ent in [ attacker, victim ] )
	{
		if( !IsValid( ent ) )
			return

		if( !ent.IsTitan() )
			return
		if( ent.IsNPC() )
			return
	}
	if( attacker.GetTeam() == victim.GetTeam() || attacker == victim )
		return

	string id = GetTitanID( attacker )
	int damage = int( DamageInfo_GetDamage( damageInfo ) )
	if( id != "none" )
		USAGE_DATA[ id + "_gd" ] += damage
	id = GetTitanID( victim )
	if( id != "none" )
		USAGE_DATA[ id + "_td" ] += damage

}

void function SavingUsageData()
{
	if( HTTP_IO_URL == "" )
		return

	HttpRequest request
	request.method = HttpRequestMethod.GET
	request.url = HTTP_IO_URL + "/read_data"
	NSHttpRequest( request, LoadUsage, debugFunc )
}

void function debugFunc( HttpRequestFailure response )
{
	printt( "faild to get request / error code:"+ response.errorCode )
	printt( "error message: "+ response.errorMessage )
}

void function LoadUsage( HttpRequestResponse response )
{
	printt( "get request / status code:"+ response.statusCode )
	table data = DecodeJSON( response.body )

	foreach( string k, int v in USAGE_DATA )
	{
		if( !( k in data ) )
			data[ k ] <- 0
		data[ k ] = string( data[ k ] ).tointeger() + v
	}

	thread NSHttpPostBody( HTTP_IO_URL + "/write_data", EncodeJSON( data ) )
}

string function GetTitanID( entity titan )
{
	asset model = titan.GetModelName()
	string id = "none"
	foreach( string key, asset val in TITAN_ID )
	{
		if( model == val )
		{
			id = key
			break
		}
	}
	if( id == "v7" && titan.GetCamo() == -1 && titan.GetSkin() == 3 )
		return "m7"
	return id
}


void function TrackUsageTime()
{
	for( ;; )
	{
		wait 5
		foreach( player in GetPlayerArray() )
		{
			if( !IsValid( player ) )
				continue
			if( !player.IsTitan() )
			{
				player = player.GetPetTitan()
				if( !IsValid( player ) )
					continue
			}
			string id = GetTitanID( player )
			if( id == "none" )
				continue
			USAGE_DATA[ id ] += 5
		}
	}
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	foreach( entity ent in [ attacker, victim ] )
	{
		if( !IsValid( ent ) )
			return

		if( !ent.IsTitan() )
			return
		if( ent.IsNPC() )
			return
	}
	if( attacker.GetTeam() == victim.GetTeam() || attacker == victim )
		return

	string id = GetTitanID( attacker )
	if( id != "none" )
		USAGE_DATA[ id + "_k" ] += 1
	id = GetTitanID( victim )
	if( id != "none" )
		USAGE_DATA[ id + "_d" ] += 1
}