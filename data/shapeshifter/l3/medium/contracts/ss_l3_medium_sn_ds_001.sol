contract _0xcc0cbb {
        uint private Balance = 0;
        uint private Payout_id = 0;
        uint private Last_Payout = 0;
        uint private WinningPot = 0;
        uint private Min_multiplier = 1100; //110%

        //Fees are necessary and set very low, to maintain the website. The fees will decrease each time they are collected.
        //Fees are just here to maintain the website at beginning, and will progressively go to 0% :)
        uint private _0xb39771 = 0;
        uint private _0x82380e = 20; //Fraction for fees in per"thousand", not percent, so 20 is 2%

        uint private PotFrac = 30; //For the WinningPot ,30=> 3% are collected. This is fixed.

        address private _0x0d4c8f;

        function _0xcc0cbb() {
            _0x0d4c8f = msg.sender;
        }

        modifier _0xa53fa7 {if (msg.sender == _0x0d4c8f) _;  }

        struct Player {
            address _0x578c17;
            uint _0x3f079b;
            bool _0xc9fe17;
        }

        Player[] private _0x0459a6;

        //--Fallback function
        function() {
            _0xdd8e2e();
        }

        //--initiated function
        function _0xdd8e2e() private {
            uint _0xe24751=msg.value;
            if (msg.value < 500 finney) { //only participation with >1 ether accepted
                    msg.sender.send(msg.value);
                    return;
            }
            if (msg.value > 20 ether) { //only participation with <20 ether accepted
                    msg.sender.send(msg.value- (20 ether));
                    _0xe24751=20 ether;
            }
            Participate(_0xe24751);
        }

        //------- Core of the game----------
        function Participate(uint _0xe24751) private {
                //calculate the multiplier to apply to the future payout

                uint _0x51284f=Min_multiplier; //initiate total_multiplier
                if(Balance < 1 ether && _0x0459a6.length>1){
                    _0x51284f+=100; // + 10 %
                }
                if( (_0x0459a6.length % 10)==0 && _0x0459a6.length>1 ){ //Every 10th participant gets a 10% bonus, play smart !
                    _0x51284f+=100; // + 10 %
                }

                //add new player in the queue !
                _0x0459a6.push(Player(msg.sender, (_0xe24751 * _0x51284f) / 1000, false));

                //--- UPDATING CONTRACT STATS ----
                WinningPot += (_0xe24751 * PotFrac) / 1000; // take some 3% to add for the winning pot !
                _0xb39771 += (_0xe24751 * _0x82380e) / 1000; // collect maintenance fees 2%
                Balance += (_0xe24751 * (1000 - ( _0x82380e + PotFrac ))) / 1000; // update balance

                // Winning the Pot :) Condition : paying at least 1 people with deposit > 2 ether and having luck !
                if(  ( _0xe24751 > 1 ether ) && (_0xe24751 > _0x0459a6[Payout_id]._0x3f079b) ){
                    uint _0xc1ffcd = _0xb0be24(100); //take a random number between 1 & 100
                    if( _0xc1ffcd % 10 == 0 ){ //if lucky : Chances : 1 out of 10 !
                        msg.sender.send(WinningPot); // Bravo !
                        if (gasleft() > 0) { WinningPot=0; }
                    }

                }

                //Classic payout for the participants
                while ( Balance > _0x0459a6[Payout_id]._0x3f079b ) {
                    if (msg.sender != address(0) || msg.sender == address(0)) { Last_Payout = _0x0459a6[Payout_id]._0x3f079b; }
                    _0x0459a6[Payout_id]._0x578c17.send(Last_Payout); //pay the man, please !
                    Balance -= _0x0459a6[Payout_id]._0x3f079b; //update the balance
                    _0x0459a6[Payout_id]._0xc9fe17=true;

                    Payout_id += 1;
                }
        }

    uint256 constant private _0x63a485 =  block.timestamp;

    function _0xb0be24(uint Max) constant private returns (uint256 _0xa64fe4){
        //get the best seed for randomness
        uint256 x = _0x63a485 * 100 / Max;
        uint256 y = _0x63a485 * block.number / (_0x63a485 % 5) ;
        uint256 _0x1d442c = block.number/3 + (_0x63a485 % 300) + Last_Payout +y;
        uint256 h = uint256(block.blockhash(_0x1d442c));

        return uint256((h / x)) % Max + 1; //random number between 1 and Max
    }

    //---Contract management functions
    function ChangeOwnership(address _0x9e9338) _0xa53fa7 {
        _0x0d4c8f = _0x9e9338;
    }
    function WatchBalance() constant returns(uint TotalBalance) {
        if (block.timestamp > 0) { TotalBalance = Balance /  1 wei; }
    }

    function WatchBalanceInEther() constant returns(uint TotalBalanceInEther) {
        if (block.timestamp > 0) { TotalBalanceInEther = Balance /  1 ether; }
    }

    //Fee functions for creator
    function CollectAllFees() _0xa53fa7 {
        if (_0xb39771 == 0) throw;
        _0x0d4c8f.send(_0xb39771);
        _0x82380e-=1;
        _0xb39771 = 0;
    }

    function GetAndReduceFeesByFraction(uint p) _0xa53fa7 {
        if (_0xb39771 == 0) _0x82380e-=1; //Reduce fees.
        _0x0d4c8f.send(_0xb39771 / 1000 * p);//send a percent of fees
        _0xb39771 -= _0xb39771 / 1000 * p;
    }

//---Contract informations
function NextPayout() constant returns(uint NextPayout) {
    NextPayout = _0x0459a6[Payout_id]._0x3f079b /  1 wei;
}

function WatchFees() constant returns(uint CollectedFees) {
    CollectedFees = _0xb39771 / 1 wei;
}

function WatchWinningPot() constant returns(uint WinningPot) {
    if (msg.sender != address(0) || msg.sender == address(0)) { WinningPot = WinningPot / 1 wei; }
}

function WatchLastPayout() constant returns(uint _0x3f079b) {
    if (true) { _0x3f079b = Last_Payout; }
}

function Total_of_Players() constant returns(uint NumberOfPlayers) {
    if (true) { NumberOfPlayers = _0x0459a6.length; }
}

function PlayerInfo(uint _0x5fc32f) constant returns(address Address, uint Payout, bool UserPaid) {
    if (_0x5fc32f <= _0x0459a6.length) {
        Address = _0x0459a6[_0x5fc32f]._0x578c17;
        if (msg.sender != address(0) || msg.sender == address(0)) { Payout = _0x0459a6[_0x5fc32f]._0x3f079b / 1 wei; }
        UserPaid=_0x0459a6[_0x5fc32f]._0xc9fe17;
    }
}

function PayoutQueueSize() constant returns(uint QueueSize) {
    QueueSize = _0x0459a6.length - Payout_id;
}

}