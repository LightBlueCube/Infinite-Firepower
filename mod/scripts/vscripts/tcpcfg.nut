untyped //entity.s need this
global function InfiniteFirepower_Init

void function InfiniteFirepower_Init()
{
	RegisterSignal( "NukeStart" )

	RandomMap_Init()    //对局结束后换图

	TitanChange_Init()    //至尊泰坦替换，神盾血

	KillStreak_Init()    //连杀系统和GUI

	TeamShuffle_Init()    //打乱队伍

	thread UseTimeCheck()

	AddClientCommandCallback( "123123", ClientCommand_123123 )
}

bool function ClientCommand_123123( entity player, array<string> args )
{
	if( "Use123123" in player.s )
		if( player.s.Use123123 )
			return true
	SendHudMessage( player, "我草我错了别骂了别骂了", -1, 0.4, 255, 100, 100, 255, 0, 6, 1 )
	PlayFX( TITAN_NUCLEAR_CORE_FX_3P, player.GetOrigin() + Vector( 0, 0, -100 ), Vector(0,RandomInt(360),0) )
	PlayFX( TITAN_NUCLEAR_CORE_FX_3P, player.GetOrigin() + Vector( 0, 0, -100 ), Vector(0,RandomInt(360),0) )
	PlayFX( TITAN_NUCLEAR_CORE_FX_3P, player.GetOrigin() + Vector( 0, 0, -100 ), Vector(0,RandomInt(360),0) )
	PlayFX( TITAN_NUCLEAR_CORE_FX_3P, player.GetOrigin() + Vector( 0, 0, -100 ), Vector(0,RandomInt(360),0) )
	EmitSoundOnEntity( player, "titan_nuclear_death_explode" )
	Remote_CallFunction_Replay( player, "ServerCallback_TitanEMP", 0.4, 2.4, 0.4 )
	player.s.Use123123 <- true
	return true
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

float CM_FIREHIGHER = 5000
void function KillStreak_Init()
{
	PrecacheModel( $"models/Robots/turret_rocket/turret_rocket.mdl" )
	RegisterWeaponDamageSource( "mp_weapon_cruise_missile", "巡飛彈" )
	RegisterSignal( "MissileImpact" )
	RegisterSignal( "CalculateCruiseMissilePoint" )
	RegisterSignal( "CruiseMissileExplode" )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, OnWinnerDetermined )
	AddCallback_OnPlayerRespawned( RestoreKillStreak )
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddCallback_OnNPCKilled( OnPlayerKilled )
	AddCallback_OnClientConnected( OnClientConnected )

	if( GetMapName() == "mp_grave" )
		CM_FIREHIGHER = 4500
	if( GetMapName() == "mp_wargames" )
		CM_FIREHIGHER = 4000
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
			if( attacker.s.totalKills % 6 == 0 || attacker.s.KillStreak % 4 == 0 )
			{
				if( attacker.s.totalKills % 6 == 0 && attacker.s.KillStreak % 4 == 0 )
				{
					attacker.s.NukeTitan += 2
					NSSendAnnouncementMessageToPlayer( attacker, "獲得雙倍核武泰坦！", "剩餘"+ attacker.s.NukeTitan +"個未交付", < 255, 0, 0 >, 255, 5 )
				}
				else
				{
					attacker.s.NukeTitan += 1
					NSSendAnnouncementMessageToPlayer( attacker, "獲得核武泰坦！", "剩餘"+ attacker.s.NukeTitan +"個未交付", < 255, 0, 0 >, 255, 5 )
				}
			}
			if( attacker.s.totalKills % 20 == 0 )
			{
				attacker.s.cruiseMissile += 1
				NSSendAnnouncementMessageToPlayer( attacker, "獲得巡飛彈！", "", < 255, 0, 0 >, 255, 5 )
			}
			if( attacker.s.KillStreakNoNPC == 30 )
			{
				attacker.s.HaveNuclearBomb <- true	//给核弹，给监听用
				NSSendAnnouncementMessageToPlayer( attacker, "聚變打擊已就緒", "", < 255, 0, 0 >, 255, 5 )
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
	player.s.NukeTitan <- 0
	player.s.cruiseMissile <- 0
	player.s.cmBeforeOrigin <- < 0, 0, 0 >
	player.s.usingCruiseMissile <- false
	player.s.dropShipAlive <- true

	// GUI //
	player.s.KsGUIL1 <- 0
	player.s.KsGUIL2 <- false
	player.s.KsGUIL2_1 <- 0
	player.s.lastGUITime <- 0.0
	AddPlayerHeldButtonEventCallback( player, IN_OFFHAND2, KsGUI, 0 )
}

bool function DropBattery( entity player )
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

			SendHudMessage( player, "\n已丢出电池!", -1, 0.3, 100, 255, 100, 255, 0, 2, 1 )
			EmitSoundOnEntityOnlyToPlayer( player, player, "UI_Menu_Store_Purchase_Success" )
			return true
		}
	}
	return false
}

void function KsGUI( entity player )
{
	table result = {}
	result.timeOut <- false
	if( !player.IsHuman() || player.s.usingCruiseMissile )
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
	wait 0.3
	if( !IsValid( player ) )
		return
	if( player.s.lastGUITime + 4 < Time() )
	{
		if( DropBattery( player ) )
			result.timeOut <- true
		return
	}
	if( player.s.lastGUITime + 2 < Time() )
		return

	result.timeOut <- true

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
	if( l1 == 3 )
		KsGUI_L2_NB( player )
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
		for( ;; )
		{
			NukeTitan( player, false )
			player.s.lastGUITime = Time()
			wait 0.5
		}
	}
	if( l1 == 1 && l2 == 1 )
	{
		NukeTitan( player, true )
		player.s.KsGUIL2 = false
	}
}

void function KsGUI_L2_NB( entity player )
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
		EmitSoundOnEntityOnlyToPlayer( player, player, "UI_InGame_FD_ArmoryPurchase" )
		return
	}

	SendHudMessage( player, "\n聚变打击离线", -1, 0.3, 255, 100, 100, 255, 0, 2, 1 )
	EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
}

void function KsGUI_L2_2( entity player )
{
	if( player.s.cruiseMissile == 0 )
	{
		SendHudMessage( player, "\n无巡弋飞弹", -1, 0.3, 255, 100, 100, 255, 0, 2, 1 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
		return
	}
	if( !IsAlive( player ) )
	{
		SendHudMessage( player, "\n死亡时不可使用巡弋飞弹", -1, 0.3, 255, 100, 100, 255, 0, 2, 1 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
		return
	}
	if( IsValid( player.GetTitanSoulBeingRodeoed() ) )
	{
		SendHudMessage( player, "\n训牛时不可使用巡弋飞弹", -1, 0.3, 255, 100, 100, 255, 0, 2, 1 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
		return
	}
	if( player.GetParent() )
	{
		SendHudMessage( player, "\n在有绑定的父级实体时不可使用巡弋飞弹", -1, 0.3, 255, 100, 100, 255, 0, 2, 1 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
		return
	}
	if( !player.IsHuman() )
	{
		SendHudMessage( player, "\n你需要处于铁驭状态才能使用巡弋飞弹", -1, 0.3, 255, 100, 100, 255, 0, 2, 1 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
		return
	}
	if( !player.IsOnGround() )
	{
		SendHudMessage( player, "\n你需要站在地上才能使用巡弋飞弹", -1, 0.3, 255, 100, 100, 255, 0, 2, 1 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
		return
	}
	if( player.IsPhaseShifted() )
	{
		SendHudMessage( player, "\n你需要离开相位才能使用巡弋飞弹", -1, 0.3, 255, 100, 100, 255, 0, 2, 1 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
		return
	}
	foreach( ent in GetPlayerArray() )
	{
		if( ent.s.usingCruiseMissile )
		{
			SendHudMessage( player, "\n场上有其他玩家正在使用巡弋飞弹", -1, 0.3, 255, 100, 100, 255, 0, 2, 1 )
			EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
			return
		}
	}

	thread CruiseMissileAnim_ThinkBefore( player )
	SendHudMessage( player, " ", -1, 0.3, 100, 255, 100, 255, 0, 2, 1 )
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_InGame_FD_ArmoryPurchase" )
	player.s.cruiseMissile -= 1
}

void function KsGUI_L2_1( entity player )
{
	bool skipL2Add = false
	if( player.s.KsGUIL2 && player.s.lastGUITime + 3 < Time() )
	{
		player.s.KsGUIL2 = false
		return KsGUI_SwitchL1( player )
	}
	if( player.s.KsGUIL2 && player.s.lastGUITime + 2 > Time() )
	{
		if( player.s.KsGUIL2_1 == 1 )
			player.s.KsGUIL2_1 = 0
		else
			player.s.KsGUIL2_1 = 1
	}
	player.s.lastGUITime = Time()

	if( player.s.KsGUIL2 == false )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, "Menu_LoadOut_Titan_Select" )
		player.s.KsGUIL2_1 = 0
	}
	else
		EmitSoundOnEntityOnlyToPlayer( player, player, "menu_click" )

	player.s.KsGUIL2 = true

	local l2 = player.s.KsGUIL2_1
	if( l2 == 0 )
		SendHudMessage( player, "当前剩余"+ player.s.NukeTitan +"个核武未交付\n\n◆交付一个◆  -  ◇交付全部◇", -1, 0.3, 200, 200, 225, 255, 0, 2, 1 )
	else
		SendHudMessage( player, "当前剩余"+ player.s.NukeTitan +"个核武未交付\n\n◇交付一个◇  -  ◆交付全部◆", -1, 0.3, 200, 200, 225, 255, 0, 2, 1 )

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

			SendHudMessage( player, "\n已丢出电池!", -1, 0.3, 100, 255, 100, 255, 0, 2, 1 )
			EmitSoundOnEntityOnlyToPlayer( player, player, "UI_Menu_Store_Purchase_Success" )
			return
		}
	}
	SendHudMessage( player, "\n你没有电池！", -1, 0.3, 255, 100, 100, 255, 0, 2, 1 )
	EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
}

const array<string> KSGUI_L1_TEXT =	[ "丢出电池", "核武泰坦", "巡弋飞弹", "聚变打击" ]
const array< array<string> > KSGUI_L1_SPACE = [ [ "  ", "  " ], [ " ", " " ], [ " ", " " ], [ "  ", "  " ] ]

void function KsGUI_SwitchL1( entity player )
{
	if( player.s.lastGUITime + 2 > Time() )
	{
		if( player.s.KsGUIL1 < KSGUI_L1_TEXT.len() - 1 )
			player.s.KsGUIL1 += 1
		else
			player.s.KsGUIL1 = 0
	}
	player.s.lastGUITime = Time()

	array<var> skipL1Elem = []
	if( !PlayerHasMaxBatteryCount( player ) )
		skipL1Elem.append( 0 )
	if( player.s.NukeTitan == 0 )
		skipL1Elem.append( 1 )
	if( player.s.cruiseMissile == 0 )
		skipL1Elem.append( 2 )
	if( player.s.HaveNuclearBomb == false )
		skipL1Elem.append( 3 )

	if( skipL1Elem.len() == KSGUI_L1_TEXT.len() )
	{
		player.s.KsGUIL1 = 0
		player.s.lastGUITime = Time() - 4
		return
	}

	foreach( i in skipL1Elem )
	{
		if( skipL1Elem.contains( player.s.KsGUIL1 ) )
		{
			if( player.s.KsGUIL1 < KSGUI_L1_TEXT.len() - 1 )
				player.s.KsGUIL1 += 1
			else
				player.s.KsGUIL1 = 0
		}
	}


	local l1 = player.s.KsGUIL1
	string text = "短按切换 == Main Menu == 长按选中\n\n"
	int i = 0
	bool isFristElem = true

	for( ;; )
	{
		if( i == KSGUI_L1_TEXT.len() )
			break

		if( skipL1Elem.contains( i ) )
		{
			i++
			continue
		}

		if( !isFristElem )	//notFristElem
			text += "-"
		else				//isFristElem
			isFristElem = false

		text += KSGUI_L1_SPACE[i][0]

		if( i == l1 )
			text += "◆"
		else
			text += "◇"

		text += KSGUI_L1_TEXT[ i ]

		if( i == 1 )
		{
			if( player.s.NukeTitan < 10 )
				text += "(0"+ player.s.NukeTitan +")"
			else
				text += "("+ player.s.NukeTitan +")"
		}
		if( i == 2 )
		{
			if( player.s.cruiseMissile < 10 )
				text += "(0"+ player.s.cruiseMissile +")"
			else
				text += "("+ player.s.cruiseMissile +")"
		}

		if( i == l1 )
			text += "◆"
		else
			text += "◇"

		text += KSGUI_L1_SPACE[i][1]

		i++
	}

	EmitSoundOnEntityOnlyToPlayer( player, player, "menu_click" )
	SendHudMessage( player, text, -1, 0.3, 200, 200, 225, 255, 0, 2, 1 )

}

void function NukeTitan( entity player, bool all )
{
	if( player.s.NukeTitan <= 0 )
	{
		SendHudMessage( player, "\n你没有核武泰坦!", -1, 0.3, 255, 100, 100, 255, 0, 2, 1 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
		return
	}
	if( !player.IsHuman() )
	{
		SendHudMessage( player, "\n你需要处于铁驭状态才能交付核武泰坦", -1, 0.3, 255, 100, 100, 255, 0, 2, 1 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "menu_deny" )
		return
	}
	if( all )
	{
		SendHudMessage( player, "\n成功交付了 "+ player.s.NukeTitan +" 个核武泰坦", -1, 0.3, 100, 255, 100, 255, 0, 2, 1 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "UI_InGame_FD_ArmoryPurchase" )
		for( var i = player.s.NukeTitan; i > 0; i -= 1)
		{
			PlayerInventory_GiveNukeTitan( player )
		}
		player.s.NukeTitan = 0
	}
	else
	{
		player.s.NukeTitan -= 1
		SendHudMessage( player, "\n成功交付了 1 个核武泰坦\n剩余 "+ player.s.NukeTitan +" 个核武泰坦未交付", -1, 0.3, 100, 255, 100, 255, 0, 2, 1 )
		EmitSoundOnEntityOnlyToPlayer( player, player, "UI_InGame_FD_ArmoryPurchase" )
		PlayerInventory_GiveNukeTitan( player )
	}
}


void function RestoreKillStreak( entity player )
{
	if( player.s.NukeTitan != 0 || player.s.cruiseMissile != 0 )
			NSSendAnnouncementMessageToPlayer( player, "有連殺獎勵未使用！", "鐵馭狀態下按 泰坦輔助技能鍵（默認為G） 打開菜單！", < 200, 200, 255 >, 255, 5 )
	if( player.s.HaveNuclearBomb == true )
			SendHudMessage( player, "//////// 聚变打击已就绪 ////////", -1, 0.4, 255, 0, 0, 255, 0.15, 5, 1 )
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
	if( !IsValid( player ) )
		return
	if( !titan.IsPlayer() )
		player = GetPetTitanOwner( titan )
	if( !IsValid( soul ) )
		return
	if( "TitanHasBeenChange" in soul.s )
		if( soul.s.TitanHasBeenChange == true )
			return

	if( titan.GetModelName() == $"models/titans/light/titan_light_northstar_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		soul.s.titanTitle <- "野獸四號"
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
        titan.GiveWeapon( "mp_titanweapon_rocketeer_rocketstream", [ "tcp_brute" ] )
	  	titan.GiveOffhandWeapon( "mp_titanability_particle_wall", OFFHAND_SPECIAL, [ "tcp_dash_shield" ] )
		titan.GiveOffhandWeapon( "mp_titanability_hover", OFFHAND_TITAN_CENTER, [ "tcp_super_hover" ] )
        titan.GiveOffhandWeapon( "mp_titanability_sonar_pulse", OFFHAND_ORDNANCE, [ "tcp_gravity" ] )
		titan.GiveOffhandWeapon( "mp_titancore_laser_cannon", OFFHAND_EQUIPMENT, [ "tcp_gravity" ] )

		array<int> passives = [ ePassives.PAS_NORTHSTAR_WEAPON,
								ePassives.PAS_NORTHSTAR_CLUSTER,
								ePassives.PAS_NORTHSTAR_TRAP,
								ePassives.PAS_NORTHSTAR_FLIGHTCORE,
								ePassives.PAS_NORTHSTAR_OPTICS ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
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
		titan.SetSharedEnergyRegenDelay( 2.0 )
		titan.SetSharedEnergyRegenRate( 200 )
		soul.s.SharedEnergyRegenRate <- 200
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
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield_ion", OFFHAND_SPECIAL, [ "tcp_vortex", "burn_mod_titan_vortex_shield" ] )
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
		titan.TakeOffhandWeapon( OFFHAND_MELEE )
		titan.GiveOffhandWeapon( "mp_ability_swordblock", OFFHAND_SPECIAL )
		titan.GiveOffhandWeapon( "mp_titanability_smoke", OFFHAND_TITAN_CENTER, [ "tcp_emp" ])
		titan.GiveOffhandWeapon( "mp_titanweapon_homing_rockets", OFFHAND_ORDNANCE )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT, ["tcp_dash_core"] )
		titan.GiveOffhandWeapon( "melee_titan_punch_northstar", OFFHAND_MELEE )

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
		titan.GiveOffhandWeapon( "mp_titanability_particle_wall", OFFHAND_SPECIAL, [ "brute4_bubble_shield" ] )
		titan.GiveOffhandWeapon( "mp_titanability_sonar_pulse", OFFHAND_TITAN_CENTER, [ "tcp_smoke" ] )
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

////////////////////
///    KS SYS   ////
////////////////////

//// CruiseMissile ////

void function CruiseMissileAnim_ThinkBefore( entity owner )
{
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDeath" )
	owner.s.usingCruiseMissile = true
	owner.kv.VisibilityFlags = 0
	PhaseShift( owner, 0, 1.2 )
	HolsterAndDisableWeapons( owner )
	owner.SetOrigin( owner.GetOrigin() )
	FindNearestSafeSpotAndPutEntity( owner, 5 )
	owner.FreezeControlsOnServer()
	owner.SetInvulnerable()
	owner.s.cmBeforeOrigin = owner.GetOrigin()
	vector cmFireOrigin = owner.GetOrigin()
	cmFireOrigin.z = CM_FIREHIGHER
	vector cmFireAngles = < 0, RandomIntRange( 0, 359 ), 0 >

	OnThreadEnd(
		function() : ( owner )
		{
			if( !IsValid( owner ) )
				return
			owner.s.usingCruiseMissile = false
			owner.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
			owner.ClearInvulnerable()
			DeployAndEnableWeapons( owner )
			owner.UnfreezeControlsOnServer()
			owner.SetPhysics( MOVETYPE_WALK )
			Remote_CallFunction_Replay( owner, "ServerCallback_TitanEMP", 0.4, 0.4, 0.4 )
			ScreenFade( owner, 0, 0, 0, 255, 2, 0.2, (FFADE_IN | FFADE_PURGE) )

			if( !IsAlive( owner ) )
				return
			owner.SetOrigin( owner.s.cmBeforeOrigin )
			FindNearestSafeSpotAndPutEntity( owner, 5 )
			PlayFXOnEntity( $"P_phase_shift_main", owner )
			EmitSoundOnEntityOnlyToPlayer( owner, owner, "Pilot_PhaseShift_WarningToEnd_1P" )
			EmitSoundOnEntityExceptToPlayer( owner, owner, "Pilot_PhaseShift_WarningToEnd_3P" )
		}
	)

	ScreenFadeToBlack( owner, 0.9, 0.8 )
	owner.SetPhysics( MOVETYPE_NOCLIP )	//防止玩家因为逃离战场而去世
	wait 1.0
	thread CruiseMissileAnim_Think( owner, cmFireOrigin, cmFireAngles )

	for( ;; )
	{
		WaitFrame()
		if( !owner.s.usingCruiseMissile )
			return
		vector origin = cmFireOrigin
		origin.z += 200
		owner.SetOrigin( origin )
	}
}

void function CruiseMissileAnim_Think( entity owner, vector cmFireOrigin, vector cmFireAngles )
{
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDeath" )

	foreach( player in GetPlayerArray() )
	{
		if( !IsValid( player ) )
			continue
		if( player == owner )
			continue
		if( player.GetTeam() == owner.GetTeam() )
		{
			NSSendLargeMessageToPlayer( player,"友方巡飛彈投放中！", "投放飛艇會標記出所有敵人的的位置！保護飛艇！", 7, "rui/callsigns/callsign_95_col" )
			EmitSoundOnEntityOnlyToPlayer( player, player, "lstar_lowammowarning" )
			continue
		}
		NSSendLargeMessageToPlayer( player,"巡飛彈來襲！", "注意頭頂！投放飛艇會標記出你的的位置！但你可以打掉飛艇！", 7, "rui/callsigns/callsign_95_col" )
		EmitSoundOnEntityOnlyToPlayer( player, player, "lstar_lowammowarning" )
	}

	table result = {}
	result.timeOut <- false
	result.timeOut2 <- false

	entity dropship = CreateDropship( owner.GetTeam(), cmFireOrigin, cmFireAngles )
	asset shipMdl = owner.GetTeam() == TEAM_MILITIA ? $"models/vehicle/crow_dropship/crow_dropship_hero.mdl" : $"models/vehicle/goblin_dropship/goblin_dropship_hero.mdl"
	owner.s.dropShipAlive = true
	DispatchSpawn( dropship )
	dropship.EndSignal( "OnDestroy" )
	dropship.EndSignal( "OnDeath" )
	dropship.SetValueForModelKey( shipMdl )
	dropship.SetHealth( 2500 )
	dropship.SetMaxHealth( 2500 )
	dropship.SetModel( shipMdl )
	thread WarpInEffectEvacShip( dropship )
	entity mover = CreateScriptMover( cmFireOrigin, cmFireAngles )

	vector camAngles = cmFireAngles
	camAngles.x += 60
	camAngles.y += 90
	if( camAngles.y > 360 )
		camAngles.y -= 360

	entity turret = CreateTurretEnt( cmFireOrigin,  cmFireAngles, null, ROCKET_TURRET_MODEL, "PROTO_at_turret" )
	turret.Hide()
	turret.SetInvulnerable()
	turret.SetParent( dropship ) // if missile gets destroyed,
	turret.SetAngles( < 45, -90, 0 > )
	turret.SetOrigin( < -800, 0, 1200 > )
	turret.GiveWeapon( "mp_weapon_rocket_launcher" )
	DisableWeapons( turret, [] )
	owner.SetAngles( camAngles )
	owner.SetOrigin( owner.GetOrigin() )
	FindNearestSafeSpotAndPutEntity( owner, 5 )
	thread DropShipTempHide( dropship, turret, owner )


	OnThreadEnd(
		function() : ( turret, mover, dropship, owner, result )
		{
			if( IsValid( turret ) )
			{
				turret.ClearDriver()
				turret.Destroy()
			}
			thread DropShipFlyOut( dropship, mover )
			if( IsValid( owner ) )
			{
				if( !result.timeOut )
				{
					owner.s.usingCruiseMissile = false
					EmitSoundOnEntityOnlyToPlayer( owner, owner, "goblin_dropship_explode" )
				}
				if( !result.timeOut2 )
					owner.s.dropShipAlive = false
				StopSoundOnEntity( owner, "scr_s2s_intro_crow_engage_warp_speed" )
			}
		}
	)

	thread DropShipSonar( owner, owner.GetTeam(), cmFireOrigin )

	thread PlayAnim( dropship, "cd_dropship_rescue_side_start", mover )	//fly in
	EmitSoundOnEntity( dropship, "Goblin_IMC_Evac_Flyin" )
	EmitSoundOnEntityOnlyToPlayer( owner, owner, "scr_s2s_intro_crow_engage_warp_speed" )
	float sequenceDuration = dropship.GetSequenceDuration( "cd_dropship_rescue_side_start" )
	float cycleFrac = dropship.GetScriptedAnimEventCycleFrac( "cd_dropship_rescue_side_start", "ReadyToLoad" )
	wait ( sequenceDuration * cycleFrac ) - 0.3

	mover.SetOrigin( turret.GetOrigin() )
	turret.SetParent( mover )
	turret.SetAngles( camAngles )
	mover.NonPhysicsMoveTo( dropship.GetOrigin(), 0.3, 0.0, 0.0 )
	ScreenFadeToBlack( owner, 0.3, 0.2 )

	wait 0.3
	mover.SetOrigin( cmFireOrigin )
	thread PlayAnim( dropship, "cd_dropship_rescue_side_idle", mover )	//waiting

	wait 0.1
	owner.UnfreezeControlsOnServer()
	turret.ClearDriver()
	turret.Destroy()
	camAngles.x += 15
	owner.SetAngles( camAngles )
	StopSoundOnEntity( owner, "scr_s2s_intro_crow_engage_warp_speed" )
	result.timeOut <- true
	thread FireCruiseMissile( owner, cmFireOrigin, cmFireAngles, camAngles )	//launcher
	mover.SetOrigin( cmFireOrigin )

	owner.WaitSignal( "CruiseMissileExplode" )

	owner.s.dropShipAlive = false
	result.timeOut2 <- true
}

void function DropShipFlyOut( entity dropship, entity mover )
{
	if( IsValid( dropship ) )
	{
		thread PlayAnim( dropship, "cd_dropship_rescue_side_end", mover )	//flyout
		wait dropship.GetSequenceDuration( "cd_dropship_rescue_side_end" )
	}

	if( IsValid( dropship ) )
		dropship.kv.VisibilityFlags = 0 // prevent jetpack trails being like "dive" into ground
	WaitFrame() // better wait because we are server

	if( IsValid( dropship ) )
		thread __WarpOutEffectShared( dropship )
	wait 1

	if( IsValid( dropship ) )
		dropship.Destroy()

	mover.Destroy()
}

void function DropShipTempHide( entity dropship, entity turret, entity owner )
{
	dropship.kv.VisibilityFlags = 0 // or it will still shows the jetpack fxs
	HideName( dropship )
	wait 0.65
	if( IsValid( dropship ) && IsValid( turret ) && IsValid( owner ) )
	{
		dropship.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
		ShowName( dropship )
		turret.SetDriver( owner )
	}
}

void function WarpInEffectEvacShip( entity dropship )
{
	dropship.EndSignal( "OnDestroy" )
	float sfxWait = 0.1
	float totalTime = WARPINFXTIME
	float preWaitTime = 0.16 // give it some time so it's actually playing anim, and we can get it's "origin" attatch for playing warp in effect
	string sfx = "dropship_warpin"

	wait preWaitTime

	int attach = dropship.LookupAttachment( "origin" )
	vector origin = dropship.GetAttachmentOrigin( attach )
	vector angles = dropship.GetAttachmentAngles( attach )

	entity fx = PlayFX( FX_GUNSHIP_CRASH_EXPLOSION_ENTRANCE, origin, angles )
	fx.FXEnableRenderAlways()
	fx.DisableHibernation()

	wait sfxWait
	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, sfx )

	wait totalTime - sfxWait
}

void function DropShipSonar( entity owner, int sonarTeam, vector cmFireOrigin )
{
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDeath" )
	owner.EndSignal( "CruiseMissileExplode" )

	array<entity> sonarEnt = []

	foreach( ent in GetNPCArray() )
	{
		sonarEnt.append( ent )
		DropShipSonarStart( ent, sonarTeam, cmFireOrigin )
	}
	foreach( ent in GetPlayerArray() )
	{
		sonarEnt.append( ent )
		DropShipSonarStart( ent, sonarTeam, cmFireOrigin )
	}

	OnThreadEnd(
		function() : ( sonarTeam, sonarEnt )
		{
			foreach( ent in sonarEnt )
			{
				DropShipSonarEnd( ent, sonarTeam )
			}
		}
	)
	for( ;; )
	{
		if( !owner.s.dropShipAlive )
			break
		WaitFrame()
	}
}
void function DropShipSonarStart( entity ent, int sonarTeam, vector cmFireOrigin )
{
	if( !IsValid( ent ) )
		return
	if( ent.GetTeam() == sonarTeam )
		return
	ent.HighlightEnableForTeam( sonarTeam )

	if ( !ent.IsPlayer() )
	{
		if ( StatusEffect_Get( ent, eStatusEffect.damage_received_multiplier ) > 0 )
			Highlight_SetSonarHighlightWithParam0( ent, "enemy_sonar", <1,0,0> )
		else
			Highlight_SetSonarHighlightWithParam1( ent, "enemy_sonar", cmFireOrigin )
	}
	else
	{
		ent.SetCloakFlicker( 0.5, -1 )
	}

	Highlight_SetSonarHighlightOrigin( ent, cmFireOrigin )

	int statusEffectHandle = StatusEffect_AddEndless( ent, eStatusEffect.sonar_detected, 1.0 )
	ent.s.statusEffectHandle <- statusEffectHandle
}
void function DropShipSonarEnd( entity ent, int team )
{
	if ( !IsValid( ent ) )
		return
	ent.HighlightDisableForTeam( team )

	if( "statusEffectHandle" in ent.s )
		StatusEffect_Stop( ent, ent.s.statusEffectHandle )

	ent.HighlightSetTeamBitField( 0 )

	if ( ent.IsPlayer() )
		ent.SetCloakFlicker( 0, 0 )
}

void function FireCruiseMissile( entity weaponOwner, vector cmFireOrigin, vector cmFireAngles, vector camAngles )
{
	StorePilotWeapons( weaponOwner )
	entity weapon = weaponOwner.GiveWeapon( "mp_weapon_rocket_launcher" )

	bool shouldPredict = weapon.ShouldPredictProjectiles()

	float speed = 500.0

	thread CalculateCruiseMissilePoint( weapon, weaponOwner )

	vector beForeOrigin = weaponOwner.GetOrigin()
	vector missileSpawnOrigin = cmFireOrigin
	missileSpawnOrigin.z -= 60
	weaponOwner.SetOrigin( missileSpawnOrigin )
	entity missile = weapon.FireWeaponMissile( missileSpawnOrigin, camAngles, speed, damageTypes.projectileImpact | DF_IMPACT, damageTypes.explosive, false, shouldPredict )
	weaponOwner.SetOrigin( beForeOrigin )

	if ( missile )
	{
		EmitSoundOnEntityOnlyToPlayer( weaponOwner, weaponOwner, "Weapon_Archer_Fire_1P" )
		thread CruiseMissileThink( weapon, weaponOwner, missile )
	}
}
void function CalculateCruiseMissilePoint( entity weapon, entity weaponOwner )
{
	weaponOwner.EndSignal( "OnDestroy" )
	weaponOwner.EndSignal( "OnDeath" )
	weaponOwner.Signal( "CalculateCruiseMissilePoint" )
	weaponOwner.EndSignal( "CalculateCruiseMissilePoint" )
	weapon.EndSignal( "OnDestroy" )

	entity info_target = CreateEntity( "info_target" )
	info_target.SetOrigin( weapon.GetOrigin() )
	info_target.SetInvulnerable()
	DispatchSpawn( info_target )
	weapon.s.guidedMissileTarget <- info_target

	OnThreadEnd(
		function() : ( weapon, info_target )
		{
			if ( IsValid( info_target ) )
			{
				info_target.Kill_Deprecated_UseDestroyInstead()
				if ( IsValid( weapon ) )
					delete weapon.s.guidedMissileTarget
			}
		}
	)

	while ( true )
	{
		if ( !IsValid_ThisFrame( weaponOwner ) || !IsValid_ThisFrame( weapon ) )
			return

		TraceResults result = GetViewTrace( weaponOwner )
		info_target.SetOrigin( result.endPos )

		WaitFrame()
	}
}

void function CruiseMissileThink( entity weapon, entity weaponOwner, entity missile )
{
	weaponOwner.EndSignal( "OnDestroy" )
	weaponOwner.EndSignal( "OnDeath" )
	missile.EndSignal( "OnDestroy" )
	missile.EndSignal( "MissileImpact" )

	if( "guidedMissileTarget" in weapon.s && IsValid( weapon.s.guidedMissileTarget ) )
	{
		missile.SetMissileTarget( weapon.s.guidedMissileTarget, Vector( 0, 0, 0 ) )
		missile.SetHomingSpeeds( 400, 0 )
	}

	missile.kv.lifetime = 12

	//HACK: using turret
	entity turret = CreateTurretEnt( missile.GetOrigin(), missile.GetAngles(), null, ROCKET_TURRET_MODEL, "PROTO_at_turret" )
	turret.Hide()
	//turret.NotSolid()
	turret.SetInvulnerable()
	turret.SetParent( missile, "exhaust" ) // if missile gets destroyed,
	turret.SetAngles( < 180, 0, -90 > )
	turret.GiveWeapon( "mp_weapon_rocket_launcher" )
	DisableWeapons( turret, [] )
	turret.SetDriver( weaponOwner )

	// needed to avoid missile gets destroyed and player stuck in turret forever
	AddEntityDestroyedCallback(
		missile,
		function( missile ) : ( missile, turret )
		{
			if ( IsValid( turret ) )
				turret.ClearParent() // clear turret so it won't get destroyed
		}
	)

	AddEntityDestroyedCallback(
		turret,
		function( turret ) : ( turret, weaponOwner )
		{
			if ( IsValid( turret ) )
				turret.ClearDriver() // clear driver before turret actually gets destroyed
		}
	)

	OnThreadEnd(
		function(): ( weapon, weaponOwner, turret )
		{
			if ( IsValid( weaponOwner ) )
			{
				weaponOwner.Signal( "CruiseMissileExplode" )
				StopSoundOnEntity( weaponOwner, "scr_s2s_intro_widow_engage_warp_speed" )
				StopSoundOnEntity( weaponOwner, "scr_s2s_intro_seyar_flyby" )

				EmitSoundOnEntityOnlyToPlayer( weaponOwner, weaponOwner, "titan_nuclear_death_explode" )

				RetrievePilotWeapons( weaponOwner )
				TakePassive( weaponOwner, ePassives.PAS_FUSION_CORE )

				// if missile accidentally gets destroyed, this is required to make player out of movement lock
				if ( !IsValid( turret ) )
					weaponOwner.Die( weaponOwner, weaponOwner, { damageSourceId = damagedef_suicide } )
				else
					thread CruiseMissileExplode( turret.GetOrigin(), weaponOwner )

				weaponOwner.s.usingCruiseMissile = false
			}

			if ( IsValid( turret ) )
			{
				turret.ClearDriver()
				turret.Destroy()
			}
		}
	)

	EmitSoundOnEntityOnlyToPlayer( weaponOwner, weaponOwner, "scr_s2s_intro_seyar_flyby" )
	GivePassive( weaponOwner, ePassives.PAS_AUTO_SONAR )
	bool HasAppendSpeed = false
	int sec = 50
	for( ;; )
	{
		sec--
		if( !IsValid( weaponOwner ) )
			break
		if( ( weaponOwner.IsInputCommandHeld( IN_ATTACK ) || sec == 0 ) && !HasAppendSpeed )
		{
			missile.SetVelocity( missile.GetForwardVector() * 6000 )
			Remote_CallFunction_Replay( weaponOwner, "ServerCallback_TitanEMP", 0.1, 0.5, 0.5 )
			StopSoundOnEntity( weaponOwner, "scr_s2s_intro_seyar_flyby" )
			EmitSoundOnEntityOnlyToPlayer( weaponOwner, weaponOwner, "scr_s2s_intro_widow_engage_warp_speed" )

			HasAppendSpeed = true
		}

		if( HasAppendSpeed )
		{
			StatusEffect_AddTimed( weaponOwner, eStatusEffect.stim_visual_effect, 1.0, 0.1, 0 )
			Remote_CallFunction_Replay( weaponOwner, "ServerCallback_ScreenShake", 400, 200, 0.2 )
			GivePassive( weaponOwner, ePassives.PAS_FUSION_CORE )
			if( weaponOwner.s.dropShipAlive )
				SendHudMessage( weaponOwner, "投放艇战区扫描标记信息系统在线\n//////////////// 动力段已启动 ////////////////\n巡弋飞弹自毁倒计时 T-"+ float( sec + 70 ) / 10 +"s", -1, -0.3, 255, 0, 0, 255, 0, 0.2, 0 )
			else
				SendHudMessage( weaponOwner, "//////// 投放艇信号丢失 ////////\n//////////////// 动力段已启动 ////////////////\n巡弋飞弹自毁倒计时 T-"+ float( sec + 70 ) / 10 +"s", -1, -0.3, 255, 0, 0, 255, 0, 0.2, 0 )
		}
		else
		{
			if( weaponOwner.s.dropShipAlive )
				SendHudMessage( weaponOwner, "投放艇战区扫描标记信息系统在线\n缓冲段燃料剩余时间 T-" + float( sec ) / 10 +"s\n按住 攻击键 立刻启动动力段", -1, -0.3, 255, 0, 0, 255, 0, 0.2, 0 )
			else
				SendHudMessage( weaponOwner, "//////// 投放艇信号丢失 ////////\n缓冲段燃料剩余时间 T-" + float( sec ) / 10 +"s\n按住 攻击键 立刻启动动力段", -1, -0.3, 255, 0, 0, 255, 0, 0.2, 0 )
		}

		WaitFrame()
	}
}

void function CruiseMissileExplode( vector origin, entity owner )
{
	PlayFX( TITAN_NUCLEAR_CORE_FX_3P, origin + Vector( 0, 0, -100 ), Vector(0,RandomInt(360),0) )

	entity inflictor = CreateEntity( "script_ref" )
	inflictor.SetOrigin( origin )
	inflictor.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	DispatchSpawn( inflictor )

	EmitSoundOnEntity( inflictor, "titan_nuclear_death_explode" )

	OnThreadEnd(
		function() : ( inflictor )
		{
			if ( IsValid( inflictor ) )
				inflictor.Destroy()
		}
	)

	for ( int i = 0; i < 20; i++ )
	{
		RadiusDamage(
			origin,										// center
			owner,										// attacker
			inflictor,									// inflictor
			75,											// damage
			1500,										// damageHeavyArmor
			350,										// innerRadius
			750,										// outerRadius
			0,											// flags
			0,											// distanceFromAttacker
			75,											// explosionForce
			DF_EXPLOSION | DF_STOPS_TITAN_REGEN,		// scriptDamageFlags
			eDamageSourceId.mp_weapon_cruise_missile )	// scriptDamageSourceIdentifier

		wait 0.1
	}
}

void function FindNearestSafeSpotAndPutEntity( entity ent, int severity )
{
	vector baseOrigin = ent.GetOrigin()

    if( PutEntityInSafeSpot( ent, ent, null, < baseOrigin.x, baseOrigin.y+severity, baseOrigin.z >, baseOrigin ) )
        return

    if( PutEntityInSafeSpot( ent, ent, null, < baseOrigin.x, baseOrigin.y-severity, baseOrigin.z >, baseOrigin ) )
        return

    if( PutEntityInSafeSpot( ent, ent, null, < baseOrigin.x+severity, baseOrigin.y, baseOrigin.z >, baseOrigin ) )
        return

	if( PutEntityInSafeSpot( ent, ent, null, < baseOrigin.x-severity, baseOrigin.y, baseOrigin.z >, baseOrigin ) )
        return

	if( PutEntityInSafeSpot( ent, ent, null, < baseOrigin.x, baseOrigin.y, baseOrigin.z+severity >, baseOrigin ) )
        return

	if( PutEntityInSafeSpot( ent, ent, null, < baseOrigin.x, baseOrigin.y, baseOrigin.z-severity >, baseOrigin ) )
        return

    return FindNearestSafeSpotAndPutEntity( ent, severity+5 )
}

//// NuclearBomb ////

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
			if( GetMapName() == "mp_black_water_canal" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_black_water_canal" )
			break
		case 1:
			if( GetMapName() == "mp_complex3" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_complex3" )
			break
		case 2:
			if( GetMapName() == "mp_crashsite3" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_crashsite3" )
			break
		case 3:
			if( GetMapName() == "mp_drydock" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_drydock" )
			break
		case 4:
			ReRandom()
			return
			if( GetMapName() == "mp_eden" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_eden" )
			break
		case 5:
			if( GetMapName() == "mp_forwardbase_kodai" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_forwardbase_kodai" )
			break
		case 6:
			if( GetMapName() == "mp_grave" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_grave" )
			break
		case 7:
			if( GetMapName() == "mp_homestead" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_homestead" )
			break
		case 8:
			if( GetMapName() == "mp_thaw" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_thaw" )
			break
		case 9:
			if( GetMapName() == "mp_angel_city" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_angel_city" )
			break
		case 10:
			if( GetMapName() == "mp_colony02" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_colony02" )
			break
		case 11:
			if( GetMapName() == "mp_relic02" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_relic02" )
			break
		case 12:
			if( GetMapName() == "mp_wargames" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_wargames" )
			break
		case 13:
			if( GetMapName() == "mp_glitch" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_glitch" )
			break
		case 14:
			if( GetMapName() == "mp_rise" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_rise" )
			break
		default:
			break
	}
}
void function ReRandom()
{
	int RandomInt = RandomInt( 15 )
	switch( RandomInt )
	{
		case 0:
			if( GetMapName() == "mp_black_water_canal" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_black_water_canal" )
			break
		case 1:
			if( GetMapName() == "mp_complex3" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_complex3" )
			break
		case 2:
			if( GetMapName() == "mp_crashsite3" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_crashsite3" )
			break
		case 3:
			if( GetMapName() == "mp_drydock" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_drydock" )
			break
		case 4:
			ReRandom()
			return
			if( GetMapName() == "mp_eden" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_eden" )
			break
		case 5:
			if( GetMapName() == "mp_forwardbase_kodai" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_forwardbase_kodai" )
			break
		case 6:
			if( GetMapName() == "mp_grave" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_grave" )
			break
		case 7:
			if( GetMapName() == "mp_homestead" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_homestead" )
			break
		case 8:
			if( GetMapName() == "mp_thaw" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_thaw" )
			break
		case 9:
			if( GetMapName() == "mp_angel_city" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_angel_city" )
			break
		case 10:
			if( GetMapName() == "mp_colony02" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_colony02" )
			break
		case 11:
			if( GetMapName() == "mp_relic02" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_relic02" )
			break
		case 12:
			if( GetMapName() == "mp_wargames" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_wargames" )
			break
		case 13:
			if( GetMapName() == "mp_glitch" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_glitch" )
			break
		case 14:
			if( GetMapName() == "mp_rise" )
			{
				ReRandom()
				return
			}
			ServerCommand( "map mp_rise" )
			break
		default:
			break
	}
}