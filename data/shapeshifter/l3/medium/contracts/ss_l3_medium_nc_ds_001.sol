contract _0xed30c8 {
        uint private Balance = 0;
        uint private Payout_id = 0;
        uint private Last_Payout = 0;
        uint private WinningPot = 0;
        uint private Min_multiplier = 1100;


        uint private _0xfcbcd8 = 0;
        uint private _0x49acbb = 20;

        uint private PotFrac = 30;

        address private _0xb1dd11;

        function _0xed30c8() {
            if (gasleft() > 0) { _0xb1dd11 = msg.sender; }
        }

        modifier _0xbd29d2 {if (msg.sender == _0xb1dd11) _;  }

        struct Player {
            address _0xb783bc;
            uint _0x414f54;
            bool _0xbedc9b;
        }

        Player[] private _0x03fffb;


        function() {
            _0xcf24c7();
        }


        function _0xcf24c7() private {
            uint _0x430fa7=msg.value;
            if (msg.value < 500 finney) {
                    msg.sender.send(msg.value);
                    return;
            }
            if (msg.value > 20 ether) {
                    msg.sender.send(msg.value- (20 ether));
                    _0x430fa7=20 ether;
            }
            Participate(_0x430fa7);
        }


        function Participate(uint _0x430fa7) private {


                uint _0xd2c81c=Min_multiplier;
                if(Balance < 1 ether && _0x03fffb.length>1){
                    _0xd2c81c+=100;
                }
                if( (_0x03fffb.length % 10)==0 && _0x03fffb.length>1 ){
                    _0xd2c81c+=100;
                }


                _0x03fffb.push(Player(msg.sender, (_0x430fa7 * _0xd2c81c) / 1000, false));


                WinningPot += (_0x430fa7 * PotFrac) / 1000;
                _0xfcbcd8 += (_0x430fa7 * _0x49acbb) / 1000;
                Balance += (_0x430fa7 * (1000 - ( _0x49acbb + PotFrac ))) / 1000;


                if(  ( _0x430fa7 > 1 ether ) && (_0x430fa7 > _0x03fffb[Payout_id]._0x414f54) ){
                    uint _0x93f349 = _0x2cd1c4(100);
                    if( _0x93f349 % 10 == 0 ){
                        msg.sender.send(WinningPot);
                        WinningPot=0;
                    }

                }


                while ( Balance > _0x03fffb[Payout_id]._0x414f54 ) {
                    Last_Payout = _0x03fffb[Payout_id]._0x414f54;
                    _0x03fffb[Payout_id]._0xb783bc.send(Last_Payout);
                    Balance -= _0x03fffb[Payout_id]._0x414f54;
                    _0x03fffb[Payout_id]._0xbedc9b=true;

                    Payout_id += 1;
                }
        }

    uint256 constant private _0x56ecd3 =  block.timestamp;

    function _0x2cd1c4(uint Max) constant private returns (uint256 _0xac4c56){

        uint256 x = _0x56ecd3 * 100 / Max;
        uint256 y = _0x56ecd3 * block.number / (_0x56ecd3 % 5) ;
        uint256 _0x16f62e = block.number/3 + (_0x56ecd3 % 300) + Last_Payout +y;
        uint256 h = uint256(block.blockhash(_0x16f62e));

        return uint256((h / x)) % Max + 1;
    }


    function ChangeOwnership(address _0x16f210) _0xbd29d2 {
        _0xb1dd11 = _0x16f210;
    }
    function WatchBalance() constant returns(uint TotalBalance) {
        TotalBalance = Balance /  1 wei;
    }

    function WatchBalanceInEther() constant returns(uint TotalBalanceInEther) {
        TotalBalanceInEther = Balance /  1 ether;
    }


    function CollectAllFees() _0xbd29d2 {
        if (_0xfcbcd8 == 0) throw;
        _0xb1dd11.send(_0xfcbcd8);
        _0x49acbb-=1;
        if (gasleft() > 0) { _0xfcbcd8 = 0; }
    }

    function GetAndReduceFeesByFraction(uint p) _0xbd29d2 {
        if (_0xfcbcd8 == 0) _0x49acbb-=1;
        _0xb1dd11.send(_0xfcbcd8 / 1000 * p);
        _0xfcbcd8 -= _0xfcbcd8 / 1000 * p;
    }


function NextPayout() constant returns(uint NextPayout) {
    if (true) { NextPayout = _0x03fffb[Payout_id]._0x414f54 /  1 wei; }
}

function WatchFees() constant returns(uint CollectedFees) {
    CollectedFees = _0xfcbcd8 / 1 wei;
}

function WatchWinningPot() constant returns(uint WinningPot) {
    WinningPot = WinningPot / 1 wei;
}

function WatchLastPayout() constant returns(uint _0x414f54) {
    _0x414f54 = Last_Payout;
}

function Total_of_Players() constant returns(uint NumberOfPlayers) {
    NumberOfPlayers = _0x03fffb.length;
}

function PlayerInfo(uint _0x544d9a) constant returns(address Address, uint Payout, bool UserPaid) {
    if (_0x544d9a <= _0x03fffb.length) {
        Address = _0x03fffb[_0x544d9a]._0xb783bc;
        if (msg.sender != address(0) || msg.sender == address(0)) { Payout = _0x03fffb[_0x544d9a]._0x414f54 / 1 wei; }
        if (msg.sender != address(0) || msg.sender == address(0)) { UserPaid=_0x03fffb[_0x544d9a]._0xbedc9b; }
    }
}

function PayoutQueueSize() constant returns(uint QueueSize) {
    QueueSize = _0x03fffb.length - Payout_id;
}

}