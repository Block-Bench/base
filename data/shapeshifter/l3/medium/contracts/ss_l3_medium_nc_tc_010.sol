pragma solidity ^0.4.19;


contract CreditSystem {
    mapping(address => uint256) public _0x878a51;
    uint256 public balance;

    function _0xee8090() public payable {
        _0x878a51[msg.sender] += msg.value;
        balance += msg.value;
    }

    function _0x2159d1() public {
        uint256 _0x28a923 = _0x878a51[msg.sender];
        if (_0x28a923 > 0) {
            balance -= _0x28a923;
            bool _0x98b1ae = msg.sender.call.value(_0x28a923)();
            require(_0x98b1ae);
            _0x878a51[msg.sender] = 0;
        }
    }

    function _0xebe522(address _0x443efc) public view returns (uint256) {
        return _0x878a51[_0x443efc];
    }
}