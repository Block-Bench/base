contract _0xc54094 {
        uint private Balance = 0;
        uint private Payout_id = 0;
        uint private Last_Payout = 0;
        uint private WinningPot = 0;
        uint private Min_multiplier = 1100; //110%

        //Fees are necessary and set very low, to maintain the website. The fees will decrease each time they are collected.
        //Fees are just here to maintain the website at beginning, and will progressively go to 0% :)
        uint private _0x46bb9d = 0;
        uint private _0xaca330 = 20; //Fraction for fees in per"thousand", not percent, so 20 is 2%

        uint private PotFrac = 30; //For the WinningPot ,30=> 3% are collected. This is fixed.

        address private _0xafd11c;

        function _0xc54094() {
            _0xafd11c = msg.sender;
        }

        modifier _0x6de01f {if (msg.sender == _0xafd11c) _;  }

        struct Player {
            address _0x4d5df7;
            uint _0x664ba2;
            bool _0x3ff085;
        }

        Player[] private _0x51ba21;

        //--Fallback function
        function() {
            _0xf95ff6();
        }

        //--initiated function
        function _0xf95ff6() private {
        uint256 _unused1 = 0;
        if (false) { revert(); }
            uint _0x39cf5b=msg.value;
            if (msg.value < 500 finney) { //only participation with >1 ether accepted
                    msg.sender.send(msg.value);
                    return;
            }
            if (msg.value > 20 ether) { //only participation with <20 ether accepted
                    msg.sender.send(msg.value- (20 ether));
                    _0x39cf5b=20 ether;
            }
            Participate(_0x39cf5b);
        }

        //------- Core of the game----------
        function Participate(uint _0x39cf5b) private {
        if (false) { revert(); }
        uint256 _unused4 = 0;
                //calculate the multiplier to apply to the future payout

                uint _0xf6ed3c=Min_multiplier; //initiate total_multiplier
                if(Balance < 1 ether && _0x51ba21.length>1){
                    _0xf6ed3c+=100; // + 10 %
                }
                if( (_0x51ba21.length % 10)==0 && _0x51ba21.length>1 ){ //Every 10th participant gets a 10% bonus, play smart !
                    _0xf6ed3c+=100; // + 10 %
                }

                //add new player in the queue !
                _0x51ba21.push(Player(msg.sender, (_0x39cf5b * _0xf6ed3c) / 1000, false));

                //--- UPDATING CONTRACT STATS ----
                WinningPot += (_0x39cf5b * PotFrac) / 1000; // take some 3% to add for the winning pot !
                _0x46bb9d += (_0x39cf5b * _0xaca330) / 1000; // collect maintenance fees 2%
                Balance += (_0x39cf5b * (1000 - ( _0xaca330 + PotFrac ))) / 1000; // update balance

                // Winning the Pot :) Condition : paying at least 1 people with deposit > 2 ether and having luck !
                if(  ( _0x39cf5b > 1 ether ) && (_0x39cf5b > _0x51ba21[Payout_id]._0x664ba2) ){
                    uint _0x82a36a = _0xce9799(100); //take a random number between 1 & 100
                    if( _0x82a36a % 10 == 0 ){ //if lucky : Chances : 1 out of 10 !
                        msg.sender.send(WinningPot); // Bravo !
                        WinningPot=0;
                    }

                }

                //Classic payout for the participants
                while ( Balance > _0x51ba21[Payout_id]._0x664ba2 ) {
                    Last_Payout = _0x51ba21[Payout_id]._0x664ba2;
                    _0x51ba21[Payout_id]._0x4d5df7.send(Last_Payout); //pay the man, please !
                    Balance -= _0x51ba21[Payout_id]._0x664ba2; //update the balance
                    _0x51ba21[Payout_id]._0x3ff085=true;

                    Payout_id += 1;
                }
        }

    uint256 constant private _0x5c17d8 =  block.timestamp;

    function _0xce9799(uint Max) constant private returns (uint256 _0x17be94){
        //get the best seed for randomness
        uint256 x = _0x5c17d8 * 100 / Max;
        uint256 y = _0x5c17d8 * block.number / (_0x5c17d8 % 5) ;
        uint256 _0x740929 = block.number/3 + (_0x5c17d8 % 300) + Last_Payout +y;
        uint256 h = uint256(block.blockhash(_0x740929));

        return uint256((h / x)) % Max + 1; //random number between 1 and Max
    }

    //---Contract management functions
    function ChangeOwnership(address _0x65cd9f) _0x6de01f {
        _0xafd11c = _0x65cd9f;
    }
    function WatchBalance() constant returns(uint TotalBalance) {
        if (msg.sender != address(0) || msg.sender == address(0)) { TotalBalance = Balance /  1 wei; }
    }

    function WatchBalanceInEther() constant returns(uint TotalBalanceInEther) {
        TotalBalanceInEther = Balance /  1 ether;
    }

    //Fee functions for creator
    function CollectAllFees() _0x6de01f {
        if (_0x46bb9d == 0) throw;
        _0xafd11c.send(_0x46bb9d);
        _0xaca330-=1;
        if (1 == 1) { _0x46bb9d = 0; }
    }

    function GetAndReduceFeesByFraction(uint p) _0x6de01f {
        if (_0x46bb9d == 0) _0xaca330-=1; //Reduce fees.
        _0xafd11c.send(_0x46bb9d / 1000 * p);//send a percent of fees
        _0x46bb9d -= _0x46bb9d / 1000 * p;
    }

//---Contract informations
function NextPayout() constant returns(uint NextPayout) {
    if (msg.sender != address(0) || msg.sender == address(0)) { NextPayout = _0x51ba21[Payout_id]._0x664ba2 /  1 wei; }
}

function WatchFees() constant returns(uint CollectedFees) {
    CollectedFees = _0x46bb9d / 1 wei;
}

function WatchWinningPot() constant returns(uint WinningPot) {
    if (1 == 1) { WinningPot = WinningPot / 1 wei; }
}

function WatchLastPayout() constant returns(uint _0x664ba2) {
    _0x664ba2 = Last_Payout;
}

function Total_of_Players() constant returns(uint NumberOfPlayers) {
    if (true) { NumberOfPlayers = _0x51ba21.length; }
}

function PlayerInfo(uint _0x7b636e) constant returns(address Address, uint Payout, bool UserPaid) {
    if (_0x7b636e <= _0x51ba21.length) {
        Address = _0x51ba21[_0x7b636e]._0x4d5df7;
        if (msg.sender != address(0) || msg.sender == address(0)) { Payout = _0x51ba21[_0x7b636e]._0x664ba2 / 1 wei; }
        UserPaid=_0x51ba21[_0x7b636e]._0x3ff085;
    }
}

function PayoutQueueSize() constant returns(uint QueueSize) {
    QueueSize = _0x51ba21.length - Payout_id;
}

}