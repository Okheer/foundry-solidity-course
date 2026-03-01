//SPDX-License-Identifier:MIT
pragma solidity ^0.8.20;

import {DecentralizedStableCoin} from "../src/DecentralizedStableCoin.sol";
import {Script} from "forge-std/Script.sol";
import {DscEngine} from "../src/DscEngine.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployDsc is Script{
    address[] tokenAddress;
    address[] pricefeed;
function run() external returns(DecentralizedStableCoin,DscEngine,HelperConfig){
    HelperConfig helperConfig= new HelperConfig();
   (address wbtcPriceFeed, address wethPriceFeed, address wbtc, address weth,uint deployerkey)=helperConfig.activeNetworkConfig();
    
    tokenAddress=[wbtc,weth];
    pricefeed=[wbtcPriceFeed,wethPriceFeed];

    vm.startBroadcast(deployerkey);
    DecentralizedStableCoin dsc=new DecentralizedStableCoin();
    DscEngine dscEngine=new DscEngine(
        tokenAddress,
        pricefeed,
        address(dsc)
    );
     dsc.transferOwnership(address(dscEngine));
    vm.stopBroadcast();
     return (dsc,dscEngine,helperConfig);
}
}