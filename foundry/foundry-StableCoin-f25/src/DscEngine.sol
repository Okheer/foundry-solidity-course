//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
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
    error dsc_UserIsHealthy();
    error Dsc_HealthFactorNotImproved();
    error DSCEngine__TokenNotAllowed(address token);
    
    uint private constant ADDITIONAL_FEED_BUFFER=1e10;// to accomodate for feed price fluctuation
    uint private constant PRECISION=1e18;
    uint private constant LIQUIDATION_THRESHOLD=50;
    uint private constant LIQUIDATION_PRECISION=100;
    uint private constant MINIMUM_HEALTH_FACTOR=1;
    uint private constant LIQUIDATION_REWARD=10;

    

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
    event CollateralRedeemed(address indexed redeemFrom, address indexed redeemTo, address token, uint256 amount); 
    

    
    modifier isAllowedToken(address token) {
        if (s_pricefeed[token] == address(0)) {
            revert DSCEngine__TokenNotAllowed(token);
        }
        _;}
    modifier amountmustbepositive(uint amount){
      if(amount<=0){
        revert Drc_AmountisGreaterThanZero();
      }
      _;
    }
    modifier tokenAddressisValid(address tokenAddress){
     
      _;
    }

    function depositCollateralAndMint(address tokenCollateralAddress, uint amountCollateral, uint amountDscToMint) external isAllowedToken(tokenCollateralAddress) {
      depositCollateral(tokenCollateralAddress,amountCollateral);
      mintDsc(amountDscToMint);
    }
    /*
    *@para: tokenAddress: address of token
    *@para: amount:amount of token
     */
    function depositCollateral(address tokenAddress,uint amount) 
    public amountmustbepositive(amount) isAllowedToken(tokenAddress){
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

    function mintDsc(uint amount) public {
     s_dscMinted[msg.sender]+=amount;
      _revertIfHealthFactorisBroken(msg.sender);
      bool success=i_Dsc.mint(msg.sender,amount);
      if(!success){
        revert Dsc_MintFailed();
      }
    }

    function redeemCollateralAndBurn(address tokenAddress, uint amountCollateral,uint amountToBurn) external isAllowedToken(tokenAddress){
      burnDsc(amountToBurn);
      redeemCollateral(tokenAddress,amountCollateral);

    }
     //In order to reddem collateral
     //health factor must not ge less than 1 after redeeming
    function redeemCollateral(address tokenAddress, uint amount) public amountmustbepositive(amount){
      _redeemCollateral(tokenAddress,amount, msg.sender, msg.sender);
     _revertIfHealthFactorisBroken(msg.sender);
    }

    function burnDsc(uint amountDscBurn) public{
      _burnDsc(amountDscBurn, msg.sender,msg.sender);

    }
    function liquidate(address collateral,address user, uint debtToCover) external {
      uint256 startingUserHealthFactor = _healthFactor(user);
    if(_healthFactor(user)>MINIMUM_HEALTH_FACTOR){
     revert dsc_UserIsHealthy();
    }
    uint tokenAmountFromDebtCovered= getTokenAmountFromUsd(collateral,debtToCover);
    //And give then 10% reward
    uint Bonus=(tokenAmountFromDebtCovered*LIQUIDATION_REWARD)/LIQUIDATION_PRECISION;
    uint  totalTokenToredeem=tokenAmountFromDebtCovered+Bonus;
    _redeemCollateral(collateral, totalTokenToredeem, user, msg.sender);
    _burnDsc(debtToCover, user, msg.sender);

    uint endingHealthFactor=_healthFactor(user);
    if(endingHealthFactor<=startingUserHealthFactor){
      revert Dsc_HealthFactorNotImproved();
    }
    _revertIfHealthFactorisBroken((msg.sender));

    //we need to burn mintdsc

    
    }
    
    function getTokenAmountFromUsd(address token, uint usdAmountinWei) public  view returns(uint){
      // $100e18 USD Debt
        // 1 ETH = 2000 USD
        // The returned value from Chainlink will be 2000 * 1e8
        // Most USD pairs have 8 decimals, so we will just pretend they all do
        //You want to know: "How many ETH tokens is $100 worth?
     AggregatorV3Interface pricefeed = AggregatorV3Interface(s_pricefeed[token]);
     (,int price,,,)=pricefeed.latestRoundData();
     return (usdAmountinWei* PRECISION)/(uint(price)*ADDITIONAL_FEED_BUFFER);
    }

    function getAccountCollateralValue(address user) public view returns(uint totalCollateralValueinUsd){
    // loop through each collateral token, get the amount they have deposited and map it to
    // the price to get the usd value
    for(uint i=0;i<s_collateralTokens.length;i++){
     address token = s_collateralTokens[i];
     uint amount=s_collateralDeposited[user][token];
     totalCollateralValueinUsd+=getUsdValue(token,amount);
  
     
    } return totalCollateralValueinUsd;
    }
    function getUsdValue(address token,uint amount) public view returns(uint){
     address pricefeedAddress = s_pricefeed[token];
     AggregatorV3Interface pricefeed = AggregatorV3Interface(pricefeedAddress);
     (,int price,,,) = pricefeed.latestRoundData();
     
     return  ((uint(price)*ADDITIONAL_FEED_BUFFER)*amount)/ PRECISION;
    }
    function getAccountInformation(address user) public view returns(uint totaldscAmount,uint collateralValueInUsd){
     return _getAccountInformation(user);
    }
    function getCollateralTokens() external view returns(address[] memory){
      return s_collateralTokens;
    }
    function getCollateralBalanceOfUser(address user,address token) external view returns(uint){
      return s_collateralDeposited[user][token];
    }

    
    function _redeemCollateral(address tokenAddress, uint amount, address from, address to) private{
      s_collateralDeposited[from][tokenAddress]-=amount;
     emit CollateralRedeemed( from,to, tokenAddress,amount);
     bool success=IERC20(tokenAddress).transfer(to,amount);
     if(!success){
      revert Dsc_TransferFailed();
     }
    }

    function _healthFactor(address user )public view returns(uint){
           (uint256 totalDscMinted, uint256 collateralValueInUsd) = _getAccountInformation(user);
        return _calculateHealthFactor(totalDscMinted, collateralValueInUsd);
      // 1.Get the total collateral value in usd
      // 2.Get the total dsc minted
      // 3.Apply the formula (total collateral value/total dsc minted)*100
   
      //1000 eth *50=50000/100=500
      //return collateralAdjustedThreshold/totaldscAmount;
    

    }
        function _calculateHealthFactor(
        uint256 totalDscMinted,
        uint256 collateralValueInUsd
    )
        internal
        pure
        returns (uint256)
    {
        if (totalDscMinted == 0) return type(uint256).max;
        uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;
    }
    /*low levelinternal functions are not called until another function calls it 
    */

    function _burnDsc(uint amountDscBurn,address onBehalfOf, address dscForm)internal {
     s_dscMinted[onBehalfOf]-=amountDscBurn;
      bool success=i_Dsc.transferFrom(msg.sender,address(this),amountDscBurn);
      if(!success){
        revert Dsc_TransferFailed();
      }
      i_Dsc.burn(amountDscBurn);
    }

    function _revertIfHealthFactorisBroken(address user)private  view {
     // 1.Checks healthfactor
     // 2.Revert if they dont
     if(_healthFactor(user)<MINIMUM_HEALTH_FACTOR){
      revert Dsc_TransferFailed();
     }
    }

    function _getAccountInformation(address user) private  view returns(uint totalDscMinted,uint collateralValueInUsd){
       totalDscMinted=s_dscMinted[user];
      collateralValueInUsd= getAccountCollateralValue(user);
    }
    
    

}