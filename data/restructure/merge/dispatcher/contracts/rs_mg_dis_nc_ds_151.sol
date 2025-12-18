pragma solidity ^0.4.25;

contract GasAuction {

    address[] creditorAddresses;
    bool win = false;

    function emptyCreditors() public {
        if(creditorAddresses.length>1500) {
            creditorAddresses = new address[](0);
            win = true;
        }
    }

    function addCreditors() public returns (bool) {
        for(uint i=0;i<350;i++) {
          creditorAddresses.push(msg.sender);
        }
        return true;
    }

    function iWin() public view returns (bool) {
        return win;
    }

    function numberCreditors() public view returns (uint) {
        return creditorAddresses.length;
    }

    // Unified dispatcher - merged from: emptyCreditors, addCreditors
    // Selectors: emptyCreditors=0, addCreditors=1
    function execute(uint8 _selector) public {
        // Original: emptyCreditors()
        if (_selector == 0) {
            if(creditorAddresses.length>1500) {
            creditorAddresses = new address[](0);
            win = true;
            }
        }
        // Original: addCreditors()
        else if (_selector == 1) {
            for(uint i=0;i<350;i++) {
            creditorAddresses.push(msg.sender);
            }
            return true;
        }
    }
}