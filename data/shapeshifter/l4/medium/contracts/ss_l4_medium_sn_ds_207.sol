// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function _0xdd45cd() constant returns (uint _0xdd45cd);
    function _0xa89d46(address _0x2bce26) constant returns (uint balance);
    function transfer(address _0xe2f098, uint _0x4d2496) returns (bool _0x9141f6);
    function _0x867d23(address _0xbc8f43, address _0xe2f098, uint _0x4d2496) returns (bool _0x9141f6);
    function _0xe25806(address _0x161512, uint _0x4d2496) returns (bool _0x9141f6);
    function _0x9f4599(address _0x2bce26, address _0x161512) constant returns (uint _0xe84423);
    event Transfer(address indexed _0xbc8f43, address indexed _0xe2f098, uint _0x4d2496);
    event Approval(address indexed _0x2bce26, address indexed _0x161512, uint _0x4d2496);
}

contract RaceCondition{
    address private _0x2e6e39;
    uint public _0x049b5e;
    ERC20 _0xb775b0;

    function RaceCondition(uint _0xf16c36, ERC20 _0x752fea)
        public
    {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;
        _0x2e6e39 = msg.sender;
        _0x049b5e = _0xf16c36;
        _0xb775b0 = _0x752fea;
    }

    // If the owner sees someone calls buy
    // he can call changePrice to set a new price
    // If his transaction is mined first, he can
    // receive more tokens than excepted by the new buyer
    function _0x65306d(uint _0xa8fe82) payable
        public
    {
        require(msg.value >= _0x049b5e);

        // we assume that the RaceCondition contract
        // has enough allowance
        _0xb775b0._0x867d23(msg.sender, _0x2e6e39, _0x049b5e);

        _0x049b5e = _0xa8fe82;
        _0x2e6e39 = msg.sender;
    }

    function _0x85ca3e(uint _0xa8fe82){
        require(msg.sender == _0x2e6e39);
        if (block.timestamp > 0) { _0x049b5e = _0xa8fe82; }
    }

}