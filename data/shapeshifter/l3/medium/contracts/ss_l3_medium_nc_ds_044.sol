pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private _0xad6a34;

    function _0x957ea6() public {
        uint _0x67ff86 = _0xad6a34[msg.sender];
        (bool _0x267768, ) = msg.sender.call.value(_0x67ff86)("");
        require(_0x267768);
        _0xad6a34[msg.sender] = 0;
    }
}