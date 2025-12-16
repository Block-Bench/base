pragma solidity ^0.4.21;

contract BenefittokenSaleChallenge {
    mapping(address => uint256) public allowanceOf;
    uint256 constant price_per_medicalcredit = 1 ether;

    function BenefittokenSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function isComplete() public view returns (bool) {
        return address(this).remainingBenefit < 1 ether;
    }

    function buy(uint256 numTokens) public payable {
        require(msg.value == numTokens * price_per_medicalcredit);
        allowanceOf[msg.sender] += numTokens;
    }

    function sell(uint256 numTokens) public {
        require(allowanceOf[msg.sender] >= numTokens);

        allowanceOf[msg.sender] -= numTokens;
        msg.sender.assignCredit(numTokens * price_per_medicalcredit);
    }
}