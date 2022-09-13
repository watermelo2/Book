GFS、MapReduce、BigTable

Chubby    ==> ZooKeeper
GFS 	  ==> HDFS
BigTable  ==> HBase
MapReduce ==> Hadoop


## 前言

读论文(尤其是长的、需要记很多概念的)时的技巧:  https://paper-notes.zhjwpku.com/assets/pdfs/how-to-read-a-paper.pdf

## GFS 

https://kb.cnblogs.com/page/174130/、https://mr-dai.github.io/gfs/

客户端不缓存文件数据,但会缓存"元数据",直到客户端缓存信息过期或者文件被重新打开时才会重新从master那询问

chunckserver不需要缓存文件数据是因为chunk被存储为本地文件,Linux提供的OS层面的buffer缓存已经保存了频繁访问的文件

GFS将数据流的传输进行了针对网络拓扑的优化: 每个机器都会尝试推送数据到网络拓扑中最近的其他目标机器(用IP地址准确预估"距离")
在没有网络拥挤的情况下,传输B个字节到R个副本的理想耗时是B/T+RL,T是网络吞吐量,L是在机器间传输字节的延迟. 所以假如网络连接是典型
的100Mbps(T),L小于1ms,因此1MB数据流大约耗时80ms

master主要存储三种类型的元数据：文件和chunk的命名空间,从文件到chunk的映射,每个chunk副本的位置

四种状态: 一致、不一致、defined、undefined

GFS通过版本侦测机制踢除某个副本因为机器故障而执行异常的副本

GFS是按照标准的文件API来要求它自己的,所以标准文件API不提供的能力它也不提供. 比如: 当一个文件正在被写入时,它依然可以被另外一个线程读,
所以完全可能会存在读到没有写入完全的数据(标准文件API也不提供这个隔离的能力)

比较严谨的程序会使用各种方法来避免此问题,比如先写入临时文件,写入结束时才原子的重命名文件,此时才对读线程可见.
或者在写入过程中不断记录写入完成量,称之为checkpoint,读线程不会随意读文件的任何位置,它会判断checkpoint（哪个偏移之前的数据是写入完全的,也就是defined）,checkpoint甚至也可以像GFS一样做应用级别的checksum.这些措施都可以帮助reader只读取到defined区域

快照和备份的区别: 快照是数据存储的某一刻的状态(元数据)记录; 备份则是数据存储的某一时刻的副本.
理论上,某个地址的数据发生变化前做过快照的话,发生变化时会锁定物理单元不能改写.所以如果发生“最初数据不存在了”,意味着要么没做过快
照,要么快照机制已经被破坏了,自然就无法恢复了.

每当授予一个新的租赁给某个chunk,都会增长chunk版本号并通知各副本. master和这个副本都持久化记录新版本号. 这些都是在写操作被处理
之前就完成了.如果某个副本当前不可用,它的chunk版本号不会被更新.master可以侦测到此chunkserver有旧的副本,因为chunkserver重启
时会汇报它的chunk及其版本号信息.如果master看到一个比自己记录的还要高的版本号,它会认为自己在授予租赁时发生了故障,继而认为更高
的版本才是最新的.

GFS会在做快照的时候释放所有租赁,同时引入"命名空间锁"来保证并发的执行以及某些点的串行

GFS虽然看似是文件目录结构存储形式,但实际上完全不是. 它不会维护维护文件目录结构,以及没有inode信息要维护,不支持listFile,创建
/root/daxigua时也不需要申请/root的写锁(但会申请读锁)

为了防止死锁,一个操作必须按照顺序来申请锁: 首先按命名空间的层级顺序,在相同层级再按字典排序

当一个文件被删除时,master并不会立即打印删除操作的日志,然而不会立刻回收资源,仅仅将文件重命名为一个隐藏的名字,包含删除时间戳.
在master对文件系统命名空间执行常规扫描时,它会删除任何超过3天的隐藏文件（周期可配）.在那之前此隐藏文件仍然能够被读,
而且只需将它重命名回去就能恢复.当隐藏文件被删除时,它才在内存中元数据中被清除,高效的切断它到自己所有chunk的引用.

GFS、TFS、Haystack都是自己定义一个逻辑存储块,目的是为了将用户的数据转换为适应本系统的物理存储格式,同时也防止用户直接操作存储细节

普通Linux文件系统上,固定大小的文件+预分配空间+合理的文件总数量+合理的目录结构等等,往往是保证I/O性能的常用方案.
所以必须有个明确的逻辑存储单元.

GFS、Haystack中都有协调组件,它们的作者都希望能将其简化,原因是: 人如果有两个大脑那么很多事情会很麻烦. 
如果协调器有两个,那客户端听谁的、两个协调器信息是否需要同步、两个协调器在指定策略时是否有资源竞争. 
GFS的只有当元数据操作的日志已经成功flush到本地磁盘和所有master副本上才会认为其成功,master副本只参与	"备份"
GFS有Shadow Master(只读的),但只是作为容灾备用,不会在线参与协调,它读取的是master副本的操作日志

在存储时,Haystack的客户端直接面对所有存储组件(所有主备物理卷,分别手动写入),GFS的客户端只面对主DataServer

Haystack用"新增+删除"来模拟修改的,因为它需要承担图片的真实文件中的存储格式和检索等责任. 
而GFS把这些交给用户,所以如果用户将100KB的文件原地修改为一个101KB的文件,那么最后面那1KB文件就会破坏掉原先的数据

GFS的愿景是给用户提供一个无限容量、放心使用的硬盘,快速的存取文件,而不是特定于某种特殊场景(小文件或图片)

GFS为什么会有租赁机制而Haystack和TFS没有: 编程界面的问题. Haystack和TFS的客户端中面对的是一个图片,只需要将图片存到服务端然后返回
图片UUID就行了,其它副本存储成ABC、BAC、CBA、BCA都没有问题. 而GFS是按照文件系统来设计的,这种情况也就是之前所说的undefined问题

GFS的实现HDFS中的HA部分是基于Zookeeper实现的,一个Active节点,多个Standby节点,Active节点失败后所有Standby节点会竞争. 为了防止
"脑裂"问题,FailoverController会通知Standby节点强制下线之前断连的Active节点(可以配置脚本)

Q: GFS 是怎么确定最近的 Replica 的位置的？
A: 论文中有提到是基于备选服务器的IP来判断距离的,我判断是人为控制相近的IP(网段作为一个单位,IP作为一个单位,或者更新)实际位置相近.
   当然,"wifi探针"能实现更实际的"测距"功能,"AP工作模式"更是能返回连接者的MAC地址

## Face Book Haystack

http://web.archive.org/web/20190603070105/http://www.importnew.com/3292.html

架构范式: 元数据总控 + 分布式协调调度 + 分区存储

背景: 以前的存储图片的方案(基于NFS和NAS),需要提供每秒1 million图片的能力. 以前方案存在一个问题: 以前方案中因为元数据查询而导致
了过多的磁盘操作. Haystack竭尽全力的减少每个图片的元数据,让其能够全部在内存中处理有所元数据

为什么不构建成一个类似GFS的系统: Fack Book大部分用户数据都存储在Mysql数据库,文件存储主要用于开发工作、日志数据以及图片.
NAS设备其实为这些场景提供了性价比很好的方案. 此外,补充了hadoop以供海量日志数据处理. 面对图片服务的long tail问题(不常用图片突然
并发),Mysql、NAS、Hadoop都不太合适.  基于NAS的方案,一个图片对应一个文件,且每一个文件需要至少一个inode,这已经占了几百byte,无法将
所有inode都存到缓存中,所以需要一个定制系统.  

每个数据只会写入一次、读操作频繁、从不修改、很少删除
NFS很多元数据（比如文件权限）,是无用的而且浪费了很多存储容量
更大的性能消耗在于文件的元数据必须从磁盘读到内存来定位文件,访问元数据就是吞吐量瓶颈所在
即使是压缩了元数据,每个图片存储为一个文件还是会导致元数据过多,难以被缓存. 所以将多个图片存储在单个文件中,控制文件个数,维护大型文件
读取单个照片就需要好几个磁盘操作: 一个（有时候更多）转换文件名为inode number,另一个从磁盘上读取inode,最后一个读取文件本身
句柄打开文件 
hadoop以供海量日志数据处理   
基于NAS的方案,一个图片对应到一个文件,每个文件需要至少一个inode,这块需要的内存就很昂贵  Haystack的取舍是: 接受
long tail的磁盘IO这个现实,但会尽量减免除了真实访问图片数据之外的其它操作,并压缩文件系统元数据的空间,将所有元数据都放到内存中  
一个文件存储多个文件,个数可控  
Haystack在设计时是假设在没有CDN的环境   
http://<CDN>/<Cache>/<Machine id>/<Logical volume, Photo>  
大部分图片在上传之后很快就会被频繁访问 
内存中维护的数据结构[key: {needle.key,needle.alternate_key},value: {needle.flag,needle.data,needle.size,needle.offset}]
`needle.alternate_key`是图片副本的标识,我认为的实际数据结构: Map<long/*needle.key*/,Map<int/*alternate_key*/,Object>>


## MapReduce

https://zhuanlan.zhihu.com/p/122571315

用于离线批处理大规模的计算(函数)

该论文讲到: 如何利用大型集群来合理设计MapReduce模型、如何复用MapReduce任务、Master是单点,目前的做法是上传check point,但当前在
执行的任务还是会重新再执行一次、combiner函数提前做好部分reduce任务、、、

MapReduce的总结: 通过限制编程模型可以很容易进行并行和分布式计算; 网络带宽是一种很昂贵的资源; 

我的总结: 这篇是比较老的论文了,东西比较简单,从现在的各种产物来看MapReduce的概念已经不太适应大部分需求了,现在大家追求于实时计算
出结果. 因为看过《DDIA》,所以这边这篇论文就总结少一点,等到开始做《DDIA》的笔记时多写点,毕竟涉及到"流处理"、"流批处理"

附上一份Tiny MapReduce作业: https://gist.github.com/watermelo2/45650ac7598ab393b065aa0a62a53357

## BigTable

https://dblab.xmu.edu.cn/post/google-bigtable/、https://niceaz.com/2019/03/24/bigtable/

最初是为了用于Google Analytics

用来管理结构化数据的分布式存储系统

Bigtable将数据视为普通字符串(简单数据模型)且不关注其内容

Bigtable是一个稀疏的、分布式的、持久化的多维排序字典(map).该字典通过行键(row key)、列键(column)和时间戳(timestamp)索引,字典中的每个值都是字节数组`(row:string, column:string, time:int64) -> string`.  这是在调研了类BigTable系统的各种
潜在用途后决定采用的数据模型. 驱动做出部分设计决策的案例是: 假设我们想要持有一份可在很多项目中使用的大量web页面和相关信息的
副本,我们称这个副本构成的特殊的表为Webtable.

|             | contents:                                       | anchor:cnnsi.com | anchor:my.look.ca |
|-------------|-------------------------------------------------|------------------|-------------------|
| com.cnn.www | <html>... <- t3
<html>... <- t5
<html>... <- t6 | "CNN" <- t9      | "CNN.com" <- t8   |

上面的`contents`和`anchor`都是列族,并且`contents`列族中的数据都是经过反转的,这样可以使得"域名相同的网页被分组到连续的行中"从而被分配到临近的Tablet(针对表分区后的基本单位)中.

列族是访问控制（access control）的基本单位. 使用格式命名：列族名:限定符. 访问控制以及磁盘和内存统计都在列族级别执行

Bigtable中的单元格可以包含相同数据的不同版本,这些版本使用时间戳(64位)索引. 
在上面的例子中为“content：”列中存储的爬取到的页面设置的时间戳为：该版本的页面被爬取到的实际时间.垃圾回收机制允许我们仅保留每个页面的最近3个版本(可配)

Bigtable支持单行事务; 可以作为MapReduce的IO;

为了减少memtable的读写冲突(主要是读取memtable的冲突),采用了'copy-on-write'来允许读操作和写操作同时进行


## Spanner

http://dblab.xmu.edu.cn/post/google-spanner/#introduction

universe: 一份Spanner的部署
zone: 部署管理、物理隔离的单位.  一个zone有一个zonemaster和几百到几千个spanserver.前者为spannerserver分配数据,
后者向客户端提供数据服务.客户端使用每个zone的location proxy来定位给它分配的为其提供数据服务的spanserver.
universe master和placement driver目前是单例.universe master主要是一个控制台,其显示了所有zone的状态信息,以用来交互式调试.
placement driver分钟级地处理zone间的自动化迁移.placement driver定期与spanserver交互来查找需要移动的数据,以满足更新
后的副本约束或进行负载均衡

TrueTime使用两种形式的参考时间(原子钟,GPS),因为它们有不同的故障原因: GPS参考源的弱点有天线和接收器故障、本地无线电干扰、相关故
障（例如,如闰秒处理不正确的设计故障、和欺骗等）、和GPS系统停机.原子时钟可能会以与GPS和彼此不相关的方式发生故障,且在长时间后会
由于频繁错误而发生明显的漂移.

Spanner Tablet和BigTable Tablet区别在于: BigTable Tablet需要按顺序排序,而Spanner Tablet没有这个要求,它只想将多个被频繁访问
的目录整合到一起

BigTable在应用中的一些毛病: 
1. 缺少类似SQL的界面,缺少关系数据库拥有的丰富的功能
2. 只支持单行事务,缺少跨行事务
3. 需要在跨数据中心的多个副本间保持一致性
Percolator是为了解决BigTable跨行事务的问题(通过两阶段锁),但付出的代价(可用性和性能问题)过于昂贵

Spanner也是用两阶段锁来实现的,不同的是,Spanner会通过Paxos组来保存事务管理器的"状态",这样就不会在协调者出问题的时候所有参与者
锁死的问题

TrueTime系统的时间是经过投票得出来的(Marzullo算法探测和拒绝欺骗)

当前使用的时钟的漂移比率是200微妙/秒,Daemon的投票间隔是30秒,所以偏移会在0~6ms之间变化,加上time master的1ms延迟,所以是1~7ms之间
的变化

假如事务开始时TrueTime API返回的时间是{t1, ε1},此时真实时间在 t1-ε1到t1+ε1之间；事务结束时TrueTime API返回的时间是{t2,ε2},
此时真实时间在t2-ε2到t2+ε2之间.Spanner会在t1+ε1和t2-ε2之间选择一个时间点作为事务的时间戳(等到结束时间的最小值大于开始时间的最
大值),但这需要保证t1+ε1小于t2-ε2,为了保证这点,Spanner会在事务执行过程中等待,直到t2-ε2大于t1+ε1时才提交事务.由此可以推导出,
Spanner中一个事务至少需要2ε的时间才能完成

TrueTimeAPI的实现大体上类似于网络时间协议NTP,但只有两个层次.第一层次,服务器是拥有高精度计时设备的,每个机房若干台,大部分机器
都装备了GPS 接收器,剩下少数机器是为GPS系统全部失效的情况而准备的,叫做“末日”服务器,装备了原子钟.所有的Spanner服务器都属于第二
层,定期向多个第一层的时间服务器获取时间来校正本地时钟,先减去通信时间,再去除异常值,最后求交集

GPS: 保持模式15ns,非保持模式30ns

Spanner实现分布式事务主要思想是: 全局唯一的物理时间 + 所有机器等待到某一时间后再操作(读、写)

只读事务的处理: 如果scope的值是由单个Paxos组来提供的,最简单的情况下(没有prepare的事务)直接用Sread=LastTS()就够了.
如果scope的值是由多个Paxos组来提供的,在最复杂的情况下,需要由多个组的领导者来根据LastTS()协商得到Sread,Spanner当前实现了
一个更加简单的选择,可以避免这么多次沟通: 让读操作在Sread=LastTS()时刻去执行.

最后,将transaction management safe time由tablet的粒度细化到了row key range的粒度. 目的是为了在当事务卡在2PC过程中时,其它的
读请求能读到比较新的快照点 

## Chubby

https://storage.googleapis.com/pub-tools-public-publication-data/pdf/c64be13661eaea41dcc4fdd569be4858963b0bd3.pdf、
https://www.slideshare.net/romain_jacotin/the-google-chubby-lock-service-for-looselycoupled-distributed-systems

TODO 直接看Zookeeper

## Dremel

发明了一种列式方式存储嵌套数据的格式(数据结构)

http://web.archive.org/web/20190528113556/http://www.importnew.com/2617.html、
https://blog.twitter.com/engineering/en_us/a/2013/dremel-made-simple-with-parquet

## Raft

MIT 6.824: https://www.bilibili.com/video/BV1x7411M7Sf?p=22
https://github.com/maemual/raft-zh_cn/blob/master/raft-zh_cn.md
https://github.com/OneSizeFitsQuorum/raft-thesis-zh_cn/blob/master/raft-thesis-zh_cn.md
http://web.archive.org/web/20220602001243/https://niceaz.com/2018/11/03/raft-and-zab/
https://www.zhihu.com/question/19787937/answer/583245468

大多数选票的好处:
1. 两次"大多数"里面至少有一台服务器是两个term中共有(重叠)的. 体现就是上一个leader所获得的选票也有部分来自这次的投票服务器

Raft作为Replica系统的共识底层,通常的做法是上层将需要同步的Log给Raft,Raft同步给大多数Replica后给上层返回success,Replica
上层会读取Raftlog并处理成上层自己的数据. 

每次选举需要将term自增

Raft每个节点的状态一共有三种：leader,folower,candidate
1. 节点启动默认是folower状态,超时没有收到leader的心跳则变为candidate状态: 节点认为leader不可用了,需要自己竞选
2. candidate状态收到超过半数节点的投票则变为leader,收到leader的心跳变为folower
3.leader收到更高termleader的心跳变为folower.

基本的Raft协议一共用到了两种RPC,RequestVote RPC和AppendEntry RPC.RequestVote RPC主要用于Leader Election 的投票.
AppendEntry RPC用于Log Replication和Leader发送心跳

状态机: https://s2.loli.net/2022/06/02/1m4pQrhdZxgvVIw.png

候选人可能会从其他的服务器接收到声明它是领导人的Append Entry RPC.如果这个领导人的任期号（包含在此次的RPC中）
不小于候选人当前的任期号,那么候选人会承认领导人合法并回到跟随者状态. 如果此次RPC中的任期号比自己小,那么候选
人就会拒绝这次的RPC并且继续保持候选人状态

理想情况下,总有一个candidate会竞选到超过半数节点的票. 也有可能是候选人既没有赢得选举也没有输: 如果有多个跟随者同时成为候
选人,那么选票可能会被瓜分以至于没有候选人可以赢得大多数人的支持.当这种情况发生的时候,每一个候选人都会超时,然后通过增加
当前任期号来开始一轮新的选举.然而,没有其他机制的话,选票可能会被无限的重复瓜分.再为极端一点,两个节点同时超时,这时可能
产生分票行为,导致两个节点都没有收到超过半数节点的投票. Raft使用随机选举超时时间的方法来确保很少会发生选票瓜分的情况,就
算发生也能很快的解决.为了阻止选票起初就被瓜分,选举超时时间是从一个固定的区间（例如 150-300 毫秒）随机选择.这样可以把服
务器都分散开以至于在大多数情况下只有一个服务器会选举超时;然后他赢得选举并在其他服务器超时之前发送心跳包.同样的机制被用在
选票瓜分的情况下.每一个候选人在开始一次选举的时候会重置一个随机的选举超时时间,然后在超时时间内等待投票的结果;这样减少了
在新的选举中另外的选票瓜分的可能性.

election timeout的取值范围: broadcastTime(心跳间隔) < electionTimeout(选举超时时间) < MTBF(机器平均故障时间,很长)

分布式共识算法负责维护一系列的log,每个log包含一条命令,共识算法负责保证所有节点上的log序列完全一致.
这样就保证log apply到状态机的时候,状态机的状态是一致的. 每条log 包含一个index,一个term和一条 command.
由于每个term只有一个leader,因此Raft的log有一个特性是如果某个index处log的term一致,则该index 
处对应的command也一定是一致的.这个特性在日志复制的Log Match过程中会被应用到

Raft 的Log Replication主要依赖于AppendEntry RPC,它只能由Leader发.该 RPC 具体定义如下.该 RPC 能够保证log一致性的关键在于
Log Match 过程.每次 AppendEntry RPC 都包含两个重要的属性,prevLogIndex 和 prevLogTerm.记录了当前所复制日志
的前一条日志的index和term.接受者收到后,会匹配一下index 处的log的term是否一致: 
1. term一致则对应的command一定是一致的.并且可以推出在此次新增的数据之前的数据是一致的,那么就接收此次AppendEntry RPC
所携带的log.
2. term不一致则说明之前已经存在数据不一致,则拒绝此次RPC.发送者在收到拒绝后会向前搜索,直至找到第一个匹配成功的log,
并将此之后的log全部复制(Leader会一直记录follower的最近的且正确的log index).

上面的第二种情况发生的场景: 因为AppendEntry RPC分start、commit两步的,只有真正commit(Leader发送同步Log)才是真正确认要保留的Log.
所以如果没有commit(Leader对应的上游返回失败)这条消息,那么在下一条Log并且commit的时候就会出现这种情况

AppendEntry RPC规范: https://s2.loli.net/2022/06/02/Ni6hRzxUufraJ3C.png

Raft数据的安全性我们可以从两个角度理解:
1. 每个状态机以严格相同的顺序执行相同的command
2. 所有已经commit的Entry必须出现在未来的所有任期内
第一条规则已经通过AppendEntry RPC保证了,下面是如果保证第二条规则.

Log冲突示例: https://s2.loli.net/2022/06/02/JNnslW94cLGgvQp.png

如上所示,在网络分区的时候,依照上面的几条限制则有出现图中这种情况的可能. 假设leader此时down了,b节点率先election timeout,
此时,如果b节点得到了超过半数节点的投票当选leader,name显然红色虚线框内已经被commit的entry就丢失了.为了避免这种情况的出现,
必须加一条限制:
```
限制一: 节点 m 向节点 n 发送了 RequestVote RPC,如果节点 n 发现节点 m 的数据没有自己新,则节点 n拒绝节点 m 
的投票请求.这里的“新”包含两个方面: term更大的数据更新; term相同,index更大的数据更新;
```
加上这条限制之后,我们看到图中节点 b 最多只能拿到自己和节点 f 的投票,未超过半数,不能当选leader.

现在证明加上这条规则后就能保证`一条已经被 commit 的 entry 一定会出现在未来的term中`:
1. 对于一条已经被提交的logI,I一定被复制到了超过半数的节点上,记这个节点集合为Q1
2. 对于之后的一个leader L而言,L一定获得了超过半数节点的投票,记这个节点集合为Q2
3. 根据鸽笼原理,Q1和Q2两个集合至少存在一个交集,记这个交集节点为S
4. S既包含I同时又向L投了票,因此在"限制一"的限制下,L一定包含I

但有了"限制一"并不能满足"Raft数据安全性的第二条规则",举例:
1. a 时刻 S1 是leader复制了一条log到 S2 上
2. b 时刻 S1 down 掉 S5 当选leader
3. c 时刻 S5 down 掉 S1 成功当选leader,S1将之前 term2 的日志复制到了 S3 上,term2的日志已经超过半数.此时我们能将
term2 的日志标记为 commited 吗？

流程图,方便理解: https://s2.loli.net/2022/06/02/6XU4SknjN9Ly38d.png

如图所示. 假设我们将term2的日志标记为commited,如果此时S1down机S5可能当选leader,但是S5上没有term2的这条日志,就导致
这条被标记为 commited 的日志没有出现在未来的term中. 这最根本的原因是S1 在 term4当选leader 时,其他节点根本不知道
term4 的存在,导致term出现了倒退的现象,把 term4复制的日志给覆盖了.  所以加上了条限制:
```
限制二: 不直接提交之前term的log,必须通过提交本term的log,间接的提交之前term的log
```
这样S5就不可能当选leader,因为超过半数的节点已经知道term4的存在从而不会给 S5 投票.很多系统的实现中,都是在当选新
leader后,立马提交一个NOP Entry来满足这条限制的.


### 成员变更

多Leader问题图片: https://s2.loli.net/2022/06/02/UuvK4X7QYoZxwFJ.jpg
一次变更一个证明图片: https://s2.loli.net/2022/06/02/eOw1vVU4Xxn6mgH.jpg

成员变更分一次性变更一个成员和一次性变更多个成员(一次多个比较麻烦).

#### Leader通知成员变更步骤

Leader收到成员变更请求后，先向`C old`和`C new`同步一条`C old,new`日志，此后所有日志都需要`C old`和`C new`两个多数派的确认。
`C old,new`日志在`C old`和`C new`都达成多数派之后才能提交，此后Leader再向`C old`和`C new`同步一条只包含`C new`的日志，
此后日志只需要`C new`的多数派确认。`C new`日志只需要在`C new`达成多数派即可提交，此时成员变更完成，不在`C new`中的成员自动下线。

#### Leader宕机且一次多个

`C old,new`中任意一个节点都可能成为新Leader，如果新Leader上没有`C old,new`日志，则继续使用`C old`，Follower上如果有
`C old,new`日志会被新Leader截断，回退到`C old`，成员变更失败；如果新Leader上有`C old,new`日志，则继续将未完成的成员变更流程走完。

#### 一次一个

可以从数学上严格证明，只要每次只允许增加或删除一个成员，`C old`与`C new`不可能形成两个不相交的多数派。
因此只要每次只增加或删除一个成员，从`C old`可直接切换到`C new`，无需过渡成员配置，实现单步成员变更

注意: 新任Leader必须在当前Term提交一条日志之后，才允许同步成员变更日志。也即Leader在当前Term还未提交日志之前，
不允许同步成员变更日志。

Raft成员变更BUG: https://blog.openacid.com/distributed/raft-bug/

### 关于优化

1. 可以通过SNAPSHOT机制来合并Log,想避免与客户端请求冲突的话可以用Copy-On-Write
2. Pipeline & Batch & Async Flush
   2.1 Async Flush: 自己异步刷盘,然后让其它超过半数节点提交(非异步的话只需要半数就好了,因为会加上自己).
   2.2 Batch: AppendEntry RPC支持一次性复制多条日志,从而实现Batch. 实际上是攒够一批数据后一次性处理.
   2.3 Pipeline: 当前一条log的处理流程还没有结束的时候,就接收新的日志,从而提高日志数据处理效率.
   Pileline和Batch是完全用于不同场景的: Pipeline有助于较少请求的响应时间; Batch有助于整体的吞吐率.
3. Leaseleader:leader 为了优化每次去请求都去确认一下自己当前是不是真正的leader 也带来了很多开销,lease read将
   每次Leader确认自己是否是Leader时带上一个租期变量,folower 响应leader 的请求则需要保证在租期内,
   不给其他节点投票,从而保证租期内,不会有新leader 的产生. 
4. PreVote: 在集群发生网络分区时,网络分区的节点由于收不到leader 的心跳,term 会在不断的自增.当网络分区恢复时,
   由于leader 收到该节点RequestVote RPC 的请求,并发现其term比自身大,使得leader失去leader的身份,重新开始一轮选举,
   导致集群的抖动. Prevote机制是当一个节点 election timeout 时,他不会立即自增 term,而是与集群中节点进行一次通信,如
   果能收到超过半数节点的响应,才会自增 term.







