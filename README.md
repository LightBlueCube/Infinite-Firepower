# (｡･∀･)ﾉﾞ

这里放的是无限火力的配置

当然，拿去开服也可以，只需要标注一下下原作者就行！

有啥服务器的问题和bug反馈也可以发这

## 特别鸣谢（名字按首字母顺序排列）：

[AnsonSkywalker][AnsonSkywalker]

[cmggy][cmggy]

[DZ][DZ][^1]

[^1]:没找到DZ的GitHub账户，先用他个人主页代替

[Pan-da32767][Pan-da32767]

[RycXEpd][RycXEpd]

[VoyageDB][VoyageDB]

[Wolf109909][Wolf109909]

[zxcPandora][zxcPandora]

## 无限火力都改了什么？

泰坦获取速度 \* 4，泰坦核心获取速度 \* 2，泰坦脱战回盾

ai刷新 \* ( 4 / 3 )，ai装甲伤害和伤害取near_val[^2] \* 2[^3]，视力取战役ai

[^2]:在配置文件里，武器在近距离对非装甲单位所造成的伤害叫"damage_near_value"，我在这里简称它为"near_val"
[^3]:部分特殊武器的伤害数值做了单独平衡

增加步枪兵和幽灵战士还有潜行者能用的武器，分别为：火箭发射器，电能步枪，磁能手榴弹

死神会投掷炸蛛，阵亡时会核爆（无视黄血和护盾）

所有泰坦都拥有边境血量（仅血量，其余不动，表现为血量 + 2500（一格））

一代训牛术[^4]（伤害取near_val \* 25[^2])

[^4]:一代训牛部分由[DB][VoyageDB]大佬修复并完善

训牛拔电池时不会打断隐身效果，训牛拔电池伤害无论如何都优先扣除盾的血量，也就是说现在黄血被拔电池只要有点盾就死不了

绿电池回血2格 + 满盾，核心恢复80%

黄电池回血1格 + 满盾（黄电池无法将泰坦从毁减状态拉出），核心恢复40%

应急电池强化使用后有 2 / 3 的概率给黄电池  1 / 3 的概率给绿电池

当且仅当玩家一命击杀24人（包括NPC泰坦），会获得Alpha核弹，启动后启动方队伍无条件胜利并结束游戏

每当玩家击杀4人（包括NPC泰坦）或一命击杀4人（包括NPC泰坦）时，都会获得一个核武泰坦，表现为召唤一个落地就开始核爆的核武泰坦，服务器内打开控制台输入hw以查看详情

按住F可以扔出电池，仅在处于铁驭状态且存活且有电池时工作

撤离阶段可以复活，撤离艇血量 27000（10格 + 2000） -> 60000（24格）

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

泰坦电烟最大持有量 4 -> 8  对非装甲单位dps 45 -> 35

MK5智障手枪对非装甲单位伤害 40 -> 20  射击模式 semi -> auto

军团智障核心开启期间，对装甲单位造成的伤害 \* 1.2，仅锁定装甲单位

强力弹群核心对装甲单位伤害 140 -> 100  溅射对装甲单位伤害 140 -> 100

帝王装备"能量盗取"处决获得的电池只加1格血 + 满盾

帝王可以一直升级到9级，升级顺序为从3个一级升级到3个二级升级再到3个三级升级

帝王涡旋升级电烟对装甲单位dps 1350 -> 850  对非装甲单位dps 90 -> 35

帝王没有神盾血量升级，血量为10000（4格），如果升级了高级崽种那么血量为15000（6格）

浪人剑核心持续时间 12 -> 6

浪人剑封减伤 70% -> 50%  核心期间剑封减伤 85% -> 70%

离子镭射核心所有伤害 325 -> 300  持续时间 4.5 -> 5.0

离子拥有边境升级"能量恢复"

火焰核心对装甲单位伤害 4500 -> 2500  对非装甲单位伤害 300 -> 200

## 新的泰坦！

所有新泰坦均不支持任何自定配件，但支持自定被动

### 远征

启用：帝王，携带"帝王边境"皮肤

血量：10000（4格）

左栏位：远征涡旋防护罩

中栏位：远征电烟

右栏位：多目标飞弹[^7]

[^7]:表现为战役里的多目标飞弹，容量12发，可以在未充能完毕的情况下使用（只发射符合充能百分比数量的飞弹），仅锁定装甲单位，对装甲单位伤害为 150，对非装甲单位伤害为 280

主武器：远征XO16

核心：爆发核心（核心启动后读条时间 5.5 -> 8）

### 野兽

启用：北极星，携带至尊涂装

血量：10000（4格）

左栏位：远征涡旋防护罩

中栏位：悬浮

右栏位：多目标飞弹[^7]

主武器：四段火箭

核心：飞行核心

### 野牛

启用：烈焰，携带至尊涂装

血量：12500（5格）

左栏位：隐身

中栏位：EMP陷阱[^8]

[^8]:表现为强力的声纳突波，效果为电弧场，落地后，等待1秒，开启5秒，伤害类型为EMP手雷，对装甲单位伤害为15 \* 8，对非装甲单位伤害为1 \* 8，当单位进入伤害范围内时，每0.1秒获得一次上述伤害，且离开该范围前将一直拥有被EMP手雷击中的屏幕特效和减速等效果

右栏位：激素（恢复速度 \* 2，使用时间 \* 2）

近战栏位：melee_titan_punch_fighter[^9]

[^9]:废稿武器，伤害改为1750每拳，范围为300，可按左键或F攻击

主武器：NULL（空）

核心：GroundSlam[^10]

[^10]:[DB][VoyageDB]大佬制作的核心，对非装甲单位伤害为500，对装甲单位伤害为4000，无衰减伤害范围 0-450  有衰减伤害范围 450-525  超过范围525外则无伤害，启动后立刻恢复激素的冷却，后提供一个根据视角朝向的大小为1200速度 + 高度轴的一个大小为-750的速度，执行烈焰的拍地动作

其他：野牛不会被卡拳，同样的，野牛也无法卡别人拳

### 执政官

启用：离子，携带至尊涂装

血量：10000（4格）

左栏位：自充能涡旋防护罩[^11]

[^11]:涡旋盾至少需要 剩余的能量 >= 100 才可以开启，当武器击中涡旋盾时，增加能量，计算公式为 近距离对装甲单位伤害 / 2500 = 要增加的百分比 如果要增加的百分比 <= 10% 那么用该计算公式: near_val / 1250 = 要增加的百分比

中栏位：EMP炸弹[^12]

[^12]:表现为强力的声纳突波，效果为电弧场，启动后消耗能量，计算公式为 当前剩余能量 / 2，落地后，开启0.5秒，伤害类型为EMP手雷，对装甲单位伤害为 25 \* 8，对非装甲单位伤害为 1 \* 8，当单位进入伤害范围内时，每0.1秒获得一次上述伤害，且离开该范围前将一直拥有被EMP手雷击中的屏幕特效和减速等效果

右栏位：EMP射线[^13]

[^13]:表现为帝王的满级能量汲取，启动后消耗能量，计算公式为 当前剩余能量 / 2，冷却时间为 原版冷却时间 \* 2，击中敌方泰坦后，敌方泰坦获得一个2秒的致盲 + 正常能量汲取伤害，击中不给使用者加盾

主武器：核裂枪[^14]

[^14]:表现为离子的分裂枪，伤害为 原版分裂枪伤害 \* 2 （对非装甲单位伤害 近距离 50 远距离 40  对装甲单位伤害 近距离 160 远距离 120），非瞄准射击一发，消耗20能量，瞄准射击三发，消耗80能量，如果能量耗光，非瞄准每射击一次将消耗2发弹药，瞄准每射击一次将消耗6发弹药

核心：冲刺核心

其他：消耗能量后需等待2.0秒后才会开始自行恢复（0.5 -> 2.0）

### 游侠

启用：浪人，携带至尊涂装

血量：10000（4格）

左栏位：剑封[^15]

[^15]:表现为浪人的剑封，减伤60%，有一个充能条，开启剑封时会消耗，在消耗殆尽之前会一直拥有移动速度加成

中栏位：NULL（空）

右栏位：同步彈頭[^16]

[^16]:針對單一目標發射歸航導彈，這個泰坦重火力武器必須先鎖定才能發射。發射時將一次發射三枚歸航導彈朝鎖定目標前進。

近战栏位：浪人剑

主武器：三連環榴彈[^17]

[^17]:三連環榴彈是同時發射三枚手榴彈的榴彈發射器。特別適用於淨空建築內部，而且榴彈一接觸裝甲即會爆炸，因此近距離對付其他泰坦非常有效。

核心：EMP风暴[^18]

[^18]:表现为开启后，在泰坦周围形成一个电弧场，持续24秒，伤害类型为EMP风暴，对装甲单位伤害为 125，对非装甲单位伤害为 20，当单位进入伤害范围内时，每0.1秒获得一次上述伤害

[RycXEpd]:https://github.com/RycXEpd
[VoyageDB]:https://github.com/DBmaoha
[cmggy]:https://github.com/cmggy
[Pan-da32767]:https://github.com/Pan-da32767
[zxcPandora]:https://github.com/zxcPandora
[DZ]:https://inchaos.icu/
[AnsonSkywalker]:https://github.com/AnsonSkywalker
[Wolf109909]:https://github.com/wolf109909