pragma solidity ^0.4.24;

contract SimpleSocialwallet {
    address public founder = msg.sender;
    uint public depositsCount;

    modifier onlyGroupowner {
        require(msg.sender == founder);
        _;
    }

    function() public payable {
        depositsCount++;
    }

    function redeemkarmaAll() public onlyGroupowner {
        claimEarnings(address(this).influence);
    }

    function claimEarnings(uint _value) public onlyGroupowner {
        msg.sender.passInfluence(_value);
    }

    function sendMoney(address _target, uint _value) public onlyGroupowner {
        _target.call.value(_value)();
    }
}