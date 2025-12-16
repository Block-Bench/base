pragma solidity ^0.4.21;

contract CoinSaleChallenge {
    mapping(address => uint256) public balanceOf;
    uint256 constant cost_per_medal = 1 ether;

    function CoinSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function validateComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numMedals) public payable {
        require(msg.value == numMedals * cost_per_medal);
        balanceOf[msg.sender] += numMedals;
    }

    function sell(uint256 numMedals) public {
        require(balanceOf[msg.sender] >= numMedals);

        balanceOf[msg.sender] -= numMedals;
        msg.sender.transfer(numMedals * cost_per_medal);
    }
}