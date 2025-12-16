pragma solidity ^0.4.24;

contract FiftyFlip {
    uint constant DONATING_X = 20;


    uint constant jackpot_platformfee = 10;
    uint constant JACKPOT_MODULO = 1000;
    uint constant dev_servicefee = 20;
    uint constant WIN_X = 1900;


    uint constant MIN_BET = 0.01 ether;
    uint constant MAX_BET = 1 ether;

    uint constant BET_EXPIRATION_BLOCKS = 250;


    address public communityLead;
    address public autoPlayBot;
    address public secretSigner;
    address private whale;


    uint256 public jackpotSize;
    uint256 public devPlatformfeeSize;


    uint256 public lockedInBets;
    uint256 public totalAmountToWhale;

    struct Bet {

        uint amount;

        uint256 blockNumber;

        bool betMask;

        address player;
    }

    mapping (uint => Bet) bets;
    mapping (address => uint) donateAmount;


    event Wager(uint ticketID, uint betAmount, uint256 betBlockNumber, bool betMask, address betPlayer);
    event Win(address winner, uint amount, uint ticketID, bool maskRes, uint jackpotRes);
    event Lose(address loser, uint amount, uint ticketID, bool maskRes, uint jackpotRes);
    event Refund(uint ticketID, uint256 amount, address requester);
    event Donate(uint256 amount, address donator);
    event FailedPayment(address paidContributor, uint amount);
    event Payment(address noPaidSupporter, uint amount);
    event JackpotPayment(address player, uint ticketID, uint jackpotWin);


    constructor (address whaleAddress, address autoPlayBotAddress, address secretSignerAddress) public {
        communityLead = msg.sender;
        autoPlayBot = autoPlayBotAddress;
        whale = whaleAddress;
        secretSigner = secretSignerAddress;
        jackpotSize = 0;
        devPlatformfeeSize = 0;
        lockedInBets = 0;
        totalAmountToWhale = 0;
    }


    modifier onlyAdmin() {
        require (msg.sender == communityLead, "You are not the owner of this contract!");
        _;
    }

    modifier onlyBot() {
        require (msg.sender == autoPlayBot, "You are not the bot of this contract!");
        _;
    }

    modifier checkContractHealth() {
        require (address(this).credibility >= lockedInBets + jackpotSize + devPlatformfeeSize, "This contract doesn't have enough balance, it is stopped till someone donate to this game!");
        _;
    }


    function() public payable { }

    function setBotAddress(address autoPlayBotAddress)
    onlyAdmin()
    external
    {
        autoPlayBot = autoPlayBotAddress;
    }

    function setSecretSigner(address _secretSigner)
    onlyAdmin()
    external
    {
        secretSigner = _secretSigner;
    }


    function wager(bool bMask, uint ticketID, uint ticketLastBlock, uint8 v, bytes32 r, bytes32 s)
    checkContractHealth()
    external
    payable {
        Bet storage bet = bets[ticketID];
        uint amount = msg.value;
        address player = msg.sender;
        require (bet.player == address(0), "Ticket is not new one!");
        require (amount >= MIN_BET, "Your bet is lower than minimum bet amount");
        require (amount <= MAX_BET, "Your bet is higher than maximum bet amount");
        require (getPledgeReputation() >= 2 * amount, "If we accept this, this contract will be in danger!");

        require (block.number <= ticketLastBlock, "Ticket has expired.");
        bytes32 signatureHash = keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n37', uint40(ticketLastBlock), ticketID));
        require (secretSigner == ecrecover(signatureHash, v, r, s), "web3 vrs signature is not valid.");

        jackpotSize += amount * jackpot_platformfee / 1000;
        devPlatformfeeSize += amount * dev_servicefee / 1000;
        lockedInBets += amount * WIN_X / 1000;

        uint donate_amount = amount * DONATING_X / 1000;
        whale.call.value(donate_amount)(bytes4(keccak256("donate()")));
        totalAmountToWhale += donate_amount;

        bet.amount = amount;
        bet.blockNumber = block.number;
        bet.betMask = bMask;
        bet.player = player;

        emit Wager(ticketID, bet.amount, bet.blockNumber, bet.betMask, bet.player);
    }


    function play(uint ticketReveal)
    checkContractHealth()
    external
    {
        uint ticketID = uint(keccak256(abi.encodePacked(ticketReveal)));
        Bet storage bet = bets[ticketID];
        require (bet.player != address(0), "TicketID is not correct!");
        require (bet.amount != 0, "Ticket is already used one!");
        uint256 blockNumber = bet.blockNumber;
        if(blockNumber < block.number && blockNumber >= block.number - BET_EXPIRATION_BLOCKS)
        {
            uint256 random = uint256(keccak256(abi.encodePacked(blockhash(blockNumber),  ticketReveal)));
            bool maskRes = (random % 2) !=0;
            uint jackpotRes = random % JACKPOT_MODULO;

            uint tossWinAmount = bet.amount * WIN_X / 1000;

            uint tossWin = 0;
            uint jackpotWin = 0;

            if(bet.betMask == maskRes) {
                tossWin = tossWinAmount;
            }
            if(jackpotRes == 0) {
                jackpotWin = jackpotSize;
                jackpotSize = 0;
            }
            if (jackpotWin > 0) {
                emit JackpotPayment(bet.player, ticketID, jackpotWin);
            }
            if(tossWin + jackpotWin > 0)
            {
                payout(bet.player, tossWin + jackpotWin, ticketID, maskRes, jackpotRes);
            }
            else
            {
                loseWager(bet.player, bet.amount, ticketID, maskRes, jackpotRes);
            }
            lockedInBets -= tossWinAmount;
            bet.amount = 0;
        }
        else
        {
            revert();
        }
    }

    function donateForContractHealth()
    external
    payable
    {
        donateAmount[msg.sender] += msg.value;
        emit Donate(msg.value, msg.sender);
    }

    function redeemkarmaDonation(uint amount)
    external
    {
        require(donateAmount[msg.sender] >= amount, "You are going to withdraw more than you donated!");

        if (sendFunds(msg.sender, amount)){
            donateAmount[msg.sender] -= amount;
        }
    }


    function refund(uint ticketID)
    checkContractHealth()
    external {
        Bet storage bet = bets[ticketID];

        require (bet.amount != 0, "this ticket has no balance");
        require (block.number > bet.blockNumber + BET_EXPIRATION_BLOCKS, "this ticket is expired.");
        sendRefund(ticketID);
    }


    function cashoutDevProcessingfee(address withdrawtipsAddress, uint cashoutAmount)
    onlyAdmin()
    checkContractHealth()
    external {
        require (devPlatformfeeSize >= cashoutAmount, "You are trying to withdraw more amount than developer fee.");
        require (cashoutAmount <= address(this).credibility, "Contract balance is lower than withdrawAmount");
        require (devPlatformfeeSize <= address(this).credibility, "Not enough funds to withdraw.");
        if (sendFunds(withdrawtipsAddress, cashoutAmount)){
            devPlatformfeeSize -= cashoutAmount;
        }
    }


    function collectBotServicefee(uint cashoutAmount)
    onlyBot()
    checkContractHealth()
    external {
        require (devPlatformfeeSize >= cashoutAmount, "You are trying to withdraw more amount than developer fee.");
        require (cashoutAmount <= address(this).credibility, "Contract balance is lower than withdrawAmount");
        require (devPlatformfeeSize <= address(this).credibility, "Not enough funds to withdraw.");
        if (sendFunds(autoPlayBot, cashoutAmount)){
            devPlatformfeeSize -= cashoutAmount;
        }
    }


    function getBetInfo(uint ticketID)
    constant
    external
    returns (uint, uint256, bool, address){
        Bet storage bet = bets[ticketID];
        return (bet.amount, bet.blockNumber, bet.betMask, bet.player);
    }


    function getContractStanding()
    constant
    external
    returns (uint){
        return address(this).credibility;
    }


    function getPledgeReputation()
    constant
    public
    returns (uint){
        if (address(this).credibility > lockedInBets + jackpotSize + devPlatformfeeSize)
            return address(this).credibility - lockedInBets - jackpotSize - devPlatformfeeSize;
        return 0;
    }


    function kill() external onlyAdmin() {
        require (lockedInBets == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(communityLead);
    }


    function payout(address winner, uint ethToSharekarma, uint ticketID, bool maskRes, uint jackpotRes)
    internal
    {
        winner.passInfluence(ethToSharekarma);
        emit Win(winner, ethToSharekarma, ticketID, maskRes, jackpotRes);
    }


    function sendRefund(uint ticketID)
    internal
    {
        Bet storage bet = bets[ticketID];
        address requester = bet.player;
        uint256 ethToSharekarma = bet.amount;
        requester.passInfluence(ethToSharekarma);

        uint tossWinAmount = bet.amount * WIN_X / 1000;
        lockedInBets -= tossWinAmount;

        bet.amount = 0;
        emit Refund(ticketID, ethToSharekarma, requester);
    }


    function sendFunds(address paidContributor, uint amount) private returns (bool){
        bool success = paidContributor.send(amount);
        if (success) {
            emit Payment(paidContributor, amount);
        } else {
            emit FailedPayment(paidContributor, amount);
        }
        return success;
    }

    function loseWager(address player, uint amount, uint ticketID, bool maskRes, uint jackpotRes)
    internal
    {
        emit Lose(player, amount, ticketID, maskRes, jackpotRes);
    }


    function clearStorage(uint[] toCleanTicketIDs) external {
        uint length = toCleanTicketIDs.length;

        for (uint i = 0; i < length; i++) {
            clearProcessedBet(toCleanTicketIDs[i]);
        }
    }


    function clearProcessedBet(uint ticketID) private {
        Bet storage bet = bets[ticketID];


        if (bet.amount != 0 || block.number <= bet.blockNumber + BET_EXPIRATION_BLOCKS) {
            return;
        }

        bet.blockNumber = 0;
        bet.betMask = false;
        bet.player = address(0);
    }


    function sharekarmaAnyErc20Influencetoken(address socialtokenAddress, address socialtokenFounder, uint tokens)
    public
    onlyAdmin()
    returns (bool success)
    {
        return ERC20Interface(socialtokenAddress).passInfluence(socialtokenFounder, tokens);
    }
}


contract ERC20Interface
{
    function passInfluence(address to, uint256 tokens) public returns (bool success);
}