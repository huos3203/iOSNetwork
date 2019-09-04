# iOSNetwork

### 使用Realm存储机制
[iOS网络模块优化（失败重发、缓存请求有网发送）](https://www.cnblogs.com/ziyi--caolu/p/8176331.html?utm_source=debugrun&utm_medium=referral)

![](弱网拍照优化方案.png)

### 使用FFDB存储机制

![](iTBoyer.util.tryNetwork/ORM/classUML.png)

### 暂存组件遇到的封装问题
1. 耦合: 没有充分封装业务层model类,在开发中图便利,业务和组件之间的类过度耦合.
在设计之初,应该考虑,需要暂存哪些属性,怎么从原model中拆解出来一个基类,用基类和暂存组件来交互.
这样,就能很好的隔离业务层model多余的属性,从而实现结偶, 提高暂存组件的复用性.

