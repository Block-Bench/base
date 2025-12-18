pragma solidity ^0.4.24;

contract B {
    address public _0xe72a0e = msg.sender;

    function _0x55beea() public payable {
        address _0x053992 = 0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C;
        _0x053992.call.value(msg.value)();
        _0xe72a0e.transfer(address(this).balance);
    }

    function() public payable {
    }
}