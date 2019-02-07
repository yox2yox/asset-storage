pragma solidity >=0.4.21 <0.6.0;

contract AssetStorage{
  
  struct AssetInfo{
    address author;
    string name;
    uint init;
    uint amount;
    uint[] salesID;
    mapping( uint => bool ) inStock;
  }
  struct SaleInfo{
    address owner;
    uint assetID;
    string name;
    uint amount;
    uint unit;
    uint price;
  }
  struct OwnerInfo{
    string name;
    mapping(uint => uint) ownedAssets;
    uint[] salesID;
    mapping( uint => bool ) inStock;
    uint balance;
  }

  uint public lastAssetID = 0;
  uint public lastSaleID = 0;


  mapping( uint => AssetInfo ) assets;
  mapping( address => OwnerInfo ) owners;
  mapping( uint => SaleInfo ) sales;

  function createNewAsset(string memory name) public returns(uint){
    assets[lastAssetID].init = 1;
    assets[lastAssetID].author = msg.sender;
    assets[lastAssetID].name = name;
    uint tmp = lastSaleID;
    lastAssetID += 1;
    return tmp;
  }

  function publish(uint assetID,address to,uint amount) public{
    require(assets[assetID].author==msg.sender && assets[assetID].init!=0);
    owners[to].ownedAssets[assetID] += amount;
    assets[assetID].amount += amount;
  }

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

  function withdraw() public {
    uint balance = owners[msg.sender].balance;
    owners[msg.sender].balance = 0;
    msg.sender.transfer(balance);
  }

  function getAssetInfo(uint assetID) public view returns (uint){
    return (assets[assetID].amount);
  }

  function getAssetOwnership(address owner,uint assetID) public view returns (uint){
    return (owners[owner].ownedAssets[assetID]);
  }

  function getSalesList(uint assetID) public view returns(uint[] memory){
    return (assets[assetID].salesID);
  }

  function getSaleInfo(uint saleID) public view returns(string memory,uint,uint,uint){
    return (sales[saleID].name,sales[saleID].amount,sales[saleID].unit,sales[saleID].price);
  }

}
