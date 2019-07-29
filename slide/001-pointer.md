% ポインター
% 江添亮
% 2019-07-29

# ポインター

江添亮

# 基礎

+ C++の多くの機能がポインターに依存している
+ ポインターの理解なくして他の機能の理解はできない


# 難しい理由

+ アドレス
+ 間接参照
+ 型システム
+ 文法


# 架空のマシン

以下のようなマシンを想定する

+ 8bitアドレス
+ フラットなアドレス空間
+ 255バイトのメモリ


# メモリ

+ 1バイト単位でアクセスできるメモリ
+ 255単位連続して並んでいる
+ 順序がある
+ 線形に並んでいる

# アドレス

+ 8bit
+ $2^8=256$ 通りの値を持つ
+ アドレス値pはある1バイトのメモリを指す
+ アドレス値p+nはnバイト先のメモリを指す
+ アドレス値p-nはバイト前のメモリを指す


# 生のアドレス

+ 任意の1バイトのメモリ箇所を表現
+ 現実の値は1バイトとは限らない
+ サイズが同じでも解釈は異なる
+ 整数型、浮動小数点数型、クラス
+ そこでどうするか

# ポインター型

+ サイズと解釈を型で表現
+ ある型へのポインター型

~~~cpp
// Tへのポインター型
T * ptr ;
~~~

# アクセス

+ operator &でポインターを得る
+ operator *で間接アクセスする

~~~cpp
int obj ;
int * ptr = &obj ;
*obj = 123 ;
~~~

# 演算

+ 加算、減算

~~~cpp
T mem[100] ;
auto p = &mem[50]
p + n ;
p - n ;
~~~

# このとき生のアドレスは

ポインターの参照する型のサイズ分加減算される

~~~cpp
char * char_ptr ;
char_ptr + 5 ; // sizeof(char) * 5バイトのアドレスを加算
int * int_ptr ;
int_ptr + 5 ; // sizeof(int) * 5バイトのアドレスを加算
~~~

# 比較

+ アドレスの比較
+ 大小比較と等価比較
+ 同じ配列内の同じ要素を指すポインターは等しい
+ 同じ配列内の順序に従った大小比較


# ポインターへのポインター

+ ポインターも型
+ ポインターは型に対するアドレスという型
+ ポインターへのポインター

~~~cpp
int obj ;
int * ptr = &obj ;
int ** pptr = &ptr ;

**ppptr = 123 ;
~~~

# 関数へのポインター

+ 関数にもポインターが存在する
+ 間接アクセスとして呼び出せる

# 使い方

~~~cpp
int func( int x ){ return x ; }

// 関数へのポインター
auto ptr = &func ;
// 間接アクセスによる呼び出し
(*ptr)(123) ;
// 便利なシンタックスシュガー
ptr(123) ;
~~~

# 型

戻り値の型Rで引数として型Aを取る関数の型

~~~cpp
R (A)
~~~

関数へのポインター型

~~~cpp
R (*)(A)
~~~

# 複雑な型

戻り値の型が関数へのポインター型で、引数として関数へのポインター型を取る関数へのポインター

~~~cpp
R1(*)( R2(*)(A2) )(A1)
~~~

# エイリアス宣言

~~~cpp
using return_type = R1(A1) ;
using parameter_type = R2(A2) ;
using function_type = return_type *( parameter_type * ) ;
using function_ptr_type = function_type * ;
~~~

# auto/decltype

~~~cpp
// 地獄から着た同僚の書いた関数
R1 func( R2(*)(A2) )(A1) ;

auto ptr = &func ;
using func_type = decltype(&func) ;
func_type = &func ;
~~~

# nullポインター

+ 有効な値を指していないポインター値

# NULL

+ C言語が導入
+ プリプロセッサーマクロ
+ nullポインター値として使えるトークン列に変換される

# 0

+ C++が導入
+ nullポインターリテラル
+ nullポインターの生のアドレス値が0という意味ではない

# nullptr

+ C++11が導入
+ nullポインターリテラル


# std::nullptr_t

+ nullポインター値しか妥当な値を持たないポインター型

~~~cpp
using nullptr_t = decltype(nullptr) ;
~~~

# unique_ptr

+ RAIIで自動delete

~~~cpp
auto ptr = std::make_unique<T>(...) ;
~~~

# 特徴

+ コピーできない
+ ムーブできる

# shared_ptr

+ 自動delete
+ リファレンスカウント
+ コピーできる

~~~cpp
auto ptr = std::make_shared<T>(...) ;

# weak_ptr

+ 使うな


# 変遷

+ void *
+ メンバーへのポインター
+ nullポインターリテラルとしての0
+ nullptr
+ 用語デリファレンスの廃止

# void *

+ 純粋なアドレス値を表現する型
+ 任意のポインター型から暗黙に変換できる
+ 任意のポインター型に明示的に変換できる
+ ポインター値をvoid *に変換して元の型のポインター値にもどすと同じポインター値になる
+ void *以前、mallocはchar *を返していた

# 例

~~~cpp
int * p1 = ... ;
void * p2 = p1 ;
int * p3 = static_cast<int *>(p2) ;
p1 == p3 ; // true
~~~

# メンバーへのポインター

2種類

+ メンバー関数へのポインター
+ データメンバーへのポインター

# 使い方

組み合わせて使う

+ メンバーへのポインター
+ クラスのオブジェクト

# 型

クラスCの型Tのメンバーへのポインター型

~~~cpp
T C::*
~~~

# ポインターを得る方法

クラスCのメンバー名memberへのポインターを得る

~~~cpp
&C::member
~~~

# 間接アクセス

クラスのオブジェクトobjectにメンバーへのポインターmem_ptrを使ってメンバーへの間接アクセス

~~~cpp
(object.*mem_ptr)
~~~

クラスへのポインターptrにメンバーへのポインターmem_ptrを使ってメンバーへの間接アクセス

~~~cpp
(ptr->*mem_ptr)
~~~

# データメンバーの例

~~~cpp
struct C { int member ; } ;
int C::* mem_ptr = &C::member ;
C object ;
// データメンバーへのアクセス
(object.*mem_ptr) = 123 ;
~~~

# メンバー関数の例

~~~cpp
struct C{ void member() {} } ;
void (C::* mem_ptr)() = &C::member ;
C object ;
// メンバー関数呼び出し
(object.*mem_ptr)() ;
~~~

# 詳細

+ データメンバーへのポインターはアドレスではない
+ オフセット
+ メンバー関数へのポインターはアドレス



# 用語

+ ポインターを経由した間接アクセス
+ indirection through a pointer

かつてはデリファレンス(dereference)という用語が使われていた

最近の規格改定で用語が統一された

