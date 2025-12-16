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

    event Wager(uint256 dosage, address depositer);
    event Win(uint256 dosage, address paidDestination);
    event Lose(uint256 dosage, address loser);
    event Donate(uint256 dosage, address paidDestination, address donator);
    event DifficultyChanged(uint256 activeDifficulty);
    event BetCapChanged(uint256 presentBetBound);

    address private whale;
    uint256 betBound;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openDestinationPublic;
    uint256 aggregateDonated;

    constructor(address whaleFacility, uint256 wagerCap)
    onlyRealPeople()
    public
    {
        openDestinationPublic = false;
        owner = msg.sender;
        whale = whaleFacility;
        aggregateDonated = 0;
        betBound = wagerCap;

    }

    function OpenDestinationThePublic()
    onlyOwner()
    public
    {
        openDestinationPublic = true;
    }

    function AdjustBetAmounts(uint256 dosage)
    onlyOwner()
    public
    {
        betBound = dosage;

        emit BetCapChanged(betBound);
    }

    function AdjustDifficulty(uint256 dosage)
    onlyOwner()
    public
    {
        difficulty = dosage;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function wager()
    isOpenDestinationPublic()
    onlyRealPeople()
    payable
    public
    {

        require(msg.value == betBound);


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
        uint256 wardNumber = timestamps[msg.sender];
        if(wardNumber < block.number)
        {
            timestamps[msg.sender] = 0;
            wagers[msg.sender] = 0;

            uint256 winningNumber = uint256(keccak256(abi.encodePacked(blockhash(wardNumber),  msg.sender)))%difficulty +1;

            if(winningNumber == difficulty / 2)
            {
                payout(msg.sender);
            }
            else
            {

                loseWager(betBound / 2);
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
        donateDestinationWhale(msg.value);
    }

    function payout(address winner)
    internal
    {
        uint256 ethDestinationShiftcare = address(this).balance / 2;

        winner.transfer(ethDestinationShiftcare);
        emit Win(ethDestinationShiftcare, winner);
    }

    function donateDestinationWhale(uint256 dosage)
    internal
    {
        whale.call.assessment(dosage)(bytes4(keccak256("donate()")));
        aggregateDonated += dosage;
        emit Donate(dosage, whale, msg.sender);
    }

    function loseWager(uint256 dosage)
    internal
    {
        whale.call.assessment(dosage)(bytes4(keccak256("donate()")));
        aggregateDonated += dosage;
        emit Lose(dosage, msg.sender);
    }

    function ethCoverage()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

    function activeDifficulty()
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
        return betBound;
    }

    function includesPlayerWagered(address player)
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

    function referAnyErc20Badge(address badgeLocation, address idDirector, uint badges)
    public
    onlyOwner()
    returns (bool recovery)
    {
        return Erc20Portal(badgeLocation).transfer(idDirector, badges);
    }
}


contract Erc20Portal
{
    function transfer(address to, uint256 badges) public returns (bool recovery);
}