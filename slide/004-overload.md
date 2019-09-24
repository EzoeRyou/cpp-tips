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

# floating-point promotion

+ floatからdobule
+ 安全

# integral conversions

+ 整数型から整数型への変換
+ 危険

# floating-point conversions

+ 浮動小数点数型から浮動小数点数型への変換
+ 危険

# floating-integral conversions

+ 浮動小数点数型から整数型への変換
+ 整数型から浮動小数点数型への変換
+ 危険

# pointer conversions

+ nullポインター定数を任意のポインター型に変換
+ ポインター型をvoid *型に変換
+ クラスへのポインター型から基本クラスへのポインター型への変換

~~~cpp
struct B { } ;
struct D : B { } ;
D d ;
B * p = &d ;
~~~

# pointer-to-member conversions

+ nullポインター定数をメンバーへのポインター型に変換
+ 基本クラスのメンバーへのポインター型からクラスのメンバーへのポインター型への変換

~~~cpp
struct B { int x ; } ;
struct D : B { } ;
int D::* p = &B::x ;
~~~

# function pointer conversions

+ noexcept関数へのポインターを関数へのポインターに変換

# boolean conversion

+ boolへの変換
+ 数値
+ unscoped enum
+ ポインター
+ メンバーへのポインター

# falseの値

+ ゼロ値
+ nullポインター値
+ nullメンバーポインター値

# trueの値

+ false以外

# ユーザー定義変換

+ クラス型から別の型への変換
+ 別の型からクラス型への変換

# コンストラクターによる変換

+ 変換コンストラクター
+ explicitではない

# 例

~~~cpp
struct S
{
    S( int ) ;
    S( double, int = 0 ) ;
    S( int, int ) ;
} ;
~~~

# 変換例

~~~cpp
S a = 1 ;
S b = 0.0 ;
S c = {1,2} ;
~~~

# 変換関数

+ メンバー関数
+ 仮引数なし
+ 名前が`operator 型名`

# 例

~~~cpp
struct S
{
    operator int() ;
} ;

S s ;
int x = s ;
~~~

# <F9>

# 関数のオーバーロード


+ 関数名が同じ
+ 引数リストが違う
+ 複数の関数が共存できる

# 例

~~~cpp
void f( int ) ;
void f( double ) ;

int main()
{
    f(0) ;      // int
    f(0.0) ;    // double
}
~~~

# 問題

+ 名前は同じ
+ シグネチャは異なる
+ どうやって選ぶのか？

# 概要

+ 候補関数を列挙
+ 呼び出し可能な関数を絞り込む
+ 最適な関数を1つ選ぶ

# 候補関数を列挙

+ 大きく分けて7種類

# 関数呼び出し文法

~~~cpp
f( 0 ) ;
f( 0.0 ) ;
f( "0"sv ) ;
~~~

# 名前付き関数を呼ぶ

~~~cpp
void f( int ) ;
void f( double ) ;
void f( string_view ) ;
~~~

# 候補関数

+ 関数名を名前検索
+ 名前検索の規則に注意
+ qualified lookup
+ unqualified lookup
+ ADL

# クラス型のオブジェクトの呼び出し

~~~cpp
struct F
{
    void operator()(int) ;
    void operator()(double) ;
    void operator())(string_view) ;
} ;

F f ;
~~~

# 候補関数

+ クラスから`operator()`を名前検索

# 式中の演算子

~~~cpp
X x ;

x + x ;
X + 1 ;
X + 0.0 ;
~~~

# 候補関数

+ メンバー候補
+ 非メンバー候補
+ ビルトイン候補
+ rewritten candidates

# rewritten candidates

+ `operator <=>`から生成される演算子のこと

~~~cpp
struct S
{
    strong_ordering operator <=>( S const & ) const ;
} ;

S a, b ;
a < b ;
~~~

# コンストラクターによる初期化

+ 返還コストラクターを列挙

~~~cpp
struct S
{
    S(int) ;
    S(double) ;
} ;

S a = 0 ;
S b = 0.0 ;
~~~

# ユーザー定義変換によるクラスのコピー初期化

+ 変換関数が候補

~~~cpp
struct A { } ;

struct B
{
    operator A(){ return A() ; }
} ;

B b ;
A a = b ;
~~~

# 直接リファレンス初期化のための変換関数による初期化

+ 変換関数が候補

~~~cpp
A && a = b ;
~~~

# リスト初期化による初期化

~~~cpp
struct S
{
    S( double, double ) ;
    S( std::initializer_list<int> ) ;
} ;

S a = {0.0, 1.0} ;
S b = {1,2,3} ;
~~~

# 候補関数(初回)

+ 初期化リストコンストラクター

# 候補関数(2回目)

+ 初期化リストコンストラクターが呼び出し可能ではない場合
+ コンストラクター

# viable functions

+ 呼び出し可能関数
+ 引数の数が一致
+ デフォルト実引数も考慮する
+ 仮引数の型に変換できる暗黙の標準変換が存在する

# best viable functions

+ 呼び出し関数のうち
+ 最も最適なひとつの関数
+ オーバーロード解決の結果
+ 最も最適な関数が複数存在するなら曖昧

# 最適

+ 複数の関数から最適なひとつの関数を決定する
+ 関数は大小比較可能でなければならない

# 
