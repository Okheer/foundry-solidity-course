//SPDX-License-Identifier:MIT

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Box is Ownable(msg.sender){
    uint private s_number;

    event NumberChanged(uint num);

    function store(uint num) external onlyOwner(){
        s_number=num;
        emit NumberChanged(num);
    }

    function getNumber() external view returns(uint s_number){
     

    }
}
