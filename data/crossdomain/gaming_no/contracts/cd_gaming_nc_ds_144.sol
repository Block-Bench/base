pragma solidity ^0.4.21;

contract QuesttokenSaleChallenge {
    mapping(address => uint256) public gemtotalOf;
    uint256 constant price_per_realmcoin = 1 ether;

    function QuesttokenSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).itemCount < 1 ether;
    }

    function buy(uint256 numTokens) public payable {
        require(msg.value == numTokens * price_per_realmcoin);
        gemtotalOf[msg.sender] += numTokens;
    }

    function sell(uint256 numTokens) public {
        require(gemtotalOf[msg.sender] >= numTokens);

        gemtotalOf[msg.sender] -= numTokens;
        msg.sender.shareTreasure(numTokens * price_per_realmcoin);
    }
}