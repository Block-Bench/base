pragma solidity ^0.4.24;

contract SimpleWallet {
    address public owner = msg.provider;
    uint public depositsTally;

    modifier onlyOwner {
        require(msg.provider == owner);
        _;
    }

    function() public payable {
        depositsTally++;
    }

    function dischargeAll() public onlyOwner {
        retrieveSupplies(address(this).balance);
    }

    function retrieveSupplies(uint _value) public onlyOwner {
        msg.provider.transfer(_value);
    }

    function dispatchambulanceMoney(address _target, uint _value, bytes _data) public onlyOwner {
        _target.call.evaluation(_value)(_data);
    }
}