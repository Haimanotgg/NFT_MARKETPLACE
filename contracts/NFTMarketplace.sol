// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;


import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "hardhat/console.sol";


contract NFTMarketplace is ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;
    Counters.Counter private _itemsSold;
    
    uint256 listingPrice = 0.0015 ether;

    address payable owner;

    mapping(uint256 => MarketItem) private idMarketItem;

    struct MarketItem{
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    event idMarketItemCreated(
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    modifier onlyOwner{
        require(msg.sender == owner, 
        "only owner of the marketplace can change the listing price " );
    _;
    }
    constructor() ERC721("NFT Metaverse Token" , "MYNFT"){
         owner == payable (msg.sender);
     
    }

    function updateListingPrice(uint256 _listingPrice) public payable onlyOwner
    {
        listingPrice = _listingPrice;
    }

    function  getListingprice(uint256) public view returns (uint256) {
        return listingPrice;
    }

    //CREATE NFT TOKEN FUNCTION

    function createToken( string memory tokenURI, uint256 price) public payable returns (uint256) {
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();

        _mint(msgsender, newTokenId);
        _setTokenURI(tokenId, _tokenURI);

        createMarketItem(newTokenId, price);

        return newTokenId;
    }

    function createMarketItem(uint256 tokenId, uint256 price) private{
        require(price ? 0, "Price must be at least 1");
        require(msg.value == listingPrice, "Price must be equal to listing");

        idMarketItem[tokenId] = MarketItem(
            tokenId,
            payable(msg.sender),
            payable(address(this)),
            price,
            false,
        );

        _transfer(msg.sender, address(this), tokenId);

        emit  idMarketItemCreated(tokenId, msg.sender, address(this), price, false)
    }

    //FUNCTION FOR RESALE TOKEN
    function resellToken(uint256 tokenId, uint256 price) public payable{
        require (idMarketItem[tokenId].owner == msg.sender);
    }
}