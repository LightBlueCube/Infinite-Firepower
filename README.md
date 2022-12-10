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

泰坦获取速度 \* 4，泰坦核心获取速度 \* 4，泰坦脱战回盾

ai刷新 \* ( 4 / 3 )，死神刷新 \* 0.5，ai装甲伤害和伤害取near_val[^2] \* 2[^3]，视力取战役ai

[^2]:在配置文件里，武器在近距离对非装甲单位所造成的伤害叫"damage_near_value"，我在这里简称它为"near_val"
[^3]:部分特殊武器的伤害数值做了单独平衡

增加步枪兵和幽灵战士能用的武器，分别为：火箭发射器，电球发射器，电能步枪，磁能手榴弹

所有泰坦都拥有边境血量（仅血量，其余不动，表现为血量 + 2500（一格））

一代训牛术[^4]（伤害取near_val \* 25[^2])

[^4]:一代训牛部分由[DB][VoyageDB]大佬修复并完善

训牛拔电池时不会打断隐身效果

训牛友方泰坦时，会获得一个绑定在友方泰坦上的盾，血量为2500，可抵挡溅射伤害

绿电池回血2格 + 满盾，黄电池回血1格 + 满盾（黄电池无法将泰坦从毁减状态拉出）

红电池回血0.5格 + 满盾，如果吃到红电池时泰坦处于毁减状态，拉出毁减，回血3格 + 满盾

强化里的应急电池会从红电池，黄电池，绿电池中随机选一个给使用者

当玩家一命击杀24人（或NPC泰坦）或总击杀达到48人（或NPC泰坦）时，会获得Alpha核弹，启动后启动方队伍无条件胜利并结束游戏

每当玩家击杀4人（或NPC泰坦）时（非连杀也算），会获得一个核武泰坦，表现为召唤一个落地就开始核爆的核武泰坦

按住E可以扔出电池，仅在处于铁驭状态且存活时工作

撤离阶段可以复活，撤离艇血量 27000（10格 + 2000） -> 100000（40格），当训牛友方铁驭且有电池时，需要按近战键以交付

### 一代训牛术的逻辑

当泰坦落地时，默认电池仓内有电池

当电池被拔出时，电池仓内无电池

当队友给友方泰坦一个电池时，电池仓内有电池

----

当铁驭训牛敌方泰坦时，如果电池仓内有电池，拔出电池后立刻掏枪[^5]

[^5]:如果此时铁驭身上已有电池，那么新拔出的电池将会掉落至地上

当铁驭训牛敌方泰坦时，如果电池仓内无电池，立刻掏枪

当泰坦死亡且电池仓内有电池时 50%掉落黄电池 40%掉落红电池 10%掉落绿电池

### 亿些平衡性修改

当玩家训牛中途跳机时，获得的离机速度增加[^6]

[^6]:获得一个方向为视角正后方的一个大小为400的没有高度速度的速度 + 一个方向为跳离时按住的方向键的方向的一个大小为200的速度（如果跳离时没按则不给这个速度） + 一个方向为固定朝上的一个大小为400的速度

泰坦电烟最大持有量 4 -> 8  对非装甲单位dps 45 -> 35

MK5智障手枪对非装甲单位伤害 40 -> 20  射击模式 semi -> auto

军团智障核心开启期间，对装甲单位造成的伤害 \* 1.5，仅锁定装甲单位

帝王装备"能量盗取"处决获得的电池只加1格血 + 满盾

帝王主武器对装甲单位伤害  近距离 120 -> 80  远距离 100 -> 70

帝王涡旋升级电烟对装甲单位dps 1350 -> 650  对非装甲单位dps 90 -> 35

帝王没有神盾血量升级，血量为10000（4格），如果升级了高级崽种那么血量为15000（6格）

浪人剑核心持续时间 12 -> 6

浪人剑封减伤 70% -> 50%  核心期间剑封减伤 85% -> 70%

离子镭射核心所有伤害 325 -> 300  持续时间 4.5 -> 5.0

离子拥有边境升级"能量恢复"

飞行核心对单位伤害 300 -> 200  溅射对非装甲单位伤害 55 -> 35  溅射对装甲单位伤害 300 -> 200

火焰核心对装甲单位伤害 4500 -> 2500  对非装甲单位伤害 300 -> 200

## 新的泰坦！

### 远征

启用：帝王，携带"帝王边境"涂装

血量：10000（4格）

左栏位：远征涡旋防护罩

中栏位：远征电烟

右栏位：多目标飞弹[^7]

[^7]:表现为远征/野兽的多目标飞弹，容量12发，可以在未充能完毕的情况下使用（只发射符合充能百分比数量的飞弹），准心套住目标时锁定需0.3s，准心移开目标后后解除锁定需0.2s，搜索距离为30，仅锁定装甲单位，伤害为 原版多目标飞弹伤害（对装甲单位伤害为 350，对非装甲单位伤害为 250）

主武器：远征XO16

核心：爆发核心（核心启动后读条时间 5.5 -> 8）

### 野兽

启用：北极星，携带至尊涂装

血量：10000（4格）

左栏位：远征涡旋防护罩

中栏位：悬浮

右栏位：多目标飞弹[^7]

主武器：四段火箭（弹匣容量 20 -> 16）

核心：飞行核心

### 野牛

启用：烈焰，携带至尊涂装

血量：12500（5格）

左栏位：隐身

中栏位：EMPSonar[^8]

[^8]:EMP声纳，落地后，等待一秒，开启三秒，伤害类型为EMP手雷，对装甲单位伤害为20 \* 8，对非装甲单位伤害为2 \* 8，当单位进入伤害范围内时，每0.3秒获得一次上述伤害，且离开该范围前将一直拥有被EMP手雷击中的屏幕特效和减速等效果

右栏位：激素（恢复速度为原版恢复速度 \* 3）

近战栏位：melee_titan_punch_fighter[^9]

[^9]:废稿武器，伤害改为2000每拳，范围为300，可按左键或F攻击

主武器：NULL（空）

核心：GroundSlam[^10]

[^10]:[DB][VoyageDB]大佬制作的核心，对非装甲单位伤害为500，对装甲单位伤害为2500，无衰减伤害范围 0-450  有衰减伤害范围 450-525  超过范围525外则无伤害，启动后立刻恢复激素的冷却，后提供一个根据视角朝向的大小为1200速度 + 高度轴的一个大小为-750的速度，执行烈焰的拍地动作

### 能核

启用：离子，携带至尊涂装

血量：10000（4格）

左栏位：自充能涡旋防护罩[^11]

[^11]:涡旋盾至少需要 剩余的能量 >= 100 才可以开启，当武器击中涡旋盾时，增加能量，计算公式为 近距离对装甲单位伤害 / 2500 = 要增加的百分比 如果要增加的百分比 <= 10% 那么用该计算公式: near_val / 1250 = 要增加的百分比

中栏位：EMPBomb[^12]

[^12]:EMP炸弹，启动后消耗能量，计算公式为 当前剩余能量 / 2，落地后，开启0.5秒，伤害类型为EMP手雷，对装甲单位伤害为 25 \* 8，对非装甲单位伤害为 1 \* 8，当单位进入伤害范围内时，每0.1秒获得一次上述伤害，且离开该范围前将一直拥有被EMP手雷击中的屏幕特效和减速等效果

右栏位：EMP射线[^13]

[^13]:表现为帝王的满级能量汲取，启动后消耗能量，计算公式为 当前剩余能量 / 2，冷却时间为 原版冷却时间 \* 2，击中敌方泰坦后，敌方泰坦获得一个2秒的致盲 + 正常能量汲取伤害，击中不给使用者加盾

主武器：核裂枪[^14]

[^14]:表现为离子的分裂枪，伤害为 原版分裂枪伤害 \* 2 （对非装甲单位 近距离 50 远距离 40  对装甲单位 近距离 160 远距离 120），非瞄准射击一发，消耗20能量，瞄准射击三发，消耗80能量，如果能量耗光，非瞄准每射击一次将消耗2发弹药，瞄准每射击一次将消耗6发弹药，不接受离子装备"折射镜片"和"缠结能量"

核心：冲刺核心

其他：消耗能量后需等待2.0秒后才会开始自行恢复（0.5 -> 2.0）

[RycXEpd]:https://github.com/RycXEpd
[VoyageDB]:https://github.com/DBmaoha
[cmggy]:https://github.com/cmggy
[Pan-da32767]:https://github.com/Pan-da32767
[zxcPandora]:https://github.com/zxcPandora
[DZ]:https://inchaos.icu/
[AnsonSkywalker]:https://github.com/AnsonSkywalker
[Wolf109909]:https://github.com/wolf109909

