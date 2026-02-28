//SPDX_License-Identifier:MIT
pragma solidity ^0.8.18;

import {Script} from 'forge-std/Script.sol';
import {FundMe} from '../src/FundMe.sol';
import {HelperConfig} from './HelperConfig.s.sol';

contract DeployFundMe is Script{
    function run() public returns(FundMe){//Foundry needs to call run() from outside the contract when you execute the script, so run must be visible externally.  
       //Before startBroadcast->Not a real tx
       HelperConfig helperConfig =new HelperConfig();
       (address ethUsdPriceFeed)=helperConfig.activeNetworkConfig();//rhs is of tuple typr
       //after startbroadcast->Real tx
       
        vm.startBroadcast();
        // FundMe fundMe=new FundMe();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);//i have not put address here but it needs to
        vm.stopBroadcast();
        return fundMe;
    }
}
