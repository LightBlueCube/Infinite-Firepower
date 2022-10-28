global function tcpback

void function tcpback()
{
	AddSpawnCallback("npc_titan", OnTitanfall )
}

void function OnTitanfall( entity titan )
{
	SetTitanLoadoutReplace( titan )
}

void function SetTitanLoadoutReplace( entity titan )
{
	entity player = GetPetTitanOwner( titan )
	if( !IsValid( player ) )
		return
	if( titan.GetModelName() == $"models/titans/light/titan_light_northstar_prime.mdl" )
	{
		SendHudMessage(player, "已启用野兽泰坦装备，取消至尊泰坦以使用原版北极星",  -1, 0.3, 200, 200, 225, 255, 0.15, 5, 1);
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
        titan.GiveWeapon( "mp_titanweapon_rocketeer_rocketstream" )
	  	titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL,["slow_recovery_vortex","sp_wider_return_spread"] )
        titan.GiveOffhandWeapon( "mp_titanweapon_salvo_rockets", OFFHAND_ORDNANCE,["tcp"] )
	}
	if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_scorch_prime.mdl" )
	{
		SendHudMessage(player, "已启用野牛泰坦装备，取消至尊泰坦以使用原版烈焰\n温馨提示：野牛攻击请按近战键（默认为F键）",  -1, 0.3, 200, 200, 225, 255, 0.15, 8, 1);
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_MELEE )
		titan.GiveOffhandWeapon("mp_titanability_particle_wall", OFFHAND_SPECIAL )
		titan.GiveOffhandWeapon("mp_ability_heal", OFFHAND_ORDNANCE, ["tcp"] )
		titan.GiveOffhandWeapon( "melee_titan_punch_fighter", OFFHAND_MELEE, ["berserker", "allow_as_primary"] )
		titan.SetActiveWeaponByName( "melee_titan_punch_fighter" )
	}
	if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() == -1 && titan.GetSkin() == 3 )
	{
		SendHudMessage(player, "已启用SB-7274装备， 取消\"边境帝王\"战绘以使用原版帝王",  -1, 0.2, 200, 200, 225, 255, 0.15, 12, 1);
		//titan.SetModel($"models/titans/buddy/titan_buddy.mdl")
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveWeapon("mp_titanweapon_xo16_shorty")
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL,["slow_recovery_vortex","sp_wider_return_spread"] )
		titan.GiveOffhandWeapon("mp_titanability_smoke", OFFHAND_TITAN_CENTER )
		titan.GiveOffhandWeapon("mp_titanweapon_salvo_rockets", OFFHAND_ORDNANCE )
		titan.GiveOffhandWeapon( "mp_titancore_amp_core", OFFHAND_EQUIPMENT )
	}
}