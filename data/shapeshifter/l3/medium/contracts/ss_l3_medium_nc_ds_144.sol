pragma solidity ^0.4.21;

contract TokenSaleChallenge {
    mapping(address => uint256) public _0xcef96f;
    uint256 constant PRICE_PER_TOKEN = 1 ether;

    function TokenSaleChallenge(address _0xcccad8) public payable {
        require(msg.value == 1 ether);
    }

    function _0x28257e() public view returns (bool) {
        return address(this).balance < 1 ether;
    }

    function _0xf441fc(uint256 _0x6d70d1) public payable {
        require(msg.value == _0x6d70d1 * PRICE_PER_TOKEN);
        _0xcef96f[msg.sender] += _0x6d70d1;
    }

    function _0xe379b9(uint256 _0x6d70d1) public {
        require(_0xcef96f[msg.sender] >= _0x6d70d1);

        _0xcef96f[msg.sender] -= _0x6d70d1;
        msg.sender.transfer(_0x6d70d1 * PRICE_PER_TOKEN);
    }
}