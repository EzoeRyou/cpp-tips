% type erasure実装
% 江添亮
% 2019-10-10


# 振り返り

+ type erasure
+ 型を隠すための技法
+ 様々なライブラリで使われている

# any

+ どんな型の値でも保持できる
+ コピーできる
+ 破棄できる
+ 保持している型を確認できる
+ 型を指定して取り出せる

# function

+ 呼び出し可能な値を保持できる
+ コピーできる
+ 破棄できる
+ 関数呼び出しできる

# variant

+ 指定した型なら保持できる
+ コピーできる
+ 破棄できる
+ 保持している型を確認できる
+ visit

# bind

+ ラムダ式があるので用済み

# shared_ptr

+ 適切なデストラクターを呼び出す

# デストラクター呼び出し

+ コンストラクターに渡された実行時型を覚えておく
+ デストラクターで実行時型のですトラクターを呼び出す
+ virtualデストラクター不要

~~~cpp
struct A { } ;
struct B : A { } ;

std::shared_ptr<A> p( new A ) ;
// B::~Bが呼び出される
~~~

# type erasure

+ 複数の型を共通の方法で操作
+ virtual関数とRTTIを使う

# anyの宣言

+ テンプレートではない

~~~cpp
class any ;
~~~

# anyの変換コンストラクター

+ メンバーテンプレート
+ コンパイルは通るようになった

~~~cpp
class any
{
public :
    template < typename T >
    any( T && value ) ;
} ;
~~~



# ナイーブな実装

~~~cpp
class any
{
    void * ptr ;
    std::type_info * info ;
public :
    template < typename T >
    any( T && value )
    {
        using VT = std::decay_t<T> ;
        ptr = new VT(value) ;
        info = *typeid(VT) ;
    }
} ;
~~~

# 問題

+ コピーできない
+ 破棄できない

# コピーできない

+ 型がわからないため

~~~cpp
// コピーコンストラクター
any( any const & other )
{
    // ptrの型はvoid *
    // 指している型がわからない
    ptr = new ???(*ptr) ;
}
~~~

# 破棄できない

+ 型がわからないため

~~~cpp
~any()
{
    delete static_cast<???>(ptr) ;
}
~~~

# 解決策

+ 共通の基本クラス
+ virtual関数
+ テンプレート

# 基本クラス

+ コピーと破棄をvirtual関数として持つ

~~~cpp
struct erased
{
    // 
    virtual erased * clone() const = 0;
    virtual ~erased() = 0 ;
} ;
~~~

# 派生クラス

+ テンプレートを使う
+ 共通の基本クラスを持つ

~~~cpp
template < typename VT >
struct holder : erased
{
    VT value ;
    erased * clone() const override
    {
        return new holder{value} ;
    }
    ~holder() override { }

} ;
~~~

# anyクラス

~~~cpp
class any
{
    erased * ptr = nullptr ;
    std::type_info * info = nullptr ;
public :
    any() { }
    bool has_value() const noexcept
    {
        return info != nullptr ; 
    }
} ;
~~~

# コンストラクター

~~~cpp
template < typename T >
any( T && value )
{
    using VT = std::decay_t<T> ;
    ptr = new holder<VT>( std::forward<T>(value) ) ;
    info = &typeid(VT) ;
}
~~~

# コピーコンストラクター

+ 実行時型に合わせて呼ばれる

~~~cpp
any( any const & other )
{
    // 値がある場合
    if ( other.has_value() )
    {
        ptr = other.clone() ;
        info = other.info ;
    }
}
~~~

# デストラクター

~~~cpp
// 
~any()
{
    delete ptr ;
}
~~~

# any_cast

~~~cpp
template < typename T >
T * any_cast( any * operand )
{
    if ( operand != nullptr && operand->type() == typeid(T) )
    {
        return &static_cast<holder<T> *>( operand.ptr ).value ;
    }
    else
        return nullptr ;
}
~~~

# 動的確保省略

+ unionを使う
+ ポインターに収まるサイズのオブジェクトならばstorageに確保
+ それ以外ならば動的確保
+ それ以外の処理もサイズで条件分岐

~~~cpp
class any
{
    bool valid_ptr ;
    union {
        erased * ptr ;
        std::byte storage[sizeof(erased *)] ;
    } ;
    std::type_info * info ;
} ;
~~~

# コンストラクター

~~~cpp
template < typename T >
any( T && value )
{
    using VT = std::decay_t<T> ;
    if constexpr ( sizeof(T) <= sizeof(storage) )
    {
        new(storage) holder<VT>( std::forward<T>(value) ) ;
    } else
    {
        ptr = new holder<VT>( std::forward<T>(value) ) ;
    }
    info = &typeid(VT) ;
}
~~~
