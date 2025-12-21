pragma solidity ^0.4.24;

contract PoCGame
{

    modifier _0x1eb852()
    {
        require(msg.sender == _0x29a3f5);
        _;
    }

   modifier _0x007871()
    {
        require(_0xaf4757);
        _;
    }

    modifier _0xf142c1()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  _0xaab9de()
    {
        require (_0x39d4b4[msg.sender] > 0);
        _;
    }

    event Wager(uint256 _0xeb521d, address _0x5d90c7);
    event Win(uint256 _0xeb521d, address _0xc614a6);
    event Lose(uint256 _0xeb521d, address _0xb2bfd2);
    event Donate(uint256 _0xeb521d, address _0xc614a6, address _0x50241c);
    event DifficultyChanged(uint256 _0xc059e2);
    event BetLimitChanged(uint256 _0x8adb0b);

    address private _0xaa3bc4;
    uint256 _0x03dad0;
    uint difficulty;
    uint private _0xfd758d;
    address _0x29a3f5;
    mapping(address => uint256) _0x46084b;
    mapping(address => uint256) _0x39d4b4;
    bool _0xaf4757;
    uint256 _0x389116;

    constructor(address _0xe66366, uint256 _0x85aea3)
    _0xf142c1()
    public
    {
        _0xaf4757 = false;
        _0x29a3f5 = msg.sender;
        _0xaa3bc4 = _0xe66366;
        _0x389116 = 0;
        _0x03dad0 = _0x85aea3;

    }

    function OpenToThePublic()
    _0x1eb852()
    public
    {
        _0xaf4757 = true;
    }

    function AdjustBetAmounts(uint256 _0xeb521d)
    _0x1eb852()
    public
    {
        _0x03dad0 = _0xeb521d;

        emit BetLimitChanged(_0x03dad0);
    }

    function AdjustDifficulty(uint256 _0xeb521d)
    _0x1eb852()
    public
    {
        difficulty = _0xeb521d;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function _0xcd7cab()
    _0x007871()
    _0xf142c1()
    payable
    public
    {

        require(msg.value == _0x03dad0);


        _0x46084b[msg.sender] = block.number;
        _0x39d4b4[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function _0xc66e79()
    _0x007871()
    _0xf142c1()
    _0xaab9de()
    public
    {
        uint256 _0xfea56e = _0x46084b[msg.sender];
        if(_0xfea56e < block.number)
        {
            _0x46084b[msg.sender] = 0;
            _0x39d4b4[msg.sender] = 0;

            uint256 _0xd57fe6 = uint256(_0xc42710(abi._0x28f870(blockhash(_0xfea56e),  msg.sender)))%difficulty +1;

            if(_0xd57fe6 == difficulty / 2)
            {
                _0x015052(msg.sender);
            }
            else
            {

                _0x933e9d(_0x03dad0 / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function _0xd96f98()
    _0x007871()
    public
    payable
    {
        _0xa23a06(msg.value);
    }

    function _0x015052(address _0xcb36dc)
    internal
    {
        uint256 _0x0e3609 = address(this).balance / 2;

        _0xcb36dc.transfer(_0x0e3609);
        emit Win(_0x0e3609, _0xcb36dc);
    }

    function _0xa23a06(uint256 _0xeb521d)
    internal
    {
        _0xaa3bc4.call.value(_0xeb521d)(bytes4(_0xc42710("donate()")));
        _0x389116 += _0xeb521d;
        emit Donate(_0xeb521d, _0xaa3bc4, msg.sender);
    }

    function _0x933e9d(uint256 _0xeb521d)
    internal
    {
        _0xaa3bc4.call.value(_0xeb521d)(bytes4(_0xc42710("donate()")));
        _0x389116 += _0xeb521d;
        emit Lose(_0xeb521d, msg.sender);
    }

    function _0xc9ec45()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function _0xc059e2()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function _0x8adb0b()
    public
    view
    returns (uint256)
    {
        return _0x03dad0;
    }

    function _0x3d3c48(address _0x67a6b2)
    public
    view
    returns (bool)
    {
        if(_0x39d4b4[_0x67a6b2] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function _0xb2aed9()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function _0xa05a9a(address _0xfa89ce, address _0x77a835, uint _0xeb6bee)
    public
    _0x1eb852()
    returns (bool _0x618106)
    {
        return ERC20Interface(_0xfa89ce).transfer(_0x77a835, _0xeb6bee);
    }
}


contract ERC20Interface
{
    function transfer(address _0xc81635, uint256 _0xeb6bee) public returns (bool _0x618106);
}