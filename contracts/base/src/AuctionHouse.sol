// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AuctionHouse Contract
/// @notice Simple auction contract with bidding.
contract AuctionHouse {

    uint256 public highestBid;
    address public highestBidder;
    uint256 public endTime;
    bool public ended;
    address payable public beneficiary;
    
    constructor() {
        beneficiary = payable(msg.sender);
        endTime = block.timestamp + 7 days;
    }
    
    function bid() external payable {
        require(block.timestamp < endTime, "Ended");
        require(msg.value > highestBid, "Bid too low");
        
        if (highestBid != 0) {
            payable(highestBidder).transfer(highestBid);
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
    }
    
    function end() external {
        require(block.timestamp >= endTime, "Not ended");
        require(!ended, "Already ended");
        
        ended = true;
        beneficiary.transfer(highestBid);
    }

}
