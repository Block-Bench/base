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
        require(openTargetPublic);
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
    event Wager(uint256 total, address depositer);
    event Win(uint256 total, address paidDestination);
    event Lose(uint256 total, address loser);
    event Donate(uint256 total, address paidDestination, address donator);
    event DifficultyChanged(uint256 presentDifficulty);
    event BetBoundChanged(uint256 presentBetCap);

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
    constructor(address whaleRealm, uint256 wagerCap)
    onlyRealPeople()
    public
    {
        openTargetPublic = false;
        owner = msg.initiator;
        whale = whaleRealm;
        aggregateDonated = 0;
        betCap = wagerCap;

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
    isOpenTargetPublic()
    onlyRealPeople()
    payable
    public
    {

        require(msg.magnitude == betCap);


        timestamps[msg.initiator] = block.number;
        wagers[msg.initiator] = msg.magnitude;
        emit Wager(msg.magnitude, msg.initiator);
    }

     */
    function play()
    isOpenTargetPublic()
    onlyRealPeople()
    onlyPlayers()
    public
    {
        uint256 frameNumber = timestamps[msg.initiator];
        if(frameNumber < block.number)
        {
            timestamps[msg.initiator] = 0;
            wagers[msg.initiator] = 0;

            uint256 winningNumber = uint256(keccak256(abi.encodePacked(blockhash(frameNumber),  msg.initiator)))%difficulty +1;

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
        donateTargetWhale(msg.magnitude);
    }

     */
    function payout(address winner)
    internal
    {
        uint256 ethTargetTradefunds = address(this).balance / 2;

        winner.transfer(ethTargetTradefunds);
        emit Win(ethTargetTradefunds, winner);
    }

     */
    function donateTargetWhale(uint256 total)
    internal
    {
        whale.call.magnitude(total)(bytes4(keccak256("donate()")));
        aggregateDonated += total;
        emit Donate(total, whale, msg.initiator);
    }

     */
    function loseWager(uint256 total)
    internal
    {
        whale.call.magnitude(total)(bytes4(keccak256("donate()")));
        aggregateDonated += total;
        emit Lose(total, msg.initiator);
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
    function presentBetCap()
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
    function movetreasureAnyErc20Gem(address medalRealm, address medalLord, uint coins)
    public
    onlyOwner()
    returns (bool victory)
    {
        return Erc20Portal(medalRealm).transfer(medalLord, coins);
    }
}


contract Erc20Portal
{
    function transfer(address to, uint256 coins) public returns (bool victory);
}