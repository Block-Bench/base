// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

    modifier _0x64b15c()
    {
        require(msg.sender == _0xd831c9);
        _;
    }

   modifier _0xeaea15()
    {
        require(_0x373177);
        _;
    }

    modifier _0x985082()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  _0x6fd2a3()
    {
        require (_0xab7aa6[msg.sender] > 0);
        _;
    }

    event Wager(uint256 _0x0868e2, address _0x18e6dc);
    event Win(uint256 _0x0868e2, address _0x9df952);
    event Lose(uint256 _0x0868e2, address _0xf22631);
    event Donate(uint256 _0x0868e2, address _0x9df952, address _0x7f6742);
    event DifficultyChanged(uint256 _0x57caa3);
    event BetLimitChanged(uint256 _0x90514f);

    address private _0xe1ec89;
    uint256 _0x2bae41;
    uint difficulty;
    uint private _0x5cba09;
    address _0xd831c9;
    mapping(address => uint256) _0x88d34a;
    mapping(address => uint256) _0xab7aa6;
    bool _0x373177;
    uint256 _0x1fd932;

    constructor(address _0x72ed44, uint256 _0xf174cb)
    _0x985082()
    public
    {
        _0x373177 = false;
        _0xd831c9 = msg.sender;
        _0xe1ec89 = _0x72ed44;
        _0x1fd932 = 0;
        _0x2bae41 = _0xf174cb;

    }

    function OpenToThePublic()
    _0x64b15c()
    public
    {
        _0x373177 = true;
    }

    function AdjustBetAmounts(uint256 _0x0868e2)
    _0x64b15c()
    public
    {
        _0x2bae41 = _0x0868e2;

        emit BetLimitChanged(_0x2bae41);
    }

    function AdjustDifficulty(uint256 _0x0868e2)
    _0x64b15c()
    public
    {
        difficulty = _0x0868e2;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function _0x47c0ac()
    _0xeaea15()
    _0x985082()
    payable
    public
    {
        //You have to send exactly 0.01 ETH.
        require(msg.value == _0x2bae41);

        //You cannot wager multiple times
        require(_0xab7aa6[msg.sender] == 0);

        //log the wager and timestamp(block number)
        _0x88d34a[msg.sender] = block.number;
        _0xab7aa6[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function _0x384de5()
    _0xeaea15()
    _0x985082()
    _0x6fd2a3()
    public
    {
        uint256 _0xf15342 = _0x88d34a[msg.sender];
        if(_0xf15342 < block.number)
        {
            _0x88d34a[msg.sender] = 0;
            _0xab7aa6[msg.sender] = 0;

            uint256 _0xbac840 = uint256(_0x2c4269(abi._0x06ebfb(blockhash(_0xf15342),  msg.sender)))%difficulty +1;

            if(_0xbac840 == difficulty / 2)
            {
                _0xd90494(msg.sender);
            }
            else
            {
                //player loses
                _0x52fdb0(_0x2bae41 / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function _0xd1ff63()
    _0xeaea15()
    public
    payable
    {
        _0x759c92(msg.value);
    }

    function _0xd90494(address _0x1f75d0)
    internal
    {
        uint256 _0x5a7c3e = address(this).balance / 2;

        _0x1f75d0.transfer(_0x5a7c3e);
        emit Win(_0x5a7c3e, _0x1f75d0);
    }

    function _0x759c92(uint256 _0x0868e2)
    internal
    {
        _0xe1ec89.call.value(_0x0868e2)(bytes4(_0x2c4269("donate()")));
        _0x1fd932 += _0x0868e2;
        emit Donate(_0x0868e2, _0xe1ec89, msg.sender);
    }

    function _0x52fdb0(uint256 _0x0868e2)
    internal
    {
        _0xe1ec89.call.value(_0x0868e2)(bytes4(_0x2c4269("donate()")));
        _0x1fd932 += _0x0868e2;
        emit Lose(_0x0868e2, msg.sender);
    }

    function _0xce6a77()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function _0x57caa3()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function _0x90514f()
    public
    view
    returns (uint256)
    {
        return _0x2bae41;
    }

    function _0x1f1dd0(address _0x860d1a)
    public
    view
    returns (bool)
    {
        if(_0xab7aa6[_0x860d1a] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function _0x2f70ef()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function _0x661256(address _0x9c5b7d, address _0x0b633f, uint _0xc36985)
    public
    _0x64b15c()
    returns (bool _0x96ae9c)
    {
        return ERC20Interface(_0x9c5b7d).transfer(_0x0b633f, _0xc36985);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address _0xf9755d, uint256 _0xc36985) public returns (bool _0x96ae9c);
}