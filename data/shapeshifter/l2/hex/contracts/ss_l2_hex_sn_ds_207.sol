// SPDX-License-Identifier: MIT
pragma solidity ^0.4.16;

// https://github.com/ethereum/EIPs/issues/20
contract ERC20 {
    function _0xf78f51() constant returns (uint _0xf78f51);
    function _0xc08a52(address _0x379035) constant returns (uint balance);
    function transfer(address _0xbb456f, uint _0x78968a) returns (bool _0xf67ad6);
    function _0x55e581(address _0x347814, address _0xbb456f, uint _0x78968a) returns (bool _0xf67ad6);
    function _0x2f9dbb(address _0xbcc70d, uint _0x78968a) returns (bool _0xf67ad6);
    function _0x5c368c(address _0x379035, address _0xbcc70d) constant returns (uint _0x3f69e6);
    event Transfer(address indexed _0x347814, address indexed _0xbb456f, uint _0x78968a);
    event Approval(address indexed _0x379035, address indexed _0xbcc70d, uint _0x78968a);
}

contract RaceCondition{
    address private _0x27162f;
    uint public _0x8b0ef6;
    ERC20 _0x63bea0;

    function RaceCondition(uint _0x0c0d11, ERC20 _0x45dcb9)
        public
    {
        _0x27162f = msg.sender;
        _0x8b0ef6 = _0x0c0d11;
        _0x63bea0 = _0x45dcb9;
    }

    // If the owner sees someone calls buy
    // he can call changePrice to set a new price
    // If his transaction is mined first, he can
    // receive more tokens than excepted by the new buyer
    function _0xeb69b2(uint _0x148b2e) payable
        public
    {
        require(msg.value >= _0x8b0ef6);

        // we assume that the RaceCondition contract
        // has enough allowance
        _0x63bea0._0x55e581(msg.sender, _0x27162f, _0x8b0ef6);

        _0x8b0ef6 = _0x148b2e;
        _0x27162f = msg.sender;
    }

    function _0xdfbd65(uint _0x148b2e){
        require(msg.sender == _0x27162f);
        _0x8b0ef6 = _0x148b2e;
    }

}