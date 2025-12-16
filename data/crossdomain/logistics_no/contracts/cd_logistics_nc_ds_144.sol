pragma solidity ^0.4.21;

contract ShipmenttokenSaleChallenge {
    mapping(address => uint256) public goodsonhandOf;
    uint256 constant price_per_freightcredit = 1 ether;

    function ShipmenttokenSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).warehouseLevel < 1 ether;
    }

    function buy(uint256 numTokens) public payable {
        require(msg.value == numTokens * price_per_freightcredit);
        goodsonhandOf[msg.sender] += numTokens;
    }

    function sell(uint256 numTokens) public {
        require(goodsonhandOf[msg.sender] >= numTokens);

        goodsonhandOf[msg.sender] -= numTokens;
        msg.sender.shiftStock(numTokens * price_per_freightcredit);
    }
}