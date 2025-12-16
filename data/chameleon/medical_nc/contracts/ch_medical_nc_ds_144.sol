pragma solidity ^0.4.21;

contract BadgeSaleChallenge {
    mapping(address => uint256) public balanceOf;
    uint256 constant cost_per_badge = 1 ether;

    function BadgeSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function testComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numBadges) public payable {
        require(msg.value == numBadges * cost_per_badge);
        balanceOf[msg.sender] += numBadges;
    }

    function sell(uint256 numBadges) public {
        require(balanceOf[msg.sender] >= numBadges);

        balanceOf[msg.sender] -= numBadges;
        msg.sender.transfer(numBadges * cost_per_badge);
    }
}