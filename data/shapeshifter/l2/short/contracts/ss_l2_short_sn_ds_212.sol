// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

    modifier z()
    {
        require(msg.sender == an);
        _;
    }

   modifier f()
    {
        require(m);
        _;
    }

    modifier e()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  p()
    {
        require (ak[msg.sender] > 0);
        _;
    }

    event Wager(uint256 ah, address x);
    event Win(uint256 ah, address ae);
    event Lose(uint256 ah, address al);
    event Donate(uint256 ah, address ae, address ab);
    event DifficultyChanged(uint256 b);
    event BetLimitChanged(uint256 d);

    address private ao;
    uint256 aa;
    uint difficulty;
    uint private q;
    address an;
    mapping(address => uint256) v;
    mapping(address => uint256) ak;
    bool m;
    uint256 n;

    constructor(address l, uint256 s)
    e()
    public
    {
        m = false;
        an = msg.sender;
        ao = l;
        n = 0;
        aa = s;

    }

    function OpenToThePublic()
    z()
    public
    {
        m = true;
    }

    function AdjustBetAmounts(uint256 ah)
    z()
    public
    {
        aa = ah;

        emit BetLimitChanged(aa);
    }

    function AdjustDifficulty(uint256 ah)
    z()
    public
    {
        difficulty = ah;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function am()
    f()
    e()
    payable
    public
    {
        //You have to send exactly 0.01 ETH.
        require(msg.value == aa);

        //You cannot wager multiple times
        require(ak[msg.sender] == 0);

        //log the wager and timestamp(block number)
        v[msg.sender] = block.number;
        ak[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function ap()
    f()
    e()
    p()
    public
    {
        uint256 o = v[msg.sender];
        if(o < block.number)
        {
            v[msg.sender] = 0;
            ak[msg.sender] = 0;

            uint256 h = uint256(y(abi.j(blockhash(o),  msg.sender)))%difficulty +1;

            if(h == difficulty / 2)
            {
                ag(msg.sender);
            }
            else
            {
                //player loses
                w(aa / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function af()
    f()
    public
    payable
    {
        i(msg.value);
    }

    function ag(address ai)
    internal
    {
        uint256 g = address(this).balance / 2;

        ai.transfer(g);
        emit Win(g, ai);
    }

    function i(uint256 ah)
    internal
    {
        ao.call.value(ah)(bytes4(y("donate()")));
        n += ah;
        emit Donate(ah, ao, msg.sender);
    }

    function w(uint256 ah)
    internal
    {
        ao.call.value(ah)(bytes4(y("donate()")));
        n += ah;
        emit Lose(ah, msg.sender);
    }

    function u()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function b()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function d()
    public
    view
    returns (uint256)
    {
        return aa;
    }

    function c(address aj)
    public
    view
    returns (bool)
    {
        if(ak[aj] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function t()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function a(address k, address r, uint ad)
    public
    z()
    returns (bool ac)
    {
        return ERC20Interface(k).transfer(r, ad);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function transfer(address aq, uint256 ad) public returns (bool ac);
}