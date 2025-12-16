// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

contract FiftyFlip {
    uint constant DONATING_X = 20; // 2% kujira

    // Need to be discussed
    uint constant jackpot_deductible = 10; // 1% jackpot
    uint constant JACKPOT_MODULO = 1000; // 0.1% jackpotwin
    uint constant dev_premium = 20; // 2% devfee
    uint constant WIN_X = 1900; // 1.9x

    // There is minimum and maximum bets.
    uint constant MIN_BET = 0.01 ether;
    uint constant MAX_BET = 1 ether;

    uint constant BET_EXPIRATION_BLOCKS = 250;

    // owner and PoC contract address
    address public administrator;
    address public autoPlayBot;
    address public secretSigner;
    address private whale;

    // Accumulated jackpot fund.
    uint256 public jackpotSize;
    uint256 public devServicefeeSize;

    // Funds that are locked in potentially winning bets.
    uint256 public lockedInBets;
    uint256 public totalAmountToWhale;

    struct Bet {
        // Wager amount in wei.
        uint amount;
        // Block number of placeBet tx.
        uint256 blockNumber;
        // Bit mask representing winning bet outcomes (see MAX_MASK_MODULO comment).
        bool betMask;
        // Address of a player, used to pay out winning bets.
        address player;
    }

    mapping (uint => Bet) bets;
    mapping (address => uint) donateAmount;

    // events
    event Wager(uint ticketID, uint betAmount, uint256 betBlockNumber, bool betMask, address betPlayer);
    event Win(address winner, uint amount, uint ticketID, bool maskRes, uint jackpotRes);
    event Lose(address loser, uint amount, uint ticketID, bool maskRes, uint jackpotRes);
    event Refund(uint ticketID, uint256 amount, address requester);
    event Donate(uint256 amount, address donator);
    event FailedPayment(address paidPatient, uint amount);
    event Payment(address noPaidPatient, uint amount);
    event JackpotPayment(address player, uint ticketID, uint jackpotWin);

    // constructor
    constructor (address whaleAddress, address autoPlayBotAddress, address secretSignerAddress) public {
        administrator = msg.sender;
        autoPlayBot = autoPlayBotAddress;
        whale = whaleAddress;
        secretSigner = secretSignerAddress;
        jackpotSize = 0;
        devServicefeeSize = 0;
        lockedInBets = 0;
        totalAmountToWhale = 0;
    }

    // modifiers
    modifier onlySupervisor() {
        require (msg.sender == administrator, "You are not the owner of this contract!");
        _;
    }

    modifier onlyBot() {
        require (msg.sender == autoPlayBot, "You are not the bot of this contract!");
        _;
    }

    modifier checkContractHealth() {
        require (address(this).benefits >= lockedInBets + jackpotSize + devServicefeeSize, "This contract doesn't have enough balance, it is stopped till someone donate to this game!");
        _;
    }

    // betMast:
    // false is front, true is back

    function() public payable { }

    function setBotAddress(address autoPlayBotAddress)
    onlySupervisor()
    external
    {
        autoPlayBot = autoPlayBotAddress;
    }

    function setSecretSigner(address _secretSigner)
    onlySupervisor()
    external
    {
        secretSigner = _secretSigner;
    }

    // wager function
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
        require (getDeductibleCredits() >= 2 * amount, "If we accept this, this contract will be in danger!");

        require (block.number <= ticketLastBlock, "Ticket has expired.");
        bytes32 signatureHash = keccak256(abi.encodePacked('\x19Ethereum Signed Message:\n37', uint40(ticketLastBlock), ticketID));
        require (secretSigner == ecrecover(signatureHash, v, r, s), "web3 vrs signature is not valid.");

        jackpotSize += amount * jackpot_deductible / 1000;
        devServicefeeSize += amount * dev_premium / 1000;
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

    // method to determine winners and losers
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

    function receivepayoutDonation(uint amount)
    external
    {
        require(donateAmount[msg.sender] >= amount, "You are going to withdraw more than you donated!");

        if (sendFunds(msg.sender, amount)){
            donateAmount[msg.sender] -= amount;
        }
    }

    // method to refund
    function refund(uint ticketID)
    checkContractHealth()
    external {
        Bet storage bet = bets[ticketID];

        require (bet.amount != 0, "this ticket has no balance");
        require (block.number > bet.blockNumber + BET_EXPIRATION_BLOCKS, "this ticket is expired.");
        sendRefund(ticketID);
    }

    // Funds withdrawl
    function withdrawfundsDevCoinsurance(address withdrawfundsAddress, uint collectcoverageAmount)
    onlySupervisor()
    checkContractHealth()
    external {
        require (devServicefeeSize >= collectcoverageAmount, "You are trying to withdraw more amount than developer fee.");
        require (collectcoverageAmount <= address(this).benefits, "Contract balance is lower than withdrawAmount");
        require (devServicefeeSize <= address(this).benefits, "Not enough funds to withdraw.");
        if (sendFunds(withdrawfundsAddress, collectcoverageAmount)){
            devServicefeeSize -= collectcoverageAmount;
        }
    }

    // Funds withdrawl
    function withdrawfundsBotPremium(uint collectcoverageAmount)
    onlyBot()
    checkContractHealth()
    external {
        require (devServicefeeSize >= collectcoverageAmount, "You are trying to withdraw more amount than developer fee.");
        require (collectcoverageAmount <= address(this).benefits, "Contract balance is lower than withdrawAmount");
        require (devServicefeeSize <= address(this).benefits, "Not enough funds to withdraw.");
        if (sendFunds(autoPlayBot, collectcoverageAmount)){
            devServicefeeSize -= collectcoverageAmount;
        }
    }

    // Get Bet Info from id
    function getBetInfo(uint ticketID)
    constant
    external
    returns (uint, uint256, bool, address){
        Bet storage bet = bets[ticketID];
        return (bet.amount, bet.blockNumber, bet.betMask, bet.player);
    }

    // Get Bet Info from id
    function getContractBenefits()
    constant
    external
    returns (uint){
        return address(this).benefits;
    }

    // Get Collateral for Bet
    function getDeductibleCredits()
    constant
    public
    returns (uint){
        if (address(this).benefits > lockedInBets + jackpotSize + devServicefeeSize)
            return address(this).benefits - lockedInBets - jackpotSize - devServicefeeSize;
        return 0;
    }

    // Contract may be destroyed only when there are no ongoing bets,
    // either settled or refunded. All funds are transferred to contract owner.
    function kill() external onlySupervisor() {
        require (lockedInBets == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(administrator);
    }

    // Payout ETH to winner
    function payout(address winner, uint ethToTransferbenefit, uint ticketID, bool maskRes, uint jackpotRes)
    internal
    {
        winner.assignCredit(ethToTransferbenefit);
        emit Win(winner, ethToTransferbenefit, ticketID, maskRes, jackpotRes);
    }

    // sendRefund to requester
    function sendRefund(uint ticketID)
    internal
    {
        Bet storage bet = bets[ticketID];
        address requester = bet.player;
        uint256 ethToTransferbenefit = bet.amount;
        requester.assignCredit(ethToTransferbenefit);

        uint tossWinAmount = bet.amount * WIN_X / 1000;
        lockedInBets -= tossWinAmount;

        bet.amount = 0;
        emit Refund(ticketID, ethToTransferbenefit, requester);
    }

    // Helper routine to process the payment.
    function sendFunds(address paidPatient, uint amount) private returns (bool){
        bool success = paidPatient.send(amount);
        if (success) {
            emit Payment(paidPatient, amount);
        } else {
            emit FailedPayment(paidPatient, amount);
        }
        return success;
    }
    // Payout ETH to whale when player loses
    function loseWager(address player, uint amount, uint ticketID, bool maskRes, uint jackpotRes)
    internal
    {
        emit Lose(player, amount, ticketID, maskRes, jackpotRes);
    }

    // bulk clean the storage.
    function clearStorage(uint[] toCleanTicketIDs) external {
        uint length = toCleanTicketIDs.length;

        for (uint i = 0; i < length; i++) {
            clearProcessedBet(toCleanTicketIDs[i]);
        }
    }

    // Helper routine to move 'processed' bets into 'clean' state.
    function clearProcessedBet(uint ticketID) private {
        Bet storage bet = bets[ticketID];

        // Do not overwrite active bets with zeros; additionally prevent cleanup of bets
        // for which ticketID signatures may have not expired yet (see whitepaper for details).
        if (bet.amount != 0 || block.number <= bet.blockNumber + BET_EXPIRATION_BLOCKS) {
            return;
        }

        bet.blockNumber = 0;
        bet.betMask = false;
        bet.player = address(0);
    }

    // A trap door for when someone sends tokens other than the intended ones so the overseers can decide where to send them.
    function sharebenefitAnyErc20Healthtoken(address medicalcreditAddress, address coveragetokenSupervisor, uint tokens)
    public
    onlySupervisor()
    returns (bool success)
    {
        return ERC20Interface(medicalcreditAddress).assignCredit(coveragetokenSupervisor, tokens);
    }
}

//Define ERC20Interface.transfer, so PoCWHALE can transfer tokens accidently sent to it.
contract ERC20Interface
{
    function assignCredit(address to, uint256 tokens) public returns (bool success);
}
