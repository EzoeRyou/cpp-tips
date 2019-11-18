% 一時オブジェクトの
% 江添亮
% 2019-11-18

# 一時オブジェクト

+ 実装上の都合で暗黙に作られるオブジェクト
+ 寿命がある
+ ルールはそんなに難しくない
+ しかし足は撃ち抜く


# 作成条件

+ prvalueがxvalueに変換されたとき
+ trivially-copyableオブジェクトを渡したりreturnするとき
+ 例外を投げるとき

# prvalueをxvalueに変換する例

+ prvalueをリファレンスに束縛したとき
+ prvalueのクラスのメンバーにアクセスしたとき

~~~cpp
std::string f() ;

std::string && ref = f() ;
f().size() ;
~~~

# 作成の遅延

+ 一時オブジェクトの作成(マテリアライゼーション)
+ 必要になるまで遅延される

# 寿命

+ 破棄のタイミング
+ 原則として完全式の終わり

# 完全式

+ 未評価オペランド
+ 定数式
+ immediate invocation
+ init-declarator, mem-initializer
+ 自動的なデストラクター呼び出し
+ サブ式ではない式で完全式の一部ではないもの

# 未評価オペランド

+ exprは完全式

~~~cpp
sizeof(expr) + 1
~~~

# 定数式

+ 名前通り

# immeidate invocation

+ consteval関数の実引数
+ exprは完全式

~~~cpp
consteval int f( int x ) { return x ; }

constexpr int c = f( expr ) + 1 ;
~~~

# init-declarator, mem-initializer

+ if文
+ for文
+ メンバー初期化子

# サブ式ではない式で完全式の一部ではないもの

~~~cpp
// 式全体
1 + 1 + 1 ;
~~~

# まとめ

+ 一時オブジェクトの寿命
+ 原則として完全式の中だけ

# 例

~~~cpp
式1 ;
// 式1で作成された一時オブジェクトの寿命は終わり
式2 ;
// 式2で作成された一時オブジェクトの寿命は終わり
~~~

# 例外ルール

+ 一時オブジェクトがリファレンスに束縛された場合
+ 寿命はリファレンスの寿命に合わせて延長される

# 例

~~~cpp
{
    // リファレンスへの束縛
    auto && ref = 1 + 1 ;
    // OK、寿命延長
    ref ; 
} // 一時オブジェクトの寿命は尽きている
~~~
