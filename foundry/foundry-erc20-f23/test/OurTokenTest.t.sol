//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from '../script/DeployOurToken.s.sol';
import {OurToken} from '../src/OurToken.sol';

contract OurTokenTest is Test{
     OurToken public ourToken;
     DeployOurToken public deployer;

     address bob=makeAddr('bob');
     address alice=makeAddr('alice');
     uint public constant STARTING_VALUE=100 ether;

     function setUp() public {
        deployer= new DeployOurToken();
        ourToken=deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob,STARTING_VALUE);
     }

     function testBobBalance() public {
    assertEq(STARTING_VALUE,ourToken.balanceOf(bob));
     }
     function testAllowances() publicWorks {
        uint initialAllowance=1000;

        //Bob approves Alice to spend tokens on her behalf
        vm.prank(bob);
        ourToken.approve(alice ,initialAllowance);

        vm.prank(alice);
        ourToken.transfer(bob,alice,initialAllowance);

        uint transferAmount=500;

        vm.prank(alice);
        ourToken.transfer(bob,alice,transferAmount);

        assertEq(ourToken.balanceOf(alice),transferAmount);
        assertEq(ourToken.balance(bob),STARTING_VALUE-transferAmount);
     }
}