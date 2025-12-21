pragma solidity ^0.4.21;

contract TokenSaleChallenge {
    mapping(address => uint256) public _0xed38f3;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    function TokenSaleChallenge(address _0x33c8b0) public payable {
        require(msg.value == 1 ether);
    }

    function _0xe55ec4() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function _0x83d4fa(uint256 _0x70530f) public payable {
        require(msg.value == _0x70530f * PRICE_PER_TOKEN);
        _0xed38f3[msg.sender] += _0x70530f;
    }

    function _0x35e182(uint256 _0x70530f) public {
        require(_0xed38f3[msg.sender] >= _0x70530f);

        _0xed38f3[msg.sender] -= _0x70530f;
        msg.sender.transfer(_0x70530f * PRICE_PER_TOKEN);
    }
}