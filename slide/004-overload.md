% オーバーロード
% 江添亮
% 2019-09-23

# お題

+ 標準変換
+ オーバーロード解決
+ テンプレートの実引数推定

# 標準変換

+ 暗黙の型変換
+ ある型の値に対して
+ 同じ値だが別の型に変換する
+ 人間の考える同じ値

# 例

~~~cpp
X x ;
Y y ;
x = y ;
~~~

# 例

~~~cpp
void f( X x ) ;

Y y ;
f( y ) ;
~~~

# lvalue-to-rvalue conversion

+ glvalueからprvalueへの変換
+ 名前が悪い
+ 名前から連想する変換ではない

# array-to-pointer conversion

+ 配列から先頭要素へのポインター

~~~cpp
int a[10] ;
// &a[0]
int * p = a ;
~~~

# function-to-pointer conversion

+ 関数から関数ポインター

~~~cpp
void f() ;
// &f
void (*p)() = f ;
~~~

# 注意

+ メンバー関数からメンバーへのポインターには変換されない

~~~cpp
struct S { void f() ; } ;
// エラー、&が必要
void (S::*p)() = S::f ;
~~~

# temporary materialization conversion

+ prvalueからxvalueへの変換
+ オーバーロード解決には使われない

~~~cpp
struct S{ int x ; } ;
int y = S().x ;
~~~

# qualification conversions

+ CV修飾子を追加する変換
+ `T`→`T const`
+ `T *`→`T const *`

# integral promotions

+ intより変換ランクの低い型を整数型をint型に変換
+ `char`→`int`
+ `short`→`int`
+ `int`で表現できなければ`unsigned int`に変換
+ 安全

# 
