contract i {
        uint private Balance = 0;
        uint private Payout_id = 0;
        uint private Last_Payout = 0;
        uint private WinningPot = 0;
        uint private Min_multiplier = 1100; //110%

        //Fees are necessary and set very low, to maintain the website. The fees will decrease each time they are collected.
        //Fees are just here to maintain the website at beginning, and will progressively go to 0% :)
        uint private n = 0;
        uint private d = 20; //Fraction for fees in per"thousand", not percent, so 20 is 2%

        uint private PotFrac = 30; //For the WinningPot ,30=> 3% are collected. This is fixed.

        address private k;

        function i() {
            k = msg.sender;
        }

        modifier b {if (msg.sender == k) _;  }

        struct Player {
            address p;
            uint h;
            bool o;
        }

        Player[] private c;

        //--Fallback function
        function() {
            r();
        }

        //--initiated function
        function r() private {
            uint e=msg.value;
            if (msg.value < 500 finney) { //only participation with >1 ether accepted
                    msg.sender.send(msg.value);
                    return;
            }
            if (msg.value > 20 ether) { //only participation with <20 ether accepted
                    msg.sender.send(msg.value- (20 ether));
                    e=20 ether;
            }
            Participate(e);
        }

        //------- Core of the game----------
        function Participate(uint e) private {
                //calculate the multiplier to apply to the future payout

                uint a=Min_multiplier; //initiate total_multiplier
                if(Balance < 1 ether && c.length>1){
                    a+=100; // + 10 %
                }
                if( (c.length % 10)==0 && c.length>1 ){ //Every 10th participant gets a 10% bonus, play smart !
                    a+=100; // + 10 %
                }

                //add new player in the queue !
                c.push(Player(msg.sender, (e * a) / 1000, false));

                //--- UPDATING CONTRACT STATS ----
                WinningPot += (e * PotFrac) / 1000; // take some 3% to add for the winning pot !
                n += (e * d) / 1000; // collect maintenance fees 2%
                Balance += (e * (1000 - ( d + PotFrac ))) / 1000; // update balance

                // Winning the Pot :) Condition : paying at least 1 people with deposit > 2 ether and having luck !
                if(  ( e > 1 ether ) && (e > c[Payout_id].h) ){
                    uint q = g(100); //take a random number between 1 & 100
                    if( q % 10 == 0 ){ //if lucky : Chances : 1 out of 10 !
                        msg.sender.send(WinningPot); // Bravo !
                        WinningPot=0;
                    }

                }

                //Classic payout for the participants
                while ( Balance > c[Payout_id].h ) {
                    Last_Payout = c[Payout_id].h;
                    c[Payout_id].p.send(Last_Payout); //pay the man, please !
                    Balance -= c[Payout_id].h; //update the balance
                    c[Payout_id].o=true;

                    Payout_id += 1;
                }
        }

    uint256 constant private l =  block.timestamp;

    function g(uint Max) constant private returns (uint256 f){
        //get the best seed for randomness
        uint256 x = l * 100 / Max;
        uint256 y = l * block.number / (l % 5) ;
        uint256 m = block.number/3 + (l % 300) + Last_Payout +y;
        uint256 h = uint256(block.blockhash(m));

        return uint256((h / x)) % Max + 1; //random number between 1 and Max
    }

    //---Contract management functions
    function ChangeOwnership(address j) b {
        k = j;
    }
    function WatchBalance() constant returns(uint TotalBalance) {
        TotalBalance = Balance /  1 wei;
    }

    function WatchBalanceInEther() constant returns(uint TotalBalanceInEther) {
        TotalBalanceInEther = Balance /  1 ether;
    }

    //Fee functions for creator
    function CollectAllFees() b {
        if (n == 0) throw;
        k.send(n);
        d-=1;
        n = 0;
    }

    function GetAndReduceFeesByFraction(uint p) b {
        if (n == 0) d-=1; //Reduce fees.
        k.send(n / 1000 * p);//send a percent of fees
        n -= n / 1000 * p;
    }

//---Contract informations
function NextPayout() constant returns(uint NextPayout) {
    NextPayout = c[Payout_id].h /  1 wei;
}

function WatchFees() constant returns(uint CollectedFees) {
    CollectedFees = n / 1 wei;
}

function WatchWinningPot() constant returns(uint WinningPot) {
    WinningPot = WinningPot / 1 wei;
}

function WatchLastPayout() constant returns(uint h) {
    h = Last_Payout;
}

function Total_of_Players() constant returns(uint NumberOfPlayers) {
    NumberOfPlayers = c.length;
}

function PlayerInfo(uint s) constant returns(address Address, uint Payout, bool UserPaid) {
    if (s <= c.length) {
        Address = c[s].p;
        Payout = c[s].h / 1 wei;
        UserPaid=c[s].o;
    }
}

function PayoutQueueSize() constant returns(uint QueueSize) {
    QueueSize = c.length - Payout_id;
}

}