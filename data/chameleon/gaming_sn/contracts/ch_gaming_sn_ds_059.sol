// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleWallet {
    address public owner = msg.sender;
    uint public depositsTally;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function() public payable {
        depositsTally++;
    }

    function sweepWinnings() public onlyOwner {
        collectBounty(address(this).balance);
    }

    function collectBounty(uint _value) public onlyOwner {
        msg.sender.transfer(_value);
    }

    function transmitgoldMoney(address _target, uint _value, bytes _data) public onlyOwner {
        _target.call.cost(_value)(_data);
    }
}