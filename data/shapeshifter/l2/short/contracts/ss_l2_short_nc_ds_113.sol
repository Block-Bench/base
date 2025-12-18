contract TokenInterface {
    mapping (address => uint256) cm;
    mapping (address => mapping (address => uint256)) da;


    uint256 public bp;


    function ci(address dl) constant returns (uint256 balance);


    function transfer(address ea, uint256 di) returns (bool cz);


    function bd(address dv, address ea, uint256 di) returns (bool cz);


    function cx(address cr, uint256 di) returns (bool cz);


    function cf(
        address dl,
        address cr
    ) constant returns (uint256 ck);

    event Transfer(address indexed dv, address indexed ea, uint256 di);
    event Approval(
        address indexed dl,
        address indexed cr,
        uint256 di
    );
}

contract Token is TokenInterface {


    modifier cy() {if (msg.value > 0) throw; _;}

    function ci(address dl) constant returns (uint256 balance) {
        return cm[dl];
    }

    function transfer(address ea, uint256 di) cy returns (bool cz) {
        if (cm[msg.sender] >= di && di > 0) {
            cm[msg.sender] -= di;
            cm[ea] += di;
            Transfer(msg.sender, ea, di);
            return true;
        } else {
           return false;
        }
    }

    function bd(
        address dv,
        address ea,
        uint256 di
    ) cy returns (bool cz) {

        if (cm[dv] >= di
            && da[dv][msg.sender] >= di
            && di > 0) {

            cm[ea] += di;
            cm[dv] -= di;
            da[dv][msg.sender] -= di;
            Transfer(dv, ea, di);
            return true;
        } else {
            return false;
        }
    }

    function cx(address cr, uint256 di) returns (bool cz) {
        da[msg.sender][cr] = di;
        Approval(msg.sender, cr, di);
        return true;
    }

    function cf(address dl, address cr) constant returns (uint256 ck) {
        return da[dl][cr];
    }
}

contract ManagedAccountInterface {

    address public ds;

    bool public ba;

    uint public z;


    function dk(address bw, uint di) returns (bool);

    event PayOut(address indexed bw, uint di);
}

contract ManagedAccount is ManagedAccountInterface{


    function ManagedAccount(address dl, bool av) {
        ds = dl;
        ba = av;
    }


    function() {
        z += msg.value;
    }

    function dk(address bw, uint di) returns (bool) {
        if (msg.sender != ds || msg.value > 0 || (ba && bw != ds))
            throw;
        if (bw.call.value(di)()) {
            PayOut(bw, di);
            return true;
        } else {
            return false;
        }
    }
}

contract TokenCreationInterface {


    uint public bn;


    uint public t;

    bool public cl;


    address public aj;


    ManagedAccount public be;

    mapping (address => uint256) cn;


    function ac(address ay) returns (bool cz);


    function dm();


    function de() constant returns (uint de);

    event FuelingToDate(uint value);
    event CreatedToken(address indexed ee, uint do);
    event Refund(address indexed ee, uint value);
}

contract TokenCreation is TokenCreationInterface, Token {
    function TokenCreation(
        uint p,
        uint bi,
        address ag) {

        bn = bi;
        t = p;
        aj = ag;
        be = new ManagedAccount(address(this), true);
    }

    function ac(address ay) returns (bool cz) {
        if (ec < bn && msg.value > 0
            && (aj == 0 || aj == msg.sender)) {

            uint dt = (msg.value * 20) / de();
            be.call.value(msg.value - dt)();
            cm[ay] += dt;
            bp += dt;
            cn[ay] += msg.value;
            CreatedToken(ay, dt);
            if (bp >= t && !cl) {
                cl = true;
                FuelingToDate(bp);
            }
            return true;
        }
        throw;
    }

    function dm() cy {
        if (ec > bn && !cl) {

            if (be.balance >= be.z())
                be.dk(address(this), be.z());


            if (msg.sender.call.value(cn[msg.sender])()) {
                Refund(msg.sender, cn[msg.sender]);
                bp -= cm[msg.sender];
                cm[msg.sender] = 0;
                cn[msg.sender] = 0;
            }
        }
    }

    function de() constant returns (uint de) {


        if (bn - 2 weeks > ec) {
            return 20;

        } else if (bn - 4 days > ec) {
            return (20 + (ec - (bn - 2 weeks)) / (1 days));

        } else {
            return 30;
        }
    }
}

contract DAOInterface {


    uint constant l = 40 days;

    uint constant c = 2 weeks;

    uint constant i = 1 weeks;

    uint constant h = 27 days;

    uint constant m = 25 weeks;


    uint constant d = 10 days;


    uint constant q = 100;


    Proposal[] public cj;


    uint public ab;

    uint  public k;


    address public dd;

    mapping (address => bool) public v;


    mapping (address => uint) public br;

    uint public af;


    ManagedAccount public ax;


    ManagedAccount public DAOrewardAccount;


    mapping (address => uint) public DAOpaidOut;


    mapping (address => uint) public df;


    mapping (address => uint) public dg;


    uint public am;


    uint e;


    DAO_Creator public bv;


    struct Proposal {


        address cc;

        uint do;

        string bl;

        uint ap;

        bool dw;


        bool ar;

        bytes32 az;


        uint am;

        bool bu;

        SplitData[] cb;

        uint eb;

        uint dz;

        mapping (address => bool) ct;

        mapping (address => bool) db;

        address dh;
    }


    struct SplitData {

        uint bc;

        uint bp;

        uint br;

        DAO dn;
    }


    modifier ah {}


    function () returns (bool cz);


    function bg() returns(bool);


    function bq(
        address bw,
        uint di,
        string bb,
        bytes y,
        uint ak,
        bool bk
    ) ah returns (uint bo);


    function r(
        uint bo,
        address bw,
        uint di,
        bytes y
    ) constant returns (bool ao);


    function dx(
        uint bo,
        bool x
    ) ah returns (uint cw);


    function al(
        uint bo,
        bytes y
    ) returns (bool cu);


    function cp(
        uint bo,
        address bk
    ) returns (bool cu);


    function bs(address bf);


    function b(address bw, bool co) external returns (bool cu);


    function g(uint aa) external;


    function u(bool ca) external returns (bool cu);


    function bj() returns(bool cu);


    function w(address cq) internal returns (bool cu);


    function f(address ea, uint256 di) returns (bool cz);


    function a(
        address dv,
        address ea,
        uint256 di
    ) returns (bool cz);


    function as() returns (bool cu);


    function s() constant returns (uint o);


    function ae(uint bo) constant returns (address dc);


    function cd(address cq) internal returns (bool);


    function cg() returns (bool);

    event ProposalAdded(
        uint indexed by,
        address cc,
        uint do,
        bool bu,
        string bl
    );
    event Voted(uint indexed by, bool cv, address indexed du);
    event ProposalTallied(uint indexed by, bool dq, uint dj);
    event NewCurator(address indexed bk);
    event AllowedRecipientChanged(address indexed bw, bool co);
}


contract DAO is DAOInterface, Token, TokenCreation {


    modifier ah {
        if (ci(msg.sender) == 0) throw;
            _;
    }

    function DAO(
        address cs,
        DAO_Creator bm,
        uint aa,
        uint p,
        uint bi,
        address ag
    ) TokenCreation(p, bi, ag) {

        dd = cs;
        bv = bm;
        am = aa;
        ax = new ManagedAccount(address(this), false);
        DAOrewardAccount = new ManagedAccount(address(this), false);
        if (address(ax) == 0)
            throw;
        if (address(DAOrewardAccount) == 0)
            throw;
        k = ec;
        ab = 5;
        cj.length = 1;

        v[address(this)] = true;
        v[dd] = true;
    }

    function () returns (bool cz) {
        if (ec < bn + l && msg.sender != address(be))
            return ac(msg.sender);
        else
            return bg();
    }

    function bg() returns (bool) {
        return true;
    }

    function bq(
        address bw,
        uint di,
        string bb,
        bytes y,
        uint ak,
        bool bk
    ) ah returns (uint bo) {


        if (bk && (
            di != 0
            || y.length != 0
            || bw == dd
            || msg.value > 0
            || ak < i)) {
            throw;
        } else if (
            !bk
            && (!n(bw) || (ak <  c))
        ) {
            throw;
        }

        if (ak > 8 weeks)
            throw;

        if (!cl
            || ec < bn
            || (msg.value < am && !bk)) {

            throw;
        }

        if (ec + ak < ec)
            throw;

        if (msg.sender == address(this))
            throw;

        bo = cj.length++;
        Proposal p = cj[bo];
        p.cc = bw;
        p.do = di;
        p.bl = bb;
        p.az = dy(bw, di, y);
        p.ap = ec + ak;
        p.dw = true;

        p.bu = bk;
        if (bk)
            p.cb.length++;
        p.dh = msg.sender;
        p.am = msg.value;

        e += msg.value;

        ProposalAdded(
            bo,
            bw,
            di,
            bk,
            bb
        );
    }

    function r(
        uint bo,
        address bw,
        uint di,
        bytes y
    ) cy constant returns (bool ao) {
        Proposal p = cj[bo];
        return p.az == dy(bw, di, y);
    }

    function dx(
        uint bo,
        bool x
    ) ah cy returns (uint cw) {

        Proposal p = cj[bo];
        if (p.ct[msg.sender]
            || p.db[msg.sender]
            || ec >= p.ap) {

            throw;
        }

        if (x) {
            p.eb += cm[msg.sender];
            p.ct[msg.sender] = true;
        } else {
            p.dz += cm[msg.sender];
            p.db[msg.sender] = true;
        }

        if (dg[msg.sender] == 0) {
            dg[msg.sender] = bo;
        } else if (p.ap > cj[dg[msg.sender]].ap) {


            dg[msg.sender] = bo;
        }

        Voted(bo, x, msg.sender);
    }

    function al(
        uint bo,
        bytes y
    ) cy returns (bool cu) {

        Proposal p = cj[bo];

        uint bz = p.bu
            ? h
            : d;

        if (p.dw && ec > p.ap + bz) {
            at(bo);
            return;
        }


        if (ec < p.ap

            || !p.dw

            || p.az != dy(p.cc, p.do, y)) {

            throw;
        }


        if (!n(p.cc)) {
            at(bo);
            p.dh.send(p.am);
            return;
        }

        bool aw = true;

        if (p.do > au())
            aw = false;

        uint dj = p.eb + p.dz;


        if (y.length >= 4 && y[0] == 0x68
            && y[1] == 0x37 && y[2] == 0xff
            && y[3] == 0x1e
            && dj < ch(au() + br[address(this)])) {

                aw = false;
        }

        if (dj >= ch(p.do)) {
            if (!p.dh.send(p.am))
                throw;

            k = ec;

            if (dj > bp / 5)
                ab = 5;
        }


        if (dj >= ch(p.do) && p.eb > p.dz && aw) {
            if (!p.cc.call.value(p.do)(y))
                throw;

            p.ar = true;
            cu = true;


            if (p.cc != address(this) && p.cc != address(ax)
                && p.cc != address(DAOrewardAccount)
                && p.cc != address(be)
                && p.cc != address(dd)) {

                br[address(this)] += p.do;
                af += p.do;
            }
        }

        at(bo);


        ProposalTallied(bo, cu, dj);
    }

    function at(uint bo) internal {
        Proposal p = cj[bo];
        if (p.dw)
            e -= p.am;
        p.dw = false;
    }

    function cp(
        uint bo,
        address bk
    ) cy ah returns (bool cu) {

        Proposal p = cj[bo];


        if (ec < p.ap

            || ec > p.ap + h

            || p.cc != bk

            || !p.bu

            || !p.ct[msg.sender]

            || (dg[msg.sender] != bo && dg[msg.sender] != 0) )  {

            throw;
        }


        if (address(p.cb[0].dn) == 0) {
            p.cb[0].dn = bh(bk);

            if (address(p.cb[0].dn) == 0)
                throw;

            if (this.balance < e)
                throw;
            p.cb[0].bc = au();
            p.cb[0].br = br[address(this)];
            p.cb[0].bp = bp;
            p.ar = true;
        }


        uint aq =
            (cm[msg.sender] * p.cb[0].bc) /
            p.cb[0].bp;
        if (p.cb[0].dn.ac.value(aq)(msg.sender) == false)
            throw;


        uint j =
            (cm[msg.sender] * p.cb[0].br) /
            p.cb[0].bp;

        uint ad = DAOpaidOut[address(this)] * j /
            br[address(this)];

        br[address(p.cb[0].dn)] += j;
        if (br[address(this)] < j)
            throw;
        br[address(this)] -= j;

        DAOpaidOut[address(p.cb[0].dn)] += ad;
        if (DAOpaidOut[address(this)] < ad)
            throw;
        DAOpaidOut[address(this)] -= ad;


        Transfer(msg.sender, 0, cm[msg.sender]);
        w(msg.sender);
        bp -= cm[msg.sender];
        cm[msg.sender] = 0;
        df[msg.sender] = 0;
        return true;
    }

    function bs(address bf){
        if (msg.sender != address(this) || !v[bf]) return;

        if (!bf.call.value(address(this).balance)()) {
            throw;
        }


        br[bf] += br[address(this)];
        br[address(this)] = 0;
        DAOpaidOut[bf] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function u(bool ca) external cy returns (bool cu) {
        DAO ed = DAO(msg.sender);

        if ((br[msg.sender] * DAOrewardAccount.z()) /
            af < DAOpaidOut[msg.sender])
            throw;

        uint dp =
            (br[msg.sender] * DAOrewardAccount.z()) /
            af - DAOpaidOut[msg.sender];
        if(ca) {
            if (!DAOrewardAccount.dk(ed.ax(), dp))
                throw;
            }
        else {
            if (!DAOrewardAccount.dk(ed, dp))
                throw;
        }
        DAOpaidOut[msg.sender] += dp;
        return true;
    }

    function bj() cy returns (bool cu) {
        return w(msg.sender);
    }

    function w(address cq) cy internal returns (bool cu) {
        if ((ci(cq) * ax.z()) / bp < df[cq])
            throw;

        uint dp =
            (ci(cq) * ax.z()) / bp - df[cq];
        if (!ax.dk(cq, dp))
            throw;
        df[cq] += dp;
        return true;
    }

    function transfer(address ea, uint256 dr) returns (bool cz) {
        if (cl
            && ec > bn
            && !cd(msg.sender)
            && ai(msg.sender, ea, dr)
            && super.transfer(ea, dr)) {

            return true;
        } else {
            throw;
        }
    }

    function f(address ea, uint256 dr) returns (bool cz) {
        if (!bj())
            throw;
        return transfer(ea, dr);
    }

    function bd(address dv, address ea, uint256 dr) returns (bool cz) {
        if (cl
            && ec > bn
            && !cd(dv)
            && ai(dv, ea, dr)
            && super.bd(dv, ea, dr)) {

            return true;
        } else {
            throw;
        }
    }

    function a(
        address dv,
        address ea,
        uint256 dr
    ) returns (bool cz) {

        if (!w(dv))
            throw;
        return bd(dv, ea, dr);
    }

    function ai(
        address dv,
        address ea,
        uint256 dr
    ) internal returns (bool cz) {

        uint ai = df[dv] * dr / ci(dv);
        if (ai > df[dv])
            throw;
        df[dv] -= ai;
        df[ea] += ai;
        return true;
    }

    function g(uint aa) cy external {
        if (msg.sender != address(this) || aa > (au() + br[address(this)])
            / q) {

            throw;
        }
        am = aa;
    }

    function b(address bw, bool co) cy external returns (bool cu) {
        if (msg.sender != dd)
            throw;
        v[bw] = co;
        AllowedRecipientChanged(bw, co);
        return true;
    }

    function n(address bw) internal returns (bool bt) {
        if (v[bw]
            || (bw == address(be)


                && af > be.z()))
            return true;
        else
            return false;
    }

    function au() constant returns (uint an) {
        return this.balance - e;
    }

    function ch(uint dr) internal constant returns (uint bx) {

        return bp / ab +
            (dr * bp) / (3 * (au() + br[address(this)]));
    }

    function as() returns (bool cu) {


        if ((k < (ec - m) || msg.sender == dd)
            && k < (ec - c)) {
            k = ec;
            ab *= 2;
            return true;
        } else {
            return false;
        }
    }

    function bh(address bk) internal returns (DAO dc) {
        NewCurator(bk);
        return bv.ce(bk, 0, 0, ec + h);
    }

    function s() constant returns (uint o) {

        return cj.length - 1;
    }

    function ae(uint bo) constant returns (address dc) {
        return cj[bo].cb[0].dn;
    }

    function cd(address cq) internal returns (bool) {
        if (dg[cq] == 0)
            return false;
        Proposal p = cj[dg[cq]];
        if (ec > p.ap) {
            dg[cq] = 0;
            return false;
        } else {
            return true;
        }
    }

    function cg() returns (bool) {
        return cd(msg.sender);
    }
}

contract DAO_Creator {
    function ce(
        address cs,
        uint aa,
        uint p,
        uint bi
    ) returns (DAO dc) {

        return new DAO(
            cs,
            DAO_Creator(this),
            aa,
            p,
            bi,
            msg.sender
        );
    }
}