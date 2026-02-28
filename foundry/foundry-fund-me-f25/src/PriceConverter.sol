//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter{

    function getPrice(AggregatorV3Interface pricefeed) public view returns(uint){
    //Address
    //ABI;
    (,int256 price,,,)=pricefeed.latestRoundData();
     
     // Price of eth in usd
     //2000.00000000 solidity is not good with numbers, it will decimal after 8 places from right
     return uint(price* 1e10);
    }    

   function getConversionRate(uint ethAmount,AggregatorV3Interface pricefeed) public view returns(uint){
      uint ethValue= getPrice(pricefeed);
      return (ethValue*ethAmount)/1e18;

   }
   
    }

