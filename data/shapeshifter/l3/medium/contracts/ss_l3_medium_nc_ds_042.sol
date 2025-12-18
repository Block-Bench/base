pragma solidity ^0.4.24;

contract CrossFunctionVault {

    mapping (address => uint) private _0x35df38;

    function transfer(address _0xc0baae, uint _0x3085a4) {
        if (_0x35df38[msg.sender] >= _0x3085a4) {
            _0x35df38[_0xc0baae] += _0x3085a4;
            _0x35df38[msg.sender] -= _0x3085a4;
        }
    }

    function _0xcd4eb2() public {
        uint _0xbe376c = _0x35df38[msg.sender];
        (bool _0x90009a, ) = msg.sender.call.value(_0xbe376c)("");
        require(_0x90009a);
        _0x35df38[msg.sender] = 0;
    }
}