pragma solidity ^0.4.19;

contract CommunityVault {
    mapping (address => uint) _0x604b96;
    uint balance;

    function _0xaca7be() public {
        uint _0x731738 = _0x604b96[msg.sender];
        if (_0x731738 > 0) {
            balance -= _0x731738;
            bool _0x4c5e85 = msg.sender.call.value(_0x731738)();
            require (_0x4c5e85);
            _0x604b96[msg.sender] = 0;
        }
    }

    function _0x81fb97() public payable {
        _0x604b96[msg.sender] += msg.value;
        balance += msg.value;
    }
}