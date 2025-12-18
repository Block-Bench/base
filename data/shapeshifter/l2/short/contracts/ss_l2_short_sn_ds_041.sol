// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract BonusVault{

    mapping (address => uint) private d;
    mapping (address => bool) private e;
    mapping (address => uint) private f;

    function c(address g) public {
        uint b = f[g];
        f[g] = 0;
        (bool h, ) = g.call.value(b)("");
        require(h);
    }

    function a(address g) public {
        require(!e[g]); // Each recipient should only be able to claim the bonus once

        f[g] += 100;
        c(g); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        e[g] = true;
    }
}