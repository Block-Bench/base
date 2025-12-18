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


    address public _0xbeee44;
    address public _0x2093c1;
    address public _0xdb6602;
    address private _0x567522;


    uint256 public _0xf13af5;
    uint256 public _0xa3c0d1;


    uint256 public _0x5af5ba;
    uint256 public _0x7b1c5e;

    struct Bet {

        uint _0xc7c396;

        uint256 _0x927696;

        bool _0x48aed0;

        address _0x52c868;
    }

    mapping (uint => Bet) _0xf17c50;
    mapping (address => uint) _0x5082be;


    event Wager(uint _0x62511e, uint _0x41e0d8, uint256 _0x508a10, bool _0x48aed0, address _0x347bd6);
    event Win(address _0xad3363, uint _0xc7c396, uint _0x62511e, bool _0x9cc6bf, uint _0x089789);
    event Lose(address _0x10ac63, uint _0xc7c396, uint _0x62511e, bool _0x9cc6bf, uint _0x089789);
    event Refund(uint _0x62511e, uint256 _0xc7c396, address _0x644039);
    event Donate(uint256 _0xc7c396, address _0x63d4ac);
    event FailedPayment(address _0x8745e2, uint _0xc7c396);
    event Payment(address _0x488a08, uint _0xc7c396);
    event JackpotPayment(address _0x52c868, uint _0x62511e, uint _0xd22c72);


    constructor (address _0xa25a0a, address _0xac6af5, address _0xd63eaf) public {
        _0xbeee44 = msg.sender;
        _0x2093c1 = _0xac6af5;
        _0x567522 = _0xa25a0a;
        _0xdb6602 = _0xd63eaf;
        _0xf13af5 = 0;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xa3c0d1 = 0; }
        _0x5af5ba = 0;
        _0x7b1c5e = 0;
    }


    modifier _0xe26140() {
        require (msg.sender == _0xbeee44, "You are not the owner of this contract!");
        _;
    }

    modifier _0x8f5f83() {
        require (msg.sender == _0x2093c1, "You are not the bot of this contract!");
        _;
    }

    modifier _0x584732() {
        require (address(this).balance >= _0x5af5ba + _0xf13af5 + _0xa3c0d1, "This contract doesn't have enough balance, it is stopped till someone donate to this game!");
        _;
    }


    function() public payable { }

    function _0x52178c(address _0xac6af5)
    _0xe26140()
    external
    {
        _0x2093c1 = _0xac6af5;
    }

    function _0xdfb692(address _0xaf50b3)
    _0xe26140()
    external
    {
        _0xdb6602 = _0xaf50b3;
    }


    function _0xfa6ea3(bool _0x4ea8fb, uint _0x62511e, uint _0xcf5831, uint8 v, bytes32 r, bytes32 s)
    _0x584732()
    external
    payable {
        Bet storage _0x5384a2 = _0xf17c50[_0x62511e];
        uint _0xc7c396 = msg.value;
        address _0x52c868 = msg.sender;
        require (_0x5384a2._0x52c868 == address(0), "Ticket is not new one!");
        require (_0xc7c396 >= MIN_BET, "Your bet is lower than minimum bet amount");
        require (_0xc7c396 <= MAX_BET, "Your bet is higher than maximum bet amount");
        require (_0x6cd531() >= 2 * _0xc7c396, "If we accept this, this contract will be in danger!");

        require (block.number <= _0xcf5831, "Ticket has expired.");
        bytes32 _0x481f97 = _0x94454e(abi._0x617fd2('\x19Ethereum Signed Message:\n37', uint40(_0xcf5831), _0x62511e));
        require (_0xdb6602 == _0x275af6(_0x481f97, v, r, s), "web3 vrs signature is not valid.");

        _0xf13af5 += _0xc7c396 * JACKPOT_FEE / 1000;
        _0xa3c0d1 += _0xc7c396 * DEV_FEE / 1000;
        _0x5af5ba += _0xc7c396 * WIN_X / 1000;

        uint _0x34c4dd = _0xc7c396 * DONATING_X / 1000;
        _0x567522.call.value(_0x34c4dd)(bytes4(_0x94454e("donate()")));
        _0x7b1c5e += _0x34c4dd;

        _0x5384a2._0xc7c396 = _0xc7c396;
        _0x5384a2._0x927696 = block.number;
        _0x5384a2._0x48aed0 = _0x4ea8fb;
        _0x5384a2._0x52c868 = _0x52c868;

        emit Wager(_0x62511e, _0x5384a2._0xc7c396, _0x5384a2._0x927696, _0x5384a2._0x48aed0, _0x5384a2._0x52c868);
    }


    function _0xf3981e(uint _0x4ec721)
    _0x584732()
    external
    {
        uint _0x62511e = uint(_0x94454e(abi._0x617fd2(_0x4ec721)));
        Bet storage _0x5384a2 = _0xf17c50[_0x62511e];
        require (_0x5384a2._0x52c868 != address(0), "TicketID is not correct!");
        require (_0x5384a2._0xc7c396 != 0, "Ticket is already used one!");
        uint256 _0x927696 = _0x5384a2._0x927696;
        if(_0x927696 < block.number && _0x927696 >= block.number - BET_EXPIRATION_BLOCKS)
        {
            uint256 _0x7cdad8 = uint256(_0x94454e(abi._0x617fd2(blockhash(_0x927696),  _0x4ec721)));
            bool _0x9cc6bf = (_0x7cdad8 % 2) !=0;
            uint _0x089789 = _0x7cdad8 % JACKPOT_MODULO;

            uint _0x206f8c = _0x5384a2._0xc7c396 * WIN_X / 1000;

            uint _0xed39b8 = 0;
            uint _0xd22c72 = 0;

            if(_0x5384a2._0x48aed0 == _0x9cc6bf) {
                _0xed39b8 = _0x206f8c;
            }
            if(_0x089789 == 0) {
                _0xd22c72 = _0xf13af5;
                _0xf13af5 = 0;
            }
            if (_0xd22c72 > 0) {
                emit JackpotPayment(_0x5384a2._0x52c868, _0x62511e, _0xd22c72);
            }
            if(_0xed39b8 + _0xd22c72 > 0)
            {
                _0xf6a2ab(_0x5384a2._0x52c868, _0xed39b8 + _0xd22c72, _0x62511e, _0x9cc6bf, _0x089789);
            }
            else
            {
                _0x8cc32d(_0x5384a2._0x52c868, _0x5384a2._0xc7c396, _0x62511e, _0x9cc6bf, _0x089789);
            }
            _0x5af5ba -= _0x206f8c;
            _0x5384a2._0xc7c396 = 0;
        }
        else
        {
            revert();
        }
    }

    function _0xabb833()
    external
    payable
    {
        _0x5082be[msg.sender] += msg.value;
        emit Donate(msg.value, msg.sender);
    }

    function _0x13da2a(uint _0xc7c396)
    external
    {
        require(_0x5082be[msg.sender] >= _0xc7c396, "You are going to withdraw more than you donated!");

        if (_0xa70ec1(msg.sender, _0xc7c396)){
            _0x5082be[msg.sender] -= _0xc7c396;
        }
    }


    function _0x8829a5(uint _0x62511e)
    _0x584732()
    external {
        Bet storage _0x5384a2 = _0xf17c50[_0x62511e];

        require (_0x5384a2._0xc7c396 != 0, "this ticket has no balance");
        require (block.number > _0x5384a2._0x927696 + BET_EXPIRATION_BLOCKS, "this ticket is expired.");
        _0x0690e1(_0x62511e);
    }


    function _0xb5a307(address _0x4954b9, uint _0xc6c28d)
    _0xe26140()
    _0x584732()
    external {
        require (_0xa3c0d1 >= _0xc6c28d, "You are trying to withdraw more amount than developer fee.");
        require (_0xc6c28d <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (_0xa3c0d1 <= address(this).balance, "Not enough funds to withdraw.");
        if (_0xa70ec1(_0x4954b9, _0xc6c28d)){
            _0xa3c0d1 -= _0xc6c28d;
        }
    }


    function _0x21143d(uint _0xc6c28d)
    _0x8f5f83()
    _0x584732()
    external {
        require (_0xa3c0d1 >= _0xc6c28d, "You are trying to withdraw more amount than developer fee.");
        require (_0xc6c28d <= address(this).balance, "Contract balance is lower than withdrawAmount");
        require (_0xa3c0d1 <= address(this).balance, "Not enough funds to withdraw.");
        if (_0xa70ec1(_0x2093c1, _0xc6c28d)){
            _0xa3c0d1 -= _0xc6c28d;
        }
    }


    function _0x441f03(uint _0x62511e)
    constant
    external
    returns (uint, uint256, bool, address){
        Bet storage _0x5384a2 = _0xf17c50[_0x62511e];
        return (_0x5384a2._0xc7c396, _0x5384a2._0x927696, _0x5384a2._0x48aed0, _0x5384a2._0x52c868);
    }


    function _0xaa090c()
    constant
    external
    returns (uint){
        return address(this).balance;
    }


    function _0x6cd531()
    constant
    public
    returns (uint){
        if (address(this).balance > _0x5af5ba + _0xf13af5 + _0xa3c0d1)
            return address(this).balance - _0x5af5ba - _0xf13af5 - _0xa3c0d1;
        return 0;
    }


    function _0x53e4ea() external _0xe26140() {
        require (_0x5af5ba == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(_0xbeee44);
    }


    function _0xf6a2ab(address _0xad3363, uint _0x9d5661, uint _0x62511e, bool _0x9cc6bf, uint _0x089789)
    internal
    {
        _0xad3363.transfer(_0x9d5661);
        emit Win(_0xad3363, _0x9d5661, _0x62511e, _0x9cc6bf, _0x089789);
    }


    function _0x0690e1(uint _0x62511e)
    internal
    {
        Bet storage _0x5384a2 = _0xf17c50[_0x62511e];
        address _0x644039 = _0x5384a2._0x52c868;
        uint256 _0x9d5661 = _0x5384a2._0xc7c396;
        _0x644039.transfer(_0x9d5661);

        uint _0x206f8c = _0x5384a2._0xc7c396 * WIN_X / 1000;
        _0x5af5ba -= _0x206f8c;

        _0x5384a2._0xc7c396 = 0;
        emit Refund(_0x62511e, _0x9d5661, _0x644039);
    }


    function _0xa70ec1(address _0x8745e2, uint _0xc7c396) private returns (bool){
        bool _0xe4870f = _0x8745e2.send(_0xc7c396);
        if (_0xe4870f) {
            emit Payment(_0x8745e2, _0xc7c396);
        } else {
            emit FailedPayment(_0x8745e2, _0xc7c396);
        }
        return _0xe4870f;
    }

    function _0x8cc32d(address _0x52c868, uint _0xc7c396, uint _0x62511e, bool _0x9cc6bf, uint _0x089789)
    internal
    {
        emit Lose(_0x52c868, _0xc7c396, _0x62511e, _0x9cc6bf, _0x089789);
    }


    function _0x9f97ba(uint[] _0x0f11fc) external {
        uint length = _0x0f11fc.length;

        for (uint i = 0; i < length; i++) {
            _0x909780(_0x0f11fc[i]);
        }
    }


    function _0x909780(uint _0x62511e) private {
        Bet storage _0x5384a2 = _0xf17c50[_0x62511e];


        if (_0x5384a2._0xc7c396 != 0 || block.number <= _0x5384a2._0x927696 + BET_EXPIRATION_BLOCKS) {
            return;
        }

        _0x5384a2._0x927696 = 0;
        _0x5384a2._0x48aed0 = false;
        _0x5384a2._0x52c868 = address(0);
    }


    function _0x261c83(address _0x2d895a, address _0x483042, uint _0x4ced5f)
    public
    _0xe26140()
    returns (bool _0xe4870f)
    {
        return ERC20Interface(_0x2d895a).transfer(_0x483042, _0x4ced5f);
    }
}


contract ERC20Interface
{
    function transfer(address _0x566e0b, uint256 _0x4ced5f) public returns (bool _0xe4870f);
}