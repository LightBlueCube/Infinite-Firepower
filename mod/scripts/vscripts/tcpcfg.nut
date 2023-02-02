untyped //entity.s need this
global function TitanChangePro_Callbacks
global function MacroCheck_Threaded

const array<string> docs =    [ "前言\n因为Emma稳定发挥，broadcast chathook 还有logsystem都是被整寄了\n所以现版本几乎没有什么能发送大量文字的方法\n所以想了这个分页法，所以阅读体验会比较差，因为一次只能显示不几行\n任何更新都会同步更新文档，常来看看！",
								"特别鸣谢（名字按首字母顺序排列）\n[cmggy]\n[D3-3109]\n[DZ]\n[Pan-da32767]\n[VoyageDB]\n[wolf109909]\n[zxcPandora]",
								"--------------------------------",
								"\n",
								"----无限火力都改了什么？----",
								"泰坦获取速度 * 4，泰坦核心获取速度 * 2，泰坦脱战回盾",
								"ai伤害取默认[注释2]，视力取战役ai，瞄准精度为最大，取消开火限制",
								"[注释2]:原版ai伤害大概为默认的四分之一",
								"增加步枪兵和幽灵战士还有潜行者能用的武器，分别为：火箭发射器，电能步枪，磁能手榴弹",
								"死神会投掷炸蛛，阵亡时会核爆（无视黄血和护盾）",
								"所有泰坦都拥有边境血量（仅血量，其余不动，表现为血量 + 2500（一格））",
								"一代训牛术[注释3]（伤害取damage_near_value_titanarmor * 16[注释4]），如果被训牛泰坦为黄血，则伤害减半",
								"[注释3]:一代训牛部分由[DB][VoyageDB]大佬修复并完善",
								"[注释4]:小部分武器的伤害数值做了单独平衡，平均ttk约为2s左右",
								"训牛拔电池时不会打断隐身效果，训牛拔电池伤害无论如何都优先扣除盾的血量，也就是说现在黄血被拔电池只要有点盾就死不了",
								"绿电池回血2格 + 满盾，核心恢复80%",
								"黄电池回血1格 + 满盾（黄电池无法将泰坦从毁减状态拉出），核心恢复40%",
								"应急电池强化使用后有 2 / 3 的概率给黄电池  1 / 3 的概率给绿电池",
								"每当玩家击杀4人（包括NPC泰坦）或一命击杀4人（包括NPC泰坦）时，都会获得一个核武泰坦\n表现为召唤一个落地就开始核爆的核武泰坦，控制台输入hw以查看详情（先关闭文档再输入）",
								"按住F可以扔出电池，仅在处于铁驭状态且存活且有电池时工作",
								"撤离阶段可以复活，撤离艇血量 27000（10格 + 2000） -> 60000（24格）",
								"队伍比分会一直隐藏到最后一分十秒，在最后一分钟会开启十倍分数获取，冲冲冲！",
								"----一代训牛术的逻辑----",
								"当泰坦落地时，默认电池仓内有电池",
								"当电池被拔出时，电池仓内无电池",
								"当队友给友方泰坦一个电池时，电池仓内有电池",
								"--------",
								"当铁驭训牛敌方泰坦时，如果电池仓内有电池，拔出电池后立刻掏枪[注释5]",
								"[注释5]:如果此时铁驭身上已有电池，那么新拔出的电池将会掉落至地上",
								"当铁驭训牛敌方泰坦时，如果电池仓内无电池，立刻掏枪",
								"当泰坦死亡且电池仓内有电池时 90%掉落黄电池 10%掉落绿电池",
								"----亿些平衡性修改----",
								"当玩家训牛中途跳机时，获得的离机速度增加[注释6]",
								"[注释6]:获得一个方向为视角正后方的一个大小为400的没有高度速度的速度\n + 一个方向为跳离时按住的方向键的方向的一个大小为200的速度（如果跳离时没按则不给这个速度） + 一个方向为固定朝上的一个大小为400的速度",
								"泰坦电烟最大持有量 4 -> 8  对非装甲单位dps 45 -> 40",
								"MK5智障手枪对非装甲单位伤害 40 -> 20  射击模式 semi -> auto",
								"军团智障核心开启期间，对装甲单位造成的伤害 * 1.2，仅锁定装甲单位",
								"强力弹群核心对装甲单位伤害 140 -> 100  溅射对装甲单位伤害 140 -> 100",
								"帝王装备\"能量盗取\"处决获得的电池只加1格血 + 满盾",
								"帝王可以一直升级到9级，升级顺序为从3个一级升级到3个二级升级再到3个三级升级",
								"帝王涡旋升级电烟对装甲单位dps 1350 -> 850",
								"帝王没有神盾血量升级，血量为10000（4格），如果升级了高级崽种那么血量为15000（6格）",
								"浪人剑核心持续时间 12 -> 6",
								"浪人剑封减伤 70% -> 50%  核心期间剑封减伤 85% -> 70%",
								"离子镭射核心所有伤害 325 -> 300  持续时间 4.5 -> 5.0",
								"火焰核心对装甲单位伤害 4500 -> 3500  对非装甲单位伤害 300 -> 200",
								"----新的泰坦！----",
								"所有新泰坦均不支持任何自定配件，但支持自定被动",
								"注：标有SP_开头的武器代表所有数值均取用战役版本",
								"--远征--",
								"启用：帝王，携带\"帝王边境\"皮肤",
								"血量：10000（4格）",
								"左栏位：SP_涡旋防护罩",
								"中栏位：SP_电子烟幕",
								"右栏位：多目标飞弹[注释7]",
								"[注释7]:表现为战役里的多目标飞弹，除了不能锁非装甲单位外其余均与战役保持一致",
								"主武器：SP_XO16",
								"核心：SP_爆发核心",
								"--野兽--",
								"启用：北极星，携带至尊涂装",
								"血量：10000（4格）",
								"左栏位：SP_涡旋防护罩",
								"中栏位：SP_悬浮",
								"右栏位：多目标飞弹[注释7]",
								"主武器：SP_四段火箭",
								"核心：SP_飞行核心",
								"其他：野兽拥有北极星装备\"毒蛇推进器\"",
								"--野牛--",
								"启用：烈焰，携带至尊涂装",
								"血量：15000（6格）",
								"左栏位：隐身",
								"中栏位：EMP陷阱[注释8]",
								"[注释8]:表现为强力的声纳突波，效果为电弧场，落地后，等待1秒，开启5秒，伤害类型为EMP手雷，对装甲单位伤害为15 * 8，对非装甲单位伤害为1 * 8\n当单位进入伤害范围内时，每0.1秒获得一次上述伤害，且离开该范围前将一直拥有被EMP手雷击中的屏幕特效和减速等效果",
								"右栏位：激素（恢复速度 * 2，使用时间 * 2）",
								"近战栏位：melee_titan_punch_fighter[注释9]",
								"[注释9]:废稿武器，伤害改为1750每拳，范围为300，可按左键或F攻击",
								"主武器：NULL（空）",
								"核心：GroundSlam[注释10]",
								"[注释10]:DB大佬制作的核心，对非装甲单位伤害为500，对装甲单位伤害为3500，无衰减伤害范围 0-450  有衰减伤害范围 450-525  超过范围525外则无伤害\n启动后立刻恢复激素的冷却，后提供一个根据视角朝向的大小为1200速度 + 高度轴的一个大小为-750的速度，执行烈焰的拍地动作",
								"其他：野牛不会被卡拳，同样的，野牛也无法卡别人拳",
								"--执政官--",
								"启用：离子，携带至尊涂装",
								"血量：10000（4格）",
								"左栏位：自充能涡旋防护罩[注释11]",
								"[注释11]:涡旋盾消耗速度为原版的两倍，至少需要剩余的能量 >= 100 才可以开启，当武器击中涡旋盾时，增加能量\n计算公式为 近距离对装甲单位伤害 / 1250 = 要增加的百分比 如果要增加的百分比 <= 10% 那么用该计算公式: near_val / 625 = 要增加的百分比",
								"中栏位：EMP炸弹[注释12]",
								"[注释12]:表现为强力的声纳突波，效果为电弧场，启动后消耗 当前能量 / 2，落地后，开启0.5秒，伤害类型为EMP手雷\n对装甲单位伤害为 5 * 8，对非装甲单位伤害为 1 * 8，当单位进入伤害范围内时\n每0.1秒获得一次上述伤害，且离开该范围前将一直拥有被EMP手雷击中的屏幕特效和减速等效果",
								"右栏位：EMP射线[注释13]",
								"[注释13]:表现为帝王的满级能量汲取，启动后消耗 当前能量 / 2，冷却时间为 原版冷却时间 * 2\n击中敌方泰坦后，敌方泰坦获得一个2秒的致盲 + 正常能量汲取伤害，击中不给使用者加盾，击中队友不给队友加盾",
								"主武器：核裂枪[注释14]",
								"[注释14]:表现为离子的分裂枪，伤害为 原版分裂枪伤害 * 2 （对非装甲单位伤害 近距离 50 远距离 40  对装甲单位伤害 近距离 160 远距离 120）\n非瞄准射击一发，消耗30能量，瞄准射击三发，消耗90能量，如果能量耗光，非瞄准每射击一次将消耗2发弹药，瞄准每射击一次将消耗6发弹药",
								"核心：雷暴[注释15]",
								"[注释15]:表现为开启后，朝视角前方释放五道（0°,±10°,±40°）电弧波，单道伤害为1250，可以被任何盾挡住且不会扣除盾的血量或耐久",
								"其他：消耗能量后需等待2.0秒后才会开始自行恢复（0.5 -> 3.0）",
								"--游侠--",
								"启用：浪人，携带至尊涂装",
								"血量：7500（3格）",
								"左栏位：剑封[注释15]",
								"[注释15]:表现为浪人的剑封，减伤50%，有一个充能条，剑封时会消耗，消耗速度为10秒，在消耗殆尽之前会一直拥有1.5倍移速加成\n消耗殆尽后移速为 正常移速 * 0.4，冷却2.5秒后才会开始恢复充能，恢复速度为8秒",
								"中栏位：电弧场[注释16]",
								"[注释16]:表现为按下后，在泰坦上形成一个电弧场，持续16秒，伤害类型为EMP风暴\n对装甲单位伤害为 64，对非装甲单位伤害为 10，当单位进入伤害范围内时，每0.1秒获得一次上述伤害",
								"右栏位：同步彈頭[注释17]",
								"[注释17]:針對單一目標發射歸航導彈，這個泰坦重火力武器必須先鎖定才能發射。發射時將一次發射三枚歸航導彈朝鎖定目標前進。",
								"近战栏位：浪人剑",
								"主武器：三連環榴彈[注释18]",
								"[注释18]:三連環榴彈是同時發射三枚手榴彈的榴彈發射器。特別適用於淨空建築內部，而且榴彈一接觸裝甲即會爆炸，因此近距離對付其他泰坦非常有效。",
								"核心：衝刺核心[注释19]",
								"[注释19]:啟用時衝刺不會耗盡。",
								"--天图--",
								"启用：强力，携带至尊涂装",
								"血量：10000（4格）",
								"左栏位：泡泡护盾[注释20]",
								"[注释20]:表现为强力的声纳突波，发射后在落点生成一个无伤害且自身无敌的泡泡护盾，持续8秒",
								"中栏位：幻影[注释21]",
								"[注释21]:表现为幻影铁驭，使用后表现为生成一个和你一模一样的泰坦幻影，抬头显示的假血量取当前血量，如果黄血则血量取 当前 * 4\n冷却时间为20秒，满充能可使用2次，不可以在仅往左移动或仅往右移动时使用",
								"右栏位：绊雷[注释22]",
								"[注释22]:表现为火箭弹群，发射3个黏性绊雷，落地后存在30秒，如果敌方单位靠近则立刻爆炸\n伤害为 对非装甲单位 500 对装甲单位 1000，无衰减范围 0-140 衰减范围 140-320 范围超过320无伤害",
								"主武器：40cm机炮[注释24]",
								"[注释24]:伤害为 对非装甲单位 200 对装甲单位 600 溅射对非装甲单位 90 溅射对装甲单位 400，无衰减范围 0-100 衰减范围 100-225 范围超过225无伤害\n射速为1.5/s，弹匣容量为10发，核心期间全自动，射速为2/s",
								"核心：破壞核心[注释25]",
								"[注释25]:啟用時大幅提升武器殺傷力。（核心期间造成的所有伤害都是1.5倍）",
								"--巨妖--",
								"启用：军团，携带至尊涂装",
								"血量：12500（5格）",
								"左栏位：穹顶护盾[注释26]",
								"[注释26]:DB大佬制作的护盾，血量为3000，持续8秒，冲刺会打破护盾，在使用期间泰坦免疫一切伤害（伤害将转移到护盾），护盾会吃到近战伤害",
								"中栏位：投掷型电子烟幕[注释27]",
								"[注释27]:表现为强力的声纳突波，在落点生成一个涡旋电子烟幕，对泰坦dps 1000  对铁驭dps 30",
								"右栏位：球状闪电[注释28]",
								"[注释28]:表现为帝王的能量汲取，冷却时间为20秒（12 -> 20），拥有两种击发模式，当按住不到1秒就松开时为射线模式，当按住超过1秒时为电球模式",
								"当射线模式时：发射一道能量汲取，消耗三分之一的武器充能，击中目标时对目标造成 对装甲单位伤害 200 对非装甲单位伤害 20 并自己回盾1000点",
								"当电球模式时：发射一个速度较慢的电球（速度为200），消耗全部武器充能\n在该范围大小为500的范围内会持续收到被电球击中的减益 + EMP减益和每0.1秒的 对装甲单位伤害 50 对非装甲单位伤害 8",
								"每当且仅当对敌方装甲单位造成一次伤害时都会恢复自己护盾100点，如果护盾已满则恢复50点生命值\n当击中目标时对目标造成 对装甲单位伤害 200 对非装甲单位伤害 20",
								"主武器：XO16[注释29]",
								"[注释29]:表现为加装了加速器的远征XO16，最大射速为20，达到最大射速需5秒，伤害为 对非装甲单位 近距离 49 远距离 34  对装甲单位 近距离 100 远距离 80\n换弹速度和一代XO16保持一致(4.6s)，弹容60发，瞄准射击扩散不会减小，在核心开启前如果击中涡旋盾则每发会消耗涡旋盾充能的1%",
								"核心开启后不可换弹，打光子弹即视为核心结束，会重置武器状态致核心前，在核心开启期间如果击中涡旋盾则每发会消耗涡旋盾充能的4%",
								"核心：弹容超载[注释30]",
								"[注释30]:开启后立刻给主武器增加150发子弹，且仅给主武器增加150发子弹，无任何额外效果，可叠加子弹",
								"想必你一定看完了吧，谢谢你，我尊重每一个有耐心看完文档的人，而不是那种有现成文档不看只会嗯问的人\n实际上，开这个模式四个月以来，遇到的这种人数不胜数，保守估计都得三位数了，总之，还是谢谢你耐心的看完了文档" ]


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
		printt( "AntiCheats: PlayerName:"+ player.GetPlayerName() +" PlayerUID: "+ player.GetUID() +" Times: "+ player.s.PlayerUseMacro +" EndMessage" )
		if( player.s.PlayerUseMacro == 4 )
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
		printt( "AntiCheats: PlayerName:"+ player.GetPlayerName() +" PlayerUID: "+ player.GetUID() +" EndMessage" )
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
	RegisterSignal( "NukeStart" )
	RegisterSignal( "StartReadingDocs" )

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
	AddClientCommandCallback( "docs", ClientCommand_docs );
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

bool function ClientCommand_docs( entity player, array<string> args )
{
	thread docsSystem( player )
	return true
}
void function docsSystem( entity player )
{
	player.Signal( "StartReadingDocs" )
	player.EndSignal( "StartReadingDocs" )
	bool ShouldWait = false
	bool QuickWait = false
	while( true )
	{
		if( ShouldWait && !QuickWait )
			wait 0.3
		else
			WaitFrame()
		if( !IsValid( player ) )
			return
		if( player.IsInputCommandHeld( IN_BACK ) )
			return
		if( !( "docsPage" in player.s ) )
			player.s.docsPage <- 0
		ScreenFadeFromColor( player, 0, 0, 0, 255, 1, 0.5  )
		if( IsValid( player ) )
			if( IsAlive( player ) )
				player.Die()
		if( player.IsInputCommandHeld( IN_MOVELEFT ) )
		{
			if( player.s.docsPage <= 0 )
				player.s.docsPage <- docs.len()
			player.s.docsPage -= 1
			if( ShouldWait )
				QuickWait = true
			ShouldWait = true
			Moved( player )
		}
		else if( player.IsInputCommandHeld( IN_MOVERIGHT ) )
		{
			player.s.docsPage += 1
			if( player.s.docsPage >= docs.len() )
				player.s.docsPage <- 0
			if( ShouldWait )
				QuickWait = true
			ShouldWait = true
			Moved( player )
		}
		else
		{
			ShouldWait = false
			QuickWait = false
		}
		int docsPage = expect int( player.s.docsPage )
		int realDocsPage = docsPage + 1
		if( docsPage + 1 < docs.len() )
		{
			if( docsPage + 2 < docs.len() )
			{
				if( docs[ docsPage ].len() + docs[ docsPage + 1 ].len() + docs[ docsPage + 2 ].len() <= 300 )
				{
					SendHudMessage( player, docs[ docsPage ] +"\n"+ docs[ docsPage + 1 ] +"\n"+ docs[ docsPage + 2 ] +"\n左右移动翻页 向后移动退出\n< "+ realDocsPage +"/"+ docs.len() +" >", -1, 0.4, 200, 200, 225, 0, 0, 1.1, 1 )
					continue
				}
			}
			if( docs[ docsPage ].len() + docs[ docsPage + 1 ].len() <= 300 )
			{
				SendHudMessage( player, docs[ docsPage ] +"\n"+ docs[ docsPage + 1 ] +"\n\n左右移动翻页 向后移动退出\n< "+ realDocsPage +"/"+ docs.len() +" >", -1, 0.4, 200, 200, 225, 0, 0, 0.5, 1 )
				continue
			}
		}
		SendHudMessage( player, "\n"+ docs[ docsPage ] +"\n\n左右移动翻页 向后移动退出\n< "+ realDocsPage +"/"+ docs.len() +" >", -1, 0.4, 200, 200, 225, 0, 0, 0.5, 1 )
	}
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
					PlayerInventory_GiveNukeTitan( player )
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
				PlayerInventory_GiveNukeTitan( player )
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
	svGlobal.levelEnt.Signal( "NukeStart" )
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
		npc.Die()
	}
	wait 5
	SetGameState( eGameState.Postmatch )
	while( true )
	{
		WaitFrame()
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
		ScreenFadeToColor( player, 192, 192, 192, 64, 0.1, 6  )
		SetWinner( owner.GetTeam() )
	}
	wait 1.7
	if( IsValid( player ) )
	{
		StopSoundOnEntity( player, "goblin_dropship_explode" )
		StopSoundOnEntity( player, "pilot_geigercounter_warning_lv3" )
		if( player == owner )
			thread OwnerKillSound( player )
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
			EmitSoundOnEntityOnlyToPlayer( player, player, "titan_nuclear_death_explode" )
			EmitSoundOnEntityOnlyToPlayer( player, player, "skyway_scripted_titanhill_mortar_explode" )
			EmitSoundOnEntityOnlyToPlayer( player, player, "bt_beacon_controlroom_dish_explosion" )
		}
	}
	wait 0.2
	if( IsValid( player ) )
	{
		ScreenFadeToColor( player, 192, 192, 192, 255, 0.1, 4  )
	}
}

void function OwnerKillSound( entity player )
{
	for (int value = GetPlayerArray().len(); value > 0; value = value - 1)
	{
		if( IsValid( player ) )
		{
			EmitSoundOnEntityOnlyToPlayer( player, player, "pilot_killed_indicator" )
			EmitSoundOnEntityOnlyToPlayer( player, player, "pilot_killed_indicator" )
		}
		WaitFrame()
	}
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
		soul.soul.titanLoadout.titanExecution = "execution_northstar_prime"
		titan.SetSharedEnergyRegenDelay( 1.0 )
		titan.SetSharedEnergyRegenRate( 333.3 )

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
		SendHudMessage(player, "已启用远征装备， 取消\"边境帝王\"战绘以使用原版帝王",  -1, 0.3, 200, 200, 225, 0, 0.15, 12, 1);
		soul.s.titanTitle <- "遠征"
		titan.SetSharedEnergyRegenDelay( 1.0 )
		titan.SetSharedEnergyRegenRate( 333.3 )

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
		SendHudMessage(player, "已启用野牛泰坦装备，取消至尊泰坦以使用原版烈焰",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
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
		soul.soul.titanLoadout.titanExecution = "execution_ion"

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
		SendHudMessage(player, "已启用游侠泰坦装备，取消至尊泰坦以使用原版浪人",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
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
		SendHudMessage(player, "已启用天图泰坦装备，取消至尊泰坦以使用原版强力",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "天圖"
		soul.s.shouldFPEmbark <- true
		soul.s.classicExecution <- true

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
		titan.GiveOffhandWeapon( "mp_titanability_sonar_pulse", OFFHAND_SPECIAL, [ "tcp_bubble_shield" ] )
		titan.GiveOffhandWeapon( "mp_ability_holopilot", OFFHAND_TITAN_CENTER, [ "tcp_titan_holo" ] )
		titan.GiveOffhandWeapon( "mp_titanweapon_salvo_rockets", OFFHAND_ORDNANCE, [ "tcp_mine" ] )
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
		SendHudMessage(player, "已启用巨妖泰坦装备，取消至尊泰坦以使用原版强力",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
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


	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_vanguard.mdl" && ( titan.GetCamo() != -1 || titan.GetSkin() != 3 ) )	//帝王
	{
		soul.s.TitanHasBeenChange <- true
		soul.SetTitanSoulNetInt( "upgradeCount", 3 )

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