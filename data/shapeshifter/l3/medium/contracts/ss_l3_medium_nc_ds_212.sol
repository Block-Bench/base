pragma solidity ^0.4.24;

contract PoCGame
{

    modifier _0x867c65()
    {
        require(msg.sender == _0x0d08c4);
        _;
    }

   modifier _0x385731()
    {
        require(_0xd7bd1e);
        _;
    }

    modifier _0x62f7ab()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  _0xdacc79()
    {
        require (_0x6492b9[msg.sender] > 0);
        _;
    }

    event Wager(uint256 _0x2205e2, address _0x12f9a2);
    event Win(uint256 _0x2205e2, address _0x2f8daa);
    event Lose(uint256 _0x2205e2, address _0x768118);
    event Donate(uint256 _0x2205e2, address _0x2f8daa, address _0x107fb0);
    event DifficultyChanged(uint256 _0x44edfb);
    event BetLimitChanged(uint256 _0xfefd02);

    address private _0xc70fcf;
    uint256 _0x13051e;
    uint difficulty;
    uint private _0xb4f420;
    address _0x0d08c4;
    mapping(address => uint256) _0x7d033d;
    mapping(address => uint256) _0x6492b9;
    bool _0xd7bd1e;
    uint256 _0x0499bc;

    constructor(address _0x30141d, uint256 _0xa72c13)
    _0x62f7ab()
    public
    {
        _0xd7bd1e = false;
        _0x0d08c4 = msg.sender;
        _0xc70fcf = _0x30141d;
        _0x0499bc = 0;
        _0x13051e = _0xa72c13;

    }

    function OpenToThePublic()
    _0x867c65()
    public
    {
        _0xd7bd1e = true;
    }

    function AdjustBetAmounts(uint256 _0x2205e2)
    _0x867c65()
    public
    {
        _0x13051e = _0x2205e2;

        emit BetLimitChanged(_0x13051e);
    }

    function AdjustDifficulty(uint256 _0x2205e2)
    _0x867c65()
    public
    {
        difficulty = _0x2205e2;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function _0x49aa5f()
    _0x385731()
    _0x62f7ab()
    payable
    public
    {

        require(msg.value == _0x13051e);


        require(_0x6492b9[msg.sender] == 0);


        _0x7d033d[msg.sender] = block.number;
        _0x6492b9[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function _0xfe5dcb()
    _0x385731()
    _0x62f7ab()
    _0xdacc79()
    public
    {
        uint256 _0x760d9c = _0x7d033d[msg.sender];
        if(_0x760d9c < block.number)
        {
            _0x7d033d[msg.sender] = 0;
            _0x6492b9[msg.sender] = 0;

            uint256 _0xa20ffc = uint256(_0x4e0bdf(abi._0xe416e7(blockhash(_0x760d9c),  msg.sender)))%difficulty +1;

            if(_0xa20ffc == difficulty / 2)
            {
                _0xa1a2ee(msg.sender);
            }
            else
            {

                _0x0f6979(_0x13051e / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function _0x5c6296()
    _0x385731()
    public
    payable
    {
        _0x8a437c(msg.value);
    }

    function _0xa1a2ee(address _0xe24e34)
    internal
    {
        uint256 _0xaec5b0 = address(this).balance / 2;

        _0xe24e34.transfer(_0xaec5b0);
        emit Win(_0xaec5b0, _0xe24e34);
    }

    function _0x8a437c(uint256 _0x2205e2)
    internal
    {
        _0xc70fcf.call.value(_0x2205e2)(bytes4(_0x4e0bdf("donate()")));
        _0x0499bc += _0x2205e2;
        emit Donate(_0x2205e2, _0xc70fcf, msg.sender);
    }

    function _0x0f6979(uint256 _0x2205e2)
    internal
    {
        _0xc70fcf.call.value(_0x2205e2)(bytes4(_0x4e0bdf("donate()")));
        _0x0499bc += _0x2205e2;
        emit Lose(_0x2205e2, msg.sender);
    }

    function _0xc48569()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function _0x44edfb()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function _0xfefd02()
    public
    view
    returns (uint256)
    {
        return _0x13051e;
    }

    function _0xfa9061(address _0x893ee8)
    public
    view
    returns (bool)
    {
        if(_0x6492b9[_0x893ee8] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function _0x78192b()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function _0xaf2284(address _0x74da3c, address _0xe99ead, uint _0x84b4b8)
    public
    _0x867c65()
    returns (bool _0x146ef3)
    {
        return ERC20Interface(_0x74da3c).transfer(_0xe99ead, _0x84b4b8);
    }
}


contract ERC20Interface
{
    function transfer(address _0x938eab, uint256 _0x84b4b8) public returns (bool _0x146ef3);
}