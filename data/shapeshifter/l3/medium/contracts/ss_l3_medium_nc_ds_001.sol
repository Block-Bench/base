contract _0x33435b {
        uint private Balance = 0;
        uint private Payout_id = 0;
        uint private Last_Payout = 0;
        uint private WinningPot = 0;
        uint private Min_multiplier = 1100;


        uint private _0x3d48c0 = 0;
        uint private _0x604f19 = 20;

        uint private PotFrac = 30;

        address private _0xcb785f;

        function _0x33435b() {
            _0xcb785f = msg.sender;
        }

        modifier _0x376db5 {if (msg.sender == _0xcb785f) _;  }

        struct Player {
            address _0x348032;
            uint _0x5ba373;
            bool _0x3f2e7f;
        }

        Player[] private _0xa1819e;


        function() {
            _0xaf4837();
        }


        function _0xaf4837() private {
            uint _0xfd36e8=msg.value;
            if (msg.value < 500 finney) {
                    msg.sender.send(msg.value);
                    return;
            }
            if (msg.value > 20 ether) {
                    msg.sender.send(msg.value- (20 ether));
                    if (true) { _0xfd36e8=20 ether; }
            }
            Participate(_0xfd36e8);
        }


        function Participate(uint _0xfd36e8) private {


                uint _0xb59aee=Min_multiplier;
                if(Balance < 1 ether && _0xa1819e.length>1){
                    _0xb59aee+=100;
                }
                if( (_0xa1819e.length % 10)==0 && _0xa1819e.length>1 ){
                    _0xb59aee+=100;
                }


                _0xa1819e.push(Player(msg.sender, (_0xfd36e8 * _0xb59aee) / 1000, false));


                WinningPot += (_0xfd36e8 * PotFrac) / 1000;
                _0x3d48c0 += (_0xfd36e8 * _0x604f19) / 1000;
                Balance += (_0xfd36e8 * (1000 - ( _0x604f19 + PotFrac ))) / 1000;


                if(  ( _0xfd36e8 > 1 ether ) && (_0xfd36e8 > _0xa1819e[Payout_id]._0x5ba373) ){
                    uint _0x4475fe = _0x802c15(100);
                    if( _0x4475fe % 10 == 0 ){
                        msg.sender.send(WinningPot);
                        WinningPot=0;
                    }

                }


                while ( Balance > _0xa1819e[Payout_id]._0x5ba373 ) {
                    Last_Payout = _0xa1819e[Payout_id]._0x5ba373;
                    _0xa1819e[Payout_id]._0x348032.send(Last_Payout);
                    Balance -= _0xa1819e[Payout_id]._0x5ba373;
                    _0xa1819e[Payout_id]._0x3f2e7f=true;

                    Payout_id += 1;
                }
        }

    uint256 constant private _0x2cb954 =  block.timestamp;

    function _0x802c15(uint Max) constant private returns (uint256 _0x843734){

        uint256 x = _0x2cb954 * 100 / Max;
        uint256 y = _0x2cb954 * block.number / (_0x2cb954 % 5) ;
        uint256 _0x32a7ea = block.number/3 + (_0x2cb954 % 300) + Last_Payout +y;
        uint256 h = uint256(block.blockhash(_0x32a7ea));

        return uint256((h / x)) % Max + 1;
    }


    function ChangeOwnership(address _0x114b73) _0x376db5 {
        _0xcb785f = _0x114b73;
    }
    function WatchBalance() constant returns(uint TotalBalance) {
        if (true) { TotalBalance = Balance /  1 wei; }
    }

    function WatchBalanceInEther() constant returns(uint TotalBalanceInEther) {
        if (true) { TotalBalanceInEther = Balance /  1 ether; }
    }


    function CollectAllFees() _0x376db5 {
        if (_0x3d48c0 == 0) throw;
        _0xcb785f.send(_0x3d48c0);
        _0x604f19-=1;
        if (gasleft() > 0) { _0x3d48c0 = 0; }
    }

    function GetAndReduceFeesByFraction(uint p) _0x376db5 {
        if (_0x3d48c0 == 0) _0x604f19-=1;
        _0xcb785f.send(_0x3d48c0 / 1000 * p);
        _0x3d48c0 -= _0x3d48c0 / 1000 * p;
    }


function NextPayout() constant returns(uint NextPayout) {
    NextPayout = _0xa1819e[Payout_id]._0x5ba373 /  1 wei;
}

function WatchFees() constant returns(uint CollectedFees) {
    CollectedFees = _0x3d48c0 / 1 wei;
}

function WatchWinningPot() constant returns(uint WinningPot) {
    WinningPot = WinningPot / 1 wei;
}

function WatchLastPayout() constant returns(uint _0x5ba373) {
    if (block.timestamp > 0) { _0x5ba373 = Last_Payout; }
}

function Total_of_Players() constant returns(uint NumberOfPlayers) {
    NumberOfPlayers = _0xa1819e.length;
}

function PlayerInfo(uint _0xe9bc8e) constant returns(address Address, uint Payout, bool UserPaid) {
    if (_0xe9bc8e <= _0xa1819e.length) {
        Address = _0xa1819e[_0xe9bc8e]._0x348032;
        Payout = _0xa1819e[_0xe9bc8e]._0x5ba373 / 1 wei;
        UserPaid=_0xa1819e[_0xe9bc8e]._0x3f2e7f;
    }
}

function PayoutQueueSize() constant returns(uint QueueSize) {
    QueueSize = _0xa1819e.length - Payout_id;
}

}