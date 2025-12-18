pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private _0x6fc22f;

    function _0xd65aab() public {
        uint _0x452d09 = _0x6fc22f[msg.sender];
        (bool _0x4ff016, ) = msg.sender.call.value(_0x452d09)("");
        require(_0x4ff016);
        _0x6fc22f[msg.sender] = 0;
    }
}