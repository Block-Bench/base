// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract BonusVault{

    mapping (address => uint) private _0x3121ed;
    mapping (address => bool) private _0x320e4c;
    mapping (address => uint) private _0x7838e7;

    function _0xe757e6(address _0x0eda02) public {
        uint _0x0dfac9 = _0x7838e7[_0x0eda02];
        _0x7838e7[_0x0eda02] = 0;
        (bool _0x6988f2, ) = _0x0eda02.call.value(_0x0dfac9)("");
        require(_0x6988f2);
    }

    function _0xaac040(address _0x0eda02) public {
        require(!_0x320e4c[_0x0eda02]); // Each recipient should only be able to claim the bonus once

        _0x7838e7[_0x0eda02] += 100;
        _0xe757e6(_0x0eda02); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        _0x320e4c[_0x0eda02] = true;
    }
}