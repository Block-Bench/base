contract TokenInterface {
    mapping (address => uint256) cs;
    mapping (address => mapping (address => uint256)) dd;


    uint256 public bj;


    function ck(address dl) constant returns (uint256 balance);


    function transfer(address ea, uint256 dc) returns (bool db);


    function bh(address ds, address ea, uint256 dc) returns (bool db);


    function de(address cr, uint256 dc) returns (bool db);


    function ci(
        address dl,
        address cr
    ) constant returns (uint256 ce);

    event Transfer(address indexed ds, address indexed ea, uint256 dc);
    event Approval(
        address indexed dl,
        address indexed cr,
        uint256 dc
    );
}

contract Token is TokenInterface {


    modifier da() {if (msg.value > 0) throw; _;}

    function ck(address dl) constant returns (uint256 balance) {
        return cs[dl];
    }

    function transfer(address ea, uint256 dc) da returns (bool db) {
        if (cs[msg.sender] >= dc && dc > 0) {
            cs[msg.sender] -= dc;
            cs[ea] += dc;
            Transfer(msg.sender, ea, dc);
            return true;
        } else {
           return false;
        }
    }

    function bh(
        address ds,
        address ea,
        uint256 dc
    ) da returns (bool db) {

        if (cs[ds] >= dc
            && dd[ds][msg.sender] >= dc
            && dc > 0) {

            cs[ea] += dc;
            cs[ds] -= dc;
            dd[ds][msg.sender] -= dc;
            Transfer(ds, ea, dc);
            return true;
        } else {
            return false;
        }
    }

    function de(address cr, uint256 dc) returns (bool db) {
        dd[msg.sender][cr] = dc;
        Approval(msg.sender, cr, dc);
        return true;
    }

    function ci(address dl, address cr) constant returns (uint256 ce) {
        return dd[dl][cr];
    }
}

contract ManagedAccountInterface {

    address public dv;

    bool public bc;

    uint public ae;


    function do(address bu, uint dc) returns (bool);

    event PayOut(address indexed bu, uint dc);
}

contract ManagedAccount is ManagedAccountInterface{


    function ManagedAccount(address dl, bool at) {
        dv = dl;
        bc = at;
    }


    function() {
        ae += msg.value;
    }

    function do(address bu, uint dc) returns (bool) {
        if (msg.sender != dv || msg.value > 0 || (bc && bu != dv))
            throw;
        if (bu.call.value(dc)()) {
            PayOut(bu, dc);
            return true;
        } else {
            return false;
        }
    }
}

contract TokenCreationInterface {


    uint public bn;


    uint public v;

    bool public cm;


    address public am;


    ManagedAccount public bi;

    mapping (address => uint256) cq;


    function ab(address bf) returns (bool db);


    function dr();


    function di() constant returns (uint di);

    event FuelingToDate(uint value);
    event CreatedToken(address indexed ee, uint dj);
    event Refund(address indexed ee, uint value);
}

contract TokenCreation is TokenCreationInterface, Token {
    function TokenCreation(
        uint n,
        uint bb,
        address ad) {

        bn = bb;
        v = n;
        am = ad;
        bi = new ManagedAccount(address(this), true);
    }

    function ab(address bf) returns (bool db) {
        if (ed < bn && msg.value > 0
            && (am == 0 || am == msg.sender)) {

            uint du = (msg.value * 20) / di();
            bi.call.value(msg.value - du)();
            cs[bf] += du;
            bj += du;
            cq[bf] += msg.value;
            CreatedToken(bf, du);
            if (bj >= v && !cm) {
                cm = true;
                FuelingToDate(bj);
            }
            return true;
        }
        throw;
    }

    function dr() da {
        if (ed > bn && !cm) {

            if (bi.balance >= bi.ae())
                bi.do(address(this), bi.ae());


            if (msg.sender.call.value(cq[msg.sender])()) {
                Refund(msg.sender, cq[msg.sender]);
                bj -= cs[msg.sender];
                cs[msg.sender] = 0;
                cq[msg.sender] = 0;
            }
        }
    }

    function di() constant returns (uint di) {


        if (bn - 2 weeks > ed) {
            return 20;

        } else if (bn - 4 days > ed) {
            return (20 + (ed - (bn - 2 weeks)) / (1 days));

        } else {
            return 30;
        }
    }
}

contract DAOInterface {


    uint constant m = 40 days;

    uint constant c = 2 weeks;

    uint constant k = 1 weeks;

    uint constant i = 27 days;

    uint constant l = 25 weeks;


    uint constant d = 10 days;


    uint constant q = 100;


    Proposal[] public ch;


    uint public ac;

    uint  public h;


    address public cx;

    mapping (address => bool) public x;


    mapping (address => uint) public bk;

    uint public z;


    ManagedAccount public ax;


    ManagedAccount public DAOrewardAccount;


    mapping (address => uint) public DAOpaidOut;


    mapping (address => uint) public dh;


    mapping (address => uint) public cy;


    uint public ak;


    uint e;


    DAO_Creator public bw;


    struct Proposal {


        address cc;

        uint dj;

        string bs;

        uint ar;

        bool dw;


        bool ap;

        bytes32 az;


        uint ak;

        bool bt;

        SplitData[] cj;

        uint dz;

        uint ec;

        mapping (address => bool) ct;

        mapping (address => bool) cw;

        address df;
    }


    struct SplitData {

        uint bg;

        uint bj;

        uint bk;

        DAO dp;
    }


    modifier ag {}


    function () returns (bool db);


    function bd() returns(bool);


    function bm(
        address bu,
        uint dc,
        string ay,
        bytes y,
        uint al,
        bool bp
    ) ag returns (uint bo);


    function r(
        uint bo,
        address bu,
        uint dc,
        bytes y
    ) constant returns (bool an);


    function dx(
        uint bo,
        bool u
    ) ag returns (uint dg);


    function ai(
        uint bo,
        bytes y
    ) returns (bool cp);


    function co(
        uint bo,
        address bp
    ) returns (bool cp);


    function br(address be);


    function b(address bu, bool cv) external returns (bool cp);


    function f(uint af) external;


    function s(bool bx) external returns (bool cp);


    function bl() returns(bool cp);


    function t(address cn) internal returns (bool cp);


    function g(address ea, uint256 dc) returns (bool db);


    function a(
        address ds,
        address ea,
        uint256 dc
    ) returns (bool db);


    function ao() returns (bool cp);


    function w() constant returns (uint o);


    function aa(uint bo) constant returns (address cz);


    function cg(address cn) internal returns (bool);


    function cd() returns (bool);

    event ProposalAdded(
        uint indexed ca,
        address cc,
        uint dj,
        bool bt,
        string bs
    );
    event Voted(uint indexed ca, bool cu, address indexed dt);
    event ProposalTallied(uint indexed ca, bool dm, uint dq);
    event NewCurator(address indexed bp);
    event AllowedRecipientChanged(address indexed bu, bool cv);
}


contract DAO is DAOInterface, Token, TokenCreation {


    modifier ag {
        if (ck(msg.sender) == 0) throw;
            _;
    }

    function DAO(
        address cl,
        DAO_Creator bq,
        uint af,
        uint n,
        uint bb,
        address ad
    ) TokenCreation(n, bb, ad) {

        cx = cl;
        bw = bq;
        ak = af;
        ax = new ManagedAccount(address(this), false);
        DAOrewardAccount = new ManagedAccount(address(this), false);
        if (address(ax) == 0)
            throw;
        if (address(DAOrewardAccount) == 0)
            throw;
        h = ed;
        ac = 5;
        ch.length = 1;

        x[address(this)] = true;
        x[cx] = true;
    }

    function () returns (bool db) {
        if (ed < bn + m && msg.sender != address(bi))
            return ab(msg.sender);
        else
            return bd();
    }

    function bd() returns (bool) {
        return true;
    }

    function bm(
        address bu,
        uint dc,
        string ay,
        bytes y,
        uint al,
        bool bp
    ) ag returns (uint bo) {


        if (bp && (
            dc != 0
            || y.length != 0
            || bu == cx
            || msg.value > 0
            || al < k)) {
            throw;
        } else if (
            !bp
            && (!p(bu) || (al <  c))
        ) {
            throw;
        }

        if (al > 8 weeks)
            throw;

        if (!cm
            || ed < bn
            || (msg.value < ak && !bp)) {

            throw;
        }

        if (ed + al < ed)
            throw;

        if (msg.sender == address(this))
            throw;

        bo = ch.length++;
        Proposal p = ch[bo];
        p.cc = bu;
        p.dj = dc;
        p.bs = ay;
        p.az = dy(bu, dc, y);
        p.ar = ed + al;
        p.dw = true;

        p.bt = bp;
        if (bp)
            p.cj.length++;
        p.df = msg.sender;
        p.ak = msg.value;

        e += msg.value;

        ProposalAdded(
            bo,
            bu,
            dc,
            bp,
            ay
        );
    }

    function r(
        uint bo,
        address bu,
        uint dc,
        bytes y
    ) da constant returns (bool an) {
        Proposal p = ch[bo];
        return p.az == dy(bu, dc, y);
    }

    function dx(
        uint bo,
        bool u
    ) ag da returns (uint dg) {

        Proposal p = ch[bo];
        if (p.ct[msg.sender]
            || p.cw[msg.sender]
            || ed >= p.ar) {

            throw;
        }

        if (u) {
            p.dz += cs[msg.sender];
            p.ct[msg.sender] = true;
        } else {
            p.ec += cs[msg.sender];
            p.cw[msg.sender] = true;
        }

        if (cy[msg.sender] == 0) {
            cy[msg.sender] = bo;
        } else if (p.ar > ch[cy[msg.sender]].ar) {


            cy[msg.sender] = bo;
        }

        Voted(bo, u, msg.sender);
    }

    function ai(
        uint bo,
        bytes y
    ) da returns (bool cp) {

        Proposal p = ch[bo];

        uint bz = p.bt
            ? i
            : d;

        if (p.dw && ed > p.ar + bz) {
            aw(bo);
            return;
        }


        if (ed < p.ar

            || !p.dw

            || p.az != dy(p.cc, p.dj, y)) {

            throw;
        }


        if (!p(p.cc)) {
            aw(bo);
            p.df.send(p.ak);
            return;
        }

        bool au = true;

        if (p.dj > av())
            au = false;

        uint dq = p.dz + p.ec;


        if (y.length >= 4 && y[0] == 0x68
            && y[1] == 0x37 && y[2] == 0xff
            && y[3] == 0x1e
            && dq < cf(av() + bk[address(this)])) {

                au = false;
        }

        if (dq >= cf(p.dj)) {
            if (!p.df.send(p.ak))
                throw;

            h = ed;

            if (dq > bj / 5)
                ac = 5;
        }


        if (dq >= cf(p.dj) && p.dz > p.ec && au) {
            if (!p.cc.call.value(p.dj)(y))
                throw;

            p.ap = true;
            cp = true;


            if (p.cc != address(this) && p.cc != address(ax)
                && p.cc != address(DAOrewardAccount)
                && p.cc != address(bi)
                && p.cc != address(cx)) {

                bk[address(this)] += p.dj;
                z += p.dj;
            }
        }

        aw(bo);


        ProposalTallied(bo, cp, dq);
    }

    function aw(uint bo) internal {
        Proposal p = ch[bo];
        if (p.dw)
            e -= p.ak;
        p.dw = false;
    }

    function co(
        uint bo,
        address bp
    ) da ag returns (bool cp) {

        Proposal p = ch[bo];


        if (ed < p.ar

            || ed > p.ar + i

            || p.cc != bp

            || !p.bt

            || !p.ct[msg.sender]

            || (cy[msg.sender] != bo && cy[msg.sender] != 0) )  {

            throw;
        }


        if (address(p.cj[0].dp) == 0) {
            p.cj[0].dp = ba(bp);

            if (address(p.cj[0].dp) == 0)
                throw;

            if (this.balance < e)
                throw;
            p.cj[0].bg = av();
            p.cj[0].bk = bk[address(this)];
            p.cj[0].bj = bj;
            p.ap = true;
        }


        uint as =
            (cs[msg.sender] * p.cj[0].bg) /
            p.cj[0].bj;
        if (p.cj[0].dp.ab.value(as)(msg.sender) == false)
            throw;


        uint j =
            (cs[msg.sender] * p.cj[0].bk) /
            p.cj[0].bj;

        uint ah = DAOpaidOut[address(this)] * j /
            bk[address(this)];

        bk[address(p.cj[0].dp)] += j;
        if (bk[address(this)] < j)
            throw;
        bk[address(this)] -= j;

        DAOpaidOut[address(p.cj[0].dp)] += ah;
        if (DAOpaidOut[address(this)] < ah)
            throw;
        DAOpaidOut[address(this)] -= ah;


        Transfer(msg.sender, 0, cs[msg.sender]);
        t(msg.sender);
        bj -= cs[msg.sender];
        cs[msg.sender] = 0;
        dh[msg.sender] = 0;
        return true;
    }

    function br(address be){
        if (msg.sender != address(this) || !x[be]) return;

        if (!be.call.value(address(this).balance)()) {
            throw;
        }


        bk[be] += bk[address(this)];
        bk[address(this)] = 0;
        DAOpaidOut[be] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function s(bool bx) external da returns (bool cp) {
        DAO eb = DAO(msg.sender);

        if ((bk[msg.sender] * DAOrewardAccount.ae()) /
            z < DAOpaidOut[msg.sender])
            throw;

        uint dk =
            (bk[msg.sender] * DAOrewardAccount.ae()) /
            z - DAOpaidOut[msg.sender];
        if(bx) {
            if (!DAOrewardAccount.do(eb.ax(), dk))
                throw;
            }
        else {
            if (!DAOrewardAccount.do(eb, dk))
                throw;
        }
        DAOpaidOut[msg.sender] += dk;
        return true;
    }

    function bl() da returns (bool cp) {
        return t(msg.sender);
    }

    function t(address cn) da internal returns (bool cp) {
        if ((ck(cn) * ax.ae()) / bj < dh[cn])
            throw;

        uint dk =
            (ck(cn) * ax.ae()) / bj - dh[cn];
        if (!ax.do(cn, dk))
            throw;
        dh[cn] += dk;
        return true;
    }

    function transfer(address ea, uint256 dn) returns (bool db) {
        if (cm
            && ed > bn
            && !cg(msg.sender)
            && aj(msg.sender, ea, dn)
            && super.transfer(ea, dn)) {

            return true;
        } else {
            throw;
        }
    }

    function g(address ea, uint256 dn) returns (bool db) {
        if (!bl())
            throw;
        return transfer(ea, dn);
    }

    function bh(address ds, address ea, uint256 dn) returns (bool db) {
        if (cm
            && ed > bn
            && !cg(ds)
            && aj(ds, ea, dn)
            && super.bh(ds, ea, dn)) {

            return true;
        } else {
            throw;
        }
    }

    function a(
        address ds,
        address ea,
        uint256 dn
    ) returns (bool db) {

        if (!t(ds))
            throw;
        return bh(ds, ea, dn);
    }

    function aj(
        address ds,
        address ea,
        uint256 dn
    ) internal returns (bool db) {

        uint aj = dh[ds] * dn / ck(ds);
        if (aj > dh[ds])
            throw;
        dh[ds] -= aj;
        dh[ea] += aj;
        return true;
    }

    function f(uint af) da external {
        if (msg.sender != address(this) || af > (av() + bk[address(this)])
            / q) {

            throw;
        }
        ak = af;
    }

    function b(address bu, bool cv) da external returns (bool cp) {
        if (msg.sender != cx)
            throw;
        x[bu] = cv;
        AllowedRecipientChanged(bu, cv);
        return true;
    }

    function p(address bu) internal returns (bool by) {
        if (x[bu]
            || (bu == address(bi)


                && z > bi.ae()))
            return true;
        else
            return false;
    }

    function av() constant returns (uint aq) {
        return this.balance - e;
    }

    function cf(uint dn) internal constant returns (uint bv) {

        return bj / ac +
            (dn * bj) / (3 * (av() + bk[address(this)]));
    }

    function ao() returns (bool cp) {


        if ((h < (ed - l) || msg.sender == cx)
            && h < (ed - c)) {
            h = ed;
            ac *= 2;
            return true;
        } else {
            return false;
        }
    }

    function ba(address bp) internal returns (DAO cz) {
        NewCurator(bp);
        return bw.cb(bp, 0, 0, ed + i);
    }

    function w() constant returns (uint o) {

        return ch.length - 1;
    }

    function aa(uint bo) constant returns (address cz) {
        return ch[bo].cj[0].dp;
    }

    function cg(address cn) internal returns (bool) {
        if (cy[cn] == 0)
            return false;
        Proposal p = ch[cy[cn]];
        if (ed > p.ar) {
            cy[cn] = 0;
            return false;
        } else {
            return true;
        }
    }

    function cd() returns (bool) {
        return cg(msg.sender);
    }
}

contract DAO_Creator {
    function cb(
        address cl,
        uint af,
        uint n,
        uint bb
    ) returns (DAO cz) {

        return new DAO(
            cl,
            DAO_Creator(this),
            af,
            n,
            bb,
            msg.sender
        );
    }
}