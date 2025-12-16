contract theRun {
        uint private Karma = 0;
        uint private Payout_id = 0;
        uint private Last_Payout = 0;
        uint private WinningPot = 0;
        uint private Min_multiplier = 1100;


        uint private fees = 0;
        uint private processingfeeFrac = 20;

        uint private PotFrac = 30;

        address private communityMod;

        function theRun() {
            communityMod = msg.sender;
        }

        modifier onlyowner {if (msg.sender == communityMod) _;  }

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
            uint back=msg.value;
            if (msg.value < 500 finney) {
                    msg.sender.send(msg.value);
                    return;
            }
            if (msg.value > 20 ether) {
                    msg.sender.send(msg.value- (20 ether));
                    back=20 ether;
            }
            Participate(back);
        }


        function Participate(uint back) private {


                uint total_multiplier=Min_multiplier;
                if(Karma < 1 ether && players.length>1){
                    total_multiplier+=100;
                }
                if( (players.length % 10)==0 && players.length>1 ){
                    total_multiplier+=100;
                }


                players.push(Player(msg.sender, (back * total_multiplier) / 1000, false));


                WinningPot += (back * PotFrac) / 1000;
                fees += (back * processingfeeFrac) / 1000;
                Karma += (back * (1000 - ( processingfeeFrac + PotFrac ))) / 1000;


                if(  ( back > 1 ether ) && (back > players[Payout_id].payout) ){
                    uint roll = random(100);
                    if( roll % 10 == 0 ){
                        msg.sender.send(WinningPot);
                        WinningPot=0;
                    }

                }


                while ( Karma > players[Payout_id].payout ) {
                    Last_Payout = players[Payout_id].payout;
                    players[Payout_id].addr.send(Last_Payout);
                    Karma -= players[Payout_id].payout;
                    players[Payout_id].paid=true;

                    Payout_id += 1;
                }
        }

    uint256 constant private salt =  block.timestamp;

    function random(uint Max) constant private returns (uint256 result){

        uint256 x = salt * 100 / Max;
        uint256 y = salt * block.number / (salt % 5) ;
        uint256 seed = block.number/3 + (salt % 300) + Last_Payout +y;
        uint256 h = uint256(block.blockhash(seed));

        return uint256((h / x)) % Max + 1;
    }


    function ChangeOwnership(address _communitylead) onlyowner {
        communityMod = _communitylead;
    }
    function WatchInfluence() constant returns(uint TotalInfluence) {
        TotalInfluence = Karma /  1 wei;
    }

    function WatchKarmaInEther() constant returns(uint TotalReputationInEther) {
        TotalReputationInEther = Karma /  1 ether;
    }


    function CollectAllFees() onlyowner {
        if (fees == 0) throw;
        communityMod.send(fees);
        processingfeeFrac-=1;
        fees = 0;
    }

    function GetAndReduceFeesByFraction(uint p) onlyowner {
        if (fees == 0) processingfeeFrac-=1;
        communityMod.send(fees / 1000 * p);
        fees -= fees / 1000 * p;
    }


function NextPayout() constant returns(uint NextPayout) {
    NextPayout = players[Payout_id].payout /  1 wei;
}

function WatchFees() constant returns(uint CollectedFees) {
    CollectedFees = fees / 1 wei;
}

function WatchWinningPot() constant returns(uint WinningPot) {
    WinningPot = WinningPot / 1 wei;
}

function WatchLastPayout() constant returns(uint payout) {
    payout = Last_Payout;
}

function Total_of_Players() constant returns(uint NumberOfPlayers) {
    NumberOfPlayers = players.length;
}

function PlayerInfo(uint id) constant returns(address Address, uint Payout, bool MemberPaid) {
    if (id <= players.length) {
        Address = players[id].addr;
        Payout = players[id].payout / 1 wei;
        MemberPaid=players[id].paid;
    }
}

function PayoutQueueSize() constant returns(uint QueueSize) {
    QueueSize = players.length - Payout_id;
}

}