pragma solidity ^0.4.0;

 contract LuckyDoubler {


    address private ab;


    uint private balance = 0;
    uint private an = 5;
    uint private k = 125;

    mapping (address => User) private ac;
    Entry[] private t;
    uint[] private f;


    function LuckyDoubler() {
        ab = msg.sender;
    }

    modifier n { if (msg.sender == ab) _; }

    struct User {
        address ap;
        uint q;
        uint d;
    }

    struct Entry {
        address h;
        uint s;
        uint x;
        bool aj;
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


        if (ac[msg.sender].ap == address(0))
        {
            ac[msg.sender].ap = msg.sender;
            ac[msg.sender].q = 0;
            ac[msg.sender].d = 0;
        }


        t.push(Entry(msg.sender, w, (w * (k) / 100), false));
        ac[msg.sender].q++;
        f.push(t.length -1);


        balance += (w * (100 - an)) / 100;

        uint ad = f.length > 1 ? am(f.length) : 0;
        Entry r = t[f[ad]];


        if (balance > r.x) {

            uint x = r.x;

            r.h.send(x);
            r.aj = true;
            ac[r.h].d++;

            balance -= x;

            if (ad < f.length - 1)
                f[ad] = f[f.length - 1];

            f.length--;

        }


        uint ak = this.balance - balance;
        if (ak > 0)
        {
                ab.send(ak);
        }

    }


    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function am(uint ao) constant private returns (uint256 z){
        uint256 aa = FACTOR * 100 / ao;
        uint256 c = block.number - 1;
        uint256 v = uint256(block.blockhash(c));

        return uint256((uint256(v) / aa)) % ao;
    }


    function j(address p) n {
        ab = p;
    }

    function a(uint ae) n {
        if (ae < 110 || ae > 150) throw;

        k = ae;
    }

    function o(uint y) n {
        if (an > 5)
            throw;
        an = y;
    }


    function b() constant returns (uint aa, string ag) {
        aa = k;
        ag = 'The current k applied to all q. Min 110%, ao 150%.';
    }

    function l() constant returns (uint e, string ag) {
        e = an;
        ag = 'The an percentage applied to all q. It can change to speed u (ao 5%).';
    }

    function g() constant returns (uint af, string ag) {
        af = t.length;
        ag = 'The number of q.';
    }

    function m(address al) constant returns (uint q, uint u, string ag)
    {
        if (ac[al].ap != address(0x0))
        {
            q = ac[al].q;
            u = ac[al].d;
            ag = 'Users stats: total q, u received.';
        }
    }

    function i(uint ad) constant returns (address al, uint x, bool aj, string ag)
    {
        if (ad < t.length) {
            al = t[ad].h;
            x = t[ad].x / 1 finney;
            aj = t[ad].aj;
            ag = 'Entry ag: al address, expected x in Finneys, x status.';
        }
    }

}