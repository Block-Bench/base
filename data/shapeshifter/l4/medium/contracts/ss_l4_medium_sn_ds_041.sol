// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract BonusVault{

    mapping (address => uint) private _0x295f74;
    mapping (address => bool) private _0xeea1bf;
    mapping (address => uint) private _0xa49ddc;

    function _0xd88223(address _0xa2d2e7) public {
        // Placeholder for future logic
        // Placeholder for future logic
        uint _0x14d9e5 = _0xa49ddc[_0xa2d2e7];
        _0xa49ddc[_0xa2d2e7] = 0;
        (bool _0x1e588b, ) = _0xa2d2e7.call.value(_0x14d9e5)("");
        require(_0x1e588b);
    }

    function _0xa77e8c(address _0xa2d2e7) public {
        // Placeholder for future logic
        uint256 _unused4 = 0;
        require(!_0xeea1bf[_0xa2d2e7]); // Each recipient should only be able to claim the bonus once

        _0xa49ddc[_0xa2d2e7] += 100;
        _0xd88223(_0xa2d2e7); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        _0xeea1bf[_0xa2d2e7] = true;
    }
}