// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract CredentialSaleChallenge {
    mapping(address => uint256) public balanceOf;
    uint256 constant cost_per_badge = 1 ether;

    function CredentialSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function verifyComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function buy(uint256 numCredentials) public payable {
        require(msg.value == numCredentials * cost_per_badge);
        balanceOf[msg.sender] += numCredentials;
    }

    function sell(uint256 numCredentials) public {
        require(balanceOf[msg.sender] >= numCredentials);

        balanceOf[msg.sender] -= numCredentials;
        msg.sender.transfer(numCredentials * cost_per_badge);
    }
}