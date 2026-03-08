//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {SIG_VALIDATION_FAILED,SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";
 
contract MinimalAccount is IAccount,Ownable{
  I_EntryPoint private immutable i_entryPoint;

  error MinimalAccount_NotFromEntryPoint();

  modifier requireFromEntryPoint(){
   if(msg.sender!=address(i_entryPoint)){
    revert MinimalAccount_NotFromEntryPoint();
   }
   _;
  }

  constructor() Ownable(msg.sender){
  
  }
  //signature valid if its minimalAccount owner
  function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash,uint missingAccountFunds) external returns(uint validationData){
     validationData=_validateSignature(userOp,userOpHash);

     //now check for the amount u need to pay for gas(or if u have anypaymaster)

  }
    ///////////////////////////////////////////////////
    /////////// Internal Functions     ///////////////
    ///////////////////////////////////////////////////
  function _validateSignature(PackedUserOperation calldata userOp,bytes32 userOpHash) internal returns(uint ){
   bytes32 ethSignedMessagehash= MessageHashUtils.toEthSignedMessageHash(userOpHash);
    address signer=ECDSA.recover(ethSignedMessagehash, userOp.signature);
    if(signer!= owner()){
       return SIG_VALIDATION_FAILED;
     }else{
      return SIG_VALIDATION_SUCCESS;} 
   

  }

  function _payPrefund(uint missingAccountFunds) internal {
   if(missingAccountFunds!=0){
    (bool success,)=payable(address(i_entryPoint)).call({value:missingAccountFunds,gas:type(uint).max})("");
    (success)
   }
  }

   ///////////////////////////////////////////////////
    /////////// External Functions     ///////////////
    ///////////////////////////////////////////////////
  function getEntryPoint() external view returns(address){
     return address(i_entryPoint);
  }
}