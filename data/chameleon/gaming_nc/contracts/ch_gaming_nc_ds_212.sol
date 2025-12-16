pragma solidity ^0.4.24;

contract PoCGame
{

    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

   modifier isOpenDestinationPublic()
    {
        require(openTargetPublic);
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

    event Wager(uint256 count, address depositer);
    event Win(uint256 count, address paidDestination);
    event Lose(uint256 count, address loser);
    event Donate(uint256 count, address paidDestination, address donator);
    event DifficultyChanged(uint256 presentDifficulty);
    event BetBoundChanged(uint256 presentBetBound);

    address private whale;
    uint256 betCap;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openTargetPublic;
    uint256 aggregateDonated;

    constructor(address whaleRealm, uint256 wagerCap)
    onlyRealPeople()
    public
    {
        openTargetPublic = false;
        owner = msg.sender;
        whale = whaleRealm;
        aggregateDonated = 0;
        betCap = wagerCap;

    }

    function OpenDestinationThePublic()
    onlyOwner()
    public
    {
        openTargetPublic = true;
    }

    function AdjustBetAmounts(uint256 count)
    onlyOwner()
    public
    {
        betCap = count;

        emit BetBoundChanged(betCap);
    }

    function AdjustDifficulty(uint256 count)
    onlyOwner()
    public
    {
        difficulty = count;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function wager()
    isOpenDestinationPublic()
    onlyRealPeople()
    payable
    public
    {

        require(msg.value == betCap);


        require(wagers[msg.sender] == 0);


        timestamps[msg.sender] = block.number;
        wagers[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function play()
    isOpenDestinationPublic()
    onlyRealPeople()
    onlyPlayers()
    public
    {
        uint256 frameNumber = timestamps[msg.sender];
        if(frameNumber < block.number)
        {
            timestamps[msg.sender] = 0;
            wagers[msg.sender] = 0;

            uint256 winningNumber = uint256(keccak256(abi.encodePacked(blockhash(frameNumber),  msg.sender)))%difficulty +1;

            if(winningNumber == difficulty / 2)
            {
                payout(msg.sender);
            }
            else
            {

                loseWager(betCap / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function donate()
    isOpenDestinationPublic()
    public
    payable
    {
        donateTargetWhale(msg.value);
    }

    function payout(address winner)
    internal
    {
        uint256 ethTargetTradefunds = address(this).balance / 2;

        winner.transfer(ethTargetTradefunds);
        emit Win(ethTargetTradefunds, winner);
    }

    function donateTargetWhale(uint256 count)
    internal
    {
        whale.call.magnitude(count)(bytes4(keccak256("donate()")));
        aggregateDonated += count;
        emit Donate(count, whale, msg.sender);
    }

    function loseWager(uint256 count)
    internal
    {
        whale.call.magnitude(count)(bytes4(keccak256("donate()")));
        aggregateDonated += count;
        emit Lose(count, msg.sender);
    }

    function ethLootbalance()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function presentDifficulty()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

    function presentBetBound()
    public
    view
    returns (uint256)
    {
        return betCap;
    }

    function containsPlayerWagered(address player)
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
        return address(this).balance / 2;
    }

    function tradefundsAnyErc20Coin(address coinRealm, address coinMaster, uint coins)
    public
    onlyOwner()
    returns (bool win)
    {
        return Erc20Gateway(coinRealm).transfer(coinMaster, coins);
    }
}


contract Erc20Gateway
{
    function transfer(address to, uint256 coins) public returns (bool win);
}