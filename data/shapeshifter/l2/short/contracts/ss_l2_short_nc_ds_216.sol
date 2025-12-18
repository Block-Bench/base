pragma solidity ^0.4.24;

contract FiftyFlip {
    uint constant DONATING_X = 20;


    uint constant JACKPOT_FEE = 10;
    uint constant JACKPOT_MODULO = 1000;
    uint constant DEV_FEE = 20;
    uint constant WIN_X = 1900;


    uint constant MIN_BET = 0.01 ether;
    uint constant MAX_BET = 1 ether;

    uint constant BET_EXPIRATION_BLOCKS = 250;


    address public bo;
    address public ag;
    address public ab;
    address private bn;


    uint256 public ai;
    uint256 public ak;


    uint256 public ad;
    uint256 public f;

    struct Bet {

        uint bi;

        uint256 ah;

        bool bf;

        address bm;
    }

    mapping (uint => Bet) bt;
    mapping (address => uint) y;


    event Wager(uint ay, uint av, uint256 p, bool bf, address at);
    event Win(address bj, uint bi, uint ay, bool bc, uint ao);
    event Lose(address br, uint bi, uint ay, bool bc, uint ao);
    event Refund(uint ay, uint256 bi, address aw);
    event Donate(uint256 bi, address bb);
    event FailedPayment(address az, uint bi);
    event Payment(address al, uint bi);
    event JackpotPayment(address bm, uint ay, uint aj);


    constructor (address af, address g, address d) public {
        bo = msg.sender;
        ag = g;
        bn = af;
        ab = d;
        ai = 0;
        ak = 0;
        ad = 0;
        f = 0;
    }


    modifier au() {
        require (msg.sender == bo, "You are not the owner of this contract!");
        _;
    }

    modifier bd() {
        require (msg.sender == ag, "You are not the bot of this contract!");
        _;
    }

    modifier e() {
        require (address(this).balance >= ad + ai + ak, "This contract doesn't have enough balance, it is stopped till someone donate to this game!");
        _;
    }


    function() public payable { }

    function s(address g)
    au()
    external
    {
        ag = g;
    }

    function l(address v)
    au()
    external
    {
        ab = v;
    }


    function bq(bool bp, uint ay, uint m, uint8 v, bytes32 r, bytes32 s)
    e()
    external
    payable {
        Bet storage bv = bt[ay];
        uint bi = msg.value;
        address bm = msg.sender;
        require (bv.bm == address(0), "Ticket is not new one!");
        require (bi >= MIN_BET, "Your bet is lower than minimum bet amount");
        require (bi <= MAX_BET, "Your bet is higher than maximum bet amount");
        require (c() >= 2 * bi, "If we accept this, this contract will be in danger!");

        require (block.number <= m, "Ticket has expired.");
        bytes32 u = ax(abi.aa('\x19Ethereum Signed Message:\n37', uint40(m), ay));
        require (ab == aq(u, v, r, s), "web3 vrs signature is not valid.");

        ai += bi * JACKPOT_FEE / 1000;
        ak += bi * DEV_FEE / 1000;
        ad += bi * WIN_X / 1000;

        uint t = bi * DONATING_X / 1000;
        bn.call.value(t)(bytes4(ax("donate()")));
        f += t;

        bv.bi = bi;
        bv.ah = block.number;
        bv.bf = bp;
        bv.bm = bm;

        emit Wager(ay, bv.bi, bv.ah, bv.bf, bv.bm);
    }


    function bu(uint ac)
    e()
    external
    {
        uint ay = uint(ax(abi.aa(ac)));
        Bet storage bv = bt[ay];
        require (bv.bm != address(0), "TicketID is not correct!");
        require (bv.bi != 0, "Ticket is already used one!");
        uint256 ah = bv.ah;
        if(ah < block.number && ah >= block.number - BET_EXPIRATION_BLOCKS)
        {
            uint256 bg = uint256(ax(abi.aa(blockhash(ah),  ac)));
            bool bc = (bg % 2) !=0;
            uint ao = bg % JACKPOT_MODULO;

            uint w = bv.bi * WIN_X / 1000;

            uint be = 0;
            uint aj = 0;

            if(bv.bf == bc) {
                be = w;
            }
            if(ao == 0) {
                aj = ai;
                ai = 0;
            }
            if (aj > 0) {
                emit JackpotPayment(bv.bm, ay, aj);
            }
            if(be + aj > 0)
            {
                bh(bv.bm, be + aj, ay, bc, ao);
            }
            else
            {
                as(bv.bm, bv.bi, ay, bc, ao);
            }
            ad -= w;
            bv.bi = 0;
        }
        else
        {
            revert();
        }
    }

    function a()
    external
    payable
    {
        y[msg.sender] += msg.value;
        emit Donate(msg.value, msg.sender);
    }

    function j(uint bi)
    external
    {
        require(y[msg.sender] >= bi, "You are going to withdraw more than you donated!");

        if (ar(msg.sender, bi)){
            y[msg.sender] -= bi;
        }
    }


    function bk(uint ay)
    e()
    external {
        Bet storage bv = bt[ay];

        require (bv.bi != 0, "this ticket has no balance");
        require (block.number > bv.ah + BET_EXPIRATION_BLOCKS, "this ticket is expired.");
        ap(ay);
    }


    function q(address n, uint o)
    au()
    e()
    external {
        require (ak >= o, "You are trying to withdraw more amount than developer fee.");
        require (o <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (ak <= address(this).balance, "Not enough funds to withdraw.");
        if (ar(n, o)){
            ak -= o;
        }
    }


    function r(uint o)
    bd()
    e()
    external {
        require (ak >= o, "You are trying to withdraw more amount than developer fee.");
        require (o <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (ak <= address(this).balance, "Not enough funds to withdraw.");
        if (ar(ag, o)){
            ak -= o;
        }
    }


    function am(uint ay)
    constant
    external
    returns (uint, uint256, bool, address){
        Bet storage bv = bt[ay];
        return (bv.bi, bv.ah, bv.bf, bv.bm);
    }


    function h()
    constant
    external
    returns (uint){
        return address(this).balance;
    }


    function c()
    constant
    public
    returns (uint){
        if (address(this).balance > ad + ai + ak)
            return address(this).balance - ad - ai - ak;
        return 0;
    }


    function bs() external au() {
        require (ad == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(bo);
    }


    function bh(address bj, uint x, uint ay, bool bc, uint ao)
    internal
    {
        bj.transfer(x);
        emit Win(bj, x, ay, bc, ao);
    }


    function ap(uint ay)
    internal
    {
        Bet storage bv = bt[ay];
        address aw = bv.bm;
        uint256 x = bv.bi;
        aw.transfer(x);

        uint w = bv.bi * WIN_X / 1000;
        ad -= w;

        bv.bi = 0;
        emit Refund(ay, x, aw);
    }


    function ar(address az, uint bi) private returns (bool){
        bool ba = az.send(bi);
        if (ba) {
            emit Payment(az, bi);
        } else {
            emit FailedPayment(az, bi);
        }
        return ba;
    }

    function as(address bm, uint bi, uint ay, bool bc, uint ao)
    internal
    {
        emit Lose(bm, bi, ay, bc, ao);
    }


    function ae(uint[] k) external {
        uint length = k.length;

        for (uint i = 0; i < length; i++) {
            i(k[i]);
        }
    }


    function i(uint ay) private {
        Bet storage bv = bt[ay];


        if (bv.bi != 0 || block.number <= bv.ah + BET_EXPIRATION_BLOCKS) {
            return;
        }

        bv.ah = 0;
        bv.bf = false;
        bv.bm = address(0);
    }


    function b(address z, address an, uint bl)
    public
    au()
    returns (bool ba)
    {
        return ERC20Interface(z).transfer(an, bl);
    }
}


contract ERC20Interface
{
    function transfer(address bw, uint256 bl) public returns (bool ba);
}