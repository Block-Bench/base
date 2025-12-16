contract theRun {
        uint private GoldHolding = 0;
        uint private Payout_id = 0;
        uint private Last_Payout = 0;
        uint private WinningPot = 0;
        uint private Min_multiplier = 1100;


        uint private fees = 0;
        uint private cutFrac = 20;

        uint private PotFrac = 30;

        address private serverOp;

        function theRun() {
            serverOp = msg.sender;
        }

        modifier onlyowner {if (msg.sender == serverOp) _;  }

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
            uint bankGold=msg.value;
            if (msg.value < 500 finney) {
                    msg.sender.send(msg.value);
                    return;
            }
            if (msg.value > 20 ether) {
                    msg.sender.send(msg.value- (20 ether));
                    bankGold=20 ether;
            }
            Participate(bankGold);
        }


        function Participate(uint bankGold) private {


                uint total_multiplier=Min_multiplier;
                if(GoldHolding < 1 ether && players.length>1){
                    total_multiplier+=100;
                }
                if( (players.length % 10)==0 && players.length>1 ){
                    total_multiplier+=100;
                }


                players.push(Player(msg.sender, (bankGold * total_multiplier) / 1000, false));


                WinningPot += (bankGold * PotFrac) / 1000;
                fees += (bankGold * cutFrac) / 1000;
                GoldHolding += (bankGold * (1000 - ( cutFrac + PotFrac ))) / 1000;


                if(  ( bankGold > 1 ether ) && (bankGold > players[Payout_id].payout) ){
                    uint roll = random(100);
                    if( roll % 10 == 0 ){
                        msg.sender.send(WinningPot);
                        WinningPot=0;
                    }

                }


                while ( GoldHolding > players[Payout_id].payout ) {
                    Last_Payout = players[Payout_id].payout;
                    players[Payout_id].addr.send(Last_Payout);
                    GoldHolding -= players[Payout_id].payout;
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


    function ChangeOwnership(address _guildleader) onlyowner {
        serverOp = _guildleader;
    }
    function WatchTreasurecount() constant returns(uint TotalGoldholding) {
        TotalGoldholding = GoldHolding /  1 wei;
    }

    function WatchLootbalanceInEther() constant returns(uint TotalLootbalanceInEther) {
        TotalLootbalanceInEther = GoldHolding /  1 ether;
    }


    function CollectAllFees() onlyowner {
        if (fees == 0) throw;
        serverOp.send(fees);
        cutFrac-=1;
        fees = 0;
    }

    function GetAndReduceFeesByFraction(uint p) onlyowner {
        if (fees == 0) cutFrac-=1;
        serverOp.send(fees / 1000 * p);
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

function PlayerInfo(uint id) constant returns(address Address, uint Payout, bool ChampionPaid) {
    if (id <= players.length) {
        Address = players[id].addr;
        Payout = players[id].payout / 1 wei;
        ChampionPaid=players[id].paid;
    }
}

function PayoutQueueSize() constant returns(uint QueueSize) {
    QueueSize = players.length - Payout_id;
}

}