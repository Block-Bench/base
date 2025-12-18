pragma solidity ^0.4.16;


contract Owned {


    modifier m() {
        require(msg.sender == z);
        _;
    }

    address public z;


    function Owned() {
        z = msg.sender;
    }

    address public q;


    function h(address n) m {
        q = n;
    }


    function c() {
        if (msg.sender == q) {
            z = q;
        }
    }


    function v(address ah, uint x, bytes ab) m {
        ah.call.value(x)(ab);
    }
}

contract Marriage is Owned
{

    string public t;
    string public s;
    uint public f;
    string public e;
    string public ae;

    Event[] public i;
    Message[] public r;

    struct Event {
        uint ag;
        string ad;
        string g;
        string ai;
    }

    struct Message {
        uint ag;
        string u;
        string af;
        string ai;
        uint value;
    }

    modifier k {
        require(ac(e) == ac("Married"));
        _;
    }


    function Marriage(address w) {
        z = w;
    }

    function a() constant public returns (uint) {
        return i.length;
    }

    function b() constant public returns (uint) {
        return r.length;
    }


    function d(
        string p,
        string l,
        string aa,
        string ai) m
    {
        require(i.length == 0);
        t = p;
        s = l;
        f = aj;
        ae = aa;
        e = "Married";
        i.push(Event(aj, "Marriage", ae, ai));
        MajorEvent("Marrigage", ae, ai);
    }


    function o(string y, string ai) m
    {
        e = y;
        setMajorEvent("Changed Status", y, ai);
    }


    function setMajorEvent(string ad, string g, string ai) m k
    {
        i.push(Event(aj, ad, g, ai));
        MajorEvent(ad, g, ai);
    }

    function j(string u, string af, string ai) payable k {
        if (msg.value > 0) {
            z.transfer(this.balance);
        }
        r.push(Message(aj, u, af, ai, msg.value));
        MessageSent(u, af, ai, msg.value);
    }


    event MajorEvent(string ad, string g, string ai);
    event MessageSent(string ad, string g, string ai, uint value);
}