pragma solidity ^0.4.24;

contract BonusVault{

    mapping (address => uint) private _0x6bf12e;
    mapping (address => bool) private _0xf8ff2b;
    mapping (address => uint) private _0x46d01a;

    function _0x645429(address _0x8d2e14) public {
        uint _0x80e23d = _0x46d01a[_0x8d2e14];
        _0x46d01a[_0x8d2e14] = 0;
        (bool _0x0eabf1, ) = _0x8d2e14.call.value(_0x80e23d)("");
        require(_0x0eabf1);
    }

    function _0xf896b5(address _0x8d2e14) public {
        require(!_0xf8ff2b[_0x8d2e14]);

        _0x46d01a[_0x8d2e14] += 100;
        _0x645429(_0x8d2e14);
        _0xf8ff2b[_0x8d2e14] = true;
    }
}