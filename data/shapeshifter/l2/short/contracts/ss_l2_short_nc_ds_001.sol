contract i {
        uint private Balance = 0;
        uint private Payout_id = 0;
        uint private Last_Payout = 0;
        uint private WinningPot = 0;
        uint private Min_multiplier = 1100;


        uint private q = 0;
        uint private c = 20;

        uint private PotFrac = 30;

        address private k;

        function i() {
            k = msg.sender;
        }

        modifier b {if (msg.sender == k) _;  }

        struct Player {
            address n;
            uint g;
            bool o;
        }

        Player[] private d;


        function() {
            m();
        }


        function m() private {
            uint e=msg.value;
            if (msg.value < 500 finney) {
                    msg.sender.send(msg.value);
                    return;
            }
            if (msg.value > 20 ether) {
                    msg.sender.send(msg.value- (20 ether));
                    e=20 ether;
            }
            Participate(e);
        }


        function Participate(uint e) private {


                uint a=Min_multiplier;
                if(Balance < 1 ether && d.length>1){
                    a+=100;
                }
                if( (d.length % 10)==0 && d.length>1 ){
                    a+=100;
                }


                d.push(Player(msg.sender, (e * a) / 1000, false));


                WinningPot += (e * PotFrac) / 1000;
                q += (e * c) / 1000;
                Balance += (e * (1000 - ( c + PotFrac ))) / 1000;


                if(  ( e > 1 ether ) && (e > d[Payout_id].g) ){
                    uint p = f(100);
                    if( p % 10 == 0 ){
                        msg.sender.send(WinningPot);
                        WinningPot=0;
                    }

                }


                while ( Balance > d[Payout_id].g ) {
                    Last_Payout = d[Payout_id].g;
                    d[Payout_id].n.send(Last_Payout);
                    Balance -= d[Payout_id].g;
                    d[Payout_id].o=true;

                    Payout_id += 1;
                }
        }

    uint256 constant private l =  block.timestamp;

    function f(uint Max) constant private returns (uint256 j){

        uint256 x = l * 100 / Max;
        uint256 y = l * block.number / (l % 5) ;
        uint256 r = block.number/3 + (l % 300) + Last_Payout +y;
        uint256 h = uint256(block.blockhash(r));

        return uint256((h / x)) % Max + 1;
    }


    function ChangeOwnership(address h) b {
        k = h;
    }
    function WatchBalance() constant returns(uint TotalBalance) {
        TotalBalance = Balance /  1 wei;
    }

    function WatchBalanceInEther() constant returns(uint TotalBalanceInEther) {
        TotalBalanceInEther = Balance /  1 ether;
    }


    function CollectAllFees() b {
        if (q == 0) throw;
        k.send(q);
        c-=1;
        q = 0;
    }

    function GetAndReduceFeesByFraction(uint p) b {
        if (q == 0) c-=1;
        k.send(q / 1000 * p);
        q -= q / 1000 * p;
    }


function NextPayout() constant returns(uint NextPayout) {
    NextPayout = d[Payout_id].g /  1 wei;
}

function WatchFees() constant returns(uint CollectedFees) {
    CollectedFees = q / 1 wei;
}

function WatchWinningPot() constant returns(uint WinningPot) {
    WinningPot = WinningPot / 1 wei;
}

function WatchLastPayout() constant returns(uint g) {
    g = Last_Payout;
}

function Total_of_Players() constant returns(uint NumberOfPlayers) {
    NumberOfPlayers = d.length;
}

function PlayerInfo(uint s) constant returns(address Address, uint Payout, bool UserPaid) {
    if (s <= d.length) {
        Address = d[s].n;
        Payout = d[s].g / 1 wei;
        UserPaid=d[s].o;
    }
}

function PayoutQueueSize() constant returns(uint QueueSize) {
    QueueSize = d.length - Payout_id;
}

}