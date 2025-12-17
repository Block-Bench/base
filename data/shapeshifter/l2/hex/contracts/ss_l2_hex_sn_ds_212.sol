// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

    modifier _0x072d96()
    {
        require(msg.sender == _0x0152f7);
        _;
    }

   modifier _0x37a4b5()
    {
        require(_0xaaffa5);
        _;
    }

    modifier _0xa11a1d()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  _0xb3fbc6()
    {
        require (_0xbbca41[msg.sender] > 0);
        _;
    }

    event Wager(uint256 _0xb899c3, address _0xea320f);
    event Win(uint256 _0xb899c3, address _0x4ae2d0);
    event Lose(uint256 _0xb899c3, address _0xfacc51);
    event Donate(uint256 _0xb899c3, address _0x4ae2d0, address _0x81ba3b);
    event DifficultyChanged(uint256 _0xe9ec4a);
    event BetLimitChanged(uint256 _0x0b3da5);

    address private _0x929f9d;
    uint256 _0xc6390b;
    uint difficulty;
    uint private _0x15c439;
    address _0x0152f7;
    mapping(address => uint256) _0x170afa;
    mapping(address => uint256) _0xbbca41;
    bool _0xaaffa5;
    uint256 _0x925b2b;

    constructor(address _0x5fb0d3, uint256 _0xe95054)
    _0xa11a1d()
    public
    {
        _0xaaffa5 = false;
        _0x0152f7 = msg.sender;
        _0x929f9d = _0x5fb0d3;
        _0x925b2b = 0;
        _0xc6390b = _0xe95054;

    }

    function OpenToThePublic()
    _0x072d96()
    public
    {
        _0xaaffa5 = true;
    }

    function AdjustBetAmounts(uint256 _0xb899c3)
    _0x072d96()
    public
    {
        _0xc6390b = _0xb899c3;

        emit BetLimitChanged(_0xc6390b);
    }

    function AdjustDifficulty(uint256 _0xb899c3)
    _0x072d96()
    public
    {
        difficulty = _0xb899c3;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function _0xc886a7()
    _0x37a4b5()
    _0xa11a1d()
    payable
    public
    {
        //You have to send exactly 0.01 ETH.
        require(msg.value == _0xc6390b);

        //You cannot wager multiple times
        require(_0xbbca41[msg.sender] == 0);

        //log the wager and timestamp(block number)
        _0x170afa[msg.sender] = block.number;
        _0xbbca41[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function _0xee256e()
    _0x37a4b5()
    _0xa11a1d()
    _0xb3fbc6()
    public
    {
        uint256 _0x0abdbe = _0x170afa[msg.sender];
        if(_0x0abdbe < block.number)
        {
            _0x170afa[msg.sender] = 0;
            _0xbbca41[msg.sender] = 0;

            uint256 _0x563f3a = uint256(_0xb6a218(abi._0x94fec4(blockhash(_0x0abdbe),  msg.sender)))%difficulty +1;

            if(_0x563f3a == difficulty / 2)
            {
                _0x8ffbce(msg.sender);
            }
            else
            {
                //player loses
                _0x2b160c(_0xc6390b / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function _0xd0b6f2()
    _0x37a4b5()
    public
    payable
    {
        _0xd4d3e1(msg.value);
    }

    function _0x8ffbce(address _0xdd86a0)
    internal
    {
        uint256 _0xcba042 = address(this).balance / 2;

        _0xdd86a0.transfer(_0xcba042);
        emit Win(_0xcba042, _0xdd86a0);
    }

    function _0xd4d3e1(uint256 _0xb899c3)
    internal
    {
        _0x929f9d.call.value(_0xb899c3)(bytes4(_0xb6a218("donate()")));
        _0x925b2b += _0xb899c3;
        emit Donate(_0xb899c3, _0x929f9d, msg.sender);
    }

    function _0x2b160c(uint256 _0xb899c3)
    internal
    {
        _0x929f9d.call.value(_0xb899c3)(bytes4(_0xb6a218("donate()")));
        _0x925b2b += _0xb899c3;
        emit Lose(_0xb899c3, msg.sender);
    }

    function _0xaedf60()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function _0xe9ec4a()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function _0x0b3da5()
    public
    view
    returns (uint256)
    {
        return _0xc6390b;
    }

    function _0x1463cb(address _0xc76ddb)
    public
    view
    returns (bool)
    {
        if(_0xbbca41[_0xc76ddb] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function _0x036c5a()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function _0x44583e(address _0x6f616a, address _0xe93195, uint _0xcf7c27)
    public
    _0x072d96()
    returns (bool _0x91fc81)
    {
        return ERC20Interface(_0x6f616a).transfer(_0xe93195, _0xcf7c27);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address _0x0519ff, uint256 _0xcf7c27) public returns (bool _0x91fc81);
}