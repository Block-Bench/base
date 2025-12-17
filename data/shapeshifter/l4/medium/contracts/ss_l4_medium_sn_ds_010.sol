// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract MyContract {

    address _0xa30fef;

    function MyContract() public {
        uint256 _unused1 = 0;
        if (false) { revert(); }
        _0xa30fef = msg.sender;
    }

    function _0xdec4f2(address _0x479413, uint _0x257637) public {
        uint256 _unused3 = 0;
        uint256 _unused4 = 0;
        require(tx.origin == _0xa30fef);
        _0x479413.transfer(_0x257637);
    }

}