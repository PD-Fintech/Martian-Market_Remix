pragma solidity ^0.5.0;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/token/ERC721/ERC721Full.sol';
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/ownership/Ownable.sol';
import './MartianAuction.sol';

contract MartianMarket is ERC721Full, Ownable {
    constructor() ERC721Full("MartianMarket", "MARS") public {}

    using Counters for Counters.Counter;

    Counters.Counter tokenIds;
    // cast a payable address for the Martian Development Foundation to be the beneficiary in the auction
    // this contract is designed to have the owner of this contract (foundation) to pay for most of the function calls
    // (all but bid and withdraw)
    address payable foundationAddress = address(uint160(owner()));
    //address payable foundationAddress = msg.sender;
    mapping(uint => MartianAuction) public auctions;

    modifier landRegistered(uint tokenId) {
        require(_exists(tokenId), "Land not registered!");
        _;
    }

    function registerLand(string memory tokenURI) public payable onlyOwner {
        //token_ids.increment();
        //uint token_id = token_ids.current();
        uint _id = totalSupply();
        _mint(msg.sender, _id);
        _setTokenURI(_id, tokenURI);
        createAuction(_id);
    }

    function createAuction(uint tokenId) public onlyOwner {
        // your code here...    
        auctions[tokenId] = new MartianAuction(now,foundationAddress);
    }

    function endAuction(uint tokenId) public onlyOwner landRegistered(tokenId) {
        require(_exists(tokenId), "Land not registered!");
        MartianAuction auction = getAuction(tokenId);
        // your code here...
        auction.auctionEnd();
        safeTransferFrom(owner(), auction.highestBidder(), tokenId);
    }

    function getAuction(uint tokenId) public view returns(MartianAuction auction) {
        // your code here...    
        return auctions[tokenId];
    }

    function auctionEnded(uint tokenId) public view returns(bool) {
        // your code here...
        MartianAuction auction = getAuction(tokenId);
        return auction.ended();
    }

    function highestBid(uint tokenId) public view landRegistered(tokenId) returns(uint) {
        // your code here...
        MartianAuction auction = getAuction(tokenId);
        return auction.highestBid();

    }

    function pendingReturn(uint tokenId, address sender) public view landRegistered(tokenId) returns(uint) {
        // your code here...
        MartianAuction auction = getAuction(tokenId);
        return auction.pendingReturn(sender);
    }

    function bid(uint tokenId) public payable landRegistered(tokenId) {
        // your code here...
        MartianAuction auction = getAuction(tokenId);
        auction.bid.value(msg.value);

    }

}
