//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {IERC20,SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol" ;
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirDrop {
 using SafeERC20 for IERC20;
  error MerkleAirDrop_InvalidProof();
  error MerkleAirDrop_AlreadyClaimed();

  address[] claimers;
  bytes32 private immutable i_merkleRoots;
  IERC20 private immutable i_airdropToken;
  mapping(address => bool) private s_hasClaimed;

  event Claim(address account, uint amount);

   constructor(bytes32 merkleRoot, IERC20 airdropToken){
    i_merkleRoots = merkleRoot;
    i_airdropToken= airdropToken;
   }

  function claim(address account ,uint amount,bytes32[] calldata merkleProof) external {
    if(s_hasClaimed[account]){
     revert MerkleAirDrop_AlreadyClaimed();
   }

    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account,amount))));
    if(!MerkleProof.verify(merkleProof,i_merkleRoots,leaf)){
        revert MerkleAirDrop_InvalidProof();
    }
   
    i_airdropToken.safeTransfer(account,amount);
     emit Claim(account,amount);
  }

  function getMerkleRoot() external returns(bytes32){
    return i_merkleRoots;
  }
  function getAirDropToken() external returns(IERC20){
    return i_airdropToken;
  }
}