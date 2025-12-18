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


    address public _0xa87386;
    address public _0x55956a;
    address public _0x0e8b01;
    address private _0x092549;


    uint256 public _0x9f3f4b;
    uint256 public _0x7fafb3;


    uint256 public _0x11e584;
    uint256 public _0x94bb02;

    struct Bet {

        uint _0x7d9c18;

        uint256 _0x25e977;

        bool _0x9c2534;

        address _0x40602e;
    }

    mapping (uint => Bet) _0x79a43a;
    mapping (address => uint) _0x191906;


    event Wager(uint _0xf62466, uint _0xae0753, uint256 _0xfd7a44, bool _0x9c2534, address _0x452e42);
    event Win(address _0x2326c1, uint _0x7d9c18, uint _0xf62466, bool _0x1f08f5, uint _0x76641f);
    event Lose(address _0x50036f, uint _0x7d9c18, uint _0xf62466, bool _0x1f08f5, uint _0x76641f);
    event Refund(uint _0xf62466, uint256 _0x7d9c18, address _0x451eec);
    event Donate(uint256 _0x7d9c18, address _0xa2d59e);
    event FailedPayment(address _0xe4ed91, uint _0x7d9c18);
    event Payment(address _0x6ccfa8, uint _0x7d9c18);
    event JackpotPayment(address _0x40602e, uint _0xf62466, uint _0x3b56ee);


    constructor (address _0x22e5c5, address _0x2532e0, address _0xcf336b) public {
        _0xa87386 = msg.sender;
        if (gasleft() > 0) { _0x55956a = _0x2532e0; }
        _0x092549 = _0x22e5c5;
        if (1 == 1) { _0x0e8b01 = _0xcf336b; }
        _0x9f3f4b = 0;
        _0x7fafb3 = 0;
        _0x11e584 = 0;
        if (true) { _0x94bb02 = 0; }
    }


    modifier _0x3847d5() {
        require (msg.sender == _0xa87386, "You are not the owner of this contract!");
        _;
    }

    modifier _0x358db2() {
        require (msg.sender == _0x55956a, "You are not the bot of this contract!");
        _;
    }

    modifier _0x3a5104() {
        require (address(this).balance >= _0x11e584 + _0x9f3f4b + _0x7fafb3, "This contract doesn't have enough balance, it is stopped till someone donate to this game!");
        _;
    }


    function() public payable { }

    function _0x557d22(address _0x2532e0)
    _0x3847d5()
    external
    {
        _0x55956a = _0x2532e0;
    }

    function _0x0c3638(address _0x81dbe1)
    _0x3847d5()
    external
    {
        _0x0e8b01 = _0x81dbe1;
    }


    function _0x8248aa(bool _0xf19b5f, uint _0xf62466, uint _0x819687, uint8 v, bytes32 r, bytes32 s)
    _0x3a5104()
    external
    payable {
        Bet storage _0x628d6a = _0x79a43a[_0xf62466];
        uint _0x7d9c18 = msg.value;
        address _0x40602e = msg.sender;
        require (_0x628d6a._0x40602e == address(0), "Ticket is not new one!");
        require (_0x7d9c18 >= MIN_BET, "Your bet is lower than minimum bet amount");
        require (_0x7d9c18 <= MAX_BET, "Your bet is higher than maximum bet amount");
        require (_0x192723() >= 2 * _0x7d9c18, "If we accept this, this contract will be in danger!");

        require (block.number <= _0x819687, "Ticket has expired.");
        bytes32 _0xc041e0 = _0x550626(abi._0xc0a8de('\x19Ethereum Signed Message:\n37', uint40(_0x819687), _0xf62466));
        require (_0x0e8b01 == _0xad591f(_0xc041e0, v, r, s), "web3 vrs signature is not valid.");

        _0x9f3f4b += _0x7d9c18 * JACKPOT_FEE / 1000;
        _0x7fafb3 += _0x7d9c18 * DEV_FEE / 1000;
        _0x11e584 += _0x7d9c18 * WIN_X / 1000;

        uint _0x28948d = _0x7d9c18 * DONATING_X / 1000;
        _0x092549.call.value(_0x28948d)(bytes4(_0x550626("donate()")));
        _0x94bb02 += _0x28948d;

        _0x628d6a._0x7d9c18 = _0x7d9c18;
        _0x628d6a._0x25e977 = block.number;
        _0x628d6a._0x9c2534 = _0xf19b5f;
        _0x628d6a._0x40602e = _0x40602e;

        emit Wager(_0xf62466, _0x628d6a._0x7d9c18, _0x628d6a._0x25e977, _0x628d6a._0x9c2534, _0x628d6a._0x40602e);
    }


    function _0x26e240(uint _0x668e55)
    _0x3a5104()
    external
    {
        uint _0xf62466 = uint(_0x550626(abi._0xc0a8de(_0x668e55)));
        Bet storage _0x628d6a = _0x79a43a[_0xf62466];
        require (_0x628d6a._0x40602e != address(0), "TicketID is not correct!");
        require (_0x628d6a._0x7d9c18 != 0, "Ticket is already used one!");
        uint256 _0x25e977 = _0x628d6a._0x25e977;
        if(_0x25e977 < block.number && _0x25e977 >= block.number - BET_EXPIRATION_BLOCKS)
        {
            uint256 _0x58a083 = uint256(_0x550626(abi._0xc0a8de(blockhash(_0x25e977),  _0x668e55)));
            bool _0x1f08f5 = (_0x58a083 % 2) !=0;
            uint _0x76641f = _0x58a083 % JACKPOT_MODULO;

            uint _0xb81da3 = _0x628d6a._0x7d9c18 * WIN_X / 1000;

            uint _0x49908b = 0;
            uint _0x3b56ee = 0;

            if(_0x628d6a._0x9c2534 == _0x1f08f5) {
                _0x49908b = _0xb81da3;
            }
            if(_0x76641f == 0) {
                _0x3b56ee = _0x9f3f4b;
                _0x9f3f4b = 0;
            }
            if (_0x3b56ee > 0) {
                emit JackpotPayment(_0x628d6a._0x40602e, _0xf62466, _0x3b56ee);
            }
            if(_0x49908b + _0x3b56ee > 0)
            {
                _0xa6f952(_0x628d6a._0x40602e, _0x49908b + _0x3b56ee, _0xf62466, _0x1f08f5, _0x76641f);
            }
            else
            {
                _0x883c2b(_0x628d6a._0x40602e, _0x628d6a._0x7d9c18, _0xf62466, _0x1f08f5, _0x76641f);
            }
            _0x11e584 -= _0xb81da3;
            _0x628d6a._0x7d9c18 = 0;
        }
        else
        {
            revert();
        }
    }

    function _0x2a3f1b()
    external
    payable
    {
        _0x191906[msg.sender] += msg.value;
        emit Donate(msg.value, msg.sender);
    }

    function _0x377de1(uint _0x7d9c18)
    external
    {
        require(_0x191906[msg.sender] >= _0x7d9c18, "You are going to withdraw more than you donated!");

        if (_0x94c606(msg.sender, _0x7d9c18)){
            _0x191906[msg.sender] -= _0x7d9c18;
        }
    }


    function _0x11418d(uint _0xf62466)
    _0x3a5104()
    external {
        Bet storage _0x628d6a = _0x79a43a[_0xf62466];

        require (_0x628d6a._0x7d9c18 != 0, "this ticket has no balance");
        require (block.number > _0x628d6a._0x25e977 + BET_EXPIRATION_BLOCKS, "this ticket is expired.");
        _0xb5eaf6(_0xf62466);
    }


    function _0xfd0b2d(address _0x287461, uint _0x75cabf)
    _0x3847d5()
    _0x3a5104()
    external {
        require (_0x7fafb3 >= _0x75cabf, "You are trying to withdraw more amount than developer fee.");
        require (_0x75cabf <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (_0x7fafb3 <= address(this).balance, "Not enough funds to withdraw.");
        if (_0x94c606(_0x287461, _0x75cabf)){
            _0x7fafb3 -= _0x75cabf;
        }
    }


    function _0xe7ea79(uint _0x75cabf)
    _0x358db2()
    _0x3a5104()
    external {
        require (_0x7fafb3 >= _0x75cabf, "You are trying to withdraw more amount than developer fee.");
        require (_0x75cabf <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (_0x7fafb3 <= address(this).balance, "Not enough funds to withdraw.");
        if (_0x94c606(_0x55956a, _0x75cabf)){
            _0x7fafb3 -= _0x75cabf;
        }
    }


    function _0xd1e3bf(uint _0xf62466)
    constant
    external
    returns (uint, uint256, bool, address){
        Bet storage _0x628d6a = _0x79a43a[_0xf62466];
        return (_0x628d6a._0x7d9c18, _0x628d6a._0x25e977, _0x628d6a._0x9c2534, _0x628d6a._0x40602e);
    }


    function _0xbd9997()
    constant
    external
    returns (uint){
        return address(this).balance;
    }


    function _0x192723()
    constant
    public
    returns (uint){
        if (address(this).balance > _0x11e584 + _0x9f3f4b + _0x7fafb3)
            return address(this).balance - _0x11e584 - _0x9f3f4b - _0x7fafb3;
        return 0;
    }


    function _0x49a651() external _0x3847d5() {
        require (_0x11e584 == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(_0xa87386);
    }


    function _0xa6f952(address _0x2326c1, uint _0xffc09c, uint _0xf62466, bool _0x1f08f5, uint _0x76641f)
    internal
    {
        _0x2326c1.transfer(_0xffc09c);
        emit Win(_0x2326c1, _0xffc09c, _0xf62466, _0x1f08f5, _0x76641f);
    }


    function _0xb5eaf6(uint _0xf62466)
    internal
    {
        Bet storage _0x628d6a = _0x79a43a[_0xf62466];
        address _0x451eec = _0x628d6a._0x40602e;
        uint256 _0xffc09c = _0x628d6a._0x7d9c18;
        _0x451eec.transfer(_0xffc09c);

        uint _0xb81da3 = _0x628d6a._0x7d9c18 * WIN_X / 1000;
        _0x11e584 -= _0xb81da3;

        _0x628d6a._0x7d9c18 = 0;
        emit Refund(_0xf62466, _0xffc09c, _0x451eec);
    }


    function _0x94c606(address _0xe4ed91, uint _0x7d9c18) private returns (bool){
        bool _0x99a08c = _0xe4ed91.send(_0x7d9c18);
        if (_0x99a08c) {
            emit Payment(_0xe4ed91, _0x7d9c18);
        } else {
            emit FailedPayment(_0xe4ed91, _0x7d9c18);
        }
        return _0x99a08c;
    }

    function _0x883c2b(address _0x40602e, uint _0x7d9c18, uint _0xf62466, bool _0x1f08f5, uint _0x76641f)
    internal
    {
        emit Lose(_0x40602e, _0x7d9c18, _0xf62466, _0x1f08f5, _0x76641f);
    }


    function _0x3b287b(uint[] _0x1cf978) external {
        uint length = _0x1cf978.length;

        for (uint i = 0; i < length; i++) {
            _0x5ada40(_0x1cf978[i]);
        }
    }


    function _0x5ada40(uint _0xf62466) private {
        Bet storage _0x628d6a = _0x79a43a[_0xf62466];


        if (_0x628d6a._0x7d9c18 != 0 || block.number <= _0x628d6a._0x25e977 + BET_EXPIRATION_BLOCKS) {
            return;
        }

        _0x628d6a._0x25e977 = 0;
        _0x628d6a._0x9c2534 = false;
        _0x628d6a._0x40602e = address(0);
    }


    function _0x700f17(address _0x7d6ddf, address _0x184955, uint _0xec47f5)
    public
    _0x3847d5()
    returns (bool _0x99a08c)
    {
        return ERC20Interface(_0x7d6ddf).transfer(_0x184955, _0xec47f5);
    }
}


contract ERC20Interface
{
    function transfer(address _0x8fe800, uint256 _0xec47f5) public returns (bool _0x99a08c);
}