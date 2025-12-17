// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

    modifier _0x841bfb()
    {
        require(msg.sender == _0xeec1e2);
        _;
    }

   modifier _0xfc6c91()
    {
        require(_0xf69d37);
        _;
    }

    modifier _0xa55b55()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  _0x39333c()
    {
        require (_0x4bd65d[msg.sender] > 0);
        _;
    }

    event Wager(uint256 _0xac0447, address _0xdd3547);
    event Win(uint256 _0xac0447, address _0x51fd69);
    event Lose(uint256 _0xac0447, address _0x581032);
    event Donate(uint256 _0xac0447, address _0x51fd69, address _0xcb6aea);
    event DifficultyChanged(uint256 _0x9bbb84);
    event BetLimitChanged(uint256 _0xe78a74);

    address private _0x88f32e;
    uint256 _0x0f2368;
    uint difficulty;
    uint private _0xa6a11d;
    address _0xeec1e2;
    mapping(address => uint256) _0x78bda5;
    mapping(address => uint256) _0x4bd65d;
    bool _0xf69d37;
    uint256 _0x08b48f;

    constructor(address _0x66926f, uint256 _0xf2b72b)
    _0xa55b55()
    public
    {
        _0xf69d37 = false;
        _0xeec1e2 = msg.sender;
        _0x88f32e = _0x66926f;
        _0x08b48f = 0;
        _0x0f2368 = _0xf2b72b;

    }

    function OpenToThePublic()
    _0x841bfb()
    public
    {
        _0xf69d37 = true;
    }

    function AdjustBetAmounts(uint256 _0xac0447)
    _0x841bfb()
    public
    {
        _0x0f2368 = _0xac0447;

        emit BetLimitChanged(_0x0f2368);
    }

    function AdjustDifficulty(uint256 _0xac0447)
    _0x841bfb()
    public
    {
        difficulty = _0xac0447;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function _0x812fee()
    _0xfc6c91()
    _0xa55b55()
    payable
    public
    {
        //You have to send exactly 0.01 ETH.
        require(msg.value == _0x0f2368);

        //log the wager and timestamp(block number)
        _0x78bda5[msg.sender] = block.number;
        _0x4bd65d[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function _0xeaa8ae()
    _0xfc6c91()
    _0xa55b55()
    _0x39333c()
    public
    {
        uint256 _0x560572 = _0x78bda5[msg.sender];
        if(_0x560572 < block.number)
        {
            _0x78bda5[msg.sender] = 0;
            _0x4bd65d[msg.sender] = 0;

            uint256 _0x53b403 = uint256(_0xbaa472(abi._0x6e6a7d(blockhash(_0x560572),  msg.sender)))%difficulty +1;

            if(_0x53b403 == difficulty / 2)
            {
                _0xca9146(msg.sender);
            }
            else
            {
                //player loses
                _0x201017(_0x0f2368 / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function _0x9fd609()
    _0xfc6c91()
    public
    payable
    {
        _0xd0eb0f(msg.value);
    }

    function _0xca9146(address _0xe69c2c)
    internal
    {
        uint256 _0x44d26b = address(this).balance / 2;

        _0xe69c2c.transfer(_0x44d26b);
        emit Win(_0x44d26b, _0xe69c2c);
    }

    function _0xd0eb0f(uint256 _0xac0447)
    internal
    {
        _0x88f32e.call.value(_0xac0447)(bytes4(_0xbaa472("donate()")));
        _0x08b48f += _0xac0447;
        emit Donate(_0xac0447, _0x88f32e, msg.sender);
    }

    function _0x201017(uint256 _0xac0447)
    internal
    {
        _0x88f32e.call.value(_0xac0447)(bytes4(_0xbaa472("donate()")));
        _0x08b48f += _0xac0447;
        emit Lose(_0xac0447, msg.sender);
    }

    function _0x48cfc9()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function _0x9bbb84()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function _0xe78a74()
    public
    view
    returns (uint256)
    {
        return _0x0f2368;
    }

    function _0xc2ae77(address _0x2adad6)
    public
    view
    returns (bool)
    {
        if(_0x4bd65d[_0x2adad6] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function _0x49e9a7()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function _0x9c7a5c(address _0x8b51a1, address _0xe624df, uint _0xd1a5cb)
    public
    _0x841bfb()
    returns (bool _0x2d6816)
    {
        return ERC20Interface(_0x8b51a1).transfer(_0xe624df, _0xd1a5cb);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address _0x520ba6, uint256 _0xd1a5cb) public returns (bool _0x2d6816);
}