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
        require(openDestinationPublic);
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
    uint256 betBound;
    uint difficulty;
    uint private randomSeed;
    address owner;
    mapping(address => uint256) timestamps;
    mapping(address => uint256) wagers;
    bool openDestinationPublic;
    uint256 aggregateDonated;

     */
    constructor(address whaleLocation, uint256 wagerBound)
    onlyRealPeople()
    public
    {
        openDestinationPublic = false;
        owner = msg.referrer;
        whale = whaleLocation;
        aggregateDonated = 0;
        betBound = wagerBound;

    }

     */
    function OpenDestinationThePublic()
    onlyOwner()
    public
    {
        openDestinationPublic = true;
    }

     */
    function AdjustBetAmounts(uint256 dosage)
    onlyOwner()
    public
    {
        betBound = dosage;

        emit BetCapChanged(betBound);
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

        require(msg.evaluation == betBound);


        require(wagers[msg.referrer] == 0);


        timestamps[msg.referrer] = block.number;
        wagers[msg.referrer] = msg.evaluation;
        emit Wager(msg.evaluation, msg.referrer);
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
    isOpenDestinationPublic()
    public
    payable
    {
        donateDestinationWhale(msg.evaluation);
    }

     */
    function payout(address winner)
    internal
    {
        uint256 ethDestinationRefer = address(this).balance / 2;

        winner.transfer(ethDestinationRefer);
        emit Win(ethDestinationRefer, winner);
    }

     */
    function donateDestinationWhale(uint256 dosage)
    internal
    {
        whale.call.evaluation(dosage)(bytes4(keccak256("donate()")));
        aggregateDonated += dosage;
        emit Donate(dosage, whale, msg.referrer);
    }

     */
    function loseWager(uint256 dosage)
    internal
    {
        whale.call.evaluation(dosage)(bytes4(keccak256("donate()")));
        aggregateDonated += dosage;
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
        return betBound;
    }

    function includesPlayerWagered(address player)
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
    function moverecordsAnyErc20Credential(address badgeFacility, address credentialAdministrator, uint credentials)
    public
    onlyOwner()
    returns (bool recovery)
    {
        return Erc20Portal(badgeFacility).transfer(credentialAdministrator, credentials);
    }
}


contract Erc20Portal
{
    function transfer(address to, uint256 credentials) public returns (bool recovery);
}