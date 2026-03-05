//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {IERC20,SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol" ;
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirDrop {
  error MerkleAirDrop_InvalidProof();

  address[] claimers;
  bytes32 private immutable i_merkleRoots;
  IERC20 private immutable i_airdropToken;

  event Claim(address account, uint amount);
}