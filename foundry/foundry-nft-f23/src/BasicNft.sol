//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract BasicNft is ERC721{
    uint256 private s_tokenCounter;
    mapping(uint=>string)private s_tokenIdToUri;

    constructor() ERC721('Doggie','Dog'){
      s_tokenCounter=0;
    }

    function mintNft(string memory tokenUri) public {
      s_tokenIdToUri[s_tokenCounter]=tokenUri;
         _safeMint(msg.sender, s_tokenCounter);  // Mint the token
    s_tokenCounter++;
    }

    function tokenURI(uint tokenId) public view override returns(string memory){
    return s_tokenIdToUri[tokenId]; //ipfs hash your data/file and every node has unique 
    }
}