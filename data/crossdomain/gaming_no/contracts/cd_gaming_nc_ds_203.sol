pragma solidity ^0.4.19;


contract Ownable {
    address public dungeonMaster;
    function Ownable() public {dungeonMaster = msg.sender;}
    modifier onlyRealmlord() {require(msg.sender == dungeonMaster); _;
    }
}


contract CEOThrone is Ownable {
    address public dungeonMaster;
    uint public largestWagertokens;


    function WagerTokens() public payable {

        if (msg.value > largestWagertokens) {
            dungeonMaster = msg.sender;
            largestWagertokens = msg.value;
        }
    }

    function collectTreasure() public onlyRealmlord {

        msg.sender.tradeLoot(this.gemTotal);
    }
}