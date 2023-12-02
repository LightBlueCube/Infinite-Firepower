global function DevTrackUsage_Init

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
	*/

	// modify titan //
	m1 = $"models/titans/medium/titan_medium_ion_prime.mdl"
	m2 = $"models/titans/heavy/titan_heavy_scorch_prime.mdl"
	m3 = $"models/titans/light/titan_light_northstar_prime.mdl"
	m4 = $"models/titans/light/titan_light_ronin_prime.mdl"
	m5 = $"models/titans/medium/titan_medium_tone_prime.mdl"
	m6 = $"models/titans/heavy/titan_heavy_legion_prime.mdl"
}

table<string,int> USAGE_TIME = {

	v1 = 0
	v2 = 0
	v3 = 0
	v4 = 0
	v5 = 0
	v6 = 0
	v7 = 0

	m1 = 0
	m2 = 0
	m3 = 0
	m4 = 0
	m5 = 0
	m6 = 0
	m7 = 0

	none = 0
}

void function DevTrackUsage_Init()
{
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddCallback_OnNPCKilled( OnPlayerKilled )
	thread TrackUsageTime()
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
			USAGE_TIME[ GetTitanID( player ) ] += 5
		}

		foreach( string key, int val in USAGE_TIME )
		{
			if( val < 60 )
				continue
			while( val >= 60 )
			{
				printt( "[devUsage] min "+ key )
				USAGE_TIME[ key ] -= 60
				val -= 60
			}
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
			if( !IsValid( GetPetTitanOwner( ent ) ) )
				return
	}

	printt( "[devUsage] kill "+ GetTitanID( attacker ) )
	printt( "[devUsage] death "+ GetTitanID( victim ) )
}