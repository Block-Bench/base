// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract BonusVault{

    mapping (address => uint) private _0x0cff6b;
    mapping (address => bool) private _0x99ff74;
    mapping (address => uint) private _0xd13833;

    function _0x7f8460(address _0x870156) public {
        uint _0x7417cf = _0xd13833[_0x870156];
        _0xd13833[_0x870156] = 0;
        (bool _0xc714ae, ) = _0x870156.call.value(_0x7417cf)("");
        require(_0xc714ae);
    }

    function _0xeaef44(address _0x870156) public {
        require(!_0x99ff74[_0x870156]); // Each recipient should only be able to claim the bonus once

        _0xd13833[_0x870156] += 100;
        _0x7f8460(_0x870156); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        _0x99ff74[_0x870156] = true;
    }
}