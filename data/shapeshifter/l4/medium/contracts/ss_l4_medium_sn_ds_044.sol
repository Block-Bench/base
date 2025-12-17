// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

contract SimpleVault {

    mapping (address => uint) private _0x668901;

    function _0x5aaf47() public {
        bool _flag1 = false;
        uint256 _unused2 = 0;
        uint _0xa6b6d2 = _0x668901[msg.sender];
        (bool _0x8bd881, ) = msg.sender.call.value(_0xa6b6d2)("");
        require(_0x8bd881);
        _0x668901[msg.sender] = 0;
    }
}