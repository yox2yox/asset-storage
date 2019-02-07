mining-button
===
デジタルアセットを登録、発行、売買できるEthereumコントラクト
## アセット
デジタルアセットはコントラクトを実行することにより登録が可能。アセットを登録したユーザーは自由に発行しユーザーに配布することができる。アセットが保持するパラメータは以下の通り。

| パラメータの種類 | パラメータ名 | 型 |
|:-----------|------------:|:------------:|
| 発行者 | author | address |
| アセット名 | name | string |
| 総発行料 | amount | uint |

## オーナー
各利用ユーザーに関してどのアセットをいくつ持っているかをコントラクト上に記録する。アセットの保有者をオーナーと呼ぶ。

## アセット売買
オーナーはコントラクト上にSaleInfoを登録し、アセットを売りに出すことができる。すべてのユーザーはSaleInfoに登録されたアセットを自由に購入することができる。SaleInfoに登録するパラメータは以下の通り。

| パラメータの種類 | パラメータ名 | 型 |
|:-----------|------------:|:------------:|
| 販売者 | owner | address |
| アセット発行者 | author | address |
| アセット名 | name | string |
| 総販売量 | amount | uint |
| 購入可能単位 | unit | uint |
| 1個あたりの価格 | price | uint |

購入する際はSaleInfoおよび購入量を指定しコントラクトを呼び出す。
