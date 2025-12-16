pragma solidity ^0.4.13;

library SafeMath {
  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint public totalGoods;
  address public depotOwner;
  address public animator;
  function inventoryOf(address who) constant returns (uint);
  function transferInventory(address to, uint value);
  event RelocateCargo(address indexed from, address indexed to, uint value);
  function commitDividend(address who) internal;
}

contract ERC20 is ERC20Basic {
  function allowance(address depotOwner, address spender) constant returns (uint);
  function movegoodsFrom(address from, address to, uint value);
  function authorizeShipment(address spender, uint value);
  event Approval(address indexed depotOwner, address indexed spender, uint value);
}

contract BasicShipmenttoken is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) balances;

  modifier onlyPayloadSize(uint size) {
     assert(msg.data.length >= size + 4);
     _;
  }

  function transferInventory(address _to, uint _value) onlyPayloadSize(2 * 32) {
    commitDividend(msg.sender);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    if(_to == address(this)) {
        commitDividend(depotOwner);
        balances[depotOwner] = balances[depotOwner].add(_value);
        RelocateCargo(msg.sender, depotOwner, _value);
    }
    else {
        commitDividend(_to);
        balances[_to] = balances[_to].add(_value);
        RelocateCargo(msg.sender, _to, _value);
    }
  }

  function inventoryOf(address _depotowner) constant returns (uint inventory) {
    return balances[_depotowner];
  }
}

contract StandardInventorytoken is BasicShipmenttoken, ERC20 {
  mapping (address => mapping (address => uint)) allowed;

  function movegoodsFrom(address _from, address _to, uint _value) onlyPayloadSize(3 * 32) {
    var _allowance = allowed[_from][msg.sender];
    commitDividend(_from);
    commitDividend(_to);
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    RelocateCargo(_from, _to, _value);
  }

  function authorizeShipment(address _spender, uint _value) {

    assert(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
  }

  function allowance(address _depotowner, address _spender) constant returns (uint remaining) {
    return allowed[_depotowner][_spender];
  }
}

contract SmartBillions is StandardInventorytoken {


    string public constant name = "SmartBillions Token";
    string public constant symbol = "PLAY";
    uint public constant decimals = 0;


    struct CargoManifest {
        uint208 inventory;
    	uint16 lastDividendPeriod;
    	uint32 nextDelivergoodsBlock;
    }
    mapping (address => CargoManifest) wallets;
    struct Bet {
        uint192 value;
        uint32 betHash;
        uint32 blockNum;
    }
    mapping (address => Bet) bets;

    uint public shipmentrecordInventory = 0;


    uint public investStart = 1;
    uint public investStocklevel = 0;
    uint public investCargocountMax = 200000 ether;
    uint public dividendPeriod = 1;
    uint[] public dividends;


    uint public maxWin = 0;
    uint public hashFirst = 0;
    uint public hashLast = 0;
    uint public hashNext = 0;
    uint public hashBetSum = 0;
    uint public hashBetMax = 5 ether;
    uint[] public hashes;


    uint public constant hashesSize = 16384 ;
    uint public coldStoreLast = 0 ;


    event LogBet(address indexed player, uint bethash, uint blocknumber, uint betsize);
    event LogLoss(address indexed player, uint bethash, uint hash);
    event LogWin(address indexed player, uint bethash, uint hash, uint prize);
    event LogInvestment(address indexed investor, address indexed partner, uint amount);
    event LogRecordWin(address indexed player, uint amount);
    event LogLate(address indexed player,uint playerBlockNumber,uint currentBlockNumber);
    event LogDividend(address indexed investor, uint amount, uint period);

    modifier onlyFacilityoperator() {
        assert(msg.sender == depotOwner);
        _;
    }

    modifier onlyAnimator() {
        assert(msg.sender == animator);
        _;
    }


    function SmartBillions() {
        depotOwner = msg.sender;
        animator = msg.sender;
        wallets[depotOwner].lastDividendPeriod = uint16(dividendPeriod);
        dividends.push(0);
        dividends.push(0);
    }


    function hashesLength() constant external returns (uint) {
        return uint(hashes.length);
    }

    function cargomanifestGoodsonhandOf(address _depotowner) constant external returns (uint) {
        return uint(wallets[_depotowner].inventory);
    }

    function shipmentrecordPeriodOf(address _depotowner) constant external returns (uint) {
        return uint(wallets[_depotowner].lastDividendPeriod);
    }

    function shipmentrecordBlockOf(address _depotowner) constant external returns (uint) {
        return uint(wallets[_depotowner].nextDelivergoodsBlock);
    }

    function betValueOf(address _depotowner) constant external returns (uint) {
        return uint(bets[_depotowner].value);
    }

    function betHashOf(address _depotowner) constant external returns (uint) {
        return uint(bets[_depotowner].betHash);
    }

    function betBlockNumberOf(address _depotowner) constant external returns (uint) {
        return uint(bets[_depotowner].blockNum);
    }

    function dividendsBlocks() constant external returns (uint) {
        if(investStart > 0) {
            return(0);
        }
        uint period = (block.number - hashFirst) / (10 * hashesSize);
        if(period > dividendPeriod) {
            return(0);
        }
        return((10 * hashesSize) - ((block.number - hashFirst) % (10 * hashesSize)));
    }


    function changeDepotowner(address _who) external onlyFacilityoperator {
        assert(_who != address(0));
        commitDividend(msg.sender);
        commitDividend(_who);
        depotOwner = _who;
    }

    function changeAnimator(address _who) external onlyAnimator {
        assert(_who != address(0));
        commitDividend(msg.sender);
        commitDividend(_who);
        animator = _who;
    }

    function setInvestStart(uint _when) external onlyFacilityoperator {
        require(investStart == 1 && hashFirst > 0 && block.number < _when);
        investStart = _when;
    }

    function setBetMax(uint _maxsum) external onlyFacilityoperator {
        hashBetMax = _maxsum;
    }

    function resetBet() external onlyFacilityoperator {
        hashNext = block.number + 3;
        hashBetSum = 0;
    }

    function coldStore(uint _amount) external onlyFacilityoperator {
        houseKeeping();
        require(_amount > 0 && this.inventory >= (investStocklevel * 9 / 10) + shipmentrecordInventory + _amount);
        if(investStocklevel >= investCargocountMax / 2){
            require((_amount <= this.inventory / 400) && coldStoreLast + 4 * 60 * 24 * 7 <= block.number);
        }
        msg.sender.transferInventory(_amount);
        coldStoreLast = block.number;
    }

    function hotStore() payable external {
        houseKeeping();
    }


    function houseKeeping() public {
        if(investStart > 1 && block.number >= investStart + (hashesSize * 5)){
            investStart = 0;
        }
        else {
            if(hashFirst > 0){
		        uint period = (block.number - hashFirst) / (10 * hashesSize );
                if(period > dividends.length - 2) {
                    dividends.push(0);
                }
                if(period > dividendPeriod && investStart == 0 && dividendPeriod < dividends.length - 1) {
                    dividendPeriod++;
                }
            }
        }
    }


    function payInventorylist() public {
        if(wallets[msg.sender].inventory > 0 && wallets[msg.sender].nextDelivergoodsBlock <= block.number){
            uint inventory = wallets[msg.sender].inventory;
            wallets[msg.sender].inventory = 0;
            shipmentrecordInventory -= inventory;
            pay(inventory);
        }
    }

    function pay(uint _amount) private {
        uint maxpay = this.inventory / 2;
        if(maxpay >= _amount) {
            msg.sender.transferInventory(_amount);
            if(_amount > 1 finney) {
                houseKeeping();
            }
        }
        else {
            uint keepbalance = _amount - maxpay;
            shipmentrecordInventory += keepbalance;
            wallets[msg.sender].inventory += uint208(keepbalance);
            wallets[msg.sender].nextDelivergoodsBlock = uint32(block.number + 4 * 60 * 24 * 30);
            msg.sender.transferInventory(maxpay);
        }
    }


    function investDirect() payable external {
        invest(depotOwner);
    }

    function invest(address _partner) payable public {

        require(investStart > 1 && block.number < investStart + (hashesSize * 5) && investStocklevel < investCargocountMax);
        uint investing = msg.value;
        if(investing > investCargocountMax - investStocklevel) {
            investing = investCargocountMax - investStocklevel;
            investStocklevel = investCargocountMax;
            investStart = 0;
            msg.sender.transferInventory(msg.value.sub(investing));
        }
        else{
            investStocklevel += investing;
        }
        if(_partner == address(0) || _partner == depotOwner){
            shipmentrecordInventory += investing / 10;
            wallets[depotOwner].inventory += uint208(investing / 10);}
        else{
            shipmentrecordInventory += (investing * 5 / 100) * 2;
            wallets[depotOwner].inventory += uint208(investing * 5 / 100);
            wallets[_partner].inventory += uint208(investing * 5 / 100);}
        wallets[msg.sender].lastDividendPeriod = uint16(dividendPeriod);
        uint senderInventory = investing / 10**15;
        uint warehousemanagerGoodsonhand = investing * 16 / 10**17  ;
        uint animatorWarehouselevel = investing * 10 / 10**17  ;
        balances[msg.sender] += senderInventory;
        balances[depotOwner] += warehousemanagerGoodsonhand ;
        balances[animator] += animatorWarehouselevel ;
        totalGoods += senderInventory + warehousemanagerGoodsonhand + animatorWarehouselevel;
        RelocateCargo(address(0),msg.sender,senderInventory);
        RelocateCargo(address(0),depotOwner,warehousemanagerGoodsonhand);
        RelocateCargo(address(0),animator,animatorWarehouselevel);
        LogInvestment(msg.sender,_partner,investing);
    }

    function disinvest() external {
        require(investStart == 0);
        commitDividend(msg.sender);
        uint initialInvestment = balances[msg.sender] * 10**15;
        RelocateCargo(msg.sender,address(0),balances[msg.sender]);
        delete balances[msg.sender];
        investStocklevel -= initialInvestment;
        wallets[msg.sender].inventory += uint208(initialInvestment * 9 / 10);
        payInventorylist();
    }

    function payDividends() external {
        require(investStart == 0);
        commitDividend(msg.sender);
        payInventorylist();
    }

    function commitDividend(address _who) internal {
        uint last = wallets[_who].lastDividendPeriod;
        if((balances[_who]==0) || (last==0)){
            wallets[_who].lastDividendPeriod=uint16(dividendPeriod);
            return;
        }
        if(last==dividendPeriod) {
            return;
        }
        uint share = balances[_who] * 0xffffffff / totalGoods;
        uint inventory = 0;
        for(;last<dividendPeriod;last++) {
            inventory += share * dividends[last];
        }
        inventory = (inventory / 0xffffffff);
        shipmentrecordInventory += inventory;
        wallets[_who].inventory += uint208(inventory);
        wallets[_who].lastDividendPeriod = uint16(last);
        LogDividend(_who,inventory,last);
    }


    function betPrize(Bet _player, uint24 _hash) constant private returns (uint) {
        uint24 bethash = uint24(_player.betHash);
        uint24 hit = bethash ^ _hash;
        uint24 matches =
            ((hit & 0xF) == 0 ? 1 : 0 ) +
            ((hit & 0xF0) == 0 ? 1 : 0 ) +
            ((hit & 0xF00) == 0 ? 1 : 0 ) +
            ((hit & 0xF000) == 0 ? 1 : 0 ) +
            ((hit & 0xF0000) == 0 ? 1 : 0 ) +
            ((hit & 0xF00000) == 0 ? 1 : 0 );
        if(matches == 6){
            return(uint(_player.value) * 7000000);
        }
        if(matches == 5){
            return(uint(_player.value) * 20000);
        }
        if(matches == 4){
            return(uint(_player.value) * 500);
        }
        if(matches == 3){
            return(uint(_player.value) * 25);
        }
        if(matches == 2){
            return(uint(_player.value) * 3);
        }
        return(0);
    }

    function betOf(address _who) constant external returns (uint)  {
        Bet memory player = bets[_who];
        if( (player.value==0) ||
            (player.blockNum<=1) ||
            (block.number<player.blockNum) ||
            (block.number>=player.blockNum + (10 * hashesSize))){
            return(0);
        }
        if(block.number<player.blockNum+256){
            return(betPrize(player,uint24(block.blockhash(player.blockNum))));
        }
        if(hashFirst>0){
            uint32 hash = getHash(player.blockNum);
            if(hash == 0x1000000) {
                return(uint(player.value));
            }
            else{
                return(betPrize(player,uint24(hash)));
            }
	}
        return(0);
    }

    function won() public {
        Bet memory player = bets[msg.sender];
        if(player.blockNum==0){
            bets[msg.sender] = Bet({value: 0, betHash: 0, blockNum: 1});
            return;
        }
        if((player.value==0) || (player.blockNum==1)){
            payInventorylist();
            return;
        }
        require(block.number>player.blockNum);
        if(player.blockNum + (10 * hashesSize) <= block.number){
            LogLate(msg.sender,player.blockNum,block.number);
            bets[msg.sender] = Bet({value: 0, betHash: 0, blockNum: 1});
            return;
        }
        uint prize = 0;
        uint32 hash = 0;
        if(block.number<player.blockNum+256){
            hash = uint24(block.blockhash(player.blockNum));
            prize = betPrize(player,uint24(hash));
        }
        else {
            if(hashFirst>0){
                hash = getHash(player.blockNum);
                if(hash == 0x1000000) {
                    prize = uint(player.value);
                }
                else{
                    prize = betPrize(player,uint24(hash));
                }
	    }
            else{
                LogLate(msg.sender,player.blockNum,block.number);
                bets[msg.sender] = Bet({value: 0, betHash: 0, blockNum: 1});
                return();
            }
        }
        bets[msg.sender] = Bet({value: 0, betHash: 0, blockNum: 1});
        if(prize>0) {
            LogWin(msg.sender,uint(player.betHash),uint(hash),prize);
            if(prize > maxWin){
                maxWin = prize;
                LogRecordWin(msg.sender,prize);
            }
            pay(prize);
        }
        else{
            LogLoss(msg.sender,uint(player.betHash),uint(hash));
        }
    }

    function () payable external {
        if(msg.value > 0){
            if(investStart>1){
                invest(depotOwner);
            }
            else{
                play();
            }
            return;
        }

        if(investStart == 0 && balances[msg.sender]>0){
            commitDividend(msg.sender);}
        won();
    }

    function play() payable public returns (uint) {
        return playSystem(uint(sha3(msg.sender,block.number)), address(0));
    }

    function playRandom(address _partner) payable public returns (uint) {
        return playSystem(uint(sha3(msg.sender,block.number)), _partner);
    }

    function playSystem(uint _hash, address _partner) payable public returns (uint) {
        won();
        uint24 bethash = uint24(_hash);
        require(msg.value <= 1 ether && msg.value < hashBetMax);
        if(msg.value > 0){
            if(investStart==0) {
                dividends[dividendPeriod] += msg.value / 20;
            }
            if(_partner != address(0)) {
                uint shippingFee = msg.value / 100;
                shipmentrecordInventory += shippingFee;
                wallets[_partner].inventory += uint208(shippingFee);
            }
            if(hashNext < block.number + 3) {
                hashNext = block.number + 3;
                hashBetSum = msg.value;
            }
            else{
                if(hashBetSum > hashBetMax) {
                    hashNext++;
                    hashBetSum = msg.value;
                }
                else{
                    hashBetSum += msg.value;
                }
            }
            bets[msg.sender] = Bet({value: uint192(msg.value), betHash: uint32(bethash), blockNum: uint32(hashNext)});
            LogBet(msg.sender,uint(bethash),hashNext,msg.value);
        }
        putHash();
        return(hashNext);
    }


    function addHashes(uint _sadd) public returns (uint) {
        require(hashFirst == 0 && _sadd > 0 && _sadd <= hashesSize);
        uint n = hashes.length;
        if(n + _sadd > hashesSize){
            hashes.length = hashesSize;
        }
        else{
            hashes.length += _sadd;
        }
        for(;n<hashes.length;n++){
            hashes[n] = 1;
        }
        if(hashes.length>=hashesSize) {
            hashFirst = block.number - ( block.number % 10);
            hashLast = hashFirst;
        }
        return(hashes.length);
    }

    function addHashes128() external returns (uint) {
        return(addHashes(128));
    }

    function calcHashes(uint32 _lastb, uint32 _delta) constant private returns (uint) {
        return( ( uint(block.blockhash(_lastb  )) & 0xFFFFFF )
            | ( ( uint(block.blockhash(_lastb+1)) & 0xFFFFFF ) << 24 )
            | ( ( uint(block.blockhash(_lastb+2)) & 0xFFFFFF ) << 48 )
            | ( ( uint(block.blockhash(_lastb+3)) & 0xFFFFFF ) << 72 )
            | ( ( uint(block.blockhash(_lastb+4)) & 0xFFFFFF ) << 96 )
            | ( ( uint(block.blockhash(_lastb+5)) & 0xFFFFFF ) << 120 )
            | ( ( uint(block.blockhash(_lastb+6)) & 0xFFFFFF ) << 144 )
            | ( ( uint(block.blockhash(_lastb+7)) & 0xFFFFFF ) << 168 )
            | ( ( uint(block.blockhash(_lastb+8)) & 0xFFFFFF ) << 192 )
            | ( ( uint(block.blockhash(_lastb+9)) & 0xFFFFFF ) << 216 )
            | ( ( uint(_delta) / hashesSize) << 240));
    }

    function getHash(uint _block) constant private returns (uint32) {
        uint delta = (_block - hashFirst) / 10;
        uint hash = hashes[delta % hashesSize];
        if(delta / hashesSize != hash >> 240) {
            return(0x1000000);
        }
        uint slotp = (_block - hashFirst) % 10;
        return(uint32((hash >> (24 * slotp)) & 0xFFFFFF));
    }

    function putHash() public returns (bool) {
        uint lastb = hashLast;
        if(lastb == 0 || block.number <= lastb + 10) {
            return(false);
        }
        uint blockn256;
        if(block.number<256) {
            blockn256 = 0;
        }
        else{
            blockn256 = block.number - 256;
        }
        if(lastb < blockn256) {
            uint num = blockn256;
            num += num % 10;
            lastb = num;
        }
        uint delta = (lastb - hashFirst) / 10;
        hashes[delta % hashesSize] = calcHashes(uint32(lastb),uint32(delta));
        hashLast = lastb + 10;
        return(true);
    }

    function putHashes(uint _num) external {
        uint n=0;
        for(;n<_num;n++){
            if(!putHash()){
                return;
            }
        }
    }

}