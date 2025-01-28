// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 1 ether; // Testing by sending 1 ETH
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // Give USER some ETH
    }

    function testMinDollarRequired() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        // assertEq(fundMe.i_owner(), msg.sender); // msg.sender is us, but fundMe is deployed by FundMeTest which was written by us
        // assertEq(fundMe.i_owner(), address(this)); // Changing again to msg.sender because of the changed code
        assertEq(fundMe.i_owner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        console.log(fundMe.getPriceFeedVersion());
        assertEq(fundMe.getPriceFeedVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // FOUNDRY CHEATCODE
        fundMe.fund(); // Sending 0 ETH, if we want to send ETH: fundMe.fund{value: ETH_AMOUNT}();
    }

    function testFundUpdatesFundersList() public {
        vm.prank(USER); // ANOTHER FOUNDRY CHEATCODE -> Next txn will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // Sending ETH (by USER)
        assertEq(fundMe.viewFundedAmount(USER), SEND_VALUE);
    }
}