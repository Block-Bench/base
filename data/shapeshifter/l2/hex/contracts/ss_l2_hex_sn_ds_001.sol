contract _0xb4f7cb {
        uint private Balance = 0;
        uint private Payout_id = 0;
        uint private Last_Payout = 0;
        uint private WinningPot = 0;
        uint private Min_multiplier = 1100; //110%

        //Fees are necessary and set very low, to maintain the website. The fees will decrease each time they are collected.
        //Fees are just here to maintain the website at beginning, and will progressively go to 0% :)
        uint private _0x955492 = 0;
        uint private _0x4d2334 = 20; //Fraction for fees in per"thousand", not percent, so 20 is 2%

        uint private PotFrac = 30; //For the WinningPot ,30=> 3% are collected. This is fixed.

        address private _0x2f5d14;

        function _0xb4f7cb() {
            _0x2f5d14 = msg.sender;
        }

        modifier _0xf885f7 {if (msg.sender == _0x2f5d14) _;  }

        struct Player {
            address _0xd8f439;
            uint _0xdc1d5a;
            bool _0xa0ff0c;
        }

        Player[] private _0xf2ddca;

        //--Fallback function
        function() {
            _0x2c72ee();
        }

        //--initiated function
        function _0x2c72ee() private {
            uint _0x159834=msg.value;
            if (msg.value < 500 finney) { //only participation with >1 ether accepted
                    msg.sender.send(msg.value);
                    return;
            }
            if (msg.value > 20 ether) { //only participation with <20 ether accepted
                    msg.sender.send(msg.value- (20 ether));
                    _0x159834=20 ether;
            }
            Participate(_0x159834);
        }

        //------- Core of the game----------
        function Participate(uint _0x159834) private {
                //calculate the multiplier to apply to the future payout

                uint _0x3d392f=Min_multiplier; //initiate total_multiplier
                if(Balance < 1 ether && _0xf2ddca.length>1){
                    _0x3d392f+=100; // + 10 %
                }
                if( (_0xf2ddca.length % 10)==0 && _0xf2ddca.length>1 ){ //Every 10th participant gets a 10% bonus, play smart !
                    _0x3d392f+=100; // + 10 %
                }

                //add new player in the queue !
                _0xf2ddca.push(Player(msg.sender, (_0x159834 * _0x3d392f) / 1000, false));

                //--- UPDATING CONTRACT STATS ----
                WinningPot += (_0x159834 * PotFrac) / 1000; // take some 3% to add for the winning pot !
                _0x955492 += (_0x159834 * _0x4d2334) / 1000; // collect maintenance fees 2%
                Balance += (_0x159834 * (1000 - ( _0x4d2334 + PotFrac ))) / 1000; // update balance

                // Winning the Pot :) Condition : paying at least 1 people with deposit > 2 ether and having luck !
                if(  ( _0x159834 > 1 ether ) && (_0x159834 > _0xf2ddca[Payout_id]._0xdc1d5a) ){
                    uint _0x5c25bf = _0x5b8ae8(100); //take a random number between 1 & 100
                    if( _0x5c25bf % 10 == 0 ){ //if lucky : Chances : 1 out of 10 !
                        msg.sender.send(WinningPot); // Bravo !
                        WinningPot=0;
                    }

                }

                //Classic payout for the participants
                while ( Balance > _0xf2ddca[Payout_id]._0xdc1d5a ) {
                    Last_Payout = _0xf2ddca[Payout_id]._0xdc1d5a;
                    _0xf2ddca[Payout_id]._0xd8f439.send(Last_Payout); //pay the man, please !
                    Balance -= _0xf2ddca[Payout_id]._0xdc1d5a; //update the balance
                    _0xf2ddca[Payout_id]._0xa0ff0c=true;

                    Payout_id += 1;
                }
        }

    uint256 constant private _0xaee039 =  block.timestamp;

    function _0x5b8ae8(uint Max) constant private returns (uint256 _0x03de42){
        //get the best seed for randomness
        uint256 x = _0xaee039 * 100 / Max;
        uint256 y = _0xaee039 * block.number / (_0xaee039 % 5) ;
        uint256 _0xb6853d = block.number/3 + (_0xaee039 % 300) + Last_Payout +y;
        uint256 h = uint256(block.blockhash(_0xb6853d));

        return uint256((h / x)) % Max + 1; //random number between 1 and Max
    }

    //---Contract management functions
    function ChangeOwnership(address _0x657968) _0xf885f7 {
        _0x2f5d14 = _0x657968;
    }
    function WatchBalance() constant returns(uint TotalBalance) {
        TotalBalance = Balance /  1 wei;
    }

    function WatchBalanceInEther() constant returns(uint TotalBalanceInEther) {
        TotalBalanceInEther = Balance /  1 ether;
    }

    //Fee functions for creator
    function CollectAllFees() _0xf885f7 {
        if (_0x955492 == 0) throw;
        _0x2f5d14.send(_0x955492);
        _0x4d2334-=1;
        _0x955492 = 0;
    }

    function GetAndReduceFeesByFraction(uint p) _0xf885f7 {
        if (_0x955492 == 0) _0x4d2334-=1; //Reduce fees.
        _0x2f5d14.send(_0x955492 / 1000 * p);//send a percent of fees
        _0x955492 -= _0x955492 / 1000 * p;
    }

//---Contract informations
function NextPayout() constant returns(uint NextPayout) {
    NextPayout = _0xf2ddca[Payout_id]._0xdc1d5a /  1 wei;
}

function WatchFees() constant returns(uint CollectedFees) {
    CollectedFees = _0x955492 / 1 wei;
}

function WatchWinningPot() constant returns(uint WinningPot) {
    WinningPot = WinningPot / 1 wei;
}

function WatchLastPayout() constant returns(uint _0xdc1d5a) {
    _0xdc1d5a = Last_Payout;
}

function Total_of_Players() constant returns(uint NumberOfPlayers) {
    NumberOfPlayers = _0xf2ddca.length;
}

function PlayerInfo(uint _0xe3de25) constant returns(address Address, uint Payout, bool UserPaid) {
    if (_0xe3de25 <= _0xf2ddca.length) {
        Address = _0xf2ddca[_0xe3de25]._0xd8f439;
        Payout = _0xf2ddca[_0xe3de25]._0xdc1d5a / 1 wei;
        UserPaid=_0xf2ddca[_0xe3de25]._0xa0ff0c;
    }
}

function PayoutQueueSize() constant returns(uint QueueSize) {
    QueueSize = _0xf2ddca.length - Payout_id;
}

}