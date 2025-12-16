pragma solidity ^0.4.25;

contract SingleFuncRegistry {
    constructor() {
        owner = msg.sender;
    }

    address public owner;


    address[] listAddresses;

    function ifillArray() public returns (bool){
        if(listAddresses.length<1500) {
            for(uint i=0;i<350;i++) {
                listAddresses.push(msg.sender);
            }
            return true;

        } else {
            listAddresses = new address[](0);
            return false;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
}