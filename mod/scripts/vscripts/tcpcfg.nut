untyped //entity.s need this
global function InfiniteFirepower_Init

void function InfiniteFirepower_Init()
{
	RegisterSignal( "NukeStart" )

	RandomMap_Init()    //对局结束后换图

	TitanChange_Init()    //至尊泰坦替换，神盾血

	NukeTitanAndNuclearBomb_Init()    //核武泰坦和核弹

	TeamShuffle_Init()    //打乱队伍

	thread UseTimeCheck()

}


void function RandomMap_Init()
{
	AddCallback_GameStateEnter( eGameState.Postmatch, GameStateEnter_Postmatch )
}

void function TitanChange_Init()
{
	AddSpawnCallback( "npc_titan", OnTitanfall )
	AddCallback_OnPilotBecomesTitan( SetPlayerTitanTitle )
	AddCallback_OnTitanBecomesPilot( SetSharedEnergy )
	AddCallback_OnUpdateDerivedPlayerTitanLoadout( ApplyFDDerviedUpgrades )
	AddCallback_OnTitanDoomed( OnTitanDoomed )
}

void function NukeTitanAndNuclearBomb_Init()
{
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, OnWinnerDetermined )
	AddCallback_OnPlayerRespawned( RestoreKillStreak )
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddCallback_OnNPCKilled( OnPlayerKilled )
	AddCallback_OnClientConnected( OnClientConnected )
	AddClientCommandCallback( "hw", NukeTitan )
}

void function OnWinnerDetermined()	//anti-crash
{
	foreach( player in GetPlayerArray() )
	{
		player.s.KillStreak <- 0
		player.s.totalKills <- 0
		player.s.KillStreakNoNPC <- 0
		player.s.HaveNuclearBomb <- false
	}
}

// 连杀系统 //

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if( IsValid( attacker ) )
	{
		if( IsValid( victim ) )
			if( victim.IsTitan() && attacker.IsTitan() )
				printt( " kill+1 "+ attacker.GetModelName() + attacker.GetCamo() + attacker.GetSkin() +" dead+1 "+ victim.GetModelName() + victim.GetCamo() + victim.GetSkin() )
		if( !( attacker.IsPlayer() || attacker.IsTitan() || !attacker.IsNPC() ) || attacker.GetClassName() == "npc_titan" )
			return
		if( attacker != victim && ( !victim.IsNPC() || victim.GetClassName() == "npc_titan" ) )
		{
			if( attacker.GetClassName() == "npc_titan" )
			{
				attacker = attacker.GetBossPlayer()
				if( !IsValid( attacker ) )
					return
				if( !( attacker.IsPlayer() ) )
					return
			}
			if( !attacker.IsPlayer() )
				return
			if( attacker.GetTeam() == victim.GetTeam() )
				return
			attacker.s.KillStreak += 1
			attacker.s.totalKills += 1
			if( victim.IsPlayer() )
				attacker.s.KillStreakNoNPC += 1
			if( attacker.s.totalKills % 4 == 0 || attacker.s.KillStreak % 4 == 0 )
			{
				if( attacker.s.totalKills % 4 == 0 && attacker.s.KillStreak % 4 == 0 )
				{
					if( "HaveNukeTitan" in attacker.s )
					{
						attacker.s.HaveNukeTitan += 2
					}
					else
					{
						attacker.s.HaveNukeTitan <- 2
					}
					NSSendAnnouncementMessageToPlayer( attacker, "獲得雙倍核武泰坦！", "剩餘"+ attacker.s.HaveNukeTitan +"個未交付", < 255, 0, 0 >, 255, 5 )
				}
				else
				{
					if( "HaveNukeTitan" in attacker.s )
					{
						attacker.s.HaveNukeTitan += 1
					}
					else
					{
						attacker.s.HaveNukeTitan <- 1
					}
					NSSendAnnouncementMessageToPlayer( attacker, "獲得核武泰坦！", "剩餘"+ attacker.s.HaveNukeTitan +"個未交付", < 255, 0, 0 >, 255, 5 )
				}
			}
			if( attacker.s.KillStreakNoNPC == 30 )
			{
				attacker.s.HaveNuclearBomb <- true	//给核弹，给监听用
				NSSendAnnouncementMessageToPlayer( attacker, "獲得聚變打擊能力！", "", < 255, 0, 0 >, 255, 5 )
			}
		}
	}
}

void function OnClientConnected( entity player )
{
	player.s.KillStreak <- 0
	player.s.totalKills <- 0
	player.s.KillStreakNoNPC <- 0

	// KS //
	player.s.HaveNuclearBomb <- false
	player.s.HaveNukeTitan <- 0

	// GUI //
	player.s.KsGUIL1 <- 0
	player.s.KsGUIL2 <- false
	player.s.KsGUIL2_1 <- 0
	player.s.lastGUITime <- 0.0
	AddPlayerHeldButtonEventCallback( player, IN_OFFHAND2, KsGUI, 0 )
	AddPlayerHeldButtonEventCallback( player, IN_MELEE, DropBattery, 1 )
}

void function DropBattery( entity player )
{
	if( player.IsHuman() && IsAlive( player ) )
	{
		if( PlayerHasMaxBatteryCount( player ) )
		{
			entity battery = Rodeo_TakeBatteryAwayFromPilot( player )
			vector viewVector = player.GetViewVector()
			vector playerVel = player.GetVelocity()
			vector batteryVel = playerVel + viewVector * 200 + < 0, 0, 100 >
			battery.SetVelocity( batteryVel )

			SendHudMessage( player, "已丢出电池!", -1, 0.4, 100, 255, 100, 0, 0, 2, 1 )
			EmitSoundOnEntityOnlyToPlayer( player, player, "UI_Menu_Store_Purchase_Success" )
			return
		}
	}
}

void function KsGUI( entity player )
{
	table result = {}
	result.timeOut <- false
	if( !player.IsHuman() )
	{
		result.timeOut <- true
		return
	}

	OnThreadEnd(
		function() : ( player, result )
		{
			if( result.timeOut )
				return
			if( IsValid( player ) )
				if( player.s.KsGUIL2 )
					KsGUI_SwitchL2( player )
				else
					KsGUI_SwitchL1( player )
		}
	)
	wait 0.5
	if( player.s.lastGUITime + 2 < Time() )
		return

	result.timeOut <- true

	if( !IsValid( player ) )
		return

	if( player.s.KsGUIL2 )
		return KsGUIL2Select( player )
	KsGUI_L1ToL2( player )

	return
}

void function KsGUI_L1ToL2( entity player )
{
	local l1 = player.s.KsGUIL1
	if( l1 == 0 )
		KsGUI_L2_0( player )
	if( l1 == 1 )
		KsGUI_L2_1( player )
	if( l1 == 2 )
		KsGUI_L2_2( player )
}

void function KsGUI_SwitchL2( entity player )
{
	local l1 = player.s.KsGUIL1
	if( l1 == 1 )
		KsGUI_L2_1( player )
}

void function KsGUIL2Select( entity player )
{
	local l1 = player.s.KsGUIL1
	local l2 = player.s.KsGUIL2_1
	if( l1 == 1 && l2 == 0 )
	{
		NukeTitan_Threaded( player, [ "1" ] )
		player.s.lastGUITime = Time()
	}
	if( l1 == 1 && l2 == 1 )
	{
		NukeTitan_Threaded( player, [ "all" ] )
		player.s.KsGUIL2 = false
	}
}

void function KsGUI_L2_2( entity player )
{
	if( player.s.HaveNuclearBomb == true )
	{
		if( player.s.HaveNuclearBomb == false )
			return
		foreach( arrayPlayer in GetPlayerArray() )
		{
			arrayPlayer.s.KillStreak <- 0
			arrayPlayer.s.totalKills <- 0
			arrayPlayer.s.KillStreakNoNPC <- 0
			arrayPlayer.s.HaveNuclearBomb <- false
		}
		thread NuclearBombAnimThink( player )
		return
	}

	SendHudMessage( player, "聚变打击离线", -1, 0.4, 255, 100, 100, 0, 0, 2, 1 )
	EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
}

void function KsGUI_L2_1( entity player )
{
	bool skipL2Add = false
	if( player.s.KsGUIL2 && player.s.lastGUITime + 2 < Time() )
	{
		if( player.s.lastGUITime + 3 < Time() )
		{
			player.s.KsGUIL2 = false
			return KsGUI_SwitchL1( player )
		}
		else
			skipL2Add = true
	}

	if( player.s.KsGUIL2 == false )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, "Menu_LoadOut_Titan_Select" )
		player.s.KsGUIL2_1 = 1
	}
	else
		EmitSoundOnEntityOnlyToPlayer( player, player, "menu_click" )

	player.s.lastGUITime = Time()
	player.s.KsGUIL2 = true
	if( player.s.KsGUIL2_1 == 1 && !skipL2Add )
		player.s.KsGUIL2_1 = 0
	else if( !skipL2Add )
		player.s.KsGUIL2_1 = 1

	local l2 = player.s.KsGUIL2_1

	if( l2 == 0 )
	{
		SendHudMessage( player, ">>交付一个<<  -  ==交付全部==", -1, 0.4, 200, 200, 225, 0, 0, 3, 1 )
	}
	else
		SendHudMessage( player, "==交付一个==  -  >>交付全部<<", -1, 0.4, 200, 200, 225, 0, 0, 3, 1 )

}

void function KsGUI_L2_0( entity player )
{
	if( player.IsHuman() && IsAlive( player ) )
	{
		if( PlayerHasMaxBatteryCount( player ) )
		{
			entity battery = Rodeo_TakeBatteryAwayFromPilot( player )
			vector viewVector = player.GetViewVector()
			vector playerVel = player.GetVelocity()
			vector batteryVel = playerVel + viewVector * 200 + < 0, 0, 100 >
			battery.SetVelocity( batteryVel )

			SendHudMessage( player, "已丢出电池!", -1, 0.4, 100, 255, 100, 0, 0, 2, 1 )
			EmitSoundOnEntityOnlyToPlayer( player, player, "UI_Menu_Store_Purchase_Success" )
			return
		}
	}
	SendHudMessage( player, "你没有电池！", -1, 0.4, 255, 100, 100, 0, 0, 2, 1 )
	EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
}

const array<string> KSGUI_L1_TEXT = [ "丢出电池", "核武泰坦", "聚变打击" ]

void function KsGUI_SwitchL1( entity player )
{
	bool skipL1Add = false
	if( player.s.lastGUITime + 2 < Time() )
		skipL1Add = true
	player.s.lastGUITime = Time()

	if( player.s.KsGUIL1 < KSGUI_L1_TEXT.len() - 1 && !skipL1Add )
		player.s.KsGUIL1 += 1
	else if( !skipL1Add )
		player.s.KsGUIL1 = 0
	local l1 = player.s.KsGUIL1
	string text = ""
	int i = 0

	for( ;; )
	{
		if( i == l1 )
			text += ">>"
		else
			text += "=="

		text += KSGUI_L1_TEXT[ i ]

		if( i == 1 )
			text += "("+ player.s.HaveNukeTitan +")"
		if( i == 2 )
			text += player.s.HaveNuclearBomb ? "(在线)" : "(离线)"

		if( i == l1 )
			text += "<<"
		else
			text += "=="

		if( i == KSGUI_L1_TEXT.len() - 1 )
			break

		text += "  -  "
		i++
	}

	EmitSoundOnEntityOnlyToPlayer( player, player, "menu_click" )
	SendHudMessage( player, text, -1, 0.4, 200, 200, 225, 0, 0, 3, 1 )

}

bool function NukeTitan( entity player, array<string> args )
{
	thread NukeTitan_Threaded( player, args )
	return true
}
void function NukeTitan_Threaded( entity player, array<string> args )
{
	if( !IsValid( player ) )
		return
	if( args.len() == 0 )
	{
		if( "HaveNukeTitan" in player.s )
		{
			SendHudMessage( player, "当前拥有 "+ player.s.HaveNukeTitan +" 个核武泰坦", -1, 0.3, 255, 0, 0, 255, 0.15, 2, 1 )
			return
		}
		else
		{
			SendHudMessage( player, "当前拥有 0 个核武泰坦", -1, 0.3, 255, 0, 0, 255, 0.15, 2, 1 )
			return
		}
	}
	else
	{
		int i = 0
		if( args[0] == "all" )
		{
			if( "HaveNukeTitan" in player.s )
			{
				if( player.s.HaveNukeTitan <= 0 )
				{
					SendHudMessage( player, "你没有核武泰坦!", -1, 0.4, 255, 0, 0, 255, 0, 2, 1 )
					EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
					return
				}
				if( player.IsTitan() )
				{
					SendHudMessage( player, "你需要先离开泰坦才能交付核武泰坦", -1, 0.4, 255, 0, 0, 255, 0, 2, 1 )
					EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
					return
				}
				if( !player.IsHuman() )
				{
					SendHudMessage( player, "你需要处于铁驭状态才能交付核武泰坦", -1, 0.4, 255, 0, 0, 255, 0, 2, 1 )
					EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
					return
				}
				SendHudMessage( player, "成功交付了 "+ player.s.HaveNukeTitan +" 个核武泰坦", -1, 0.4, 255, 0, 0, 255, 0, 2, 1 )
				EmitSoundOnEntityOnlyToPlayer( player, player, "UI_InGame_FD_ArmoryPurchase" )
				for( var i = player.s.HaveNukeTitan; i > 0; i -= 1)
				{
					PlayerInventory_GiveNukeTitan( player )
				}
				player.s.HaveNukeTitan = 0
			}
			else
			{
				SendHudMessage( player, "你没有核武泰坦!", -1, 0.4, 255, 0, 0, 255, 0, 2, 1 )
				EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
			}
			return
		}
		else
			i = args[0].tointeger()
		if( i <= 0 )
		{
			SendHudMessage( player, "填入了非法参数", -1, 0.4, 255, 0, 0, 255, 0, 2, 1 )
			EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
			return
		}
		if( "HaveNukeTitan" in player.s )
		{
			if( player.s.HaveNukeTitan <= 0 )
			{
				SendHudMessage( player, "你没有核武泰坦!", -1, 0.4, 255, 0, 0, 255, 0, 2, 1 )
				EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
				return
			}
			if( i > player.s.HaveNukeTitan )
			{
				SendHudMessage( player, "你只有 "+ player.s.HaveNukeTitan +" 个核武泰坦\n但你填入的值 "+ i +" 明显大于你所拥有的值", -1, 0.4, 255, 0, 0, 255, 0.15, 3, 1 )
				EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
				return
			}
			if( player.IsTitan() )
			{
				SendHudMessage( player, "你需要先离开泰坦才能交付核武泰坦", -1, 0.4, 255, 0, 0, 255, 0, 2, 1 )
				EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
				return
			}
			if( !player.IsHuman() )
			{
				SendHudMessage( player, "你需要处于铁驭状态才能交付核武泰坦", -1, 0.4, 255, 0, 0, 255, 0, 2, 1 )
				EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
				return
			}
			player.s.HaveNukeTitan -= i
			SendHudMessage( player, "成功交付了 "+ i +" 个核武泰坦\n剩余 "+ player.s.HaveNukeTitan +" 个核武泰坦未交付", -1, 0.4, 255, 0, 0, 255, 0, 3, 1 )
			EmitSoundOnEntityOnlyToPlayer( player, player, "UI_InGame_FD_ArmoryPurchase" )
			while( i > 0 )
			{
				PlayerInventory_GiveNukeTitan( player )
				i -= 1
			}
		}
		else
		{
			SendHudMessage( player, "你没有核武泰坦!", -1, 0.4, 255, 0, 0, 255, 0, 2, 1 )
			EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
		}
		return
	}
}


void function RestoreKillStreak( entity player )
{
	if( "HaveNukeTitan" in player.s )
		if( player.s.HaveNukeTitan != 0 )
			NSSendAnnouncementMessageToPlayer( player, "剩餘"+ player.s.HaveNukeTitan +"個核武泰坦未交付", "記得使用！", < 255, 0, 0 >, 255, 5 )
	if( "HaveNuclearBomb" in player.s )
		if( player.s.HaveNuclearBomb == true )
			SendHudMessage( player, "////////聚变打击已就绪，长按\"近战\"键（默认为\"F\"）以启用////////", -1, 0.4, 255, 0, 0, 255, 0.15, 5, 1 )
	if( "DontRestore" in player.s )
	{
		if( player.s.DontRestore == true )
		{
			player.s.DontRestore <- false
			return
		}
	}
	player.s.KillStreak <- 0	//重置玩家的一命击杀数
	player.s.KillStreakNoNPC <- 0
}


//// 泰坦系统 ////



void function SetPlayerTitanTitle( entity player, entity titan )
{
	entity soul = player.GetTitanSoul()
	if( !IsValid( soul ) )
		return
	if( "titanTitle" in soul.s )
	{
		if( soul.s.titanTitle != "" )
		{
			if( soul.s.classicRodeoBatteryCount == 0 )
			{
				player.SetTitle( soul.s.titanTitle + " - 反應爐外漏" )
				return
			}
			player.SetTitle( soul.s.titanTitle )
		}
	}
	if( "SharedEnergyRegenRate" in soul.s )
		player.SetSharedEnergyRegenRate( soul.s.SharedEnergyRegenRate )
	if( "SharedEnergyRegenDelay" in soul.s )
		player.SetSharedEnergyRegenDelay( soul.s.SharedEnergyRegenDelay )
	if( "SharedEnergyTotal" in soul.s )
	{
		player.SetSharedEnergyTotal( soul.s.SharedEnergyTotal )
		if( player.GetSharedEnergyCount() > soul.s.SharedEnergyTotal )
			player.TakeSharedEnergy( player.GetSharedEnergyCount() - soul.s.SharedEnergyTotal )
	}
}

void function SetSharedEnergy( entity player, entity titan )
{
	entity soul = titan.GetTitanSoul()
	if( !IsValid( soul ) )
		return
	if( "SharedEnergyRegenRate" in soul.s )
		titan.SetSharedEnergyRegenRate( soul.s.SharedEnergyRegenRate )
	if( "SharedEnergyRegenDelay" in soul.s )
		titan.SetSharedEnergyRegenDelay( soul.s.SharedEnergyRegenDelay )
	if( "SharedEnergyTotal" in soul.s )
	{
		titan.SetSharedEnergyTotal( soul.s.SharedEnergyTotal )
		if( titan.GetSharedEnergyCount() > soul.s.SharedEnergyTotal )
			titan.TakeSharedEnergy( titan.GetSharedEnergyCount() - soul.s.SharedEnergyTotal )
	}
}

void function OnTitanDoomed( entity titan, var damageInfo )	//帝王逝者生存平衡
{
	thread OnTitanDoomed_Threaded( titan )
}
void function OnTitanDoomed_Threaded( entity titan )
{
	WaitFrame()
	if( !IsValid( titan ) )
		return
	if( !IsAlive( titan ) )
		return
	if( titan.GetModelName() != $"models/titans/medium/titan_medium_vanguard.mdl" )
		return
	if( titan.GetCamo() == -1 && titan.GetSkin() == 3 )
		return
	entity soul = titan.GetTitanSoul()
	if( !IsValid( soul ) )
		return
	if( !SoulHasPassive( soul, ePassives.PAS_VANGUARD_DOOM ) )
		return
	titan.SetMaxHealth( 5000 )
	titan.SetHealth( 5000 )
}

void function OnTitanfall( entity titan )
{
	entity player = titan
	entity soul = titan.GetTitanSoul()
	if( !IsValid( player ) )	//anti crash
		return
	if( !titan.IsPlayer() )	//如果实体"titan"不是玩家
		player = GetPetTitanOwner( titan )	//所以获得实体"titan"的主人"玩家"赋值给实体"player"
	if( IsValid( soul ) )	//如果soul != null
		if( "TitanHasBeenChange" in soul.s )	//检测是否有这个sting在soul.s里
			if( soul.s.TitanHasBeenChange == true )	//如果已经换过武器了，那么跳过
				return								//补充解释，为什么没有soul.s.TitanHasBeenChange <- false
													//因为当泰坦死亡或者摧毁时，它的soul会变成null，理所应当的，soul.s里的内容也会null
	if( !IsValid( soul ) )	//如果soul == null，我们应该直接return，防止执行后面的soul.s.TitanHasBeenChange <- true时报错
		return

	if( titan.GetModelName() == $"models/titans/light/titan_light_northstar_prime.mdl" )	//检查玩家的模型
	{
		soul.s.TitanHasBeenChange <- true
		soul.s.titanTitle <- "野獸"	//众所周知，当玩家上泰坦时不会按照我们的意愿设置标题的，所以这边整个变量让玩家上泰坦时读取这个然后写上
		soul.soul.titanLoadout.titanExecution = "execution_northstar_prime"
		titan.SetSharedEnergyRegenDelay( 1.0 )
		titan.SetSharedEnergyRegenRate( 333.3 )
		soul.s.SharedEnergyRegenRate <- 333.3
		soul.s.SharedEnergyRegenDelay <- 1.0

		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
        titan.GiveWeapon( "mp_titanweapon_rocketeer_rocketstream", [ "tcp_sp_base" ] )
	  	titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield_ion", OFFHAND_SPECIAL,["tcp_sp_base"] )
		titan.GiveOffhandWeapon( "mp_titanability_hover", OFFHAND_TITAN_CENTER )
        titan.GiveOffhandWeapon( "mp_titanweapon_shoulder_rockets", OFFHAND_ORDNANCE,["tcp_sp_base"] )
		titan.GiveOffhandWeapon( "mp_titancore_flight_core", OFFHAND_EQUIPMENT, [ "tcp_sp_base" ] )

		array<int> passives = [ ePassives.PAS_NORTHSTAR_WEAPON,
								ePassives.PAS_NORTHSTAR_CLUSTER,
								ePassives.PAS_NORTHSTAR_TRAP,
								ePassives.PAS_NORTHSTAR_FLIGHTCORE,
								ePassives.PAS_NORTHSTAR_OPTICS ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
		GivePassive( soul, ePassives.PAS_NORTHSTAR_FLIGHTCORE )
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && titan.GetCamo() == -1 && titan.GetSkin() == 3 )
	{
		soul.s.TitanHasBeenChange <- true
		soul.s.titanTitle <- "遠征"
		titan.SetSharedEnergyRegenDelay( 1.0 )
		titan.SetSharedEnergyRegenRate( 333.3 )
		soul.s.SharedEnergyRegenRate <- 333.3
		soul.s.SharedEnergyRegenDelay <- 1.0

		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty", [ "tcp_sp_base" ] )
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield_ion", OFFHAND_SPECIAL,["tcp_sp_base"] )
		titan.GiveOffhandWeapon( "mp_titanability_smoke", OFFHAND_TITAN_CENTER )
		titan.GiveOffhandWeapon( "mp_titanweapon_shoulder_rockets", OFFHAND_ORDNANCE,["tcp_sp_base"] )
		titan.GiveOffhandWeapon( "mp_titancore_amp_core", OFFHAND_EQUIPMENT )

		array<int> passives = [ ePassives.PAS_VANGUARD_COREMETER,
								ePassives.PAS_VANGUARD_SHIELD,
								ePassives.PAS_VANGUARD_REARM,
								ePassives.PAS_VANGUARD_DOOM,
								ePassives.PAS_VANGUARD_CORE1,
								ePassives.PAS_VANGUARD_CORE2,
								ePassives.PAS_VANGUARD_CORE3,
								ePassives.PAS_VANGUARD_CORE4,
								ePassives.PAS_VANGUARD_CORE5,
								ePassives.PAS_VANGUARD_CORE6,
								ePassives.PAS_VANGUARD_CORE7,
								ePassives.PAS_VANGUARD_CORE8,
								ePassives.PAS_VANGUARD_CORE9 ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_scorch_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		soul.s.titanTitle <- "野牛"
		soul.soul.titanLoadout.titanExecution = "execution_scorch_prime"

		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.TakeOffhandWeapon( OFFHAND_MELEE )
		titan.GiveOffhandWeapon( "mp_titanability_particle_wall", OFFHAND_SPECIAL, [ "tcp_parent_shield" ] )
		titan.GiveOffhandWeapon( "mp_ability_heal", OFFHAND_TITAN_CENTER, [ "amped_tacticals", "tcp_super_dash" ] )
		titan.GiveOffhandWeapon( "mp_titanweapon_homing_rockets", OFFHAND_ORDNANCE, [ "tcp_push_back" ] )
		titan.GiveOffhandWeapon( "mp_titancore_flame_wave", OFFHAND_EQUIPMENT, [ "ground_slam" ] )
		titan.GiveOffhandWeapon( "melee_titan_punch_fighter", OFFHAND_MELEE, [ "berserker", "allow_as_primary" ] )
		titan.SetActiveWeaponByName( "melee_titan_punch_fighter" )

		array<int> passives = [ ePassives.PAS_SCORCH_WEAPON,
								ePassives.PAS_SCORCH_FIREWALL,
								ePassives.PAS_SCORCH_SHIELD,
								ePassives.PAS_SCORCH_SELFDMG,
								ePassives.PAS_SCORCH_FLAMECORE ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_ion_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		soul.s.titanTitle <- "執政官"
		soul.soul.titanLoadout.titanExecution = "execution_ion"
		titan.SetSharedEnergyRegenDelay( 1.0 )
		titan.SetSharedEnergyRegenRate( 100 )
		soul.s.SharedEnergyRegenRate <- 100
		soul.s.SharedEnergyRegenDelay <- 1.0

		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
		titan.GiveWeapon( "mp_titanweapon_arc_cannon", [ "capacitor" ] )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield_ion", OFFHAND_SPECIAL, [ "tcp_vortex", "shield_only", "burn_mod_titan_vortex_shield" ] )
		titan.GiveOffhandWeapon( "mp_titanability_laser_trip", OFFHAND_TITAN_CENTER, [ "pas_ion_tripwire", "tcp_arc_trip" ] )
		titan.GiveOffhandWeapon( "mp_titanweapon_dumbfire_rockets", OFFHAND_ORDNANCE, [ "tcp_arc_bomb" ] )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT, [ "tcp_arc_wave" ] )

		array<int> passives = [ ePassives.PAS_ION_WEAPON,
								ePassives.PAS_ION_TRIPWIRE,
								ePassives.PAS_ION_VORTEX,
								ePassives.PAS_ION_LASERCANNON,
								ePassives.PAS_ION_WEAPON_ADS ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}

	}
	else if( titan.GetModelName() == $"models/titans/light/titan_light_ronin_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		soul.s.titanTitle <- "游俠"
		soul.s.shouldFPEmbark <- true
		soul.s.classicExecution <- true

		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
		titan.GiveWeapon( "mp_titanweapon_triplethreat", [ "rolling_rounds" ] )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveOffhandWeapon( "mp_ability_swordblock", OFFHAND_SPECIAL )
		titan.GiveOffhandWeapon( "mp_titanability_smoke", OFFHAND_TITAN_CENTER, [ "tcp_emp" ])
		titan.GiveOffhandWeapon( "mp_titanweapon_homing_rockets", OFFHAND_ORDNANCE )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT, ["tcp_dash_core"] )

		array<int> passives = [ ePassives.PAS_RONIN_WEAPON,
								ePassives.PAS_RONIN_ARCWAVE,
								ePassives.PAS_RONIN_PHASE,
								ePassives.PAS_RONIN_SWORDCORE,
								ePassives.PAS_RONIN_AUTOSHIFT ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_tone_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		soul.s.titanTitle <- "天圖"
		soul.s.shouldFPEmbark <- true
		soul.s.classicExecution <- true
		titan.SetSharedEnergyTotal( 550 )
		titan.SetSharedEnergyRegenRate( 30 )
		soul.s.SharedEnergyRegenRate <- 30
		soul.s.SharedEnergyTotal <- 550

		if( titan.GetSharedEnergyCount() > soul.s.SharedEnergyTotal )
			titan.TakeSharedEnergy( titan.GetSharedEnergyCount() - soul.s.SharedEnergyTotal )

		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
		titan.GiveWeapon( "mp_titanweapon_sticky_40mm", [ "mortar_shots" ] )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveOffhandWeapon( "mp_titanability_particle_wall", OFFHAND_SPECIAL, [ "tcp_color_shield" ] )
		titan.GiveOffhandWeapon( "mp_titanability_rearm", OFFHAND_TITAN_CENTER, [ "tcp_no_gravity" ] )
		titan.GiveOffhandWeapon( "mp_titanweapon_laser_lite", OFFHAND_ORDNANCE, [ "tcp_mark_laser" ] )
		titan.GiveOffhandWeapon( "mp_titancore_amp_core", OFFHAND_EQUIPMENT, ["damage_core"] )



		array<int> passives = [ ePassives.PAS_TONE_WEAPON,
								ePassives.PAS_TONE_ROCKETS,
								ePassives.PAS_TONE_SONAR,
								ePassives.PAS_TONE_WALL,
								ePassives.PAS_TONE_BURST ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}
	else if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_legion_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		soul.s.titanTitle <- "巨妖"
		soul.s.shouldFPEmbark <- true
		soul.s.classicExecution <- true
		soul.SetTitanSoulNetInt( "upgradeCount", 4 )

		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty", [ "accelerator" ] )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveOffhandWeapon( "mp_titanability_sonar_pulse", OFFHAND_TITAN_CENTER, [ "tcp_smoke" ] )
		titan.GiveOffhandWeapon( "mp_titanability_particle_wall", OFFHAND_SPECIAL, [ "brute4_bubble_shield" ] )
		titan.GiveOffhandWeapon( "mp_titanweapon_stun_laser", OFFHAND_ORDNANCE, [ "charge_ball" ] )
		titan.GiveOffhandWeapon( "mp_titancore_upgrade", OFFHAND_EQUIPMENT, [ "tcp_ammo_core" ] )

		array<int> passives = [ ePassives.PAS_LEGION_CHARGESHOT,
								ePassives.PAS_LEGION_GUNSHIELD,
								ePassives.PAS_LEGION_SMARTCORE,
								ePassives.PAS_LEGION_SPINUP,
								ePassives.PAS_LEGION_WEAPON ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}

	//// 原版泰坦 ////

	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && ( titan.GetCamo() != -1 || titan.GetSkin() != 3 ) )	//帝王
	{
		soul.s.titanTitle <- "帝王"
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_ajax.mdl" )	//离子
	{
		soul.s.titanTitle <- "離子"
	}
	else if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_ogre.mdl" )		//烈焰
	{
		soul.s.titanTitle <- "烈焰"
	}
	else if( titan.GetModelName() == $"models/titans/light/titan_light_raptor.mdl" )	//北极星
	{
		soul.s.titanTitle <- "北極星"
	}
	else if( titan.GetModelName() == $"models/titans/light/titan_light_locust.mdl" )	//浪人
	{
		soul.s.titanTitle <- "浪人"
	}
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_wraith.mdl" )	//强力
	{
		soul.s.titanTitle <- "強力"
	}
	else if( titan.GetModelName() == $"models/titans/heavy/titan_heavy_deadbolt.mdl" )	//军团
	{
		soul.s.titanTitle <- "軍團"
	}
}



///////////////////////
////	核弹系统	////
///////////////////////

void function NuclearBombAnimThink( entity owner )
{
	SetShouldPlayFactionDialogue( false )
	SetBattleChatterEnabled_Northstar( false )
	SetShouldPlayDefaultMusic( false )
	SetServerVar( "gameEndTime", Time() + 120.0 )

	array<string> a = [ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" ]
	PlayBeepSound( owner )
	a.append( "IBM System/370 Model 168" )
	HudMsgAnimThink( a, owner )
	wait 0.5
	PlayBeepSound( owner )
	a.append( "" )
	HudMsgAnimThink( a, owner )
	a.append( "MVSLaunch v2.1" )
	HudMsgAnimThink( a, owner )
	a.append( "IBM Corporation 1975" )
	HudMsgAnimThink( a, owner )
	wait 1
	PlayBeepSound( owner )
	a.append( "BEGIN LAUNCH SEQUENCE." )
	HudMsgAnimThink( a, owner )
	wait 0.8
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "BEGIN LAUNCH SEQUENCE.."
	HudMsgAnimThink( a, owner )
	wait 0.8
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "BEGIN LAUNCH SEQUENCE..."
	HudMsgAnimThink( a, owner )
	wait 0.8
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "BEGIN LAUNCH SEQUENCE...[Done]"
	a.append( "LAUNCH CODES ENTERED:" )
	HudMsgAnimThink( a, owner )
	a.append( "" )
	HudMsgAnimThink( a, owner )
	wait 0.5
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "*"
	HudMsgAnimThink( a, owner )
	wait 0.2
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "**"
	HudMsgAnimThink( a, owner )
	wait 0.2
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "***"
	HudMsgAnimThink( a, owner )
	wait 0.2
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "****"
	HudMsgAnimThink( a, owner )
	wait 0.2
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "*****"
	HudMsgAnimThink( a, owner )
	wait 0.2
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "******"
	HudMsgAnimThink( a, owner )
	wait 1.0
	PlayBeepSound( owner )
	a.append( "VERIFYING LAUNCH CODES." )
	HudMsgAnimThink( a, owner )
	wait 0.8
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "VERIFYING LAUNCH CODES.."
	HudMsgAnimThink( a, owner )
	wait 0.8
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "VERIFYING LAUNCH CODES..."
	HudMsgAnimThink( a, owner )
	wait 0.8
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "VERIFYING LAUNCH CODES"
	a.append( "LAUNCH CODES ACCEPTED" )
	HudMsgAnimThink( a, owner )
	wait 1.0
	PlayBeepSound( owner )
	a.append( "INITIALIZING TARGETING MATRIX." )
	HudMsgAnimThink( a, owner )
	wait 0.8
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "INITIALIZING TARGETING MATRIX.."
	HudMsgAnimThink( a, owner )
	wait 0.8
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "INITIALIZING TARGETING MATRIX..."
	HudMsgAnimThink( a, owner )
	wait 0.8
	waitthread RandomStringAnim( owner )
	wait 0.1
	PlayBeepSound( owner )
	a[ a.len() - 1 ] = "INITIALIZING TARGETING MATRIX...[Done]"
	a.append( "TARGETING MATRIX ONLINE" )
	HudMsgAnimThink( a, owner )
	wait 1
	a.append( "WARHEAD LAUNCHED" )
	HudMsgAnimThink( a, owner )
	wait 0.2
	a = [ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "WARHEAD LAUNCHED" ]
	HudMsgAnimThink( a, owner )
	wait 0.2
	a[ a.len() - 1 ] = "WARHEAD LAUNCHED"
	PlayBeepSound( owner )
	HudMsgAnimThink( a, owner, true )
	wait 0.3
	a[ a.len() - 1 ] = ""
	HudMsgAnimThink( a, owner )
	wait 0.2
	a[ a.len() - 1 ] = "WARHEAD LAUNCHED"
	PlayBeepSound( owner )
	HudMsgAnimThink( a, owner, true )
	wait 0.3
	a[ a.len() - 1 ] = ""
	HudMsgAnimThink( a, owner )
	wait 0.2
	a[ a.len() - 1 ] = "WARHEAD LAUNCHED"
	PlayBeepSound( owner )
	HudMsgAnimThink( a, owner, true )
	wait 0.3
	a[ a.len() - 1 ] = ""
	HudMsgAnimThink( a, owner )
	wait 0.2
	a[ a.len() - 1 ] = "WARHEAD LAUNCHED"
	PlayBeepSound( owner )
	HudMsgAnimThink( a, owner, true )
	wait 0.3
	a[ a.len() - 1 ] = ""
	HudMsgAnimThink( a, owner )

	wait 4
	thread NuclearBombThink( owner )
}

void function PlayBeepSound( entity owner )
{
	if( !IsValid( owner ) )
		return
	EmitSoundOnEntityOnlyToPlayer( owner, owner, "hud_boost_card_radar_jammer_redtextbeep_1p" )
}

void function RandomStringAnim( entity owner )
{
	array<string> randomString = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9","!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "_", "=", "+", "[", "]", "{", "}", "|", "\\", "/", "<", ">", "?", ",", ".", ";", ":" ]
									//Thank u ChatGPT
	string msg = ""
	string bar = ""
	if( IsValid( owner ) )
		EmitSoundOnEntityOnlyToPlayer( owner, owner, "dataknife_loopable_beep" )
	for( int a = 0; a < 50; a++ )
	{
		if( a == 25 )
		{
			if( IsValid( owner ) )
			{
				StopSoundOnEntity( owner, "dataknife_loopable_beep" )
				EmitSoundOnEntityOnlyToPlayer( owner, owner, "dataknife_loopable_beep" )
			}
		}
		msg = ""
		bar = ""
		for( int b = 0; b < 9; b++ )
		{
			msg += "        "
			string s = ""
			for( int c = 0; c < 30; c++ )
			{
				s += randomString[ RandomInt( randomString.len() ) ]
			}
			msg += s
			msg += "\n"
		}
		msg += "    "
		for( int d = 0; d < a; d += 5 )
		{
			bar += "/"
		}
		for( int e = 50 - a; e >= 5; e -= 5 )
		{
			bar += "-"
		}
		msg += "INITIALIZING TARGETING MATRIX ["+ bar +"]"
		if( IsValid( owner ) )
			SendHudMessage( owner, msg, 0, 0.3, 235, 235, 235, 255, 0, 2, 0 )
		WaitFrame()
	}
	if( IsValid( owner ) )
		StopSoundOnEntity( owner, "dataknife_loopable_beep" )
}

void function HudMsgAnimThink( array<string> a, entity owner, bool isRed = false )
{
	if( !IsValid( owner ) )
		return

	string msg = ""
	int i =  a.len() - 10
	while( i < a.len() )
	{
		msg += "                "
		msg += a[i]
		msg += "\n"
		i++
	}
	if( isRed )
	{
		SendHudMessage( owner, msg, 0, 0.3, 235, 0, 0, 255, 0, 1, 0 )
		return
	}
	SendHudMessage( owner, msg, 0, 0.3, 235, 235, 235, 255, 0, 2, 0 )
}

void function PlayBeepSoundToAll()
{
	foreach( player in GetPlayerArray() )
	{
		if( !IsValid( player ) )
			continue
		EmitSoundOnEntityOnlyToPlayer( player, player, "hud_boost_card_radar_jammer_redtextbeep_1p" )
	}
}

void function NuclearBombThink( entity owner )
{
	string ownerName
	if( IsValid( owner ) )
		ownerName = owner.GetPlayerName()
	else
		ownerName = "[错误:玩家离线]"

	svGlobal.levelEnt.Signal( "NukeStart" )
	SendHudMessageToAll( "\n侦测到来自 "+ ownerName +" 的聚变打击\n\n", -1, 0.3, 235, 0, 0, 255, 0, 2, 0 )
	PlayBeepSoundToAll()
	wait 0.5
	SendHudMessageToAll( "", -1, 0.4, 235, 235, 235, 255, 0, 2, 0 )
	wait 0.3
	SendHudMessageToAll( "\n侦测到来自 "+ ownerName +" 的聚变打击\n\n", -1, 0.3, 235, 0, 0, 255, 0, 2, 0 )
	PlayBeepSoundToAll()
	wait 0.5
	SendHudMessageToAll( "", -1, 0.4, 235, 235, 235, 255, 0, 2, 0 )
	wait 0.3
	SendHudMessageToAll( "\n侦测到来自 "+ ownerName +" 的聚变打击\n\n", -1, 0.3, 235, 0, 0, 255, 0, 2, 0 )
	PlayBeepSoundToAll()
	wait 0.8
	SendHudMessageToAll( "\n侦测到来自 "+ ownerName +" 的聚变打击\n预计到达时间 ETA T-20s\n", -1, 0.3, 235, 0, 0, 255, 0, 2, 0 )
	PlayBeepSoundToAll()
	wait 1
	float realSec
	for( int sec = 200; sec > 0; sec-- )
	{
		realSec = float( sec ) / 10
		PlayNukeSound()
		SendHudMessageToAll( "//////////////// WARNING ////////////////\n侦测到来自 "+ ownerName +" 的聚变打击\n预计到达时间 ETA T-"+ realSec +"s\n//////////////// WARNING ////////////////", -1, 0.3, 235, 0, 0, 255, 0, 2, 0 )
		wait 0.1
		sec--
		realSec = float( sec ) / 10
		PlayNukeSound()
		SendHudMessageToAll( "//////////////// WARNING ////////////////\n侦测到来自 "+ ownerName +" 的聚变打击\n预计到达时间 ETA T-"+ realSec +"s\n//////////////// WARNING ////////////////", -1, 0.3, 235, 0, 0, 255, 0, 2, 0 )
		wait 0.1
		sec--
		realSec = float( sec ) / 10
		PlayNukeSound()
		SendHudMessageToAll( "//////////////// WARNING ////////////////\n侦测到来自 "+ ownerName +" 的聚变打击\n预计到达时间 ETA T-"+ realSec +"s\n//////////////// WARNING ////////////////", -1, 0.3, 235, 0, 0, 255, 0, 2, 0 )
		wait 0.1
		sec--
		realSec = float( sec ) / 10
		PlayNukeSound()
		SendHudMessageToAll( "\n侦测到来自 "+ ownerName +" 的聚变打击\n预计到达时间 ETA T-"+ realSec +"s\n", -1, 0.3, 235, 0, 0, 255, 0, 2, 0 )
		wait 0.1
		sec--
		realSec = float( sec ) / 10
		PlayNukeSound()
		SendHudMessageToAll( "\n侦测到来自 "+ ownerName +" 的聚变打击\n预计到达时间 ETA  T-"+ realSec +"s\n", -1, 0.3, 235, 0, 0, 255, 0, 2, 0 )
	}
	wait 0.1
	SendHudMessageToAll( "//////////////// WARNING ////////////////\n侦测到来自 "+ ownerName +" 的聚变打击\n预计到达时间 ETA T-0s\n//////////////// WARNING ////////////////", -1, 0.3, 235, 0, 0, 255, 0, 0.1, 0 )

	if( IsValid( owner ) )
		SetWinner( owner.GetTeam() )
	foreach( player in GetPlayerArray() )
		thread NukeExplode( player )

	wait 4
	SetGameState( eGameState.Postmatch )
}

void function PlayNukeSound()
{
	foreach( player in GetPlayerArray() )
	{
		if( !IsValid( player ) )
			continue
		EmitSoundOnEntityOnlyToPlayer( player, player, "titan_cockpit_missile_close_warning" )
	}
}

void function NukeExplode( entity player )
{
	if( IsValid( player ) )
	{
		StopSoundOnEntity( player, "titan_cockpit_missile_close_warning" )
		for( int value = 4; value > 0; value = value - 1 )
		{
			EmitSoundOnEntityOnlyToPlayer( player, player, "goblin_dropship_explode_OLD" )
		}
		thread FakeShellShock_Threaded( player, 10 )
		StatusEffect_AddTimed( player, eStatusEffect.turn_slow, 0.4, 10, 0.5 )
		ScreenFadeToColor( player, 192, 192, 192, 64, 0.1, 6  )
		thread NukeFX( player )
	}
	wait 2.0
	if( IsValid( player ) )
	{
		StopSoundOnEntity( player, "goblin_dropship_explode_OLD" )
		if( IsAlive( player ) )
			player.Die()
		EmitSoundOnEntityOnlyToPlayer( player, player, "death.pinkmist" )
		EmitSoundOnEntityOnlyToPlayer( player, player, "titan_nuclear_death_explode" )
		EmitSoundOnEntityOnlyToPlayer( player, player, "bt_beacon_controlroom_dish_explosion" )
		ScreenFadeToColor( player, 192, 192, 192, 255, 0.1, 4  )
	}
}

void function NukeFX( entity player )
{
	float endTime = Time() + 2.1
	float bloomScale = 1.0
	float sunScale = -1.0
	while ( Time() < endTime && IsValid( player ) )
	{
		Remote_CallFunction_Replay( player, "ServerCallback_ScreenShake", 200, 100, 0.5 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_SetMapSettings", bloomScale, false, 1.0, 1.0, 1.0, 0, 0, sunScale, 1.0 )
		bloomScale *= 1.25
		//sunScale -= 0.4
		sunScale *= 1.5
		WaitFrame()
	}
}

void function FakeShellShock_Threaded( entity victim, float duration )
{
	victim.EndSignal( "OnDeath" )
	StatusEffect_AddTimed( victim, eStatusEffect.move_slow, 0.25, duration, 0.25 )
	//StatusEffect_AddTimed( victim, eStatusEffect.turn_slow, 0.25, duration, 0.25 )
	AddCinematicFlag( victim, CE_FLAG_EXECUTION )

	OnThreadEnd(
		function(): ( victim )
		{
			if( IsValid( victim ) )
				RemoveCinematicFlag( victim, CE_FLAG_EXECUTION )
		}
	)

	wait duration
}


//// 杂项 ////
void function UseTimeCheck()
{
	int UseTime_1 = 0
	int UseTime_2 = 0
	int UseTime_3 = 0
	int UseTime_4 = 0
	int UseTime_5 = 0
	int UseTime_6 = 0
	int UseTime_7 = 0

	int UseTime_ModTitan_1 = 0
	int UseTime_ModTitan_2 = 0
	int UseTime_ModTitan_3 = 0
	int UseTime_ModTitan_4 = 0
	int UseTime_ModTitan_5 = 0
	int UseTime_ModTitan_6 = 0
	int UseTime_ModTitan_7 = 0

	while( true )
	{
		wait 10
		foreach( player in GetPlayerArray() )
		{
			if( !IsValid( player ) )
				continue
			if( player.IsHuman() )
			{
				player = player.GetPetTitan()
				if( !IsValid( player ) )
					continue
			}
			if( !IsValid( player.GetModelName() ) )
				continue
			if( player.GetModelName() == $"models/titans/medium/titan_medium_ajax.mdl" )	//离子
			{
				UseTime_1 += 10
			}
			if( player.GetModelName() == $"models/titans/heavy/titan_heavy_ogre.mdl" )		//烈焰
			{
				UseTime_2 += 10
			}
			if( player.GetModelName() == $"models/titans/light/titan_light_raptor.mdl" )	//北极星
			{
				UseTime_3 += 10
			}
			if( player.GetModelName() == $"models/titans/light/titan_light_locust.mdl" )	//浪人
			{
				UseTime_4 += 10
			}
			if( player.GetModelName() == $"models/titans/medium/titan_medium_wraith.mdl" )	//强力
			{
				UseTime_5 += 10
			}
			if( player.GetModelName() == $"models/titans/heavy/titan_heavy_deadbolt.mdl" )	//军团
			{
				UseTime_6 += 10
			}
			if( player.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && ( player.GetCamo() != -1 || player.GetSkin() != 3 ) )	//帝王
			{
				UseTime_7 += 10
			}
			//// ModTitan ////
			if( player.GetModelName() == $"models/titans/light/titan_light_northstar_prime.mdl" )	//野兽
			{
				UseTime_ModTitan_1 += 10
			}
			if( player.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && player.GetCamo() == -1 && player.GetSkin() == 3 )	//远征
			{
				UseTime_ModTitan_2 += 10
			}
			if( player.GetModelName() == $"models/titans/heavy/titan_heavy_scorch_prime.mdl" )		//野牛
			{
				UseTime_ModTitan_3 += 10
			}
			if( player.GetModelName() == $"models/titans/medium/titan_medium_ion_prime.mdl" )		//执政官
			{
				UseTime_ModTitan_4 += 10
			}
			if( player.GetModelName() == $"models/titans/light/titan_light_ronin_prime.mdl" )		//游侠
			{
				UseTime_ModTitan_5 += 10
			}
			if( player.GetModelName() == $"models/titans/medium/titan_medium_tone_prime.mdl" )		//天图
			{
				UseTime_ModTitan_6 += 10
			}
			if( player.GetModelName() == $"models/titans/heavy/titan_heavy_legion_prime.mdl" )		//巨妖
			{
				UseTime_ModTitan_7 += 10
			}

			if( UseTime_1 % 60 == 0 && UseTime_1 != 0 )
			{
				printt( "UseTimeCheck: Titan_1 add 1 min" )
				UseTime_1 = 0
			}
			if( UseTime_2 % 60 == 0	&& UseTime_2 != 0 )
			{
				printt( "UseTimeCheck: Titan_2 add 1 min" )
				UseTime_2 = 0
			}
			if( UseTime_3 % 60 == 0	&& UseTime_3 != 0 )
			{
				printt( "UseTimeCheck: Titan_3 add 1 min" )
				UseTime_3 = 0
			}
			if( UseTime_4 % 60 == 0	&& UseTime_4 != 0 )
			{
				printt( "UseTimeCheck: Titan_4 add 1 min" )
				UseTime_4 = 0
			}
			if( UseTime_5 % 60 == 0	&& UseTime_5 != 0 )
			{
				printt( "UseTimeCheck: Titan_5 add 1 min" )
				UseTime_5 = 0
			}
			if( UseTime_6 % 60 == 0	&& UseTime_6 != 0 )
			{
				printt( "UseTimeCheck: Titan_6 add 1 min" )
				UseTime_6 = 0
			}
			if( UseTime_7 % 60 == 0	&& UseTime_7 != 0 )
			{
				printt( "UseTimeCheck: Titan_7 add 1 min" )
				UseTime_7 = 0
			}
			//// ModTitan ////
			if( UseTime_ModTitan_1 % 60 == 0 && UseTime_ModTitan_1 != 0 )
			{
				printt( "UseTimeCheck: ModTitan_1 add 1 min" )
				UseTime_ModTitan_1 = 0
			}
			if( UseTime_ModTitan_2 % 60 == 0 && UseTime_ModTitan_2 != 0 )
			{
				printt( "UseTimeCheck: ModTitan_2 add 1 min" )
				UseTime_ModTitan_2 = 0
			}
			if( UseTime_ModTitan_3 % 60 == 0 && UseTime_ModTitan_3 != 0 )
			{
				printt( "UseTimeCheck: ModTitan_3 add 1 min" )
				UseTime_ModTitan_3 = 0
			}
			if( UseTime_ModTitan_4 % 60 == 0 && UseTime_ModTitan_4 != 0 )
			{
				printt( "UseTimeCheck: ModTitan_4 add 1 min" )
				UseTime_ModTitan_4 = 0
			}
			if( UseTime_ModTitan_5 % 60 == 0 && UseTime_ModTitan_5 != 0 )
			{
				printt( "UseTimeCheck: ModTitan_5 add 1 min" )
				UseTime_ModTitan_5 = 0
			}
			if( UseTime_ModTitan_6 % 60 == 0 && UseTime_ModTitan_6 != 0 )
			{
				printt( "UseTimeCheck: ModTitan_6 add 1 min" )
				UseTime_ModTitan_6 = 0
			}
			if( UseTime_ModTitan_7 % 60 == 0 && UseTime_ModTitan_7 != 0 )
			{
				printt( "UseTimeCheck: ModTitan_7 add 1 min" )
				UseTime_ModTitan_7 = 0
			}
		}
	}
}

void function GameStateEnter_Postmatch()
{
	thread RandomMap()
}
void function RandomMap()
{
	wait ( GAME_POSTMATCH_LENGTH - 0.1 )
	int RandomInt = RandomInt( 15 )
	switch( RandomInt )
	{
		case 0:
			if( GetMapName() != "mp_black_water_canal" )
				ServerCommand( "map mp_black_water_canal" )
			break
		case 1:
			if( GetMapName() != "mp_complex3" )
				ServerCommand( "map mp_complex3" )
			break
		case 2:
			if( GetMapName() != "mp_crashsite3" )
				ServerCommand( "map mp_crashsite3" )
			break
		case 3:
			if( GetMapName() != "mp_drydock" )
				ServerCommand( "map mp_drydock" )
			break
		case 4:
			if( GetMapName() != "mp_eden" )
				ServerCommand( "map mp_eden" )
			break
		case 5:
			if( GetMapName() != "mp_forwardbase_kodai" )
				ServerCommand( "map mp_forwardbase_kodai" )
			break
		case 6:
			if( GetMapName() != "mp_grave" )
				ServerCommand( "map mp_grave" )
			break
		case 7:
			if( GetMapName() != "mp_homestead" )
				ServerCommand( "map mp_homestead" )
			break
		case 8:
			if( GetMapName() != "mp_thaw" )
				ServerCommand( "map mp_thaw" )
			break
		case 9:
			if( GetMapName() != "mp_angel_city" )
				ServerCommand( "map mp_angel_city" )
			break
		case 10:
			if( GetMapName() != "mp_colony02" )
				ServerCommand( "map mp_colony02" )
			break
		case 11:
			if( GetMapName() != "mp_relic02" )
				ServerCommand( "map mp_relic02" )
			break
		case 12:
			if( GetMapName() != "mp_wargames" )
				ServerCommand( "map mp_wargames" )
			break
		case 13:
			if( GetMapName() != "mp_glitch" )
				ServerCommand( "map mp_glitch" )
			break
		case 14:
			if( GetMapName() != "mp_rise" )
				ServerCommand( "map mp_rise" )
			break
		default:
			break
	}
}