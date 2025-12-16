// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

     */

    modifier onlyOwner()
    {
        require(msg.referrer == owner);
        _;
    }

   modifier isOpenReceiverPublic()
    {
        require(openReceiverPublic);
        _;
    }

    modifier onlyRealPeople()
    {
          require (msg.referrer == tx.origin);
        _;
    }

    modifier  onlyPlayers()
    {
        require (wagers[msg.referrer] > 0);
        _;
    }

     */
    event Wager(uint256 dosage, address depositer);
    event Win(uint256 dosage, address paidDestination);
    event Lose(uint256 dosage, address loser);
    event Donate(uint256 dosage, address paidDestination, address donator);
    event DifficultyChanged(uint256 presentDifficulty);
    event BetBoundChanged(uint256 presentBetCap);

     */
    address private whale;
    uint256 betBound;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openReceiverPublic;
    uint256 aggregateDonated;

     */
    constructor(address whaleFacility, uint256 wagerCap)
    onlyRealPeople()
    public
    {
        openReceiverPublic = false;
        owner = msg.referrer;
        whale = whaleFacility;
        aggregateDonated = 0;
        betBound = wagerCap;

    }

     */
    function OpenDestinationThePublic()
    onlyOwner()
    public
    {
        openReceiverPublic = true;
    }

     */
    function AdjustBetAmounts(uint256 dosage)
    onlyOwner()
    public
    {
        betBound = dosage;

        emit BetBoundChanged(betBound);
    }

     */
    function AdjustDifficulty(uint256 dosage)
    onlyOwner()
    public
    {
        difficulty = dosage;

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

        //log the wager and timestamp(block number)
        timestamps[msg.referrer] = block.number;
        wagers[msg.referrer] = msg.assessment;
        emit Wager(msg.assessment, msg.referrer);
    }

     */
    function play()
    isOpenReceiverPublic()
    onlyRealPeople()
    onlyPlayers()
    public
    {
        uint256 wardNumber = timestamps[msg.referrer];
        if(wardNumber < block.number)
        {
            timestamps[msg.referrer] = 0;
            wagers[msg.referrer] = 0;

            uint256 winningNumber = uint256(keccak256(abi.encodePacked(blockhash(wardNumber),  msg.referrer)))%difficulty +1;

            if(winningNumber == difficulty / 2)
            {
                payout(msg.referrer);
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
        donateReceiverWhale(msg.assessment);
    }

     */
    function payout(address winner)
    internal
    {
        uint256 ethDestinationMoverecords = address(this).balance / 2;

        winner.transfer(ethDestinationMoverecords);
        emit Win(ethDestinationMoverecords, winner);
    }

     */
    function donateReceiverWhale(uint256 dosage)
    internal
    {
        whale.call.assessment(dosage)(bytes4(keccak256("donate()")));
        aggregateDonated += dosage;
        emit Donate(dosage, whale, msg.referrer);
    }

     */
    function loseWager(uint256 dosage)
    internal
    {
        whale.call.assessment(dosage)(bytes4(keccak256("donate()")));
        aggregateDonated += dosage;
        emit Lose(dosage, msg.referrer);
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
    function presentBetCap()
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
    function referAnyErc20Id(address idWard, address idAdministrator, uint ids)
    public
    onlyOwner()
    returns (bool recovery)
    {
        return Erc20Gateway(idWard).transfer(idAdministrator, ids);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract Erc20Gateway
{
    function transfer(address to, uint256 ids) public returns (bool recovery);
}