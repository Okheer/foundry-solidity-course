//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;    

import {DecentralizedStableCoin} from "../../src/DecentralizedStableCoin.sol";
import {DscEngine} from "../../src/DscEngine.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test} from "forge-std/Test.sol";
import {DeployDsc} from "../../script/DeployDsc.s.sol";
import {ERC20Mock}  from "../mocks/ERC20Mock.sol";

contract DscEngineTest is Test{
    DecentralizedStableCoin dsc;
    DscEngine dscEngine;
    HelperConfig config;
    DeployDsc deployer;
    address wbtc;
    address weth;

    address public USER=makeAddr("user");
    uint public constant AMOUNT_COLLATERAL = 10 ether;

    function setUp() external{
     deployer = new DeployDsc();
     (dsc,dscEngine,config)=deployer.run();
     (,, wbtc, weth,) = config.activeNetworkConfig();
   
    }

    //getusdvalue
    function testGetUsdValue() public {
        uint EthinUsd=2000e18;
        uint amount=15e18;
        uint expected= 30000e18;
        uint actualUsd=dscEngine.getUsdValue(weth,amount);  
        assertEq(expected,actualUsd);

    }
    function testRevertIfCollateralZer0() public{
        vm.startPrank(USER);
        ERC20Mock(weth).approve(address(dscEngine), AMOUNT_COLLATERAL);
        vm.expectRevert(DscEngine.Drc_AmountisGreaterThanZero.selector);
        dscEngine.depositCollateral(weth,0);
        vm.stopPrank();

        
    }
}