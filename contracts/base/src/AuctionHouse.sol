// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AuctionHouse {
    struct Auction {
        address seller;
        string itemName;
        uint256 startingBid;
        uint256 highestBid;
        address highestBidder;
        uint256 endTime;
        bool ended;
    }

    mapping(uint256 => Auction) public auctions;
    uint256 public auctionCounter;

    event AuctionCreated(uint256 indexed auctionId, string itemName);
    event BidPlaced(uint256 indexed auctionId, address bidder, uint256 amount);
    event AuctionEnded(uint256 indexed auctionId, address winner);

    error BidTooLow();
    error AuctionExpired();

    function createAuction(string memory itemName, uint256 startingBid, uint256 duration) external returns (uint256) {
        uint256 auctionId = auctionCounter++;
        auctions[auctionId] = Auction(
            msg.sender,
            itemName,
            startingBid,
            0,
            address(0),
            block.timestamp + duration,
            false
        );
        emit AuctionCreated(auctionId, itemName);
        return auctionId;
    }

    function placeBid(uint256 auctionId) external payable {
        Auction storage auction = auctions[auctionId];
        if (block.timestamp > auction.endTime) revert AuctionExpired();
        if (msg.value <= auction.highestBid || msg.value < auction.startingBid) revert BidTooLow();

        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }

        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
        emit BidPlaced(auctionId, msg.sender, msg.value);
    }

    function endAuction(uint256 auctionId) external {
        Auction storage auction = auctions[auctionId];
        auction.ended = true;
        if (auction.highestBidder != address(0)) {
            payable(auction.seller).transfer(auction.highestBid);
        }
        emit AuctionEnded(auctionId, auction.highestBidder);
    }

    function getAuction(uint256 auctionId) external view returns (Auction memory) {
        return auctions[auctionId];
    }
}
