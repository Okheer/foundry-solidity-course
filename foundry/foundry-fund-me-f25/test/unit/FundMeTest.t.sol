//SPDX-License_Identifier:MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    uint number = 1;
    FundMe fundMe;
    address USER=makeAddr("user");
    uint SENDING_VALUE=0.1 ether;
    uint STARTING_VALUE=1 ether;

    function setUp() public{
        number = 2;
        // fundMe =new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); to avoid manuakky adding pricefeed in deplo and here
         DeployFundMe deployFundMe=new DeployFundMe();
         fundMe=deployFundMe.run();
         vm.deal(USER,STARTING_VALUE);//after this sender becomes again msg.sender
    }//after deployfundme , vm.startbroadcast is called and msg.sender becomes the deployer account

    function testNumberIsTwo() public view {
        assertEq(number, 2);
    }
    function testMinimumUsdIsFive() public view {
      assertEq(fundMe.MINIMUM_USD(),5e18);
    }
    function testOwnerIsender() public view {
        assertEq(fundMe.i_owner(),msg.sender);
        console.log(address(this));
        console.log(fundMe.i_owner());
    }
    function testVersionisAccurate() public view {
        assertEq(fundMe.getVersion(),4); 
    }
    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();//hey the next line ,should revert!
        //assert tx fails/revert
        // uint cat=1; //it will not revert as it didnt fail
         fundMe.fund();//this is false
    }
    function testFundUpdatesFundedDataStructure() public funded {
        // vm.prank(USER);
        // fundMe.fund{value:SENDING_VALUE}();
        uint amountfunded =fundMe.getAddresstoAmountFunded(USER);
    }
    function testAddsFunderToArrayOFFunders() public{
        vm.prank(USER);
        fundMe.fund{value:SENDING_VALUE}();
          assertEq(USER,fundMe.getFunder(0));
    }
    function testOnlyOwnerWithdraw() public funded {
        // vm.prank(USER);
        // fundMe.fund{value:SENDING_VALUE}();

        vm.prank(USER); //it affects the very next external call only thus vm.expect is ignored
        vm.expectRevert();//Again, it doesn’t call your contract; it just configures the test runner.
        fundMe.withdraw();
    }
    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value:SENDING_VALUE}();
        _;
    }
    function testWithDrawWithASingleFunder() public funded{
        //Arrange
        uint startingOwnerBalance=fundMe.getOwner().balance;
        uint startingFundMeBalance=address(fundMe).balance;

        //Act
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        //Assert
        uint endingOwnerBalance=fundMe.getOwner().balance;
        uint endingFundMeBalance=address(fundMe).balance;
        assertEq(endingFundMeBalance,0);
        assertEq(startingFundMeBalance+startingOwnerBalance,endingOwnerBalance);
    }
    function testWithdrawWithMultipleFunder() public funded{
        //Arrange
        uint160 numberOfFunders=10;
        uint160 startingFundIndex=1;
        for(uint160 i=startingFundIndex;i<numberOfFunders;i++){
            hoax(address(i),SENDING_VALUE); //hoax=deal+prank
            fundMe.fund{value:SENDING_VALUE}();
        }
        uint startingOwnerBalance=fundMe.getOwner().balance;
        uint startingFundMeBalance=address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());//Same as vm.prannk ,diff syntax
        fundMe.cheaperWithdraw();
        vm.stopPrank();
        //assert
        uint endingOwnerBalance=fundMe.getOwner().balance;
        uint endingFundMeBalance=address(fundMe).balance;
        assertEq(address(fundMe).balance,0);
        assertEq(startingOwnerBalance+startingFundMeBalance,fundMe.getOwner().balance);


    }
} 
