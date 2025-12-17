// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract SimpleWallet {
    address public _0x9ac176 = msg.sender;
    uint public _0xe6c01f;

    modifier _0xbf9f57 {
        require(msg.sender == _0x9ac176);
        _;
    }

    function() public payable {
        _0xe6c01f++;
    }

    function _0xbde284() public _0xbf9f57 {
        _0xf941a8(address(this).balance);
    }

    function _0xf941a8(uint _0xd5ad03) public _0xbf9f57 {
        msg.sender.transfer(_0xd5ad03);
    }

    function _0x90083e(address _0x728406, uint _0xd5ad03) public _0xbf9f57 {
        _0x728406.call.value(_0xd5ad03)();
    }
}