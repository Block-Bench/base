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
    address public _0x1681ce;
    address public _0xcc9735;
    address public _0x5ca585;
    address private _0xab5b7c;

    // Accumulated jackpot fund.
    uint256 public _0xd27f28;
    uint256 public _0x54a174;

    // Funds that are locked in potentially winning bets.
    uint256 public _0x6a1002;
    uint256 public _0x4fe8a6;

    struct Bet {
        // Wager amount in wei.
        uint _0x03b6d3;
        // Block number of placeBet tx.
        uint256 _0x0d4a20;
        // Bit mask representing winning bet outcomes (see MAX_MASK_MODULO comment).
        bool _0x14392d;
        // Address of a player, used to pay out winning bets.
        address _0x28b097;
    }

    mapping (uint => Bet) _0x6fc2ea;
    mapping (address => uint) _0x37c1e2;

    // events
    event Wager(uint _0x6ea68f, uint _0x32f7c8, uint256 _0x825179, bool _0x14392d, address _0x477b52);
    event Win(address _0x5b053a, uint _0x03b6d3, uint _0x6ea68f, bool _0x0f62a3, uint _0x1d99cb);
    event Lose(address _0x6fb66b, uint _0x03b6d3, uint _0x6ea68f, bool _0x0f62a3, uint _0x1d99cb);
    event Refund(uint _0x6ea68f, uint256 _0x03b6d3, address _0xf55888);
    event Donate(uint256 _0x03b6d3, address _0xba4c8e);
    event FailedPayment(address _0x20b9fa, uint _0x03b6d3);
    event Payment(address _0xa85b96, uint _0x03b6d3);
    event JackpotPayment(address _0x28b097, uint _0x6ea68f, uint _0x6076d1);

    // constructor
    constructor (address _0xb8c6b2, address _0x0157bc, address _0x16d197) public {
        _0x1681ce = msg.sender;
        _0xcc9735 = _0x0157bc;
        _0xab5b7c = _0xb8c6b2;
        _0x5ca585 = _0x16d197;
        _0xd27f28 = 0;
        _0x54a174 = 0;
        _0x6a1002 = 0;
        _0x4fe8a6 = 0;
    }

    // modifiers
    modifier _0x2861b2() {
        require (msg.sender == _0x1681ce, "You are not the owner of this contract!");
        _;
    }

    modifier _0x766947() {
        require (msg.sender == _0xcc9735, "You are not the bot of this contract!");
        _;
    }

    modifier _0x1ac712() {
        require (address(this).balance >= _0x6a1002 + _0xd27f28 + _0x54a174, "This contract doesn't have enough balance, it is stopped till someone donate to this game!");
        _;
    }

    // betMast:
    // false is front, true is back

    function() public payable { }

    function _0x0bdd14(address _0x0157bc)
    _0x2861b2()
    external
    {
        _0xcc9735 = _0x0157bc;
    }

    function _0x05df06(address _0x0f732e)
    _0x2861b2()
    external
    {
        _0x5ca585 = _0x0f732e;
    }

    // wager function
    function _0xf6bec4(bool _0xdd4619, uint _0x6ea68f, uint _0xe39bb0, uint8 v, bytes32 r, bytes32 s)
    _0x1ac712()
    external
    payable {
        Bet storage _0x4aa599 = _0x6fc2ea[_0x6ea68f];
        uint _0x03b6d3 = msg.value;
        address _0x28b097 = msg.sender;
        require (_0x4aa599._0x28b097 == address(0), "Ticket is not new one!");
        require (_0x03b6d3 >= MIN_BET, "Your bet is lower than minimum bet amount");
        require (_0x03b6d3 <= MAX_BET, "Your bet is higher than maximum bet amount");
        require (_0x55fe50() >= 2 * _0x03b6d3, "If we accept this, this contract will be in danger!");

        require (block.number <= _0xe39bb0, "Ticket has expired.");
        bytes32 _0x96717b = _0x0a47c8(abi._0xebf030('\x19Ethereum Signed Message:\n37', uint40(_0xe39bb0), _0x6ea68f));
        require (_0x5ca585 == _0xef3100(_0x96717b, v, r, s), "web3 vrs signature is not valid.");

        _0xd27f28 += _0x03b6d3 * JACKPOT_FEE / 1000;
        _0x54a174 += _0x03b6d3 * DEV_FEE / 1000;
        _0x6a1002 += _0x03b6d3 * WIN_X / 1000;

        uint _0x0bc80a = _0x03b6d3 * DONATING_X / 1000;
        _0xab5b7c.call.value(_0x0bc80a)(bytes4(_0x0a47c8("donate()")));
        _0x4fe8a6 += _0x0bc80a;

        _0x4aa599._0x03b6d3 = _0x03b6d3;
        _0x4aa599._0x0d4a20 = block.number;
        _0x4aa599._0x14392d = _0xdd4619;
        _0x4aa599._0x28b097 = _0x28b097;

        emit Wager(_0x6ea68f, _0x4aa599._0x03b6d3, _0x4aa599._0x0d4a20, _0x4aa599._0x14392d, _0x4aa599._0x28b097);
    }

    // method to determine winners and losers
    function _0x1b7abe(uint _0x4b75b7)
    _0x1ac712()
    external
    {
        uint _0x6ea68f = uint(_0x0a47c8(abi._0xebf030(_0x4b75b7)));
        Bet storage _0x4aa599 = _0x6fc2ea[_0x6ea68f];
        require (_0x4aa599._0x28b097 != address(0), "TicketID is not correct!");
        require (_0x4aa599._0x03b6d3 != 0, "Ticket is already used one!");
        uint256 _0x0d4a20 = _0x4aa599._0x0d4a20;
        if(_0x0d4a20 < block.number && _0x0d4a20 >= block.number - BET_EXPIRATION_BLOCKS)
        {
            uint256 _0xfa7dfe = uint256(_0x0a47c8(abi._0xebf030(blockhash(_0x0d4a20),  _0x4b75b7)));
            bool _0x0f62a3 = (_0xfa7dfe % 2) !=0;
            uint _0x1d99cb = _0xfa7dfe % JACKPOT_MODULO;

            uint _0x056721 = _0x4aa599._0x03b6d3 * WIN_X / 1000;

            uint _0x110f7b = 0;
            uint _0x6076d1 = 0;

            if(_0x4aa599._0x14392d == _0x0f62a3) {
                _0x110f7b = _0x056721;
            }
            if(_0x1d99cb == 0) {
                _0x6076d1 = _0xd27f28;
                _0xd27f28 = 0;
            }
            if (_0x6076d1 > 0) {
                emit JackpotPayment(_0x4aa599._0x28b097, _0x6ea68f, _0x6076d1);
            }
            if(_0x110f7b + _0x6076d1 > 0)
            {
                _0xb45ba9(_0x4aa599._0x28b097, _0x110f7b + _0x6076d1, _0x6ea68f, _0x0f62a3, _0x1d99cb);
            }
            else
            {
                _0x27bcbb(_0x4aa599._0x28b097, _0x4aa599._0x03b6d3, _0x6ea68f, _0x0f62a3, _0x1d99cb);
            }
            _0x6a1002 -= _0x056721;
            _0x4aa599._0x03b6d3 = 0;
        }
        else
        {
            revert();
        }
    }

    function _0x0c9840()
    external
    payable
    {
        _0x37c1e2[msg.sender] += msg.value;
        emit Donate(msg.value, msg.sender);
    }

    function _0x77a7bd(uint _0x03b6d3)
    external
    {
        require(_0x37c1e2[msg.sender] >= _0x03b6d3, "You are going to withdraw more than you donated!");

        if (_0xd303df(msg.sender, _0x03b6d3)){
            _0x37c1e2[msg.sender] -= _0x03b6d3;
        }
    }

    // method to refund
    function _0xb96cd9(uint _0x6ea68f)
    _0x1ac712()
    external {
        Bet storage _0x4aa599 = _0x6fc2ea[_0x6ea68f];

        require (_0x4aa599._0x03b6d3 != 0, "this ticket has no balance");
        require (block.number > _0x4aa599._0x0d4a20 + BET_EXPIRATION_BLOCKS, "this ticket is expired.");
        _0xfd3639(_0x6ea68f);
    }

    // Funds withdrawl
    function _0x9cfd95(address _0xfe39a9, uint _0x37c733)
    _0x2861b2()
    _0x1ac712()
    external {
        require (_0x54a174 >= _0x37c733, "You are trying to withdraw more amount than developer fee.");
        require (_0x37c733 <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (_0x54a174 <= address(this).balance, "Not enough funds to withdraw.");
        if (_0xd303df(_0xfe39a9, _0x37c733)){
            _0x54a174 -= _0x37c733;
        }
    }

    // Funds withdrawl
    function _0x6c25e3(uint _0x37c733)
    _0x766947()
    _0x1ac712()
    external {
        require (_0x54a174 >= _0x37c733, "You are trying to withdraw more amount than developer fee.");
        require (_0x37c733 <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (_0x54a174 <= address(this).balance, "Not enough funds to withdraw.");
        if (_0xd303df(_0xcc9735, _0x37c733)){
            _0x54a174 -= _0x37c733;
        }
    }

    // Get Bet Info from id
    function _0xc7b25f(uint _0x6ea68f)
    constant
    external
    returns (uint, uint256, bool, address){
        Bet storage _0x4aa599 = _0x6fc2ea[_0x6ea68f];
        return (_0x4aa599._0x03b6d3, _0x4aa599._0x0d4a20, _0x4aa599._0x14392d, _0x4aa599._0x28b097);
    }

    // Get Bet Info from id
    function _0x6ea0d9()
    constant
    external
    returns (uint){
        return address(this).balance;
    }

    // Get Collateral for Bet
    function _0x55fe50()
    constant
    public
    returns (uint){
        if (address(this).balance > _0x6a1002 + _0xd27f28 + _0x54a174)
            return address(this).balance - _0x6a1002 - _0xd27f28 - _0x54a174;
        return 0;
    }

    // Contract may be destroyed only when there are no ongoing bets,
    // either settled or refunded. All funds are transferred to contract owner.
    function _0xd7d53a() external _0x2861b2() {
        require (_0x6a1002 == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(_0x1681ce);
    }

    // Payout ETH to winner
    function _0xb45ba9(address _0x5b053a, uint _0x35b45e, uint _0x6ea68f, bool _0x0f62a3, uint _0x1d99cb)
    internal
    {
        _0x5b053a.transfer(_0x35b45e);
        emit Win(_0x5b053a, _0x35b45e, _0x6ea68f, _0x0f62a3, _0x1d99cb);
    }

    // sendRefund to requester
    function _0xfd3639(uint _0x6ea68f)
    internal
    {
        Bet storage _0x4aa599 = _0x6fc2ea[_0x6ea68f];
        address _0xf55888 = _0x4aa599._0x28b097;
        uint256 _0x35b45e = _0x4aa599._0x03b6d3;
        _0xf55888.transfer(_0x35b45e);

        uint _0x056721 = _0x4aa599._0x03b6d3 * WIN_X / 1000;
        _0x6a1002 -= _0x056721;

        _0x4aa599._0x03b6d3 = 0;
        emit Refund(_0x6ea68f, _0x35b45e, _0xf55888);
    }

    // Helper routine to process the payment.
    function _0xd303df(address _0x20b9fa, uint _0x03b6d3) private returns (bool){
        bool _0x6be670 = _0x20b9fa.send(_0x03b6d3);
        if (_0x6be670) {
            emit Payment(_0x20b9fa, _0x03b6d3);
        } else {
            emit FailedPayment(_0x20b9fa, _0x03b6d3);
        }
        return _0x6be670;
    }
    // Payout ETH to whale when player loses
    function _0x27bcbb(address _0x28b097, uint _0x03b6d3, uint _0x6ea68f, bool _0x0f62a3, uint _0x1d99cb)
    internal
    {
        emit Lose(_0x28b097, _0x03b6d3, _0x6ea68f, _0x0f62a3, _0x1d99cb);
    }

    // bulk clean the storage.
    function _0xa35d5a(uint[] _0xc4285c) external {
        uint length = _0xc4285c.length;

        for (uint i = 0; i < length; i++) {
            _0x635791(_0xc4285c[i]);
        }
    }

    // Helper routine to move 'processed' bets into 'clean' state.
    function _0x635791(uint _0x6ea68f) private {
        Bet storage _0x4aa599 = _0x6fc2ea[_0x6ea68f];

        // Do not overwrite active bets with zeros; additionally prevent cleanup of bets
        // for which ticketID signatures may have not expired yet (see whitepaper for details).
        if (_0x4aa599._0x03b6d3 != 0 || block.number <= _0x4aa599._0x0d4a20 + BET_EXPIRATION_BLOCKS) {
            return;
        }

        _0x4aa599._0x0d4a20 = 0;
        _0x4aa599._0x14392d = false;
        _0x4aa599._0x28b097 = address(0);
    }

    // A trap door for when someone sends tokens other than the intended ones so the overseers can decide where to send them.
    function _0xf54cca(address _0x418aee, address _0x615db3, uint _0x283a62)
    public
    _0x2861b2()
    returns (bool _0x6be670)
    {
        return ERC20Interface(_0x418aee).transfer(_0x615db3, _0x283a62);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address _0x2b12e9, uint256 _0x283a62) public returns (bool _0x6be670);
}
