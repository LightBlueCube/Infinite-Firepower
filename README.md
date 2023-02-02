# (｡･∀･)ﾉﾞ

这里放的是无限火力的配置

如需使用本仓库请遵循[GPLv3][GPLv3]协议

有啥服务器的问题和bug反馈也可以发这

## 特别鸣谢（名字按首字母顺序排列）：

[cmggy][cmggy]

[D3-3109][D3-3109]

[DZ][DZ][^1]

[^1]:没找到DZ的GitHub账户，先用他个人主页代替

[Pan-da32767][Pan-da32767]

[VoyageDB][VoyageDB]

[wolf109909][wolf109909]

[zxcPandora][zxcPandora]

## 无限火力都改了什么？

泰坦获取速度 \* 4，泰坦核心获取速度 \* 2，泰坦脱战回盾

ai伤害取默认[^2]，视力取战役ai，瞄准精度为最大，取消开火限制

[^2]:原版ai伤害大概为默认的四分之一

增加步枪兵和幽灵战士还有潜行者能用的武器，分别为：火箭发射器，电能步枪，磁能手榴弹

死神会投掷炸蛛，阵亡时会核爆（无视黄血和护盾）

所有泰坦都拥有边境血量（仅血量，其余不动，表现为血量 + 2500（一格））

一代训牛术[^3]（伤害取damage_near_value_titanarmor \* 16[^4]），如果被训牛泰坦为黄血，则伤害减半

[^3]:一代训牛部分由[DB][VoyageDB]大佬修复并完善
[^4]:小部分武器的伤害数值做了单独平衡，平均ttk约为2s左右

训牛拔电池时不会打断隐身效果，训牛拔电池伤害无论如何都优先扣除盾的血量，也就是说现在黄血被拔电池只要有点盾就死不了

绿电池回血2格 + 满盾，核心恢复80%

黄电池回血1格 + 满盾（黄电池无法将泰坦从毁减状态拉出），核心恢复40%

应急电池强化使用后有 2 / 3 的概率给黄电池  1 / 3 的概率给绿电池

当且仅当玩家一命击杀30人（包括NPC泰坦），会获得Alpha核弹，启动后启动方队伍无条件胜利并结束游戏

每当玩家击杀4人（包括NPC泰坦）或一命击杀4人（包括NPC泰坦）时，都会获得一个核武泰坦，表现为召唤一个落地就开始核爆的核武泰坦，服务器内打开控制台输入hw以查看详情

按住F可以扔出电池，仅在处于铁驭状态且存活且有电池时工作

撤离阶段可以复活，撤离艇血量 27000（10格 + 2000） -> 60000（24格）

队伍比分会一直隐藏到最后一分十秒，在最后一分钟会开启十倍分数获取，冲冲冲！

### 一代训牛术的逻辑

当泰坦落地时，默认电池仓内有电池

当电池被拔出时，电池仓内无电池

当队友给友方泰坦一个电池时，电池仓内有电池

----

当铁驭训牛敌方泰坦时，如果电池仓内有电池，拔出电池后立刻掏枪[^5]

[^5]:如果此时铁驭身上已有电池，那么新拔出的电池将会掉落至地上

当铁驭训牛敌方泰坦时，如果电池仓内无电池，立刻掏枪

当泰坦死亡且电池仓内有电池时 90%掉落黄电池 10%掉落绿电池

### 亿些平衡性修改

当玩家训牛中途跳机时，获得的离机速度增加[^6]

[^6]:获得一个方向为视角正后方的一个大小为400的没有高度速度的速度 + 一个方向为跳离时按住的方向键的方向的一个大小为200的速度（如果跳离时没按则不给这个速度） + 一个方向为固定朝上的一个大小为400的速度

泰坦电烟最大持有量 4 -> 8  对非装甲单位dps 45 -> 40

MK5智障手枪对非装甲单位伤害 40 -> 20  射击模式 semi -> auto

军团智障核心开启期间，对装甲单位造成的伤害 \* 1.2，仅锁定装甲单位

强力弹群核心对装甲单位伤害 140 -> 100  溅射对装甲单位伤害 140 -> 100

帝王装备"能量盗取"处决获得的电池只加1格血 + 满盾

帝王可以一直升级到9级，升级顺序为从3个一级升级到3个二级升级再到3个三级升级

帝王涡旋升级电烟对装甲单位dps 1350 -> 850

帝王没有神盾血量升级，血量为10000（4格），如果升级了高级崽种那么血量为15000（6格）

浪人剑核心持续时间 12 -> 6

浪人剑封减伤 70% -> 50%  核心期间剑封减伤 85% -> 70%

离子镭射核心所有伤害 325 -> 300  持续时间 4.5 -> 5.0

火焰核心对装甲单位伤害 4500 -> 3500  对非装甲单位伤害 300 -> 200

## 新的泰坦！

所有新泰坦均不支持任何自定配件，但支持自定被动

注：标有SP_开头的武器代表所有数值均取用战役版本

### 远征

启用：帝王，携带"帝王边境"皮肤

血量：10000（4格）

左栏位：SP_涡旋防护罩

中栏位：SP_电子烟幕

右栏位：多目标飞弹[^7]

[^7]:表现为战役里的多目标飞弹，除了不能锁非装甲单位外其余均与战役保持一致

主武器：SP_XO16

核心：SP_爆发核心

### 野兽

启用：北极星，携带至尊涂装

血量：10000（4格）

左栏位：SP_涡旋防护罩

中栏位：SP_悬浮

右栏位：多目标飞弹[^7]

主武器：SP_四段火箭

核心：SP_飞行核心

其他：野兽拥有北极星装备"毒蛇推进器"

### 野牛

启用：烈焰，携带至尊涂装

血量：15000（6格）

左栏位：隐身

中栏位：EMP陷阱[^8]

[^8]:表现为强力的声纳突波，效果为电弧场，落地后，等待1秒，开启5秒，伤害类型为EMP手雷，对装甲单位伤害为15 \* 8，对非装甲单位伤害为1 \* 8，当单位进入伤害范围内时，每0.1秒获得一次上述伤害，且离开该范围前将一直拥有被EMP手雷击中的屏幕特效和减速等效果

右栏位：激素（恢复速度 \* 2，使用时间 \* 2）

近战栏位：melee_titan_punch_fighter[^9]

[^9]:废稿武器，伤害改为1750每拳，范围为300，可按左键或F攻击

主武器：NULL（空）

核心：GroundSlam[^10]

[^10]:[DB][VoyageDB]大佬制作的核心，对非装甲单位伤害为500，对装甲单位伤害为3500，无衰减伤害范围 0-450  有衰减伤害范围 450-525  超过范围525外则无伤害，启动后立刻恢复激素的冷却，后提供一个根据视角朝向的大小为1200速度 + 高度轴的一个大小为-750的速度，执行烈焰的拍地动作

其他：野牛不会被卡拳，同样的，野牛也无法卡别人拳

### 执政官

启用：离子，携带至尊涂装

血量：10000（4格）

左栏位：自充能涡旋防护罩[^11]

[^11]:涡旋盾消耗速度 2.0 -> 6.0，至少需要剩余的能量 >= 100 才可以开启，当武器击中涡旋盾时，增加能量，计算公式为 近距离对装甲单位伤害 / 1250 = 要增加的百分比 如果要增加的百分比 <= 10% 那么用该计算公式: near_val / 625 = 要增加的百分比

中栏位：EMP炸弹[^12]

[^12]:表现为强力的声纳突波，效果为电弧场，启动后消耗 当前能量 / 2，落地后，开启0.5秒，伤害类型为EMP手雷，对装甲单位伤害为 25 \* 8，对非装甲单位伤害为 1 \* 8，当单位进入伤害范围内时，每0.1秒获得一次上述伤害，且离开该范围前将一直拥有被EMP手雷击中的屏幕特效和减速等效果

右栏位：闪光束[^13]

[^13]:表现为帝王的满级能量汲取，启动后消耗 当前能量 / 2，冷却时间为 原版冷却时间 \* 2，击中敌方泰坦后，敌方泰坦获得一个2秒的致盲 + 正常能量汲取伤害，击中不给使用者加盾，击中队友不给队友加盾

主武器：核裂枪[^14]

[^14]:表现为离子的分裂枪，伤害为 原版分裂枪伤害 \* 2 （对非装甲单位伤害 近距离 50 远距离 40  对装甲单位伤害 近距离 160 远距离 120），非瞄准射击一发，消耗30能量，瞄准射击三发，消耗90能量，如果能量耗光，非瞄准每射击一次将消耗2发弹药，瞄准每射击一次将消耗6发弹药

核心：雷暴[^15]

[^15]:表现为开启后，朝视角前方释放五道（0°,±10°,±40°）电弧波，单道伤害为1250，可以被任何盾挡住且不会扣除盾的血量或耐久

其他：消耗能量后需等待2.0秒后才会开始自行恢复（0.5 -> 2.0）

### 游侠

启用：浪人，携带至尊涂装

血量：7500（3格）

左栏位：剑封[^15]

[^15]:表现为浪人的剑封，减伤50%，有一个充能条，剑封时会消耗，消耗速度为10秒，在消耗殆尽之前会一直拥有1.5倍移速加成，消耗殆尽后移速为 正常移速 \* 0.4，冷却2.5秒后才会开始恢复充能，恢复速度为8秒

中栏位：电弧场[^16]

[^16]:表现为按下后，在泰坦上形成一个电弧场，持续16秒，伤害类型为EMP风暴，对装甲单位伤害为 64，对非装甲单位伤害为 10，当单位进入伤害范围内时，每0.1秒获得一次上述伤害

右栏位：同步彈頭[^17]

[^17]:針對單一目標發射歸航導彈，這個泰坦重火力武器必須先鎖定才能發射。發射時將一次發射三枚歸航導彈朝鎖定目標前進。

近战栏位：浪人剑

主武器：三連環榴彈[^18]

[^18]:三連環榴彈是同時發射三枚手榴彈的榴彈發射器。特別適用於淨空建築內部，而且榴彈一接觸裝甲即會爆炸，因此近距離對付其他泰坦非常有效。

核心：衝刺核心[^19]

[^19]:啟用時衝刺不會耗盡。

### 天图

启用：强力，携带至尊涂装

血量：10000（4格）

左栏位：泡泡护盾[^20]

[^20]:表现为强力的声纳突波，发射后在落点生成一个无伤害且自身无敌的泡泡护盾，持续8秒

中栏位：幻影[^21]

[^21]:表现为幻影铁驭，使用后表现为生成一个和你一模一样的泰坦幻影，抬头显示的假血量取当前血量，如果黄血则血量取 当前 \* 4，冷却时间为20秒，满充能可使用2次，不可以在仅往左移动或仅往右移动时使用

右栏位：绊雷[^22]

[^22]:表现为火箭弹群，发射3个黏性绊雷，落地后存在30秒，如果敌方单位靠近则立刻爆炸，伤害为 对非装甲单位 500 对装甲单位 1000，无衰减范围 0-140 衰减范围 140-320 范围超过320无伤害

主武器：40cm机炮[^23]

[^23]:伤害为 对非装甲单位 200 对装甲单位 600 溅射对非装甲单位 90 溅射对装甲单位 400，无衰减范围 0-100 衰减范围 100-225 范围超过225无伤害，射速为1.5/s，弹匣容量为10发，核心期间全自动，射速为2/s

核心：破壞核心[^24]

[^24]:啟用時大幅提升武器殺傷力。（核心期间造成的所有伤害都是1.5倍）

### 巨妖

启用：军团，携带至尊涂装

血量：12500（5格）

左栏位：穹顶护盾[^25]

[^25]:[DB][VoyageDB]大佬制作的护盾，血量为3000，持续8秒，冲刺会打破护盾，在使用期间泰坦免疫一切伤害（伤害将转移到护盾），护盾会吃到近战伤害

中栏位：投掷型电子烟幕[^26]

[^26]:表现为强力的声纳突波，在落点生成一个涡旋电子烟幕，对泰坦dps 1000  对铁驭dps 30

右栏位：球状闪电[^27]

[^27]:表现为帝王的能量汲取，冷却时间为20秒（12 -> 20），拥有两种击发模式，当按住不到1秒就松开时为射线模式，当按住超过1秒时为电球模式，当射线模式时：发射一道能量汲取，消耗三分之一的武器充能，击中目标时对目标造成 对装甲单位伤害 200 对非装甲单位伤害 20 并自己回盾1000点。当电球模式时：发射一个速度较慢的电球（速度为200），消耗全部武器充能，在该范围大小为500的范围内会持续收到被电球击中的减益 + EMP减益 和每0.1秒的 对装甲单位伤害 50 对非装甲单位伤害 8，每当且仅当对敌方装甲单位造成一次伤害时都会恢复自己护盾100点，如果护盾已满则恢复50点生命值，当击中目标时对目标造成 对装甲单位伤害 200 对非装甲单位伤害 20

主武器：XO16[^28]

[^28]:表现为加装了加速器的远征XO16，最大射速为20，达到最大射速需5秒，伤害为 对非装甲单位 近距离 49 远距离 34  对装甲单位 近距离 100 远距离 80，换弹速度和一代XO16保持一致(4.6s)，弹容60发，瞄准射击扩散不会减小，在核心开启前如果击中涡旋盾则每发会消耗涡旋盾充能的1%，核心开启后不可换弹，打光子弹即视为核心结束，会重置武器状态致核心前，在核心开启期间如果击中涡旋盾则每发会消耗涡旋盾充能的4%

核心：弹容超载[^29]

[^29]:开启后立刻给主武器增加150发子弹，且仅给主武器增加150发子弹，无任何额外效果，可叠加子弹


[GPLv3]:https://www.gnu.org/licenses/gpl-3.0.en.html
[VoyageDB]:https://github.com/DBmaoha
[D3-3109]:https://github.com/D3-3109
[cmggy]:https://github.com/cmggy
[Pan-da32767]:https://github.com/Pan-da32767
[zxcPandora]:https://github.com/zxcPandora
[DZ]:https://inchaos.icu/
[wolf109909]:https://github.com/wolf109909
