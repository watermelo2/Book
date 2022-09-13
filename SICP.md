SICP

[(书评)Its the Best! Its the Worst! Why the split?](https://www.amazon.com/review/R403HR4VL71K8/ref=cm_cr_srp_d_rdp_perm?ie=UTF8)


```导包
#lang sicp
(#%require "lib.scm")
(sq 5)	
```

``` 定义&使用 函数
#lang sicp
(define (square x) (* x x))
(square 10)
```

```用lambda定义函数(lambda是关键字,用来"make a procedure")
#lang sicp
(define square (lambda (x) (* x x)))
(square 10)
```

```cond语法
((lambda (pick)
   (cond ((= pick 1) 37)
         ((= pick 2) 49)))
 1) 
```

```断路器语法
(if (= 1 1)
	1
    0
)

PS: 大致是这样,如果分支中是lambda的话需要加括号
```

数据的使用和表示分离开的意图是什么? 


TODO P12中的第二节课中的20分~35分??的stream需要再看看
TODO P13中的1:12~X的"矛盾y组合子"




最后一节课的最后一部分证明不存在一个能检测任意函数是否有死循环的算法解释:

> 这个问题等价图灵停机问题可以简单的证明如下: 假设存在一个函数bool check(code c,data d),可以对输入的code c在data d上进行判断，如果死循环则返回true，反之返回false，那么我们可以构造一个新函数

```
bool new_check(code c)
{
   if(check(c,c)) 
        return true;
   while(1);
   return false;
}
```
那么对于new_check(new_check)就会造成矛盾:如果new_check会死循环，则说明check(new_check)返回了false，说明new_check不会死循环如果new_check不会死循环，则说明check(new_check)返回了true，说明new_check会死循环

[参考链接](https://www.zhihu.com/question/33617297/answer/176820992)


























































































































































