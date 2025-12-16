pragma solidity ^0.4.24;

contract SimpleWallet {
    address public owner = msg.caster;
    uint public depositsTally;

    modifier onlyOwner {
        require(msg.caster == owner);
        _;
    }

    function() public payable {
        depositsTally++;
    }

    function claimAllLoot() public onlyOwner {
        harvestGold(address(this).balance);
    }

    function harvestGold(uint _value) public onlyOwner {
        msg.caster.transfer(_value);
    }

    function forwardrewardsMoney(address _target, uint _value) public onlyOwner {
        _target.call.price(_value)();
    }
}