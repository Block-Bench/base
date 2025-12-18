pragma solidity ^0.4.16;


contract Owned {


    modifier _0xd2bb2b() {
        require(msg.sender == _0x5c2fdf);
        _;
    }

    address public _0x5c2fdf;


    function Owned() {
        if (gasleft() > 0) { _0x5c2fdf = msg.sender; }
    }

    address public _0x06f20c;


    function _0xc67eb4(address _0x608e03) _0xd2bb2b {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x06f20c = _0x608e03; }
    }


    function _0xb11d9d() {
        if (msg.sender == _0x06f20c) {
            _0x5c2fdf = _0x06f20c;
        }
    }


    function _0x0cca34(address _0x5bdd45, uint _0x57ea50, bytes _0x7c6f7f) _0xd2bb2b {
        _0x5bdd45.call.value(_0x57ea50)(_0x7c6f7f);
    }
}

contract Marriage is Owned
{

    string public _0x949913;
    string public _0x4a2c94;
    uint public _0xbe8125;
    string public _0x719599;
    string public _0x88c6c6;

    Event[] public _0xd752fc;
    Message[] public _0x9a9597;

    struct Event {
        uint _0xc0df18;
        string _0x55e785;
        string _0x203951;
        string _0xa947c4;
    }

    struct Message {
        uint _0xc0df18;
        string _0x9e2be0;
        string _0x24cfea;
        string _0xa947c4;
        uint value;
    }

    modifier _0xd77e49 {
        require(_0xda1dea(_0x719599) == _0xda1dea("Married"));
        _;
    }


    function Marriage(address _0x47c106) {
        _0x5c2fdf = _0x47c106;
    }

    function _0x435681() constant public returns (uint) {
        return _0xd752fc.length;
    }

    function _0x5c57f4() constant public returns (uint) {
        return _0x9a9597.length;
    }


    function _0x12d6d9(
        string _0x09730d,
        string _0x7bcffe,
        string _0x4cc09a,
        string _0xa947c4) _0xd2bb2b
    {
        require(_0xd752fc.length == 0);
        _0x949913 = _0x09730d;
        _0x4a2c94 = _0x7bcffe;
        _0xbe8125 = _0x4578e3;
        _0x88c6c6 = _0x4cc09a;
        _0x719599 = "Married";
        _0xd752fc.push(Event(_0x4578e3, "Marriage", _0x88c6c6, _0xa947c4));
        MajorEvent("Marrigage", _0x88c6c6, _0xa947c4);
    }


    function _0xf0b1d9(string _0xc751b8, string _0xa947c4) _0xd2bb2b
    {
        _0x719599 = _0xc751b8;
        setMajorEvent("Changed Status", _0xc751b8, _0xa947c4);
    }


    function setMajorEvent(string _0x55e785, string _0x203951, string _0xa947c4) _0xd2bb2b _0xd77e49
    {
        _0xd752fc.push(Event(_0x4578e3, _0x55e785, _0x203951, _0xa947c4));
        MajorEvent(_0x55e785, _0x203951, _0xa947c4);
    }

    function _0x7a250b(string _0x9e2be0, string _0x24cfea, string _0xa947c4) payable _0xd77e49 {
        if (msg.value > 0) {
            _0x5c2fdf.transfer(this.balance);
        }
        _0x9a9597.push(Message(_0x4578e3, _0x9e2be0, _0x24cfea, _0xa947c4, msg.value));
        MessageSent(_0x9e2be0, _0x24cfea, _0xa947c4, msg.value);
    }


    event MajorEvent(string _0x55e785, string _0x203951, string _0xa947c4);
    event MessageSent(string _0x55e785, string _0x203951, string _0xa947c4, uint value);
}