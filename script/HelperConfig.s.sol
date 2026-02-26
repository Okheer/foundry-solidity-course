//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {ERC20Mock} from "../test/mocks/ERC20Mock.sol";

contract HelperConfig is Script{
    uint256  anvilKey=0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6;
    struct NetworkConfig{
        address wbitcoinpricefeed;
        address wEtherpricefeed;
        address wbtc;
        address wEth;
        uint deployerKey;
        }

    NetworkConfig public activeNetworkConfig;
    constructor(){
        if(block.chainid==11155111){
            getSepoliaConfig();
        }else{
        getorcreateAnvilConfig();
        }
    }

     function getSepoliaConfig() public returns(NetworkConfig memory){
        activeNetworkConfig=NetworkConfig({
            wbitcoinpricefeed:0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43,
            wEtherpricefeed:0x694AA1769357215DE4FAC081bf1f309aDC325306,
            wbtc:0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063,
            wEth:0xdd13E55209Fd76AfE204dBda4007C227904f0a81,
            deployerKey:vm.envUint("PRIVATE_KEY")
        });
        return activeNetworkConfig;
     }

     function getorcreateAnvilConfig() public returns(NetworkConfig memory){
        if(activeNetworkConfig.wEtherpricefeed!=address(0)){
            return activeNetworkConfig;
        }

        MockV3Aggregator mockWethPriceFeed=new MockV3Aggregator(8,2000e8);
        MockV3Aggregator mockWbtcPriceFeed=new MockV3Aggregator(8,2000e8);
        ERC20Mock wethMock=new ERC20Mock("WETH","WETH",msg.sender,1000e8);
        ERC20Mock wbtcMock=new ERC20Mock("WBTC","WBTC",msg.sender,1000e8);
        activeNetworkConfig=NetworkConfig({
            wbitcoinpricefeed:address(mockWbtcPriceFeed),
            wEtherpricefeed:address(mockWethPriceFeed),
            wbtc:address(wbtcMock),
            wEth:address(wethMock),             
             deployerKey:anvilKey
        });
        return activeNetworkConfig;
     
    }
}