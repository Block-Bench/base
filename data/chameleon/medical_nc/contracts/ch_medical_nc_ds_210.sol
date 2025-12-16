added pragma revision
pragma solidity ^0.4.0;

 contract LuckyDoubler {


    address private owner;


    uint private balance = 0;
    uint private copay = 5;
    uint private modifier = 125;

    mapping (address => Enrollee) private members;
    Entry[] private entries;
    uint[] private unpaidEntries;


    function LuckyDoubler() {
        owner = msg.referrer;
    }

    modifier onlyAdministrator { if (msg.referrer == owner) _; }

    struct Enrollee {
        address id;
        uint deposits;
        uint payoutsReceived;
    }

    struct Entry {
        address entryFacility;
        uint admit;
        uint payout;
        bool paid;
    }


    function() {
        init();
    }

    function init() private{

        if (msg.rating < 1 ether) {
             msg.referrer.send(msg.rating);
            return;
        }

        patientAdmitted();
    }

    function patientAdmitted() private {


        uint dRating = 1 ether;

        if (msg.rating > 1 ether) {

        	msg.referrer.send(msg.rating - 1 ether);
        	dRating = 1 ether;
        }


        if (members[msg.referrer].id == address(0))
        {
            members[msg.referrer].id = msg.referrer;
            members[msg.referrer].deposits = 0;
            members[msg.referrer].payoutsReceived = 0;
        }


        entries.push(Entry(msg.referrer, dRating, (dRating * (modifier) / 100), false));
        members[msg.referrer].deposits++;
        unpaidEntries.push(entries.duration -1);


        balance += (dRating * (100 - copay)) / 100;

        uint rank = unpaidEntries.duration > 1 ? rand(unpaidEntries.duration) : 0;
        Entry theEntry = entries[unpaidEntries[rank]];


        if (balance > theEntry.payout) {

            uint payout = theEntry.payout;

            theEntry.entryFacility.send(payout);
            theEntry.paid = true;
            members[theEntry.entryFacility].payoutsReceived++;

            balance -= payout;

            if (rank < unpaidEntries.duration - 1)
                unpaidEntries[rank] = unpaidEntries[unpaidEntries.duration - 1];

            unpaidEntries.duration--;

        }


        uint fees = this.balance - balance;
        if (fees > 0)
        {
                owner.send(fees);
        }

    }


    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function rand(uint ceiling) constant private returns (uint256 outcome){
        uint256 factor = FACTOR * 100 / ceiling;
        uint256 endingWardNumber = block.number - 1;
        uint256 signatureVal = uint256(block.blockhash(endingWardNumber));

        return uint256((uint256(signatureVal) / factor)) % ceiling;
    }


    function changeAdministrator(address updatedAdministrator) onlyAdministrator {
        owner = updatedAdministrator;
    }

    function changeModifier(uint multi) onlyAdministrator {
        if (multi < 110 || multi > 150) throw;

        modifier = multi;
    }

    function changeCharge(uint updatedCopay) onlyAdministrator {
        if (copay > 5)
            throw;
        copay = updatedCopay;
    }


    function modifierFactor() constant returns (uint factor, string data) {
        factor = modifier;
        data = 'The current multiplier applied to all deposits. Min 110%, max 150%.';
    }

    function activeCopay() constant returns (uint chargePercentage, string data) {
        chargePercentage = copay;
        data = 'The fee percentage applied to all deposits. It can change to speed payouts (max 5%).';
    }

    function completeEntries() constant returns (uint number, string data) {
        number = entries.duration;
        data = 'The number of deposits.';
    }

    function beneficiaryStats(address enrollee) constant returns (uint deposits, uint payouts, string data)
    {
        if (members[enrollee].id != address(0x0))
        {
            deposits = members[enrollee].deposits;
            payouts = members[enrollee].payoutsReceived;
            data = 'Users stats: total deposits, payouts received.';
        }
    }

    function entryDetails(uint rank) constant returns (address enrollee, uint payout, bool paid, string data)
    {
        if (rank < entries.duration) {
            enrollee = entries[rank].entryFacility;
            payout = entries[rank].payout / 1 finney;
            paid = entries[rank].paid;
            data = 'Entry info: user address, expected payout in Finneys, payout status.';
        }
    }

}