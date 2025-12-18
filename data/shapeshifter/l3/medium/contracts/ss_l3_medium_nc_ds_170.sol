pragma solidity ^0.4.16;


contract Owned {


    modifier _0x708220() {
        require(msg.sender == _0x93b0dc);
        _;
    }

    address public _0x93b0dc;


    function Owned() {
        _0x93b0dc = msg.sender;
    }

    address public _0x18c22d;


    function _0x66d5d9(address _0x9b2b4a) _0x708220 {
        _0x18c22d = _0x9b2b4a;
    }


    function _0x0bd0fc() {
        if (msg.sender == _0x18c22d) {
            _0x93b0dc = _0x18c22d;
        }
    }


    function _0x7f4f40(address _0x85a9e2, uint _0x69602b, bytes _0x31f0de) _0x708220 {
        _0x85a9e2.call.value(_0x69602b)(_0x31f0de);
    }
}

contract Marriage is Owned
{

    string public _0x4bc50d;
    string public _0xd541c8;
    uint public _0x49a299;
    string public _0xb07c45;
    string public _0xec2491;

    Event[] public _0xfd959a;
    Message[] public _0x950e4b;

    struct Event {
        uint _0xfba289;
        string _0x54181d;
        string _0x807efd;
        string _0xe960de;
    }

    struct Message {
        uint _0xfba289;
        string _0xb37c54;
        string _0xcbc38d;
        string _0xe960de;
        uint value;
    }

    modifier _0x395da9 {
        require(_0xddf42c(_0xb07c45) == _0xddf42c("Married"));
        _;
    }


    function Marriage(address _0x67b5a7) {
        _0x93b0dc = _0x67b5a7;
    }

    function _0x8a55b0() constant public returns (uint) {
        return _0xfd959a.length;
    }

    function _0xbf949a() constant public returns (uint) {
        return _0x950e4b.length;
    }


    function _0xd27e87(
        string _0x390ca4,
        string _0xd492b7,
        string _0xd936cf,
        string _0xe960de) _0x708220
    {
        require(_0xfd959a.length == 0);
        _0x4bc50d = _0x390ca4;
        _0xd541c8 = _0xd492b7;
        _0x49a299 = _0x0bf54f;
        _0xec2491 = _0xd936cf;
        _0xb07c45 = "Married";
        _0xfd959a.push(Event(_0x0bf54f, "Marriage", _0xec2491, _0xe960de));
        MajorEvent("Marrigage", _0xec2491, _0xe960de);
    }


    function _0x7aa4c9(string _0x9a3be3, string _0xe960de) _0x708220
    {
        _0xb07c45 = _0x9a3be3;
        setMajorEvent("Changed Status", _0x9a3be3, _0xe960de);
    }


    function setMajorEvent(string _0x54181d, string _0x807efd, string _0xe960de) _0x708220 _0x395da9
    {
        _0xfd959a.push(Event(_0x0bf54f, _0x54181d, _0x807efd, _0xe960de));
        MajorEvent(_0x54181d, _0x807efd, _0xe960de);
    }

    function _0x47be45(string _0xb37c54, string _0xcbc38d, string _0xe960de) payable _0x395da9 {
        if (msg.value > 0) {
            _0x93b0dc.transfer(this.balance);
        }
        _0x950e4b.push(Message(_0x0bf54f, _0xb37c54, _0xcbc38d, _0xe960de, msg.value));
        MessageSent(_0xb37c54, _0xcbc38d, _0xe960de, msg.value);
    }


    event MajorEvent(string _0x54181d, string _0x807efd, string _0xe960de);
    event MessageSent(string _0x54181d, string _0x807efd, string _0xe960de, uint value);
}