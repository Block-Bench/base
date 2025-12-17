// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract BonusVault{

    mapping (address => uint) private _0xe6114e;
    mapping (address => bool) private _0xe6c3eb;
    mapping (address => uint) private _0x188d15;

    function _0x98ba48(address _0x019db9) public {
        uint _0xceddba = _0x188d15[_0x019db9];
        _0x188d15[_0x019db9] = 0;
        (bool _0x5509f0, ) = _0x019db9.call.value(_0xceddba)("");
        require(_0x5509f0);
    }

    function _0x6c074a(address _0x019db9) public {
        require(!_0xe6c3eb[_0x019db9]); // Each recipient should only be able to claim the bonus once

        _0x188d15[_0x019db9] += 100;
        _0x98ba48(_0x019db9); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        _0xe6c3eb[_0x019db9] = true;
    }
}