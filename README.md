# (｡･∀･)ﾉﾞ

这里放的是无限火力的配置

当然，拿去开服也可以

有啥服务器的问题和bug反馈也可以发这

## 特别鸣谢（名字按首字母顺序排列）：

[cmggy][cmggy]

[DZ][DZ][^1]

[^1]:没找到DZ的GitHub账户，先用他个人主页代替

[Pan-da32767][Pan-da32767]

[RycXEpd][RycXEpd]

[VoyageDB][VoyageDB]

[zxcPandora][zxcPandora]

## 无限火力都改了什么？

泰坦获取速度\*4，泰坦核心获取速度\*4，泰坦脱战回盾

ai刷新\*2，ai伤害取near_var\*4，视力取战役ai

一代训牛术（伤害取near_var\*30)

绿电池回血2格+满盾，黄电池回血1格+满盾

强化里的应急电池给的是黄电池，其余电池获取方式给的都是绿电池（除了捡起黄电池）

### 亿些平衡性修改

MK5智障手枪 3发死 -> 5发死

普通电烟对铁驭dps上调

帝王电烟对泰坦dps下调+对铁驭dps下调（但还是比普通电烟对铁驭dps高）

军团智障核心锁定时间 0.5 -> 0.8

帝王装备"能量盗取"处决获得的电池只加1格血+满盾

帝王主武器伤害下调 120 -> 100

浪人剑核心伤害从2000下调至1800

----

### 更新日志

----

2022/10/28 18:00 

新增三个泰坦，分别为"野兽","野牛","SB-7274"

代码来源：VoyageDB的Super.Mixed.Game

#### 如何获取？

野兽：当泰坦为北极星且是至尊涂装时，替换泰坦武器和副手装备为野兽装备

野牛：当泰坦为烈焰且是至尊涂装时，替换泰坦武器和副手装备为野牛装备

SB-7274：当泰坦为帝王且拥有 "帝王边境" 涂装时，替换泰坦武器和副手装备和核心装备为远征装备

#### 野兽装备

左栏位：远征涡旋防护罩

右栏位：12发无锁定导弹

主武器：四段火箭

其他栏位保持不变

#### 野牛装备

左栏位：带burn的涡旋防护罩（子弹打到直接反弹，不能攒一起后释放）

中栏位：NULL（空）

右栏位：激素

主武器：NULL（空）

近战栏位：melee_titan_punch_fighter 拥有mod："berserker","allow_as_primary" 伤害：2500/拳

核心装备：野牛冲刺核心[^2]

[^2]:启动后近战伤害\*1.5，冲刺恢复速度加快

其他栏位保持不变

#### SB-7274

左栏位：远征涡旋防护罩

中栏位：电子烟雾

右栏位：12发无锁定导弹

主武器：xo16远征版本

核心装备：爆发核心

其他栏位保持不变

----

2022/10/29 14:10

#### 追加更新

新增电弧泰坦，当泰坦为浪人且拥有至尊涂装时，替换武器至电弧泰坦装备，绑定电弧效果到泰坦上

#### 电弧泰坦装备

左栏位：电弧波（恢复速度\*2)

中栏位：NULL（空）

右栏位：相位冲刺

主武器：天女散花（弹容只有一发）

核心装备：电弧冲刺核心[^3]

[^3]:启动后无限使用电弧波且电弧波伤害增加一倍，冲刺恢复速度加快

特殊栏位（可能不是栏位）:

绑定电弧效果至泰坦

对铁驭伤害为2

对泰坦伤害为160

tick为0.33

其他栏位保持不变

----

2022/11/2 13:15

#### 新增更多泰坦

分别为"监察者"，"壁垒"

当泰坦为离子且拥有至尊涂装时，替换为监察者

当泰坦为军团且拥有至尊涂装时，替换为壁垒

#### 监察者装备

左栏位：离子肩射炮

中栏位：悬浮（恢复速度\*4）

右栏位：12发无锁定火箭

核心装备：强力的弹群核心

其他栏位保持不变

#### 壁垒装备

左栏位：涡旋防护罩（当被击中时，增加剩余使用时间[^4]，只能在充能满80%以上时开启）

[^4]:计算公式为：（ 击中武器的near_var / 100 ）+ 剩余使用时间的百分比 = 击中后剩余使用时间的百分比

中栏位：NULL（空）

右栏位：帝王的能量汲取（拥有全部升级）

主武器：铝热剂发射器

核心装备：壁垒超载核心[^5]

[^5]:启动后冲刺恢复加快，涡旋防护罩变为无限使用，获得连发的铝热剂发射器（无限弹药）

其他栏位保持不变

----

2022/11/4 16:50

### 新增一个泰坦

弧光泰坦

当泰坦为强力且拥有至尊涂装时，替换为弧光泰坦

### 弧光泰坦装备

左栏位：带burn的涡旋防护罩（子弹打到直接反弹，不能攒一起后释放）

中栏位：NULL（空）

右栏位：北极星的集束飞弹

主武器：mp_weapon_turretlaser_mega_fort_war[^6]

[^6]:废稿武器，类似于大号滋崩，按下后开始蓄能，不能取消，蓄能需要3秒，蓄能完毕后击发，伤害为6000

核心装备：离子的镭射核心

其他栏位保持不变

[RycXEpd]:https://github.com/RycXEpd
[VoyageDB]:https://github.com/DBmaoha
[cmggy]:https://github.com/cmggy
[Pan-da32767]:https://github.com/Pan-da32767
[zxcPandora]:https://github.com/zxcPandora
[DZ]:https://inchaos.icu/
[Wolf109909]:https://github.com/wolf109909
[BobTheBob9]:https://github.com/bobthebob9
