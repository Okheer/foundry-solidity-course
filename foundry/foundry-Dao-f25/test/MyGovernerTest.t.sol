//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Box} from "../src/Box.sol";
import {GovToken} from "../src/GovToken.sol";
import {TimeLock} from "../src/TimeLock.sol";
import {MyGovernor} from "../src/MyGoverner.sol";
import {Test} from "forge-std/Test.sol";

contract MyGovernerTest is Test{
    GovToken token;
    Box box;
    address USER=makeAddr("user");
    uint MIN_DELAY=3600;
    address[] proposers;
    address[] executioner;
    MyGovernor governer;
    TimeLock timelock;
    

    function setUp() external {
   
     token=new GovToken();
     token.mint(USER,100e18);

     vm.startPrank(USER);
     token.delegate(USER);
     timelock=new TimeLock(MIN_DELAY,proposers,executioner);
     governer=new MyGovernor(token,timelock);
     bytes32 proposerRole = timelock.PROPOSER_ROLE();
     bytes32 executionerRole= timelock.EXECUTOR_ROLE();
     bytes32 adminRole=timelock.DEFAULT_ADMIN_ROLE();

     timelock.grantRole(proposerRole, address(governer));
     timelock.grantRole(executionerRole,address(0));
     timelock.revokeRole(adminRole,address(USER));
     vm.stopPrank();
     box= new Box();
     box.transferOwnership(address(timelock));

    }
    function testCantUpdateBoxWithoutGovernance() public {
        vm.expectRevert();
        box.store(1);
    }
}

