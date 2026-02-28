//SPDX-License_Identifier:MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe,WithdrawFundMe} from "../../script/Interaction.s.sol";

contract InteractionsTest is Test{
    
    FundMe fundMe;
    address USER=makeAddr("user");
    uint SENDING_VALUE=0.1 ether;
    uint STARTING_VALUE=1 ether;
    uint GAS_PRICE=1;
  
    function setUp() external{
      
        // fundMe =new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); to avoid manuakky adding pricefeed in deplo and here
         DeployFundMe deploy=new DeployFundMe();
         fundMe=deploy.run();
    }
    function testUserCanFundInteractions() public{
        FundFundMe fundFundMe=new FundFundMe();
         vm.deal(address(fundFundMe),STARTING_VALUE);
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe=new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
        assert(address(fundMe).balance==0);
}
}