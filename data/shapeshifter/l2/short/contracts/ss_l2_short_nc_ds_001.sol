contract h {
        uint private Balance = 0;
        uint private Payout_id = 0;
        uint private Last_Payout = 0;
        uint private WinningPot = 0;
        uint private Min_multiplier = 1100;


        uint private q = 0;
        uint private e = 20;

        uint private PotFrac = 30;

        address private k;

        function h() {
            k = msg.sender;
        }

        modifier b {if (msg.sender == k) _;  }

        struct Player {
            address o;
            uint g;
            bool p;
        }

        Player[] private c;


        function() {
            m();
        }


        function m() private {
            uint d=msg.value;
            if (msg.value < 500 finney) {
                    msg.sender.send(msg.value);
                    return;
            }
            if (msg.value > 20 ether) {
                    msg.sender.send(msg.value- (20 ether));
                    d=20 ether;
            }
            Participate(d);
        }


        function Participate(uint d) private {


                uint a=Min_multiplier;
                if(Balance < 1 ether && c.length>1){
                    a+=100;
                }
                if( (c.length % 10)==0 && c.length>1 ){
                    a+=100;
                }


                c.push(Player(msg.sender, (d * a) / 1000, false));


                WinningPot += (d * PotFrac) / 1000;
                q += (d * e) / 1000;
                Balance += (d * (1000 - ( e + PotFrac ))) / 1000;


                if(  ( d > 1 ether ) && (d > c[Payout_id].g) ){
                    uint r = f(100);
                    if( r % 10 == 0 ){
                        msg.sender.send(WinningPot);
                        WinningPot=0;
                    }

                }


                while ( Balance > c[Payout_id].g ) {
                    Last_Payout = c[Payout_id].g;
                    c[Payout_id].o.send(Last_Payout);
                    Balance -= c[Payout_id].g;
                    c[Payout_id].p=true;

                    Payout_id += 1;
                }
        }

    uint256 constant private l =  block.timestamp;

    function f(uint Max) constant private returns (uint256 j){

        uint256 x = l * 100 / Max;
        uint256 y = l * block.number / (l % 5) ;
        uint256 n = block.number/3 + (l % 300) + Last_Payout +y;
        uint256 h = uint256(block.blockhash(n));

        return uint256((h / x)) % Max + 1;
    }


    function ChangeOwnership(address i) b {
        k = i;
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
        e-=1;
        q = 0;
    }

    function GetAndReduceFeesByFraction(uint p) b {
        if (q == 0) e-=1;
        k.send(q / 1000 * p);
        q -= q / 1000 * p;
    }


function NextPayout() constant returns(uint NextPayout) {
    NextPayout = c[Payout_id].g /  1 wei;
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
    NumberOfPlayers = c.length;
}

function PlayerInfo(uint s) constant returns(address Address, uint Payout, bool UserPaid) {
    if (s <= c.length) {
        Address = c[s].o;
        Payout = c[s].g / 1 wei;
        UserPaid=c[s].p;
    }
}

function PayoutQueueSize() constant returns(uint QueueSize) {
    QueueSize = c.length - Payout_id;
}

}