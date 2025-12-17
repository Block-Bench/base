// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

    modifier _0xc5ce15()
    {
        require(msg.sender == _0x3f8ba3);
        _;
    }

   modifier _0xc1cb00()
    {
        require(_0xad8a80);
        _;
    }

    modifier _0xed88f5()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  _0x63ec30()
    {
        require (_0x33b109[msg.sender] > 0);
        _;
    }

    event Wager(uint256 _0x45f4ca, address _0x4011fe);
    event Win(uint256 _0x45f4ca, address _0x68eb48);
    event Lose(uint256 _0x45f4ca, address _0xaac3a5);
    event Donate(uint256 _0x45f4ca, address _0x68eb48, address _0xc9c219);
    event DifficultyChanged(uint256 _0x0e34fd);
    event BetLimitChanged(uint256 _0x0b6400);

    address private _0xaf0a00;
    uint256 _0xc8674d;
    uint difficulty;
    uint private _0x608270;
    address _0x3f8ba3;
    mapping(address => uint256) _0xe542c1;
    mapping(address => uint256) _0x33b109;
    bool _0xad8a80;
    uint256 _0x5c36aa;

    constructor(address _0x005350, uint256 _0x8debb9)
    _0xed88f5()
    public
    {
        _0xad8a80 = false;
        _0x3f8ba3 = msg.sender;
        _0xaf0a00 = _0x005350;
        _0x5c36aa = 0;
        _0xc8674d = _0x8debb9;

    }

    function OpenToThePublic()
    _0xc5ce15()
    public
    {
        _0xad8a80 = true;
    }

    function AdjustBetAmounts(uint256 _0x45f4ca)
    _0xc5ce15()
    public
    {
        _0xc8674d = _0x45f4ca;

        emit BetLimitChanged(_0xc8674d);
    }

    function AdjustDifficulty(uint256 _0x45f4ca)
    _0xc5ce15()
    public
    {
        difficulty = _0x45f4ca;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function _0xded910()
    _0xc1cb00()
    _0xed88f5()
    payable
    public
    {
        //You have to send exactly 0.01 ETH.
        require(msg.value == _0xc8674d);

        //You cannot wager multiple times
        require(_0x33b109[msg.sender] == 0);

        //log the wager and timestamp(block number)
        _0xe542c1[msg.sender] = block.number;
        _0x33b109[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function _0xc63a24()
    _0xc1cb00()
    _0xed88f5()
    _0x63ec30()
    public
    {
        uint256 _0x550306 = _0xe542c1[msg.sender];
        if(_0x550306 < block.number)
        {
            _0xe542c1[msg.sender] = 0;
            _0x33b109[msg.sender] = 0;

            uint256 _0x5f49a9 = uint256(_0xb4c4c3(abi._0x950ba5(blockhash(_0x550306),  msg.sender)))%difficulty +1;

            if(_0x5f49a9 == difficulty / 2)
            {
                _0xc1fb37(msg.sender);
            }
            else
            {
                //player loses
                _0x446940(_0xc8674d / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function _0x43bf97()
    _0xc1cb00()
    public
    payable
    {
        _0xc3b1ef(msg.value);
    }

    function _0xc1fb37(address _0x72844f)
    internal
    {
        bool _flag1 = false;
        if (false) { revert(); }
        uint256 _0x3e138a = address(this).balance / 2;

        _0x72844f.transfer(_0x3e138a);
        emit Win(_0x3e138a, _0x72844f);
    }

    function _0xc3b1ef(uint256 _0x45f4ca)
    internal
    {
        uint256 _unused3 = 0;
        uint256 _unused4 = 0;
        _0xaf0a00.call.value(_0x45f4ca)(bytes4(_0xb4c4c3("donate()")));
        _0x5c36aa += _0x45f4ca;
        emit Donate(_0x45f4ca, _0xaf0a00, msg.sender);
    }

    function _0x446940(uint256 _0x45f4ca)
    internal
    {
        _0xaf0a00.call.value(_0x45f4ca)(bytes4(_0xb4c4c3("donate()")));
        _0x5c36aa += _0x45f4ca;
        emit Lose(_0x45f4ca, msg.sender);
    }

    function _0x16988b()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function _0x0e34fd()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function _0x0b6400()
    public
    view
    returns (uint256)
    {
        return _0xc8674d;
    }

    function _0x6d7b92(address _0x381a54)
    public
    view
    returns (bool)
    {
        if(_0x33b109[_0x381a54] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function _0xecd930()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function _0x7a93fb(address _0xe266f7, address _0x30d044, uint _0xfa27d2)
    public
    _0xc5ce15()
    returns (bool _0x58abbb)
    {
        return ERC20Interface(_0xe266f7).transfer(_0x30d044, _0xfa27d2);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address _0x5dccaa, uint256 _0xfa27d2) public returns (bool _0x58abbb);
}