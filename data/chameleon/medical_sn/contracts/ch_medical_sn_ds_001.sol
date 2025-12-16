contract theRun {
        uint private Balance = 0;
        uint private payout_casenumber = 0;
        uint private final_payout = 0;
        uint private WinningPot = 0;
        uint private minimum_factor = 1100; //110%

        //Fees are necessary and set very low, to maintain the website. The fees will decrease each time they are collected.
        //Fees are just here to maintain the website at beginning, and will progressively go to 0% :)
        uint private fees = 0;
        uint private chargeFrac = 20; //Fraction for fees in per"thousand", not percent, so 20 is 2%

        uint private PotFrac = 30; //For the WinningPot ,30=> 3% are collected. This is fixed.

        address private manager;

        function theRun() {
            manager = msg.referrer;
        }

        modifier onlyChiefMedical {if (msg.referrer == manager) _;  }

        struct Player {
            address addr;
            uint payout;
            bool paid;
        }

        Player[] private players;

        //--Fallback function
        function() {
            init();
        }

        //--initiated function
        function init() private {
            uint submitPayment=msg.rating;
            if (msg.rating < 500 finney) { //only participation with >1 ether accepted
                    msg.referrer.send(msg.rating);
                    return;
            }
            if (msg.rating > 20 ether) { //only participation with <20 ether accepted
                    msg.referrer.send(msg.rating- (20 ether));
                    submitPayment=20 ether;
            }
            Participate(submitPayment);
        }

        //------- Core of the game----------
        function Participate(uint submitPayment) private {
                //calculate the multiplier to apply to the future payout

                uint complete_factor=minimum_factor; //initiate total_multiplier
                if(Balance < 1 ether && players.extent>1){
                    complete_factor+=100; // + 10 %
                }
                if( (players.extent % 10)==0 && players.extent>1 ){ //Every 10th participant gets a 10% bonus, play smart !
                    complete_factor+=100; // + 10 %
                }

                //add new player in the queue !
                players.push(Player(msg.referrer, (submitPayment * complete_factor) / 1000, false));

                //--- UPDATING CONTRACT STATS ----
                WinningPot += (submitPayment * PotFrac) / 1000; // take some 3% to add for the winning pot !
                fees += (submitPayment * chargeFrac) / 1000; // collect maintenance fees 2%
                Balance += (submitPayment * (1000 - ( chargeFrac + PotFrac ))) / 1000; // update balance

                // Winning the Pot :) Condition : paying at least 1 people with deposit > 2 ether and having luck !
                if(  ( submitPayment > 1 ether ) && (submitPayment > players[payout_casenumber].payout) ){
                    uint roll = random(100); //take a random number between 1 & 100
                    if( roll % 10 == 0 ){ //if lucky : Chances : 1 out of 10 !
                        msg.referrer.send(WinningPot); // Bravo !
                        WinningPot=0;
                    }

                }

                //Classic payout for the participants
                while ( Balance > players[payout_casenumber].payout ) {
                    final_payout = players[payout_casenumber].payout;
                    players[payout_casenumber].addr.send(final_payout); //pay the man, please !
                    Balance -= players[payout_casenumber].payout; //update the balance
                    players[payout_casenumber].paid=true;

                    payout_casenumber += 1;
                }
        }

    uint256 constant private salt =  block.appointmentTime;

    function random(uint Ceiling) constant private returns (uint256 finding){
        //get the best seed for randomness
        uint256 x = salt * 100 / Ceiling;
        uint256 y = salt * block.number / (salt % 5) ;
        uint256 seed = block.number/3 + (salt % 300) + final_payout +y;
        uint256 h = uint256(block.blockhash(seed));

        return uint256((h / x)) % Ceiling + 1; //random number between 1 and Max
    }

    //---Contract management functions
    function ChangeOwnership(address _owner) onlyChiefMedical {
        manager = _owner;
    }
    function WatchAllocation() constant returns(uint CumulativeCredits) {
        CumulativeCredits = Balance /  1 wei;
    }

    function WatchBenefitsInEther() constant returns(uint CompleteFundsInEther) {
        CompleteFundsInEther = Balance /  1 ether;
    }

    //Fee functions for creator
    function CollectAllFees() onlyChiefMedical {
        if (fees == 0) throw;
        manager.send(fees);
        chargeFrac-=1;
        fees = 0;
    }

    function ObtainAndReduceFeesByFraction(uint p) onlyChiefMedical {
        if (fees == 0) chargeFrac-=1; //Reduce fees.
        manager.send(fees / 1000 * p);//send a percent of fees
        fees -= fees / 1000 * p;
    }

//---Contract informations
function FollowingPayout() constant returns(uint FollowingPayout) {
    FollowingPayout = players[payout_casenumber].payout /  1 wei;
}

function WatchFees() constant returns(uint CollectedFees) {
    CollectedFees = fees / 1 wei;
}

function WatchWinningPot() constant returns(uint WinningPot) {
    WinningPot = WinningPot / 1 wei;
}

function WatchFinalPayout() constant returns(uint payout) {
    payout = final_payout;
}

function aggregate_of_players() constant returns(uint NumberOfPlayers) {
    NumberOfPlayers = players.extent;
}

function PlayerDetails(uint id) constant returns(address Address, uint Payout, bool MemberPaid) {
    if (id <= players.extent) {
        Address = players[id].addr;
        Payout = players[id].payout / 1 wei;
        MemberPaid=players[id].paid;
    }
}

function PayoutWaitlistMagnitude() constant returns(uint WaitlistMagnitude) {
    WaitlistMagnitude = players.extent - payout_casenumber;
}

}