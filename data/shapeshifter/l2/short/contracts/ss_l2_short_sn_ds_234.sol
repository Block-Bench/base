// SPDX-License-Identifier: MIT
pragma solidity ^0.4.13;

library SafeMath {
  function dt(uint a, uint b) internal returns (uint) {
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
  uint public af;
  address public cy; //owner
  address public bi; //animator
  function az(address dp) constant returns (uint);
  function transfer(address dv, uint value);
  event Transfer(address indexed from, address indexed dv, uint value);
  function m(address dp) internal; // pays remaining dividend
}

contract ERC20 is ERC20Basic {
  function at(address cy, address by) constant returns (uint);
  function ab(address from, address dv, uint value);
  function bt(address by, uint value);
  event Approval(address indexed cy, address indexed by, uint value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) bl;

  modifier h(uint dk) {
     assert(msg.data.length >= dk + 4);
     _;
  }

  function transfer(address do, uint cg) h(2 * 32) {
    m(msg.sender);
    bl[msg.sender] = bl[msg.sender].dt(cg);
    if(do == address(this)) {
        m(cy);
        bl[cy] = bl[cy].dn(cg);
        Transfer(msg.sender, cy, cg);
    }
    else {
        m(do);
        bl[do] = bl[do].dn(cg);
        Transfer(msg.sender, do, cg);
    }
  }

  function az(address cq) constant returns (uint balance) {
    return bl[cq];
  }
}

contract StandardToken is BasicToken, ERC20 {
  mapping (address => mapping (address => uint)) cc;

  function ab(address ct, address do, uint cg) h(3 * 32) {
    var aj = cc[ct][msg.sender];
    m(ct);
    m(do);
    bl[do] = bl[do].dn(cg);
    bl[ct] = bl[ct].dt(cg);
    cc[ct][msg.sender] = aj.dt(cg);
    Transfer(ct, do, cg);
  }

  function bt(address bm, uint cg) {
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    assert(!((cg != 0) && (cc[msg.sender][bm] != 0)));
    cc[msg.sender][bm] = cg;
    Approval(msg.sender, bm, cg);
  }

  function at(address cq, address bm) constant returns (uint aw) {
    return cc[cq][bm];
  }
}

contract SmartBillions is StandardToken {

    // metadata
    string public constant dj = "SmartBillions Token";
    string public constant ci = "PLAY";
    uint public constant bh = 0;

    // contract state
    struct Wallet {
        uint208 balance; // current balance of user
    	uint16 b; // last processed dividend period of user's tokens
    	uint32 d; // next withdrawal possible after this block number
    }
    mapping (address => Wallet) bw;
    struct Bet {
        uint192 value; // bet size
        uint32 bz; // selected numbers
        uint32 bo; // blocknumber when lottery runs
    }
    mapping (address => Bet) dh;

    uint public u = 0; // sum of funds in wallets

    // investment parameters
    uint public ah = 1; // investment start block, 0: closed, 1: preparation
    uint public r = 0; // funding from investors
    uint public g = 200000 ether; // maximum funding
    uint public p = 1;
    uint[] public be; // dividens collected per period, growing array

    // betting parameters
    uint public ck = 0; // maximum prize won
    uint public au = 0; // start time of building hashes database
    uint public bk = 0; // last saved block of hashes
    uint public bf = 0; // next available bet block.number
    uint public ak = 0; // used bet volume of next block
    uint public an = 5 ether; // maximum bet size per block
    uint[] public cp; // space for storing lottery results

    // constants
    //uint public constant hashesSize = 1024 ; // DEBUG ONLY !!!
    uint public constant am = 16384 ; // 30 days of blocks
    uint public q = 0 ; // block of last cold store transfer

    // events
    event LogBet(address indexed co, uint bx, uint ae, uint bu);
    event LogLoss(address indexed co, uint bx, uint dl);
    event LogWin(address indexed co, uint bx, uint dl, uint cz);
    event LogInvestment(address indexed bp, address indexed bv, uint cn);
    event LogRecordWin(address indexed co, uint cn);
    event LogLate(address indexed co,uint c,uint a);
    event LogDividend(address indexed bp, uint cn, uint cm);

    modifier bd() {
        assert(msg.sender == cy);
        _;
    }

    modifier v() {
        assert(msg.sender == bi);
        _;
    }

    // constructor
    function SmartBillions() {
        cy = msg.sender;
        bi = msg.sender;
        bw[cy].b = uint16(p);
        be.push(0); // not used
        be.push(0); // current dividend
    }

/* getters */

    function z() constant external returns (uint) {
        return uint(cp.length);
    }

    function j(address cq) constant external returns (uint) {
        return uint(bw[cq].balance);
    }

    function n(address cq) constant external returns (uint) {
        return uint(bw[cq].b);
    }

    function t(address cq) constant external returns (uint) {
        return uint(bw[cq].d);
    }

    function ap(address cq) constant external returns (uint) {
        return uint(dh[cq].value);
    }

    function as(address cq) constant external returns (uint) {
        return uint(dh[cq].bz);
    }

    function f(address cq) constant external returns (uint) {
        return uint(dh[cq].bo);
    }

    function i() constant external returns (uint) {
        if(ah > 0) {
            return(0);
        }
        uint cm = (block.number - au) / (10 * am);
        if(cm > p) {
            return(0);
        }
        return((10 * am) - ((block.number - au) % (10 * am)));
    }

/* administrative functions */

    function ag(address di) external bd {
        assert(di != address(0));
        m(msg.sender);
        m(di);
        cy = di;
    }

    function l(address di) external v {
        assert(di != address(0));
        m(msg.sender);
        m(di);
        bi = di;
    }

    function o(uint cw) external bd {
        require(ah == 1 && au > 0 && block.number < cw);
        ah = cw;
    }

    function ba(uint ce) external bd {
        an = ce;
    }

    function bj() external bd {
        bf = block.number + 3;
        ak = 0;
    }

    function bc(uint bs) external bd {
        ac();
        require(bs > 0 && this.balance >= (r * 9 / 10) + u + bs);
        if(r >= g / 2){ // additional jackpot protection
            require((bs <= this.balance / 400) && q + 4 * 60 * 24 * 7 <= block.number);
        }
        msg.sender.transfer(bs);
        q = block.number;
    }

    function bn() payable external {
        ac();
    }

/* housekeeping functions */

    function ac() public {
        if(ah > 1 && block.number >= ah + (am * 5)){ // ca. 14 days
            ah = 0; // start dividend payments
        }
        else {
            if(au > 0){
		        uint cm = (block.number - au) / (10 * am );
                if(cm > be.length - 2) {
                    be.push(0);
                }
                if(cm > p && ah == 0 && p < be.length - 1) {
                    p++;
                }
            }
        }
    }

/* payments */

    function ax() public {
        if(bw[msg.sender].balance > 0 && bw[msg.sender].d <= block.number){
            uint balance = bw[msg.sender].balance;
            bw[msg.sender].balance = 0;
            u -= balance;
            du(balance);
        }
    }

    function du(uint bs) private {
        uint ch = this.balance / 2;
        if(ch >= bs) {
            msg.sender.transfer(bs);
            if(bs > 1 finney) {
                ac();
            }
        }
        else {
            uint ad = bs - ch;
            u += ad;
            bw[msg.sender].balance += uint208(ad);
            bw[msg.sender].d = uint32(block.number + 4 * 60 * 24 * 30); // wait 1 month for more funds
            msg.sender.transfer(ch);
        }
    }

/* investment functions */

    function aa() payable external {
        cj(cy);
    }

    function cj(address bg) payable public {
        //require(fromUSA()==false); // fromUSA() not yet implemented :-(
        require(ah > 1 && block.number < ah + (am * 5) && r < g);
        uint aq = msg.value;
        if(aq > g - r) {
            aq = g - r;
            r = g;
            ah = 0; // close investment round
            msg.sender.transfer(msg.value.dt(aq)); // send back funds immediately
        }
        else{
            r += aq;
        }
        if(bg == address(0) || bg == cy){
            u += aq / 10;
            bw[cy].balance += uint208(aq / 10);} // 10% for marketing if no affiliates
        else{
            u += (aq * 5 / 100) * 2;
            bw[cy].balance += uint208(aq * 5 / 100); // 5% initial marketing funds
            bw[bg].balance += uint208(aq * 5 / 100);} // 5% for affiliates
        bw[msg.sender].b = uint16(p); // assert(dividendPeriod == 1);
        uint s = aq / 10**15;
        uint w = aq * 16 / 10**17  ;
        uint k = aq * 10 / 10**17  ;
        bl[msg.sender] += s;
        bl[cy] += w ; // 13% of shares go to developers
        bl[bi] += k ; // 8% of shares go to animator
        af += s + w + k;
        Transfer(address(0),msg.sender,s); // for etherscan
        Transfer(address(0),cy,w); // for etherscan
        Transfer(address(0),bi,k); // for etherscan
        LogInvestment(msg.sender,bg,aq);
    }

    function ay() external {
        require(ah == 0);
        m(msg.sender);
        uint e = bl[msg.sender] * 10**15;
        Transfer(msg.sender,address(0),bl[msg.sender]); // for etherscan
        delete bl[msg.sender]; // totalSupply stays the same, investBalance is reduced
        r -= e;
        bw[msg.sender].balance += uint208(e * 9 / 10);
        ax();
    }

    function y() external {
        require(ah == 0);
        m(msg.sender);
        ax();
    }

    function m(address di) internal {
        uint dg = bw[di].b;
        if((bl[di]==0) || (dg==0)){
            bw[di].b=uint16(p);
            return;
        }
        if(dg==p) {
            return;
        }
        uint cs = bl[di] * 0xffffffff / af;
        uint balance = 0;
        for(;dg<p;dg++) {
            balance += cs * be[dg];
        }
        balance = (balance / 0xffffffff);
        u += balance;
        bw[di].balance += uint208(balance);
        bw[di].b = uint16(dg);
        LogDividend(di,balance,dg);
    }

/* lottery functions */

    function bq(Bet cb, uint24 cv) constant private returns (uint) { // house fee 13.85%
        uint24 bx = uint24(cb.bz);
        uint24 ds = bx ^ cv;
        uint24 br =
            ((ds & 0xF) == 0 ? 1 : 0 ) +
            ((ds & 0xF0) == 0 ? 1 : 0 ) +
            ((ds & 0xF00) == 0 ? 1 : 0 ) +
            ((ds & 0xF000) == 0 ? 1 : 0 ) +
            ((ds & 0xF0000) == 0 ? 1 : 0 ) +
            ((ds & 0xF00000) == 0 ? 1 : 0 );
        if(br == 6){
            return(uint(cb.value) * 7000000);
        }
        if(br == 5){
            return(uint(cb.value) * 20000);
        }
        if(br == 4){
            return(uint(cb.value) * 500);
        }
        if(br == 3){
            return(uint(cb.value) * 25);
        }
        if(br == 2){
            return(uint(cb.value) * 3);
        }
        return(0);
    }

    function cu(address di) constant external returns (uint)  {
        Bet memory co = dh[di];
        if( (co.value==0) ||
            (co.bo<=1) ||
            (block.number<co.bo) ||
            (block.number>=co.bo + (10 * am))){
            return(0);
        }
        if(block.number<co.bo+256){
            return(bq(co,uint24(block.blockhash(co.bo))));
        }
        if(au>0){
            uint32 dl = cd(co.bo);
            if(dl == 0x1000000) { // load hash failed :-(, return funds
                return(uint(co.value));
            }
            else{
                return(bq(co,uint24(dl)));
            }
	}
        return(0);
    }

    function dm() public {
        Bet memory co = dh[msg.sender];
        if(co.bo==0){ // create a new player
            dh[msg.sender] = Bet({value: 0, bz: 0, bo: 1});
            return;
        }
        if((co.value==0) || (co.bo==1)){
            ax();
            return;
        }
        require(block.number>co.bo); // if there is an active bet, throw()
        if(co.bo + (10 * am) <= block.number){ // last bet too long ago, lost !
            LogLate(msg.sender,co.bo,block.number);
            dh[msg.sender] = Bet({value: 0, bz: 0, bo: 1});
            return;
        }
        uint cz = 0;
        uint32 dl = 0;
        if(block.number<co.bo+256){
            dl = uint24(block.blockhash(co.bo));
            cz = bq(co,uint24(dl));
        }
        else {
            if(au>0){ // lottery is open even before swap space (hashes) is ready, but player must collect results within 256 blocks after run
                dl = cd(co.bo);
                if(dl == 0x1000000) { // load hash failed :-(, return funds
                    cz = uint(co.value);
                }
                else{
                    cz = bq(co,uint24(dl));
                }
	    }
            else{
                LogLate(msg.sender,co.bo,block.number);
                dh[msg.sender] = Bet({value: 0, bz: 0, bo: 1});
                return();
            }
        }
        dh[msg.sender] = Bet({value: 0, bz: 0, bo: 1});
        if(cz>0) {
            LogWin(msg.sender,uint(co.bz),uint(dl),cz);
            if(cz > ck){
                ck = cz;
                LogRecordWin(msg.sender,cz);
            }
            du(cz);
        }
        else{
            LogLoss(msg.sender,uint(co.bz),uint(dl));
        }
    }

    function () payable external {
        if(msg.value > 0){
            if(ah>1){ // during ICO payment to the contract is treated as investment
                cj(cy);
            }
            else{ // if not ICO running payment to contract is treated as play
                df();
            }
            return;
        }
        //check for dividends and other assets
        if(ah == 0 && bl[msg.sender]>0){
            m(msg.sender);}
        dm(); // will run payWallet() if nothing else available
    }

    function df() payable public returns (uint) {
        return ai(uint(de(msg.sender,block.number)), address(0));
    }

    function al(address bg) payable public returns (uint) {
        return ai(uint(de(msg.sender,block.number)), bg);
    }

    function ai(uint cv, address bg) payable public returns (uint) {
        dm(); // check if player did not win
        uint24 bx = uint24(cv);
        require(msg.value <= 1 ether && msg.value < an);
        if(msg.value > 0){
            if(ah==0) { // dividends only after investment finished
                be[p] += msg.value / 20; // 5% dividend
            }
            if(bg != address(0)) {
                uint dq = msg.value / 100;
                u += dq;
                bw[bg].balance += uint208(dq); // 1% for affiliates
            }
            if(bf < block.number + 3) {
                bf = block.number + 3;
                ak = msg.value;
            }
            else{
                if(ak > an) {
                    bf++;
                    ak = msg.value;
                }
                else{
                    ak += msg.value;
                }
            }
            dh[msg.sender] = Bet({value: uint192(msg.value), bz: uint32(bx), bo: uint32(bf)});
            LogBet(msg.sender,uint(bx),bf,msg.value);
        }
        ca(); // players help collecing data
        return(bf);
    }

/* database functions */

    function av(uint dc) public returns (uint) {
        require(au == 0 && dc > 0 && dc <= am);
        uint n = cp.length;
        if(n + dc > am){
            cp.length = am;
        }
        else{
            cp.length += dc;
        }
        for(;n<cp.length;n++){ // make sure to burn gas
            cp[n] = 1;
        }
        if(cp.length>=am) { // assume block.number > 10
            au = block.number - ( block.number % 10);
            bk = au;
        }
        return(cp.length);
    }

    function x() external returns (uint) {
        return(av(128));
    }

    function ao(uint32 cl, uint32 cr) constant private returns (uint) {
        return( ( uint(block.blockhash(cl  )) & 0xFFFFFF )
            | ( ( uint(block.blockhash(cl+1)) & 0xFFFFFF ) << 24 )
            | ( ( uint(block.blockhash(cl+2)) & 0xFFFFFF ) << 48 )
            | ( ( uint(block.blockhash(cl+3)) & 0xFFFFFF ) << 72 )
            | ( ( uint(block.blockhash(cl+4)) & 0xFFFFFF ) << 96 )
            | ( ( uint(block.blockhash(cl+5)) & 0xFFFFFF ) << 120 )
            | ( ( uint(block.blockhash(cl+6)) & 0xFFFFFF ) << 144 )
            | ( ( uint(block.blockhash(cl+7)) & 0xFFFFFF ) << 168 )
            | ( ( uint(block.blockhash(cl+8)) & 0xFFFFFF ) << 192 )
            | ( ( uint(block.blockhash(cl+9)) & 0xFFFFFF ) << 216 )
            | ( ( uint(cr) / am) << 240));
    }

    function cd(uint cf) constant private returns (uint32) {
        uint db = (cf - au) / 10;
        uint dl = cp[db % am];
        if(db / am != dl >> 240) {
            return(0x1000000); // load failed, incorrect data in hashes
        }
        uint cx = (cf - au) % 10;
        return(uint32((dl >> (24 * cx)) & 0xFFFFFF));
    }

    function ca() public returns (bool) {
        uint da = bk;
        if(da == 0 || block.number <= da + 10) {
            return(false);
        }
        uint ar;
        if(block.number<256) { // useless test for testnet :-(
            ar = 0;
        }
        else{
            ar = block.number - 256;
        }
        if(da < ar) {
            uint dr = ar;
            dr += dr % 10;
            da = dr;
        }
        uint db = (da - au) / 10;
        cp[db % am] = ao(uint32(da),uint32(db));
        bk = da + 10;
        return(true);
    }

    function bb(uint dd) external {
        uint n=0;
        for(;n<dd;n++){
            if(!ca()){
                return;
            }
        }
    }

}