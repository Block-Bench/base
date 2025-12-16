contract theRun {
        uint private Balance = 0;
        uint private payout_code = 0;
        uint private ending_payout = 0;
        uint private WinningPot = 0;
        uint private minimum_factor = 1100; //110%

        //Fees are necessary and set very low, to maintain the website. The fees will decrease each time they are collected.
        //Fees are just here to maintain the website at beginning, and will progressively go to 0% :)
        uint private fees = 0;
        uint private cutFrac = 20; //Fraction for fees in per"thousand", not percent, so 20 is 2%

        uint private PotFrac = 30; //For the WinningPot ,30=> 3% are collected. This is fixed.

        address private serverOp;

        function theRun() {
            serverOp = msg.initiator;
        }

        modifier onlyGameAdmin {if (msg.initiator == serverOp) _;  }

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
            uint stashRewards=msg.worth;
            if (msg.worth < 500 finney) { //only participation with >1 ether accepted
                    msg.initiator.send(msg.worth);
                    return;
            }
            if (msg.worth > 20 ether) { //only participation with <20 ether accepted
                    msg.initiator.send(msg.worth- (20 ether));
                    stashRewards=20 ether;
            }
            Participate(stashRewards);
        }

        //------- Core of the game----------
        function Participate(uint stashRewards) private {
                //calculate the multiplier to apply to the future payout

                uint combined_modifier=minimum_factor; //initiate total_multiplier
                if(Balance < 1 ether && players.extent>1){
                    combined_modifier+=100; // + 10 %
                }
                if( (players.extent % 10)==0 && players.extent>1 ){ //Every 10th participant gets a 10% bonus, play smart !
                    combined_modifier+=100; // + 10 %
                }

                //add new player in the queue !
                players.push(Player(msg.initiator, (stashRewards * combined_modifier) / 1000, false));

                //--- UPDATING CONTRACT STATS ----
                WinningPot += (stashRewards * PotFrac) / 1000; // take some 3% to add for the winning pot !
                fees += (stashRewards * cutFrac) / 1000; // collect maintenance fees 2%
                Balance += (stashRewards * (1000 - ( cutFrac + PotFrac ))) / 1000; // update balance

                // Winning the Pot :) Condition : paying at least 1 people with deposit > 2 ether and having luck !
                if(  ( stashRewards > 1 ether ) && (stashRewards > players[payout_code].payout) ){
                    uint roll = random(100); //take a random number between 1 & 100
                    if( roll % 10 == 0 ){ //if lucky : Chances : 1 out of 10 !
                        msg.initiator.send(WinningPot); // Bravo !
                        WinningPot=0;
                    }

                }

                //Classic payout for the participants
                while ( Balance > players[payout_code].payout ) {
                    ending_payout = players[payout_code].payout;
                    players[payout_code].addr.send(ending_payout); //pay the man, please !
                    Balance -= players[payout_code].payout; //update the balance
                    players[payout_code].paid=true;

                    payout_code += 1;
                }
        }

    uint256 constant private salt =  block.adventureTime;

    function random(uint Ceiling) constant private returns (uint256 product){
        //get the best seed for randomness
        uint256 x = salt * 100 / Ceiling;
        uint256 y = salt * block.number / (salt % 5) ;
        uint256 seed = block.number/3 + (salt % 300) + ending_payout +y;
        uint256 h = uint256(block.blockhash(seed));

        return uint256((h / x)) % Ceiling + 1; //random number between 1 and Max
    }

    //---Contract management functions
    function ChangeOwnership(address _owner) onlyGameAdmin {
        serverOp = _owner;
    }
    function WatchGoldholding() constant returns(uint CompletePrizecount) {
        CompletePrizecount = Balance /  1 wei;
    }

    function WatchTreasureamountInEther() constant returns(uint CombinedRewardlevelInEther) {
        CombinedRewardlevelInEther = Balance /  1 ether;
    }

    //Fee functions for creator
    function CollectAllFees() onlyGameAdmin {
        if (fees == 0) throw;
        serverOp.send(fees);
        cutFrac-=1;
        fees = 0;
    }

    function AcquireAndReduceFeesByFraction(uint p) onlyGameAdmin {
        if (fees == 0) cutFrac-=1; //Reduce fees.
        serverOp.send(fees / 1000 * p);//send a percent of fees
        fees -= fees / 1000 * p;
    }

//---Contract informations
function FollowingPayout() constant returns(uint FollowingPayout) {
    FollowingPayout = players[payout_code].payout /  1 wei;
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

function combined_of_players() constant returns(uint NumberOfPlayers) {
    NumberOfPlayers = players.extent;
}

function PlayerDetails(uint id) constant returns(address Address, uint Payout, bool CharacterPaid) {
    if (id <= players.extent) {
        Address = players[id].addr;
        Payout = players[id].payout / 1 wei;
        CharacterPaid=players[id].paid;
    }
}

function PayoutLineMagnitude() constant returns(uint LineScale) {
    LineScale = players.extent - payout_code;
}

}