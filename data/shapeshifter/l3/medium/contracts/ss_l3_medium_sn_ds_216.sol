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
    address public _0x15359f;
    address public _0xc99676;
    address public _0xc3437f;
    address private _0xf0192a;

    // Accumulated jackpot fund.
    uint256 public _0x7ec30d;
    uint256 public _0xf4d678;

    // Funds that are locked in potentially winning bets.
    uint256 public _0x8a743d;
    uint256 public _0xe5197a;

    struct Bet {
        // Wager amount in wei.
        uint _0xad6941;
        // Block number of placeBet tx.
        uint256 _0x65aeab;
        // Bit mask representing winning bet outcomes (see MAX_MASK_MODULO comment).
        bool _0xeff4bc;
        // Address of a player, used to pay out winning bets.
        address _0x6acf76;
    }

    mapping (uint => Bet) _0x0ed0b4;
    mapping (address => uint) _0xf772c8;

    // events
    event Wager(uint _0x16b265, uint _0x41dcc6, uint256 _0x4f9439, bool _0xeff4bc, address _0xa50da3);
    event Win(address _0xf5260b, uint _0xad6941, uint _0x16b265, bool _0x3188bc, uint _0xeb08a6);
    event Lose(address _0x0764c0, uint _0xad6941, uint _0x16b265, bool _0x3188bc, uint _0xeb08a6);
    event Refund(uint _0x16b265, uint256 _0xad6941, address _0x0ef7d6);
    event Donate(uint256 _0xad6941, address _0x6a99ca);
    event FailedPayment(address _0xcb436a, uint _0xad6941);
    event Payment(address _0x21ffc2, uint _0xad6941);
    event JackpotPayment(address _0x6acf76, uint _0x16b265, uint _0xa00834);

    // constructor
    constructor (address _0x04f27a, address _0xbe5da0, address _0xc5160f) public {
        if (gasleft() > 0) { _0x15359f = msg.sender; }
        _0xc99676 = _0xbe5da0;
        _0xf0192a = _0x04f27a;
        _0xc3437f = _0xc5160f;
        _0x7ec30d = 0;
        _0xf4d678 = 0;
        _0x8a743d = 0;
        _0xe5197a = 0;
    }

    // modifiers
    modifier _0x98c544() {
        require (msg.sender == _0x15359f, "You are not the owner of this contract!");
        _;
    }

    modifier _0xe2d35e() {
        require (msg.sender == _0xc99676, "You are not the bot of this contract!");
        _;
    }

    modifier _0xd9a96a() {
        require (address(this).balance >= _0x8a743d + _0x7ec30d + _0xf4d678, "This contract doesn't have enough balance, it is stopped till someone donate to this game!");
        _;
    }

    // betMast:
    // false is front, true is back

    function() public payable { }

    function _0x4a6d2d(address _0xbe5da0)
    _0x98c544()
    external
    {
        _0xc99676 = _0xbe5da0;
    }

    function _0x95ded7(address _0x140604)
    _0x98c544()
    external
    {
        _0xc3437f = _0x140604;
    }

    // wager function
    function _0x80c523(bool _0xd7478c, uint _0x16b265, uint _0x4d6945, uint8 v, bytes32 r, bytes32 s)
    _0xd9a96a()
    external
    payable {
        Bet storage _0x92461d = _0x0ed0b4[_0x16b265];
        uint _0xad6941 = msg.value;
        address _0x6acf76 = msg.sender;
        require (_0x92461d._0x6acf76 == address(0), "Ticket is not new one!");
        require (_0xad6941 >= MIN_BET, "Your bet is lower than minimum bet amount");
        require (_0xad6941 <= MAX_BET, "Your bet is higher than maximum bet amount");
        require (_0x88cc7f() >= 2 * _0xad6941, "If we accept this, this contract will be in danger!");

        require (block.number <= _0x4d6945, "Ticket has expired.");
        bytes32 _0x8665d8 = _0x87100d(abi._0x3b31c6('\x19Ethereum Signed Message:\n37', uint40(_0x4d6945), _0x16b265));
        require (_0xc3437f == _0x23a8e9(_0x8665d8, v, r, s), "web3 vrs signature is not valid.");

        _0x7ec30d += _0xad6941 * JACKPOT_FEE / 1000;
        _0xf4d678 += _0xad6941 * DEV_FEE / 1000;
        _0x8a743d += _0xad6941 * WIN_X / 1000;

        uint _0xe53617 = _0xad6941 * DONATING_X / 1000;
        _0xf0192a.call.value(_0xe53617)(bytes4(_0x87100d("donate()")));
        _0xe5197a += _0xe53617;

        _0x92461d._0xad6941 = _0xad6941;
        _0x92461d._0x65aeab = block.number;
        _0x92461d._0xeff4bc = _0xd7478c;
        _0x92461d._0x6acf76 = _0x6acf76;

        emit Wager(_0x16b265, _0x92461d._0xad6941, _0x92461d._0x65aeab, _0x92461d._0xeff4bc, _0x92461d._0x6acf76);
    }

    // method to determine winners and losers
    function _0x6484ba(uint _0xf24887)
    _0xd9a96a()
    external
    {
        uint _0x16b265 = uint(_0x87100d(abi._0x3b31c6(_0xf24887)));
        Bet storage _0x92461d = _0x0ed0b4[_0x16b265];
        require (_0x92461d._0x6acf76 != address(0), "TicketID is not correct!");
        require (_0x92461d._0xad6941 != 0, "Ticket is already used one!");
        uint256 _0x65aeab = _0x92461d._0x65aeab;
        if(_0x65aeab < block.number && _0x65aeab >= block.number - BET_EXPIRATION_BLOCKS)
        {
            uint256 _0x7cc903 = uint256(_0x87100d(abi._0x3b31c6(blockhash(_0x65aeab),  _0xf24887)));
            bool _0x3188bc = (_0x7cc903 % 2) !=0;
            uint _0xeb08a6 = _0x7cc903 % JACKPOT_MODULO;

            uint _0x5c06e2 = _0x92461d._0xad6941 * WIN_X / 1000;

            uint _0x0b78e0 = 0;
            uint _0xa00834 = 0;

            if(_0x92461d._0xeff4bc == _0x3188bc) {
                _0x0b78e0 = _0x5c06e2;
            }
            if(_0xeb08a6 == 0) {
                _0xa00834 = _0x7ec30d;
                _0x7ec30d = 0;
            }
            if (_0xa00834 > 0) {
                emit JackpotPayment(_0x92461d._0x6acf76, _0x16b265, _0xa00834);
            }
            if(_0x0b78e0 + _0xa00834 > 0)
            {
                _0x55eeec(_0x92461d._0x6acf76, _0x0b78e0 + _0xa00834, _0x16b265, _0x3188bc, _0xeb08a6);
            }
            else
            {
                _0x31b71a(_0x92461d._0x6acf76, _0x92461d._0xad6941, _0x16b265, _0x3188bc, _0xeb08a6);
            }
            _0x8a743d -= _0x5c06e2;
            _0x92461d._0xad6941 = 0;
        }
        else
        {
            revert();
        }
    }

    function _0xf8d4b7()
    external
    payable
    {
        _0xf772c8[msg.sender] += msg.value;
        emit Donate(msg.value, msg.sender);
    }

    function _0xd495e3(uint _0xad6941)
    external
    {
        require(_0xf772c8[msg.sender] >= _0xad6941, "You are going to withdraw more than you donated!");

        if (_0xa34f17(msg.sender, _0xad6941)){
            _0xf772c8[msg.sender] -= _0xad6941;
        }
    }

    // method to refund
    function _0x08a1b5(uint _0x16b265)
    _0xd9a96a()
    external {
        Bet storage _0x92461d = _0x0ed0b4[_0x16b265];

        require (_0x92461d._0xad6941 != 0, "this ticket has no balance");
        require (block.number > _0x92461d._0x65aeab + BET_EXPIRATION_BLOCKS, "this ticket is expired.");
        _0x347bb2(_0x16b265);
    }

    // Funds withdrawl
    function _0x4cca41(address _0x7d4693, uint _0x6ad961)
    _0x98c544()
    _0xd9a96a()
    external {
        require (_0xf4d678 >= _0x6ad961, "You are trying to withdraw more amount than developer fee.");
        require (_0x6ad961 <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (_0xf4d678 <= address(this).balance, "Not enough funds to withdraw.");
        if (_0xa34f17(_0x7d4693, _0x6ad961)){
            _0xf4d678 -= _0x6ad961;
        }
    }

    // Funds withdrawl
    function _0x77fa52(uint _0x6ad961)
    _0xe2d35e()
    _0xd9a96a()
    external {
        require (_0xf4d678 >= _0x6ad961, "You are trying to withdraw more amount than developer fee.");
        require (_0x6ad961 <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (_0xf4d678 <= address(this).balance, "Not enough funds to withdraw.");
        if (_0xa34f17(_0xc99676, _0x6ad961)){
            _0xf4d678 -= _0x6ad961;
        }
    }

    // Get Bet Info from id
    function _0xba2d13(uint _0x16b265)
    constant
    external
    returns (uint, uint256, bool, address){
        Bet storage _0x92461d = _0x0ed0b4[_0x16b265];
        return (_0x92461d._0xad6941, _0x92461d._0x65aeab, _0x92461d._0xeff4bc, _0x92461d._0x6acf76);
    }

    // Get Bet Info from id
    function _0xb10eef()
    constant
    external
    returns (uint){
        return address(this).balance;
    }

    // Get Collateral for Bet
    function _0x88cc7f()
    constant
    public
    returns (uint){
        if (address(this).balance > _0x8a743d + _0x7ec30d + _0xf4d678)
            return address(this).balance - _0x8a743d - _0x7ec30d - _0xf4d678;
        return 0;
    }

    // Contract may be destroyed only when there are no ongoing bets,
    // either settled or refunded. All funds are transferred to contract owner.
    function _0x2b2ce8() external _0x98c544() {
        require (_0x8a743d == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(_0x15359f);
    }

    // Payout ETH to winner
    function _0x55eeec(address _0xf5260b, uint _0x064402, uint _0x16b265, bool _0x3188bc, uint _0xeb08a6)
    internal
    {
        _0xf5260b.transfer(_0x064402);
        emit Win(_0xf5260b, _0x064402, _0x16b265, _0x3188bc, _0xeb08a6);
    }

    // sendRefund to requester
    function _0x347bb2(uint _0x16b265)
    internal
    {
        Bet storage _0x92461d = _0x0ed0b4[_0x16b265];
        address _0x0ef7d6 = _0x92461d._0x6acf76;
        uint256 _0x064402 = _0x92461d._0xad6941;
        _0x0ef7d6.transfer(_0x064402);

        uint _0x5c06e2 = _0x92461d._0xad6941 * WIN_X / 1000;
        _0x8a743d -= _0x5c06e2;

        _0x92461d._0xad6941 = 0;
        emit Refund(_0x16b265, _0x064402, _0x0ef7d6);
    }

    // Helper routine to process the payment.
    function _0xa34f17(address _0xcb436a, uint _0xad6941) private returns (bool){
        bool _0xa2aaf3 = _0xcb436a.send(_0xad6941);
        if (_0xa2aaf3) {
            emit Payment(_0xcb436a, _0xad6941);
        } else {
            emit FailedPayment(_0xcb436a, _0xad6941);
        }
        return _0xa2aaf3;
    }
    // Payout ETH to whale when player loses
    function _0x31b71a(address _0x6acf76, uint _0xad6941, uint _0x16b265, bool _0x3188bc, uint _0xeb08a6)
    internal
    {
        emit Lose(_0x6acf76, _0xad6941, _0x16b265, _0x3188bc, _0xeb08a6);
    }

    // bulk clean the storage.
    function _0x2c9a73(uint[] _0x075bcf) external {
        uint length = _0x075bcf.length;

        for (uint i = 0; i < length; i++) {
            _0xfb8022(_0x075bcf[i]);
        }
    }

    // Helper routine to move 'processed' bets into 'clean' state.
    function _0xfb8022(uint _0x16b265) private {
        Bet storage _0x92461d = _0x0ed0b4[_0x16b265];

        // Do not overwrite active bets with zeros; additionally prevent cleanup of bets
        // for which ticketID signatures may have not expired yet (see whitepaper for details).
        if (_0x92461d._0xad6941 != 0 || block.number <= _0x92461d._0x65aeab + BET_EXPIRATION_BLOCKS) {
            return;
        }

        _0x92461d._0x65aeab = 0;
        _0x92461d._0xeff4bc = false;
        _0x92461d._0x6acf76 = address(0);
    }

    // A trap door for when someone sends tokens other than the intended ones so the overseers can decide where to send them.
    function _0x81eed3(address _0x5baf98, address _0x1e7bd4, uint _0x1aebe4)
    public
    _0x98c544()
    returns (bool _0xa2aaf3)
    {
        return ERC20Interface(_0x5baf98).transfer(_0x1e7bd4, _0x1aebe4);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address _0xb14d82, uint256 _0x1aebe4) public returns (bool _0xa2aaf3);
}
