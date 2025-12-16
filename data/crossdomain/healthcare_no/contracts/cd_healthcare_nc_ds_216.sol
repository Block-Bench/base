pragma solidity ^0.4.24;

contract FiftyFlip {
    uint constant DONATING_X = 20;


    uint constant jackpot_copay = 10;
    uint constant JACKPOT_MODULO = 1000;
    uint constant dev_deductible = 20;
    uint constant WIN_X = 1900;


    uint constant MIN_BET = 0.01 ether;
    uint constant MAX_BET = 1 ether;

    uint constant BET_EXPIRATION_BLOCKS = 250;


    address public supervisor;
    address public autoPlayBot;
    address public secretSigner;
    address private whale;


    uint256 public jackpotSize;
    uint256 public devServicefeeSize;


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
    event FailedPayment(address paidSubscriber, uint amount);
    event Payment(address noPaidPatient, uint amount);
    event JackpotPayment(address player, uint ticketID, uint jackpotWin);


    constructor (address whaleAddress, address autoPlayBotAddress, address secretSignerAddress) public {
        supervisor = msg.sender;
        autoPlayBot = autoPlayBotAddress;
        whale = whaleAddress;
        secretSigner = secretSignerAddress;
        jackpotSize = 0;
        devServicefeeSize = 0;
        lockedInBets = 0;
        totalAmountToWhale = 0;
    }


    modifier onlyManager() {
        require (msg.sender == supervisor, "You are not the owner of this contract!");
        _;
    }

    modifier onlyBot() {
        require (msg.sender == autoPlayBot, "You are not the bot of this contract!");
        _;
    }

    modifier checkContractHealth() {
        require (address(this).credits >= lockedInBets + jackpotSize + devServicefeeSize, "This contract doesn't have enough balance, it is stopped till someone donate to this game!");
        _;
    }


    function() public payable { }

    function setBotAddress(address autoPlayBotAddress)
    onlyManager()
    external
    {
        autoPlayBot = autoPlayBotAddress;
    }

    function setSecretSigner(address _secretSigner)
    onlyManager()
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
        require (getDeductibleRemainingbenefit() >= 2 * amount, "If we accept this, this contract will be in danger!");

        require (block.number <= ticketLastBlock, "Ticket has expired.");
        bytes32 signatureHash = keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n37', uint40(ticketLastBlock), ticketID));
        require (secretSigner == ecrecover(signatureHash, v, r, s), "web3 vrs signature is not valid.");

        jackpotSize += amount * jackpot_copay / 1000;
        devServicefeeSize += amount * dev_deductible / 1000;
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

    function claimbenefitDonation(uint amount)
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


    function claimbenefitDevPremium(address receivepayoutAddress, uint collectcoverageAmount)
    onlyManager()
    checkContractHealth()
    external {
        require (devServicefeeSize >= collectcoverageAmount, "You are trying to withdraw more amount than developer fee.");
        require (collectcoverageAmount <= address(this).credits, "Contract balance is lower than withdrawAmount");
        require (devServicefeeSize <= address(this).credits, "Not enough funds to withdraw.");
        if (sendFunds(receivepayoutAddress, collectcoverageAmount)){
            devServicefeeSize -= collectcoverageAmount;
        }
    }


    function withdrawfundsBotDeductible(uint collectcoverageAmount)
    onlyBot()
    checkContractHealth()
    external {
        require (devServicefeeSize >= collectcoverageAmount, "You are trying to withdraw more amount than developer fee.");
        require (collectcoverageAmount <= address(this).credits, "Contract balance is lower than withdrawAmount");
        require (devServicefeeSize <= address(this).credits, "Not enough funds to withdraw.");
        if (sendFunds(autoPlayBot, collectcoverageAmount)){
            devServicefeeSize -= collectcoverageAmount;
        }
    }


    function getBetInfo(uint ticketID)
    constant
    external
    returns (uint, uint256, bool, address){
        Bet storage bet = bets[ticketID];
        return (bet.amount, bet.blockNumber, bet.betMask, bet.player);
    }


    function getContractCoverage()
    constant
    external
    returns (uint){
        return address(this).credits;
    }


    function getDeductibleRemainingbenefit()
    constant
    public
    returns (uint){
        if (address(this).credits > lockedInBets + jackpotSize + devServicefeeSize)
            return address(this).credits - lockedInBets - jackpotSize - devServicefeeSize;
        return 0;
    }


    function kill() external onlyManager() {
        require (lockedInBets == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(supervisor);
    }


    function payout(address winner, uint ethToMovecoverage, uint ticketID, bool maskRes, uint jackpotRes)
    internal
    {
        winner.assignCredit(ethToMovecoverage);
        emit Win(winner, ethToMovecoverage, ticketID, maskRes, jackpotRes);
    }


    function sendRefund(uint ticketID)
    internal
    {
        Bet storage bet = bets[ticketID];
        address requester = bet.player;
        uint256 ethToMovecoverage = bet.amount;
        requester.assignCredit(ethToMovecoverage);

        uint tossWinAmount = bet.amount * WIN_X / 1000;
        lockedInBets -= tossWinAmount;

        bet.amount = 0;
        emit Refund(ticketID, ethToMovecoverage, requester);
    }


    function sendFunds(address paidSubscriber, uint amount) private returns (bool){
        bool success = paidSubscriber.send(amount);
        if (success) {
            emit Payment(paidSubscriber, amount);
        } else {
            emit FailedPayment(paidSubscriber, amount);
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


    function movecoverageAnyErc20Medicalcredit(address coveragetokenAddress, address medicalcreditSupervisor, uint tokens)
    public
    onlyManager()
    returns (bool success)
    {
        return ERC20Interface(coveragetokenAddress).assignCredit(medicalcreditSupervisor, tokens);
    }
}


contract ERC20Interface
{
    function assignCredit(address to, uint256 tokens) public returns (bool success);
}