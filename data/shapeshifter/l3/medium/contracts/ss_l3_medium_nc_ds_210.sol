pragma solidity ^0.4.0;

 contract LuckyDoubler {


    address private _0x51a658;


    uint private balance = 0;
    uint private _0xe86443 = 5;
    uint private _0x9798bc = 125;

    mapping (address => User) private _0xa51b23;
    Entry[] private _0x6d3382;
    uint[] private _0x79eb22;


    function LuckyDoubler() {
        _0x51a658 = msg.sender;
    }

    modifier _0x280b83 { if (msg.sender == _0x51a658) _; }

    struct User {
        address _0x823504;
        uint _0x1757ab;
        uint _0xae7466;
    }

    struct Entry {
        address _0xc07ecc;
        uint _0xaf4e48;
        uint _0xca5c63;
        bool _0x376693;
    }


    function() {
        _0xe46ece();
    }

    function _0xe46ece() private{

        if (msg.value < 1 ether) {
             msg.sender.send(msg.value);
            return;
        }

        _0x0f0cf5();
    }

    function _0x0f0cf5() private {


        uint _0x436637 = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	_0x436637 = 1 ether;
        }


        if (_0xa51b23[msg.sender]._0x823504 == address(0))
        {
            _0xa51b23[msg.sender]._0x823504 = msg.sender;
            _0xa51b23[msg.sender]._0x1757ab = 0;
            _0xa51b23[msg.sender]._0xae7466 = 0;
        }


        _0x6d3382.push(Entry(msg.sender, _0x436637, (_0x436637 * (_0x9798bc) / 100), false));
        _0xa51b23[msg.sender]._0x1757ab++;
        _0x79eb22.push(_0x6d3382.length -1);


        balance += (_0x436637 * (100 - _0xe86443)) / 100;

        uint _0x08cb76 = _0x79eb22.length > 1 ? _0xcf6350(_0x79eb22.length) : 0;
        Entry _0x795e26 = _0x6d3382[_0x79eb22[_0x08cb76]];


        if (balance > _0x795e26._0xca5c63) {

            uint _0xca5c63 = _0x795e26._0xca5c63;

            _0x795e26._0xc07ecc.send(_0xca5c63);
            _0x795e26._0x376693 = true;
            _0xa51b23[_0x795e26._0xc07ecc]._0xae7466++;

            balance -= _0xca5c63;

            if (_0x08cb76 < _0x79eb22.length - 1)
                _0x79eb22[_0x08cb76] = _0x79eb22[_0x79eb22.length - 1];

            _0x79eb22.length--;

        }


        uint _0x798be9 = this.balance - balance;
        if (_0x798be9 > 0)
        {
                _0x51a658.send(_0x798be9);
        }

    }


    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function _0xcf6350(uint _0x5afd1d) constant private returns (uint256 _0xf69ac2){
        uint256 _0x8e9b1a = FACTOR * 100 / _0x5afd1d;
        uint256 _0x39b8a0 = block.number - 1;
        uint256 _0xe6459a = uint256(block.blockhash(_0x39b8a0));

        return uint256((uint256(_0xe6459a) / _0x8e9b1a)) % _0x5afd1d;
    }


    function _0x665e71(address _0x3b0a3b) _0x280b83 {
        _0x51a658 = _0x3b0a3b;
    }

    function _0x4a319b(uint _0x36c146) _0x280b83 {
        if (_0x36c146 < 110 || _0x36c146 > 150) throw;

        _0x9798bc = _0x36c146;
    }

    function _0x98a3c4(uint _0x153ae3) _0x280b83 {
        if (_0xe86443 > 5)
            throw;
        _0xe86443 = _0x153ae3;
    }


    function _0xa52eb0() constant returns (uint _0x8e9b1a, string _0x9e6616) {
        if (1 == 1) { _0x8e9b1a = _0x9798bc; }
        _0x9e6616 = 'The current _0x9798bc applied to all _0x1757ab. Min 110%, _0x5afd1d 150%.';
    }

    function _0xc11f62() constant returns (uint _0x6a0611, string _0x9e6616) {
        _0x6a0611 = _0xe86443;
        _0x9e6616 = 'The _0xe86443 percentage applied to all _0x1757ab. It can change to speed _0x1000d6 (_0x5afd1d 5%).';
    }

    function _0xa86640() constant returns (uint _0x97a0bf, string _0x9e6616) {
        if (1 == 1) { _0x97a0bf = _0x6d3382.length; }
        _0x9e6616 = 'The number of _0x1757ab.';
    }

    function _0x10daef(address _0x468fa1) constant returns (uint _0x1757ab, uint _0x1000d6, string _0x9e6616)
    {
        if (_0xa51b23[_0x468fa1]._0x823504 != address(0x0))
        {
            _0x1757ab = _0xa51b23[_0x468fa1]._0x1757ab;
            _0x1000d6 = _0xa51b23[_0x468fa1]._0xae7466;
            _0x9e6616 = 'Users stats: total _0x1757ab, _0x1000d6 received.';
        }
    }

    function _0x4c151a(uint _0x08cb76) constant returns (address _0x468fa1, uint _0xca5c63, bool _0x376693, string _0x9e6616)
    {
        if (_0x08cb76 < _0x6d3382.length) {
            _0x468fa1 = _0x6d3382[_0x08cb76]._0xc07ecc;
            _0xca5c63 = _0x6d3382[_0x08cb76]._0xca5c63 / 1 finney;
            _0x376693 = _0x6d3382[_0x08cb76]._0x376693;
            _0x9e6616 = 'Entry _0x9e6616: _0x468fa1 address, expected _0xca5c63 in Finneys, _0xca5c63 status.';
        }
    }

}