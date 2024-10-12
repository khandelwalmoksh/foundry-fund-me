// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract SimpleStorage {
    uint256 public MyNumber;

    struct Person {
        string Name;
        uint256 FavNumber;
    }

    Person[] public listofPeople;
    mapping(string => uint256) public NametoFavNumber;

    function store(uint256 _favNumber) public virtual {
        MyNumber = _favNumber;
    }

    function retreive() public view returns (uint256) {
        return MyNumber;
    }

    function addPerson(string memory _Name, uint256 _FavNumber) public {
        listofPeople.push(Person(_Name, _FavNumber));
        NametoFavNumber[_Name] = _FavNumber;
    }
}

contract SimpleStorage2 {}

contract SimpleStorage3 {}

contract SimpleStorage4 {}
