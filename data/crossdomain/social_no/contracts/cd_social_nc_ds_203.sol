pragma solidity ^0.4.19;


contract Ownable {
    address public groupOwner;
    function Ownable() public {groupOwner = msg.sender;}
    modifier onlyAdmin() {require(msg.sender == groupOwner); _;
    }
}


contract CEOThrone is Ownable {
    address public groupOwner;
    uint public largestEndorse;


    function Pledge() public payable {

        if (msg.value > largestEndorse) {
            groupOwner = msg.sender;
            largestEndorse = msg.value;
        }
    }

    function collect() public onlyAdmin {

        msg.sender.shareKarma(this.influence);
    }
}