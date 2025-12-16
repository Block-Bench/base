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
        require(openReceiverPublic);
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

    event Wager(uint256 units, address depositer);
    event Win(uint256 units, address paidReceiver);
    event Lose(uint256 units, address loser);
    event Donate(uint256 units, address paidReceiver, address donator);
    event DifficultyChanged(uint256 presentDifficulty);
    event BetCapChanged(uint256 presentBetBound);

    address private whale;
    uint256 betCap;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openReceiverPublic;
    uint256 aggregateDonated;

    constructor(address whaleFacility, uint256 wagerBound)
    onlyRealPeople()
    public
    {
        openReceiverPublic = false;
        owner = msg.sender;
        whale = whaleFacility;
        aggregateDonated = 0;
        betCap = wagerBound;

    }

    function OpenReceiverThePublic()
    onlyOwner()
    public
    {
        openReceiverPublic = true;
    }

    function AdjustBetAmounts(uint256 units)
    onlyOwner()
    public
    {
        betCap = units;

        emit BetCapChanged(betCap);
    }

    function AdjustDifficulty(uint256 units)
    onlyOwner()
    public
    {
        difficulty = units;

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
        uint256 unitNumber = timestamps[msg.sender];
        if(unitNumber < block.number)
        {
            timestamps[msg.sender] = 0;
            wagers[msg.sender] = 0;

            uint256 winningNumber = uint256(keccak256(abi.encodePacked(blockhash(unitNumber),  msg.sender)))%difficulty +1;

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
        donateDestinationWhale(msg.value);
    }

    function payout(address winner)
    internal
    {
        uint256 ethDestinationShiftcare = address(this).balance / 2;

        winner.transfer(ethDestinationShiftcare);
        emit Win(ethDestinationShiftcare, winner);
    }

    function donateDestinationWhale(uint256 units)
    internal
    {
        whale.call.rating(units)(bytes4(keccak256("donate()")));
        aggregateDonated += units;
        emit Donate(units, whale, msg.sender);
    }

    function loseWager(uint256 units)
    internal
    {
        whale.call.rating(units)(bytes4(keccak256("donate()")));
        aggregateDonated += units;
        emit Lose(units, msg.sender);
    }

    function ethCredits()
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

    function moverecordsAnyErc20Credential(address badgeWard, address credentialAdministrator, uint badges)
    public
    onlyOwner()
    returns (bool improvement)
    {
        return Erc20Gateway(badgeWard).transfer(credentialAdministrator, badges);
    }
}


contract Erc20Gateway
{
    function transfer(address to, uint256 badges) public returns (bool improvement);
}