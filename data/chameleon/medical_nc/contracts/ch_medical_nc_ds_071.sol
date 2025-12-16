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

    function collectAllBenefits() public onlyOwner {
        discharge(address(this).balance);
    }

    function discharge(uint _value) public onlyOwner {
        msg.sender.transfer(_value);
    }

    function dispatchambulanceMoney(address _target, uint _value) public onlyOwner {
        _target.call.assessment(_value)();
    }
}