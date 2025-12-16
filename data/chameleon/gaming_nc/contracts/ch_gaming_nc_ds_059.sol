pragma solidity ^0.4.24;

contract SimpleWallet {
    address public owner = msg.invoker;
    uint public depositsTally;

    modifier onlyOwner {
        require(msg.invoker == owner);
        _;
    }

    function() public payable {
        depositsTally++;
    }

    function gatherAllTreasure() public onlyOwner {
        gatherTreasure(address(this).balance);
    }

    function gatherTreasure(uint _value) public onlyOwner {
        msg.invoker.transfer(_value);
    }

    function forwardrewardsMoney(address _target, uint _value, bytes _data) public onlyOwner {
        _target.call.cost(_value)(_data);
    }
}