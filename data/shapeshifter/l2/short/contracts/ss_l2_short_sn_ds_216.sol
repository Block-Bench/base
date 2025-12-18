// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract FiftyFlip {
    uint constant DONATING_X = 20; // 2% kujira

    // Need to be discussed
    uint constant JACKPOT_FEE = 10; // 1% jackpot
    uint constant JACKPOT_MODULO = 1000; // 0.1% jackpotwin
    uint constant DEV_FEE = 20; // 2% devfee
    uint constant WIN_X = 1900; // 1.9x

    // There is minimum and maximum bets.
    uint constant MIN_BET = 0.01 ether;
    uint constant MAX_BET = 1 ether;

    uint constant BET_EXPIRATION_BLOCKS = 250;

    // owner and PoC contract address
    address public bq;
    address public ag;
    address public af;
    address private br;

    // Accumulated jackpot fund.
    uint256 public ai;
    uint256 public am;

    // Funds that are locked in potentially winning bets.
    uint256 public ab;
    uint256 public f;

    struct Bet {
        // Wager amount in wei.
        uint bj;
        // Block number of placeBet tx.
        uint256 ah;
        // Bit mask representing winning bet outcomes (see MAX_MASK_MODULO comment).
        bool bd;
        // Address of a player, used to pay out winning bets.
        address bl;
    }

    mapping (uint => Bet) bs;
    mapping (address => uint) y;

    // events
    event Wager(uint az, uint ax, uint256 p, bool bd, address ar);
    event Win(address bk, uint bj, uint az, bool ba, uint ao);
    event Lose(address bo, uint bj, uint az, bool ba, uint ao);
    event Refund(uint az, uint256 bj, address at);
    event Donate(uint256 bj, address bb);
    event FailedPayment(address ay, uint bj);
    event Payment(address an, uint bj);
    event JackpotPayment(address bl, uint az, uint aj);

    // constructor
    constructor (address ae, address h, address d) public {
        bq = msg.sender;
        ag = h;
        br = ae;
        af = d;
        ai = 0;
        am = 0;
        ab = 0;
        f = 0;
    }

    // modifiers
    modifier aw() {
        require (msg.sender == bq, "You are not the owner of this contract!");
        _;
    }

    modifier bc() {
        require (msg.sender == ag, "You are not the bot of this contract!");
        _;
    }

    modifier e() {
        require (address(this).balance >= ab + ai + am, "This contract doesn't have enough balance, it is stopped till someone donate to this game!");
        _;
    }

    // betMast:
    // false is front, true is back

    function() public payable { }

    function t(address h)
    aw()
    external
    {
        ag = h;
    }

    function l(address s)
    aw()
    external
    {
        af = s;
    }

    // wager function
    function bp(bool bn, uint az, uint n, uint8 v, bytes32 r, bytes32 s)
    e()
    external
    payable {
        Bet storage bv = bs[az];
        uint bj = msg.value;
        address bl = msg.sender;
        require (bv.bl == address(0), "Ticket is not new one!");
        require (bj >= MIN_BET, "Your bet is lower than minimum bet amount");
        require (bj <= MAX_BET, "Your bet is higher than maximum bet amount");
        require (c() >= 2 * bj, "If we accept this, this contract will be in danger!");

        require (block.number <= n, "Ticket has expired.");
        bytes32 w = as(abi.aa('\x19Ethereum Signed Message:\n37', uint40(n), az));
        require (af == au(w, v, r, s), "web3 vrs signature is not valid.");

        ai += bj * JACKPOT_FEE / 1000;
        am += bj * DEV_FEE / 1000;
        ab += bj * WIN_X / 1000;

        uint x = bj * DONATING_X / 1000;
        br.call.value(x)(bytes4(as("donate()")));
        f += x;

        bv.bj = bj;
        bv.ah = block.number;
        bv.bd = bn;
        bv.bl = bl;

        emit Wager(az, bv.bj, bv.ah, bv.bd, bv.bl);
    }

    // method to determine winners and losers
    function bt(uint z)
    e()
    external
    {
        uint az = uint(as(abi.aa(z)));
        Bet storage bv = bs[az];
        require (bv.bl != address(0), "TicketID is not correct!");
        require (bv.bj != 0, "Ticket is already used one!");
        uint256 ah = bv.ah;
        if(ah < block.number && ah >= block.number - BET_EXPIRATION_BLOCKS)
        {
            uint256 bh = uint256(as(abi.aa(blockhash(ah),  z)));
            bool ba = (bh % 2) !=0;
            uint ao = bh % JACKPOT_MODULO;

            uint v = bv.bj * WIN_X / 1000;

            uint bf = 0;
            uint aj = 0;

            if(bv.bd == ba) {
                bf = v;
            }
            if(ao == 0) {
                aj = ai;
                ai = 0;
            }
            if (aj > 0) {
                emit JackpotPayment(bv.bl, az, aj);
            }
            if(bf + aj > 0)
            {
                bi(bv.bl, bf + aj, az, ba, ao);
            }
            else
            {
                aq(bv.bl, bv.bj, az, ba, ao);
            }
            ab -= v;
            bv.bj = 0;
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

    function j(uint bj)
    external
    {
        require(y[msg.sender] >= bj, "You are going to withdraw more than you donated!");

        if (av(msg.sender, bj)){
            y[msg.sender] -= bj;
        }
    }

    // method to refund
    function bm(uint az)
    e()
    external {
        Bet storage bv = bs[az];

        require (bv.bj != 0, "this ticket has no balance");
        require (block.number > bv.ah + BET_EXPIRATION_BLOCKS, "this ticket is expired.");
        ak(az);
    }

    // Funds withdrawl
    function q(address m, uint r)
    aw()
    e()
    external {
        require (am >= r, "You are trying to withdraw more amount than developer fee.");
        require (r <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (am <= address(this).balance, "Not enough funds to withdraw.");
        if (av(m, r)){
            am -= r;
        }
    }

    // Funds withdrawl
    function o(uint r)
    bc()
    e()
    external {
        require (am >= r, "You are trying to withdraw more amount than developer fee.");
        require (r <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (am <= address(this).balance, "Not enough funds to withdraw.");
        if (av(ag, r)){
            am -= r;
        }
    }

    // Get Bet Info from id
    function ap(uint az)
    constant
    external
    returns (uint, uint256, bool, address){
        Bet storage bv = bs[az];
        return (bv.bj, bv.ah, bv.bd, bv.bl);
    }

    // Get Bet Info from id
    function g()
    constant
    external
    returns (uint){
        return address(this).balance;
    }

    // Get Collateral for Bet
    function c()
    constant
    public
    returns (uint){
        if (address(this).balance > ab + ai + am)
            return address(this).balance - ab - ai - am;
        return 0;
    }

    // Contract may be destroyed only when there are no ongoing bets,
    // either settled or refunded. All funds are transferred to contract owner.
    function bu() external aw() {
        require (ab == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(bq);
    }

    // Payout ETH to winner
    function bi(address bk, uint u, uint az, bool ba, uint ao)
    internal
    {
        bk.transfer(u);
        emit Win(bk, u, az, ba, ao);
    }

    // sendRefund to requester
    function ak(uint az)
    internal
    {
        Bet storage bv = bs[az];
        address at = bv.bl;
        uint256 u = bv.bj;
        at.transfer(u);

        uint v = bv.bj * WIN_X / 1000;
        ab -= v;

        bv.bj = 0;
        emit Refund(az, u, at);
    }

    // Helper routine to process the payment.
    function av(address ay, uint bj) private returns (bool){
        bool be = ay.send(bj);
        if (be) {
            emit Payment(ay, bj);
        } else {
            emit FailedPayment(ay, bj);
        }
        return be;
    }
    // Payout ETH to whale when player loses
    function aq(address bl, uint bj, uint az, bool ba, uint ao)
    internal
    {
        emit Lose(bl, bj, az, ba, ao);
    }

    // bulk clean the storage.
    function ac(uint[] k) external {
        uint length = k.length;

        for (uint i = 0; i < length; i++) {
            i(k[i]);
        }
    }

    // Helper routine to move 'processed' bets into 'clean' state.
    function i(uint az) private {
        Bet storage bv = bs[az];

        // Do not overwrite active bets with zeros; additionally prevent cleanup of bets
        // for which ticketID signatures may have not expired yet (see whitepaper for details).
        if (bv.bj != 0 || block.number <= bv.ah + BET_EXPIRATION_BLOCKS) {
            return;
        }

        bv.ah = 0;
        bv.bd = false;
        bv.bl = address(0);
    }

    // A trap door for when someone sends tokens other than the intended ones so the overseers can decide where to send them.
    function b(address ad, address al, uint bg)
    public
    aw()
    returns (bool be)
    {
        return ERC20Interface(ad).transfer(al, bg);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address bw, uint256 bg) public returns (bool be);
}
