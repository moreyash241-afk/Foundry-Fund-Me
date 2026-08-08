// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.0;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from './HelperConfig.s.sol';

contract DeployFundMe is Script{
    function run() external returns(FundMe){
        // BEFOR BROADCAST -> it is not a real transaction
        HelperConfig helperConfig = new HelperConfig();
        // AFTER BROADCAT -> IT IS A REAL TRANSACTION
        vm.startBroadcast();
        // MOCK
        address ethUsdPriceFeed = helperConfig.getActiveNetworkConfig().priceFeed;
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}