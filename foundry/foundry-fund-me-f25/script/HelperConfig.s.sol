//SPDX-License-Identifier: MIT
//1.Deploy mocks when we are on a local anvil chain
//2.Keep track of contract across different chains
//Sepolia ETH/USD
//Mainnet ETH/USD
pragma solidity ^0.8.18;

import {Script} from 'forge-std/Script.sol';
import {MockV3Aggregator} from  '../test/mocks/MockV3Aggregator.sol';
contract HelperConfig is Script{
    uint8 public DECIMALS=8;
    int public INITIAL_PRICE=200e8;
    NetworkConfig public activeNetworkConfig;
    
    struct NetworkConfig{
        address pricefeed;
    }
   constructor(){
    if(block.chainid==11155111){
        activeNetworkConfig=getSepoliaEthConfig();  
    }else if(block.chainid==1){
        activeNetworkConfig=getMainnetEthConfig();
    }else{
        activeNetworkConfig=getorcreateAnvilConfig();
    }
   }
   
    function getSepoliaEthConfig() public returns(NetworkConfig memory){
        NetworkConfig memory sepoliaConfig=NetworkConfig({pricefeed:0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;

    }
    function getMainnetEthConfig() public returns(NetworkConfig memory){
        NetworkConfig memory mainnetConfig=NetworkConfig(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        return mainnetConfig;

    }
    function getorcreateAnvilConfig() public returns(NetworkConfig memory){
        if (activeNetworkConfig.pricefeed!=address(0)){
            return activeNetworkConfig;
        }
        //1.Deploy the mocks
        // 2.return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed=new MockV3Aggregator(DECIMALS,INITIAL_PRICE);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig=NetworkConfig(address(mockPriceFeed));
        return anvilConfig;
    }
}