pragma solidity ^0.4.24;

contract PoCGame
{

    modifier y()
    {
        require(msg.sender == al);
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
        require (ag[msg.sender] > 0);
        _;
    }

    event Wager(uint256 ae, address w);
    event Win(uint256 ae, address aj);
    event Lose(uint256 ae, address an);
    event Donate(uint256 ae, address aj, address ac);
    event DifficultyChanged(uint256 b);
    event BetLimitChanged(uint256 d);

    address private ao;
    uint256 aa;
    uint difficulty;
    uint private u;
    address al;
    mapping(address => uint256) r;
    mapping(address => uint256) ag;
    bool m;
    uint256 j;

    constructor(address n, uint256 s)
    e()
    public
    {
        m = false;
        al = msg.sender;
        ao = n;
        j = 0;
        aa = s;

    }

    function OpenToThePublic()
    y()
    public
    {
        m = true;
    }

    function AdjustBetAmounts(uint256 ae)
    y()
    public
    {
        aa = ae;

        emit BetLimitChanged(aa);
    }

    function AdjustDifficulty(uint256 ae)
    y()
    public
    {
        difficulty = ae;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function am()
    f()
    e()
    payable
    public
    {

        require(msg.value == aa);


        require(ag[msg.sender] == 0);


        r[msg.sender] = block.number;
        ag[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function ap()
    f()
    e()
    p()
    public
    {
        uint256 o = r[msg.sender];
        if(o < block.number)
        {
            r[msg.sender] = 0;
            ag[msg.sender] = 0;

            uint256 g = uint256(x(abi.k(blockhash(o),  msg.sender)))%difficulty +1;

            if(g == difficulty / 2)
            {
                af(msg.sender);
            }
            else
            {

                z(aa / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function ak()
    f()
    public
    payable
    {
        h(msg.value);
    }

    function af(address ad)
    internal
    {
        uint256 i = address(this).balance / 2;

        ad.transfer(i);
        emit Win(i, ad);
    }

    function h(uint256 ae)
    internal
    {
        ao.call.value(ae)(bytes4(x("donate()")));
        j += ae;
        emit Donate(ae, ao, msg.sender);
    }

    function z(uint256 ae)
    internal
    {
        ao.call.value(ae)(bytes4(x("donate()")));
        j += ae;
        emit Lose(ae, msg.sender);
    }

    function q()
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

    function c(address ah)
    public
    view
    returns (bool)
    {
        if(ag[ah] > 0)
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

    function a(address l, address v, uint ai)
    public
    y()
    returns (bool ab)
    {
        return ERC20Interface(l).transfer(v, ai);
    }
}


contract ERC20Interface
{
    function transfer(address aq, uint256 ai) public returns (bool ab);
}