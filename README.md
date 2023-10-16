# (｡･∀･)ﾉﾞ

如需使用本仓库请遵循[GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)协议

# 代码建议别看，全是屎山（

本mod的编写原则是能跑就行，代码屎的不行，建议在任何时候最好只做个参照

如果你真的想尝尝屎的话，这里提供了4个func，可以按照自行需求搭配

```Squirrel
void function RandomMap_Init()    //对局结束后换图
void function TitanChange_Init()    //至尊泰坦替换，神盾血
void function DocsSystem_Init()    //文档系统
void function KillStreak_Init()    //连杀系统和GUI
void function TeamShuffle_Init()    //打乱队伍
```

----

有啥服务器的问题和bug反馈也可以发这

## 特别鸣谢（名字按首字母顺序排列）：

[cmggy](https://github.com/cmggy)

[D3-3109](https://github.com/D3-3109)

[DZ](https://github.com/Ghroth-follower)

[Pan-da32767](https://github.com/Pan-da32767)

[VoyageDB](https://github.com/DBmaoha)

[wolf109909](https://github.com/wolf109909)

[zxcPandora](https://github.com/zxcPandora)

## TLDR(太长不看)

开启一代训牛术，伤害通过算法平衡，所有武器（部分特殊武器另做平衡）拆泰坦的击杀时间都在1秒左右，泰坦脱战回盾

电池被拔出后若无友方铁驭补给电池（自己拿电池上机不行），则再次被训牛时敌方铁驭不需要拔电池直接掏枪

**在铁驭状态下按 泰坦辅助技能键（默认为G）（如果找不到可以去设置看按键对应）可以打开迷你菜单，可以在里面使用连杀或者丢弃电池**

每个泰坦选择至尊涂装都有一个对应的新的泰坦！（帝王为携带"帝王边境"皮肤）

## 以下为完整版文档

看完 TLDR(太长不看) 之后就可以回去玩了，如果你想深入了解的话可以接着往下看

### 无限火力都改了什么？

泰坦获取速度 \* 2，泰坦脱战回盾

所有泰坦都拥有边境血量（仅血量，其余不动，表现为血量 + 2500（一格））

开启一代训牛术，如果被训牛泰坦为黄血，则伤害减半

> 一代训牛部分由[DB](https://github.com/DBmaoha)大佬修复并完善
> 伤害通过算法平衡，所有武器（部分特殊武器另做平衡）拆泰坦的击杀时间都在1秒左右

训牛拔电池时不会打断隐身效果，训牛拔电池伤害无论如何都优先扣除盾的血量

撤离阶段可以复活，撤离艇血量 27000（10格 + 2000） -> 60000（24格）

在最后一分钟会根据双方分数差距进行分数获取加倍，冲冲冲！

**如果你不想每次都进服都要做那套烦人的操作来关掉黑屏和让你去看文档的红字，控制台输入sdf，下次进入服务器就不会再显示**

### 连杀奖励

当且仅当玩家一命击杀30名玩家时会获得聚变打击能力

每当玩家击杀6人（包括NPC泰坦）或一命击杀4人（包括NPC泰坦）时都会获得一个核武泰坦

每当玩家击杀20人（包括NPC泰坦）时会获得巡弋飞弹

**在铁驭状态下按 泰坦辅助技能键（默认为G）（如果找不到可以去设置看按键对应）可以打开迷你菜单，可以在里面使用连杀**

### 电池机制

绿电池回血1格 + 满盾，核心恢复80%

黄电池回血1格 + 满盾（黄电池可以将泰坦从毁减状态拉出），核心恢复40%

红电池回血0.5格 + 满盾，核心恢复20%（不是核武训牛术，别想了）

泰坦死亡时若有未被拔出的电池则会掉落一颗电池（10%概率为绿，90%概率为黄）

掉落电池后，若无人与其互动，60秒后会劣化为红电池，劣化后再过60秒会消失

**电池不仅可以在迷你菜单中选择丢弃，还可以在未打开菜单时直接长按 泰坦辅助技能键 来快速丢弃电池**

### 一代训牛术的逻辑

当被训牛时，敌方铁驭总是会拔出泰坦的电池

> 如果敌方铁驭已有电池，拔出来的电池会掉在地上

如果无友方铁驭补给电池（自己拿电池上机不行），则再次被训牛时敌方铁驭不需要拔电池直接掏枪

> 电池被拔出后，会在你泰坦的名字后显示"反應爐外漏"，所有人都能看到，小心行事！

### 亿些平衡性修改

#### 烈焰

火焰核心对装甲单位伤害 4500 -> 3500  对非装甲单位伤害 300 -> 200

#### 浪人

浪人剑核心开启时每当挥剑一次都减少3秒剩余时间

浪人装备"高地战士“时每挥剑一次只减少2秒剩余时间

浪人剑封减伤 70% -> 50%  核心期间剑封减伤 85% -> 70%

#### 军团

军团智障核心开启期间，仅锁定装甲单位

#### 帝王

帝王装备"逝者生存"黄血时血量为5000 吃到任何电池都会脱离黄血

帝王装备"防护罩放大器"能量吸收防护罩增大 25% -> 100% 并对友军恢复量也增加 100%

帝王装备"能量盗取"处决获得的电池只加20%核心

帝王升级顺序为先升级你选择的三个自定义升级，随后按照顺序一直升级到九级（已升级的直接跳到下一个升级）

帝王涡旋升级电烟对非装甲单位dps 90 -> 45

帝王主武器对装甲单位伤害 120 -> 100 远距离衰减后伤害 100 -> 80

帝王没有神盾血量升级，血量为10000（4格），如果升级了高级崽种那么血量为15000（6格）

#### 杂项

当玩家训牛中途跳机时，获得的离机速度增加

> 获得一个方向为跳离时按住的方向键的方向的一个大小为500的速度（如果跳离时没按则不给这个速度） + 一个方向为固定朝上的一个大小为400的速度

泰坦电烟最大持有量 4 -> 8

MK5智障手枪对非装甲单位伤害 40 -> 20  射击模式 semi -> auto

## 新的泰坦！

所有新泰坦均不支持任何自定配件，但支持自定被动


注2：一些名词解释：装甲单位指泰坦，死神，撤离艇这类大型实体，非装甲单位则指铁驭，步枪兵，幽灵战士，潜行者这一类的小型单位

### 远征

启用：帝王，携带"帝王边境"皮肤

血量：12500（5格）

左栏位：涡旋防护罩

中栏位：电子烟幕

右栏位：多目标飞弹

> 表现为战役里的多目标飞弹，除了不能锁非装甲单位外其余均与战役保持一致

主武器：XO16

核心: 爆发核心

### 野兽

启用：北极星，携带至尊涂装

血量：10000（4格）

左栏位：SP_涡旋防护罩

中栏位：SP_悬浮

右栏位：多目标飞弹

> 表现为战役里的多目标飞弹，除了不能锁非装甲单位外其余均与战役保持一致

主武器：SP_四段火箭

核心：SP_飞行核心

其他：野兽拥有北极星装备"毒蛇推进器"

### 野牛

启用：烈焰，携带至尊涂装

血量：12500（5格）

左栏位：跟随护盾

> 生成一个护盾，会跟着野牛走（略微有滞后）

中栏位：野牛突刺

> 按下后野牛将进行一次跳冲，可以冲两次，在地面冲刺时速度更快，在空中冲刺时跳的更高

右栏位：牵引飞弹

> 在一段较短锁定后发射，命中目标会轻微瘫痪目标并以非常大的速度拉向野牛

近战栏位：野牛拳

> 野牛拳可以对敌方泰坦造成巨额伤害

主武器：NULL（空）

核心：GroundSlam

> 在一个长冲刺后拍地并对周围泰坦造成可观的伤害（3500HP）

其他：野牛不会被卡拳，同样的，野牛也无法卡别人拳

### 执政官

启用：离子，携带至尊涂装

血量：10000（4格）

左栏位：被动式涡旋防护罩

> 此种涡旋防护罩接到子弹后会立刻反弹，在未收到攻击时消耗非常非常缓慢，但每收到一次攻击都会降低剩余时间

中栏位：陷阱电场

> 使用后快速布置一排电弧场，敌方泰坦穿越会受到可观的伤害和瘫痪效果

右栏位：投掷EMP火箭弹

> 发射一个带电弧场的火箭弹，被命中或是波及都会收到极大的伤害

主武器：電弧機砲

> 電弧機砲發射一道電光，連續攻擊多個目標。

核心：雷暴

> 朝视角前方释放3道伤害可观的电弧波，但是可以被任何盾挡住且不会扣除盾的血量或耐久

### 游侠

启用：浪人，携带至尊涂装

血量：7500（3格）

左栏位：剑封

> 剑封时移速极快（1.5倍），减伤50%，充能条耗尽后移速极低（0.4倍）

中栏位：电弧场

> 在泰坦周围形成一圈电弧场，会对非装甲单位造成非常可观的伤害，很适合反训牛

右栏位：同步EMP飞弹

> 锁定目标后发射，击中后对目标造成一定程度的瘫痪

近战栏位：浪人剑

主武器：三連環榴彈

> 三連環榴彈是同時發射三枚手榴彈的榴彈發射器。特別適用於淨空建築內部，而且榴彈一接觸裝甲即會爆炸，因此近距離對付其他泰坦非常有效。

核心：衝刺核心

> 啟用時衝刺不會耗盡。

### 天图

启用：强力，携带至尊涂装

血量：10000（4格）

左栏位：彩虹护盾

> 生成一个无敌的RGB泡泡护盾！

中栏位：线圈重载

> 使用后短时间内超载主武器线圈加速模块，使其射出的子弹变得更快，并利用子弹的升力构型抵消下坠

右栏位：标记射线

> 击中敌人后会短时间标记敌人，期间敌人受到任何伤害都是1.5倍

主武器：40cm机炮

> 超大的口径虽能造成极高的伤害，但也有着严重的下坠和过低的初速

核心：破壞核心

> 啟用時大幅提升武器殺傷力。

### 巨妖

启用：军团，携带至尊涂装

血量：12500（5格）

左栏位：穹顶护盾

> 生成一个跟着泰坦移动的穹顶护盾，有着不低的血量，但是冲刺会打破护盾，以及护盾能被近战快速破盾

中栏位：投掷型电子烟幕

> 这种电烟不仅可以扔出去，对泰坦的伤害还要比普通电烟高得多

右栏位：球状闪电

> 发射一个速度较慢的电球，电球造成伤害会恢复巨妖的护盾和血量，非常适合在一对多时使用

主武器：XO16

> 加装了加速器的XO16，当射速达到高峰时可造成非常可观的伤害，换弹速度和一代XO16保持一致（4.6s）

核心：弹容超载

> 开启后立刻给主武器增加150发子弹，且仅给主武器增加150发子弹，无任何额外效果，可叠加子弹


