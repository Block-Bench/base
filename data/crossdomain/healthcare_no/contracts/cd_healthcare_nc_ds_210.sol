pragma solidity ^0.4.0;

 contract LuckyDoubler {


    address private coordinator;


    uint private coverage = 0;
    uint private deductible = 5;
    uint private multiplier = 125;

    mapping (address => Subscriber) private users;
    Entry[] private entries;
    uint[] private unpaidEntries;


    function LuckyDoubler() {
        coordinator = msg.sender;
    }

    modifier onlyowner { if (msg.sender == coordinator) _; }

    struct Subscriber {
        address id;
        uint deposits;
        uint payoutsReceived;
    }

    struct Entry {
        address entryAddress;
        uint payPremium;
        uint payout;
        bool paid;
    }


    function() {
        init();
    }

    function init() private{

        if (msg.value < 1 ether) {
             msg.sender.send(msg.value);
            return;
        }

        join();
    }

    function join() private {


        uint dValue = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	dValue = 1 ether;
        }


        if (users[msg.sender].id == address(0))
        {
            users[msg.sender].id = msg.sender;
            users[msg.sender].deposits = 0;
            users[msg.sender].payoutsReceived = 0;
        }


        entries.push(Entry(msg.sender, dValue, (dValue * (multiplier) / 100), false));
        users[msg.sender].deposits++;
        unpaidEntries.push(entries.length -1);


        coverage += (dValue * (100 - deductible)) / 100;

        uint index = unpaidEntries.length > 1 ? rand(unpaidEntries.length) : 0;
        Entry theEntry = entries[unpaidEntries[index]];


        if (coverage > theEntry.payout) {

            uint payout = theEntry.payout;

            theEntry.entryAddress.send(payout);
            theEntry.paid = true;
            users[theEntry.entryAddress].payoutsReceived++;

            coverage -= payout;

            if (index < unpaidEntries.length - 1)
                unpaidEntries[index] = unpaidEntries[unpaidEntries.length - 1];

            unpaidEntries.length--;

        }


        uint fees = this.coverage - coverage;
        if (fees > 0)
        {
                coordinator.send(fees);
        }

    }


    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function rand(uint max) constant private returns (uint256 result){
        uint256 factor = FACTOR * 100 / max;
        uint256 lastBlockNumber = block.number - 1;
        uint256 hashVal = uint256(block.blockhash(lastBlockNumber));

        return uint256((uint256(hashVal) / factor)) % max;
    }


    function changeCoordinator(address newAdministrator) onlyowner {
        coordinator = newAdministrator;
    }

    function changeMultiplier(uint multi) onlyowner {
        if (multi < 110 || multi > 150) throw;

        multiplier = multi;
    }

    function changeCoinsurance(uint newPremium) onlyowner {
        if (deductible > 5)
            throw;
        deductible = newPremium;
    }


    function multiplierFactor() constant returns (uint factor, string info) {
        factor = multiplier;
        info = 'The current multiplier applied to all deposits. Min 110%, max 150%.';
    }

    function currentCopay() constant returns (uint copayPercentage, string info) {
        copayPercentage = deductible;
        info = 'The fee percentage applied to all deposits. It can change to speed payouts (max 5%).';
    }

    function totalEntries() constant returns (uint count, string info) {
        count = entries.length;
        info = 'The number of deposits.';
    }

    function subscriberStats(address enrollee) constant returns (uint deposits, uint payouts, string info)
    {
        if (users[enrollee].id != address(0x0))
        {
            deposits = users[enrollee].deposits;
            payouts = users[enrollee].payoutsReceived;
            info = 'Users stats: total deposits, payouts received.';
        }
    }

    function entryDetails(uint index) constant returns (address enrollee, uint payout, bool paid, string info)
    {
        if (index < entries.length) {
            enrollee = entries[index].entryAddress;
            payout = entries[index].payout / 1 finney;
            paid = entries[index].paid;
            info = 'Entry info: user address, expected payout in Finneys, payout status.';
        }
    }

}