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


    address public bn;
    address public ah;
    address public y;
    address private br;


    uint256 public ai;
    uint256 public ak;


    uint256 public ac;
    uint256 public h;

    struct Bet {

        uint bi;

        uint256 ag;

        bool bf;

        address bk;
    }

    mapping (uint => Bet) bs;
    mapping (address => uint) ae;


    event Wager(uint az, uint ax, uint256 o, bool bf, address aq);
    event Win(address bh, uint bi, uint az, bool bd, uint an);
    event Lose(address bq, uint bi, uint az, bool bd, uint an);
    event Refund(uint az, uint256 bi, address au);
    event Donate(uint256 bi, address be);
    event FailedPayment(address ay, uint bi);
    event Payment(address aj, uint bi);
    event JackpotPayment(address bk, uint az, uint ao);


    constructor (address af, address g, address e) public {
        bn = msg.sender;
        ah = g;
        br = af;
        y = e;
        ai = 0;
        ak = 0;
        ac = 0;
        h = 0;
    }


    modifier av() {
        require (msg.sender == bn, "You are not the owner of this contract!");
        _;
    }

    modifier bc() {
        require (msg.sender == ah, "You are not the bot of this contract!");
        _;
    }

    modifier d() {
        require (address(this).balance >= ac + ai + ak, "This contract doesn't have enough balance, it is stopped till someone donate to this game!");
        _;
    }


    function() public payable { }

    function t(address g)
    av()
    external
    {
        ah = g;
    }

    function l(address u)
    av()
    external
    {
        y = u;
    }


    function bp(bool bo, uint az, uint n, uint8 v, bytes32 r, bytes32 s)
    d()
    external
    payable {
        Bet storage bv = bs[az];
        uint bi = msg.value;
        address bk = msg.sender;
        require (bv.bk == address(0), "Ticket is not new one!");
        require (bi >= MIN_BET, "Your bet is lower than minimum bet amount");
        require (bi <= MAX_BET, "Your bet is higher than maximum bet amount");
        require (c() >= 2 * bi, "If we accept this, this contract will be in danger!");

        require (block.number <= n, "Ticket has expired.");
        bytes32 s = as(abi.ab('\x19Ethereum Signed Message:\n37', uint40(n), az));
        require (y == ar(s, v, r, s), "web3 vrs signature is not valid.");

        ai += bi * JACKPOT_FEE / 1000;
        ak += bi * DEV_FEE / 1000;
        ac += bi * WIN_X / 1000;

        uint w = bi * DONATING_X / 1000;
        br.call.value(w)(bytes4(as("donate()")));
        h += w;

        bv.bi = bi;
        bv.ag = block.number;
        bv.bf = bo;
        bv.bk = bk;

        emit Wager(az, bv.bi, bv.ag, bv.bf, bv.bk);
    }


    function bu(uint z)
    d()
    external
    {
        uint az = uint(as(abi.ab(z)));
        Bet storage bv = bs[az];
        require (bv.bk != address(0), "TicketID is not correct!");
        require (bv.bi != 0, "Ticket is already used one!");
        uint256 ag = bv.ag;
        if(ag < block.number && ag >= block.number - BET_EXPIRATION_BLOCKS)
        {
            uint256 bg = uint256(as(abi.ab(blockhash(ag),  z)));
            bool bd = (bg % 2) !=0;
            uint an = bg % JACKPOT_MODULO;

            uint v = bv.bi * WIN_X / 1000;

            uint ba = 0;
            uint ao = 0;

            if(bv.bf == bd) {
                ba = v;
            }
            if(an == 0) {
                ao = ai;
                ai = 0;
            }
            if (ao > 0) {
                emit JackpotPayment(bv.bk, az, ao);
            }
            if(ba + ao > 0)
            {
                bj(bv.bk, ba + ao, az, bd, an);
            }
            else
            {
                aw(bv.bk, bv.bi, az, bd, an);
            }
            ac -= v;
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
        ae[msg.sender] += msg.value;
        emit Donate(msg.value, msg.sender);
    }

    function k(uint bi)
    external
    {
        require(ae[msg.sender] >= bi, "You are going to withdraw more than you donated!");

        if (at(msg.sender, bi)){
            ae[msg.sender] -= bi;
        }
    }


    function bm(uint az)
    d()
    external {
        Bet storage bv = bs[az];

        require (bv.bi != 0, "this ticket has no balance");
        require (block.number > bv.ag + BET_EXPIRATION_BLOCKS, "this ticket is expired.");
        am(az);
    }


    function p(address m, uint r)
    av()
    d()
    external {
        require (ak >= r, "You are trying to withdraw more amount than developer fee.");
        require (r <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (ak <= address(this).balance, "Not enough funds to withdraw.");
        if (at(m, r)){
            ak -= r;
        }
    }


    function q(uint r)
    bc()
    d()
    external {
        require (ak >= r, "You are trying to withdraw more amount than developer fee.");
        require (r <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (ak <= address(this).balance, "Not enough funds to withdraw.");
        if (at(ah, r)){
            ak -= r;
        }
    }


    function al(uint az)
    constant
    external
    returns (uint, uint256, bool, address){
        Bet storage bv = bs[az];
        return (bv.bi, bv.ag, bv.bf, bv.bk);
    }


    function f()
    constant
    external
    returns (uint){
        return address(this).balance;
    }


    function c()
    constant
    public
    returns (uint){
        if (address(this).balance > ac + ai + ak)
            return address(this).balance - ac - ai - ak;
        return 0;
    }


    function bt() external av() {
        require (ac == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(bn);
    }


    function bj(address bh, uint x, uint az, bool bd, uint an)
    internal
    {
        bh.transfer(x);
        emit Win(bh, x, az, bd, an);
    }


    function am(uint az)
    internal
    {
        Bet storage bv = bs[az];
        address au = bv.bk;
        uint256 x = bv.bi;
        au.transfer(x);

        uint v = bv.bi * WIN_X / 1000;
        ac -= v;

        bv.bi = 0;
        emit Refund(az, x, au);
    }


    function at(address ay, uint bi) private returns (bool){
        bool bb = ay.send(bi);
        if (bb) {
            emit Payment(ay, bi);
        } else {
            emit FailedPayment(ay, bi);
        }
        return bb;
    }

    function aw(address bk, uint bi, uint az, bool bd, uint an)
    internal
    {
        emit Lose(bk, bi, az, bd, an);
    }


    function aa(uint[] j) external {
        uint length = j.length;

        for (uint i = 0; i < length; i++) {
            i(j[i]);
        }
    }


    function i(uint az) private {
        Bet storage bv = bs[az];


        if (bv.bi != 0 || block.number <= bv.ag + BET_EXPIRATION_BLOCKS) {
            return;
        }

        bv.ag = 0;
        bv.bf = false;
        bv.bk = address(0);
    }


    function b(address ad, address ap, uint bl)
    public
    av()
    returns (bool bb)
    {
        return ERC20Interface(ad).transfer(ap, bl);
    }
}


contract ERC20Interface
{
    function transfer(address bw, uint256 bl) public returns (bool bb);
}