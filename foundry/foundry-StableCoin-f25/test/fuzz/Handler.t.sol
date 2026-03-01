// Commented out for now until revert on fail == false per function customization is implemented

// // SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Test } from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDsc} from "../../script/DeployDsc.s.sol";
import {DscEngine} from "../../src/DscEngine.sol";
import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {ERC20Mock} from "../mocks/ERC20Mock.sol";
import { console } from "forge-std/console.sol";

contract Handler is Test {
    DscEngine dscEngine;
    DecentralizedStableCoin dsc;
    ERC20Mock wbtc;
    ERC20Mock weth;
    uint MAX_DEPOSIT_SEED=type(uint96).max;
     constructor(DscEngine _dscEngine, DecentralizedStableCoin _dsc) {
        dscEngine = _dscEngine;
        dsc = _dsc;
        
         address[] memory collateralToken=dscEngine.getCollateralTokens();
     wbtc= ERC20Mock(collateralToken[0]);
     weth=ERC20Mock(collateralToken[1]);
    }
        
   // redeem collateral
   function depositcollateral(uint collateralseed, uint amountCollateral) public {

    ERC20Mock collateral= _getCollateralFromSeed(collateralseed);
    amountCollateral=bound(amountCollateral,1,MAX_DEPOSIT_SEED);
    vm.startPrank(msg.sender);
    collateral.mint(address(msg.sender), amountCollateral);
    collateral.approve(address(dscEngine), amountCollateral);
    dscEngine.depositCollateral(address(collateral), amountCollateral);
    vm.stopPrank();
   
   }     
  function redeemCollateral(uint collateralseed,uint amountCollateral) public {
      ERC20Mock collateral= _getCollateralFromSeed(collateralseed);
     uint maxCollateralToRedeem= dscEngine.getCollateralBalanceOfUser(msg.sender, address(collateral));

     if(maxCollateralToRedeem==0) return;
     
     amountCollateral = bound(amountCollateral,0, maxCollateralToRedeem);
     vm.startPrank(msg.sender);
    collateral.mint(address(dscEngine),maxCollateralToRedeem);
   dscEngine.redeemCollateral(address(collateral), amountCollateral);
   vm.stopPrank();
  }
  function mintDsc(uint mintAmount) public{
    (uint totalDscMinted,uint collateralValueInUsd)=dscEngine.getAccountInformation(msg.sender);
    int maxDscToMinted=int(collateralValueInUsd/2)- int(totalDscMinted);

    if(maxDscToMinted<0) return;
     mintAmount= bound(mintAmount,0,uint(maxDscToMinted));
    vm.startPrank(msg.sender);
    dscEngine.mintDsc(mintAmount);
    vm.stopPrank();
  }

  function _getCollateralFromSeed(uint collateralseed) private view returns(ERC20Mock){
    if(collateralseed % 2 ==0){
      return wbtc;
    }else{
      return weth;
    }
  }
   function callSummary() external view {
        console.log("Weth total deposited", weth.balanceOf(address(dscEngine)));
        console.log("Wbtc total deposited", wbtc.balanceOf(address(dscEngine)));
        console.log("Total supply of DSC", dsc.totalSupply());
    }



}