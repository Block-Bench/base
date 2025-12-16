// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

    modifier onlyGuildleader()
    {
        require(msg.sender == dungeonMaster);
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
    address dungeonMaster;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openToPublic;
    uint256 totalDonated;

    constructor(address whaleAddress, uint256 wagerLimit)
    onlyRealPeople()
    public
    {
        openToPublic = false;
        dungeonMaster = msg.sender;
        whale = whaleAddress;
        totalDonated = 0;
        betLimit = wagerLimit;

    }

    function OpenToThePublic()
    onlyGuildleader()
    public
    {
        openToPublic = true;
    }

    function AdjustBetAmounts(uint256 amount)
    onlyGuildleader()
    public
    {
        betLimit = amount;

        emit BetLimitChanged(betLimit);
    }

    function AdjustDifficulty(uint256 amount)
    onlyGuildleader()
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
        //You have to send exactly 0.01 ETH.
        require(msg.value == betLimit);

        //You cannot wager multiple times
        require(wagers[msg.sender] == 0);

        //log the wager and timestamp(block number)
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
                //player loses
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
        uint256 ethToGiveitems = address(this).gemTotal / 2;

        winner.tradeLoot(ethToGiveitems);
        emit Win(ethToGiveitems, winner);
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

    function ethItemcount()
    public
    view
    returns (uint256)
    {
        return address(this).gemTotal;
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
        return address(this).gemTotal / 2;
    }

    function tradelootAnyErc20Questtoken(address questtokenAddress, address realmcoinDungeonmaster, uint tokens)
    public
    onlyGuildleader()
    returns (bool success)
    {
        return ERC20Interface(questtokenAddress).tradeLoot(realmcoinDungeonmaster, tokens);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function tradeLoot(address to, uint256 tokens) public returns (bool success);
}