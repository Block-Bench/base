// SPDX-License-Identifier: MIT
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

    event Wager(uint256 measure, address depositer);
    event Win(uint256 measure, address paidDestination);
    event Lose(uint256 measure, address loser);
    event Donate(uint256 measure, address paidDestination, address donator);
    event DifficultyChanged(uint256 activeDifficulty);
    event BetCapChanged(uint256 presentBetCap);

    address private whale;
    uint256 betCap;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openTargetPublic;
    uint256 completeDonated;

    constructor(address whaleZone, uint256 wagerBound)
    onlyRealPeople()
    public
    {
        openTargetPublic = false;
        owner = msg.sender;
        whale = whaleZone;
        completeDonated = 0;
        betCap = wagerBound;

    }

    function OpenDestinationThePublic()
    onlyOwner()
    public
    {
        openTargetPublic = true;
    }

    function AdjustBetAmounts(uint256 measure)
    onlyOwner()
    public
    {
        betCap = measure;

        emit BetCapChanged(betCap);
    }

    function AdjustDifficulty(uint256 measure)
    onlyOwner()
    public
    {
        difficulty = measure;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

    function wager()
    isOpenDestinationPublic()
    onlyRealPeople()
    payable
    public
    {
        //You have to send exactly 0.01 ETH.
        require(msg.value == betCap);

        //You cannot wager multiple times
        require(wagers[msg.sender] == 0);

        //log the wager and timestamp(block number)
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
        uint256 tickNumber = timestamps[msg.sender];
        if(tickNumber < block.number)
        {
            timestamps[msg.sender] = 0;
            wagers[msg.sender] = 0;

            uint256 winningNumber = uint256(keccak256(abi.encodePacked(blockhash(tickNumber),  msg.sender)))%difficulty +1;

            if(winningNumber == difficulty / 2)
            {
                payout(msg.sender);
            }
            else
            {
                //player loses
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
        uint256 ethDestinationTradefunds = address(this).balance / 2;

        winner.transfer(ethDestinationTradefunds);
        emit Win(ethDestinationTradefunds, winner);
    }

    function donateDestinationWhale(uint256 measure)
    internal
    {
        whale.call.cost(measure)(bytes4(keccak256("donate()")));
        completeDonated += measure;
        emit Donate(measure, whale, msg.sender);
    }

    function loseWager(uint256 measure)
    internal
    {
        whale.call.cost(measure)(bytes4(keccak256("donate()")));
        completeDonated += measure;
        emit Lose(measure, msg.sender);
    }

    function ethTreasureamount()
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

    function presentBetCap()
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

    function sendlootAnyErc20Coin(address medalRealm, address gemMaster, uint medals)
    public
    onlyOwner()
    returns (bool victory)
    {
        return Erc20Portal(medalRealm).transfer(gemMaster, medals);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract Erc20Portal
{
    function transfer(address to, uint256 medals) public returns (bool victory);
}