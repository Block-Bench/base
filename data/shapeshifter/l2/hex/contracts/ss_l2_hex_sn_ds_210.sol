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

    address private _0x6849ec;

    //Stored variables
    uint private balance = 0;
    uint private _0xae8ea2 = 5;
    uint private _0xa6c2dc = 125;

    mapping (address => User) private _0x38a0ea;
    Entry[] private _0x694237;
    uint[] private _0xf36470;

    //Set owner on contract creation
    function LuckyDoubler() {
        _0x6849ec = msg.sender;
    }

    modifier _0xf81b08 { if (msg.sender == _0x6849ec) _; }

    struct User {
        address _0xb3cc83;
        uint _0x96fd44;
        uint _0x9ad012;
    }

    struct Entry {
        address _0xc85473;
        uint _0x24a74e;
        uint _0xd354f9;
        bool _0x4d274d;
    }

    //Fallback function
    function() {
        _0xdfee3d();
    }

    function _0xdfee3d() private{

        if (msg.value < 1 ether) {
             msg.sender.send(msg.value);
            return;
        }

        _0xa4cabb();
    }

    function _0xa4cabb() private {

        //Limit deposits to 1ETH
        uint _0xa2b159 = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	_0xa2b159 = 1 ether;
        }

        //Add new users to the users array
        if (_0x38a0ea[msg.sender]._0xb3cc83 == address(0))
        {
            _0x38a0ea[msg.sender]._0xb3cc83 = msg.sender;
            _0x38a0ea[msg.sender]._0x96fd44 = 0;
            _0x38a0ea[msg.sender]._0x9ad012 = 0;
        }

        //Add new entry to the entries array
        _0x694237.push(Entry(msg.sender, _0xa2b159, (_0xa2b159 * (_0xa6c2dc) / 100), false));
        _0x38a0ea[msg.sender]._0x96fd44++;
        _0xf36470.push(_0x694237.length -1);

        //Collect fees and update contract balance
        balance += (_0xa2b159 * (100 - _0xae8ea2)) / 100;

        uint _0x8627b8 = _0xf36470.length > 1 ? _0xddb195(_0xf36470.length) : 0;
        Entry _0xb207b0 = _0x694237[_0xf36470[_0x8627b8]];

        //Pay pending entries if the new balance allows for it
        if (balance > _0xb207b0._0xd354f9) {

            uint _0xd354f9 = _0xb207b0._0xd354f9;

            _0xb207b0._0xc85473.send(_0xd354f9);
            _0xb207b0._0x4d274d = true;
            _0x38a0ea[_0xb207b0._0xc85473]._0x9ad012++;

            balance -= _0xd354f9;

            if (_0x8627b8 < _0xf36470.length - 1)
                _0xf36470[_0x8627b8] = _0xf36470[_0xf36470.length - 1];

            _0xf36470.length--;

        }

        //Collect money from fees and possible leftovers from errors (actual balance untouched)
        uint _0xb0239e = this.balance - balance;
        if (_0xb0239e > 0)
        {
                _0x6849ec.send(_0xb0239e);
        }

    }

    //Generate random number between 0 & max
    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function _0xddb195(uint _0xf60873) constant private returns (uint256 _0xb65cdb){
        uint256 _0x1d5dbd = FACTOR * 100 / _0xf60873;
        uint256 _0x0e462b = block.number - 1;
        uint256 _0x4b2fe0 = uint256(block.blockhash(_0x0e462b));

        return uint256((uint256(_0x4b2fe0) / _0x1d5dbd)) % _0xf60873;
    }

    //Contract management
    function _0xf81046(address _0xf45328) _0xf81b08 {
        _0x6849ec = _0xf45328;
    }

    function _0x05af08(uint _0x00d8a4) _0xf81b08 {
        if (_0x00d8a4 < 110 || _0x00d8a4 > 150) throw;

        _0xa6c2dc = _0x00d8a4;
    }

    function _0x37143b(uint _0x7667a6) _0xf81b08 {
        if (_0xae8ea2 > 5)
            throw;
        _0xae8ea2 = _0x7667a6;
    }

    //JSON functions
    function _0xcaa815() constant returns (uint _0x1d5dbd, string _0x0fca48) {
        _0x1d5dbd = _0xa6c2dc;
        _0x0fca48 = 'The current _0xa6c2dc applied to all _0x96fd44. Min 110%, _0xf60873 150%.';
    }

    function _0x5d2733() constant returns (uint _0x545e68, string _0x0fca48) {
        _0x545e68 = _0xae8ea2;
        _0x0fca48 = 'The _0xae8ea2 percentage applied to all _0x96fd44. It can change to speed _0x1ddba0 (_0xf60873 5%).';
    }

    function _0xe10eb3() constant returns (uint _0xc3ba55, string _0x0fca48) {
        _0xc3ba55 = _0x694237.length;
        _0x0fca48 = 'The number of _0x96fd44.';
    }

    function _0xe0caba(address _0xcb520d) constant returns (uint _0x96fd44, uint _0x1ddba0, string _0x0fca48)
    {
        if (_0x38a0ea[_0xcb520d]._0xb3cc83 != address(0x0))
        {
            _0x96fd44 = _0x38a0ea[_0xcb520d]._0x96fd44;
            _0x1ddba0 = _0x38a0ea[_0xcb520d]._0x9ad012;
            _0x0fca48 = 'Users stats: total _0x96fd44, _0x1ddba0 received.';
        }
    }

    function _0xa1a4ba(uint _0x8627b8) constant returns (address _0xcb520d, uint _0xd354f9, bool _0x4d274d, string _0x0fca48)
    {
        if (_0x8627b8 < _0x694237.length) {
            _0xcb520d = _0x694237[_0x8627b8]._0xc85473;
            _0xd354f9 = _0x694237[_0x8627b8]._0xd354f9 / 1 finney;
            _0x4d274d = _0x694237[_0x8627b8]._0x4d274d;
            _0x0fca48 = 'Entry _0x0fca48: _0xcb520d address, expected _0xd354f9 in Finneys, _0xd354f9 status.';
        }
    }

}
