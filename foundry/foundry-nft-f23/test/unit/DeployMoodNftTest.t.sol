//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Test,console} from "forge-std/Test.sol";
import {Base64} from  "@openzeppelin/contracts/utils/Base64.sol";
import {DeployMoodNft} from "../../script/DeployMoodNft.s.sol";

contract DeployMoodNftTest is Test {
    DeployMoodNft public deployer;

    function setUp() public {
        deployer =new DeployMoodNft();
    

    }
    function testConvertSvgToUri() public view{
        string memory expectedUri = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI1MDAiIGhlaWdodD0iNTAwIj4KPHRleHQgeD0iMTUiIHk9IjE1IiBmaWxsPSJibGFjayI+IGhpISBZb3UgZGVjb2RlZCB0aGlzISA8L3RleHQ+Cjwvc3ZnPg==";
       string memory svg = string(
    abi.encodePacked(
        '<svg xmlns="http://www.w3.org/2000/svg" width="500" height="500">',
        '\n', // The Base64 has a newline here
        '<text x="15" y="15" fill="black"> hi! You decoded this! </text>',
        '\n', // The Base64 has a newline here
        '</svg>'
    ));
        string memory actualUri = deployer.svgToImageURI(svg);
        assert(
            keccak256(abi.encodePacked(actualUri)) ==
                keccak256(abi.encodePacked(expectedUri)) 
        );    
    }
}