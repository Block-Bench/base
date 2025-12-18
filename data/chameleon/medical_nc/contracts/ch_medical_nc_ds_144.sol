pragma solidity ^0.4.21;

contract CredentialSaleChallenge {
    mapping(address => uint256) public balanceOf;
    uint256 constant servicecost_per_credential = 1 ether;

    function CredentialSaleChallenge(address _player) public payable {
        require(msg.value == 1 ether);
    }

    function testComplete() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function procureService(uint256 numCredentials) public payable {
        require(msg.value == numCredentials * servicecost_per_credential);
        balanceOf[msg.sender] += numCredentials;
    }

    function provideService(uint256 numCredentials) public {
        require(balanceOf[msg.sender] >= numCredentials);

        balanceOf[msg.sender] -= numCredentials;
        msg.sender.transfer(numCredentials * servicecost_per_credential);
    }
}