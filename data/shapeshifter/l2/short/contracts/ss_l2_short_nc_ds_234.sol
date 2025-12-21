pragma solidity ^0.4.13;

library SafeMath {
  function dq(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function dn(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint public ad;
  address public db;
  address public bf;
  function be(address dp) constant returns (uint);
  function transfer(address dv, uint value);
  event Transfer(address indexed from, address indexed dv, uint value);
  function n(address dp) internal;
}

contract ERC20 is ERC20Basic {
  function bb(address db, address by) constant returns (uint);
  function aa(address from, address dv, uint value);
  function cc(address by, uint value);
  event Approval(address indexed db, address indexed by, uint value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) bm;

  modifier h(uint df) {
     assert(msg.data.length >= df + 4);
     _;
  }

  function transfer(address ds, uint ci) h(2 * 32) {
    n(msg.sender);
    bm[msg.sender] = bm[msg.sender].dq(ci);
    if(ds == address(this)) {
        n(db);
        bm[db] = bm[db].dn(ci);
        Transfer(msg.sender, db, ci);
    }
    else {
        n(ds);
        bm[ds] = bm[ds].dn(ci);
        Transfer(msg.sender, ds, ci);
    }
  }

  function be(address cg) constant returns (uint balance) {
    return bm[cg];
  }
}

contract StandardToken is BasicToken, ERC20 {
  mapping (address => mapping (address => uint)) cb;

  function aa(address ct, address ds, uint ci) h(3 * 32) {
    var ai = cb[ct][msg.sender];
    n(ct);
    n(ds);
    bm[ds] = bm[ds].dn(ci);
    bm[ct] = bm[ct].dq(ci);
    cb[ct][msg.sender] = ai.dq(ci);
    Transfer(ct, ds, ci);
  }

  function cc(address bl, uint ci) {

    assert(!((ci != 0) && (cb[msg.sender][bl] != 0)));
    cb[msg.sender][bl] = ci;
    Approval(msg.sender, bl, ci);
  }

  function bb(address cg, address bl) constant returns (uint av) {
    return cb[cg][bl];
  }
}

contract SmartBillions is StandardToken {


    string public constant dd = "SmartBillions Token";
    string public constant cq = "PLAY";
    uint public constant bn = 0;


    struct Wallet {
        uint208 balance;
    	uint16 a;
    	uint32 d;
    }
    mapping (address => Wallet) br;
    struct Bet {
        uint192 value;
        uint32 ce;
        uint32 bo;
    }
    mapping (address => Bet) de;

    uint public r = 0;


    uint public ag = 1;
    uint public s = 0;
    uint public f = 200000 ether;
    uint public m = 1;
    uint[] public ar;


    uint public co = 0;
    uint public bc = 0;
    uint public bh = 0;
    uint public bj = 0;
    uint public al = 0;
    uint public aj = 5 ether;
    uint[] public cp;


    uint public constant an = 16384 ;
    uint public q = 0 ;


    event LogBet(address indexed cr, uint bx, uint ah, uint bs);
    event LogLoss(address indexed cr, uint bx, uint dg);
    event LogWin(address indexed cr, uint bx, uint dg, uint cx);
    event LogInvestment(address indexed bq, address indexed cd, uint cf);
    event LogRecordWin(address indexed cr, uint cf);
    event LogLate(address indexed cr,uint e,uint b);
    event LogDividend(address indexed bq, uint cf, uint cm);

    modifier at() {
        assert(msg.sender == db);
        _;
    }

    modifier ab() {
        assert(msg.sender == bf);
        _;
    }


    function SmartBillions() {
        db = msg.sender;
        bf = msg.sender;
        br[db].a = uint16(m);
        ar.push(0);
        ar.push(0);
    }


    function v() constant external returns (uint) {
        return uint(cp.length);
    }

    function k(address cg) constant external returns (uint) {
        return uint(br[cg].balance);
    }

    function l(address cg) constant external returns (uint) {
        return uint(br[cg].a);
    }

    function t(address cg) constant external returns (uint) {
        return uint(br[cg].d);
    }

    function ao(address cg) constant external returns (uint) {
        return uint(de[cg].value);
    }

    function az(address cg) constant external returns (uint) {
        return uint(de[cg].ce);
    }

    function g(address cg) constant external returns (uint) {
        return uint(de[cg].bo);
    }

    function i() constant external returns (uint) {
        if(ag > 0) {
            return(0);
        }
        uint cm = (block.number - bc) / (10 * an);
        if(cm > m) {
            return(0);
        }
        return((10 * an) - ((block.number - bc) % (10 * an)));
    }


    function ae(address di) external at {
        assert(di != address(0));
        n(msg.sender);
        n(di);
        db = di;
    }

    function o(address di) external ab {
        assert(di != address(0));
        n(msg.sender);
        n(di);
        bf = di;
    }

    function p(uint cu) external at {
        require(ag == 1 && bc > 0 && block.number < cu);
        ag = cu;
    }

    function bd(uint ca) external at {
        aj = ca;
    }

    function bk() external at {
        bj = block.number + 3;
        al = 0;
    }

    function ax(uint bz) external at {
        w();
        require(bz > 0 && this.balance >= (s * 9 / 10) + r + bz);
        if(s >= f / 2){
            require((bz <= this.balance / 400) && q + 4 * 60 * 24 * 7 <= block.number);
        }
        msg.sender.transfer(bz);
        q = block.number;
    }

    function bg() payable external {
        w();
    }


    function w() public {
        if(ag > 1 && block.number >= ag + (an * 5)){
            ag = 0;
        }
        else {
            if(bc > 0){
		        uint cm = (block.number - bc) / (10 * an );
                if(cm > ar.length - 2) {
                    ar.push(0);
                }
                if(cm > m && ag == 0 && m < ar.length - 1) {
                    m++;
                }
            }
        }
    }


    function ay() public {
        if(br[msg.sender].balance > 0 && br[msg.sender].d <= block.number){
            uint balance = br[msg.sender].balance;
            br[msg.sender].balance = 0;
            r -= balance;
            dm(balance);
        }
    }

    function dm(uint bz) private {
        uint ck = this.balance / 2;
        if(ck >= bz) {
            msg.sender.transfer(bz);
            if(bz > 1 finney) {
                w();
            }
        }
        else {
            uint af = bz - ck;
            r += af;
            br[msg.sender].balance += uint208(af);
            br[msg.sender].d = uint32(block.number + 4 * 60 * 24 * 30);
            msg.sender.transfer(ck);
        }
    }


    function z() payable external {
        cn(db);
    }

    function cn(address bi) payable public {

        require(ag > 1 && block.number < ag + (an * 5) && s < f);
        uint au = msg.value;
        if(au > f - s) {
            au = f - s;
            s = f;
            ag = 0;
            msg.sender.transfer(msg.value.dq(au));
        }
        else{
            s += au;
        }
        if(bi == address(0) || bi == db){
            r += au / 10;
            br[db].balance += uint208(au / 10);}
        else{
            r += (au * 5 / 100) * 2;
            br[db].balance += uint208(au * 5 / 100);
            br[bi].balance += uint208(au * 5 / 100);}
        br[msg.sender].a = uint16(m);
        uint u = au / 10**15;
        uint ac = au * 16 / 10**17  ;
        uint j = au * 10 / 10**17  ;
        bm[msg.sender] += u;
        bm[db] += ac ;
        bm[bf] += j ;
        ad += u + ac + j;
        Transfer(address(0),msg.sender,u);
        Transfer(address(0),db,ac);
        Transfer(address(0),bf,j);
        LogInvestment(msg.sender,bi,au);
    }

    function ba() external {
        require(ag == 0);
        n(msg.sender);
        uint c = bm[msg.sender] * 10**15;
        Transfer(msg.sender,address(0),bm[msg.sender]);
        delete bm[msg.sender];
        s -= c;
        br[msg.sender].balance += uint208(c * 9 / 10);
        ay();
    }

    function x() external {
        require(ag == 0);
        n(msg.sender);
        ay();
    }

    function n(address di) internal {
        uint dj = br[di].a;
        if((bm[di]==0) || (dj==0)){
            br[di].a=uint16(m);
            return;
        }
        if(dj==m) {
            return;
        }
        uint cs = bm[di] * 0xffffffff / ad;
        uint balance = 0;
        for(;dj<m;dj++) {
            balance += cs * ar[dj];
        }
        balance = (balance / 0xffffffff);
        r += balance;
        br[di].balance += uint208(balance);
        br[di].a = uint16(dj);
        LogDividend(di,balance,dj);
    }


    function bp(Bet bt, uint24 cv) constant private returns (uint) {
        uint24 bx = uint24(bt.ce);
        uint24 do = bx ^ cv;
        uint24 bv =
            ((do & 0xF) == 0 ? 1 : 0 ) +
            ((do & 0xF0) == 0 ? 1 : 0 ) +
            ((do & 0xF00) == 0 ? 1 : 0 ) +
            ((do & 0xF000) == 0 ? 1 : 0 ) +
            ((do & 0xF0000) == 0 ? 1 : 0 ) +
            ((do & 0xF00000) == 0 ? 1 : 0 );
        if(bv == 6){
            return(uint(bt.value) * 7000000);
        }
        if(bv == 5){
            return(uint(bt.value) * 20000);
        }
        if(bv == 4){
            return(uint(bt.value) * 500);
        }
        if(bv == 3){
            return(uint(bt.value) * 25);
        }
        if(bv == 2){
            return(uint(bt.value) * 3);
        }
        return(0);
    }

    function cz(address di) constant external returns (uint)  {
        Bet memory cr = de[di];
        if( (cr.value==0) ||
            (cr.bo<=1) ||
            (block.number<cr.bo) ||
            (block.number>=cr.bo + (10 * an))){
            return(0);
        }
        if(block.number<cr.bo+256){
            return(bp(cr,uint24(block.blockhash(cr.bo))));
        }
        if(bc>0){
            uint32 dg = bu(cr.bo);
            if(dg == 0x1000000) {
                return(uint(cr.value));
            }
            else{
                return(bp(cr,uint24(dg)));
            }
	}
        return(0);
    }

    function dt() public {
        Bet memory cr = de[msg.sender];
        if(cr.bo==0){
            de[msg.sender] = Bet({value: 0, ce: 0, bo: 1});
            return;
        }
        if((cr.value==0) || (cr.bo==1)){
            ay();
            return;
        }
        require(block.number>cr.bo);
        if(cr.bo + (10 * an) <= block.number){
            LogLate(msg.sender,cr.bo,block.number);
            de[msg.sender] = Bet({value: 0, ce: 0, bo: 1});
            return;
        }
        uint cx = 0;
        uint32 dg = 0;
        if(block.number<cr.bo+256){
            dg = uint24(block.blockhash(cr.bo));
            cx = bp(cr,uint24(dg));
        }
        else {
            if(bc>0){
                dg = bu(cr.bo);
                if(dg == 0x1000000) {
                    cx = uint(cr.value);
                }
                else{
                    cx = bp(cr,uint24(dg));
                }
	    }
            else{
                LogLate(msg.sender,cr.bo,block.number);
                de[msg.sender] = Bet({value: 0, ce: 0, bo: 1});
                return();
            }
        }
        de[msg.sender] = Bet({value: 0, ce: 0, bo: 1});
        if(cx>0) {
            LogWin(msg.sender,uint(cr.ce),uint(dg),cx);
            if(cx > co){
                co = cx;
                LogRecordWin(msg.sender,cx);
            }
            dm(cx);
        }
        else{
            LogLoss(msg.sender,uint(cr.ce),uint(dg));
        }
    }

    function () payable external {
        if(msg.value > 0){
            if(ag>1){
                cn(db);
            }
            else{
                dh();
            }
            return;
        }

        if(ag == 0 && bm[msg.sender]>0){
            n(msg.sender);}
        dt();
    }

    function dh() payable public returns (uint) {
        return ap(uint(dk(msg.sender,block.number)), address(0));
    }

    function ak(address bi) payable public returns (uint) {
        return ap(uint(dk(msg.sender,block.number)), bi);
    }

    function ap(uint cv, address bi) payable public returns (uint) {
        dt();
        uint24 bx = uint24(cv);
        require(msg.value <= 1 ether && msg.value < aj);
        if(msg.value > 0){
            if(ag==0) {
                ar[m] += msg.value / 20;
            }
            if(bi != address(0)) {
                uint dr = msg.value / 100;
                r += dr;
                br[bi].balance += uint208(dr);
            }
            if(bj < block.number + 3) {
                bj = block.number + 3;
                al = msg.value;
            }
            else{
                if(al > aj) {
                    bj++;
                    al = msg.value;
                }
                else{
                    al += msg.value;
                }
            }
            de[msg.sender] = Bet({value: uint192(msg.value), ce: uint32(bx), bo: uint32(bj)});
            LogBet(msg.sender,uint(bx),bj,msg.value);
        }
        bw();
        return(bj);
    }


    function aq(uint cy) public returns (uint) {
        require(bc == 0 && cy > 0 && cy <= an);
        uint n = cp.length;
        if(n + cy > an){
            cp.length = an;
        }
        else{
            cp.length += cy;
        }
        for(;n<cp.length;n++){
            cp[n] = 1;
        }
        if(cp.length>=an) {
            bc = block.number - ( block.number % 10);
            bh = bc;
        }
        return(cp.length);
    }

    function y() external returns (uint) {
        return(aq(128));
    }

    function am(uint32 ch, uint32 cl) constant private returns (uint) {
        return( ( uint(block.blockhash(ch  )) & 0xFFFFFF )
            | ( ( uint(block.blockhash(ch+1)) & 0xFFFFFF ) << 24 )
            | ( ( uint(block.blockhash(ch+2)) & 0xFFFFFF ) << 48 )
            | ( ( uint(block.blockhash(ch+3)) & 0xFFFFFF ) << 72 )
            | ( ( uint(block.blockhash(ch+4)) & 0xFFFFFF ) << 96 )
            | ( ( uint(block.blockhash(ch+5)) & 0xFFFFFF ) << 120 )
            | ( ( uint(block.blockhash(ch+6)) & 0xFFFFFF ) << 144 )
            | ( ( uint(block.blockhash(ch+7)) & 0xFFFFFF ) << 168 )
            | ( ( uint(block.blockhash(ch+8)) & 0xFFFFFF ) << 192 )
            | ( ( uint(block.blockhash(ch+9)) & 0xFFFFFF ) << 216 )
            | ( ( uint(cl) / an) << 240));
    }

    function bu(uint cj) constant private returns (uint32) {
        uint dc = (cj - bc) / 10;
        uint dg = cp[dc % an];
        if(dc / an != dg >> 240) {
            return(0x1000000);
        }
        uint da = (cj - bc) % 10;
        return(uint32((dg >> (24 * da)) & 0xFFFFFF));
    }

    function bw() public returns (bool) {
        uint cw = bh;
        if(cw == 0 || block.number <= cw + 10) {
            return(false);
        }
        uint as;
        if(block.number<256) {
            as = 0;
        }
        else{
            as = block.number - 256;
        }
        if(cw < as) {
            uint du = as;
            du += du % 10;
            cw = du;
        }
        uint dc = (cw - bc) / 10;
        cp[dc % an] = am(uint32(cw),uint32(dc));
        bh = cw + 10;
        return(true);
    }

    function aw(uint dl) external {
        uint n=0;
        for(;n<dl;n++){
            if(!bw()){
                return;
            }
        }
    }

}