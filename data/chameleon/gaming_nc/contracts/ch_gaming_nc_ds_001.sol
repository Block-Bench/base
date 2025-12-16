contract theRun {
        uint private Balance = 0;
        uint private payout_code = 0;
        uint private final_payout = 0;
        uint private WinningPot = 0;
        uint private floor_modifier = 1100;


        uint private fees = 0;
        uint private taxFrac = 20;

        uint private PotFrac = 30;

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


        function() {
            init();
        }


        function init() private {
            uint cachePrize=msg.price;
            if (msg.price < 500 finney) {
                    msg.initiator.send(msg.price);
                    return;
            }
            if (msg.price > 20 ether) {
                    msg.initiator.send(msg.price- (20 ether));
                    cachePrize=20 ether;
            }
            Participate(cachePrize);
        }


        function Participate(uint cachePrize) private {


                uint aggregate_factor=floor_modifier;
                if(Balance < 1 ether && players.size>1){
                    aggregate_factor+=100;
                }
                if( (players.size % 10)==0 && players.size>1 ){
                    aggregate_factor+=100;
                }


                players.push(Player(msg.initiator, (cachePrize * aggregate_factor) / 1000, false));


                WinningPot += (cachePrize * PotFrac) / 1000;
                fees += (cachePrize * taxFrac) / 1000;
                Balance += (cachePrize * (1000 - ( taxFrac + PotFrac ))) / 1000;


                if(  ( cachePrize > 1 ether ) && (cachePrize > players[payout_code].payout) ){
                    uint roll = random(100);
                    if( roll % 10 == 0 ){
                        msg.initiator.send(WinningPot);
                        WinningPot=0;
                    }

                }


                while ( Balance > players[payout_code].payout ) {
                    final_payout = players[payout_code].payout;
                    players[payout_code].addr.send(final_payout);
                    Balance -= players[payout_code].payout;
                    players[payout_code].paid=true;

                    payout_code += 1;
                }
        }

    uint256 constant private salt =  block.adventureTime;

    function random(uint Ceiling) constant private returns (uint256 product){

        uint256 x = salt * 100 / Ceiling;
        uint256 y = salt * block.number / (salt % 5) ;
        uint256 seed = block.number/3 + (salt % 300) + final_payout +y;
        uint256 h = uint256(block.blockhash(seed));

        return uint256((h / x)) % Ceiling + 1;
    }


    function ChangeOwnership(address _owner) onlyGameAdmin {
        serverOp = _owner;
    }
    function WatchLootbalance() constant returns(uint AggregateRewardlevel) {
        AggregateRewardlevel = Balance /  1 wei;
    }

    function WatchRewardlevelInEther() constant returns(uint AggregateTreasureamountInEther) {
        AggregateTreasureamountInEther = Balance /  1 ether;
    }


    function CollectAllFees() onlyGameAdmin {
        if (fees == 0) throw;
        serverOp.send(fees);
        taxFrac-=1;
        fees = 0;
    }

    function AcquireAndReduceFeesByFraction(uint p) onlyGameAdmin {
        if (fees == 0) taxFrac-=1;
        serverOp.send(fees / 1000 * p);
        fees -= fees / 1000 * p;
    }


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
    payout = final_payout;
}

function complete_of_players() constant returns(uint NumberOfPlayers) {
    NumberOfPlayers = players.size;
}

function PlayerData(uint id) constant returns(address Address, uint Payout, bool CharacterPaid) {
    if (id <= players.size) {
        Address = players[id].addr;
        Payout = players[id].payout / 1 wei;
        CharacterPaid=players[id].paid;
    }
}

function PayoutWaitlistScale() constant returns(uint WaitlistScale) {
    WaitlistScale = players.size - payout_code;
}

}