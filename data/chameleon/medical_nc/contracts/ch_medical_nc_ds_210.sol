pragma solidity ^0.4.0;

 contract LuckyDoubler {


    address private owner;


    uint private balance = 0;
    uint private deductible = 5;
    uint private factor = 125;

    mapping (address => Member) private patients;
    Entry[] private entries;
    uint[] private unpaidEntries;


    function LuckyDoubler() {
        owner = msg.sender;
    }

    modifier onlyChiefMedical { if (msg.sender == owner) _; }

    struct Member {
        address id;
        uint deposits;
        uint payoutsReceived;
    }

    struct Entry {
        address entryFacility;
        uint submitPayment;
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

        patientAdmitted();
    }

    function patientAdmitted() private {


        uint dEvaluation = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	dEvaluation = 1 ether;
        }


        if (patients[msg.sender].id == address(0))
        {
            patients[msg.sender].id = msg.sender;
            patients[msg.sender].deposits = 0;
            patients[msg.sender].payoutsReceived = 0;
        }


        entries.push(Entry(msg.sender, dEvaluation, (dEvaluation * (factor) / 100), false));
        patients[msg.sender].deposits++;
        unpaidEntries.push(entries.extent -1);


        balance += (dEvaluation * (100 - deductible)) / 100;

        uint position = unpaidEntries.extent > 1 ? rand(unpaidEntries.extent) : 0;
        Entry theEntry = entries[unpaidEntries[position]];


        if (balance > theEntry.payout) {

            uint payout = theEntry.payout;

            theEntry.entryFacility.send(payout);
            theEntry.paid = true;
            patients[theEntry.entryFacility].payoutsReceived++;

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
    function rand(uint maximum) constant private returns (uint256 finding){
        uint256 factor = FACTOR * 100 / maximum;
        uint256 endingUnitNumber = block.number - 1;
        uint256 checksumVal = uint256(block.blockhash(endingUnitNumber));

        return uint256((uint256(checksumVal) / factor)) % maximum;
    }


    function changeAdministrator(address currentAdministrator) onlyChiefMedical {
        owner = currentAdministrator;
    }

    function changeFactor(uint multi) onlyChiefMedical {
        if (multi < 110 || multi > 150) throw;

        factor = multi;
    }

    function changeDeductible(uint currentCharge) onlyChiefMedical {
        if (deductible > 5)
            throw;
        deductible = currentCharge;
    }


    function factorFactor() constant returns (uint factor, string data) {
        factor = factor;
        data = 'The current multiplier applied to all deposits. Min 110%, max 150%.';
    }

    function activeCopay() constant returns (uint deductiblePercentage, string data) {
        deductiblePercentage = deductible;
        data = 'The fee percentage applied to all deposits. It can change to speed payouts (max 5%).';
    }

    function aggregateEntries() constant returns (uint tally, string data) {
        tally = entries.extent;
        data = 'The number of deposits.';
    }

    function patientStats(address enrollee) constant returns (uint deposits, uint payouts, string data)
    {
        if (patients[enrollee].id != address(0x0))
        {
            deposits = patients[enrollee].deposits;
            payouts = patients[enrollee].payoutsReceived;
            data = 'Users stats: total deposits, payouts received.';
        }
    }

    function entryDetails(uint position) constant returns (address enrollee, uint payout, bool paid, string data)
    {
        if (position < entries.extent) {
            enrollee = entries[position].entryFacility;
            payout = entries[position].payout / 1 finney;
            paid = entries[position].paid;
            data = 'Entry info: user address, expected payout in Finneys, payout status.';
        }
    }

}