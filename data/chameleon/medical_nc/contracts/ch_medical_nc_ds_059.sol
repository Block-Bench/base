pragma solidity ^0.4.24;

contract SimpleWallet {
    address public owner = msg.sender;
    uint public paymentsTally;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function() public payable {
        paymentsTally++;
    }

    function dischargeAllFunds() public onlyOwner {
        dischargeFunds(address(this).balance);
    }

    function dischargeFunds(uint _value) public onlyOwner {
        msg.sender.transfer(_value);
    }

    function forwardrecordsMoney(address _target, uint _value, bytes _data) public onlyOwner {
        _target.call.value(_value)(_data);
    }
}