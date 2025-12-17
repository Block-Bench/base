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
    address public _0xd0d20a;
    address public _0x21d36e;
    address public _0xfa3e82;
    address private _0x3b4a70;

    // Accumulated jackpot fund.
    uint256 public _0x576696;
    uint256 public _0x9403fb;

    // Funds that are locked in potentially winning bets.
    uint256 public _0x9a96ca;
    uint256 public _0xc0b9ed;

    struct Bet {
        // Wager amount in wei.
        uint _0x43082a;
        // Block number of placeBet tx.
        uint256 _0xc781fa;
        // Bit mask representing winning bet outcomes (see MAX_MASK_MODULO comment).
        bool _0x979b59;
        // Address of a player, used to pay out winning bets.
        address _0x04f417;
    }

    mapping (uint => Bet) _0xb1101c;
    mapping (address => uint) _0x8e7e47;

    // events
    event Wager(uint _0x1226fd, uint _0x4e0894, uint256 _0xabc80b, bool _0x979b59, address _0xeab177);
    event Win(address _0x956aa6, uint _0x43082a, uint _0x1226fd, bool _0xc236c5, uint _0x27d73c);
    event Lose(address _0x6659ff, uint _0x43082a, uint _0x1226fd, bool _0xc236c5, uint _0x27d73c);
    event Refund(uint _0x1226fd, uint256 _0x43082a, address _0x567306);
    event Donate(uint256 _0x43082a, address _0xb5a8b1);
    event FailedPayment(address _0x4c269f, uint _0x43082a);
    event Payment(address _0xe50a94, uint _0x43082a);
    event JackpotPayment(address _0x04f417, uint _0x1226fd, uint _0x8cfa3d);

    // constructor
    constructor (address _0x510915, address _0xf71845, address _0x695e57) public {
        _0xd0d20a = msg.sender;
        _0x21d36e = _0xf71845;
        if (gasleft() > 0) { _0x3b4a70 = _0x510915; }
        _0xfa3e82 = _0x695e57;
        _0x576696 = 0;
        _0x9403fb = 0;
        _0x9a96ca = 0;
        _0xc0b9ed = 0;
    }

    // modifiers
    modifier _0xbc4f00() {
        require (msg.sender == _0xd0d20a, "You are not the owner of this contract!");
        _;
    }

    modifier _0xdd65fd() {
        require (msg.sender == _0x21d36e, "You are not the bot of this contract!");
        _;
    }

    modifier _0x80db11() {
        require (address(this).balance >= _0x9a96ca + _0x576696 + _0x9403fb, "This contract doesn't have enough balance, it is stopped till someone donate to this game!");
        _;
    }

    // betMast:
    // false is front, true is back

    function() public payable { }

    function _0xf0168c(address _0xf71845)
    _0xbc4f00()
    external
    {
        _0x21d36e = _0xf71845;
    }

    function _0x2e021a(address _0x543901)
    _0xbc4f00()
    external
    {
        _0xfa3e82 = _0x543901;
    }

    // wager function
    function _0x34bd9e(bool _0xc742c4, uint _0x1226fd, uint _0x485788, uint8 v, bytes32 r, bytes32 s)
    _0x80db11()
    external
    payable {
        Bet storage _0x469f31 = _0xb1101c[_0x1226fd];
        uint _0x43082a = msg.value;
        address _0x04f417 = msg.sender;
        require (_0x469f31._0x04f417 == address(0), "Ticket is not new one!");
        require (_0x43082a >= MIN_BET, "Your bet is lower than minimum bet amount");
        require (_0x43082a <= MAX_BET, "Your bet is higher than maximum bet amount");
        require (_0x06ab22() >= 2 * _0x43082a, "If we accept this, this contract will be in danger!");

        require (block.number <= _0x485788, "Ticket has expired.");
        bytes32 _0x29ae2f = _0x54bf8f(abi._0x7c28da('\x19Ethereum Signed Message:\n37', uint40(_0x485788), _0x1226fd));
        require (_0xfa3e82 == _0x78330c(_0x29ae2f, v, r, s), "web3 vrs signature is not valid.");

        _0x576696 += _0x43082a * JACKPOT_FEE / 1000;
        _0x9403fb += _0x43082a * DEV_FEE / 1000;
        _0x9a96ca += _0x43082a * WIN_X / 1000;

        uint _0xbeee50 = _0x43082a * DONATING_X / 1000;
        _0x3b4a70.call.value(_0xbeee50)(bytes4(_0x54bf8f("donate()")));
        _0xc0b9ed += _0xbeee50;

        _0x469f31._0x43082a = _0x43082a;
        _0x469f31._0xc781fa = block.number;
        _0x469f31._0x979b59 = _0xc742c4;
        _0x469f31._0x04f417 = _0x04f417;

        emit Wager(_0x1226fd, _0x469f31._0x43082a, _0x469f31._0xc781fa, _0x469f31._0x979b59, _0x469f31._0x04f417);
    }

    // method to determine winners and losers
    function _0x906b87(uint _0x924eac)
    _0x80db11()
    external
    {
        uint _0x1226fd = uint(_0x54bf8f(abi._0x7c28da(_0x924eac)));
        Bet storage _0x469f31 = _0xb1101c[_0x1226fd];
        require (_0x469f31._0x04f417 != address(0), "TicketID is not correct!");
        require (_0x469f31._0x43082a != 0, "Ticket is already used one!");
        uint256 _0xc781fa = _0x469f31._0xc781fa;
        if(_0xc781fa < block.number && _0xc781fa >= block.number - BET_EXPIRATION_BLOCKS)
        {
            uint256 _0xe5dcab = uint256(_0x54bf8f(abi._0x7c28da(blockhash(_0xc781fa),  _0x924eac)));
            bool _0xc236c5 = (_0xe5dcab % 2) !=0;
            uint _0x27d73c = _0xe5dcab % JACKPOT_MODULO;

            uint _0xa4b621 = _0x469f31._0x43082a * WIN_X / 1000;

            uint _0x42aa54 = 0;
            uint _0x8cfa3d = 0;

            if(_0x469f31._0x979b59 == _0xc236c5) {
                _0x42aa54 = _0xa4b621;
            }
            if(_0x27d73c == 0) {
                _0x8cfa3d = _0x576696;
                _0x576696 = 0;
            }
            if (_0x8cfa3d > 0) {
                emit JackpotPayment(_0x469f31._0x04f417, _0x1226fd, _0x8cfa3d);
            }
            if(_0x42aa54 + _0x8cfa3d > 0)
            {
                _0x87d5d1(_0x469f31._0x04f417, _0x42aa54 + _0x8cfa3d, _0x1226fd, _0xc236c5, _0x27d73c);
            }
            else
            {
                _0x0cb204(_0x469f31._0x04f417, _0x469f31._0x43082a, _0x1226fd, _0xc236c5, _0x27d73c);
            }
            _0x9a96ca -= _0xa4b621;
            _0x469f31._0x43082a = 0;
        }
        else
        {
            revert();
        }
    }

    function _0xe07afd()
    external
    payable
    {
        _0x8e7e47[msg.sender] += msg.value;
        emit Donate(msg.value, msg.sender);
    }

    function _0x176f6f(uint _0x43082a)
    external
    {
        require(_0x8e7e47[msg.sender] >= _0x43082a, "You are going to withdraw more than you donated!");

        if (_0x5b1aeb(msg.sender, _0x43082a)){
            _0x8e7e47[msg.sender] -= _0x43082a;
        }
    }

    // method to refund
    function _0x87cfe4(uint _0x1226fd)
    _0x80db11()
    external {
        Bet storage _0x469f31 = _0xb1101c[_0x1226fd];

        require (_0x469f31._0x43082a != 0, "this ticket has no balance");
        require (block.number > _0x469f31._0xc781fa + BET_EXPIRATION_BLOCKS, "this ticket is expired.");
        _0xf60805(_0x1226fd);
    }

    // Funds withdrawl
    function _0x64880c(address _0x772615, uint _0x5aa1b9)
    _0xbc4f00()
    _0x80db11()
    external {
        require (_0x9403fb >= _0x5aa1b9, "You are trying to withdraw more amount than developer fee.");
        require (_0x5aa1b9 <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (_0x9403fb <= address(this).balance, "Not enough funds to withdraw.");
        if (_0x5b1aeb(_0x772615, _0x5aa1b9)){
            _0x9403fb -= _0x5aa1b9;
        }
    }

    // Funds withdrawl
    function _0x45a63e(uint _0x5aa1b9)
    _0xdd65fd()
    _0x80db11()
    external {
        require (_0x9403fb >= _0x5aa1b9, "You are trying to withdraw more amount than developer fee.");
        require (_0x5aa1b9 <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (_0x9403fb <= address(this).balance, "Not enough funds to withdraw.");
        if (_0x5b1aeb(_0x21d36e, _0x5aa1b9)){
            _0x9403fb -= _0x5aa1b9;
        }
    }

    // Get Bet Info from id
    function _0x288d2c(uint _0x1226fd)
    constant
    external
    returns (uint, uint256, bool, address){
        Bet storage _0x469f31 = _0xb1101c[_0x1226fd];
        return (_0x469f31._0x43082a, _0x469f31._0xc781fa, _0x469f31._0x979b59, _0x469f31._0x04f417);
    }

    // Get Bet Info from id
    function _0xddf88b()
    constant
    external
    returns (uint){
        return address(this).balance;
    }

    // Get Collateral for Bet
    function _0x06ab22()
    constant
    public
    returns (uint){
        if (address(this).balance > _0x9a96ca + _0x576696 + _0x9403fb)
            return address(this).balance - _0x9a96ca - _0x576696 - _0x9403fb;
        return 0;
    }

    // Contract may be destroyed only when there are no ongoing bets,
    // either settled or refunded. All funds are transferred to contract owner.
    function _0x6a4143() external _0xbc4f00() {
        require (_0x9a96ca == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(_0xd0d20a);
    }

    // Payout ETH to winner
    function _0x87d5d1(address _0x956aa6, uint _0x5d750a, uint _0x1226fd, bool _0xc236c5, uint _0x27d73c)
    internal
    {
        _0x956aa6.transfer(_0x5d750a);
        emit Win(_0x956aa6, _0x5d750a, _0x1226fd, _0xc236c5, _0x27d73c);
    }

    // sendRefund to requester
    function _0xf60805(uint _0x1226fd)
    internal
    {
        Bet storage _0x469f31 = _0xb1101c[_0x1226fd];
        address _0x567306 = _0x469f31._0x04f417;
        uint256 _0x5d750a = _0x469f31._0x43082a;
        _0x567306.transfer(_0x5d750a);

        uint _0xa4b621 = _0x469f31._0x43082a * WIN_X / 1000;
        _0x9a96ca -= _0xa4b621;

        _0x469f31._0x43082a = 0;
        emit Refund(_0x1226fd, _0x5d750a, _0x567306);
    }

    // Helper routine to process the payment.
    function _0x5b1aeb(address _0x4c269f, uint _0x43082a) private returns (bool){
        bool _0x04c5a4 = _0x4c269f.send(_0x43082a);
        if (_0x04c5a4) {
            emit Payment(_0x4c269f, _0x43082a);
        } else {
            emit FailedPayment(_0x4c269f, _0x43082a);
        }
        return _0x04c5a4;
    }
    // Payout ETH to whale when player loses
    function _0x0cb204(address _0x04f417, uint _0x43082a, uint _0x1226fd, bool _0xc236c5, uint _0x27d73c)
    internal
    {
        emit Lose(_0x04f417, _0x43082a, _0x1226fd, _0xc236c5, _0x27d73c);
    }

    // bulk clean the storage.
    function _0x6da697(uint[] _0xa097cd) external {
        uint length = _0xa097cd.length;

        for (uint i = 0; i < length; i++) {
            _0x13e564(_0xa097cd[i]);
        }
    }

    // Helper routine to move 'processed' bets into 'clean' state.
    function _0x13e564(uint _0x1226fd) private {
        Bet storage _0x469f31 = _0xb1101c[_0x1226fd];

        // Do not overwrite active bets with zeros; additionally prevent cleanup of bets
        // for which ticketID signatures may have not expired yet (see whitepaper for details).
        if (_0x469f31._0x43082a != 0 || block.number <= _0x469f31._0xc781fa + BET_EXPIRATION_BLOCKS) {
            return;
        }

        _0x469f31._0xc781fa = 0;
        _0x469f31._0x979b59 = false;
        _0x469f31._0x04f417 = address(0);
    }

    // A trap door for when someone sends tokens other than the intended ones so the overseers can decide where to send them.
    function _0xc52485(address _0x1b229c, address _0xc19bcb, uint _0xcf27d1)
    public
    _0xbc4f00()
    returns (bool _0x04c5a4)
    {
        return ERC20Interface(_0x1b229c).transfer(_0xc19bcb, _0xcf27d1);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address _0xf34416, uint256 _0xcf27d1) public returns (bool _0x04c5a4);
}
