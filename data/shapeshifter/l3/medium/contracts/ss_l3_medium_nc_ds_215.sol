pragma solidity ^0.4.24;

contract PoCGame
{

    modifier _0xb5fb34()
    {
        require(msg.sender == _0x77cd4b);
        _;
    }

   modifier _0x0ac0df()
    {
        require(_0xf9dd2e);
        _;
    }

    modifier _0xb60054()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  _0xd71abb()
    {
        require (_0xa2bbc1[msg.sender] > 0);
        _;
    }

    event Wager(uint256 _0x2554d4, address _0x29a75b);
    event Win(uint256 _0x2554d4, address _0xb1464e);
    event Lose(uint256 _0x2554d4, address _0x16a6f7);
    event Donate(uint256 _0x2554d4, address _0xb1464e, address _0x4630c7);
    event DifficultyChanged(uint256 _0xb9ec2f);
    event BetLimitChanged(uint256 _0xa1fbe2);

    address private _0x519bbb;
    uint256 _0xbc2a9b;
    uint difficulty;
    uint private _0x5696bd;
    address _0x77cd4b;
    mapping(address => uint256) _0x1f75f9;
    mapping(address => uint256) _0xa2bbc1;
    bool _0xf9dd2e;
    uint256 _0x90d489;

    constructor(address _0x58242c, uint256 _0x414290)
    _0xb60054()
    public
    {
        _0xf9dd2e = false;
        _0x77cd4b = msg.sender;
        _0x519bbb = _0x58242c;
        _0x90d489 = 0;
        _0xbc2a9b = _0x414290;

    }

    function OpenToThePublic()
    _0xb5fb34()
    public
    {
        _0xf9dd2e = true;
    }

    function AdjustBetAmounts(uint256 _0x2554d4)
    _0xb5fb34()
    public
    {
        _0xbc2a9b = _0x2554d4;

        emit BetLimitChanged(_0xbc2a9b);
    }

    function AdjustDifficulty(uint256 _0x2554d4)
    _0xb5fb34()
    public
    {
        difficulty = _0x2554d4;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function _0xec5845()
    _0x0ac0df()
    _0xb60054()
    payable
    public
    {

        require(msg.value == _0xbc2a9b);


        _0x1f75f9[msg.sender] = block.number;
        _0xa2bbc1[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function _0x6301e1()
    _0x0ac0df()
    _0xb60054()
    _0xd71abb()
    public
    {
        uint256 _0xff42fe = _0x1f75f9[msg.sender];
        if(_0xff42fe < block.number)
        {
            _0x1f75f9[msg.sender] = 0;
            _0xa2bbc1[msg.sender] = 0;

            uint256 _0xe22252 = uint256(_0x37e392(abi._0x78aa76(blockhash(_0xff42fe),  msg.sender)))%difficulty +1;

            if(_0xe22252 == difficulty / 2)
            {
                _0x81a068(msg.sender);
            }
            else
            {

                _0x481d59(_0xbc2a9b / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function _0xe08b80()
    _0x0ac0df()
    public
    payable
    {
        _0xc41738(msg.value);
    }

    function _0x81a068(address _0x074bee)
    internal
    {
        uint256 _0xc9e80c = address(this).balance / 2;

        _0x074bee.transfer(_0xc9e80c);
        emit Win(_0xc9e80c, _0x074bee);
    }

    function _0xc41738(uint256 _0x2554d4)
    internal
    {
        _0x519bbb.call.value(_0x2554d4)(bytes4(_0x37e392("donate()")));
        _0x90d489 += _0x2554d4;
        emit Donate(_0x2554d4, _0x519bbb, msg.sender);
    }

    function _0x481d59(uint256 _0x2554d4)
    internal
    {
        _0x519bbb.call.value(_0x2554d4)(bytes4(_0x37e392("donate()")));
        _0x90d489 += _0x2554d4;
        emit Lose(_0x2554d4, msg.sender);
    }

    function _0x6f3db0()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function _0xb9ec2f()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function _0xa1fbe2()
    public
    view
    returns (uint256)
    {
        return _0xbc2a9b;
    }

    function _0x1f9c3f(address _0x437b78)
    public
    view
    returns (bool)
    {
        if(_0xa2bbc1[_0x437b78] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function _0xb96dde()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function _0x57c89f(address _0xa289bf, address _0xdd95e8, uint _0xc421e5)
    public
    _0xb5fb34()
    returns (bool _0xea85e4)
    {
        return ERC20Interface(_0xa289bf).transfer(_0xdd95e8, _0xc421e5);
    }
}


contract ERC20Interface
{
    function transfer(address _0x5c844d, uint256 _0xc421e5) public returns (bool _0xea85e4);
}