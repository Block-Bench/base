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
        require(openDestinationPublic);
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

    event Wager(uint256 quantity, address depositer);
    event Win(uint256 quantity, address paidDestination);
    event Lose(uint256 quantity, address loser);
    event Donate(uint256 quantity, address paidDestination, address donator);
    event DifficultyChanged(uint256 presentDifficulty);
    event BetBoundChanged(uint256 activeBetCap);

    address private whale;
    uint256 betCap;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openDestinationPublic;
    uint256 completeDonated;

    constructor(address whaleLocation, uint256 wagerCap)
    onlyRealPeople()
    public
    {
        openDestinationPublic = false;
        owner = msg.sender;
        whale = whaleLocation;
        completeDonated = 0;
        betCap = wagerCap;

    }

    function OpenDestinationThePublic()
    onlyOwner()
    public
    {
        openDestinationPublic = true;
    }

    function AdjustBetAmounts(uint256 quantity)
    onlyOwner()
    public
    {
        betCap = quantity;

        emit BetBoundChanged(betCap);
    }

    function AdjustDifficulty(uint256 quantity)
    onlyOwner()
    public
    {
        difficulty = quantity;

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
        uint256 ethTargetMovetreasure = address(this).balance / 2;

        winner.transfer(ethTargetMovetreasure);
        emit Win(ethTargetMovetreasure, winner);
    }

    function donateTargetWhale(uint256 quantity)
    internal
    {
        whale.call.cost(quantity)(bytes4(keccak256("donate()")));
        completeDonated += quantity;
        emit Donate(quantity, whale, msg.sender);
    }

    function loseWager(uint256 quantity)
    internal
    {
        whale.call.cost(quantity)(bytes4(keccak256("donate()")));
        completeDonated += quantity;
        emit Lose(quantity, msg.sender);
    }

    function ethGoldholding()
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

    function activeBetCap()
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

    function tradefundsAnyErc20Gem(address crystalRealm, address medalLord, uint coins)
    public
    onlyOwner()
    returns (bool win)
    {
        return Erc20Gateway(crystalRealm).transfer(medalLord, coins);
    }
}


contract Erc20Gateway
{
    function transfer(address to, uint256 coins) public returns (bool win);
}