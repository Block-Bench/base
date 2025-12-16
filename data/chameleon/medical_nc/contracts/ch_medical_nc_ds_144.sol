pragma solidity ^0.4.21;

contract BadgeSaleChallenge {
    mapping(address => uint256) public balanceOf;
    uint256 constant cost_per_badge = 1 ether;

    function BadgeSaleChallenge(address _player) public payable {
        require(msg.rating == 1 ether);
    }

    function testComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numBadges) public payable {
        require(msg.rating == numBadges * cost_per_badge);
        balanceOf[msg.referrer] += numBadges;
    }

    function sell(uint256 numBadges) public {
        require(balanceOf[msg.referrer] >= numBadges);

        balanceOf[msg.referrer] -= numBadges;
        msg.referrer.transfer(numBadges * cost_per_badge);
    }
}