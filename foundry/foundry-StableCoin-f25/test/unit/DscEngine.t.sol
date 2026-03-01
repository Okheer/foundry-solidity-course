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
    address btcPricefeed;
    address ethPricefeed;

    address public USER=makeAddr("user");
    uint public constant AMOUNT_COLLATERAL = 10 ether;

    function setUp() external{
     deployer = new DeployDsc();
     (dsc,dscEngine,config)=deployer.run();
     (btcPricefeed,ethPricefeed, wbtc, weth,) = config.activeNetworkConfig();
   
    }

    ////////////////////
    ////constructor/////
    ////////////////////
    address[] public tokenAddress;
    address[] public pricefeed;
    function testrevertifTokenlengthNotMatch() external {
        tokenAddress.push(wbtc);
        tokenAddress.push(weth);
        pricefeed.push(btcPricefeed);
        vm.expectRevert(DscEngine.Drc_lengthTokenAddressisnotEqualToLEngthPricefeed.selector);
        new DscEngine(tokenAddress,pricefeed,address(dsc));



        
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
    function testRevertsWithUnapprovedCollateral() public {
        ERC20Mock ranToken = new ERC20Mock("RAN","RAN",USER,AMOUNT_COLLATERAL);
        vm.startPrank(USER);
     
        
        vm.expectRevert( abi.encodeWithSelector(DscEngine.DSCEngine__TokenNotAllowed.selector, address(ranToken)));
        dscEngine.depositCollateral(address(ranToken),AMOUNT_COLLATERAL);
        vm.stopPrank();
    }
    modifier depositCollateral() {
       vm.startPrank(USER);
        ERC20Mock(weth).mint(USER, AMOUNT_COLLATERAL);
       ERC20Mock(weth).approve(address(dscEngine),AMOUNT_COLLATERAL);
       dscEngine.depositCollateral(weth,AMOUNT_COLLATERAL);
       vm.stopPrank();
        _;
    }
    function testCanDepositCollateralAndGetInfo() public depositCollateral(){
       (uint totalDscMinted, uint collateralValueInUsd)= dscEngine.getAccountInformation(USER);
       uint expectedTotalDscMinted = 0;
        uint256 expectedDepositedAmount = dscEngine.getTokenAmountFromUsd(weth, collateralValueInUsd);
        assertEq(totalDscMinted, 0);
        assertEq(expectedDepositedAmount, AMOUNT_COLLATERAL);
    }
    function testgetTokenAmountFromUsd() external {
        uint usdAmount= 100 ether;//ether f,entioned for e18
        uint expectedEth=0.05 ether;
        uint actualEth=dscEngine.getTokenAmountFromUsd(address(wbtc),usdAmount);
        assertEq(expectedEth,actualEth);
    }
}