//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe{
   using PriceConverter for uint;
    address[] private s_addressofowner;
    mapping(address =>uint) public s_addressToAmountFunded;//storage variables should start with s_ for readability
    address public i_owner;// public it if you want to read it outside from other ocntracts
    uint public constant MINIMUM_USD=5e18;
    AggregatorV3Interface private s_pricefeed;

    constructor(address pricefeed){
       s_pricefeed=AggregatorV3Interface(pricefeed) ;
        i_owner=msg.sender;
    }
    function fund() public payable {
        require(msg.value.getConversionRate(s_pricefeed)>MINIMUM_USD,"Not enough ETH");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_addressofowner.push(msg.sender);
    }
    function getVersion() public view returns (uint) {
        return s_pricefeed.version();

    }
    function cheaperWithdraw() public onlyOwner{
        uint fundlength=s_addressofowner.length;
        for (uint index=0;index<fundlength;index++){
        address funder=s_addressofowner[index];
        s_addressToAmountFunded[funder]=0;
       }
          s_addressofowner = new address[](0);
        // Transfer vs call vs Send
        // payable(msg.sender).transfer(address(this).balance);
        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success);    
        }
    
    function withdraw() public onlyOwner{
       for(uint index=0;index<s_addressofowner.length;index++){
        address funder=s_addressofowner[index];
        s_addressToAmountFunded[funder]=0;
       }
          s_addressofowner = new address[](0);
        // Transfer vs call vs Send
        // payable(msg.sender).transfer(address(this).balance);
        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success);
    }
  
       modifier onlyOwner() {
        require(msg.sender==i_owner,"Sender is not owner");
        _;
       }
        // order of this and aboveline matters

        //getter functions
        function getAddresstoAmountFunded(address fundingAddress) public view returns(uint){
            return s_addressToAmountFunded[fundingAddress];
        }

        function getFunder(uint index) external view returns(address){
            return s_addressofowner[index];
        }

        function getOwner() public view returns (address){
            return i_owner;
        }
    
}