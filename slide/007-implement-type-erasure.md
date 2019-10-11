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
+ 保持している型を確認できる
+ visit

# bind

+ ラムダ式があるので用済み

# shared_ptr

+ 適切なデストラクターを呼び出す

# デストラクター呼び出し

+ virtualデストラクター不要

~~~cpp
struct A { } ;
struct B : A { } ;

std::shared_ptr<A> p( new A ) ;
// B::~Bが呼び出される
~~~

