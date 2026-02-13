// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../src/AuctionHouse.sol";

contract AuctionHouseTest is Test {
    AuctionHouse public c;
    
    function setUp() public {
        c = new AuctionHouse();
    }

    function testDeployment() public {
        assertTrue(address(c) != address(0));
    }
}
