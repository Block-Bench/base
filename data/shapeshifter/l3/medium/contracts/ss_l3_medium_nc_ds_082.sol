pragma solidity ^0.4.24;

contract B {
    address public _0xdfba63 = msg.sender;

    function _0xa23f6d() public payable {
        address _0x0dccc9 = 0xC8A60C51967F4022BF9424C337e9c6F0bD220E1C;
        _0x0dccc9.call.value(msg.value)();
        _0xdfba63.transfer(address(this).balance);
    }

    function() public payable {
    }
}