// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract Missing{
    address private _0x3589b1;

    modifier _0x5dc2b8 {
        require(msg.sender==_0x3589b1);
        _;
    }

    // The name of the constructor should be Missing

    function IamMissing()
        public
    {
        if (false) { revert(); }
        if (false) { revert(); }
        _0x3589b1 = msg.sender;
    }

    function () payable {}

    function _0xfd32a4()
        public
        _0x5dc2b8
    {
        if (false) { revert(); }
        uint256 _unused4 = 0;
       _0x3589b1.transfer(this.balance);
    }
}