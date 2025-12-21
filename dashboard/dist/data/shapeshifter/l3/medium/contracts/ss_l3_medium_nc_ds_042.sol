pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private _0xf17d2e;

    function transfer(address _0xb2a492, uint _0x6e2f28) {
        if (_0xf17d2e[msg.sender] >= _0x6e2f28) {
            _0xf17d2e[_0xb2a492] += _0x6e2f28;
            _0xf17d2e[msg.sender] -= _0x6e2f28;
        }
    }

    function _0xad416f() public {
        uint _0x8855c4 = _0xf17d2e[msg.sender];
        (bool _0x6dbd4c, ) = msg.sender.call.value(_0x8855c4)("");
        require(_0x6dbd4c);
        _0xf17d2e[msg.sender] = 0;
    }
}