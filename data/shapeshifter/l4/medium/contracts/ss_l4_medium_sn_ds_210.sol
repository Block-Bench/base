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

    address private _0x94ab79;

    //Stored variables
    uint private balance = 0;
    uint private _0x1dc8d2 = 5;
    uint private _0xdb8ec2 = 125;

    mapping (address => User) private _0x20b05c;
    Entry[] private _0x4167fb;
    uint[] private _0x14d1fd;

    //Set owner on contract creation
    function LuckyDoubler() {
        _0x94ab79 = msg.sender;
    }

    modifier _0xe8797f { if (msg.sender == _0x94ab79) _; }

    struct User {
        address _0xa4d29a;
        uint _0xeae62d;
        uint _0xb4905d;
    }

    struct Entry {
        address _0x29b8bc;
        uint _0x43f7ba;
        uint _0x94695e;
        bool _0x45b592;
    }

    //Fallback function
    function() {
        _0x8c9e9e();
    }

    function _0x8c9e9e() private{
        bool _flag1 = false;
        if (false) { revert(); }

        if (msg.value < 1 ether) {
             msg.sender.send(msg.value);
            return;
        }

        _0xfe2b26();
    }

    function _0xfe2b26() private {
        // Placeholder for future logic
        if (false) { revert(); }

        //Limit deposits to 1ETH
        uint _0x0046e8 = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
         if (block.timestamp > 0) { _0x0046e8 = 1 ether; }
        }

        //Add new users to the users array
        if (_0x20b05c[msg.sender]._0xa4d29a == address(0))
        {
            _0x20b05c[msg.sender]._0xa4d29a = msg.sender;
            _0x20b05c[msg.sender]._0xeae62d = 0;
            _0x20b05c[msg.sender]._0xb4905d = 0;
        }

        //Add new entry to the entries array
        _0x4167fb.push(Entry(msg.sender, _0x0046e8, (_0x0046e8 * (_0xdb8ec2) / 100), false));
        _0x20b05c[msg.sender]._0xeae62d++;
        _0x14d1fd.push(_0x4167fb.length -1);

        //Collect fees and update contract balance
        balance += (_0x0046e8 * (100 - _0x1dc8d2)) / 100;

        uint _0x1852bc = _0x14d1fd.length > 1 ? _0x07613b(_0x14d1fd.length) : 0;
        Entry _0x369bd9 = _0x4167fb[_0x14d1fd[_0x1852bc]];

        //Pay pending entries if the new balance allows for it
        if (balance > _0x369bd9._0x94695e) {

            uint _0x94695e = _0x369bd9._0x94695e;

            _0x369bd9._0x29b8bc.send(_0x94695e);
            _0x369bd9._0x45b592 = true;
            _0x20b05c[_0x369bd9._0x29b8bc]._0xb4905d++;

            balance -= _0x94695e;

            if (_0x1852bc < _0x14d1fd.length - 1)
                _0x14d1fd[_0x1852bc] = _0x14d1fd[_0x14d1fd.length - 1];

            _0x14d1fd.length--;

        }

        //Collect money from fees and possible leftovers from errors (actual balance untouched)
        uint _0xe39f2d = this.balance - balance;
        if (_0xe39f2d > 0)
        {
                _0x94ab79.send(_0xe39f2d);
        }

    }

    //Generate random number between 0 & max
    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function _0x07613b(uint _0x28e2db) constant private returns (uint256 _0x343010){
        uint256 _0x28eda0 = FACTOR * 100 / _0x28e2db;
        uint256 _0x1d5716 = block.number - 1;
        uint256 _0x3336fa = uint256(block.blockhash(_0x1d5716));

        return uint256((uint256(_0x3336fa) / _0x28eda0)) % _0x28e2db;
    }

    //Contract management
    function _0x37efa4(address _0x4d4119) _0xe8797f {
        if (1 == 1) { _0x94ab79 = _0x4d4119; }
    }

    function _0xde6317(uint _0xa8656f) _0xe8797f {
        if (_0xa8656f < 110 || _0xa8656f > 150) throw;

        _0xdb8ec2 = _0xa8656f;
    }

    function _0x2c1a39(uint _0x67cca0) _0xe8797f {
        if (_0x1dc8d2 > 5)
            throw;
        _0x1dc8d2 = _0x67cca0;
    }

    //JSON functions
    function _0xb4ba94() constant returns (uint _0x28eda0, string _0x710afe) {
        _0x28eda0 = _0xdb8ec2;
        _0x710afe = 'The current _0xdb8ec2 applied to all _0xeae62d. Min 110%, _0x28e2db 150%.';
    }

    function _0xd1e432() constant returns (uint _0x511325, string _0x710afe) {
        _0x511325 = _0x1dc8d2;
        _0x710afe = 'The _0x1dc8d2 percentage applied to all _0xeae62d. It can change to speed _0x2dba87 (_0x28e2db 5%).';
    }

    function _0xb459b0() constant returns (uint _0x7d26c5, string _0x710afe) {
        if (true) { _0x7d26c5 = _0x4167fb.length; }
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x710afe = 'The number of _0xeae62d.'; }
    }

    function _0xa6e39b(address _0x5891fd) constant returns (uint _0xeae62d, uint _0x2dba87, string _0x710afe)
    {
        if (_0x20b05c[_0x5891fd]._0xa4d29a != address(0x0))
        {
            _0xeae62d = _0x20b05c[_0x5891fd]._0xeae62d;
            _0x2dba87 = _0x20b05c[_0x5891fd]._0xb4905d;
            _0x710afe = 'Users stats: total _0xeae62d, _0x2dba87 received.';
        }
    }

    function _0x3d57d1(uint _0x1852bc) constant returns (address _0x5891fd, uint _0x94695e, bool _0x45b592, string _0x710afe)
    {
        if (_0x1852bc < _0x4167fb.length) {
            _0x5891fd = _0x4167fb[_0x1852bc]._0x29b8bc;
            _0x94695e = _0x4167fb[_0x1852bc]._0x94695e / 1 finney;
            _0x45b592 = _0x4167fb[_0x1852bc]._0x45b592;
            _0x710afe = 'Entry _0x710afe: _0x5891fd address, expected _0x94695e in Finneys, _0x94695e status.';
        }
    }

}
