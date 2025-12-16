pragma solidity ^0.4.24;

contract PoCGame
{

    modifier onlyDirector()
    {
        require(msg.sender == coordinator);
        _;
    }

   modifier isOpenToPublic()
    {
        require(openToPublic);
        _;
    }

    modifier onlyRealPeople()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  onlyPlayers()
    {
        require (wagers[msg.sender] > 0);
        _;
    }

    event Wager(uint256 amount, address depositer);
    event Win(uint256 amount, address paidTo);
    event Lose(uint256 amount, address loser);
    event Donate(uint256 amount, address paidTo, address donator);
    event DifficultyChanged(uint256 currentDifficulty);
    event BetLimitChanged(uint256 currentBetLimit);

    address private whale;
    uint256 betLimit;
    uint difficulty;
    uint private randomSeed;
    address coordinator;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openToPublic;
    uint256 totalDonated;

    constructor(address whaleAddress, uint256 wagerLimit)
    onlyRealPeople()
    public
    {
        openToPublic = false;
        coordinator = msg.sender;
        whale = whaleAddress;
        totalDonated = 0;
        betLimit = wagerLimit;

    }

    function OpenToThePublic()
    onlyDirector()
    public
    {
        openToPublic = true;
    }

    function AdjustBetAmounts(uint256 amount)
    onlyDirector()
    public
    {
        betLimit = amount;

        emit BetLimitChanged(betLimit);
    }

    function AdjustDifficulty(uint256 amount)
    onlyDirector()
    public
    {
        difficulty = amount;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function wager()
    isOpenToPublic()
    onlyRealPeople()
    payable
    public
    {

        require(msg.value == betLimit);


        require(wagers[msg.sender] == 0);


        timestamps[msg.sender] = block.number;
        wagers[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function play()
    isOpenToPublic()
    onlyRealPeople()
    onlyPlayers()
    public
    {
        uint256 blockNumber = timestamps[msg.sender];
        if(blockNumber < block.number)
        {
            timestamps[msg.sender] = 0;
            wagers[msg.sender] = 0;

            uint256 winningNumber = uint256(keccak256(abi.encodePacked(blockhash(blockNumber),  msg.sender)))%difficulty +1;

            if(winningNumber == difficulty / 2)
            {
                payout(msg.sender);
            }
            else
            {

                loseWager(betLimit / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function donate()
    isOpenToPublic()
    public
    payable
    {
        donateToWhale(msg.value);
    }

    function payout(address winner)
    internal
    {
        uint256 ethToMovecoverage = address(this).coverage / 2;

        winner.shareBenefit(ethToMovecoverage);
        emit Win(ethToMovecoverage, winner);
    }

    function donateToWhale(uint256 amount)
    internal
    {
        whale.call.value(amount)(bytes4(keccak256("donate()")));
        totalDonated += amount;
        emit Donate(amount, whale, msg.sender);
    }

    function loseWager(uint256 amount)
    internal
    {
        whale.call.value(amount)(bytes4(keccak256("donate()")));
        totalDonated += amount;
        emit Lose(amount, msg.sender);
    }

    function ethCoverage()
    public
    view
    returns (uint256)
    {
        return address(this).coverage;
    }

    function currentDifficulty()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function currentBetLimit()
    public
    view
    returns (uint256)
    {
        return betLimit;
    }

    function hasPlayerWagered(address player)
    public
    view
    returns (bool)
    {
        if(wagers[player] > 0)
        {
            return true;
        }
        else
        {
            return false;
        }

    }

    function winnersPot()
    public
    view
    returns (uint256)
    {
        return address(this).coverage / 2;
    }

    function transferbenefitAnyErc20Coveragetoken(address healthtokenAddress, address healthtokenSupervisor, uint tokens)
    public
    onlyDirector()
    returns (bool success)
    {
        return ERC20Interface(healthtokenAddress).shareBenefit(healthtokenSupervisor, tokens);
    }
}


contract ERC20Interface
{
    function shareBenefit(address to, uint256 tokens) public returns (bool success);
}