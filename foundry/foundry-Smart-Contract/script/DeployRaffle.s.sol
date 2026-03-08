//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.sol";

contract DeployRaffle is Script{
    Raffle raffle;
    HelperConfig helperConfig;

    function run() external{
        helperConfig= new HelperConfig();
        (uint subscriptionId ,bytes32 keyHash ,uint interval ,uint entranceFee ,uint32 callBackGasLimit,address vrfCoordinator )= helperConfig.activeConfig();
      
        vm.startBroadcast();
          raffle= new Raffle(subscriptionId,keyHash,interval,entranceFee,callBackGasLimit,vrfCoordinator);
        vm.stopBroadcast();
        
    }
}

