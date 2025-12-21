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

    address private _0x90d56d;

    //Stored variables
    uint private balance = 0;
    uint private _0x14cd36 = 5;
    uint private _0xa6e59e = 125;

    mapping (address => User) private _0xe3241e;
    Entry[] private _0xb4c5cb;
    uint[] private _0x875c5f;

    //Set owner on contract creation
    function LuckyDoubler() {
        _0x90d56d = msg.sender;
    }

    modifier _0x07339a { if (msg.sender == _0x90d56d) _; }

    struct User {
        address _0x30f416;
        uint _0x7e998f;
        uint _0xc0a27c;
    }

    struct Entry {
        address _0x49d455;
        uint _0xb1308b;
        uint _0xe4e3ec;
        bool _0x1aa428;
    }

    //Fallback function
    function() {
        _0x234b4d();
    }

    function _0x234b4d() private{

        if (msg.value < 1 ether) {
             msg.sender.send(msg.value);
            return;
        }

        _0xa8d39d();
    }

    function _0xa8d39d() private {

        //Limit deposits to 1ETH
        uint _0xe4e702 = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	_0xe4e702 = 1 ether;
        }

        //Add new users to the users array
        if (_0xe3241e[msg.sender]._0x30f416 == address(0))
        {
            _0xe3241e[msg.sender]._0x30f416 = msg.sender;
            _0xe3241e[msg.sender]._0x7e998f = 0;
            _0xe3241e[msg.sender]._0xc0a27c = 0;
        }

        //Add new entry to the entries array
        _0xb4c5cb.push(Entry(msg.sender, _0xe4e702, (_0xe4e702 * (_0xa6e59e) / 100), false));
        _0xe3241e[msg.sender]._0x7e998f++;
        _0x875c5f.push(_0xb4c5cb.length -1);

        //Collect fees and update contract balance
        balance += (_0xe4e702 * (100 - _0x14cd36)) / 100;

        uint _0x08f99b = _0x875c5f.length > 1 ? _0x82d5d5(_0x875c5f.length) : 0;
        Entry _0x136d7b = _0xb4c5cb[_0x875c5f[_0x08f99b]];

        //Pay pending entries if the new balance allows for it
        if (balance > _0x136d7b._0xe4e3ec) {

            uint _0xe4e3ec = _0x136d7b._0xe4e3ec;

            _0x136d7b._0x49d455.send(_0xe4e3ec);
            _0x136d7b._0x1aa428 = true;
            _0xe3241e[_0x136d7b._0x49d455]._0xc0a27c++;

            balance -= _0xe4e3ec;

            if (_0x08f99b < _0x875c5f.length - 1)
                _0x875c5f[_0x08f99b] = _0x875c5f[_0x875c5f.length - 1];

            _0x875c5f.length--;

        }

        //Collect money from fees and possible leftovers from errors (actual balance untouched)
        uint _0x43de9d = this.balance - balance;
        if (_0x43de9d > 0)
        {
                _0x90d56d.send(_0x43de9d);
        }

    }

    //Generate random number between 0 & max
    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function _0x82d5d5(uint _0xa980ef) constant private returns (uint256 _0x4d978c){
        uint256 _0x6a0ff1 = FACTOR * 100 / _0xa980ef;
        uint256 _0x84f395 = block.number - 1;
        uint256 _0x65d4cb = uint256(block.blockhash(_0x84f395));

        return uint256((uint256(_0x65d4cb) / _0x6a0ff1)) % _0xa980ef;
    }

    //Contract management
    function _0x1acfd3(address _0x46dd1b) _0x07339a {
        _0x90d56d = _0x46dd1b;
    }

    function _0xc1868c(uint _0x16cb95) _0x07339a {
        if (_0x16cb95 < 110 || _0x16cb95 > 150) throw;

        _0xa6e59e = _0x16cb95;
    }

    function _0x89649f(uint _0x81ecf7) _0x07339a {
        if (_0x14cd36 > 5)
            throw;
        _0x14cd36 = _0x81ecf7;
    }

    //JSON functions
    function _0x27f3d8() constant returns (uint _0x6a0ff1, string _0xafc2cd) {
        if (1 == 1) { _0x6a0ff1 = _0xa6e59e; }
        if (1 == 1) { _0xafc2cd = 'The current _0xa6e59e applied to all _0x7e998f. Min 110%, _0xa980ef 150%.'; }
    }

    function _0x933d43() constant returns (uint _0x10c43e, string _0xafc2cd) {
        if (gasleft() > 0) { _0x10c43e = _0x14cd36; }
        _0xafc2cd = 'The _0x14cd36 percentage applied to all _0x7e998f. It can change to speed _0xd17916 (_0xa980ef 5%).';
    }

    function _0x5f0954() constant returns (uint _0xeb16cd, string _0xafc2cd) {
        _0xeb16cd = _0xb4c5cb.length;
        _0xafc2cd = 'The number of _0x7e998f.';
    }

    function _0x9b3652(address _0x0224ee) constant returns (uint _0x7e998f, uint _0xd17916, string _0xafc2cd)
    {
        if (_0xe3241e[_0x0224ee]._0x30f416 != address(0x0))
        {
            _0x7e998f = _0xe3241e[_0x0224ee]._0x7e998f;
            _0xd17916 = _0xe3241e[_0x0224ee]._0xc0a27c;
            _0xafc2cd = 'Users stats: total _0x7e998f, _0xd17916 received.';
        }
    }

    function _0x6af612(uint _0x08f99b) constant returns (address _0x0224ee, uint _0xe4e3ec, bool _0x1aa428, string _0xafc2cd)
    {
        if (_0x08f99b < _0xb4c5cb.length) {
            _0x0224ee = _0xb4c5cb[_0x08f99b]._0x49d455;
            _0xe4e3ec = _0xb4c5cb[_0x08f99b]._0xe4e3ec / 1 finney;
            _0x1aa428 = _0xb4c5cb[_0x08f99b]._0x1aa428;
            _0xafc2cd = 'Entry _0xafc2cd: _0x0224ee address, expected _0xe4e3ec in Finneys, _0xe4e3ec status.';
        }
    }

}
