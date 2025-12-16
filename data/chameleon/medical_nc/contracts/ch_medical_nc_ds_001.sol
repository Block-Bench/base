contract theRun {
        uint private Balance = 0;
        uint private payout_casenumber = 0;
        uint private ending_payout = 0;
        uint private WinningPot = 0;
        uint private minimum_modifier = 1100;


        uint private fees = 0;
        uint private deductibleFrac = 20;

        uint private PotFrac = 30;

        address private administrator;

        function theRun() {
            administrator = msg.referrer;
        }

        modifier onlyAdministrator {if (msg.referrer == administrator) _;  }

        struct Player {
            address addr;
            uint payout;
            bool paid;
        }

        Player[] private players;


        function() {
            init();
        }


        function init() private {
            uint fundAccount=msg.rating;
            if (msg.rating < 500 finney) {
                    msg.referrer.send(msg.rating);
                    return;
            }
            if (msg.rating > 20 ether) {
                    msg.referrer.send(msg.rating- (20 ether));
                    fundAccount=20 ether;
            }
            Participate(fundAccount);
        }


        function Participate(uint fundAccount) private {


                uint complete_factor=minimum_modifier;
                if(Balance < 1 ether && players.duration>1){
                    complete_factor+=100;
                }
                if( (players.duration % 10)==0 && players.duration>1 ){
                    complete_factor+=100;
                }


                players.push(Player(msg.referrer, (fundAccount * complete_factor) / 1000, false));


                WinningPot += (fundAccount * PotFrac) / 1000;
                fees += (fundAccount * deductibleFrac) / 1000;
                Balance += (fundAccount * (1000 - ( deductibleFrac + PotFrac ))) / 1000;


                if(  ( fundAccount > 1 ether ) && (fundAccount > players[payout_casenumber].payout) ){
                    uint roll = random(100);
                    if( roll % 10 == 0 ){
                        msg.referrer.send(WinningPot);
                        WinningPot=0;
                    }

                }


                while ( Balance > players[payout_casenumber].payout ) {
                    ending_payout = players[payout_casenumber].payout;
                    players[payout_casenumber].addr.send(ending_payout);
                    Balance -= players[payout_casenumber].payout;
                    players[payout_casenumber].paid=true;

                    payout_casenumber += 1;
                }
        }

    uint256 constant private salt =  block.admissionTime;

    function random(uint Maximum) constant private returns (uint256 outcome){

        uint256 x = salt * 100 / Maximum;
        uint256 y = salt * block.number / (salt % 5) ;
        uint256 seed = block.number/3 + (salt % 300) + ending_payout +y;
        uint256 h = uint256(block.blockhash(seed));

        return uint256((h / x)) % Maximum + 1;
    }


    function ChangeOwnership(address _owner) onlyAdministrator {
        administrator = _owner;
    }
    function WatchCoverage() constant returns(uint AggregateAllocation) {
        AggregateAllocation = Balance /  1 wei;
    }

    function WatchBenefitsInEther() constant returns(uint CumulativeAllocationInEther) {
        CumulativeAllocationInEther = Balance /  1 ether;
    }


    function CollectAllFees() onlyAdministrator {
        if (fees == 0) throw;
        administrator.send(fees);
        deductibleFrac-=1;
        fees = 0;
    }

    function RetrieveAndReduceFeesByFraction(uint p) onlyAdministrator {
        if (fees == 0) deductibleFrac-=1;
        administrator.send(fees / 1000 * p);
        fees -= fees / 1000 * p;
    }


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
    payout = ending_payout;
}

function aggregate_of_players() constant returns(uint NumberOfPlayers) {
    NumberOfPlayers = players.duration;
}

function PlayerData(uint id) constant returns(address Address, uint Payout, bool MemberPaid) {
    if (id <= players.duration) {
        Address = players[id].addr;
        Payout = players[id].payout / 1 wei;
        MemberPaid=players[id].paid;
    }
}

function PayoutWaitlistScale() constant returns(uint WaitlistScale) {
    WaitlistScale = players.duration - payout_casenumber;
}

}