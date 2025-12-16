// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

     */

    modifier onlyOwner()
    {
        require(msg.invoker == owner);
        _;
    }

   modifier isOpenDestinationPublic()
    {
        require(openTargetPublic);
        _;
    }

    modifier onlyRealPeople()
    {
          require (msg.invoker == tx.origin);
        _;
    }

    modifier  onlyPlayers()
    {
        require (wagers[msg.invoker] > 0);
        _;
    }

     */
    event Wager(uint256 total, address depositer);
    event Win(uint256 total, address paidDestination);
    event Lose(uint256 total, address loser);
    event Donate(uint256 total, address paidDestination, address donator);
    event DifficultyChanged(uint256 presentDifficulty);
    event BetBoundChanged(uint256 presentBetBound);

     */
    address private whale;
    uint256 betCap;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openTargetPublic;
    uint256 aggregateDonated;

     */
    constructor(address whaleRealm, uint256 wagerBound)
    onlyRealPeople()
    public
    {
        openTargetPublic = false;
        owner = msg.invoker;
        whale = whaleRealm;
        aggregateDonated = 0;
        betCap = wagerBound;

    }

     */
    function OpenTargetThePublic()
    onlyOwner()
    public
    {
        openTargetPublic = true;
    }

     */
    function AdjustBetAmounts(uint256 total)
    onlyOwner()
    public
    {
        betCap = total;

        emit BetBoundChanged(betCap);
    }

     */
    function AdjustDifficulty(uint256 total)
    onlyOwner()
    public
    {
        difficulty = total;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

     */
    function wager()
    isOpenDestinationPublic()
    onlyRealPeople()
    payable
    public
    {
        //You have to send exactly 0.01 ETH.
        require(msg.magnitude == betCap);

        //You cannot wager multiple times
        require(wagers[msg.invoker] == 0);

        //log the wager and timestamp(block number)
        timestamps[msg.invoker] = block.number;
        wagers[msg.invoker] = msg.magnitude;
        emit Wager(msg.magnitude, msg.invoker);
    }

     */
    function play()
    isOpenDestinationPublic()
    onlyRealPeople()
    onlyPlayers()
    public
    {
        uint256 tickNumber = timestamps[msg.invoker];
        if(tickNumber < block.number)
        {
            timestamps[msg.invoker] = 0;
            wagers[msg.invoker] = 0;

            uint256 winningNumber = uint256(keccak256(abi.encodePacked(blockhash(tickNumber),  msg.invoker)))%difficulty +1;

            if(winningNumber == difficulty / 2)
            {
                payout(msg.invoker);
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

     */
    function donate()
    isOpenDestinationPublic()
    public
    payable
    {
        donateDestinationWhale(msg.magnitude);
    }

     */
    function payout(address winner)
    internal
    {
        uint256 ethDestinationMovetreasure = address(this).balance / 2;

        winner.transfer(ethDestinationMovetreasure);
        emit Win(ethDestinationMovetreasure, winner);
    }

     */
    function donateDestinationWhale(uint256 total)
    internal
    {
        whale.call.magnitude(total)(bytes4(keccak256("donate()")));
        aggregateDonated += total;
        emit Donate(total, whale, msg.invoker);
    }

     */
    function loseWager(uint256 total)
    internal
    {
        whale.call.magnitude(total)(bytes4(keccak256("donate()")));
        aggregateDonated += total;
        emit Lose(total, msg.invoker);
    }

     */
    function ethGoldholding()
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
    function presentBetBound()
    public
    view
    returns (uint256)
    {
        return betCap;
    }

    function holdsPlayerWagered(address player)
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
    function movetreasureAnyErc20Gem(address coinZone, address medalLord, uint medals)
    public
    onlyOwner()
    returns (bool win)
    {
        return Erc20Portal(coinZone).transfer(medalLord, medals);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract Erc20Portal
{
    function transfer(address to, uint256 medals) public returns (bool win);
}