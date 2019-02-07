pragma solidity >=0.4.21 <0.6.0;

contract AssetStorage{

  struct AssetInfo{
    address author;
    string name;
    uint init;
    uint amount; //現在の総発行料
    uint[] salesID; //このアセットに関する販売情報
    mapping( uint => bool ) inStock; //上記salesIDに関して在庫があるかどうか
  }

  //Assetの販売情報
  struct SaleInfo{
    address owner;
    uint assetID;
    string name;
    uint amount;
    uint unit;
    uint price;
  }

  //Assetオーナーの情報
  struct OwnerInfo{
    string name;
    mapping(uint => uint) ownedAssets;
    uint[] salesID; //このユーザーが登録した販売情報
    mapping( uint => bool ) inStock;
    uint balance; //Asset販売の売り上げ
  }

  uint public lastAssetID = 0;
  uint public lastSaleID = 0;

  //AssetID => AssetInfo
  mapping( uint => AssetInfo ) assets;

  // Owner Address => OwnerInfo
  mapping( address => OwnerInfo ) owners;

  // SaleID => SaleInfo
  mapping( uint => SaleInfo ) sales;

  ///@title 新規Assetを登録
  ///@param name :Asset名
  ///@return AssetID
  function createNewAsset(string memory name) public returns(uint){
    assets[lastAssetID].init = 1;
    assets[lastAssetID].author = msg.sender;
    assets[lastAssetID].name = name;
    uint tmp = lastSaleID;
    lastAssetID += 1;
    return tmp;
  }

  ///@title Assetを発行
  ///@notice 指定したAssetのAuthorでなければ発行できません
  ///@param assetID :AssetID
  ///@param to :発行先
  ///@param amount :発行量
  function publish(uint assetID,address to,uint amount) public{
    require(assets[assetID].author==msg.sender && assets[assetID].init!=0);
    owners[to].ownedAssets[assetID] += amount;
    assets[assetID].amount += amount;
  }

  ///@title Assetを販売
  ///@notice 販売量がAsset保有量を超えている場合は販売登録できません
  ///@param assetID :assetID
  ///@param amount :販売量
  ///@param unit :購入可能単位
  ///@param price :1個あたりの価格
  ///@return SaleID
  function sell(uint assetID,uint amount,uint unit,uint price) public returns(uint){
    require(owners[msg.sender].ownedAssets[assetID]>=amount);
    sales[lastSaleID].owner = msg.sender;
    sales[lastSaleID].assetID = assetID;
    sales[lastSaleID].name = assets[assetID].name;
    sales[lastSaleID].amount = amount;
    sales[lastSaleID].unit = unit;
    sales[lastSaleID].price = price;
    assets[assetID].salesID.push(lastSaleID);
    owners[msg.sender].salesID.push(lastSaleID);
    owners[msg.sender].ownedAssets[assetID]-=amount;
    if(amount>0){
      assets[assetID].inStock[lastSaleID] = true;
      owners[msg.sender].inStock[lastSaleID] = true;
    }
    uint tmp = lastSaleID;
    lastSaleID += 1;
    return tmp;
  }

  ///@title Asset購入
  ///@param saleID :saleID
  ///@param num :購入数
  function buy(uint saleID,uint num) public payable returns(bool){
    require(sales[saleID].unit%num==0
       && sales[saleID].amount>=num
       && msg.value==sales[saleID].price*num);
    owners[sales[saleID].owner].balance+=msg.value;
    sales[saleID].amount-=num;
    if(sales[saleID].amount<=0){
      assets[sales[saleID].assetID].inStock[saleID] = false;
      owners[sales[saleID].owner].inStock[saleID] = false;
    }
    owners[msg.sender].ownedAssets[sales[saleID].assetID]+=num;
  }

  ///@title 売上金引き出し
  ///@notice balanceに溜まっている売上金を全て引き出します
  function withdraw() public {
    uint balance = owners[msg.sender].balance;
    owners[msg.sender].balance = 0;
    msg.sender.transfer(balance);
  }

  ///@title Asset情報取得
  ///@param assetID :AssetID
  ///@return (Asset名,Asset総発行料)
  function getAssetInfo(uint assetID) public view returns (string memory,uint){
    return (assets[assetID].name,assets[assetID].amount);
  }

  ///@title Asset保有数取得
  ///@param owner :オーナーアドレス
  ///@param assetID :assetID
  ///@return アセット保有数
  function getAssetOwnership(address owner,uint assetID) public view returns (uint){
    return (owners[owner].ownedAssets[assetID]);
  }

  ///@title 販売情報一覧取得
  ///@param assetID :assetID
  ///@return SaleID一覧の配列
  function getSalesList(uint assetID) public view returns(uint[] memory){
    return (assets[assetID].salesID);
  }

  ///@title 販売情報詳細取得
  ///@param saleID :SaleID
  ///@return (アセット名, 販売量, 購入単位, 価格)
  function getSaleInfo(uint saleID) public view returns(string memory,uint,uint,uint){
    return (sales[saleID].name,sales[saleID].amount,sales[saleID].unit,sales[saleID].price);
  }

}
