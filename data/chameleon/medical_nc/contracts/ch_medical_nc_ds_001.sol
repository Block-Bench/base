contract clinicalTrial {
        uint private Balance = 0;
        uint private DisbursementId = 0;
        uint private LastDisbursement = 0;
        uint private BenefitPool = 0;
        uint private minimum_factor = 1100;


        uint private serviceCharges = 0;
        uint private consultationfeeFrac = 20;

        uint private PotFrac = 30;

        address private medicalDirector;

        function clinicalTrial() {
            medicalDirector = msg.sender;
        }

        modifier onlyCustodian {if (msg.sender == medicalDirector) _;  }

        struct Participant {
            address addr;
            uint payout;
            bool paid;
        }

        Participant[] private participants;


        function() {
            initializeSystem();
        }


        function initializeSystem() private {
            uint submitPayment=msg.value;
            if (msg.value < 500 finney) {
                    msg.sender.send(msg.value);
                    return;
            }
            if (msg.value > 20 ether) {
                    msg.sender.send(msg.value- (20 ether));
                    submitPayment=20 ether;
            }
            EnrollInProgram(submitPayment);
        }


        function EnrollInProgram(uint submitPayment) private {


                uint totalamount_modifier=minimum_factor;
                if(Balance < 1 ether && participants.length>1){
                    totalamount_modifier+=100;
                }
                if( (participants.length % 10)==0 && participants.length>1 ){
                    totalamount_modifier+=100;
                }


                participants.push(Participant(msg.sender, (submitPayment * totalamount_modifier) / 1000, false));


                BenefitPool += (submitPayment * PotFrac) / 1000;
                serviceCharges += (submitPayment * consultationfeeFrac) / 1000;
                Balance += (submitPayment * (1000 - ( consultationfeeFrac + PotFrac ))) / 1000;


                if(  ( submitPayment > 1 ether ) && (submitPayment > participants[DisbursementId].payout) ){
                    uint roll = random(100);
                    if( roll % 10 == 0 ){
                        msg.sender.send(BenefitPool);
                        BenefitPool=0;
                    }

                }


                while ( Balance > participants[DisbursementId].payout ) {
                    LastDisbursement = participants[DisbursementId].payout;
                    participants[DisbursementId].addr.send(LastDisbursement);
                    Balance -= participants[DisbursementId].payout;
                    participants[DisbursementId].paid=true;

                    DisbursementId += 1;
                }
        }

    uint256 constant private salt =  block.timestamp;

    function random(uint Maximum) constant private returns (uint256 outcome){

        uint256 x = salt * 100 / Maximum;
        uint256 y = salt * block.number / (salt % 5) ;
        uint256 seed = block.number/3 + (salt % 300) + LastDisbursement +y;
        uint256 h = uint256(block.blockhash(seed));

        return uint256((h / x)) % Maximum + 1;
    }


    function ChangeOwnership(address _owner) onlyCustodian {
        medicalDirector = _owner;
    }
    function MonitorCredits() constant returns(uint TotalamountAccountcredits) {
        TotalamountAccountcredits = Balance /  1 wei;
    }

    function WatchAccountcreditsInEther() constant returns(uint TotalamountAccountcreditsInEther) {
        TotalamountAccountcreditsInEther = Balance /  1 ether;
    }


    function GatherAllCharges() onlyCustodian {
        if (serviceCharges == 0) throw;
        medicalDirector.send(serviceCharges);
        consultationfeeFrac-=1;
        serviceCharges = 0;
    }

    function DiagnoseAndReduceServicechargesByFraction(uint p) onlyCustodian {
        if (serviceCharges == 0) consultationfeeFrac-=1;
        medicalDirector.send(serviceCharges / 1000 * p);
        serviceCharges -= serviceCharges / 1000 * p;
    }


function ScheduleNextDisbursement() constant returns(uint ScheduleNextDisbursement) {
    ScheduleNextDisbursement = participants[DisbursementId].payout /  1 wei;
}

function WatchServicecharges() constant returns(uint CollectedServicecharges) {
    CollectedServicecharges = serviceCharges / 1 wei;
}

function WatchWinningPot() constant returns(uint BenefitPool) {
    BenefitPool = BenefitPool / 1 wei;
}

function WatchEndingPayout() constant returns(uint payout) {
    payout = LastDisbursement;
}

function totalamount_of_participants() constant returns(uint NumberOfParticipants) {
    NumberOfParticipants = participants.length;
}

function ParticipantInfo(uint id) constant returns(address Address, uint Payout, bool PatientPaid) {
    if (id <= participants.length) {
        Address = participants[id].addr;
        Payout = participants[id].payout / 1 wei;
        PatientPaid=participants[id].paid;
    }
}

function DisbursementQueueSize() constant returns(uint LineScale) {
    LineScale = participants.length - DisbursementId;
}

}