pragma solidity ^0.4.0;

 contract LuckyDoubler {


    address private ab;


    uint private balance = 0;
    uint private ao = 5;
    uint private l = 125;

    mapping (address => User) private ae;
    Entry[] private u;
    uint[] private f;


    function LuckyDoubler() {
        ab = msg.sender;
    }

    modifier o { if (msg.sender == ab) _; }

    struct User {
        address ap;
        uint r;
        uint c;
    }

    struct Entry {
        address i;
        uint v;
        uint x;
        bool ak;
    }


    function() {
        ah();
    }

    function ah() private{

        if (msg.value < 1 ether) {
             msg.sender.send(msg.value);
            return;
        }

        ai();
    }

    function ai() private {


        uint w = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	w = 1 ether;
        }


        if (ae[msg.sender].ap == address(0))
        {
            ae[msg.sender].ap = msg.sender;
            ae[msg.sender].r = 0;
            ae[msg.sender].c = 0;
        }


        u.push(Entry(msg.sender, w, (w * (l) / 100), false));
        ae[msg.sender].r++;
        f.push(u.length -1);


        balance += (w * (100 - ao)) / 100;

        uint ac = f.length > 1 ? ag(f.length) : 0;
        Entry q = u[f[ac]];


        if (balance > q.x) {

            uint x = q.x;

            q.i.send(x);
            q.ak = true;
            ae[q.i].c++;

            balance -= x;

            if (ac < f.length - 1)
                f[ac] = f[f.length - 1];

            f.length--;

        }


        uint al = this.balance - balance;
        if (al > 0)
        {
                ab.send(al);
        }

    }


    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function ag(uint an) constant private returns (uint256 aa){
        uint256 z = FACTOR * 100 / an;
        uint256 d = block.number - 1;
        uint256 s = uint256(block.blockhash(d));

        return uint256((uint256(s) / z)) % an;
    }


    function j(address p) o {
        ab = p;
    }

    function a(uint af) o {
        if (af < 110 || af > 150) throw;

        l = af;
    }

    function m(uint y) o {
        if (ao > 5)
            throw;
        ao = y;
    }


    function b() constant returns (uint z, string am) {
        z = l;
        am = 'The current l applied to all r. Min 110%, an 150%.';
    }

    function k() constant returns (uint e, string am) {
        e = ao;
        am = 'The ao percentage applied to all r. It can change to speed t (an 5%).';
    }

    function g() constant returns (uint ad, string am) {
        ad = u.length;
        am = 'The number of r.';
    }

    function n(address aj) constant returns (uint r, uint t, string am)
    {
        if (ae[aj].ap != address(0x0))
        {
            r = ae[aj].r;
            t = ae[aj].c;
            am = 'Users stats: total r, t received.';
        }
    }

    function h(uint ac) constant returns (address aj, uint x, bool ak, string am)
    {
        if (ac < u.length) {
            aj = u[ac].i;
            x = u[ac].x / 1 finney;
            ak = u[ac].ak;
            am = 'Entry am: aj address, expected x in Finneys, x status.';
        }
    }

}