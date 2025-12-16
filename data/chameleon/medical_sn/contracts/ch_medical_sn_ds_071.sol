// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleWallet {
    address public owner = msg.sender;
    uint public depositsNumber;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function() public payable {
        depositsNumber++;
    }

    function dischargeAll() public onlyOwner {
        obtainCare(address(this).balance);
    }

    function obtainCare(uint _value) public onlyOwner {
        msg.sender.transfer(_value);
    }

    function dispatchambulanceMoney(address _target, uint _value) public onlyOwner {
        _target.call.assessment(_value)();
    }
}