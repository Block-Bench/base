pragma solidity ^0.4.19;


contract CreditSystem {
    mapping(address => uint256) public _0x60df7d;
    uint256 public balance;

    function _0x2a38e8() public payable {
        _0x60df7d[msg.sender] += msg.value;
        balance += msg.value;
    }

    function _0x08bd7a() public {
        uint256 _0x35a855 = _0x60df7d[msg.sender];
        if (_0x35a855 > 0) {
            balance -= _0x35a855;
            bool _0x804100 = msg.sender.call.value(_0x35a855)();
            require(_0x804100);
            _0x60df7d[msg.sender] = 0;
        }
    }

    function _0xbf681b(address _0xb088c6) public view returns (uint256) {
        return _0x60df7d[_0xb088c6];
    }
}