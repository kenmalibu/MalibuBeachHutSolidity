// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./MalibuCoinI.sol";







import "hardhat/console.sol";




contract BeachHutPasses is ERC1155Supply, Ownable, ReentrancyGuard {

    string collectionURI = "";
    string private name_;
    string private symbol_; 
    uint256 public commissionQty;
    uint256 public commissionPrice;
    uint256 public privateQty;
    uint256 public privatePrice;
    uint256 public maxMintQty;
    bool public paused;
    address public CoinContract;

    MalibuCoinI public coin;

    constructor() ERC1155(collectionURI) {
        name_ = "Beach Hut Passes";
        symbol_ = "BHP";
        commissionQty = 2;
        commissionPrice = 5000 * 10 ** 18;
        privateQty = 1;
        privatePrice = 15000 * 10 ** 18;
        maxMintQty = 1;
        paused = true;
    }
    
    function name() public view returns (string memory) {
      return name_;
    }

    function symbol() public view returns (string memory) {
      return symbol_;
    }

    function mintCommissionPass()
        public
        nonReentrant
    {
        checkMintRequirements(1, commissionPrice, commissionQty);

        coin.transferFrom(_msgSender(), address(this), commissionPrice);
        _mint(_msgSender(), 1, maxMintQty, "");

        console.log(coin.balanceOf(_msgSender()));


        console.log(totalSupply(1));
        console.log(commissionQty);
    }

    function mintPrivatePass()
        public
        nonReentrant
    {
        checkMintRequirements(2, privatePrice, privateQty);

        coin.transferFrom(_msgSender(), address(this), privatePrice);
        _mint(_msgSender(), 2, maxMintQty, "");

        console.log(coin.balanceOf(_msgSender()));
    }

    function checkMintRequirements(uint256 id, uint256 price, uint256 qty) private view {

        require(paused == false, "Minting is paused");
        require(totalSupply(id) < qty, "All Minted");
        require(tx.origin == _msgSender(), "The caller is another contract");
        require(coin.balanceOf(_msgSender()) >= price, "You do not own enough Malibu Coins to make this transaction");

    }



    // REDEEM PASSES HERE
    // burn( address account, uint256 id, uint256 value) 



    function redeemCommissionPass() 
        public 
        nonReentrant
    {
        require(balanceOf(_msgSender(), 1) > 0, "You do not own a commission pass");
        require(tx.origin == _msgSender(), "The caller is another contract");

        _burn(_msgSender(),1, 1);
    }


    function redeemPrivatePass() 
        public 
        nonReentrant
    {
        require(balanceOf(_msgSender(), 2) > 0, "You do not own a private pass");
        require(tx.origin == _msgSender(), "The caller is another contract");

       _burn(_msgSender(),2, 1);
    }








    //=============================================================================
    // Private Functions
    //=============================================================================

    function setCollectionURI(string memory newCollectionURI) public onlyOwner {
        collectionURI = newCollectionURI;
    }

    function getCollectionURI() public view returns(string memory) {
        return collectionURI;
    }

    function setCommissionQty(uint256 qty) public onlyOwner {
        commissionQty = qty;
    }

    function setCommissionPrice(uint256 price) public onlyOwner {
        commissionPrice = price;
    }

    function setPrivateQty(uint256 qty) public onlyOwner {
        privateQty = qty;
    }

    function setPrivatePrice(uint256 price) public onlyOwner {
        privatePrice = price;
    }

    function setMaxMintQty(uint256 qty) public onlyOwner {
        maxMintQty = qty;
    }

    function togglePaused() public onlyOwner {
        paused = !paused;
    }

    function setMalibuCoin(address _contract) external onlyOwner {
        require(_contract != address(0), "Can not be address 0");
        coin = MalibuCoinI(_contract);
        CoinContract = _contract;
    }

    function coinWithdraw() public onlyOwner {
        coin.transferFrom(address(this), owner(), coin.balanceOf(address(this)));
    }

    //=============================================================================
    // Override Functions
    //=============================================================================
    
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal override(ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function uri(uint256 _tokenId) public override view returns (string memory) {
        return string(abi.encodePacked(collectionURI, Strings.toString(_tokenId), ".json"));
    }  
}
