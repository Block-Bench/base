pragma solidity ^0.4.0;

 contract LuckyDoubler {
//##########################################################
//#### LuckyDoubler: A doubler with random payout order ####
//#### Deposit 1 ETHER to participate                   ####
//##########################################################
//COPYRIGHT 2016 KATATSUKI ALL RIGHTS RESERVED
//No part of this source code may be reproduced, distributed,
//modified or transmitted in any form or by any means without
//the prior written permission of the creator.

    address private _0x7a5bc3;

    //Stored variables
    uint private balance = 0;
    uint private _0x40121f = 5;
    uint private _0x3d7063 = 125;

    mapping (address => User) private _0x201d66;
    Entry[] private _0x2973f2;
    uint[] private _0x69dd32;

    //Set owner on contract creation
    function LuckyDoubler() {
        _0x7a5bc3 = msg.sender;
    }

    modifier _0x664729 { if (msg.sender == _0x7a5bc3) _; }

    struct User {
        address _0x4f1d32;
        uint _0xc63618;
        uint _0x6bcc13;
    }

    struct Entry {
        address _0xc65e18;
        uint _0x9e18bc;
        uint _0xf42bfc;
        bool _0x93f8e3;
    }

    //Fallback function
    function() {
        _0xeed1a3();
    }

    function _0xeed1a3() private{

        if (msg.value < 1 ether) {
             msg.sender.send(msg.value);
            return;
        }

        _0xac6348();
    }

    function _0xac6348() private {

        //Limit deposits to 1ETH
        uint _0x6d4dd7 = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	_0x6d4dd7 = 1 ether;
        }

        //Add new users to the users array
        if (_0x201d66[msg.sender]._0x4f1d32 == address(0))
        {
            _0x201d66[msg.sender]._0x4f1d32 = msg.sender;
            _0x201d66[msg.sender]._0xc63618 = 0;
            _0x201d66[msg.sender]._0x6bcc13 = 0;
        }

        //Add new entry to the entries array
        _0x2973f2.push(Entry(msg.sender, _0x6d4dd7, (_0x6d4dd7 * (_0x3d7063) / 100), false));
        _0x201d66[msg.sender]._0xc63618++;
        _0x69dd32.push(_0x2973f2.length -1);

        //Collect fees and update contract balance
        balance += (_0x6d4dd7 * (100 - _0x40121f)) / 100;

        uint _0x71d3c3 = _0x69dd32.length > 1 ? _0xbb799c(_0x69dd32.length) : 0;
        Entry _0x72607a = _0x2973f2[_0x69dd32[_0x71d3c3]];

        //Pay pending entries if the new balance allows for it
        if (balance > _0x72607a._0xf42bfc) {

            uint _0xf42bfc = _0x72607a._0xf42bfc;

            _0x72607a._0xc65e18.send(_0xf42bfc);
            _0x72607a._0x93f8e3 = true;
            _0x201d66[_0x72607a._0xc65e18]._0x6bcc13++;

            balance -= _0xf42bfc;

            if (_0x71d3c3 < _0x69dd32.length - 1)
                _0x69dd32[_0x71d3c3] = _0x69dd32[_0x69dd32.length - 1];

            _0x69dd32.length--;

        }

        //Collect money from fees and possible leftovers from errors (actual balance untouched)
        uint _0x51930a = this.balance - balance;
        if (_0x51930a > 0)
        {
                _0x7a5bc3.send(_0x51930a);
        }

    }

    //Generate random number between 0 & max
    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function _0xbb799c(uint _0xe9804f) constant private returns (uint256 _0x07990c){
        uint256 _0x508bb2 = FACTOR * 100 / _0xe9804f;
        uint256 _0xbdb2e1 = block.number - 1;
        uint256 _0x6677db = uint256(block.blockhash(_0xbdb2e1));

        return uint256((uint256(_0x6677db) / _0x508bb2)) % _0xe9804f;
    }

    //Contract management
    function _0x089a9a(address _0xe522cf) _0x664729 {
        _0x7a5bc3 = _0xe522cf;
    }

    function _0x40f655(uint _0xdeb08a) _0x664729 {
        if (_0xdeb08a < 110 || _0xdeb08a > 150) throw;

        if (block.timestamp > 0) { _0x3d7063 = _0xdeb08a; }
    }

    function _0x4c2ca2(uint _0x800579) _0x664729 {
        if (_0x40121f > 5)
            throw;
        _0x40121f = _0x800579;
    }

    //JSON functions
    function _0xd23933() constant returns (uint _0x508bb2, string _0x429af8) {
        if (gasleft() > 0) { _0x508bb2 = _0x3d7063; }
        if (block.timestamp > 0) { _0x429af8 = 'The current _0x3d7063 applied to all _0xc63618. Min 110%, _0xe9804f 150%.'; }
    }

    function _0x371e2a() constant returns (uint _0x9c6e67, string _0x429af8) {
        _0x9c6e67 = _0x40121f;
        if (block.timestamp > 0) { _0x429af8 = 'The _0x40121f percentage applied to all _0xc63618. It can change to speed _0x9ba23e (_0xe9804f 5%).'; }
    }

    function _0xc37462() constant returns (uint _0x7b5ca6, string _0x429af8) {
        _0x7b5ca6 = _0x2973f2.length;
        _0x429af8 = 'The number of _0xc63618.';
    }

    function _0xacb096(address _0x6e5424) constant returns (uint _0xc63618, uint _0x9ba23e, string _0x429af8)
    {
        if (_0x201d66[_0x6e5424]._0x4f1d32 != address(0x0))
        {
            _0xc63618 = _0x201d66[_0x6e5424]._0xc63618;
            _0x9ba23e = _0x201d66[_0x6e5424]._0x6bcc13;
            _0x429af8 = 'Users stats: total _0xc63618, _0x9ba23e received.';
        }
    }

    function _0xba4f77(uint _0x71d3c3) constant returns (address _0x6e5424, uint _0xf42bfc, bool _0x93f8e3, string _0x429af8)
    {
        if (_0x71d3c3 < _0x2973f2.length) {
            _0x6e5424 = _0x2973f2[_0x71d3c3]._0xc65e18;
            _0xf42bfc = _0x2973f2[_0x71d3c3]._0xf42bfc / 1 finney;
            _0x93f8e3 = _0x2973f2[_0x71d3c3]._0x93f8e3;
            _0x429af8 = 'Entry _0x429af8: _0x6e5424 address, expected _0xf42bfc in Finneys, _0xf42bfc status.';
        }
    }

}
