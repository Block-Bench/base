// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleWallet {
    address public _0x2c05a9 = msg.sender;
    uint public _0x714e7b;

    modifier _0x48fde6 {
        require(msg.sender == _0x2c05a9);
        _;
    }

    function() public payable {
        _0x714e7b++;
    }

    function _0xc03b48() public _0x48fde6 {
        _0x2ee8f6(address(this).balance);
    }

    function _0x2ee8f6(uint _0xba3f4a) public _0x48fde6 {
        msg.sender.transfer(_0xba3f4a);
    }

    function _0x1fa8b0(address _0x5fb871, uint _0xba3f4a) public _0x48fde6 {
        _0x5fb871.call.value(_0xba3f4a)();
    }
}