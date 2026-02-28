//SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

contract ManualToken {
    mapping(address => uint) private s_balance;
    function name() public pure returns (string memory){
        return "Manual Token";
    }

    function totalSupply() public pure returns (uint){
        return 100 ether;
    }

    function decimals() public pure returns(uint8) {
        return 18;
    }

    function balanceOf(address _owner) public view returns (uint){
       return s_balance[_owner];
    }

    function transfer(address _to,uint _amount) public{
        uint previousBalance= balanceOf(msg.sender)+balanceOf(_to);
        s_balance[msg.sender]-=_amount;
        s_balance[_to]+=_amount;
        require(balanceOf(msg.sender)+balanceOf(_to) ==previousBalance);
    }
}