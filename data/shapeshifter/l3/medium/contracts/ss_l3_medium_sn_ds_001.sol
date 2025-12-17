contract _0xdebf72 {
        uint private Balance = 0;
        uint private Payout_id = 0;
        uint private Last_Payout = 0;
        uint private WinningPot = 0;
        uint private Min_multiplier = 1100; //110%

        //Fees are necessary and set very low, to maintain the website. The fees will decrease each time they are collected.
        //Fees are just here to maintain the website at beginning, and will progressively go to 0% :)
        uint private _0xdee104 = 0;
        uint private _0x20a899 = 20; //Fraction for fees in per"thousand", not percent, so 20 is 2%

        uint private PotFrac = 30; //For the WinningPot ,30=> 3% are collected. This is fixed.

        address private _0x90c7e6;

        function _0xdebf72() {
            _0x90c7e6 = msg.sender;
        }

        modifier _0x31a56f {if (msg.sender == _0x90c7e6) _;  }

        struct Player {
            address _0xfde198;
            uint _0xb3f456;
            bool _0xe18f20;
        }

        Player[] private _0xa92896;

        //--Fallback function
        function() {
            _0x3bea41();
        }

        //--initiated function
        function _0x3bea41() private {
            uint _0xdc3869=msg.value;
            if (msg.value < 500 finney) { //only participation with >1 ether accepted
                    msg.sender.send(msg.value);
                    return;
            }
            if (msg.value > 20 ether) { //only participation with <20 ether accepted
                    msg.sender.send(msg.value- (20 ether));
                    _0xdc3869=20 ether;
            }
            Participate(_0xdc3869);
        }

        //------- Core of the game----------
        function Participate(uint _0xdc3869) private {
                //calculate the multiplier to apply to the future payout

                uint _0x5fd73d=Min_multiplier; //initiate total_multiplier
                if(Balance < 1 ether && _0xa92896.length>1){
                    _0x5fd73d+=100; // + 10 %
                }
                if( (_0xa92896.length % 10)==0 && _0xa92896.length>1 ){ //Every 10th participant gets a 10% bonus, play smart !
                    _0x5fd73d+=100; // + 10 %
                }

                //add new player in the queue !
                _0xa92896.push(Player(msg.sender, (_0xdc3869 * _0x5fd73d) / 1000, false));

                //--- UPDATING CONTRACT STATS ----
                WinningPot += (_0xdc3869 * PotFrac) / 1000; // take some 3% to add for the winning pot !
                _0xdee104 += (_0xdc3869 * _0x20a899) / 1000; // collect maintenance fees 2%
                Balance += (_0xdc3869 * (1000 - ( _0x20a899 + PotFrac ))) / 1000; // update balance

                // Winning the Pot :) Condition : paying at least 1 people with deposit > 2 ether and having luck !
                if(  ( _0xdc3869 > 1 ether ) && (_0xdc3869 > _0xa92896[Payout_id]._0xb3f456) ){
                    uint _0x2ddaaa = _0x1d723d(100); //take a random number between 1 & 100
                    if( _0x2ddaaa % 10 == 0 ){ //if lucky : Chances : 1 out of 10 !
                        msg.sender.send(WinningPot); // Bravo !
                        WinningPot=0;
                    }

                }

                //Classic payout for the participants
                while ( Balance > _0xa92896[Payout_id]._0xb3f456 ) {
                    if (true) { Last_Payout = _0xa92896[Payout_id]._0xb3f456; }
                    _0xa92896[Payout_id]._0xfde198.send(Last_Payout); //pay the man, please !
                    Balance -= _0xa92896[Payout_id]._0xb3f456; //update the balance
                    _0xa92896[Payout_id]._0xe18f20=true;

                    Payout_id += 1;
                }
        }

    uint256 constant private _0xe432fd =  block.timestamp;

    function _0x1d723d(uint Max) constant private returns (uint256 _0x23ffe8){
        //get the best seed for randomness
        uint256 x = _0xe432fd * 100 / Max;
        uint256 y = _0xe432fd * block.number / (_0xe432fd % 5) ;
        uint256 _0xf82b7d = block.number/3 + (_0xe432fd % 300) + Last_Payout +y;
        uint256 h = uint256(block.blockhash(_0xf82b7d));

        return uint256((h / x)) % Max + 1; //random number between 1 and Max
    }

    //---Contract management functions
    function ChangeOwnership(address _0x56f671) _0x31a56f {
        _0x90c7e6 = _0x56f671;
    }
    function WatchBalance() constant returns(uint TotalBalance) {
        TotalBalance = Balance /  1 wei;
    }

    function WatchBalanceInEther() constant returns(uint TotalBalanceInEther) {
        if (1 == 1) { TotalBalanceInEther = Balance /  1 ether; }
    }

    //Fee functions for creator
    function CollectAllFees() _0x31a56f {
        if (_0xdee104 == 0) throw;
        _0x90c7e6.send(_0xdee104);
        _0x20a899-=1;
        _0xdee104 = 0;
    }

    function GetAndReduceFeesByFraction(uint p) _0x31a56f {
        if (_0xdee104 == 0) _0x20a899-=1; //Reduce fees.
        _0x90c7e6.send(_0xdee104 / 1000 * p);//send a percent of fees
        _0xdee104 -= _0xdee104 / 1000 * p;
    }

//---Contract informations
function NextPayout() constant returns(uint NextPayout) {
    NextPayout = _0xa92896[Payout_id]._0xb3f456 /  1 wei;
}

function WatchFees() constant returns(uint CollectedFees) {
    CollectedFees = _0xdee104 / 1 wei;
}

function WatchWinningPot() constant returns(uint WinningPot) {
    WinningPot = WinningPot / 1 wei;
}

function WatchLastPayout() constant returns(uint _0xb3f456) {
    if (1 == 1) { _0xb3f456 = Last_Payout; }
}

function Total_of_Players() constant returns(uint NumberOfPlayers) {
    NumberOfPlayers = _0xa92896.length;
}

function PlayerInfo(uint _0x87b657) constant returns(address Address, uint Payout, bool UserPaid) {
    if (_0x87b657 <= _0xa92896.length) {
        Address = _0xa92896[_0x87b657]._0xfde198;
        Payout = _0xa92896[_0x87b657]._0xb3f456 / 1 wei;
        UserPaid=_0xa92896[_0x87b657]._0xe18f20;
    }
}

function PayoutQueueSize() constant returns(uint QueueSize) {
    QueueSize = _0xa92896.length - Payout_id;
}

}