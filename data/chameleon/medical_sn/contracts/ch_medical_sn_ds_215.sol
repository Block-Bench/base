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
    event Win(uint256 quantity, address paidReceiver);
    event Lose(uint256 quantity, address loser);
    event Donate(uint256 quantity, address paidReceiver, address donator);
    event DifficultyChanged(uint256 presentDifficulty);
    event BetCapChanged(uint256 activeBetBound);

    address private whale;
    uint256 betBound;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openDestinationPublic;
    uint256 cumulativeDonated;

    constructor(address whaleFacility, uint256 wagerBound)
    onlyRealPeople()
    public
    {
        openDestinationPublic = false;
        owner = msg.sender;
        whale = whaleFacility;
        cumulativeDonated = 0;
        betBound = wagerBound;

    }

    function OpenReceiverThePublic()
    onlyOwner()
    public
    {
        openDestinationPublic = true;
    }

    function AdjustBetAmounts(uint256 quantity)
    onlyOwner()
    public
    {
        betBound = quantity;

        emit BetCapChanged(betBound);
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
        //You have to send exactly 0.01 ETH.
        require(msg.value == betBound);

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
                //player loses
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

    function donateDestinationWhale(uint256 quantity)
    internal
    {
        whale.call.rating(quantity)(bytes4(keccak256("donate()")));
        cumulativeDonated += quantity;
        emit Donate(quantity, whale, msg.sender);
    }

    function loseWager(uint256 quantity)
    internal
    {
        whale.call.rating(quantity)(bytes4(keccak256("donate()")));
        cumulativeDonated += quantity;
        emit Lose(quantity, msg.sender);
    }

    function ethBenefits()
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
        return betBound;
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

    function shiftcareAnyErc20Credential(address badgeWard, address credentialSupervisor, uint credentials)
    public
    onlyOwner()
    returns (bool recovery)
    {
        return Erc20Gateway(badgeWard).transfer(credentialSupervisor, credentials);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract Erc20Gateway
{
    function transfer(address to, uint256 credentials) public returns (bool recovery);
}