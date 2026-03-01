//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MoodNft} from "../src/MoodNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {console} from "forge-std/console.sol";


contract DeployMoodNft is Script{
  
  function run() external returns (MoodNft) {
      string memory sadSvg = vm.readFile("./img/Sad.svg");
        string memory happySvg = vm.readFile("./img/Happy.svg");

        vm.startBroadcast();
        MoodNft moodNft = new MoodNft(svgToImageURI(sadSvg), svgToImageURI(happySvg));
        vm.stopBroadcast();
        return moodNft;
  }

  function svgToImageURI(
    string memory svg
  ) public pure returns (string memory) {
    //   example
    //   <svg width="1024px" height="1024px" ...>
    //   data:image/svg+xml;base64,hash
      string memory baseURL = "data:image/svg+xml;base64,";
      string memory svgBase64Encoded = Base64.encode(
        bytes(string(abi.encodePacked(svg)))
      );
      return string(abi.encodePacked(baseURL, svgBase64Encoded));
  }
}