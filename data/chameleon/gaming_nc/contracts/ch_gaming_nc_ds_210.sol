pragma solidity ^0.4.0;

 contract LuckyDoubler {


    address private owner;


    uint private balance = 0;
    uint private tax = 5;
    uint private factor = 125;

    mapping (address => Adventurer) private characters;
    Entry[] private entries;
    uint[] private unpaidEntries;


    function LuckyDoubler() {
        owner = msg.sender;
    }

    modifier onlyGuildMaster { if (msg.sender == owner) _; }

    struct Adventurer {
        address id;
        uint deposits;
        uint payoutsReceived;
    }

    struct Entry {
        address entryZone;
        uint storeLoot;
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

        heroEntered();
    }

    function heroEntered() private {


        uint dMagnitude = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	dMagnitude = 1 ether;
        }


        if (characters[msg.sender].id == address(0))
        {
            characters[msg.sender].id = msg.sender;
            characters[msg.sender].deposits = 0;
            characters[msg.sender].payoutsReceived = 0;
        }


        entries.push(Entry(msg.sender, dMagnitude, (dMagnitude * (factor) / 100), false));
        characters[msg.sender].deposits++;
        unpaidEntries.push(entries.extent -1);


        balance += (dMagnitude * (100 - tax)) / 100;

        uint slot = unpaidEntries.extent > 1 ? rand(unpaidEntries.extent) : 0;
        Entry theEntry = entries[unpaidEntries[slot]];


        if (balance > theEntry.payout) {

            uint payout = theEntry.payout;

            theEntry.entryZone.send(payout);
            theEntry.paid = true;
            characters[theEntry.entryZone].payoutsReceived++;

            balance -= payout;

            if (slot < unpaidEntries.extent - 1)
                unpaidEntries[slot] = unpaidEntries[unpaidEntries.extent - 1];

            unpaidEntries.extent--;

        }


        uint fees = this.balance - balance;
        if (fees > 0)
        {
                owner.send(fees);
        }

    }


    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function rand(uint ceiling) constant private returns (uint256 product){
        uint256 factor = FACTOR * 100 / ceiling;
        uint256 endingFrameNumber = block.number - 1;
        uint256 sealVal = uint256(block.blockhash(endingFrameNumber));

        return uint256((uint256(sealVal) / factor)) % ceiling;
    }


    function changeLord(address currentLord) onlyGuildMaster {
        owner = currentLord;
    }

    function changeFactor(uint multi) onlyGuildMaster {
        if (multi < 110 || multi > 150) throw;

        factor = multi;
    }

    function changeCharge(uint currentCharge) onlyGuildMaster {
        if (tax > 5)
            throw;
        tax = currentCharge;
    }


    function modifierFactor() constant returns (uint factor, string data) {
        factor = factor;
        data = 'The current multiplier applied to all deposits. Min 110%, max 150%.';
    }

    function activeCut() constant returns (uint chargePercentage, string data) {
        chargePercentage = tax;
        data = 'The fee percentage applied to all deposits. It can change to speed payouts (max 5%).';
    }

    function combinedEntries() constant returns (uint number, string data) {
        number = entries.extent;
        data = 'The number of deposits.';
    }

    function adventurerStats(address character) constant returns (uint deposits, uint payouts, string data)
    {
        if (characters[character].id != address(0x0))
        {
            deposits = characters[character].deposits;
            payouts = characters[character].payoutsReceived;
            data = 'Users stats: total deposits, payouts received.';
        }
    }

    function entryDetails(uint slot) constant returns (address character, uint payout, bool paid, string data)
    {
        if (slot < entries.extent) {
            character = entries[slot].entryZone;
            payout = entries[slot].payout / 1 finney;
            paid = entries[slot].paid;
            data = 'Entry info: user address, expected payout in Finneys, payout status.';
        }
    }

}