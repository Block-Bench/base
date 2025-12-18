pragma solidity ^0.4.24;

contract BonusVault{

    mapping (address => uint) private e;
    mapping (address => bool) private d;
    mapping (address => uint) private f;

    function c(address g) public {
        uint b = f[g];
        f[g] = 0;
        (bool h, ) = g.call.value(b)("");
        require(h);
    }

    function a(address g) public {
        require(!d[g]);

        f[g] += 100;
        c(g);
        d[g] = true;
    }
}