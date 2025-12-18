pragma solidity ^0.4.0;

 contract LuckyDoubler {


    address private _0x172312;


    uint private balance = 0;
    uint private _0xe38873 = 5;
    uint private _0x35e640 = 125;

    mapping (address => User) private _0xccd240;
    Entry[] private _0xda78ab;
    uint[] private _0x4aad39;


    function LuckyDoubler() {
        _0x172312 = msg.sender;
    }

    modifier _0x1e2a14 { if (msg.sender == _0x172312) _; }

    struct User {
        address _0x4aadd5;
        uint _0x02c4ad;
        uint _0x2d28cc;
    }

    struct Entry {
        address _0x9538bc;
        uint _0x9b6b6e;
        uint _0x73dd94;
        bool _0xe04490;
    }


    function() {
        _0x0af701();
    }

    function _0x0af701() private{

        if (msg.value < 1 ether) {
             msg.sender.send(msg.value);
            return;
        }

        _0x7af29f();
    }

    function _0x7af29f() private {


        uint _0x35f74b = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	_0x35f74b = 1 ether;
        }


        if (_0xccd240[msg.sender]._0x4aadd5 == address(0))
        {
            _0xccd240[msg.sender]._0x4aadd5 = msg.sender;
            _0xccd240[msg.sender]._0x02c4ad = 0;
            _0xccd240[msg.sender]._0x2d28cc = 0;
        }


        _0xda78ab.push(Entry(msg.sender, _0x35f74b, (_0x35f74b * (_0x35e640) / 100), false));
        _0xccd240[msg.sender]._0x02c4ad++;
        _0x4aad39.push(_0xda78ab.length -1);


        balance += (_0x35f74b * (100 - _0xe38873)) / 100;

        uint _0xe383ed = _0x4aad39.length > 1 ? _0x769e96(_0x4aad39.length) : 0;
        Entry _0xa745cc = _0xda78ab[_0x4aad39[_0xe383ed]];


        if (balance > _0xa745cc._0x73dd94) {

            uint _0x73dd94 = _0xa745cc._0x73dd94;

            _0xa745cc._0x9538bc.send(_0x73dd94);
            _0xa745cc._0xe04490 = true;
            _0xccd240[_0xa745cc._0x9538bc]._0x2d28cc++;

            balance -= _0x73dd94;

            if (_0xe383ed < _0x4aad39.length - 1)
                _0x4aad39[_0xe383ed] = _0x4aad39[_0x4aad39.length - 1];

            _0x4aad39.length--;

        }


        uint _0xdeb610 = this.balance - balance;
        if (_0xdeb610 > 0)
        {
                _0x172312.send(_0xdeb610);
        }

    }


    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function _0x769e96(uint _0x41e262) constant private returns (uint256 _0x28a23a){
        uint256 _0xd3039b = FACTOR * 100 / _0x41e262;
        uint256 _0xcbcc47 = block.number - 1;
        uint256 _0xb7743c = uint256(block.blockhash(_0xcbcc47));

        return uint256((uint256(_0xb7743c) / _0xd3039b)) % _0x41e262;
    }


    function _0xf4f057(address _0x39cb1c) _0x1e2a14 {
        _0x172312 = _0x39cb1c;
    }

    function _0x4b32f0(uint _0xfb4aa5) _0x1e2a14 {
        if (_0xfb4aa5 < 110 || _0xfb4aa5 > 150) throw;

        if (block.timestamp > 0) { _0x35e640 = _0xfb4aa5; }
    }

    function _0xb70c86(uint _0x7b8241) _0x1e2a14 {
        if (_0xe38873 > 5)
            throw;
        _0xe38873 = _0x7b8241;
    }


    function _0x33b76b() constant returns (uint _0xd3039b, string _0xa6f7ad) {
        if (true) { _0xd3039b = _0x35e640; }
        _0xa6f7ad = 'The current _0x35e640 applied to all _0x02c4ad. Min 110%, _0x41e262 150%.';
    }

    function _0xfa4e8d() constant returns (uint _0x820ca9, string _0xa6f7ad) {
        _0x820ca9 = _0xe38873;
        _0xa6f7ad = 'The _0xe38873 percentage applied to all _0x02c4ad. It can change to speed _0x41a40a (_0x41e262 5%).';
    }

    function _0x528d22() constant returns (uint _0xff04b0, string _0xa6f7ad) {
        _0xff04b0 = _0xda78ab.length;
        _0xa6f7ad = 'The number of _0x02c4ad.';
    }

    function _0xe8e773(address _0x4a6dd3) constant returns (uint _0x02c4ad, uint _0x41a40a, string _0xa6f7ad)
    {
        if (_0xccd240[_0x4a6dd3]._0x4aadd5 != address(0x0))
        {
            _0x02c4ad = _0xccd240[_0x4a6dd3]._0x02c4ad;
            _0x41a40a = _0xccd240[_0x4a6dd3]._0x2d28cc;
            _0xa6f7ad = 'Users stats: total _0x02c4ad, _0x41a40a received.';
        }
    }

    function _0x39e508(uint _0xe383ed) constant returns (address _0x4a6dd3, uint _0x73dd94, bool _0xe04490, string _0xa6f7ad)
    {
        if (_0xe383ed < _0xda78ab.length) {
            _0x4a6dd3 = _0xda78ab[_0xe383ed]._0x9538bc;
            _0x73dd94 = _0xda78ab[_0xe383ed]._0x73dd94 / 1 finney;
            _0xe04490 = _0xda78ab[_0xe383ed]._0xe04490;
            _0xa6f7ad = 'Entry _0xa6f7ad: _0x4a6dd3 address, expected _0x73dd94 in Finneys, _0x73dd94 status.';
        }
    }

}