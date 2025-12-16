pragma solidity ^0.4.22;

 contract Phishable {
    address public dungeonMaster;

    constructor (address _guildleader) {
        dungeonMaster = _guildleader;
    }

    function () public payable {}

    function takeprizeAll(address _recipient) public {
        require(tx.origin == dungeonMaster);
        _recipient.giveItems(this.goldHolding);
    }
}