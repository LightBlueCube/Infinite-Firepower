untyped //entity.s need this
global function TitanChangePro_Callbacks
global function MacroCheck_Threaded


array<string> KickedPlayerUID = []

void function MacroCheck_Threaded( entity player )
{
	if( !IsValid( player ) )
		return
	if( !player.IsTitan() )
		return

	player.EndSignal( "MacroCheck" )
	table result = {}
	result.NotMacro <- false
	OnThreadEnd(
		function():( player, result )
		{
			if( !IsValid( player ) )
				return
			if( !result.NotMacro )
				thread IsMacro( player )
		}
	)
	WaitFrame()
	WaitFrame()
	result.NotMacro = true
}
void function IsMacro( entity player )
{
	if( "PlayerUseMacro" in player.s )
	{
		player.s.PlayerUseMacro += 1
		printt( "AntiCheats: PlayerUseMacro PlayerName:"+ player.GetPlayerName() +" PlayerUID: "+ player.GetUID() +" Times: "+ player.s.PlayerUseMacro +" EndMessage" )
		if( player.s.PlayerUseMacro == 6 )
		{
			for( int i = 300; i > 0; i-- )
			{
				WaitFrame()
				if( IsValid( player ) )
					SendHudMessage( player, "侦测到您多次使用宏进行弹射操作，我们不推荐也不建议这么做\n如果您依旧多次使用宏，可能会进行封号操作", -1, 0.4, 200, 200, 225, 0, 0.0, 0.0, 1);
			}
		}
		/*if( player.s.PlayerUseMacro == 6 )
		{
			printt( "AntiCheats: PlayerUseMacroAndLastWARN PlayerName:"+ player.GetPlayerName() +" PlayerUID: "+ player.GetUID() +" EndMessage" )
			for( int i = 600; i > 0; i-- )
			{
				WaitFrame()
				if( IsValid( player ) )
					SendHudMessage( player, "侦测到您依旧多次使用宏进行弹射操作，这是针对您的最后一次警告\n你已经被警告过了", -1, 0.4, 255, 0, 0, 0, 0.0, 0.0, 1);
			}
		}
		if( player.s.PlayerUseMacro > 6 )
		{
			if( !IsValid( player ) )
				return
			KickedPlayerUID.append( player.GetUID() )
			printt( "AntiCheats: PlayerUseMacroAndKicked PlayerName:"+ player.GetPlayerName() +" PlayerUID: "+ player.GetUID() +" EndMessage" )
			ServerCommand( "kickid "+ player.GetUID() )
		}*/
	}
	else
	{
		player.s.PlayerUseMacro <- 1
		printt( "AntiCheats: PlayerUseMacro PlayerName:"+ player.GetPlayerName() +" PlayerUID: "+ player.GetUID() +" EndMessage" )
	}
}


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

void function TitanChangePro_Callbacks()
{
	AddSpawnCallback( "npc_titan", OnTitanfall )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, OnWinnerDetermined )
	AddCallback_GameStateEnter( eGameState.Postmatch, GameStateEnter_Postmatch )
	AddCallback_OnPilotBecomesTitan( SetPlayerTitanTitle )
	AddCallback_OnPlayerRespawned( RestoreKillStreak )
	AddCallback_OnUpdateDerivedPlayerTitanLoadout( ApplyFDDerviedUpgrades )
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddCallback_OnNPCKilled( OnPlayerKilled )
	AddCallback_OnClientConnected( OnClientConnected )
	AddClientCommandCallback( "hw", NukeTitan );
	AddClientCommandCallback( "help1", simpelhelp );
	AddClientCommandCallback( "help2", simpelhelp2 );
	AddClientCommandCallback( "help3", simpelhelp3 );
	thread UseTimeCheck()
}

void function UseTimeCheck()
{
	while( true )
	{
		wait 10
		foreach( player in GetPlayerArray() )
		{
			if( !IsValid( player ) )
				continue
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
			if( player.GetModelName() == $"models/titans/medium/titan_medium_wraith.mdl" || player.GetModelName() == $"models/titans/medium/titan_medium_tone_prime.mdl" )	//强力
			{
				UseTime_5 += 10
			}
			if( player.GetModelName() == $"models/titans/heavy/titan_heavy_deadbolt.mdl" || player.GetModelName() == $"models/titans/heavy/titan_heavy_legion_prime.mdl" )	//军团
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
		}
	}
}

bool function simpelhelp( entity player, array<string> args )
{
	if( IsValid( player ) )
		SendHudMessage(player, "因为摆寄星EN把BroadCast写寄了所以我只能做个简单介绍\n控制台输入\"help2\"看第二页\n按住F可以扔电池\n有一代训牛，拔下电池后往电池仓打\n新泰坦可以通过以下涂装获得\n远征:边境帝王涂装\n野兽:至尊北极星\n野牛:至尊烈焰\n能核:至尊离子\n游侠:至尊浪人",  -1, 0.3, 200, 200, 225, 0, 0.15, 50, 1);
	return true
}

bool function simpelhelp2( entity player, array<string> args )
{
	if( IsValid( player ) )
		SendHudMessage(player, "控制台输入\"help3\"看第三页\n绿电池回血2格\n黄电池回血1格，不能从黄血拉出\n红电池回血0.5格，但是如果是黄血吃到那么拉出黄血且回血3格\n能核Q的作用是致盲敌方泰坦\n电池被拔过后除非友方铁驭补给否则再次被训牛敌方铁驭不需要拔电池就能掏枪射击",  -1, 0.3, 200, 200, 225, 0, 0.15, 50, 1);
	return	true
}

bool function simpelhelp3( entity player, array<string> args )
{
	if( IsValid( player ) )
		SendHudMessage(player, "能核的盾接到子弹会恢复能量\n每杀四个人就会获得一个核武泰坦，表现为召唤一个落地就核爆的泰坦，控制台输入hw查看详情\nNPC的刷新数量和伤害都有大幅提升\n帝王可以升到9级，顺序为先升三个一级升级然后三个二级再然后三个三级",  -1, 0.3, 200, 200, 225, 0, 0.15, 50, 1);
	return	true
}

void function GameStateEnter_Postmatch()
{
	thread RandomMap()
}
void function RandomMap()
{
	wait ( GAME_POSTMATCH_LENGTH - 0.1 )
	printt( "UseTimeCheck: "+ UseTime_1 +","+ UseTime_2 +","+ UseTime_3 +","+ UseTime_4 +","+ UseTime_5 +","+ UseTime_6 +","+ UseTime_7 +",|ModTitan|,"+ UseTime_ModTitan_1 +","+ UseTime_ModTitan_2 +","+ UseTime_ModTitan_3 +","+ UseTime_ModTitan_4 +","+ UseTime_ModTitan_5 )
	int RandomInt = RandomInt( 15 )
	switch( RandomInt )
	{
		case 0:
			ServerCommand( "map mp_black_water_canal" )
			break
		case 1:
			ServerCommand( "map mp_complex3" )
			break
		case 2:
			ServerCommand( "map mp_crashsite3" )
			break
		case 3:
			ServerCommand( "map mp_drydock" )
			break
		case 4:
			ServerCommand( "map mp_eden" )
			break
		case 5:
			ServerCommand( "map mp_forwardbase_kodai" )
			break
		case 6:
			ServerCommand( "map mp_grave" )
			break
		case 7:
			ServerCommand( "map mp_homestead" )
			break
		case 8:
			ServerCommand( "map mp_thaw" )
			break
		case 9:
			ServerCommand( "map mp_angel_city" )
			break
		case 10:
			ServerCommand( "map mp_colony02" )
			break
		case 11:
			ServerCommand( "map mp_relic02" )
			break
		case 12:
			ServerCommand( "map mp_wargames" )
			break
		case 13:
			ServerCommand( "map mp_glitch" )
			break
		case 14:
			ServerCommand( "map mp_rise" )
			break
		default:
			break
	}
}
void function OnWinnerDetermined()	//anti-crash
{
	foreach( player in GetPlayerArray() )
	{
		player.s.KillStreak <- 0
		player.s.totalKills <- 0
		player.s.HaveNuclearBomb <- false
	}
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if( IsValid( attacker ) )
	{
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
			if( !( attacker.IsPlayer() ) )
				return
			if( attacker.GetTeam() == victim.GetTeam() )
				return
			if( !( "KillStreak" in attacker.s ) )
				attacker.s.KillStreak <- 0
			if( !( "totalKills" in attacker.s ) )
				attacker.s.totalKills <- 0
			attacker.s.KillStreak += 1
			attacker.s.totalKills += 1
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
					SendHudMessage( attacker, "获得 2 个核武泰坦\n剩余 "+ attacker.s.HaveNukeTitan +" 个核武泰坦未交付",  -1, 0.3, 255, 0, 0, 255, 0.15, 2, 1);
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
					SendHudMessage( attacker, "获得 1 个核武泰坦\n剩余 "+ attacker.s.HaveNukeTitan +" 个核武泰坦未交付",  -1, 0.3, 255, 0, 0, 255, 0.15, 3, 1);
				}
			}
			if( attacker.s.KillStreak == 30 )
			{
				attacker.s.HaveNuclearBomb <- true	//给核弹，给监听用
				SendHudMessage( attacker, "////////////////Ahpla核弹已就绪，长按\"近战\"键（默认为\"F\"）以启用////////////////",  -1, 0.4, 255, 0, 0, 255, 0.15, 30, 1);
			}
		}
	}
}

void function OnClientConnected( entity player )
{
	player.s.KillStreak <- 0
	player.s.totalKills <- 0
	AddPlayerHeldButtonEventCallback( player, IN_MELEE, StartNuke, 1 )
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
			SendHudMessage( player, "当前拥有 "+ player.s.HaveNukeTitan +" 个核武泰坦\n控制台输入\"hw 数量\"以交付核武泰坦\n控制台输入\"hw all\"以交付全部核武泰坦", -1, 0.3, 255, 0, 0, 255, 0.15, 3, 1);
			return
		}
		else
		{
			SendHudMessage( player, "当前拥有 0 个核武泰坦\n控制台输入\"hw 数量\"以交付核武泰坦\n控制台输入\"hw all\"以交付全部核武泰坦", -1, 0.3, 255, 0, 0, 255, 0.15, 3, 1);
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
					SendHudMessage( player, "你没有核武泰坦!", -1, 0.4, 255, 0, 0, 255, 0.15, 2, 1);
					return
				}
				if( player.IsTitan() )
				{
					SendHudMessage(player, "你需要先离开泰坦才能交付核武泰坦", -1, 0.4, 255, 0, 0, 255, 0.15, 2, 1);
					return
				}
				if( !player.IsHuman() )
				{
					SendHudMessage(player, "你需要处于铁驭状态才能交付核武泰坦", -1, 0.4, 255, 0, 0, 255, 0.15, 2, 1);
					return
				}
				SendHudMessage( player, "成功交付了 "+ player.s.HaveNukeTitan +" 个核武泰坦", -1, 0.4, 255, 0, 0, 255, 0.15, 2, 1);
				for( var i = player.s.HaveNukeTitan; i > 0; i -= 1)
				{
					PlayerInventory_PushInventoryItemByBurnRef( player, "burnmeter_nuke_titan" )
				}
				player.s.HaveNukeTitan = 0
			}
			else
				SendHudMessage( player, "你没有核武泰坦!", -1, 0.4, 255, 0, 0, 255, 0.15, 2, 1);
			return
		}
		else
			i = args[0].tointeger()
		if( i <= 0 )
		{
			SendHudMessage( player, "填入了非法参数", -1, 0.4, 255, 0, 0, 255, 0.15, 2, 1);
			return
		}
		if( "HaveNukeTitan" in player.s )
		{
			if( player.s.HaveNukeTitan <= 0 )
			{
				SendHudMessage( player, "你没有核武泰坦!", -1, 0.4, 255, 0, 0, 255, 0.15, 2, 1);
				return
			}
			if( i > player.s.HaveNukeTitan )
			{
				SendHudMessage( player, "你只有 "+ player.s.HaveNukeTitan +" 个核武泰坦\n但你填入的值 "+ i +" 明显大于你所拥有的值", -1, 0.4, 255, 0, 0, 255, 0.15, 3, 1);
				return
			}
			if( player.IsTitan() )
			{
				SendHudMessage(player, "你需要先离开泰坦才能交付核武泰坦", -1, 0.4, 255, 0, 0, 255, 0.15, 2, 1);
				return
			}
			if( !player.IsHuman() )
			{
				SendHudMessage(player, "你需要处于铁驭状态才能交付核武泰坦", -1, 0.4, 255, 0, 0, 255, 0.15, 2, 1);
				return
			}
			player.s.HaveNukeTitan -= i
			SendHudMessage( player, "成功交付了 "+ i +" 个核武泰坦\n剩余 "+ player.s.HaveNukeTitan +" 个核武泰坦未交付", -1, 0.4, 255, 0, 0, 255, 0.15, 3, 1);
			while( i > 0 )
			{
				PlayerInventory_PushInventoryItemByBurnRef( player, "burnmeter_nuke_titan" )
				i -= 1
			}
		}
		else
			SendHudMessage( player, "你没有核武泰坦!", -1, 0.4, 255, 0, 0, 255, 0.15, 2, 1);
		return
	}
}

void function StartNuke( entity player )
{
	if( IsValid( player ) )
	{
		if( player.IsHuman() && IsAlive( player ) )
		{
			if( PlayerHasMaxBatteryCount( player ) )
			{
				if( GetBatteryOnBack( player ).GetSkin() == 1 )
					return

				entity battery = Rodeo_TakeBatteryAwayFromPilot( player )
				vector viewVector = player.GetViewVector()
				vector playerVel = player.GetVelocity()
				vector batteryVel = playerVel + viewVector * 200 + < 0, 0, 100 >
				battery.SetVelocity( batteryVel )

				SendHudMessage(player, "您已丢出电池", -1, 0.4, 200, 200, 225, 0, 0.15, 2, 1);
			}
		}
		else
		{
			if( !IsAlive( player ) )
				SendHudMessage(player, "你需要处于存活状态才可丢出电池", -1, 0.4, 200, 200, 225, 0, 0.15, 2, 1);
			if( !player.IsHuman() )
				SendHudMessage(player, "你需要处于铁驭状态才可丢出电池", -1, 0.4, 200, 200, 225, 0, 0.15, 2, 1);
		}
	}
	if( "HaveNuclearBomb" in player.s )
	{
		if( player.s.HaveNuclearBomb == true )
		{
			wait 2
			int sec = 40
			while( sec > 0 )
			{
				if( IsValid( player ) )
					SendHudMessage(player, "////////////////正在启动Alpha核弹！启动倒计时"+float(sec) / 10+"sec////////////////",  -1, 0.4, 255, 0, 0, 0, 0, 0.2, 0);
				sec = sec - 1
				wait 0.1
			}
			if( player.s.HaveNuclearBomb == false )
				return
			foreach( arrayPlayer in GetPlayerArray() )
			{
				arrayPlayer.s.KillStreak <- 0
				arrayPlayer.s.totalKills <- 0
				arrayPlayer.s.HaveNuclearBomb <- false
			}
			thread StartNukeWARN( player )
		}
	}
}

void function StartNukeWARN( entity owner )
{
	int sec = 200
	bool HasWARN = false
	SetServerVar( "gameEndTime", Time() + 60.0 )
	while( sec > 0 )
	{
		if( sec == 20 )
		{
			foreach( player in GetPlayerArray() )
			{
				thread explodeSound( player )
			}
		}
		if( sec <= 100 )
		{
			if( HasWARN == true )
			{
				HasWARN = false
			}
			else
			{
				foreach ( player in GetPlayerArray() )
				{
					if( IsValid( player ) )
					{
						thread playerWARN( player, owner, sec, true )
					}
				}
				HasWARN = true
			}

		}
		else
		{
			foreach ( player in GetPlayerArray() )
			{
				if( IsValid( player ) )
				{
					thread playerWARN( player, owner, sec )
				}
			}
		}
		sec = sec - 2
		wait 0.2
	}
	foreach ( player in GetPlayerArray() )
	{
		if( IsValid( player ) )
		{
			StopSoundOnEntity( player, "titan_cockpit_missile_close_warning" )
			thread explode( player, owner )
		}
	}
	foreach ( entity npc in GetNPCArray() )
	{
		if ( !IsValid( npc ) || !IsAlive( npc ) )
			continue
		// kill rather than destroy, as destroying will cause issues with children which is an issue especially for dropships and titans
		npc.Die( svGlobal.worldspawn, svGlobal.worldspawn, { damageSourceId = eDamageSourceId.round_end } )
	}
	wait 3
	while( true )
	{
		wait 1
		foreach( player in GetPlayerArray() )
		{
			if( IsValid( player ) )
				if( IsAlive( player ) )
					player.Die()
		}
	}
}

void function playerWARN( entity player, entity owner, int sec, bool Is10sec = false )
{
	if( Is10sec == false )
	{
		if( IsValid( player ) )
			SendHudMessage( player, "玩家 \""+owner.GetPlayerName()+"\" 手动启用了Alpha核弹引爆程序\n////////地表所有设施和生命体都将在T- "+ float( sec ) / 10 +"秒后被彻底抹除////////",  -1, 0.3, 255, 0, 0, 0, 0, 0.2, 0);
	}
	else
	{
		if( IsValid( player ) )
		{
			SendHudMessage( player, "//////////////////////////////// WARNING ////////////////////////////////\n玩家 \""+owner.GetPlayerName()+"\" 手动启用了Alpha核弹引爆程序\n////////地表所有设施和生命体都将在T- "+ float( sec ) / 10 +"秒后被彻底抹除////////\n//////////////////////////////// WARNING ////////////////////////////////",  -1, 0.27, 255, 0, 0, 0, 0, 0.2, 0);
		}
		wait 0.1
		if( IsValid( player ) )
			SendHudMessage( player, "//////////////////////////////// WARNING ////////////////////////////////\n玩家 \""+owner.GetPlayerName()+"\" 手动启用了Alpha核弹引爆程序\n////////地表所有设施和生命体都将在T- "+ float( sec - 1) / 10 +"秒后被彻底抹除////////\n//////////////////////////////// WARNING ////////////////////////////////",  -1, 0.27, 255, 0, 0, 0, 0, 0.2, 0);
	}
	if( IsValid( player ) )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, "titan_cockpit_missile_close_warning" )
	}
	wait 0.1
	if( Is10sec == true )
	{
		if( IsValid( player ) )
			SendHudMessage( player, "玩家 \""+owner.GetPlayerName()+"\" 手动启用了Alpha核弹引爆程序\n////////地表所有设施和生命体都将在T- "+ float( sec - 2 ) / 10 +"秒后被彻底抹除////////",  -1, 0.3, 255, 0, 0, 0, 0, 0.2, 0);
		wait 0.1
		if( IsValid( player ) )
		{
			EmitSoundOnEntityOnlyToPlayer( player, player, "titan_cockpit_missile_close_warning" )
			SendHudMessage( player, "玩家 \""+owner.GetPlayerName()+"\" 手动启用了Alpha核弹引爆程序\n////////地表所有设施和生命体都将在T- "+ float( sec - 3 ) / 10 +"秒后被彻底抹除////////",  -1, 0.3, 255, 0, 0, 0, 0, 0.2, 0);
		}
	}
	else if( IsValid( player ) )
		SendHudMessage( player, "玩家 \""+owner.GetPlayerName()+"\" 手动启用了Alpha核弹引爆程序\n////////地表所有设施和生命体都将在T- "+ float( sec - 1 ) / 10 +"秒后被彻底抹除////////",  -1, 0.3, 255, 0, 0, 0, 0, 0.2, 0);
}

void function explode( entity player, entity owner )
{
	if( IsValid( player ) )
	{
		for (int value = 4; value > 0; value = value - 1)
		{
			EmitSoundOnEntityOnlyToPlayer( player, player, "goblin_dropship_explode" )
			Remote_CallFunction_Replay( player, "ServerCallback_ScreenShake", 400, 200, 10 )
		}
		thread FakeShellShock_Threaded( player, 10 )
		StatusEffect_AddTimed( player, eStatusEffect.turn_slow, 0.4, 10, 0.5 )
		ScreenFadeToColor( player, 192, 192, 192, 64, 0.1, 3  )
		SetWinner( owner.GetTeam() )
	}
	wait 1.7
	if( IsValid( player ) )
	{
		StopSoundOnEntity( player, "goblin_dropship_explode" )
		StopSoundOnEntity( player, "pilot_geigercounter_warning_lv3" )
	}
	wait 0.1
	if( IsValid( player ) )
	{
		if( IsAlive( player ) )
			player.Die()
		player.FreezeControlsOnServer()
		for (int value = 2; value > 0; value = value - 1)
		{
			EmitSoundOnEntityOnlyToPlayer( player, player, "titan_death_explode" )
			EmitSoundOnEntityOnlyToPlayer( player, player, "skyway_scripted_titanhill_mortar_explode" )
			EmitSoundOnEntityOnlyToPlayer( player, player, "bt_beacon_controlroom_dish_explosion" )
		}
	}
	wait 0.2
	if( IsValid( player ) )
	{
		ScreenFadeToColor( player, 192, 192, 192, 255, 0.1, 4  )
	}
	wait 2
	SetGameState( eGameState.Postmatch )
}

void function explodeSound( entity player )
{
	for (int value = 20; value > 0; value = value - 1)
	{
		if( IsValid( player ) )
			EmitSoundOnEntityOnlyToPlayer( player, player, "pilot_geigercounter_warning_lv3" )
		wait 0.1
	}
}

void function RestoreKillStreak( entity player )
{
	player.s.KillStreak <- 0	//重置玩家的一命击杀数
	if( KickedPlayerUID.contains( player.GetUID() ) )	//踢掉被踢后想重进的宏孩儿
		ServerCommand( "kickid "+ player.GetUID() )
	if( "HaveNuclearBomb" in player.s )
		if( player.s.HaveNuclearBomb == true )
			SendHudMessage( player, "////////////////Ahpla核弹已就绪，长按\"近战\"键（默认为\"F\"）以启用////////////////",  -1, 0.4, 255, 0, 0, 255, 0.15, 8, 1);
}

void function SetPlayerTitanTitle( entity player, entity titan )
{
	entity soul = player.GetTitanSoul()
	if( IsValid( soul ) )
		if( "titanTitle" in soul.s )
			if( soul.s.titanTitle != "" )
				player.SetTitle( soul.s.titanTitle )	//设置玩家的小血条上的标题（也就是你瞄准敌人时，顶上会显示泰坦名，玩家名，血量剩余的一个玩意，这里我们改的是泰坦名）
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
		SendHudMessage(player, "已启用野兽泰坦装备，取消至尊泰坦以使用原版北极星",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "野獸"	//众所周知，当玩家上泰坦时不会按照我们的意愿设置标题的，所以这边整个变量让玩家上泰坦时读取这个然后写上
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
        titan.GiveWeapon( "mp_titanweapon_rocketeer_rocketstream" )
	  	titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL,["slow_recovery_vortex","sp_wider_return_spread"] )
		titan.GiveOffhandWeapon( "mp_titanability_hover", OFFHAND_TITAN_CENTER )
        titan.GiveOffhandWeapon( "mp_titanweapon_shoulder_rockets", OFFHAND_ORDNANCE,["tcp"] )
		titan.GiveOffhandWeapon( "mp_titancore_flight_core", OFFHAND_EQUIPMENT )

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
		SendHudMessage(player, "已启用远征装备， 取消\"边境帝王\"战绘以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "遠征"
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
        titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveWeapon( "mp_titanweapon_xo16_shorty" )
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield", OFFHAND_SPECIAL,["slow_recovery_vortex","sp_wider_return_spread"] )
		titan.GiveOffhandWeapon( "mp_titanability_smoke", OFFHAND_TITAN_CENTER )
		titan.GiveOffhandWeapon( "mp_titanweapon_shoulder_rockets", OFFHAND_ORDNANCE,["tcp"] )
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
		SendHudMessage(player, "已启用野牛泰坦装备，取消至尊泰坦以使用原版烈焰",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "野牛"
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
		titan.GiveOffhandWeapon( "mp_ability_cloak", OFFHAND_SPECIAL )
		titan.GiveOffhandWeapon( "mp_titanability_sonar_pulse", OFFHAND_TITAN_CENTER, ["tcp"] )
		titan.GiveOffhandWeapon( "mp_ability_heal", OFFHAND_ORDNANCE, ["bc_super_stim", "tcp"] )
		titan.GiveOffhandWeapon( "mp_titancore_flame_wave", OFFHAND_EQUIPMENT, ["ground_slam"] )
		titan.GiveOffhandWeapon( "melee_titan_punch_fighter", OFFHAND_MELEE, ["berserker", "allow_as_primary"] )
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
		SendHudMessage(player, "已启用执政官泰坦装备，取消至尊泰坦以使用原版离子",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "執政官"
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
		titan.GiveWeapon( "mp_titanweapon_particle_accelerator", ["tcp"] )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveOffhandWeapon( "mp_titanweapon_vortex_shield_ion", OFFHAND_SPECIAL, ["tcp_vortex"] )
		titan.GiveOffhandWeapon( "mp_titanability_sonar_pulse", OFFHAND_TITAN_CENTER,["tcp_fast_emp"] )
		titan.GiveOffhandWeapon( "mp_titanweapon_stun_laser", OFFHAND_ORDNANCE, ["tcp_flash","energy_field_energy_transfer"] )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT, ["tcp_dash_core"] )	//shield_core"] )

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
		SendHudMessage(player, "已启用游侠泰坦装备，取消至尊泰坦以使用原版浪人",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "游俠"
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
		titan.GiveWeapon( "mp_titanweapon_triplethreat" )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveOffhandWeapon( "mp_ability_swordblock", OFFHAND_SPECIAL )
		titan.GiveOffhandWeapon( "mp_titanability_smoke", OFFHAND_TITAN_CENTER, [ "tcp_emp" ])
		titan.GiveOffhandWeapon( "mp_titanweapon_homing_rockets", OFFHAND_ORDNANCE )
		//titan.GiveOffhandWeapon( "mp_titancore_laser_cannon", OFFHAND_EQUIPMENT, [ "tesla_core" ] )
		titan.GiveOffhandWeapon( "mp_titancore_shift_core", OFFHAND_EQUIPMENT, [ "tcp_arc_wave" ] )

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
	/*else if( titan.GetModelName() == $"models/titans/medium/titan_medium_tone_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "已启用天图泰坦装备，取消至尊泰坦以使用原版强力",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "天圖"
		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
		titan.GiveWeapon( "mp_titanweapon_sniper", [ "arc_cannon", "capacitor", "arc_cannon_charge_sound", "power_shot" ] )
		titan.GetMainWeapons()[0].SetWeaponPrimaryClipCount( 0 )
		titan.GetMainWeapons()[0].SetWeaponPrimaryAmmoCount( 0 )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		//titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )

		array<int> passives = [ ePassives.PAS_TONE_WEAPON,
								ePassives.PAS_TONE_ROCKETS,
								ePassives.PAS_TONE_SONAR,
								ePassives.PAS_TONE_WALL,
								ePassives.PAS_TONE_BURST ]
		foreach( passive in passives )
		{
			TakePassive( soul, passive )
		}
	}*/


	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && ( titan.GetCamo() != -1 || titan.GetSkin() != 3 ) )	//帝王
	{
		soul.s.TitanHasBeenChange <- true

		array<int> passives = [ ePassives.PAS_VANGUARD_CORE1,
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
}



//////////////////////////////////
////	从其他地方借来的函数	////
//////////////////////////////////

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