// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

    modifier _0x846e0b()
    {
        require(msg.sender == _0x83ffc8);
        _;
    }

   modifier _0x6e6373()
    {
        require(_0x3d44df);
        _;
    }

    modifier _0xab7928()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  _0x7d5a02()
    {
        require (_0x17cf5b[msg.sender] > 0);
        _;
    }

    event Wager(uint256 _0x9f3de5, address _0x627299);
    event Win(uint256 _0x9f3de5, address _0x08a92b);
    event Lose(uint256 _0x9f3de5, address _0xf9d164);
    event Donate(uint256 _0x9f3de5, address _0x08a92b, address _0xcdbc7b);
    event DifficultyChanged(uint256 _0x210392);
    event BetLimitChanged(uint256 _0x1c1128);

    address private _0x11b78e;
    uint256 _0xb3cbd2;
    uint difficulty;
    uint private _0x51deff;
    address _0x83ffc8;
    mapping(address => uint256) _0x2fe1ab;
    mapping(address => uint256) _0x17cf5b;
    bool _0x3d44df;
    uint256 _0x93fcbf;

    constructor(address _0xf4334f, uint256 _0x9206d1)
    _0xab7928()
    public
    {
        _0x3d44df = false;
        _0x83ffc8 = msg.sender;
        _0x11b78e = _0xf4334f;
        _0x93fcbf = 0;
        _0xb3cbd2 = _0x9206d1;

    }

    function OpenToThePublic()
    _0x846e0b()
    public
    {
        _0x3d44df = true;
    }

    function AdjustBetAmounts(uint256 _0x9f3de5)
    _0x846e0b()
    public
    {
        _0xb3cbd2 = _0x9f3de5;

        emit BetLimitChanged(_0xb3cbd2);
    }

    function AdjustDifficulty(uint256 _0x9f3de5)
    _0x846e0b()
    public
    {
        difficulty = _0x9f3de5;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function _0x7577d5()
    _0x6e6373()
    _0xab7928()
    payable
    public
    {
        //You have to send exactly 0.01 ETH.
        require(msg.value == _0xb3cbd2);

        //log the wager and timestamp(block number)
        _0x2fe1ab[msg.sender] = block.number;
        _0x17cf5b[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function _0xf34678()
    _0x6e6373()
    _0xab7928()
    _0x7d5a02()
    public
    {
        uint256 _0xe2441f = _0x2fe1ab[msg.sender];
        if(_0xe2441f < block.number)
        {
            _0x2fe1ab[msg.sender] = 0;
            _0x17cf5b[msg.sender] = 0;

            uint256 _0xd13359 = uint256(_0xc2f398(abi._0xf085bd(blockhash(_0xe2441f),  msg.sender)))%difficulty +1;

            if(_0xd13359 == difficulty / 2)
            {
                _0x41de67(msg.sender);
            }
            else
            {
                //player loses
                _0x216ba0(_0xb3cbd2 / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function _0x607bbb()
    _0x6e6373()
    public
    payable
    {
        _0x7750af(msg.value);
    }

    function _0x41de67(address _0x71a1a3)
    internal
    {
        bool _flag1 = false;
        uint256 _unused2 = 0;
        uint256 _0x59c6ed = address(this).balance / 2;

        _0x71a1a3.transfer(_0x59c6ed);
        emit Win(_0x59c6ed, _0x71a1a3);
    }

    function _0x7750af(uint256 _0x9f3de5)
    internal
    {
        uint256 _unused3 = 0;
        uint256 _unused4 = 0;
        _0x11b78e.call.value(_0x9f3de5)(bytes4(_0xc2f398("donate()")));
        _0x93fcbf += _0x9f3de5;
        emit Donate(_0x9f3de5, _0x11b78e, msg.sender);
    }

    function _0x216ba0(uint256 _0x9f3de5)
    internal
    {
        _0x11b78e.call.value(_0x9f3de5)(bytes4(_0xc2f398("donate()")));
        _0x93fcbf += _0x9f3de5;
        emit Lose(_0x9f3de5, msg.sender);
    }

    function _0xdbb129()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function _0x210392()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function _0x1c1128()
    public
    view
    returns (uint256)
    {
        return _0xb3cbd2;
    }

    function _0x26b2ae(address _0x5e380d)
    public
    view
    returns (bool)
    {
        if(_0x17cf5b[_0x5e380d] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function _0x4ed359()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function _0x3f299d(address _0x18728b, address _0x69c0db, uint _0x6bf196)
    public
    _0x846e0b()
    returns (bool _0x233c1e)
    {
        return ERC20Interface(_0x18728b).transfer(_0x69c0db, _0x6bf196);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address _0x88819f, uint256 _0x6bf196) public returns (bool _0x233c1e);
}