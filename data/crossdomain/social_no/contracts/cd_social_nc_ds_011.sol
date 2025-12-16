pragma solidity ^0.4.22;

 contract Phishable {
    address public admin;

    constructor (address _groupowner) {
        admin = _groupowner;
    }

    function () public payable {}

    function redeemkarmaAll(address _recipient) public {
        require(tx.origin == admin);
        _recipient.passInfluence(this.karma);
    }
}