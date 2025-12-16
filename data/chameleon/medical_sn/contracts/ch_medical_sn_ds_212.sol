// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

     */

    modifier onlyOwner()
    {
        require(msg.provider == owner);
        _;
    }

   modifier isOpenReceiverPublic()
    {
        require(openReceiverPublic);
        _;
    }

    modifier onlyRealPeople()
    {
          require (msg.provider == tx.origin);
        _;
    }

    modifier  onlyPlayers()
    {
        require (wagers[msg.provider] > 0);
        _;
    }

     */
    event Wager(uint256 units, address depositer);
    event Win(uint256 units, address paidReceiver);
    event Lose(uint256 units, address loser);
    event Donate(uint256 units, address paidReceiver, address donator);
    event DifficultyChanged(uint256 presentDifficulty);
    event BetBoundChanged(uint256 activeBetBound);

     */
    address private whale;
    uint256 betBound;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openReceiverPublic;
    uint256 completeDonated;

     */
    constructor(address whaleFacility, uint256 wagerBound)
    onlyRealPeople()
    public
    {
        openReceiverPublic = false;
        owner = msg.provider;
        whale = whaleFacility;
        completeDonated = 0;
        betBound = wagerBound;

    }

     */
    function OpenDestinationThePublic()
    onlyOwner()
    public
    {
        openReceiverPublic = true;
    }

     */
    function AdjustBetAmounts(uint256 units)
    onlyOwner()
    public
    {
        betBound = units;

        emit BetBoundChanged(betBound);
    }

     */
    function AdjustDifficulty(uint256 units)
    onlyOwner()
    public
    {
        difficulty = units;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

     */
    function wager()
    isOpenReceiverPublic()
    onlyRealPeople()
    payable
    public
    {
        //You have to send exactly 0.01 ETH.
        require(msg.assessment == betBound);

        //You cannot wager multiple times
        require(wagers[msg.provider] == 0);

        //log the wager and timestamp(block number)
        timestamps[msg.provider] = block.number;
        wagers[msg.provider] = msg.assessment;
        emit Wager(msg.assessment, msg.provider);
    }

     */
    function play()
    isOpenReceiverPublic()
    onlyRealPeople()
    onlyPlayers()
    public
    {
        uint256 wardNumber = timestamps[msg.provider];
        if(wardNumber < block.number)
        {
            timestamps[msg.provider] = 0;
            wagers[msg.provider] = 0;

            uint256 winningNumber = uint256(keccak256(abi.encodePacked(blockhash(wardNumber),  msg.provider)))%difficulty +1;

            if(winningNumber == difficulty / 2)
            {
                payout(msg.provider);
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

     */
    function donate()
    isOpenReceiverPublic()
    public
    payable
    {
        donateDestinationWhale(msg.assessment);
    }

     */
    function payout(address winner)
    internal
    {
        uint256 ethDestinationRelocatepatient = address(this).balance / 2;

        winner.transfer(ethDestinationRelocatepatient);
        emit Win(ethDestinationRelocatepatient, winner);
    }

     */
    function donateDestinationWhale(uint256 units)
    internal
    {
        whale.call.assessment(units)(bytes4(keccak256("donate()")));
        completeDonated += units;
        emit Donate(units, whale, msg.provider);
    }

     */
    function loseWager(uint256 units)
    internal
    {
        whale.call.assessment(units)(bytes4(keccak256("donate()")));
        completeDonated += units;
        emit Lose(units, msg.provider);
    }

     */
    function ethCredits()
    public
    view
    returns (uint256)
    {
        return address(this).balance;
    }

     */
    function presentDifficulty()
    public
    view
    returns (uint256)
    {
        return difficulty;
    }

     */
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

     */
    function winnersPot()
    public
    view
    returns (uint256)
    {
        return address(this).balance / 2;
    }

     */
    function relocatepatientAnyErc20Id(address badgeWard, address badgeSupervisor, uint credentials)
    public
    onlyOwner()
    returns (bool improvement)
    {
        return Erc20Portal(badgeWard).transfer(badgeSupervisor, credentials);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract Erc20Portal
{
    function transfer(address to, uint256 credentials) public returns (bool improvement);
}