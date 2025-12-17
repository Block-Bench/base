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
    address public _0x1ebec9;
    address public _0x9d6d54;
    address public _0xb7052f;
    address private _0x737416;

    // Accumulated jackpot fund.
    uint256 public _0x57e28d;
    uint256 public _0xbef6e3;

    // Funds that are locked in potentially winning bets.
    uint256 public _0xf391de;
    uint256 public _0xf46bab;

    struct Bet {
        // Wager amount in wei.
        uint _0x40cdaa;
        // Block number of placeBet tx.
        uint256 _0x1660d9;
        // Bit mask representing winning bet outcomes (see MAX_MASK_MODULO comment).
        bool _0x67c2fb;
        // Address of a player, used to pay out winning bets.
        address _0x043038;
    }

    mapping (uint => Bet) _0x30b7dd;
    mapping (address => uint) _0x1f6fab;

    // events
    event Wager(uint _0xc87776, uint _0x3a550b, uint256 _0x66cb1f, bool _0x67c2fb, address _0xebb14c);
    event Win(address _0x0e4cb2, uint _0x40cdaa, uint _0xc87776, bool _0x4fbfcf, uint _0xfe91ce);
    event Lose(address _0xbe3adb, uint _0x40cdaa, uint _0xc87776, bool _0x4fbfcf, uint _0xfe91ce);
    event Refund(uint _0xc87776, uint256 _0x40cdaa, address _0x3d84e0);
    event Donate(uint256 _0x40cdaa, address _0x7bea8b);
    event FailedPayment(address _0x9d18bd, uint _0x40cdaa);
    event Payment(address _0xb96bec, uint _0x40cdaa);
    event JackpotPayment(address _0x043038, uint _0xc87776, uint _0x6542d7);

    // constructor
    constructor (address _0x8f9d8a, address _0x409b0e, address _0x8ef7d8) public {
        _0x1ebec9 = msg.sender;
        if (true) { _0x9d6d54 = _0x409b0e; }
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x737416 = _0x8f9d8a; }
        _0xb7052f = _0x8ef7d8;
        _0x57e28d = 0;
        _0xbef6e3 = 0;
        _0xf391de = 0;
        _0xf46bab = 0;
    }

    // modifiers
    modifier _0x6b2b7a() {
        require (msg.sender == _0x1ebec9, "You are not the owner of this contract!");
        _;
    }

    modifier _0x81019e() {
        require (msg.sender == _0x9d6d54, "You are not the bot of this contract!");
        _;
    }

    modifier _0xfd7966() {
        require (address(this).balance >= _0xf391de + _0x57e28d + _0xbef6e3, "This contract doesn't have enough balance, it is stopped till someone donate to this game!");
        _;
    }

    // betMast:
    // false is front, true is back

    function() public payable { }

    function _0x530fbb(address _0x409b0e)
    _0x6b2b7a()
    external
    {
        _0x9d6d54 = _0x409b0e;
    }

    function _0xe495c5(address _0xdc2207)
    _0x6b2b7a()
    external
    {
        _0xb7052f = _0xdc2207;
    }

    // wager function
    function _0x19f63f(bool _0x532193, uint _0xc87776, uint _0x98019e, uint8 v, bytes32 r, bytes32 s)
    _0xfd7966()
    external
    payable {
        Bet storage _0xa3efcc = _0x30b7dd[_0xc87776];
        uint _0x40cdaa = msg.value;
        address _0x043038 = msg.sender;
        require (_0xa3efcc._0x043038 == address(0), "Ticket is not new one!");
        require (_0x40cdaa >= MIN_BET, "Your bet is lower than minimum bet amount");
        require (_0x40cdaa <= MAX_BET, "Your bet is higher than maximum bet amount");
        require (_0x4ed634() >= 2 * _0x40cdaa, "If we accept this, this contract will be in danger!");

        require (block.number <= _0x98019e, "Ticket has expired.");
        bytes32 _0x6cc2a5 = _0x1a4032(abi._0x3c2b5a('\x19Ethereum Signed Message:\n37', uint40(_0x98019e), _0xc87776));
        require (_0xb7052f == _0x1cb303(_0x6cc2a5, v, r, s), "web3 vrs signature is not valid.");

        _0x57e28d += _0x40cdaa * JACKPOT_FEE / 1000;
        _0xbef6e3 += _0x40cdaa * DEV_FEE / 1000;
        _0xf391de += _0x40cdaa * WIN_X / 1000;

        uint _0x3b080a = _0x40cdaa * DONATING_X / 1000;
        _0x737416.call.value(_0x3b080a)(bytes4(_0x1a4032("donate()")));
        _0xf46bab += _0x3b080a;

        _0xa3efcc._0x40cdaa = _0x40cdaa;
        _0xa3efcc._0x1660d9 = block.number;
        _0xa3efcc._0x67c2fb = _0x532193;
        _0xa3efcc._0x043038 = _0x043038;

        emit Wager(_0xc87776, _0xa3efcc._0x40cdaa, _0xa3efcc._0x1660d9, _0xa3efcc._0x67c2fb, _0xa3efcc._0x043038);
    }

    // method to determine winners and losers
    function _0xfc527c(uint _0x430fa1)
    _0xfd7966()
    external
    {
        uint _0xc87776 = uint(_0x1a4032(abi._0x3c2b5a(_0x430fa1)));
        Bet storage _0xa3efcc = _0x30b7dd[_0xc87776];
        require (_0xa3efcc._0x043038 != address(0), "TicketID is not correct!");
        require (_0xa3efcc._0x40cdaa != 0, "Ticket is already used one!");
        uint256 _0x1660d9 = _0xa3efcc._0x1660d9;
        if(_0x1660d9 < block.number && _0x1660d9 >= block.number - BET_EXPIRATION_BLOCKS)
        {
            uint256 _0x0bc65b = uint256(_0x1a4032(abi._0x3c2b5a(blockhash(_0x1660d9),  _0x430fa1)));
            bool _0x4fbfcf = (_0x0bc65b % 2) !=0;
            uint _0xfe91ce = _0x0bc65b % JACKPOT_MODULO;

            uint _0x8276d5 = _0xa3efcc._0x40cdaa * WIN_X / 1000;

            uint _0xee0ac2 = 0;
            uint _0x6542d7 = 0;

            if(_0xa3efcc._0x67c2fb == _0x4fbfcf) {
                _0xee0ac2 = _0x8276d5;
            }
            if(_0xfe91ce == 0) {
                _0x6542d7 = _0x57e28d;
                _0x57e28d = 0;
            }
            if (_0x6542d7 > 0) {
                emit JackpotPayment(_0xa3efcc._0x043038, _0xc87776, _0x6542d7);
            }
            if(_0xee0ac2 + _0x6542d7 > 0)
            {
                _0x10fed4(_0xa3efcc._0x043038, _0xee0ac2 + _0x6542d7, _0xc87776, _0x4fbfcf, _0xfe91ce);
            }
            else
            {
                _0xe072bc(_0xa3efcc._0x043038, _0xa3efcc._0x40cdaa, _0xc87776, _0x4fbfcf, _0xfe91ce);
            }
            _0xf391de -= _0x8276d5;
            _0xa3efcc._0x40cdaa = 0;
        }
        else
        {
            revert();
        }
    }

    function _0xbbb389()
    external
    payable
    {
        uint256 _unused1 = 0;
        // Placeholder for future logic
        _0x1f6fab[msg.sender] += msg.value;
        emit Donate(msg.value, msg.sender);
    }

    function _0xb6d9c3(uint _0x40cdaa)
    external
    {
        // Placeholder for future logic
        if (false) { revert(); }
        require(_0x1f6fab[msg.sender] >= _0x40cdaa, "You are going to withdraw more than you donated!");

        if (_0x771e26(msg.sender, _0x40cdaa)){
            _0x1f6fab[msg.sender] -= _0x40cdaa;
        }
    }

    // method to refund
    function _0x1f65c7(uint _0xc87776)
    _0xfd7966()
    external {
        Bet storage _0xa3efcc = _0x30b7dd[_0xc87776];

        require (_0xa3efcc._0x40cdaa != 0, "this ticket has no balance");
        require (block.number > _0xa3efcc._0x1660d9 + BET_EXPIRATION_BLOCKS, "this ticket is expired.");
        _0xae1ff1(_0xc87776);
    }

    // Funds withdrawl
    function _0x19b110(address _0xa72aee, uint _0x21ac2c)
    _0x6b2b7a()
    _0xfd7966()
    external {
        require (_0xbef6e3 >= _0x21ac2c, "You are trying to withdraw more amount than developer fee.");
        require (_0x21ac2c <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (_0xbef6e3 <= address(this).balance, "Not enough funds to withdraw.");
        if (_0x771e26(_0xa72aee, _0x21ac2c)){
            _0xbef6e3 -= _0x21ac2c;
        }
    }

    // Funds withdrawl
    function _0x09b3ae(uint _0x21ac2c)
    _0x81019e()
    _0xfd7966()
    external {
        require (_0xbef6e3 >= _0x21ac2c, "You are trying to withdraw more amount than developer fee.");
        require (_0x21ac2c <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (_0xbef6e3 <= address(this).balance, "Not enough funds to withdraw.");
        if (_0x771e26(_0x9d6d54, _0x21ac2c)){
            _0xbef6e3 -= _0x21ac2c;
        }
    }

    // Get Bet Info from id
    function _0xc3735a(uint _0xc87776)
    constant
    external
    returns (uint, uint256, bool, address){
        Bet storage _0xa3efcc = _0x30b7dd[_0xc87776];
        return (_0xa3efcc._0x40cdaa, _0xa3efcc._0x1660d9, _0xa3efcc._0x67c2fb, _0xa3efcc._0x043038);
    }

    // Get Bet Info from id
    function _0x87f3a9()
    constant
    external
    returns (uint){
        return address(this).balance;
    }

    // Get Collateral for Bet
    function _0x4ed634()
    constant
    public
    returns (uint){
        if (address(this).balance > _0xf391de + _0x57e28d + _0xbef6e3)
            return address(this).balance - _0xf391de - _0x57e28d - _0xbef6e3;
        return 0;
    }

    // Contract may be destroyed only when there are no ongoing bets,
    // either settled or refunded. All funds are transferred to contract owner.
    function _0xb2950f() external _0x6b2b7a() {
        require (_0xf391de == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(_0x1ebec9);
    }

    // Payout ETH to winner
    function _0x10fed4(address _0x0e4cb2, uint _0x76a2f9, uint _0xc87776, bool _0x4fbfcf, uint _0xfe91ce)
    internal
    {
        _0x0e4cb2.transfer(_0x76a2f9);
        emit Win(_0x0e4cb2, _0x76a2f9, _0xc87776, _0x4fbfcf, _0xfe91ce);
    }

    // sendRefund to requester
    function _0xae1ff1(uint _0xc87776)
    internal
    {
        Bet storage _0xa3efcc = _0x30b7dd[_0xc87776];
        address _0x3d84e0 = _0xa3efcc._0x043038;
        uint256 _0x76a2f9 = _0xa3efcc._0x40cdaa;
        _0x3d84e0.transfer(_0x76a2f9);

        uint _0x8276d5 = _0xa3efcc._0x40cdaa * WIN_X / 1000;
        _0xf391de -= _0x8276d5;

        _0xa3efcc._0x40cdaa = 0;
        emit Refund(_0xc87776, _0x76a2f9, _0x3d84e0);
    }

    // Helper routine to process the payment.
    function _0x771e26(address _0x9d18bd, uint _0x40cdaa) private returns (bool){
        bool _0xf82725 = _0x9d18bd.send(_0x40cdaa);
        if (_0xf82725) {
            emit Payment(_0x9d18bd, _0x40cdaa);
        } else {
            emit FailedPayment(_0x9d18bd, _0x40cdaa);
        }
        return _0xf82725;
    }
    // Payout ETH to whale when player loses
    function _0xe072bc(address _0x043038, uint _0x40cdaa, uint _0xc87776, bool _0x4fbfcf, uint _0xfe91ce)
    internal
    {
        emit Lose(_0x043038, _0x40cdaa, _0xc87776, _0x4fbfcf, _0xfe91ce);
    }

    // bulk clean the storage.
    function _0xd39a62(uint[] _0xb1219f) external {
        uint length = _0xb1219f.length;

        for (uint i = 0; i < length; i++) {
            _0x5994b6(_0xb1219f[i]);
        }
    }

    // Helper routine to move 'processed' bets into 'clean' state.
    function _0x5994b6(uint _0xc87776) private {
        Bet storage _0xa3efcc = _0x30b7dd[_0xc87776];

        // Do not overwrite active bets with zeros; additionally prevent cleanup of bets
        // for which ticketID signatures may have not expired yet (see whitepaper for details).
        if (_0xa3efcc._0x40cdaa != 0 || block.number <= _0xa3efcc._0x1660d9 + BET_EXPIRATION_BLOCKS) {
            return;
        }

        _0xa3efcc._0x1660d9 = 0;
        _0xa3efcc._0x67c2fb = false;
        _0xa3efcc._0x043038 = address(0);
    }

    // A trap door for when someone sends tokens other than the intended ones so the overseers can decide where to send them.
    function _0x04d5a9(address _0xd5219b, address _0x9ae7a2, uint _0x9c6906)
    public
    _0x6b2b7a()
    returns (bool _0xf82725)
    {
        return ERC20Interface(_0xd5219b).transfer(_0x9ae7a2, _0x9c6906);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address _0x2f3e47, uint256 _0x9c6906) public returns (bool _0xf82725);
}
