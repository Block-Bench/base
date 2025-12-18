// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

    modifier _0xae33a9()
    {
        require(msg.sender == _0xa888d1);
        _;
    }

   modifier _0xc95bcd()
    {
        require(_0x88223f);
        _;
    }

    modifier _0xdd23e5()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  _0x631a67()
    {
        require (_0xfc21d7[msg.sender] > 0);
        _;
    }

    event Wager(uint256 _0xeb6a25, address _0xaa5500);
    event Win(uint256 _0xeb6a25, address _0x5d1274);
    event Lose(uint256 _0xeb6a25, address _0x56a0ea);
    event Donate(uint256 _0xeb6a25, address _0x5d1274, address _0x49bcba);
    event DifficultyChanged(uint256 _0x4ec0ee);
    event BetLimitChanged(uint256 _0x33a06d);

    address private _0x5b3520;
    uint256 _0x3eb5dd;
    uint difficulty;
    uint private _0x1a0f9d;
    address _0xa888d1;
    mapping(address => uint256) _0x0a6bc9;
    mapping(address => uint256) _0xfc21d7;
    bool _0x88223f;
    uint256 _0x482b47;

    constructor(address _0x32f666, uint256 _0x5c1beb)
    _0xdd23e5()
    public
    {
        _0x88223f = false;
        _0xa888d1 = msg.sender;
        _0x5b3520 = _0x32f666;
        _0x482b47 = 0;
        _0x3eb5dd = _0x5c1beb;

    }

    function OpenToThePublic()
    _0xae33a9()
    public
    {
        _0x88223f = true;
    }

    function AdjustBetAmounts(uint256 _0xeb6a25)
    _0xae33a9()
    public
    {
        _0x3eb5dd = _0xeb6a25;

        emit BetLimitChanged(_0x3eb5dd);
    }

    function AdjustDifficulty(uint256 _0xeb6a25)
    _0xae33a9()
    public
    {
        difficulty = _0xeb6a25;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function _0x5ce443()
    _0xc95bcd()
    _0xdd23e5()
    payable
    public
    {
        //You have to send exactly 0.01 ETH.
        require(msg.value == _0x3eb5dd);

        //log the wager and timestamp(block number)
        _0x0a6bc9[msg.sender] = block.number;
        _0xfc21d7[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function _0x9324c2()
    _0xc95bcd()
    _0xdd23e5()
    _0x631a67()
    public
    {
        uint256 _0xff0fb8 = _0x0a6bc9[msg.sender];
        if(_0xff0fb8 < block.number)
        {
            _0x0a6bc9[msg.sender] = 0;
            _0xfc21d7[msg.sender] = 0;

            uint256 _0x7836bc = uint256(_0x0bc962(abi._0xb334ee(blockhash(_0xff0fb8),  msg.sender)))%difficulty +1;

            if(_0x7836bc == difficulty / 2)
            {
                _0x785fce(msg.sender);
            }
            else
            {
                //player loses
                _0x1ffe49(_0x3eb5dd / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function _0x79d7e5()
    _0xc95bcd()
    public
    payable
    {
        _0x5ad725(msg.value);
    }

    function _0x785fce(address _0x7f808f)
    internal
    {
        uint256 _0xcc86c2 = address(this).balance / 2;

        _0x7f808f.transfer(_0xcc86c2);
        emit Win(_0xcc86c2, _0x7f808f);
    }

    function _0x5ad725(uint256 _0xeb6a25)
    internal
    {
        _0x5b3520.call.value(_0xeb6a25)(bytes4(_0x0bc962("donate()")));
        _0x482b47 += _0xeb6a25;
        emit Donate(_0xeb6a25, _0x5b3520, msg.sender);
    }

    function _0x1ffe49(uint256 _0xeb6a25)
    internal
    {
        _0x5b3520.call.value(_0xeb6a25)(bytes4(_0x0bc962("donate()")));
        _0x482b47 += _0xeb6a25;
        emit Lose(_0xeb6a25, msg.sender);
    }

    function _0xb3a698()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function _0x4ec0ee()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function _0x33a06d()
    public
    view
    returns (uint256)
    {
        return _0x3eb5dd;
    }

    function _0x2e5095(address _0xd14bf6)
    public
    view
    returns (bool)
    {
        if(_0xfc21d7[_0xd14bf6] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function _0x1ad8e6()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function _0x07bc4e(address _0x310446, address _0xa7c731, uint _0x40ba64)
    public
    _0xae33a9()
    returns (bool _0x8429e9)
    {
        return ERC20Interface(_0x310446).transfer(_0xa7c731, _0x40ba64);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address _0xfc4483, uint256 _0x40ba64) public returns (bool _0x8429e9);
}