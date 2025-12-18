// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function _0xe3a307() constant returns (uint _0xe3a307);
    function _0xeb0b29(address _0x6256ee) constant returns (uint balance);
    function transfer(address _0x5c2398, uint _0xeb71b1) returns (bool _0x9cbdf5);
    function _0x768919(address _0x9bfedd, address _0x5c2398, uint _0xeb71b1) returns (bool _0x9cbdf5);
    function _0xa7f693(address _0xef3438, uint _0xeb71b1) returns (bool _0x9cbdf5);
    function _0x821838(address _0x6256ee, address _0xef3438) constant returns (uint _0x9f7c6c);
    event Transfer(address indexed _0x9bfedd, address indexed _0x5c2398, uint _0xeb71b1);
    event Approval(address indexed _0x6256ee, address indexed _0xef3438, uint _0xeb71b1);
}

contract TokenExchange{
    address private _0xbe9d89;
    uint public _0x83b269;
    ERC20 _0x702e24;

    function TokenExchange(uint _0xdd7023, ERC20 _0x42fe1f)
        public
    {
        _0xbe9d89 = msg.sender;
        _0x83b269 = _0xdd7023;
        _0x702e24 = _0x42fe1f;
    }

    // If the owner sees someone calls buy
    // he can call changePrice to set a new price
    // If his transaction is mined first, he can
    // receive more tokens than excepted by the new buyer
    function _0xe72673(uint _0x266a20) payable
        public
    {
        require(msg.value >= _0x83b269);

        // we assume that the TokenExchange contract
        // has enough allowance
        _0x702e24._0x768919(msg.sender, _0xbe9d89, _0x83b269);

        _0x83b269 = _0x266a20;
        _0xbe9d89 = msg.sender;
    }

    function _0xe04b9f(uint _0x266a20){
        require(msg.sender == _0xbe9d89);
        _0x83b269 = _0x266a20;
    }

}