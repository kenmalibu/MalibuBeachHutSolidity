// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

//     __  __  __   __  _____   ______  ______                                                       
//    /\ \/\ \/\ "-.\ \/\  __-./\  ___\/\  == \                                                      
//    \ \ \_\ \ \ \-.  \ \ \/\ \ \  __\\ \  __<                                                      
//     \ \_____\ \_\\"\_\ \____-\ \_____\ \_\ \_\                                                    
//      \/_____/\/_/ \/_/\/____/ \/_____/\/_/ /_/                                                    
//     ______  ______  __   __  ______  ______ ______  __  __  ______  ______ __  ______  __   __    
//    /\  ___\/\  __ \/\ "-.\ \/\  ___\/\__  _/\  == \/\ \/\ \/\  ___\/\__  _/\ \/\  __ \/\ "-.\ \   
//    \ \ \___\ \ \/\ \ \ \-.  \ \___  \/_/\ \\ \  __<\ \ \_\ \ \ \___\/_/\ \\ \ \ \ \/\ \ \ \-.  \  
//     \ \_____\ \_____\ \_\\"\_\/\_____\ \ \_\\ \_\ \_\ \_____\ \_____\ \ \_\\ \_\ \_____\ \_\\"\_\ 
//      \/_____/\/_____/\/_/ \/_/\/_____/  \/_/ \/_/ /_/\/_____/\/_____/  \/_/ \/_/\/_____/\/_/ \/_/ 

contract BeachHutCommissions is ERC1155Supply, Ownable, ReentrancyGuard {

    string collectionName = "Beach Hut Commissions";
    string collectionSymbol = "MBHC";
    string collectionURI = "ipfs://Qmdp5xB3W7qgorsV3TsZBhPCfCq7YHt1qdmQDt98dNAnex/";
    string private name_;
    string private symbol_; 
    uint256 public tokenPrice;
    uint256 public tokenQty;
    uint256 public maxMintQty;
    uint256 public currentTokenId;
    bool public paused;

    constructor() ERC1155(collectionURI) {
        name_ = collectionName;
        symbol_ = collectionSymbol;
        tokenPrice = 0.03 ether;
        tokenQty = 50;
        maxMintQty = 2;
        currentTokenId = 1;
    }

    function mint(uint256 amount)
        public
        payable
        nonReentrant
    {
        require(tx.origin == _msgSender(), "The caller is another contract");
        require(paused == false, "Minting is paused");
        require(totalSupply(currentTokenId) < tokenQty, "All Minted");
        require(amount <= maxMintQty, "Mint quantity is too high");
        require(amount * tokenPrice == msg.value, "You have not sent the correct amount of ETH");

        _mint(_msgSender(), currentTokenId, amount, "");
    }

    //=============================================================================
    // Admin Functions
    //=============================================================================

    function adminMintOverride(address account, uint256 id, uint256 amount) public onlyOwner {
        _mint(account, id, amount, "");
    }

    function setCollectionURI(string memory newCollectionURI) public onlyOwner {
        collectionURI = newCollectionURI;
    }

    function getCollectionURI() public view returns(string memory) {
        return collectionURI;
    }

    function setTokenPrice(uint256 price) public onlyOwner {
        tokenPrice = price;
    }

    function setTokenQty(uint256 qty) public onlyOwner {
        tokenQty = qty;
    }

    function setMaxMintQty(uint256 qty) public onlyOwner {
        maxMintQty = qty;
    }

    function setCurrentTokenId(uint256 id) public onlyOwner {
        currentTokenId = id;
    }

    function togglePaused() public onlyOwner {
        paused = !paused;
    }

    function withdrawETH() public onlyOwner {
		payable(_msgSender()).transfer(address(this).balance);
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
