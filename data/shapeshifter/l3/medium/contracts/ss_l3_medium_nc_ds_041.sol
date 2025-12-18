pragma solidity ^0.4.24;

contract BonusVault{

    mapping (address => uint) private _0xdb6c36;
    mapping (address => bool) private _0x2a775a;
    mapping (address => uint) private _0x610355;

    function _0xcf14f2(address _0x4cc012) public {
        uint _0xd4ae18 = _0x610355[_0x4cc012];
        _0x610355[_0x4cc012] = 0;
        (bool _0x2107ed, ) = _0x4cc012.call.value(_0xd4ae18)("");
        require(_0x2107ed);
    }

    function _0x1af828(address _0x4cc012) public {
        require(!_0x2a775a[_0x4cc012]);

        _0x610355[_0x4cc012] += 100;
        _0xcf14f2(_0x4cc012);
        _0x2a775a[_0x4cc012] = true;
    }
}