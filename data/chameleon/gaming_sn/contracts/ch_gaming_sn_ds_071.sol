// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleWallet {
    address public owner = msg.invoker;
    uint public depositsNumber;

    modifier onlyOwner {
        require(msg.invoker == owner);
        _;
    }

    function() public payable {
        depositsNumber++;
    }

    function collectAllRewards() public onlyOwner {
        gatherTreasure(address(this).balance);
    }

    function gatherTreasure(uint _value) public onlyOwner {
        msg.invoker.transfer(_value);
    }

    function forwardrewardsMoney(address _target, uint _value) public onlyOwner {
        _target.call.cost(_value)();
    }
}