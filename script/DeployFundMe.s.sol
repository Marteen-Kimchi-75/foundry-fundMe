// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {FundMe} from "src/FundMe.sol";

contract DeployFundMe is Script {
    address priceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306; // ETH/USD Sepolia address

    function run() external returns (FundMe) {
        vm.startBroadcast();
        FundMe fundMe = new FundMe(priceFeedAddress);
        vm.stopBroadcast();
        return fundMe;
    }
}