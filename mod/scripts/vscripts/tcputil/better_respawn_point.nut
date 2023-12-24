global function BetterRespawnPoint_Init
global function GetBetterSpawnPoint
global function SvmPredictEnable
global function SetSvmPredictEnable
global function BetterRespawnPointEnable
global function SetBetterRespawnPointEnable

struct{
	bool svmPredictEnable = true
	bool betterRespawnPointEnable = true
}file

void function BetterRespawnPoint_Init()
{
	AddSpawnpointValidationRule( CustomRespawnpointValidationRule )
}

bool function CustomRespawnpointValidationRule( entity spawnpoint, int team )
{
	if( SvmPredictEnable() && NSSvmPredict( NSSvmTrain( GetSvmTrainData() ), spawnpoint.GetOrigin() ) != team && spawnpoint.GetTeam() <= 0 )
		return false
	return true
}

array<table> function GetSvmTrainData()
{
	array<table> data
	foreach( player in GetPlayerArray() )
	{
		data.append({
			pos = player.GetOrigin(),
			team = player.GetTeam()
		})
	}
	return data
}

bool function SvmPredictEnable()
{
	return file.svmPredictEnable
}

void function SetSvmPredictEnable( bool state )
{
	file.betterRespawnPointEnable = state
}

bool function BetterRespawnPointEnable()
{
	return file.betterRespawnPointEnable
}

void function SetBetterRespawnPointEnable( bool state )
{
	file.betterRespawnPointEnable = state
}

entity function GetBetterSpawnPoint( int team, array<entity> points, float range = 2000, int callTimes = 0 )
{
	array<vector> friendlyPos
	array<vector> enemyPos
	bool hasAlivePlayer = false
	foreach( player in GetPlayerArray() )
	{
		if( !IsAlive( player ) )
			continue
		hasAlivePlayer = true
		if( player.GetTeam() == team )
			friendlyPos.append( player.GetOrigin() )
		else
			enemyPos.append( player.GetOrigin() )
	}
	if( !hasAlivePlayer || callTimes >= 10 || GetPlayerArray().len() <= 1 )
		return points[ RandomInt( points.len() ) ]


	float weightSave = 0
	int arrayNum = -1
	int target = -1
	foreach( point in points )
	{
		arrayNum++
		vector pointPos = point.GetOrigin()
		bool haveFriendly = false
		bool haveEmeny = false
		float weight = 0

		foreach( pos in enemyPos )
		{

			float distance = Distance( pos, pointPos )
			if( distance > range )
				continue
			if( distance <= range * 0.5 )
				weight += -4
			else if( distance <= range )
			{
				if( haveEmeny )
				{
					weight += -1
					continue
				}

				haveEmeny = true
				weight += 2
				weight += GraphCapped( distance, range * 0.5, range, 0, 0.1 )
			}
		}
		foreach( pos in friendlyPos )
		{
			float distance = Distance( pos, pointPos )
			if( distance > range )
				continue
			haveFriendly = true
			if( haveEmeny )
			{
				weight += 1
				weight += GraphCapped( distance, range, 0, 0, 0.1 )
			}
			else
			{
				weight += 0.6
				weight += GraphCapped( fabs( distance - range * 0.5 ), range * 0.5, 0, 0, 0.9 )
			}

		}
		if( !haveFriendly )
			weight += -1

		if( weight > weightSave )
		{
			weightSave = weight
			target = arrayNum
		}
	}

	if( target < 0 )
		return GetBetterSpawnPoint( team, points, range + 500, callTimes + 1 )

	return points[ target ]
}