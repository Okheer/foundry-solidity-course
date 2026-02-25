//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

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
contract DscEngine{
    error Drc_AmountisGreaterThanZero();
    error Drc_lengthTokenAddressisnotEqualToLEngthPricefeed();
    error Drc_ZeroAddressisNotAcceptable();

    address private i_Dsc;
    mapping(address=>address) private s_pricefeed;
    mapping(address=>mapping(address=>uint)) private s_collateralDeposited;

    constructor(address[] memory tokenAddress, address[] memory pricefeed, address DscAddress){
      if(tokenAddress.length!=pricefeed.length){
        revert Drc_lengthTokenAddressisnotEqualToLEngthPricefeed();
      }
     for(uint i=0;i<tokenAddress.length;i++){
       s_pricefeed[tokenAddress[i]]=pricefeed[i];
     }
     i_Dsc=DscAddress;
    }

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
    function depositCollateralandMintDsc(address tokenAddress,uint amount) 
    external amountmustbepositive(amount){
     if(tokenAddress==address(0)){
      revert Drc_ZeroAddressisNotAcceptable();
     }
     s_collateralDeposited[msg.sender][tokenAddress]+=amount;

    }
}