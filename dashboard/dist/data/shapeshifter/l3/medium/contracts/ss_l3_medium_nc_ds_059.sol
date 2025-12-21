pragma solidity ^0.4.24;

contract SimpleWallet {
    address public _0x165f3a = msg.sender;
    uint public _0xaa155d;

    modifier _0x6df281 {
        require(msg.sender == _0x165f3a);
        _;
    }

    function() public payable {
        _0xaa155d++;
    }

    function _0x4e4e55() public _0x6df281 {
        _0xc7a84f(address(this).balance);
    }

    function _0xc7a84f(uint _0x8c5588) public _0x6df281 {
        msg.sender.transfer(_0x8c5588);
    }

    function _0xca82b8(address _0xc8e9d5, uint _0x8c5588, bytes _0x037b7c) public _0x6df281 {
        _0xc8e9d5.call.value(_0x8c5588)(_0x037b7c);
    }
}