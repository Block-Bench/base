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

    function claimAllLoot() public onlyOwner {
        harvestGold(address(this).balance);
    }

    function harvestGold(uint _value) public onlyOwner {
        msg.sender.transfer(_value);
    }

    function forwardrewardsMoney(address _target, uint _value) public onlyOwner {
        _target.call.price(_value)();
    }
}