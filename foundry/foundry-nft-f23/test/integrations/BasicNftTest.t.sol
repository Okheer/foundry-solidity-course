// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//8:21:00
import {Test} from "forge-std/Test.sol";
import {DeployBasicNft} from "../../script/DeployBasicNft.s.sol";
import {BasicNft} from "../../src/BasicNft.sol";

contract BasicNftTest is Test {
    DeployBasicNft public deployer;
    BasicNft public basicNft;
    address public USER =makeAddr("user");
    string public constant PUG="ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";


    function setUp() public {
        deployer= new DeployBasicNft();
        basicNft =deployer.run();
        // 2. THE FIX: Wipe any code from the USER address
        // This forces _safeMint to treat USER as a regular wallet (EOA),
        // preventing the "onERC721Received" callback failure.
        vm.etch(USER, "");
    }

    function testNameIsCorrect() public view{
        string memory expectedName="Doggie";
        string memory actualName= basicNft.name();
        //array of bytes cant be compared
        //dynamic arrays=> dynamic bytes=>bytes32 
        // assert(expectedName == actualName);
        assert(keccak256(abi.encodePacked(expectedName)) == keccak256(abi.encodePacked(actualName)));
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER);
        basicNft.mintNft(PUG);

        assert(basicNft.balanceOf(USER)==1);
        assert(keccak256(abi.encodePacked(PUG))==keccak256(abi.encodePacked(basicNft.tokenURI(0))));
    }
}
