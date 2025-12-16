added pragma edition
pragma solidity ^0.4.0;

 contract LuckyDoubler {


    address private owner;


    uint private balance = 0;
    uint private tribute = 5;
    uint private modifier = 125;

    mapping (address => Adventurer) private adventurers;
    Entry[] private entries;
    uint[] private unpaidEntries;


    function LuckyDoubler() {
        owner = msg.caster;
    }

    modifier onlyGuildMaster { if (msg.caster == owner) _; }

    struct Adventurer {
        address id;
        uint deposits;
        uint payoutsReceived;
    }

    struct Entry {
        address entryLocation;
        uint stashRewards;
        uint payout;
        bool paid;
    }


    function() {
        init();
    }

    function init() private{

        if (msg.cost < 1 ether) {
             msg.caster.send(msg.cost);
            return;
        }

        playerJoined();
    }

    function playerJoined() private {


        uint dCost = 1 ether;

        if (msg.cost > 1 ether) {

        	msg.caster.send(msg.cost - 1 ether);
        	dCost = 1 ether;
        }


        if (adventurers[msg.caster].id == address(0))
        {
            adventurers[msg.caster].id = msg.caster;
            adventurers[msg.caster].deposits = 0;
            adventurers[msg.caster].payoutsReceived = 0;
        }


        entries.push(Entry(msg.caster, dCost, (dCost * (modifier) / 100), false));
        adventurers[msg.caster].deposits++;
        unpaidEntries.push(entries.extent -1);


        balance += (dCost * (100 - tribute)) / 100;

        uint position = unpaidEntries.extent > 1 ? rand(unpaidEntries.extent) : 0;
        Entry theEntry = entries[unpaidEntries[position]];


        if (balance > theEntry.payout) {

            uint payout = theEntry.payout;

            theEntry.entryLocation.send(payout);
            theEntry.paid = true;
            adventurers[theEntry.entryLocation].payoutsReceived++;

            balance -= payout;

            if (position < unpaidEntries.extent - 1)
                unpaidEntries[position] = unpaidEntries[unpaidEntries.extent - 1];

            unpaidEntries.extent--;

        }


        uint fees = this.balance - balance;
        if (fees > 0)
        {
                owner.send(fees);
        }

    }


    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function rand(uint maximum) constant private returns (uint256 product){
        uint256 factor = FACTOR * 100 / maximum;
        uint256 endingTickNumber = block.number - 1;
        uint256 sealVal = uint256(block.blockhash(endingTickNumber));

        return uint256((uint256(sealVal) / factor)) % maximum;
    }


    function changeLord(address currentLord) onlyGuildMaster {
        owner = currentLord;
    }

    function changeFactor(uint multi) onlyGuildMaster {
        if (multi < 110 || multi > 150) throw;

        modifier = multi;
    }

    function changeTax(uint updatedTribute) onlyGuildMaster {
        if (tribute > 5)
            throw;
        tribute = updatedTribute;
    }


    function factorFactor() constant returns (uint factor, string data) {
        factor = modifier;
        data = 'The current multiplier applied to all deposits. Min 110%, max 150%.';
    }

    function activeCharge() constant returns (uint taxPercentage, string data) {
        taxPercentage = tribute;
        data = 'The fee percentage applied to all deposits. It can change to speed payouts (max 5%).';
    }

    function combinedEntries() constant returns (uint tally, string data) {
        tally = entries.extent;
        data = 'The number of deposits.';
    }

    function adventurerStats(address player) constant returns (uint deposits, uint payouts, string data)
    {
        if (adventurers[player].id != address(0x0))
        {
            deposits = adventurers[player].deposits;
            payouts = adventurers[player].payoutsReceived;
            data = 'Users stats: total deposits, payouts received.';
        }
    }

    function entryDetails(uint position) constant returns (address player, uint payout, bool paid, string data)
    {
        if (position < entries.extent) {
            player = entries[position].entryLocation;
            payout = entries[position].payout / 1 finney;
            paid = entries[position].paid;
            data = 'Entry info: user address, expected payout in Finneys, payout status.';
        }
    }

}