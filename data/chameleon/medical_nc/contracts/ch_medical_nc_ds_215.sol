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
        require(openReceiverPublic);
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
    event BetBoundChanged(uint256 presentBetCap);

    address private whale;
    uint256 requestLimit;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openReceiverPublic;
    uint256 totalamountDonated;

    constructor(address whaleFacility, uint256 wagerBound)
    onlyRealPeople()
    public
    {
        openReceiverPublic = false;
        owner = msg.sender;
        whale = whaleFacility;
        totalamountDonated = 0;
        requestLimit = wagerBound;

    }

    function OpenDestinationThePublic()
    onlyOwner()
    public
    {
        openReceiverPublic = true;
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

    function presentBetCap()
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

    function transfercareAnyErc20Credential(address credentialFacility, address credentialCustodian, uint credentials)
    public
    onlyOwner()
    returns (bool improvement)
    {
        return Erc20Gateway(credentialFacility).transfer(credentialCustodian, credentials);
    }
}


contract Erc20Gateway
{
    function transfer(address to, uint256 credentials) public returns (bool improvement);
}