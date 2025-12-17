// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

    modifier _0x31214b()
    {
        require(msg.sender == _0xbf6eb1);
        _;
    }

   modifier _0x01d2bb()
    {
        require(_0x44870e);
        _;
    }

    modifier _0xfeefbd()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  _0x08fbd4()
    {
        require (_0x855f39[msg.sender] > 0);
        _;
    }

    event Wager(uint256 _0x815fcf, address _0xb279fd);
    event Win(uint256 _0x815fcf, address _0x4bc3a1);
    event Lose(uint256 _0x815fcf, address _0x9936bd);
    event Donate(uint256 _0x815fcf, address _0x4bc3a1, address _0xa0cf97);
    event DifficultyChanged(uint256 _0x8fae29);
    event BetLimitChanged(uint256 _0x28f626);

    address private _0xaca6e8;
    uint256 _0x32632f;
    uint difficulty;
    uint private _0x493b4f;
    address _0xbf6eb1;
    mapping(address => uint256) _0x8cb2e1;
    mapping(address => uint256) _0x855f39;
    bool _0x44870e;
    uint256 _0x985f3c;

    constructor(address _0x0c5b2c, uint256 _0x136609)
    _0xfeefbd()
    public
    {
        _0x44870e = false;
        _0xbf6eb1 = msg.sender;
        _0xaca6e8 = _0x0c5b2c;
        _0x985f3c = 0;
        _0x32632f = _0x136609;

    }

    function OpenToThePublic()
    _0x31214b()
    public
    {
        _0x44870e = true;
    }

    function AdjustBetAmounts(uint256 _0x815fcf)
    _0x31214b()
    public
    {
        _0x32632f = _0x815fcf;

        emit BetLimitChanged(_0x32632f);
    }

    function AdjustDifficulty(uint256 _0x815fcf)
    _0x31214b()
    public
    {
        difficulty = _0x815fcf;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function _0x8f6a2e()
    _0x01d2bb()
    _0xfeefbd()
    payable
    public
    {
        //You have to send exactly 0.01 ETH.
        require(msg.value == _0x32632f);

        //You cannot wager multiple times
        require(_0x855f39[msg.sender] == 0);

        //log the wager and timestamp(block number)
        _0x8cb2e1[msg.sender] = block.number;
        _0x855f39[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function _0x66a54f()
    _0x01d2bb()
    _0xfeefbd()
    _0x08fbd4()
    public
    {
        uint256 _0x7c821d = _0x8cb2e1[msg.sender];
        if(_0x7c821d < block.number)
        {
            _0x8cb2e1[msg.sender] = 0;
            _0x855f39[msg.sender] = 0;

            uint256 _0x84939d = uint256(_0xb7f01b(abi._0x88cde5(blockhash(_0x7c821d),  msg.sender)))%difficulty +1;

            if(_0x84939d == difficulty / 2)
            {
                _0x8a3d05(msg.sender);
            }
            else
            {
                //player loses
                _0x0553a7(_0x32632f / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function _0x85feae()
    _0x01d2bb()
    public
    payable
    {
        _0xa34236(msg.value);
    }

    function _0x8a3d05(address _0xa58dd7)
    internal
    {
        uint256 _0x8d9a65 = address(this).balance / 2;

        _0xa58dd7.transfer(_0x8d9a65);
        emit Win(_0x8d9a65, _0xa58dd7);
    }

    function _0xa34236(uint256 _0x815fcf)
    internal
    {
        _0xaca6e8.call.value(_0x815fcf)(bytes4(_0xb7f01b("donate()")));
        _0x985f3c += _0x815fcf;
        emit Donate(_0x815fcf, _0xaca6e8, msg.sender);
    }

    function _0x0553a7(uint256 _0x815fcf)
    internal
    {
        _0xaca6e8.call.value(_0x815fcf)(bytes4(_0xb7f01b("donate()")));
        _0x985f3c += _0x815fcf;
        emit Lose(_0x815fcf, msg.sender);
    }

    function _0x0fcbe5()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function _0x8fae29()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function _0x28f626()
    public
    view
    returns (uint256)
    {
        return _0x32632f;
    }

    function _0x55aed6(address _0xc7ce01)
    public
    view
    returns (bool)
    {
        if(_0x855f39[_0xc7ce01] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function _0xd04796()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function _0x01d365(address _0x7e3617, address _0xd99e22, uint _0x6a0dc7)
    public
    _0x31214b()
    returns (bool _0xe2f5ec)
    {
        return ERC20Interface(_0x7e3617).transfer(_0xd99e22, _0x6a0dc7);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address _0xd53bee, uint256 _0x6a0dc7) public returns (bool _0xe2f5ec);
}