% リファレンス
% 江添亮
% 2019-07-29

# リファレンス

江添亮

# 区分

+ lvalueリファレンス
+ rvalueリファレンス

# ポインター

+ 文法が面倒

~~~cpp
int obj ;
int * ptr = &obj ;
*ptr = 123 ;
~~~

# リファレンスなら

+ 簡単

~~~cpp
int obj ;
int & ref = obj ;
ref = 123 ;
~~~

# 共通点

+ 値を参照する

~~~cpp
int obj = 0 ;
int ref = obj ;
++ref ;
std::cout << obj ; // 1
~~~

# 特徴

+ 初期化が必要
+ nullリファレンスはない

~~~cpp
int & ref ; // エラー
~~~

# 値

+ 

~~~cpp
int f() ;
int x{} ;

f() ;
x ;
x + x ;
0 ;
~~~o

