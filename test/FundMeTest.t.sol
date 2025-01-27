// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "lib/forge-std/src/Test.sol";

contract FundMeTest is Test {
    uint256 my_num = 5;

    function setUp() external {
        my_num = 8;
    }

    function testDemo() public view {
        assertEq(my_num, 8);
    }
}