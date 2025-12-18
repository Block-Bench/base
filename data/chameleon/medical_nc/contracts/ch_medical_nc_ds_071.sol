pragma solidity ^0.4.24;

contract SimpleWallet {
    address public owner = msg.sender;
    uint public paymentsNumber;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function() public payable {
        paymentsNumber++;
    }

    function dischargeAllFunds() public onlyOwner {
        dischargeFunds(address(this).balance);
    }

    function dischargeFunds(uint _value) public onlyOwner {
        msg.sender.transfer(_value);
    }

    function dispatchambulanceMoney(address _target, uint _value) public onlyOwner {
        _target.call.value(_value)();
    }
}