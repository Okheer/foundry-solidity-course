//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";

contract HelperConfig {
   NetworkConfig public activeConfig;

    struct NetworkConfig{
        uint subscriptionId;
        bytes32 gasLane;
        uint interval;
        uint EntranceFee;
        uint32 callbackGasLimit;
        address vrfCoordinatorV2;
    }
  
  constructor(){
    if(block.chainid==11155111){
      getSepoliaConfig();
    }else{
        getOrcreateAnvilConfig();
    }
  }

  function getSepoliaConfig() internal returns (NetworkConfig memory activeConfig ){
    activeConfig= NetworkConfig({
                  subscriptionId:0,
                  gasLane:0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
                  interval:30,
                  EntranceFee:0.01 ether,
                  callbackGasLimit:100000,
                  vrfCoordinatorV2:0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B
    });

  }
   function getOrcreateAnvilConfig() internal returns(NetworkConfig memory activeConfig){
  
   }

}