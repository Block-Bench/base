pragma solidity ^0.4.24;

contract PoCGame
{

    modifier x()
    {
        require(msg.sender == am);
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

    event Wager(uint256 af, address y);
    event Win(uint256 af, address aj);
    event Lose(uint256 af, address ao);
    event Donate(uint256 af, address aj, address ac);
    event DifficultyChanged(uint256 b);
    event BetLimitChanged(uint256 d);

    address private al;
    uint256 aa;
    uint difficulty;
    uint private v;
    address am;
    mapping(address => uint256) t;
    mapping(address => uint256) ak;
    bool m;
    uint256 k;

    constructor(address n, uint256 s)
    e()
    public
    {
        m = false;
        am = msg.sender;
        al = n;
        k = 0;
        aa = s;

    }

    function OpenToThePublic()
    x()
    public
    {
        m = true;
    }

    function AdjustBetAmounts(uint256 af)
    x()
    public
    {
        aa = af;

        emit BetLimitChanged(aa);
    }

    function AdjustDifficulty(uint256 af)
    x()
    public
    {
        difficulty = af;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function an()
    f()
    e()
    payable
    public
    {

        require(msg.value == aa);


        require(ak[msg.sender] == 0);


        t[msg.sender] = block.number;
        ak[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function ap()
    f()
    e()
    p()
    public
    {
        uint256 o = t[msg.sender];
        if(o < block.number)
        {
            t[msg.sender] = 0;
            ak[msg.sender] = 0;

            uint256 h = uint256(z(abi.l(blockhash(o),  msg.sender)))%difficulty +1;

            if(h == difficulty / 2)
            {
                ae(msg.sender);
            }
            else
            {

                w(aa / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function ad()
    f()
    public
    payable
    {
        i(msg.value);
    }

    function ae(address ag)
    internal
    {
        uint256 g = address(this).balance / 2;

        ag.transfer(g);
        emit Win(g, ag);
    }

    function i(uint256 af)
    internal
    {
        al.call.value(af)(bytes4(z("donate()")));
        k += af;
        emit Donate(af, al, msg.sender);
    }

    function w(uint256 af)
    internal
    {
        al.call.value(af)(bytes4(z("donate()")));
        k += af;
        emit Lose(af, msg.sender);
    }

    function r()
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

    function c(address ai)
    public
    view
    returns (bool)
    {
        if(ak[ai] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function q()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

    function a(address j, address u, uint ah)
    public
    x()
    returns (bool ab)
    {
        return ERC20Interface(j).transfer(u, ah);
    }
}


contract ERC20Interface
{
    function transfer(address aq, uint256 ah) public returns (bool ab);
}