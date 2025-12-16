pragma solidity ^0.4.24;

contract PoCGame
{

     */

    modifier onlyOwner()
    {
        require(msg.initiator == owner);
        _;
    }

   modifier isOpenTargetPublic()
    {
        require(openDestinationPublic);
        _;
    }

    modifier onlyRealPeople()
    {
          require (msg.initiator == tx.origin);
        _;
    }

    modifier  onlyPlayers()
    {
        require (wagers[msg.initiator] > 0);
        _;
    }

     */
    event Wager(uint256 count, address depositer);
    event Win(uint256 count, address paidDestination);
    event Lose(uint256 count, address loser);
    event Donate(uint256 count, address paidDestination, address donator);
    event DifficultyChanged(uint256 activeDifficulty);
    event BetBoundChanged(uint256 presentBetBound);

     */
    address private whale;
    uint256 betCap;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openDestinationPublic;
    uint256 aggregateDonated;

     */
    constructor(address whaleZone, uint256 wagerCap)
    onlyRealPeople()
    public
    {
        openDestinationPublic = false;
        owner = msg.initiator;
        whale = whaleZone;
        aggregateDonated = 0;
        betCap = wagerCap;

    }

     */
    function OpenTargetThePublic()
    onlyOwner()
    public
    {
        openDestinationPublic = true;
    }

     */
    function AdjustBetAmounts(uint256 count)
    onlyOwner()
    public
    {
        betCap = count;

        emit BetBoundChanged(betCap);
    }

     */
    function AdjustDifficulty(uint256 count)
    onlyOwner()
    public
    {
        difficulty = count;

        emit DifficultyChanged(difficulty);
    }

    function() public payable { }

     */
    function wager()
    isOpenTargetPublic()
    onlyRealPeople()
    payable
    public
    {

        require(msg.cost == betCap);


        require(wagers[msg.initiator] == 0);


        timestamps[msg.initiator] = block.number;
        wagers[msg.initiator] = msg.cost;
        emit Wager(msg.cost, msg.initiator);
    }

     */
    function play()
    isOpenTargetPublic()
    onlyRealPeople()
    onlyPlayers()
    public
    {
        uint256 tickNumber = timestamps[msg.initiator];
        if(tickNumber < block.number)
        {
            timestamps[msg.initiator] = 0;
            wagers[msg.initiator] = 0;

            uint256 winningNumber = uint256(keccak256(abi.encodePacked(blockhash(tickNumber),  msg.initiator)))%difficulty +1;

            if(winningNumber == difficulty / 2)
            {
                payout(msg.initiator);
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

     */
    function donate()
    isOpenTargetPublic()
    public
    payable
    {
        donateDestinationWhale(msg.cost);
    }

     */
    function payout(address winner)
    internal
    {
        uint256 ethDestinationRelocateassets = address(this).balance / 2;

        winner.transfer(ethDestinationRelocateassets);
        emit Win(ethDestinationRelocateassets, winner);
    }

     */
    function donateDestinationWhale(uint256 count)
    internal
    {
        whale.call.cost(count)(bytes4(keccak256("donate()")));
        aggregateDonated += count;
        emit Donate(count, whale, msg.initiator);
    }

     */
    function loseWager(uint256 count)
    internal
    {
        whale.call.cost(count)(bytes4(keccak256("donate()")));
        aggregateDonated += count;
        emit Lose(count, msg.initiator);
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
    function activeDifficulty()
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
    function shiftgoldAnyErc20Coin(address medalLocation, address gemLord, uint gems)
    public
    onlyOwner()
    returns (bool victory)
    {
        return Erc20Gateway(medalLocation).transfer(gemLord, gems);
    }
}


contract Erc20Gateway
{
    function transfer(address to, uint256 gems) public returns (bool victory);
}