// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

   modifier isOpenReceiverPublic()
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

    event Wager(uint256 measure, address depositer);
    event Win(uint256 measure, address paidDestination);
    event Lose(uint256 measure, address loser);
    event Donate(uint256 measure, address paidDestination, address donator);
    event DifficultyChanged(uint256 activeDifficulty);
    event BetBoundChanged(uint256 activeBetCap);

    address private whale;
    uint256 betCap;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openReceiverPublic;
    uint256 completeDonated;

    constructor(address whaleFacility, uint256 wagerCap)
    onlyRealPeople()
    public
    {
        openReceiverPublic = false;
        owner = msg.sender;
        whale = whaleFacility;
        completeDonated = 0;
        betCap = wagerCap;

    }

    function OpenDestinationThePublic()
    onlyOwner()
    public
    {
        openReceiverPublic = true;
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
    isOpenReceiverPublic()
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
    isOpenReceiverPublic()
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
    isOpenReceiverPublic()
    public
    payable
    {
        donateReceiverWhale(msg.value);
    }

    function payout(address winner)
    internal
    {
        uint256 ethReceiverRelocatepatient = address(this).balance / 2;

        winner.transfer(ethReceiverRelocatepatient);
        emit Win(ethReceiverRelocatepatient, winner);
    }

    function donateReceiverWhale(uint256 measure)
    internal
    {
        whale.call.assessment(measure)(bytes4(keccak256("donate()")));
        completeDonated += measure;
        emit Donate(measure, whale, msg.sender);
    }

    function loseWager(uint256 measure)
    internal
    {
        whale.call.assessment(measure)(bytes4(keccak256("donate()")));
        completeDonated += measure;
        emit Lose(measure, msg.sender);
    }

    function ethFunds()
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

    function passcaseAnyErc20Id(address idFacility, address idSupervisor, uint credentials)
    public
    onlyOwner()
    returns (bool improvement)
    {
        return Erc20Gateway(idFacility).transfer(idSupervisor, credentials);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract Erc20Gateway
{
    function transfer(address to, uint256 credentials) public returns (bool improvement);
}