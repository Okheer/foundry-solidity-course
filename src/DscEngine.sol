//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
/*
*@title DrcEngine
*@Author Mihir
*Characteristics:
  1.Pegged
  2.Algorithmic
  3.Eogenous
*Drcengine is the main contract which implements the mining and burn logic accordingly  
*The worth of minted stablecoin shouldnot be more than collateral value 

*/
contract DscEngine is ReentrancyGuard{
    error Drc_AmountisGreaterThanZero();
    error Drc_lengthTokenAddressisnotEqualToLEngthPricefeed();
    error Drc_ZeroAddressisNotAcceptable();
    error Dsc_TransferFailed();
    error Dsc_MintFailed();
    
    uint private constant ADDITIONAL_FEED_BUFFER=1e10;// to accomodate for feed price fluctuation
    uint private constant PRECISION=1e18;
    uint private constant LIQUIDATION_THRESHOLD=50;
    uint private constant LIQUIDATION_PRECISION=100;
    uint private constant MINIMUM_HEALTH_FACTOR=1;
    

    DecentralizedStableCoin private i_Dsc;
    mapping(address tokenAddress =>address) private s_pricefeed;
    mapping(address user =>mapping(address tokenAddress=>uint amount)) private s_collateralDeposited;
    mapping(address user=>uint amount) private s_dscMinted;
    address[] private s_collateralTokens;

    constructor(address[] memory tokenAddress, address[] memory pricefeed, address DscAddress){
      if(tokenAddress.length!=pricefeed.length){
        revert Drc_lengthTokenAddressisnotEqualToLEngthPricefeed();
      }
     for(uint i=0;i<tokenAddress.length;i++){
       s_pricefeed[tokenAddress[i]]=pricefeed[i];
        s_collateralTokens.push(tokenAddress[i]);
     }
     i_Dsc=DecentralizedStableCoin(DscAddress);
    }

    event CollateralDeposited(address indexed user,address indexed token, uint indexed amount);

    modifier amountmustbepositive(uint amount){
      if(amount<=0){
        revert Drc_AmountisGreaterThanZero();
      }
      _;
    }
    modifier tokenAddressisValid(address tokenAddress){
     
      _;
    }
    /*
    *@para: tokenAddress: address of token
    *@para: amount:amount of token
     */
    function depositCollateral(address tokenAddress,uint amount) 
    external amountmustbepositive(amount){
     if(tokenAddress==address(0)){
      revert Drc_ZeroAddressisNotAcceptable();
     }
     s_collateralDeposited[msg.sender][tokenAddress]+=amount;
     emit CollateralDeposited(msg.sender,tokenAddress, amount);
     bool success= IERC20(tokenAddress).transferFrom(msg.sender,address(this),amount);
     if(!success){
      revert Dsc_TransferFailed();
     }

    }

    function mintDsc(uint amount) external returns(uint){
     s_dscMinted[msg.sender]+=amount;
      _revertIfHealthFactorisBroken(msg.sender);
      bool success=i_Dsc.mint(msg.sender,amount);
      if(!success){
        revert Dsc_MintFailed();
      }

    }
    

    function getHealthFactor() external view returns(uint){

    }
    function getAccountCollateralValue(address user) external returns(uint totalCollateralValueinUSd){
    // loop through each collateral token, get the amount they have deposited and map it to
    // the price to get the usd value
    for(uint i=0;i<s_collateralTokens.length;i++){
     address token = s_collateralTokens[i];
     uint amount=s_collateralDeposited[user][token];
     totalCollateralValueinUSd+=getUsdValue(token,amount);

     return totalCollateralValueinUSd;
  
     
    }
    }
    function getUsdValue(address token,uint amount) public returns(uint){
     address pricefeedAddress = s_pricefeed[token];
     AggregatorV3Interface pricefeed = AggregatorV3Interface(pricefeedAddress);
     (,int price,,,) = pricefeed.latestRoundData();
     
     return  ((uint(price)*ADDITIONAL_FEED_BUFFER)*amount)/ PRECISION;
    }
    function _getAccountInformation(address user) private returns(uint totaldscAmount,uint collateralValueInUsd){
      totaldscAmount=s_dscMinted[user];
      collateralValueInUsd= this.getAccountCollateralValue(user);
     

    }
    function _healthFactor(address user)public returns(uint){
      // 1.Get the total collateral value in usd
      // 2.Get the total dsc minted
      // 3.Apply the formula (total collateral value/total dsc minted)*100
      (uint totaldscAmount,uint collateralValueInUsd)=_getAccountInformation(user);
       uint collateralAdjustedThreshold=(collateralValueInUsd*LIQUIDATION_PRECISION)/totaldscAmount;
      //1000 eth *50=50000/100=500
      //return collateralAdjustedThreshold/totaldscAmount;
    

    }

    function _revertIfHealthFactorisBroken(address user)private {
     // 1.Checks healthfactor
     // 2.Revert if they dont
     if(_healthFactor(user)<MINIMUM_HEALTH_FACTOR){
      revert Dsc_TransferFailed();
     }
    }
    
    

}