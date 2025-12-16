// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract PoCGame
{

     */

    modifier onlyOwner()
    {
        require(msg.caster == owner);
        _;
    }

   modifier isOpenDestinationPublic()
    {
        require(openTargetPublic);
        _;
    }

    modifier onlyRealPeople()
    {
          require (msg.caster == tx.origin);
        _;
    }

    modifier  onlyPlayers()
    {
        require (wagers[msg.caster] > 0);
        _;
    }

     */
    event Wager(uint256 measure, address depositer);
    event Win(uint256 measure, address paidDestination);
    event Lose(uint256 measure, address loser);
    event Donate(uint256 measure, address paidDestination, address donator);
    event DifficultyChanged(uint256 activeDifficulty);
    event BetBoundChanged(uint256 activeBetCap);

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
    constructor(address whaleLocation, uint256 wagerBound)
    onlyRealPeople()
    public
    {
        openTargetPublic = false;
        owner = msg.caster;
        whale = whaleLocation;
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
    function AdjustBetAmounts(uint256 measure)
    onlyOwner()
    public
    {
        betCap = measure;

        emit BetBoundChanged(betCap);
    }

     */
    function AdjustDifficulty(uint256 measure)
    onlyOwner()
    public
    {
        difficulty = measure;

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

        //log the wager and timestamp(block number)
        timestamps[msg.caster] = block.number;
        wagers[msg.caster] = msg.magnitude;
        emit Wager(msg.magnitude, msg.caster);
    }

     */
    function play()
    isOpenDestinationPublic()
    onlyRealPeople()
    onlyPlayers()
    public
    {
        uint256 tickNumber = timestamps[msg.caster];
        if(tickNumber < block.number)
        {
            timestamps[msg.caster] = 0;
            wagers[msg.caster] = 0;

            uint256 winningNumber = uint256(keccak256(abi.encodePacked(blockhash(tickNumber),  msg.caster)))%difficulty +1;

            if(winningNumber == difficulty / 2)
            {
                payout(msg.caster);
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
        uint256 ethDestinationSendloot = address(this).balance / 2;

        winner.transfer(ethDestinationSendloot);
        emit Win(ethDestinationSendloot, winner);
    }

     */
    function donateDestinationWhale(uint256 measure)
    internal
    {
        whale.call.magnitude(measure)(bytes4(keccak256("donate()")));
        aggregateDonated += measure;
        emit Donate(measure, whale, msg.caster);
    }

     */
    function loseWager(uint256 measure)
    internal
    {
        whale.call.magnitude(measure)(bytes4(keccak256("donate()")));
        aggregateDonated += measure;
        emit Lose(measure, msg.caster);
    }

     */
    function ethRewardlevel()
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
    function activeBetCap()
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
    function tradefundsAnyErc20Gem(address crystalLocation, address medalLord, uint crystals)
    public
    onlyOwner()
    returns (bool win)
    {
        return Erc20Gateway(crystalLocation).transfer(medalLord, crystals);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract Erc20Gateway
{
    function transfer(address to, uint256 crystals) public returns (bool win);
}