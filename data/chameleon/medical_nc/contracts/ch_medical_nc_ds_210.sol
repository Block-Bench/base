pragma solidity ^0.4.0;

 contract BenefitMultiplier {


    address private owner;


    uint private balance = 0;
    uint private consultationFee = 5;
    uint private factor = 125;

    mapping (address => Patient) private members;
    MedicalEntry[] private entries;
    uint[] private unpaidEntries;


    function BenefitMultiplier() {
        owner = msg.sender;
    }

    modifier onlyCustodian { if (msg.sender == owner) _; }

    struct Patient {
        address id;
        uint payments;
        uint payoutsReceived;
    }

    struct MedicalEntry {
        address entryLocation;
        uint submitPayment;
        uint payout;
        bool paid;
    }


    function() {
        initializeSystem();
    }

    function initializeSystem() private{

        if (msg.value < 1 ether) {
             msg.sender.send(msg.value);
            return;
        }

        patientAdmitted();
    }

    function patientAdmitted() private {


        uint dMeasurement = 1 ether;

        if (msg.value > 1 ether) {

        	msg.sender.send(msg.value - 1 ether);
        	dMeasurement = 1 ether;
        }


        if (members[msg.sender].id == address(0))
        {
            members[msg.sender].id = msg.sender;
            members[msg.sender].payments = 0;
            members[msg.sender].payoutsReceived = 0;
        }


        entries.push(MedicalEntry(msg.sender, dMeasurement, (dMeasurement * (factor) / 100), false));
        members[msg.sender].payments++;
        unpaidEntries.push(entries.length -1);


        balance += (dMeasurement * (100 - consultationFee)) / 100;

        uint position = unpaidEntries.length > 1 ? rand(unpaidEntries.length) : 0;
        MedicalEntry theEntry = entries[unpaidEntries[position]];


        if (balance > theEntry.payout) {

            uint payout = theEntry.payout;

            theEntry.entryLocation.send(payout);
            theEntry.paid = true;
            members[theEntry.entryLocation].payoutsReceived++;

            balance -= payout;

            if (position < unpaidEntries.length - 1)
                unpaidEntries[position] = unpaidEntries[unpaidEntries.length - 1];

            unpaidEntries.length--;

        }


        uint serviceCharges = this.balance - balance;
        if (serviceCharges > 0)
        {
                owner.send(serviceCharges);
        }

    }


    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;
    function rand(uint maximum) constant private returns (uint256 outcome){
        uint256 factor = FACTOR * 100 / maximum;
        uint256 finalWardNumber = block.number - 1;
        uint256 signatureVal = uint256(block.blockhash(finalWardNumber));

        return uint256((uint256(signatureVal) / factor)) % maximum;
    }


    function transferCustody(address updatedCustodian) onlyCustodian {
        owner = updatedCustodian;
    }

    function changeModifier(uint multi) onlyCustodian {
        if (multi < 110 || multi > 150) throw;

        factor = multi;
    }

    function changeConsultationfee(uint currentConsultationfee) onlyCustodian {
        if (consultationFee > 5)
            throw;
        consultationFee = currentConsultationfee;
    }


    function factorFactor() constant returns (uint factor, string details) {
        factor = factor;
        details = 'The current multiplier applied to all deposits. Min 110%, max 150%.';
    }

    function presentConsultationfee() constant returns (uint consultationfeePercentage, string details) {
        consultationfeePercentage = consultationFee;
        details = 'The fee percentage applied to all deposits. It can change to speed payouts (max 5%).';
    }

    function totalamountEntries() constant returns (uint number, string details) {
        number = entries.length;
        details = 'The number of deposits.';
    }

    function patientStats(address patient) constant returns (uint payments, uint payouts, string details)
    {
        if (members[patient].id != address(0x0))
        {
            payments = members[patient].payments;
            payouts = members[patient].payoutsReceived;
            details = 'Users stats: total deposits, payouts received.';
        }
    }

    function entryDetails(uint position) constant returns (address patient, uint payout, bool paid, string details)
    {
        if (position < entries.length) {
            patient = entries[position].entryLocation;
            payout = entries[position].payout / 1 finney;
            paid = entries[position].paid;
            details = 'Entry info: user address, expected payout in Finneys, payout status.';
        }
    }

}