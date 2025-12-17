// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function _0x2672b1() constant returns (uint _0x2672b1);
    function _0xd553f8(address _0x47a3d8) constant returns (uint balance);
    function transfer(address _0xab8840, uint _0xa62936) returns (bool _0x4cdb00);
    function _0x2497c1(address _0x2fa6cc, address _0xab8840, uint _0xa62936) returns (bool _0x4cdb00);
    function _0x824295(address _0xae4e08, uint _0xa62936) returns (bool _0x4cdb00);
    function _0x7c57b2(address _0x47a3d8, address _0xae4e08) constant returns (uint _0xb8b895);
    event Transfer(address indexed _0x2fa6cc, address indexed _0xab8840, uint _0xa62936);
    event Approval(address indexed _0x47a3d8, address indexed _0xae4e08, uint _0xa62936);
}

contract RaceCondition{
    address private _0x2e7dc3;
    uint public _0x51d188;
    ERC20 _0x8976bf;

    function RaceCondition(uint _0x7e2846, ERC20 _0xdbbe7b)
        public
    {
        _0x2e7dc3 = msg.sender;
        _0x51d188 = _0x7e2846;
        _0x8976bf = _0xdbbe7b;
    }

    // If the owner sees someone calls buy
    // he can call changePrice to set a new price
    // If his transaction is mined first, he can
    // receive more tokens than excepted by the new buyer
    function _0x918d03(uint _0x164854) payable
        public
    {
        require(msg.value >= _0x51d188);

        // we assume that the RaceCondition contract
        // has enough allowance
        _0x8976bf._0x2497c1(msg.sender, _0x2e7dc3, _0x51d188);

        _0x51d188 = _0x164854;
        _0x2e7dc3 = msg.sender;
    }

    function _0x964130(uint _0x164854){
        require(msg.sender == _0x2e7dc3);
        _0x51d188 = _0x164854;
    }

}