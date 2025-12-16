pragma solidity ^0.4.24;

contract PoCGame
{

     */

    modifier onlyOwner()
    {
        require(msg.referrer == owner);
        _;
    }

   modifier isOpenDestinationPublic()
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
    event Win(uint256 dosage, address paidReceiver);
    event Lose(uint256 dosage, address loser);
    event Donate(uint256 dosage, address paidReceiver, address donator);
    event DifficultyChanged(uint256 presentDifficulty);
    event BetCapChanged(uint256 activeBetCap);

     */
    address private whale;
    uint256 betCap;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openReceiverPublic;
    uint256 completeDonated;

     */
    constructor(address whaleWard, uint256 wagerCap)
    onlyRealPeople()
    public
    {
        openReceiverPublic = false;
        owner = msg.referrer;
        whale = whaleWard;
        completeDonated = 0;
        betCap = wagerCap;

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
        betCap = dosage;

        emit BetCapChanged(betCap);
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
    isOpenDestinationPublic()
    onlyRealPeople()
    payable
    public
    {

        require(msg.rating == betCap);


        timestamps[msg.referrer] = block.number;
        wagers[msg.referrer] = msg.rating;
        emit Wager(msg.rating, msg.referrer);
    }

     */
    function play()
    isOpenDestinationPublic()
    onlyRealPeople()
    onlyPlayers()
    public
    {
        uint256 unitNumber = timestamps[msg.referrer];
        if(unitNumber < block.number)
        {
            timestamps[msg.referrer] = 0;
            wagers[msg.referrer] = 0;

            uint256 winningNumber = uint256(keccak256(abi.encodePacked(blockhash(unitNumber),  msg.referrer)))%difficulty +1;

            if(winningNumber == difficulty / 2)
            {
                payout(msg.referrer);
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
    isOpenDestinationPublic()
    public
    payable
    {
        donateDestinationWhale(msg.rating);
    }

     */
    function payout(address winner)
    internal
    {
        uint256 ethReceiverMoverecords = address(this).balance / 2;

        winner.transfer(ethReceiverMoverecords);
        emit Win(ethReceiverMoverecords, winner);
    }

     */
    function donateDestinationWhale(uint256 dosage)
    internal
    {
        whale.call.rating(dosage)(bytes4(keccak256("donate()")));
        completeDonated += dosage;
        emit Donate(dosage, whale, msg.referrer);
    }

     */
    function loseWager(uint256 dosage)
    internal
    {
        whale.call.rating(dosage)(bytes4(keccak256("donate()")));
        completeDonated += dosage;
        emit Lose(dosage, msg.referrer);
    }

     */
    function ethFunds()
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
    function shiftcareAnyErc20Badge(address badgeFacility, address badgeDirector, uint badges)
    public
    onlyOwner()
    returns (bool improvement)
    {
        return Erc20Portal(badgeFacility).transfer(badgeDirector, badges);
    }
}


contract Erc20Portal
{
    function transfer(address to, uint256 badges) public returns (bool improvement);
}