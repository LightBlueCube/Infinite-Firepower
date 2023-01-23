untyped //entity.s need this
global function TitanChangePro_Callbacks
global function MacroCheck_Threaded

const array<string> Tips_CN = [ "你知道吗？无限火力最开始只有4倍核心和4倍泰坦获取",
								"你知道吗？无限火力这个名字源于腐竹在官服瞎调私房设置时想出来的",
								"你知道吗？无限火力这个项目已经做了3个多月",
								"你知道吗？其实远征和野兽的多目标飞弹最开始没能力还原出来用的其实是帝王的飞弹",
								"你知道吗？其实我并不愿意写这个b玩意",
								"你知道吗？其实游侠最开始只有左栏位和右栏位，中栏位还是后面追加的",
								"你知道吗？很久之前的一代训牛带电池上机时不需要拔电池就能打",
								"你知道吗？很久之前服务器非常容易崩，其中绝大部分都是因为一代训牛",
								"你知道吗？其实这个小tips最开始是想用HudMsg显示的，但是rui更好看",
								"你知道吗？其实这些tips我有打算写他个一千多条",
								"你知道吗？其实原先有红电池，但因为太没用就删了",
								"你知道吗？其实原先想做一个队友可以拔出友方泰坦电池后再插回去的功能，但是过于滑稽和不平衡惨遭被砍",
								"你知道吗？其实原先有做一个上友方泰坦会给一个跟着视角动的盾牌，但是因为太不稳定经常崩所以被砍了",
								"你知道吗？其实天图最开始的方案是尝试还原一代的电弧炮，但是效果贼差，只能使用plan b",
								"你知道吗？其实我写这个只是为了吸引你多下点泰坦哈哈哈",
								"你知道吗？其实远征的上机动作是SB-7274的",
								"你知道吗？其实游侠和天图还有巨妖的处决是一代的",
								"你知道吗？其实游侠和天图还有巨妖的上机动作是取自一代的第一人称上机",
								"你知道吗？其实隐藏队伍比分是为了让你们不要把输赢看那么重要",
								"你知道吗？其实DB帮我真的非常多，没有他的帮助，这个项目也不会做这么久",
								"你知道吗？野牛和执政官的emp声纳的伤害类型其实是电弧手榴弹",
								"你知道吗？游侠核心可以被任何类型的盾挡住！",
								"你知道吗？被执政官致盲时你依旧可以操纵泰坦，且除了看不见不受任何影响",
								"你知道吗？其实我最烦的人就是不看简介就进来的，哪怕标题写的那么清楚",
								"你知道吗？充游戏的钱可以捐给nscn",
								"你知道吗？野牛EMP电不到人其实是因为落地后有一秒的前摇！",
								"你知道吗？服务器以前叫做一代训牛无限火力",
								"你知道吗？在这里被改过的AI的枪法比你还准！",
								"你知道吗？在这里被改过的死神就是本服大爹！",
								"你知道吗？其实重生和EA都没有木琴",
								"你知道吗？在这里被改过的死神会核爆!跳过黄血和护盾！",
								"你知道吗？其实浪人已经削的不能再削了",
								"你知道吗？我最初是开短时消耗战的，也不知道那时候的玩家能不能来看看现在的服",
								"你知道吗？野兽主武器溅射伤害很高，对铁驭两发溅射就死！",
								"你知道吗？游侠剑封时是两倍速度！",
								"你知道吗？在这里被改过的AI可以拿起反泰坦武器！",
								"你知道吗？智障手枪在这里被改成了全自动！",
								"你知道吗？训牛的TTK(Time to kill)在2秒以下，你只需要2秒就能拆一架泰坦！",
								"你知道吗？执政官的核心是一代的冲刺核心，我挺喜欢这个的，嘿嘿",
								"你知道吗？当年还没开始做平衡时烈焰可以一打三！",
								"你知道吗？一直都有在做平衡！我写了一堆东西来检测每个泰坦的使用数据！都不超模！",
								"你知道吗？以前泰坦核心获取倍率是4倍！现在是2倍！",
								"你知道吗？很久以前有个泰坦叫弧光，后面忘了",
								"你知道吗？我从去年8月2日才正式的当一名腐竹，当时啥也不会，哈哈",
								"你知道吗？无限火力是开源开发的！github.com/LightBlueCube/Infinite-Firepower",
								"你知道吗？我不接受任何形式，任何理由的捐赠",
								"你知道吗？一命击杀30人或泰坦可以获得核弹！",
								"你知道吗？记得看他吗的简介",
								"你知道吗？我菜到甚至打不过自己改的ai",
								"你知道吗？我不知道这条tips要写什么了",
								"你知道吗？在这里被改过的死神会投掷炸蛛！",
								"你知道吗？训牛拔电池不会取消隐身效果！",
								"你知道吗？应急电池有三分之二的概率给黄电池，三分之一的概率给绿点池！",
								"你知道吗？击杀4人和连杀4人都会获得一个核武泰坦！",
								"你知道吗？核武泰坦能砸死队友！",
								"你知道吗？我把撤离阶段改成了可以复活的！",
								"你知道吗？泰坦死亡后如果没有被拔过会有0.1的概率掉绿点池，反之掉落黄电池！",
								"你知道吗？训牛跳机时获得的速度更大！你可以通过这个技巧飞很远！",
								"你知道吗？所有的新增泰坦都不支持加配件的哦，但是被动是可以加的！",
								"你知道吗？远征和野兽除了飞弹不能锁人，其余都是完美还原战役的！",
								"你知道吗？野牛的隐身在低血量时并不好用！",
								"你知道吗？执政官消耗能量后需要等待两秒才会开始恢复！",
								"你知道吗？游侠的三连环榴弹伤害超高！近距离直接一次发射秒掉黄血！",
								"你知道吗？天图的投掷型电子烟幕的伤害是几乎两倍的帝王高级电烟！",
								"你知道吗？天图的圆顶护盾血量是3000，看起来薄是因为他接受了全方位的伤害！",
								"你知道吗？天图的核心其实是加100发弹药，可以叠加！",
								"你知道吗？天图的XO16在正常情况下是每一发都有0.01的破盾！",
								"你知道吗？天图开启核心后打光或者下机才会视为一次核心结束，核心期间每一发都有0.04的破盾！",
								"你知道吗？无限火力有一个5000多字的完整文档！",
								"你知道吗？启动野牛核心会立刻恢复激素！",
								"你知道吗？训牛拔电池伤害改成了无论如何都优先扣除盾的血量，也就是说现在黄血被拔只要有盾就死不了！",
								"你知道吗？帝王装备\"能量盗取\"处决获得的电池只加1格血 + 满盾",
								"你知道吗？只有帝王没有神盾血量升级",
								"你知道吗？野牛不会被卡拳！同样他也没法卡别人拳",
								"你知道吗？电弧场！游侠的电弧场可以快速杀死铁驭！",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"你知道吗？",
								"BASE64 <- 6K6w5b6X5bim5LiK5Zu+54mH",
								"(KEY=BASE64) DES <- U2FsdGVkX19/Y7I/2NcymJc/6kMWb7HQR1fyezAQS0w=" ]

const array<string> Tips =    [ "你知道嗎？無限火力最開始只有4倍核心和4倍泰坦獲取",
								"你知道嗎？無限火力這個名字源於腐竹在官服瞎調私房設置時想出來的",
								"你知道嗎？無限火力這個項目已經做了3個多月",
								"你知道嗎？其實遠征和野獸的多目標飛彈最開始沒能力還原出來用的其實是帝王的飛彈",
								"你知道嗎？其實我並不願意寫這個b玩意",
								"你知道嗎？其實遊俠最開始只有左欄位和右欄位，中欄位還是後面追加的",
								"你知道嗎？很久之前的一代訓牛帶電池上機時不需要拔電池就能打",
								"你知道嗎？很久之前服務器非常容易崩，其中絕大部分都是因為一代訓牛",
								"你知道嗎？其實這個小tips最開始是想用HudMsg顯示的，但是rui更好看",
								"你知道嗎？其實這些tips我有打算寫他個一千多條",
								"你知道嗎？其實原先有紅電池，但因為太沒用就刪了",
								"你知道嗎？其實原先想做一個隊友可以拔出友方泰坦電池後再插回去的功能，但是過於滑稽和不平衡慘遭被砍",
								"你知道嗎？其實原先有做一個上友方泰坦會給一個跟著視角動的盾牌，但是因為太不穩定經常崩所以被砍了",
								"你知道嗎？其實天圖最開始的方案是嘗試還原一代的電弧炮，但是效果賊差，只能使用plan b",
								"你知道嗎？其實我寫這個只是為了吸引你多下點泰坦哈哈哈",
								"你知道嗎？其實遠征的上機動作是SB-7274的",
								"你知道嗎？其實遊俠和天圖還有巨妖的處決是一代的",
								"你知道嗎？其實遊俠和天圖還有巨妖的上機動作是取自一代的第一人稱上機",
								"你知道嗎？其實隱藏隊伍比分是為了讓你們不要把輸贏看那麼重要",
								"你知道嗎？其實DB大佬幫我真的非常多，沒有他的幫助，這個項目也不會做這麼久",
								"你知道嗎？野牛和執政官的emp聲納的傷害類型其實是電弧手榴彈",
								"你知道嗎？遊俠核心可以被任何類型的盾擋住！",
								"你知道嗎？被執政官致盲時你依舊可以操縱泰坦，且除了看不見不受任何影響",
								"你知道嗎？其實我最煩的人就是不看簡介就進來的，哪怕標題寫的那麼清楚",
								"你知道嗎？充遊戲的錢可以捐給nscn",
								"你知道嗎？野牛EMP電不到人其實是因為落地後有一秒的前搖！",
								"你知道嗎？服務器以前叫做一代訓牛無限火力",
								"你知道嗎？在這裏被改過的AI的槍法比你還準！",
								"你知道嗎？在這裏被改過的死神就是本服大爹！",
								"你知道嗎？其實重生和EA都沒有木琴",
								"你知道嗎？在這裏被改過的死神會核爆呦，跳過黃血和護盾！",
								"你知道嗎？其實浪人已經削的不能再削了",
								"你知道嗎？我最初是開短時消耗戰的，也不知道那時候的玩家能不能來看看現在的服",
								"你知道嗎？野獸主武器濺射傷害很高，對鐵馭兩發濺射就死！",
								"你知道嗎？遊俠劍封時是兩倍速度！",
								"你知道嗎？在這裏被改過的AI可以拿起反泰坦武器！",
								"你知道嗎？智障手槍在這裏被改成了全自動！",
								"你知道嗎？訓牛的TTK(Time to kill)在2秒以下，你只需要2秒就能拆一架泰坦！",
								"你知道嗎？執政官的核心是一代的沖刺核心，我挺喜歡這個的，嘿嘿",
								"你知道嗎？當年還沒開始做平衡時烈焰可以一打三！",
								"你知道嗎？一直都有在做平衡！我寫了一堆東西來檢測每個泰坦的使用數據！都不超模！",
								"你知道嗎？以前泰坦核心獲取倍率是4倍！現在是2倍！",
								"你知道嗎？很久以前有個泰坦叫弧光，後面忘了",
								"你知道嗎？我從去年8月2日才正式的當一名腐竹，當時啥也不會，哈哈",
								"你知道嗎？無限火力是開源開發的！github.com/LightBlueCube/Infinite-Firepower",
								"你知道嗎？我不接受任何形式，任何理由的捐贈",
								"你知道嗎？一命擊殺30人或泰坦可以獲得核彈！",
								"你知道嗎？記得看他嗎的簡介",
								"你知道嗎？我菜到甚至打不過自己改的ai",
								"你知道嗎？我不知道這條tips要寫什麼了",
								"你知道嗎？在這裏被改過的死神會投擲炸蛛！",
								"你知道嗎？訓牛拔電池不會取消隱身效果！",
								"你知道嗎？應急電池有三分之二的概率給黃電池，三分之一的概率給綠點池！",
								"你知道嗎？擊殺4人和連殺4人都會獲得一個核武泰坦！",
								"你知道嗎？核武泰坦能砸死隊友！",
								"你知道嗎？我把撤離階段改成了可以復活的！",
								"你知道嗎？泰坦死亡後如果沒有被拔過會有0.1的概率掉綠點池，反之掉落黃電池！",
								"你知道嗎？訓牛跳機時獲得的速度更大！你可以通過這個技巧飛很遠！",
								"你知道嗎？所有的新增泰坦都不支持加配件的哦，但是被動是可以加的！",
								"你知道嗎？遠征和野獸除了飛彈不能鎖人，其余都是完美還原戰役的！",
								"你知道嗎？野牛的隱身在低血量時並不好用！",
								"你知道嗎？執政官消耗能量後需要等待兩秒才會開始恢復！",
								"你知道嗎？遊俠的三連環榴彈傷害超高！近距離直接一次發射秒掉黃血！",
								"你知道嗎？天圖的投擲型電子煙幕的傷害是幾乎兩倍的帝王高級電煙！",
								"你知道嗎？天圖的窮頂護盾血量是3000，看起來薄是因為他接受了全方位的傷害！",
								"你知道嗎？天圖的核心其實是加100發彈藥，可以疊加！",
								"你知道嗎？天圖的XO16在正常情況下是每一發都有0.01的破盾！",
								"你知道嗎？天圖開啟核心後打光或者下機才會視為一次核心結束，核心期間每一發都有0.04的破盾！",
								"你知道嗎？無限火力有一個5000多字的完整文檔！",
								"BASE64 <- 6K6w5b6X5bim5LiK5Zu+54mH",
								"(KEY=BASE64) DES <- U2FsdGVkX19/Y7I/2NcymJc/6kMWb7HQR1fyezAQS0w=" ]

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
	AddClientCommandCallback( "helpa", simpelhelp );
	AddClientCommandCallback( "helpb", simpelhelp2 );
	AddClientCommandCallback( "helpc", simpelhelp3 );
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
			if( player.GetModelName() == $"models/titans/medium/titan_medium_tone_prime.mdl" )		//天图
			{
				UseTime_ModTitan_6 += 10
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
		}
	}
}

bool function simpelhelp( entity player, array<string> args )
{
	if( IsValid( player ) )
		SendHudMessage(player, "因为BroadCast寄了所以只能做个简单介绍\n控制台输入\"helpb\"看第2页\n按住F可以扔电池\n有一代训牛 拔下电池后往电池仓打\n新泰坦可以通过以下涂装获得\n远征:边境帝王涂装\n野兽:至尊北极星\n野牛:至尊烈焰\n执政官:至尊离子\n游侠:至尊浪人\n天图:至尊强力",  -1, 0.3, 200, 200, 225, 0, 0.15, 50, 1);
	return true
}

bool function simpelhelp2( entity player, array<string> args )
{
	if( IsValid( player ) )
		SendHudMessage(player, "控制台输入\"helpc\"看第3页\n绿电池回血2格\n黄电池回血1格，不能从黄血拉出\n执政官Q的作用是致盲敌方泰坦\n电池被拔过后除非友方铁驭补给否则再次被训牛敌方铁驭不需要拔电池就能掏枪射击",  -1, 0.3, 200, 200, 225, 0, 0.15, 50, 1);
	return	true
}

bool function simpelhelp3( entity player, array<string> args )
{
	if( IsValid( player ) )
		SendHudMessage(player, "执政官的盾接到子弹会恢复能量\n每杀四个人就会获得一个核武泰坦，表现为召唤一个落地就核爆的泰坦，控制台输入hw查看详情\nNPC的刷新数量和伤害都有大幅提升\n帝王可以升到9级，顺序为先升三个一级升级然后三个二级再然后三个三级",  -1, 0.3, 200, 200, 225, 0, 0.15, 50, 1);
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

	//NSSendInfoMessageToPlayer( player, Tips[ RandomInt( Tips.len() ) ] )	//给玩家发Tips
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
		soul.s.shouldFPEmbark <- true
		soul.s.classicExecution <- true

		array<entity> weapons = titan.GetMainWeapons()
        foreach( entity weapon in weapons )
        {
            titan.TakeWeaponNow( weapon.GetWeaponClassName() )
        }
		titan.GiveWeapon( "mp_titanweapon_triplethreat", [ "spread_increase_ttt", "rolling_rounds" ] )
		titan.TakeOffhandWeapon( OFFHAND_ORDNANCE )
		titan.TakeOffhandWeapon( OFFHAND_TITAN_CENTER )
        titan.TakeOffhandWeapon( OFFHAND_SPECIAL )
		titan.TakeOffhandWeapon( OFFHAND_EQUIPMENT )
		titan.GiveOffhandWeapon( "mp_ability_swordblock", OFFHAND_SPECIAL )
		titan.GiveOffhandWeapon( "mp_titanability_smoke", OFFHAND_TITAN_CENTER, [ "tcp_emp" ])
		titan.GiveOffhandWeapon( "mp_titanweapon_homing_rockets", OFFHAND_ORDNANCE )
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
	else if( titan.GetModelName() == $"models/titans/medium/titan_medium_tone_prime.mdl" )
	{
		soul.s.TitanHasBeenChange <- true
		SendHudMessage(player, "已启用天图泰坦装备，取消至尊泰坦以使用原版强力",  -1, 0.3, 200, 200, 225, 0, 0.15, 5, 1);
		soul.s.titanTitle <- "天圖"
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