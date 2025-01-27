// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "lib/forge-std/src/Script.sol";
import {FundMe} from "src/FundMe.sol";

contract DeployFundMe is Script {
    function run() external {
        vm.startBroadcast();
        FundMe fundMe = new FundMe();
        vm.stopBroadcast();
    }
}