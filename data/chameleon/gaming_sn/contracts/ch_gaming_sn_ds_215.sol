// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

   modifier isOpenTargetPublic()
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

    event Wager(uint256 measure, address depositer);
    event Win(uint256 measure, address paidDestination);
    event Lose(uint256 measure, address loser);
    event Donate(uint256 measure, address paidDestination, address donator);
    event DifficultyChanged(uint256 presentDifficulty);
    event BetBoundChanged(uint256 activeBetBound);

    address private whale;
    uint256 betCap;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openDestinationPublic;
    uint256 aggregateDonated;

    constructor(address whaleZone, uint256 wagerBound)
    onlyRealPeople()
    public
    {
        openDestinationPublic = false;
        owner = msg.sender;
        whale = whaleZone;
        aggregateDonated = 0;
        betCap = wagerBound;

    }

    function OpenDestinationThePublic()
    onlyOwner()
    public
    {
        openDestinationPublic = true;
    }

    function AdjustBetAmounts(uint256 measure)
    onlyOwner()
    public
    {
        betCap = measure;

        emit BetBoundChanged(betCap);
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
    isOpenTargetPublic()
    onlyRealPeople()
    payable
    public
    {
        //You have to send exactly 0.01 ETH.
        require(msg.value == betCap);

        //log the wager and timestamp(block number)
        timestamps[msg.sender] = block.number;
        wagers[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function play()
    isOpenTargetPublic()
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
    isOpenTargetPublic()
    public
    payable
    {
        donateDestinationWhale(msg.value);
    }

    function payout(address winner)
    internal
    {
        uint256 ethTargetSendloot = address(this).balance / 2;

        winner.transfer(ethTargetSendloot);
        emit Win(ethTargetSendloot, winner);
    }

    function donateDestinationWhale(uint256 measure)
    internal
    {
        whale.call.cost(measure)(bytes4(keccak256("donate()")));
        aggregateDonated += measure;
        emit Donate(measure, whale, msg.sender);
    }

    function loseWager(uint256 measure)
    internal
    {
        whale.call.cost(measure)(bytes4(keccak256("donate()")));
        aggregateDonated += measure;
        emit Lose(measure, msg.sender);
    }

    function ethRewardlevel()
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

    function activeBetBound()
    public
    view
    returns (uint256)
    {
        return betCap;
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

    function tradefundsAnyErc20Coin(address crystalZone, address crystalMaster, uint crystals)
    public
    onlyOwner()
    returns (bool victory)
    {
        return Erc20Gateway(crystalZone).transfer(crystalMaster, crystals);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract Erc20Gateway
{
    function transfer(address to, uint256 crystals) public returns (bool victory);
}