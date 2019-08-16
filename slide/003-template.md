% テンプレート基礎
% 江添亮
% 2019-08-13

# 歴史

+ 1979年：Bjarneが博士号取得
+ 同年：C with Classes
+ 1983年：C++命名
+ 1986年：ホワイトペーパーにテンプレート
+ 1990年：テンプレート採用
+ 1991年：CFront 3.0でテンプレート実装

# 動機

コンテナーを作りたい

# int

~~~cpp
struct list
{
    struct node {
        node * next ;
        node * prev ;
        int value ;
    } ;
    node * first ;
    node * last ;
} ;
~~~

# double


~~~cpp
struct list
{
    struct node {
        node * next ;
        node * prev ;
        double value ;
    } ;
    node * first ;
    node * last ;
} ;
~~~

# 違い

+ 型だけ
+ 残りのコードはほぼ同じ
+ なんとかしたい

# なんとか

+ ひどい

~~~cpp
#define GEN_LIST(T) \
struct list\
{\
    struct node {\
        node * next ;\
        node * prev ;\
        T value ;
    } ;
    node * first ;
    node * last ;
} ;
~~~

# かんとか

+ 型安全？　なにそれ美味しいの？
+ しかも追加の動的メモリ確保

~~~cpp
struct list
{
    struct node {
        node * next ;
        node * prev ;
        void * value ;
    } ;
    node * first ;
    node * last ;
} ;
~~~

# 関数

+ 値を引数で取る
+ 戻り値を返す
+ 戻り値は引数に依存する

~~~cpp
int twice( int x )
{
    return x * 2 ;
}
~~~

# テンプレート

+ 型をテンプレート引数で取る
+ 実体化したコードとなる
+ コードは引数に依存する

~~~cpp
template < typename T >
struct list
{
    struct node {
        node * next ;
        node * prev ;
        T value ;
    } ;
    node * first ;
    node * last ;
} ;
~~~

# テンプレート宣言

+ 宣言をテンプレート化する
+ typename Tはテンプレート仮引数
+ Tは宣言の中で型として振る舞う
+ クラス、関数、変数、エイリアス宣言、コンセプト

~~~cpp
template < typename T >
    宣言
~~~

# クラス

~~~cpp
template < typename T >
sturct S
{
    T x ;
    T f() ;
} ;
~~~

# 関数

~~~cpp
template < typename T >
T twice( T x )
{
    return x * 2 ;
}
~~~

# 変数

~~~cpp
template < typename T >
T pi = static_cast<T>(3.141592) ;
~~~

# エイリアス宣言

~~~cpp
template < typename T >
using custom_vector = std::vector< T, custom_allocator > ;
~~~

# コンセプト

~~~cpp
tempalte < typename T >
concept has_swap = requires( T a, T b )
{
    a.swap(b) ;
} ;
~~~

# 実体化

+ テンプレートは具体的なコードではない
+ 具体的なテンプレート実引数が与えられて初めて具体的なコードになる
+ 実体化という

# テンプレート実引数の与え方

+ tempalte-idにテンプレート実引数を指定
+ 実引数推定

# template-id

+ テンプレートの名前
+ クラス名、関数名、変数名、typedef名、コンセプト名

~~~cpp
template < typename T >
struct
template_id // これ
{ } ;
~~~

# 実引数の与え方

+ template-idに続いて\< \>で実引数を指定

~~~cpp
template_id<int>
template_id<double>
~~~

# 実引数推定

+ 関数呼び出し
+ テンプレート実引数を明示的に与えるのは面倒

~~~cpp
template < typename T >
T f(T x ){ return x }

f<int>(0) ;
f<double>(0.0) ;
int x{} ;
f<int>(x) ;
~~~

# コンパイラーは知っている

+ 関数の引数の型

~~~cpp
0 ; // これはint
0.0 ; // これはdouble
int x { } ;
x ; // これはint
~~~

# コンパイラーに頑張ってもらう

~~~cpp
// f<int>
f(0) ;
// f<double>
f(0) ;
// f<int>
f(x) ;
~~~

# 頑張れない例

+ 引数から推定が無理

~~~cpp
template < typename T >
T f( int x ) ;

// 無理
f( 0 ) ;
~~~

# クラステンプレートと実引数推定

+ 直接実引数推定できない
+ コンストラクターから実引数推定できる

~~~cpp
template < typename T >
class holder
{
    T value ;
public :
    holder( T const & init )
        : value( init ) { }
} ;

// holder<int>
holder x(0) ;
~~~

# ちょっと無理な例

+ 直接推定できない

~~~cpp
template < typename Tr >
class holder
{
    std::vector<T> values ;
public :
    template < typename Iterator >
    holder( Iterator first, Iterator last )
        values( first, last ) { }
}
~~~

# レンジ版

~~~cpp
template < typename Tr >
class holder
{
    std::vector<T> values ;
public :
    // abbreviated function template
    holder( std::ranges::input_iterator auto first,
            std::ranges::input_iterator auto last )
        values( first, last ) { }
}
~~~

# 推定ガイド

+ 推定のヒントを与える

~~~cpp
template < typename Iterator >
holder( Iterator, Iterator ) -> holder< std::iter_value_t<Iteraotr> > ;
~~~

# すると

+ 推定ガイドに従って推定してくれる

~~~cpp
std::array a = {1,2,3} ;

holder( std::begin(a), std::end(a) ) ;
~~~

# レンジ版


~~~cpp
std::array a = {1,2,3} ;

holder( std::ranges::begin(a), std::ranges::end(a) ) ;
~~~

# 実装

+ テンプレートのアイディアは1986年
+ 規格採用は1990年
+ 実装は1991年

# 実装が難しい

+ テンプレートコードはコードではない
+ テンプレート実引数が与えられて初めて意味が判明する

# CFront 3.0

+ 最初にテンプレートを実装
+ Bjarne Stroustrup謹製

# 戦略

1. 実体化せずコンパイル
2. リンカーのエラーメッセージをパース
3. 実体化の必要な特殊化を把握
4. 実体化生成
5. コンパイル
6. goto 2.

# なぜループ

+ 実体化の結果、別の実体化が必要になるため
+ A\<int\>を実体化するとB\<int\>が必要
~~~cpp
template < typename T >
struct A
{
    B<T> x ;
} ;
~~~

# 遅い

+ ある大学
+ 別の戦略で実装されたコンパイラーなら数時間かかるコード
+ CFrontでは一週間かかると報告

# 問題

+ テンプレートコードの翻訳単位
+ テンプレートを使う翻訳単位
+ 異なる
+ プログラム全体でテンプレート管理が必要

# Sun Microsystems

+ ビルドにDBを使用
+ テンプレートコードを発見したらDBに突っ込む
+ テンプレートの実体化の必要性を発見したら実体化してDBに突っ込む
+ リンク時にDBからオブジェクトコードを引っ張ってくる
+ そんなに早くなかった

# Borland

 おなじトークン列なら同じ意味
+ テンプレートコードはヘッダーファイルに書く
+ テンプレートが必要なすべての翻訳単位で\#include
+ 重複はリンカーが省く
+ 早い！

# 標準化委員会割れる

+ そんな実装認めていいのか！
+ ODR違反だ！
+ でも実装は簡単だ

# 妥協

+ もっと洗練された実装の余地も残そう
+ export可決
+ EDG反対
+ EDG実装
+ 誰も使わず

# 結果

+ みんなBorland方式で実装
+ export廃止

# 非型テンプレートパラメーター

~~~cpp
template < int N >
int f()
{
    return N ;
}

f<10>() ;
~~~

# プレイスホルダー

+ C++17から

~~~cpp
template < auto N >
struct S { } ;

// Nはint型の値
S<0> ;
// Nはlong型の値 
S<0L>
~~~

# 
