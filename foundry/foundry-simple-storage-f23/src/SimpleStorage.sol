// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

contract SimpleStorage {
    // boolean,int(pos or neg int),uint(pos int),address,byte
    bool hasFavouriteNum = true;
    int FavouriteNum = -5;
    string FavouriteNumInString = "Hello";
    bytes Fav = "cat";
    uint public myfavoriteNumber = 5; //Not assigning value means assigning 0

    // not writing after uint is same as writong internal
    //   address FavAdress=
    function store(uint256 _favouriteNumber) public virtual {
        //to make it overridable
        myfavoriteNumber = _favouriteNumber;
        // uint256 testvar=5;
    }

    //   function something() public{
    //      testvar=6; // It is blockscopr, ie variable could be only called when it is in the same curly
    //     favoriteNumber=7;//it works fine here as this variable is in the some
    //   }

    function retrieve() public view returns (uint128) {
        return uint128(myfavoriteNumber);
        //view=disallow cahnge but read state fromblockchain
        //pure=disallow read and change
    }

    //uint256[ listoffavorite;
    struct Person {
        uint favoriteNumber;
        string name;
    } //static array only fix amount of element
    Person[] public listOfPeople; //[]
    mapping(string => uint) public nameToFavoriteNumber;

    function addPerson(string memory _name, uint _favoriteNumber) public {
        listOfPeople.push(Person(_favoriteNumber, _name));
        nameToFavoriteNumber[_name] = _favoriteNumber;
    }

    // Person public pat=Person({favoriteNumber:7, name:"Pat"}) ;
}

contract SimpleStorage2 {}
