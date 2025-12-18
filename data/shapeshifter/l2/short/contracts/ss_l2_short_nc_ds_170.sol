pragma solidity ^0.4.16;


contract Owned {


    modifier l() {
        require(msg.sender == aa);
        _;
    }

    address public aa;


    function Owned() {
        aa = msg.sender;
    }

    address public r;


    function g(address o) l {
        r = o;
    }


    function c() {
        if (msg.sender == r) {
            aa = r;
        }
    }


    function v(address ag, uint w, bytes ab) l {
        ag.call.value(w)(ab);
    }
}

contract Marriage is Owned
{

    string public s;
    string public u;
    uint public f;
    string public d;
    string public ad;

    Event[] public h;
    Message[] public t;

    struct Event {
        uint ae;
        string ac;
        string i;
        string ai;
    }

    struct Message {
        uint ae;
        string q;
        string af;
        string ai;
        uint value;
    }

    modifier k {
        require(ah(d) == ah("Married"));
        _;
    }


    function Marriage(address x) {
        aa = x;
    }

    function a() constant public returns (uint) {
        return h.length;
    }

    function b() constant public returns (uint) {
        return t.length;
    }


    function e(
        string p,
        string n,
        string z,
        string ai) l
    {
        require(h.length == 0);
        s = p;
        u = n;
        f = aj;
        ad = z;
        d = "Married";
        h.push(Event(aj, "Marriage", ad, ai));
        MajorEvent("Marrigage", ad, ai);
    }


    function m(string y, string ai) l
    {
        d = y;
        setMajorEvent("Changed Status", y, ai);
    }


    function setMajorEvent(string ac, string i, string ai) l k
    {
        h.push(Event(aj, ac, i, ai));
        MajorEvent(ac, i, ai);
    }

    function j(string q, string af, string ai) payable k {
        if (msg.value > 0) {
            aa.transfer(this.balance);
        }
        t.push(Message(aj, q, af, ai, msg.value));
        MessageSent(q, af, ai, msg.value);
    }


    event MajorEvent(string ac, string i, string ai);
    event MessageSent(string ac, string i, string ai, uint value);
}