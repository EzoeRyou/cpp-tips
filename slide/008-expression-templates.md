% Expression templates
% 江添亮
% 2019-10-24

# 概要

+ 式のキャプチャー
+ 遅延評価
+ DSL

# ベクトル計算

+ 複数の要素を持つ
+ 四則演算はそれぞれの要素ごとに演算

# 例

~~~cpp
struct vector
{
    double elem[1000] ;
    double & operator []( std::size_t i )
    { return elem[i] ; }

    vector & +=( vector const & other )
    {
        for ( std::size_t i = 0 ; i != 1000 ; ++i )
            *this[i] += other[i] ;
        return *this ;
    }
} ;

vector operator + ( vector const & a, vector const & b )
{
    auto temp = a ;
    temp += b ;
    return temp ;
}
~~~

# 使い方

~~~cpp
vector a, b, c, d ;

auto x = a + b + c + d ;
std::cout << x[100] ;
~~~

# 問題

+ 非効率的
+ コンパイラーはすべてを最適化できない

~~~cpp
temp0 = a ;
temp0 += b ;
temp1 = temp0 ;
temp1 += c ;
temp2 = temp1 ;
temp2 += d ;
auto x = temp2 ;
~~~

# ムーブセマンティクス

~~~cpp
vector operator +( vector && a, vector const & b )
{
    a += b ;
    return a ;
}
vector operator +( vector const & a, vector && b )
{
    b += a ;
    return b ;
}
vector operator +( vector && a, vector && b )
{
    a += b ;
    return a ;
}
~~~

# まだある問題

+ こっちのほうが速い

~~~cpp
double x = a[00] + b[100] + c[100] + d[100] ;
std::cout << x ;
~~~

# でもこう書きたい

+ わざわざ考えたくない

~~~cpp
auto x = a + b + c + d ;
std::cout << x[100] ;
~~~

# 発想の転換

+ `x[i]`が`a[i]+b[i]+c[i]+d[i]`になればいい
+ `a+b+c+d`がそういうことをする`x`を返せばいい

# 演算の実装

+ 四則演算など

~~~cpp
struct plus
{
    template < typename L, typename R >
    decltype(auto) operator ()( L const & R const & r ) const
    {
        return l + r ;
    } 
} ;
~~~

# operator +

~~~cpp
template < typename L, typename R >
expr< plus, L, R > operator + ( L const & l, R const & l )
{
    return { l, r } ;
}
~~~

# expr

~~~cpp
template < typename OP, typename L, typename R >
struct expr
{
    L const & l ;
    R const & r ;
    expr( L const & l, R const & r )
        : l(l), r(r)
    { }
    decltype(auto) operator []( std::size_t i ) const
    {
        OP op ;
        return op( l[i], r[i] ) ;
    }
} ;
~~~

# 結果

~~~cpp
/*
 expr< plus,
    vector,
    expr< plus,
        vector,
        expr< plus,
            vector,
            vector > 
    >
>
*/
auto x = a + b + c + d ;
~~~

# 結果

~~~cpp
// op( a[100], op( b[100], op( c[100], d[100] ) ) )
// a[100] + b[100] + c[100] + d[100]
std::cout << x[100]
~~~

# まとめ

+ Expression Templatesは式をキャプチャーする
+ 演算子のオーバーロードを利用する
+ 式の構造をそのままテンプレートで表現できる
+ 後はいくらでも評価すれば良い

# 応用

+ 正規表現
+ パーサー
+ 行列演算
+ DSL
