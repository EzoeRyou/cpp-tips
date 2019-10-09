% 派生
% 江添亮
% 2019-09-30

# 細目

+ 派生と継承
+ RTTI
+ type erasure
+ expression templates

# クラスがある

~~~cpp
struct A
{
    int data_member ;
    void member_function() ;
} ;
~~~

# データメンバーに持つ

+ B has-a A

~~~cpp
struct B
{
    A a ;
} ;
~~~

# メンバー経由で使う

~~~cpp
B b ;
b.a.data_member = 0 ;
b.a.member_function() ;
~~~

# 派生(derivation)

+ B is-a A
+ B derives from A
+ A is a base class of B
+ シンタックスシュガー

~~~cpp
struct B : A
{ } ;
~~~

# is-a

+ クラスは基本クラスである
+ ポインターを変換できる
+ リファレンスを変換できる

~~~cpp
B b ;
A * p = &b ;
A & r = b ;
~~~

# 継承(inheritance)

+ 基本クラスのメンバーを派生クラスが受け継ぐ

~~~cpp
B b ;
b.data_member = 0 ;
b.member_function() ;
~~~

# 派生 vs 継承

+ 派生は基本クラスと派生クラスの関係のこと
+ 継承は基本クラスのメンバーを受け継ぐこと

# super/sub

+ 基本クラスはスーパークラス
+ 派生クラスはsubクラス
+ C++では使わない用語
+ Bjarneが覚えられなかったから
+ base/derivedになった

# hidingおさらい

+ スコープの内側の名前は
+ 外側の同名を隠す

~~~cpp
int name ;
void f()
{
    int name{} ;
    // 関数fのローカル変数name
    name = 0 ;
}
~~~

# クラススコープ

+ クラスもスコープ

~~~cpp
// グローバル名前空間スコープ
class S
{
// クラスSのスコープ
} ;
~~~

# クラスのhiding

~~~cpp
struct A { int name ; } ;
struct B : A { } ;
B b ;
// B::name
b.name = 0 ;
~~~

# 基本クラスの名前の参照方法

+ qualified nameを使う

~~~cpp
b.A::name = 0 ;
~~~

# メンバー関数とhiding

+ メンバー関数名もhiding

~~~cpp
struct A { void name() ; } ;
struct B : A { void name() ; } ;
B b ;
// B::name
b.name() ;
~~~

# オーバーロード解決とhiding

+ 見つかった名前が候補関数
+ 見つからない名前は候補関数ではない
+ 候補関数でなければ選ばれることはない

~~~cpp
struct A { void name(int) ; } ;
struct B : A { void name(double) ; } ;
B b ;
// B::name
b.name(0) ;
~~~

# using宣言

+ 基本クラスの名前をスコープに持ち込む

~~~cpp
struct A { void name(int) ; }
struct B : A
{
    using A::name ;
    void name(double) ;
} ;

B b ;
// A::name
b.name(0) ;
// B::name
b.name(0.0) ;
~~~

# 継承されないコンストラクター

~~~cpp
struct A{ A(int) ; } ;
struct B : A { }
// エラー
B b(123) ;
~~~

# 継承コンストラクター

+ using宣言を使う

~~~cpp
struct A{ A(int) ; } ;
struct B : A
{
    using A::A ; 
} ;
// OK
B b(123) ;
~~~

# ポリモーフィズム

+ こういうクラスがある

~~~cpp
struct A { void f() ; }
struct B : A { void f() ; }
~~~

# 実行時型

+ こういう関数がある
+ A, Bどちらか戻り値
+ 実行時にしかわからない

~~~cpp
std::unique_ptr<A> get()
{
    bool b{} ;
    std::cin >> b ;
    if ( b )
        return std::make_unique<A>() ;
    else
        return std::make_unique<B>() ;
}
~~~

# 仕様例

~~~cpp
auto p = get() ;
p->f() ;
~~~

# 結果

+ A::fが呼ばれる
+ A *だから
+ 実行時の型に合わせたメンバー関数が呼ばれてほしい

# virtual関数

+ virtualキーワード
+ シグネチャが一致した派生クラスのメンバー関数は
+ 基本クラスのvirtual関数をオーバーライドする
+ 戻り値の型は少し特殊なルールがある

~~~cpp
struct A
{
    virtual void f() ;
} ;
struct B : A
{
    void f () ; // A::fをオーバーライド
}
~~~

# 蛇足

+ 派生クラスにもvirtualと書いていい
+ 書く必要はない

~~~cpp
struct B : A
{
    virtual f() ;
} ;
~~~

# 結果

`A *`, `A &`の参照先が

+ AならばA::fが呼ばれる
+ BならばB::fが呼ばれる

# シグネチャ違い

+ シグネチャが違う場合はオーバーライドされない

~~~cpp
struct A { virtual void func(int) ; } ;
struct B : A
{
    // シグネチャが違う
    void func(long) ; 
    void funk(int) ;
}
~~~

# override

+ オーバーライドを明示するキーワード
+ オーバーライドしていないとエラー

~~~cpp
struct B : A
{
    // OK
    void func(int) override ;
    // エラー
    void func(long) override ;
    void funk(int) override ;
}
~~~

# pure virtual関数

+ = 0をつける
+ abstractクラスになる

~~~cpp
struct abstract 
{
    void f() = 0 ;
} ;
~~~

# abstractクラス

+ オブジェクトを作れない

~~~cpp
// エラー
struct abstract object ;
~~~

# 脱abstract

+ pure virtual関数をオーバーライドする

~~~cpp
struct concrete : abstract
{
    void f() override { }
} ;
// オブジェクトを作れる
concrete object ;
~~~

# 多重継承

+ Multiple Inheritance
+ 複数の基本クラスを持つこと
+ 歴史的経緯で多重継承と呼ばれている

# 例

~~~cpp
struct A { } ;
struct B { } ;
struct C : A, B { } ;
~~~

# 例

~~~cpp
struct A { int x ; void f() ; } ;
struct B { int x ; void f() ; } ;
struct C : A, B { } ;

C c ;
C.A::x = 0 ;
C.B::f() ;
~~~

# 共通の基本クラス

+ Cにはcommonが2つある
+ A::common
+ B::common

~~~cpp
struct common { int x ; } ;
struct A : common { } ;
struct B : common { } ;
struct C : A, B { } ;
~~~

# 例

~~~cpp
C c ;
// C::A::common::x
c.A::x ;
// C::B::common::x
c.A::x ;
~~~

# virtual基本クラス

+ virtualキーワードを付けた基本クラス
+ クラスのオブジェクトにvirtual基本クラスはひとつしか存在しない

# 例

~~~cpp
struct common { int x ; } ;
struct A : virtual common { } ;
struct B : virtual common { } ;
struct C : A, B { } ;
C c ;
c.x ; // OK
~~~

# 派生クラスへの型変換

+ 基本クラスのポインターやリファレンスから
+ 派生クラスのポインターやリファレンスに変換できる
+ 自己責任

~~~cpp
struct A { } ;
struct B : A { int member ; } ;

void f( A * p )
{
    B * bp = static_cast<B *>(p) ;
    bp->member = 0 ;
    B & br = static_cast<B &>(*p) ;
    br.member = 0 ;
}
~~~

# 危険

+ 型が実行時にしかわからない場合

~~~cpp
void evil( bool random )
{
    if ( random )
    {
        A a ;
        f(&a) ;
    }
    else
    {
        B b ;
        f(&b) ;
    }
}
~~~

# 安全な変換

+ dynamic_cast
+ ポインターとリファレンスを変換する

~~~cpp
dynamic_cast<derived>(base) ;
~~~

# ポインターの場合

+ pがBを差しているのならば変換される
+ それ以外の場合はnullptr

~~~cpp
B * bp = dynamic_cast<B *>(p) ;
~~~

# リファレンスの場合

+ pがBを差しているのならば変換される
+ それ以外の場合はthrow std::bad_cast

~~~cpp
B & br = dynamic_cast<B &>(*p) ;
~~~

# 基本クラスの重複と変換

+ どちら側のオブジェクトなのか明示的にする

~~~cpp
struct A { } ;
struct B : A { } ;
struct C : A { } ;
struct D : B, C { } ;

D d ;
// D::B::A
A * ba = static_cast<A &>( static_cast<B &>(d) ) ;
// D::C::A
A * ca = static_cast<A &>( static_cast<B &>(d) ) ;
~~~


# RTTI

+ Run Time Type Information
+ 実行時に型情報を取得する


# 動機

~~~cpp
struct A { } ;
struct B : A { } ;
void f( A * p )
{
    // pが参照するオブジェクトの実行時型を知りたい
}
~~~

# typeid

+ 型情報を返す

~~~cpp
typeid(expression)
typeid(type-id)
~~~

# 例

~~~cpp
// intの型情報
typeid(0) ;
typeid(int) ;
~~~

# type_info

+ typeidを評価した結果の値の型
+ コピーできない
+ リファレンスで受ける
+ 寿命を気にする必要はない

~~~cpp
std::type_info & t = typeid(int) ;
decltype(auto) t = typeid(int) ;
~~~

# 比較

+ type_infoは同値比較できる。

~~~cpp
int x{} ;
bool b1 = typeid(x) == typeid(int) ;
bool b2 = typeid(x) != typeid(double) ;
~~~

# typed_index

+ type_infoのラッパー
+ コピーできる
+ 大小比較できる
+ ハッシュがとれる

# 例

~~~cpp
std::type_index ti = typeid(int) ;
std::vector< std::type_index > v ;
std::flat_map< std::type_index > fm ;
std::unordered_map< std::type_index > um ;
~~~

# 静的型と動的型

+ typeidの挙動が違う

# 静的型type_info

+ typeidはコンパイル時にtype_infoを決定する

~~~cpp
void f( Base & b )
{
    // 常にtrue
    bool b = typeid(b) == typeid(Base) ;
}
~~~

# 動的型type_info

+ typeidは実行時にtype_infoを決定する

~~~cpp
void f( Base & b )
{
    // falseになりうる
    bool b = typeid(b) == typeid(Base) ;
}
~~~

# 動的型

+ typeidに渡すクラスがポリモーフィック型

# ポリモーフィック型

+ virtual関数をもつクラス
+ virtual関数を継承するクラス

# 派生と継承の使い方

+ iostream
+ type_tratis
+ mixin
+ type erasure

# iostream

+ オブジェクト指向
+ 共通コードの再利用
+ 適当なグラフをググる

# コード再利用

+ 2Dゲームの画面上に表示するオブジェクト
+ 共通の操作を抜き出す

~~~cpp
struct object
{
    float x, y ;
    path image ;

    virtual void update() = 0 ;
    virtual void render() = 0 ;
    virtual bool interect_with( object & ) = 0 ;
} ;
~~~

# 実際のオブジェクト

+ objectを基本クラスに持つ

~~~cpp
struct tree : object ;
struct house : object ;
strcut enemy : object ;
~~~

# すると

+ 同じコードで処理

~~~cpp
std::vector< std::shared_ptr<object> > objects ;

for ( auto o : objects )
{
    o->update() ;
    o->render() ;
    if ( o->intersect_with(player) )
        ...
}
~~~


# type_tratis

+ ナイーブなis_pointerの実装

~~~cpp
template < typename T >
struct is_pointer
{ static constexpr bool value = false ; } ;
template < typename T >
struct is_pointer<T *>
{ static constexpr bool value = true ; } ;
~~~

# 本当の実装

+ boilarplate

~~~cpp
template < typename T >
struct is_pointer
{
    static constexpr bool value = false ;
    using value_type = bool ;
    using type = integral_constant<bool, false> ;
    constexpr operator bool() const noexcept { return false ; }
    constexpr bool operator()() const noexcept( return false ; }
} ;
~~~

# integral_constant

~~~cpp
template<class T, T v> 
struct integral_constant
{
    static constexpr T value = v;
    using value_type = T;
    using type = integral_constant<T, v>;
    constexpr operator value_type() const noexcept { return value; }
    constexpr value_type operator()() const noexcept { return value; }
} ;
~~~

# typedef名

~~~cpp
template<bool B>
using bool_constant = integral_constant<bool, B>;
using true_type = bool_constant<true>;
using false_type = bool_constant<false>;
~~~

# 実装

~~~cpp
template < typename T >
struct is_pointer       : std::false_type { } ;
template < typename T >
struct is_pointer<T *>  : std::true_type { } ;
~~~

# mixin

+ 基本クラスとして使うライブラリ
+ クラスに機能を追加する

# nested_exception

+ 例外が来た
+ やってきた例外をそのままに
+ 自分の例外も投げたい
+ 例外のネストがしたい

~~~cpp
void do_work()
{
    try {
        do_internal_work() ;
    } catch(...)
    {
        // キャッチした例外も投げたい
        throw std::logic_error("work failed.") ;
    }

}
~~~

# 方法

+ current_exceptionでexception_ptrを取得
+ 自前の例外クラスで保持
+ 自前の例外クラスを投げる
+ だるい

# neestd_exception

+ コンストラクターでcurrent_exceptionを呼び出す
+ exception_ptrを保持
+ rethrow_with_nestedで保持している例外を投げる

# ネストされた例外

+ decay_t<T>とnested_exceptionから多重派生したクラスをthrow

~~~cpp
template < typename T >
[[noreturn]] void throw_with_nested( T && t ) ;
~~~

# ネストされた例外の受け取り

~~~cpp
catch( std::exception & e )
{
    // 例外処理
    // ネストされた例外があれば投げる
    std::rethrow_if_nested(e) ;
}
~~~

# 実装

~~~cpp
template < typename E >
void rethrow_if_nested( const E & e )
{
    if constexpr (
        std::is_polymorphic_v<E> &&
        std::is_convertible_v< E, std::nested_exception > )
    {
        if ( auto p = dynamic_cast<const std::nested_exception *>( std::addressof(e) ) )
            p->rethrow_nested() ;
    }
}
~~~


