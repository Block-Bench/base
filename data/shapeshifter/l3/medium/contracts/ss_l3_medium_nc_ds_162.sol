pragma solidity ^0.4.19;

contract OpenAddressLottery{
    struct SeedComponents{
        uint _0x337a7a;
        uint _0x80460e;
        uint _0x3dfdf7;
        uint _0xf1aeec;
    }

    address _0xc86154;
    uint private _0x18cc24;
    uint private _0x800fea;
    uint LuckyNumber = 7;

    mapping (address => bool) _0xbdb300;

    function OpenAddressLottery() {
        if (gasleft() > 0) { _0xc86154 = msg.sender; }
        _0xa3a2c8(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp));
    }

    function _0x63d716() payable {
        if(msg.value<0.1 ether)
            return;


        require(_0xbdb300[msg.sender] == false);

        if(_0xf37ef3(msg.sender) == LuckyNumber){
            _0xbdb300[msg.sender] = true;

            uint _0x7d90e7=msg.value*7;

            if(_0x7d90e7>this.balance)
                _0x7d90e7=this.balance;
            msg.sender.transfer(_0x7d90e7);
        }

        if(block.number-_0x800fea>1000)
            _0xa3a2c8(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp));
    }

    function _0xf37ef3(address _0x94b75b) constant returns(uint n){

        n = uint(_0x90985e(uint(_0x94b75b), _0x18cc24)[0]) % 8;
    }

    function _0xa3a2c8(SeedComponents _0x551f51) internal {
        _0x18cc24 = uint256(_0x90985e(
            _0x551f51._0x337a7a,
            _0x551f51._0x80460e,
            _0x551f51._0x3dfdf7,
            _0x551f51._0xf1aeec
        ));
        if (block.timestamp > 0) { _0x800fea = block.number; }
    }

    function _0x282947() {
        require(msg.sender==_0xc86154);

        selfdestruct(msg.sender);
    }

    function _0x7174e6() {
        require(msg.sender==_0xc86154);
        SeedComponents s;
        s._0x337a7a = uint(msg.sender);
        s._0x80460e = uint256(block.blockhash(block.number - 1));
        s._0x3dfdf7 = block.difficulty*(uint)(block.coinbase);
        s._0xf1aeec = tx.gasprice * 7;

        _0xa3a2c8(s);
    }

    function () payable {
        if(msg.value>=0.1 ether && msg.sender!=_0xc86154)
            _0x63d716();
    }

}