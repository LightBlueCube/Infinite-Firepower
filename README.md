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

ai刷新 \* ( 5 / 3 )，ai装甲伤害和伤害取near_val[^2] \* 2，视力取战役ai

[^2]:在配置文件里，武器在近距离对非装甲单位所造成的伤害叫"damage_near_value"，我在这里简称它为"near_val"

所有泰坦都拥有边境血量（仅血量，其余不动）

一代训牛术[^3]（伤害取near_val \* 25[^4])

[^3]:一代训牛部分由[DB][VoyageDB]大佬修复并完善，快谢谢他
[^4]:充能步枪伤害为near_val \* 50 快充伤害为2500  EVA-8和敖犬为near_val \* 6.25  莫三比克伤害为near_val \* 12.5  智障手枪伤害为1250

绿电池回血2格 + 满盾，黄电池回血1格 + 满盾（黄电池无法将泰坦从毁减状态拉出）

强化里的应急电池给的是黄电池，其余电池获取方式给的都是绿电池（除了捡起黄电池）

当玩家一命击杀20人时，会获得Alpha核弹，启动后倒计时20秒，启动方队伍无条件胜利并结束游戏

### 一代训牛术的逻辑

当泰坦落地时，默认电池仓内有电池

当电池被拔出时，电池仓内无电池

当队友给友方泰坦一个电池时，电池仓内有电池

----

当铁驭训牛敌方泰坦时，如果电池仓内有电池，拔出电池后立刻掏枪[^5]

[^5]:如果此时铁驭身上已有电池，那么新拔出的电池将会掉落至地上

当铁驭训牛敌方泰坦时，如果电池仓内无电池，立刻掏枪

当泰坦死亡且电池仓内有电池时 40%掉落黄电池 4%掉落绿电池 56%不掉落

### 亿些平衡性修改

当玩家训牛中途跳机时，获得的离机速度增加[^6]

[^6]:获得一个方向为视角正后方的一个大小为400的没有高度速度的速度 + 一个方向为跳离时按住的方向键的方向的一个大小为200的速度（如果跳离时没按则不给这个速度） + 一个方向为固定朝上的一个大小为400的速度

MK5智障手枪对非装甲单位伤害 40 -> 20  射击模式 semi -> auto

军团智障核心开启期间，对非装甲单位造成的伤害 \* 0.1，对装甲单位造成的伤害为 原版伤害 \* 1.5

帝王装备"能量盗取"处决获得的电池只加1格血 + 满盾

帝王主武器伤害  近距离 120 -> 80  远距离 100 -> 70

帝王涡旋升级电烟对装甲单位dps 1350 -> 650  对非装甲单位dps 90 -> 45

浪人剑核心持续时间 12 -> 6

离子镭射核心所有伤害 325 -> 300  持续时间 4.5 -> 5.0

离子拥有边境升级"能量恢复"

强力弹群核心对装甲单位伤害 140 -> 120

飞行核心对单位伤害 300 -> 200  溅射对非装甲单位伤害 55 -> 35  溅射对装甲单位伤害 300 -> 200

火焰核心对装甲单位伤害 4500 -> 3500  对非装甲单位伤害 300 -> 200

## 新的泰坦！

### 远征

启用：帝王，携带"帝王边境"涂装

血量：10000（4格）

左栏位：远征涡旋防护罩

中栏位：远征电烟

右栏位：帝王导弹（单次射击数量 6 -> 12）

主武器：远征XO16

核心：爆发核心（核心启动后读条结束时间 5.5 -> 8  防止读条提前结束但是效果没结束导致的一堆bug）

### 野兽

启用：北极星，携带至尊涂装

左栏位：远征涡旋防护罩

中栏位：悬浮

右栏位：帝王导弹（单次射击数量 6 -> 12）

主武器：四段火箭（弹匣容量 20 -> 16）

核心：飞行核心

### 野牛

启用：烈焰，携带至尊涂装

血量：15000（6格）

左栏位：EMPSonar[^7]

[^7]:EMP声纳，落地后，等待一秒，开启三秒，伤害类型为EMP手雷，对装甲单位伤害为20 \* 8，对非装甲单位伤害为2 \* 8，当单位进入伤害范围内时，每0.3秒获得一次上述伤害，且离开该范围前将一直拥有被EMP手雷击中的屏幕特效和减速等效果

中栏位：NULL（空）

右栏位：激素（恢复速度为原版恢复速度 \* 3，使用速度为原版使用速度 \* 1.5）

近战栏位：melee_titan_punch_fighter[^8]

[^8]:废稿武器，伤害改为2500每拳，范围为300，可按左键或F攻击

主武器：NULL（空）

核心：GroundSlam[^9]

[^9]:[DB][VoyageDB]大佬制作的核心(谢谢你!)，对非装甲单位伤害为500，对装甲单位伤害为3500，无衰减伤害范围 0-450  有衰减伤害范围 450-525  超过范围525外则无伤害，启动后立刻恢复激素的冷却，后提供一个根据视角朝向的大小为1200速度 + 高度轴的一个大小为-750的速度，执行烈焰的拍地动作

### 能核

启用：离子，携带至尊涂装

血量：10000（4格）

左栏位：自充能涡旋防护罩[^10]

[^10]:涡旋盾至少需要100剩余的能量才可以开启，当武器击中涡旋盾时，增加能量，计算公式为 武器对装甲单位伤害 / 2500 = 要增加的百分比

中栏位：EMPBomb[^11]

[^11]:EMP炸弹，启动后消耗能量，计算公式为 当前剩余能量 / 2，落地后，开启0.7秒，伤害类型为EMP手雷，对装甲单位伤害为20 \* 16，对非装甲单位伤害为2 \* 16，当单位进入伤害范围内时，每0.3秒获得一次上述伤害，且离开该范围前将一直拥有被EMP手雷击中的屏幕特效和减速等效果

右栏位：闪光弹[^12]

[^12]:表现为帝王的满级能量汲取，启动后消耗能量，计算公式为 当前剩余能量 / 2，冷却时间为 原版冷却时间 \* 2，击中地方泰坦后，敌方泰坦获得一个2秒的全白 + 正常能量汲取伤害，击中不给使用者加盾

主武器：核裂枪[^13]

[^13]:表现为离子的分裂枪，非瞄准射击一发，消耗30能量，瞄准射击三发，消耗60能量，伤害为 原版伤害 \* 1.8，如果能量耗光，非瞄准每射击一次将消耗3发弹药，瞄准每射击一次将消耗6发弹药

核心：冲刺核心

[RycXEpd]:https://github.com/RycXEpd
[VoyageDB]:https://github.com/DBmaoha
[cmggy]:https://github.com/cmggy
[Pan-da32767]:https://github.com/Pan-da32767
[zxcPandora]:https://github.com/zxcPandora
[DZ]:https://inchaos.icu/
[AnsonSkywalker]:https://github.com/AnsonSkywalker
[Wolf109909]:https://github.com/wolf109909

