// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("Kimy");
    uint256 constant SEND_VALUE = 1 ether; // Testing by sending 1 ETH
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // Give USER some ETH
    }

    modifier funded() {
        vm.prank(USER); // FOUNDRY CHEATCODE -> The very next txn/instruction will be sent by USER
        fundMe.fund{value: SEND_VALUE}(); // Sending ETH (by USER)
        assert(address(fundMe).balance > 0);
        _;
    }

    function testMinDollarRequired() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        // assertEq(fundMe.i_owner(), msg.sender); // msg.sender is us, but fundMe is deployed by FundMeTest which was written by us
        // assertEq(fundMe.i_owner(), address(this)); // Changing again to msg.sender because of the changed code
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersion() public view {
        console.log(fundMe.getPriceFeedVersion());
        assertEq(fundMe.getPriceFeedVersion(), 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert(); // FOUNDRY CHEATCODE
        fundMe.fund(); // Sending 0 ETH, if we want to send ETH: fundMe.fund{value: ETH_AMOUNT}();
    }

    function testFundUpdatesAmountFunded() public funded { 
        assertEq(fundMe.viewFundedAmount(USER), SEND_VALUE);
    }

    function testFundAddsToFunders() public funded {
        address funder = fundMe.viewFunders()[0];
        assertEq(funder, USER);
    }

    function testWithdrawFromSingleFunder() public funded {
        // AAA : Arrange, Act, Assert methodology for tests
        // Arrange
        address owner = fundMe.getOwner();
        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(owner);
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = owner.balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange
        uint160 num_of_additional_funders = 10; // addresses work well with uint160, not uint256
        uint160 startingFunderIdx = 1; // address -> 20 bytes value, and uint160 -> 160 bits = 20 bytes

        for(uint160 i=startingFunderIdx; i<=num_of_additional_funders; i++) {
            hoax(address(i), SEND_VALUE); // Hoax does the work of both vm.prank and vm.deal (creates an account with specified balance)
            fundMe.fund{value: SEND_VALUE}();
        }

        address owner = fundMe.getOwner();
        uint256 startingOwnerBalance = owner.balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(owner);
        fundMe.withdraw();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == owner.balance);
    }

    function testOnlyOwnerCanWithdraw() public {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }
}