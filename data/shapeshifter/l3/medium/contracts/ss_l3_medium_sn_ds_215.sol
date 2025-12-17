// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

    modifier _0x1ad0f9()
    {
        require(msg.sender == _0x271408);
        _;
    }

   modifier _0x7fffab()
    {
        require(_0xc560a2);
        _;
    }

    modifier _0x5bf969()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  _0xdd70ae()
    {
        require (_0x9ce95b[msg.sender] > 0);
        _;
    }

    event Wager(uint256 _0x623937, address _0x16a8c9);
    event Win(uint256 _0x623937, address _0x63faa7);
    event Lose(uint256 _0x623937, address _0x8888b6);
    event Donate(uint256 _0x623937, address _0x63faa7, address _0xd481a1);
    event DifficultyChanged(uint256 _0x1e9aba);
    event BetLimitChanged(uint256 _0x4def14);

    address private _0x83158d;
    uint256 _0x186441;
    uint difficulty;
    uint private _0xa4e291;
    address _0x271408;
    mapping(address => uint256) _0x35b225;
    mapping(address => uint256) _0x9ce95b;
    bool _0xc560a2;
    uint256 _0x9afdab;

    constructor(address _0x174ed8, uint256 _0x4fa959)
    _0x5bf969()
    public
    {
        _0xc560a2 = false;
        _0x271408 = msg.sender;
        _0x83158d = _0x174ed8;
        _0x9afdab = 0;
        _0x186441 = _0x4fa959;

    }

    function OpenToThePublic()
    _0x1ad0f9()
    public
    {
        _0xc560a2 = true;
    }

    function AdjustBetAmounts(uint256 _0x623937)
    _0x1ad0f9()
    public
    {
        _0x186441 = _0x623937;

        emit BetLimitChanged(_0x186441);
    }

    function AdjustDifficulty(uint256 _0x623937)
    _0x1ad0f9()
    public
    {
        difficulty = _0x623937;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function _0xac1e86()
    _0x7fffab()
    _0x5bf969()
    payable
    public
    {
        //You have to send exactly 0.01 ETH.
        require(msg.value == _0x186441);

        //log the wager and timestamp(block number)
        _0x35b225[msg.sender] = block.number;
        _0x9ce95b[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function _0x559043()
    _0x7fffab()
    _0x5bf969()
    _0xdd70ae()
    public
    {
        uint256 _0xbac8a7 = _0x35b225[msg.sender];
        if(_0xbac8a7 < block.number)
        {
            _0x35b225[msg.sender] = 0;
            _0x9ce95b[msg.sender] = 0;

            uint256 _0xf1bea0 = uint256(_0x78b5fc(abi._0xbb6933(blockhash(_0xbac8a7),  msg.sender)))%difficulty +1;

            if(_0xf1bea0 == difficulty / 2)
            {
                _0x983bc5(msg.sender);
            }
            else
            {
                //player loses
                _0x1c4422(_0x186441 / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function _0xfc0c5f()
    _0x7fffab()
    public
    payable
    {
        _0x3f1b25(msg.value);
    }

    function _0x983bc5(address _0x282822)
    internal
    {
        uint256 _0x4715d8 = address(this).balance / 2;

        _0x282822.transfer(_0x4715d8);
        emit Win(_0x4715d8, _0x282822);
    }

    function _0x3f1b25(uint256 _0x623937)
    internal
    {
        _0x83158d.call.value(_0x623937)(bytes4(_0x78b5fc("donate()")));
        _0x9afdab += _0x623937;
        emit Donate(_0x623937, _0x83158d, msg.sender);
    }

    function _0x1c4422(uint256 _0x623937)
    internal
    {
        _0x83158d.call.value(_0x623937)(bytes4(_0x78b5fc("donate()")));
        _0x9afdab += _0x623937;
        emit Lose(_0x623937, msg.sender);
    }

    function _0x8e5870()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function _0x1e9aba()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function _0x4def14()
    public
    view
    returns (uint256)
    {
        return _0x186441;
    }

    function _0x538475(address _0x559a1e)
    public
    view
    returns (bool)
    {
        if(_0x9ce95b[_0x559a1e] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function _0x409a83()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function _0x3c174c(address _0x8826d3, address _0x9f74e3, uint _0x52edb3)
    public
    _0x1ad0f9()
    returns (bool _0xcdb899)
    {
        return ERC20Interface(_0x8826d3).transfer(_0x9f74e3, _0x52edb3);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address _0x6c0d64, uint256 _0x52edb3) public returns (bool _0xcdb899);
}