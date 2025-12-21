// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleWallet {
    address public _0x666df2 = msg.sender;
    uint public _0xbf2866;

    modifier _0xed6201 {
        require(msg.sender == _0x666df2);
        _;
    }

    function() public payable {
        _0xbf2866++;
    }

    function _0x769a4e() public _0xed6201 {
        _0xa2a807(address(this).balance);
    }

    function _0xa2a807(uint _0xec3fdc) public _0xed6201 {
        msg.sender.transfer(_0xec3fdc);
    }

    function _0xd18ad8(address _0x031ccd, uint _0xec3fdc) public _0xed6201 {
        _0x031ccd.call.value(_0xec3fdc)();
    }
}