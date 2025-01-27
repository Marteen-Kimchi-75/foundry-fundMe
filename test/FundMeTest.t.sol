// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    function setUp() external {
        fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); // ETH/USD Sepolia address
    }

    function testMinDollarRequired() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        // assertEq(fundMe.i_owner(), msg.sender); // msg.sender is us, but fundMe is deployed by FundMeTest which was written by us
        assertEq(fundMe.i_owner(), address(this));
    }

    function testPriceFeedVersion() public view {
        console.log(fundMe.getPriceFeedVersion());
        assertEq(fundMe.getPriceFeedVersion(), 4);
    }
}