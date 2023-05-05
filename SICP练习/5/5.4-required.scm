#lang sicp

;; 最后两节一定要先记住这些
;; 如果看书上的那些文字没看懂,直接看MIT 6.001视频

;; 约定参数:
;; exp 用于存放被求值的表达式
;; env 包含了求值发生时需要用的环境,即变量绑定
;; val 存放求值结果
;; continue 在递归中用于标记调用成功后应该返回的位置
;; proc 在调用求值时,用于存放过程/操作符的求值结果
;; argl 用于存放实参列表的求值结果(原文: list of evaluated arguments)
;; unev 存放还没有被求值(unevaluated)的子表达式


;; 指令(5.1.5中有总结,5.2.2、5.2.3有它们的实现):
;; assign <x> <y> 将寄存器y的内容赋给x
;; reg <x> 获取寄存器中x的值
;; op <x> 执行操作(过程);   例子: `assign t (op rem) (reg a) (reg b)`将操作rem对寄存器a和b的内容算出的值赋给t
;; save x 将值放入堆栈
;; restore 从堆栈中恢复一个值
;; perform (op <operation name>) <input1> ... <inputn> 执行操作
  
;; operand vs operator
;; 例: 3 + 6 = 9; `+`是operator,`3`和`6`是operand

;; Contract that eval-dispatch fulfills
;; - 你想要求值的表达式就放在EXP寄存器中
;; - 求值所基于的环境存放在ENV寄存器中
;; - 当求值完成后机器需要去的地方放在CONTINUE寄存器中
;; - 求值的结果会放在VAL寄存器中(它不会对其他其它的寄存器做任何保证)

;; Contract thas apply-dispatch fulfills
;; - ARGL寄存器存放求值后的参数列表
;; - FUN寄存器存放着那个过程
;; - 当APPLY完成后机器应该跳转到的下一个地方是APPLY-DISPATCH被调用时的栈顶元素
;; - 过程执行完的结果会被存到VAL寄存器中. 栈会被弹出(popped)


;; eval-arg-loop: 将UENV中的值求出并存入ENV寄存器中


