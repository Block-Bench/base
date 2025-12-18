pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) _0x46d817;
    uint balance;

    function _0x18100a() public {
        uint _0x812419 = _0x46d817[msg.sender];
        if (_0x812419 > 0) {
            balance -= _0x812419;
            bool _0xeba297 = msg.sender.call.value(_0x812419)();
            require (_0xeba297);
            _0x46d817[msg.sender] = 0;
        }
    }

    function _0x78871f() public payable {
        _0x46d817[msg.sender] += msg.value;
        balance += msg.value;
    }
}