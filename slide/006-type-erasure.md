% Type Easure
% 江添亮
% 2019-10-09

# タイプスレイヤー

+ AIEEE!
+ 型!?
+ 型ナンデ？

# 型殺すべし

+ 慈悲はない

# 実際ダルい

+ ユーザーからの入力を受ける
+ 様々な型で受ける
+ 簡単では？

~~~cpp
template < typename T >
auto get( )
{
    T x{} ;
    std::cin >> x ;
    return x ;
}
~~~

# ユーザーがポリモーフィック

+ ユーザーは様々な型を入力できる
+ どの型を入力するか事前に告げてくれる


~~~cpp
// アイエー！
// 型!? 型ナンデ？
??? get_user_input()
{
    switch( get<int>() )
    {
        case 0 :
            return get<int>() ;
        case 1 :
            return get<double>() ;
        ...
    }
}
~~~

# any

+ 合法です
+ ワザマエ！

~~~cpp
std::any get_user_input() ;
~~~

# 型は都市伝説

+ anyの存在が証明

~~~cpp
std::any x = 0 ;
x = 0.0 ;
x = "hello"s ;
~~~

# コピー

+ 当然できる

~~~cpp
std::any a = 0, b ;
b = a ;
~~~

# any_cast

+ 値を取り出す
+ リファレンス

~~~cpp
void f( std::any a )
{
    try {
        int value = std::any_cast<int>(a) ;
    } catch( std::bad_any_cast & e )
    {
        // 型が違った
    }
}
~~~

# ポインター

~~~cpp
void f( std::any a )
{
    int * ptr = std::any_cast<int>(&a) ;
    if ( ptr == nullptr )
        // 型が違った
}
~~~

# has_value

+ 値が入っているか調べる

~~~cpp
std::any a ;
// false
bool b = a.has_value() ;
a = b ;
// true
b = a.has_value() ;
~~~

# type

+ type_infoを返す

~~~cpp
std::any a = 0 ;
// true
a.type() == typeid(int) ;
a = 0.0 ;
// true
a.type() == typeid(double) ;
~~~

# anyの問題点

+ なんでも入る
+ あまりにも汎用的すぎる
+ 値のコピー程度しかできない
+ 使うときは型を指定しなければならない

# function

+ 関数呼び出しできる値しか入らない
+ 関数呼び出しできる
+ 型を指定しなくてよい

# 使い方

+ テンプレート実引数に関数型を指定
+ 戻り値と引数リストの型

~~~cpp
// intを引数にとりintを返す
std::funciton< int (int) > a ;
// int, intを引数にとりboolを返す
std::function< bool (int,int) > b ;
// 引数を取らず戻り値も返さない
std::function< void () > c ;
~~~

# 代入

~~~cpp
std::function<int(int)> func ;
int a(int) { return 0 ; }
func = &a ;
struct B { int operator(int) ; } b ;
func = b ;
func = [](int x){ return 0 ; } ;
~~~

# メンバー関数へのポインター

+ 第一引数がthis

~~~cpp
struct S { void f(int x) ; } ;

int main ()
{
    std::function<void(S *, int)> f = &S::f ;
    S s ;
    f( &s, 123 ) ;
}
~~~

# リファレンス

~~~cpp
std::function<void(S &, int)> f = &::f ;
S s ;
f( s, 123 ) ;
~~~

# データメンバーへのポインター

+ 関数呼び出しの結果
+ データメンバーへのアクセス

~~~cpp
struct S { int data ; } ;

int main ()
{
    std::function<int &(S &)> f = &S::data ;
    S s ;
    f(s) = 123 ;
    // 123
    std::cout << s.data ;
}
~~~

# variant
