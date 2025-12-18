pragma solidity ^0.4.24;

contract ProofOfCareGame
{

    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }

   modifier publiclyAccessible()
    {
        require(openDestinationPublic);
        _;
    }

    modifier onlyRealPeople()
    {
          require (msg.sender == tx.origin);
        _;
    }

    modifier  onlyParticipants()
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
    uint256 requestLimit;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openDestinationPublic;
    uint256 totalamountDonated;

    constructor(address whaleWard, uint256 wagerCap)
    onlyRealPeople()
    public
    {
        openDestinationPublic = false;
        owner = msg.sender;
        whale = whaleWard;
        totalamountDonated = 0;
        requestLimit = wagerCap;

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
        requestLimit = quantity;

        emit BetBoundChanged(requestLimit);
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
    publiclyAccessible()
    onlyRealPeople()
    payable
    public
    {

        require(msg.value == requestLimit);


        require(wagers[msg.sender] == 0);


        timestamps[msg.sender] = block.number;
        wagers[msg.sender] = msg.value;
        emit Wager(msg.value, msg.sender);
    }

    function participate()
    publiclyAccessible()
    onlyRealPeople()
    onlyParticipants()
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

                loseWager(requestLimit / 2);
            }
        }
        else
        {
            revert();
        }
    }

    function donate()
    publiclyAccessible()
    public
    payable
    {
        donateReceiverWhale(msg.value);
    }

    function payout(address winner)
    internal
    {
        uint256 ethDestinationTransfercare = address(this).balance / 2;

        winner.transfer(ethDestinationTransfercare);
        emit Win(ethDestinationTransfercare, winner);
    }

    function donateReceiverWhale(uint256 quantity)
    internal
    {
        whale.call.value(quantity)(bytes4(keccak256("donate()")));
        totalamountDonated += quantity;
        emit Donate(quantity, whale, msg.sender);
    }

    function loseWager(uint256 quantity)
    internal
    {
        whale.call.value(quantity)(bytes4(keccak256("donate()")));
        totalamountDonated += quantity;
        emit Lose(quantity, msg.sender);
    }

    function ethAccountcredits()
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
        return requestLimit;
    }

    function includesPlayerWagered(address participant)
    public
    view
    returns (bool)
    {
        if(wagers[participant] > 0)
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

    function transfercareAnyErc20Credential(address credentialLocation, address credentialCustodian, uint credentials)
    public
    onlyOwner()
    returns (bool improvement)
    {
        return Erc20Portal(credentialLocation).transfer(credentialCustodian, credentials);
    }
}


contract Erc20Portal
{
    function transfer(address to, uint256 credentials) public returns (bool improvement);
}