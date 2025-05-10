
关于此模组的介绍详见[这里](https://lightbluecube.github.io/ifpdocs/)

## 如果你是开发者请看以下信息

modify泰坦武器在/weapons

modify铁驭武器在/modify_weapons

泰坦替换和铁驭替换在/modify

连杀奖励在/killstreak，GUI也在里面

常用插件在/tcputil，有些插件有前置，大部分前置在/tcputil/shared

> <strong><font color="#dc3545">注意！</font></strong>在某些文件中定义了一些global struct或者global var，请保证定义这些东西的文件在json中的顺序要比使用这些东西的文件要靠前，否则编译器会报错undefined

在tcp_loadedinits.gnut内配置要开启的功能，默认全开

## 这个模组的拓展和插件

https://github.com/LightBlueCube/ifp-tempfix

用于让nessie-tempfix和ifp一起运行而不是爆炸螺旋起飞，请使用下方的nessie-tempfix

需要前置：

https://github.com/LightBlueCube/MixedGame/tree/nessie-tempfix

https://github.com/LightBlueCube/Infinite-Firepower

冲突：

https://github.com/LightBlueCube/ifp-fdpack
	
----                              

https://github.com/LightBlueCube/ifp-rotation

主要用于给其他冤种玩的PVP 5v5游戏模式，虽然也没多少人玩，我觉得挺好玩的

需要前置：

https://github.com/LightBlueCube/ifp-tempfix

https://github.com/LightBlueCube/MixedGame/tree/nessie-tempfix

https://github.com/LightBlueCube/Infinite-Firepower


冲突：

https://github.com/LightBlueCube/ifp-stable

https://github.com/LightBlueCube/ifp-fdpack

----

https://github.com/LightBlueCube/ifp-stable

已经废弃掉的最初的PVP游戏模式，基本上只是一个能让ifp能用的超级简单玩法包，好处是服务器会很稳定

需要前置：

https://github.com/LightBlueCube/Infinite-Firepower

冲突：

https://github.com/LightBlueCube/ifp-rotation

https://github.com/LightBlueCube/ifp-fdpack

----

https://github.com/LightBlueCube/ifp-fdpack

为边境防御增加了ifp的东西，以及包含一个ifp泰坦的神盾升级拓展，由于破坏性改动过多，不能和其他任何拓展一起使用

需要前置：

https://github.com/LightBlueCube/Northstar.FD

https://github.com/LightBlueCube/Infinite-Firepower


冲突：

https://github.com/LightBlueCube/ifp-rotation

https://github.com/LightBlueCube/ifp-stable

https://github.com/LightBlueCube/ifp-tempfix

https://github.com/LightBlueCube/MixedGame/tree/nessie-tempfix
