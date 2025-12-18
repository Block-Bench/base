pragma solidity ^0.4.24;

contract PoCGame
{

    modifier _0x5929f4()
    {
        require(msg.sender == _0x52c25b);
        _;
    }

   modifier _0x1369c1()
    {
        require(_0xdb408c);
        _;
    }

    modifier _0x762d77()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  _0x8869d3()
    {
        require (_0xf3c089[msg.sender] > 0);
        _;
    }

    event Wager(uint256 _0xcff57d, address _0x0d7340);
    event Win(uint256 _0xcff57d, address _0x7bb2d4);
    event Lose(uint256 _0xcff57d, address _0xaecf08);
    event Donate(uint256 _0xcff57d, address _0x7bb2d4, address _0xafe086);
    event DifficultyChanged(uint256 _0x62ffff);
    event BetLimitChanged(uint256 _0xd49182);

    address private _0x47f5fa;
    uint256 _0x129ca7;
    uint difficulty;
    uint private _0x465697;
    address _0x52c25b;
    mapping(address => uint256) _0x6005cf;
    mapping(address => uint256) _0xf3c089;
    bool _0xdb408c;
    uint256 _0xb1b8cf;

    constructor(address _0x16b14c, uint256 _0xdb7b6f)
    _0x762d77()
    public
    {
        _0xdb408c = false;
        _0x52c25b = msg.sender;
        _0x47f5fa = _0x16b14c;
        _0xb1b8cf = 0;
        _0x129ca7 = _0xdb7b6f;

    }

    function OpenToThePublic()
    _0x5929f4()
    public
    {
        _0xdb408c = true;
    }

    function AdjustBetAmounts(uint256 _0xcff57d)
    _0x5929f4()
    public
    {
        _0x129ca7 = _0xcff57d;

        emit BetLimitChanged(_0x129ca7);
    }

    function AdjustDifficulty(uint256 _0xcff57d)
    _0x5929f4()
    public
    {
        difficulty = _0xcff57d;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function _0xadb55c()
    _0x1369c1()
    _0x762d77()
    payable
    public
    {

        require(msg.value == _0x129ca7);


        require(_0xf3c089[msg.sender] == 0);


        _0x6005cf[msg.sender] = block.number;
        _0xf3c089[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function _0x2e6d43()
    _0x1369c1()
    _0x762d77()
    _0x8869d3()
    public
    {
        uint256 _0x4bd2b9 = _0x6005cf[msg.sender];
        if(_0x4bd2b9 < block.number)
        {
            _0x6005cf[msg.sender] = 0;
            _0xf3c089[msg.sender] = 0;

            uint256 _0xa9144e = uint256(_0x6dc76a(abi._0x790aaa(blockhash(_0x4bd2b9),  msg.sender)))%difficulty +1;

            if(_0xa9144e == difficulty / 2)
            {
                _0xf41ad3(msg.sender);
            }
            else
            {

                _0x3950e8(_0x129ca7 / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function _0x1cea32()
    _0x1369c1()
    public
    payable
    {
        _0xe5b74a(msg.value);
    }

    function _0xf41ad3(address _0xe0baef)
    internal
    {
        uint256 _0x92b7f9 = address(this).balance / 2;

        _0xe0baef.transfer(_0x92b7f9);
        emit Win(_0x92b7f9, _0xe0baef);
    }

    function _0xe5b74a(uint256 _0xcff57d)
    internal
    {
        _0x47f5fa.call.value(_0xcff57d)(bytes4(_0x6dc76a("donate()")));
        _0xb1b8cf += _0xcff57d;
        emit Donate(_0xcff57d, _0x47f5fa, msg.sender);
    }

    function _0x3950e8(uint256 _0xcff57d)
    internal
    {
        _0x47f5fa.call.value(_0xcff57d)(bytes4(_0x6dc76a("donate()")));
        _0xb1b8cf += _0xcff57d;
        emit Lose(_0xcff57d, msg.sender);
    }

    function _0x599758()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function _0x62ffff()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function _0xd49182()
    public
    view
    returns (uint256)
    {
        return _0x129ca7;
    }

    function _0xcab036(address _0xfb0e7f)
    public
    view
    returns (bool)
    {
        if(_0xf3c089[_0xfb0e7f] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function _0x5024b7()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function _0x5cbae4(address _0x3da724, address _0x4ae6a0, uint _0x577f2e)
    public
    _0x5929f4()
    returns (bool _0xf4964d)
    {
        return ERC20Interface(_0x3da724).transfer(_0x4ae6a0, _0x577f2e);
    }
}


contract ERC20Interface
{
    function transfer(address _0xfa40ff, uint256 _0x577f2e) public returns (bool _0xf4964d);
}