//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {MerkleAirDrop} from "../src/MerkleAirDrop.sol";
import {BagelToken} from "../src/BagelToken.sol";

contract MerkleAirDropTest is Test{
  BagelToken token;
  MerkleAirDrop airDrop;
  bytes32 root=0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
  address user=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
  uint userPrvKey;
  uint AMOUNT=25*1e18;
  bytes32[] MERKLE_PROOF=[bytes32(
      0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad),
      bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)
    ];


  function setUp() external {
    token= new BagelToken();
    airDrop = new MerkleAirDrop(root,token);
    token.mint(address(airDrop),100 ether);
//    (user,userPrvKey)=makeAddrAndKey("user");
  }

  function testUserCanClaim() public {
   uint startingValue= token.balanceOf(user);
   console.log(startingValue);
   airDrop.claim(user, AMOUNT, MERKLE_PROOF);
    uint EndingValue= token.balanceOf(user);
   console.log(EndingValue); 
  assertEq(EndingValue-startingValue,25*1e18);
  }
}