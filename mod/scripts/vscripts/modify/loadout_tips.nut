untyped
global function LoadoutTips_Init

void function LoadoutTips_Init()
{
	AddSpawnCallback( "npc_titan", OnTitanfall )
	AddCallback_OnClientConnected( OnClientConnected )
}

void function OnClientConnected( entity player )
{
	player.s.lastTitanLoadout <- "init"
}

void function OnTitanfall( entity titan )
{
	entity soul = titan.GetTitanSoul()
	if( !IsValid( soul ) )
		return
	entity player = titan
	if( !player.IsPlayer() )
		player = GetPetTitanOwner( titan )
	if( !IsValid( player ) )
		return
	string tips = ""
	if( player.s.lastTitanLoadout == GetTitanName( titan ) )
		return
	player.s.lastTitanLoadout = GetTitanName( titan )
	tips += "当前泰坦"
	if( IsCustomTitan( titan ) )
		tips += "被替换"
	tips += "为: "+ GetTitanName( titan ) +"\n"

	if( GetTitanName( titan ) == "遠征" )
		tips += "关闭\"帝王边境\"皮肤"
	else if( GetTitanName( titan ) == "帝王" )
		tips += "携带\"帝王边境\"皮肤"
	else if( IsCustomTitan( titan ) )
		tips += "关闭至尊涂装"
	else
		tips += "携带至尊涂装"

	tips += "以启用"
	if( IsCustomTitan( titan ) )
		tips += "原版泰坦"
	else
		tips += "客制化泰坦"
	tips += ": "+ GetSwitchedTitan( titan )

	SendHudMessage( player, tips,  -1, 0.3, 200, 200, 225, 255, 0.15, 5, 1 )
}

string function GetTitanName( entity titan )
{
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_ion_prime.mdl" )
		return "執政官"
	if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_scorch_prime.mdl" )
		return "野牛"
	if( titan.GetModelName() == $"models/titans/light/titan_light_northstar_prime.mdl" )
		return "野獸四號"
	if( titan.GetModelName() == $"models/titans/light/titan_light_ronin_prime.mdl" )
		return "游俠"
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_tone_prime.mdl" )
		return "天圖"
	if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_legion_prime.mdl" )
		return "巨妖"
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() == -1 && titan.GetSkin() == 3 )
		return "遠征"
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_ajax.mdl" )
		return "離子"
	if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_ogre.mdl" )
		return "烈焰"
	if( titan.GetModelName() == $"models/titans/light/titan_light_raptor.mdl" )
		return "北極星"
	if( titan.GetModelName() == $"models/titans/light/titan_light_locust.mdl" )
		return "浪人"
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_wraith.mdl" )
		return "強力"
	if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_deadbolt.mdl" )
		return "軍團"
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && ( titan.GetCamo() != -1 || titan.GetSkin() != 3 ) )
		return "帝王"
	unreachable
}

bool function IsCustomTitan( entity titan )
{
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_ion_prime.mdl" )
		return true
	if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_scorch_prime.mdl" )
		return true
	if( titan.GetModelName() == $"models/titans/light/titan_light_northstar_prime.mdl" )
		return true
	if( titan.GetModelName() == $"models/titans/light/titan_light_ronin_prime.mdl" )
		return true
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_tone_prime.mdl" )
		return true
	if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_legion_prime.mdl" )
		return true
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() == -1 && titan.GetSkin() == 3 )
		return true
	return false
}

string function GetSwitchedTitan( entity titan )
{
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_ion_prime.mdl" )
		return "離子"
	if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_scorch_prime.mdl" )
		return "烈焰"
	if( titan.GetModelName() == $"models/titans/light/titan_light_northstar_prime.mdl" )
		return "北極星"
	if( titan.GetModelName() == $"models/titans/light/titan_light_ronin_prime.mdl" )
		return "浪人"
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_tone_prime.mdl" )
		return "強力"
	if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_legion_prime.mdl" )
		return "軍團"
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() == -1 && titan.GetSkin() == 3 )
		return "帝王"
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_ajax.mdl" )
		return "執政官"
	if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_ogre.mdl" )
		return "野牛"
	if( titan.GetModelName() == $"models/titans/light/titan_light_raptor.mdl" )
		return "野獸四號"
	if( titan.GetModelName() == $"models/titans/light/titan_light_locust.mdl" )
		return "游俠"
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_wraith.mdl" )
		return "天圖"
	if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_deadbolt.mdl" )
		return "巨妖"
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && ( titan.GetCamo() != -1 || titan.GetSkin() != 3 ) )
		return "遠征"
	unreachable
}