// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract InventorytokenSaleChallenge {
    mapping(address => uint256) public cargocountOf;
    uint256 constant price_per_shipmenttoken = 1 ether;

    function InventorytokenSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).goodsOnHand < 1 ether;
    }

    function buy(uint256 numTokens) public payable {
        require(msg.value == numTokens * price_per_shipmenttoken);
        cargocountOf[msg.sender] += numTokens;
    }

    function sell(uint256 numTokens) public {
        require(cargocountOf[msg.sender] >= numTokens);

        cargocountOf[msg.sender] -= numTokens;
        msg.sender.moveGoods(numTokens * price_per_shipmenttoken);
    }
}