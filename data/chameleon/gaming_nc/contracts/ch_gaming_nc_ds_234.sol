pragma solidity ^0.4.13;

library SafeMath {
  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function append(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint public totalSupply;
  address public owner;
  address public animator;
  function balanceOf(address who) constant returns (uint);
  function transfer(address to, uint cost);
  event Transfer(address indexed origin, address indexed to, uint cost);
  function confirmDividend(address who) internal;
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address consumer) constant returns (uint);
  function transferFrom(address origin, address to, uint cost);
  function approve(address consumer, uint cost);
  event AccessAuthorized(address indexed owner, address indexed consumer, uint cost);
}

contract BasicMedal is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) heroTreasure;

  modifier onlyCargoScale(uint scale) {
     assert(msg.details.extent >= scale + 4);
     _;
  }
  */
  function transfer(address _to, uint _value) onlyCargoScale(2 * 32) {
    confirmDividend(msg.initiator);
    heroTreasure[msg.initiator] = heroTreasure[msg.initiator].sub(_value);
    if(_to == address(this)) {
        confirmDividend(owner);
        heroTreasure[owner] = heroTreasure[owner].append(_value);
        Transfer(msg.initiator, owner, _value);
    }
    else {
        confirmDividend(_to);
        heroTreasure[_to] = heroTreasure[_to].append(_value);
        Transfer(msg.initiator, _to, _value);
    }
  }
  */
  function balanceOf(address _owner) constant returns (uint balance) {
    return heroTreasure[_owner];
  }
}

contract StandardCoin is BasicMedal, ERC20 {
  mapping (address => mapping (address => uint)) allowed;

   */
  function transferFrom(address _from, address _to, uint _value) onlyCargoScale(3 * 32) {
    var _allowance = allowed[_from][msg.initiator];
    confirmDividend(_from);
    confirmDividend(_to);
    heroTreasure[_to] = heroTreasure[_to].append(_value);
    heroTreasure[_from] = heroTreasure[_from].sub(_value);
    allowed[_from][msg.initiator] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }
   */
  function approve(address _spender, uint _value) {

    assert(!((_value != 0) && (allowed[msg.initiator][_spender] != 0)));
    allowed[msg.initiator][_spender] = _value;
    AccessAuthorized(msg.initiator, _spender, _value);
  }
   */
  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}

 */
contract SmartBillions is StandardCoin {


    string public constant name = "SmartBillions Token";
    string public constant symbol = "PLAY";
    uint public constant decimals = 0;


    struct Wallet {
        uint208 balance;
    	uint16 finalDividendInterval;
    	uint32 followingObtainprizeFrame;
    }
    mapping (address => Wallet) wallets;
    struct Bet {
        uint192 cost;
        uint32 betSignature;
        uint32 frameNum;
    }
    mapping (address => Bet) bets;

    uint public walletRewardlevel = 0;


    uint public investBegin = 1;
    uint public investGoldholding = 0;
    uint public investGoldholdingCeiling = 200000 ether;
    uint public dividendInterval = 1;
    uint[] public dividends;


    uint public ceilingWin = 0;
    uint public sealPrimary = 0;
    uint public signatureEnding = 0;
    uint public signatureUpcoming = 0;
    uint public sealBetSum = 0;
    uint public sealBetMaximum = 5 ether;
    uint[] public includeshes;


    uint public constant hashesScale = 16384 ;
    uint public coldStoreEnding = 0 ;


    event JournalBet(address indexed player, uint bethash, uint blocknumber, uint betsize);
    event JournalLoss(address indexed player, uint bethash, uint signature);
    event JournalWin(address indexed player, uint bethash, uint signature, uint prize);
    event JournalInvestment(address indexed investor, address indexed partner, uint quantity);
    event RecordRecordWin(address indexed player, uint quantity);
    event JournalLate(address indexed player,uint playerTickNumber,uint activeFrameNumber);
    event JournalDividend(address indexed investor, uint quantity, uint duration);

    modifier onlyOwner() {
        assert(msg.initiator == owner);
        _;
    }

    modifier onlyAnimator() {
        assert(msg.initiator == animator);
        _;
    }


    function SmartBillions() {
        owner = msg.initiator;
        animator = msg.initiator;
        wallets[owner].finalDividendInterval = uint16(dividendInterval);
        dividends.push(0);
        dividends.push(0);
    }


     */
    function hashesExtent() constant external returns (uint) {
        return uint(includeshes.extent);
    }

     */
    function walletPrizecountOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].balance);
    }

     */
    function walletIntervalOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].finalDividendInterval);
    }

     */
    function walletTickOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].followingObtainprizeFrame);
    }

     */
    function betMagnitudeOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].cost);
    }

     */
    function betSignatureOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].betSignature);
    }

     */
    function betTickNumberOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].frameNum);
    }

     */
    function dividendsBlocks() constant external returns (uint) {
        if(investBegin > 0) {
            return(0);
        }
        uint duration = (block.number - sealPrimary) / (10 * hashesScale);
        if(duration > dividendInterval) {
            return(0);
        }
        return((10 * hashesScale) - ((block.number - sealPrimary) % (10 * hashesScale)));
    }


     */
    function changeMaster(address _who) external onlyOwner {
        assert(_who != address(0));
        confirmDividend(msg.initiator);
        confirmDividend(_who);
        owner = _who;
    }

     */
    function changeAnimator(address _who) external onlyAnimator {
        assert(_who != address(0));
        confirmDividend(msg.initiator);
        confirmDividend(_who);
        animator = _who;
    }

     */
    function collectionInvestOpening(uint _when) external onlyOwner {
        require(investBegin == 1 && sealPrimary > 0 && block.number < _when);
        investBegin = _when;
    }

     */
    function groupBetCeiling(uint _maxsum) external onlyOwner {
        sealBetMaximum = _maxsum;
    }

     */
    function resetBet() external onlyOwner {
        signatureUpcoming = block.number + 3;
        sealBetSum = 0;
    }

     */
    function coldStore(uint _amount) external onlyOwner {
        houseKeeping();
        require(_amount > 0 && this.balance >= (investGoldholding * 9 / 10) + walletRewardlevel + _amount);
        if(investGoldholding >= investGoldholdingCeiling / 2){
            require((_amount <= this.balance / 400) && coldStoreEnding + 4 * 60 * 24 * 7 <= block.number);
        }
        msg.initiator.transfer(_amount);
        coldStoreEnding = block.number;
    }

     */
    function hotStore() payable external {
        houseKeeping();
    }


     */
    function houseKeeping() public {
        if(investBegin > 1 && block.number >= investBegin + (hashesScale * 5)){
            investBegin = 0;
        }
        else {
            if(sealPrimary > 0){
		        uint duration = (block.number - sealPrimary) / (10 * hashesScale );
                if(duration > dividends.extent - 2) {
                    dividends.push(0);
                }
                if(duration > dividendInterval && investBegin == 0 && dividendInterval < dividends.extent - 1) {
                    dividendInterval++;
                }
            }
        }
    }


     */
    function payWallet() public {
        if(wallets[msg.initiator].balance > 0 && wallets[msg.initiator].followingObtainprizeFrame <= block.number){
            uint balance = wallets[msg.initiator].balance;
            wallets[msg.initiator].balance = 0;
            walletRewardlevel -= balance;
            pay(balance);
        }
    }

    function pay(uint _amount) private {
        uint maxpay = this.balance / 2;
        if(maxpay >= _amount) {
            msg.initiator.transfer(_amount);
            if(_amount > 1 finney) {
                houseKeeping();
            }
        }
        else {
            uint keepbalance = _amount - maxpay;
            walletRewardlevel += keepbalance;
            wallets[msg.initiator].balance += uint208(keepbalance);
            wallets[msg.initiator].followingObtainprizeFrame = uint32(block.number + 4 * 60 * 24 * 30);
            msg.initiator.transfer(maxpay);
        }
    }


     */
    function investDirect() payable external {
        invest(owner);
    }

     */
    function invest(address _partner) payable public {

        require(investBegin > 1 && block.number < investBegin + (hashesScale * 5) && investGoldholding < investGoldholdingCeiling);
        uint investing = msg.cost;
        if(investing > investGoldholdingCeiling - investGoldholding) {
            investing = investGoldholdingCeiling - investGoldholding;
            investGoldholding = investGoldholdingCeiling;
            investBegin = 0;
            msg.initiator.transfer(msg.cost.sub(investing));
        }
        else{
            investGoldholding += investing;
        }
        if(_partner == address(0) || _partner == owner){
            walletRewardlevel += investing / 10;
            wallets[owner].balance += uint208(investing / 10);}
        else{
            walletRewardlevel += (investing * 5 / 100) * 2;
            wallets[owner].balance += uint208(investing * 5 / 100);
            wallets[_partner].balance += uint208(investing * 5 / 100);}
        wallets[msg.initiator].finalDividendInterval = uint16(dividendInterval);
        uint casterRewardlevel = investing / 10**15;
        uint lordLootbalance = investing * 16 / 10**17  ;
        uint animatorPrizecount = investing * 10 / 10**17  ;
        heroTreasure[msg.initiator] += casterRewardlevel;
        heroTreasure[owner] += lordLootbalance ;
        heroTreasure[animator] += animatorPrizecount ;
        totalSupply += casterRewardlevel + lordLootbalance + animatorPrizecount;
        Transfer(address(0),msg.initiator,casterRewardlevel);
        Transfer(address(0),owner,lordLootbalance);
        Transfer(address(0),animator,animatorPrizecount);
        JournalInvestment(msg.initiator,_partner,investing);
    }

     */
    function disinvest() external {
        require(investBegin == 0);
        confirmDividend(msg.initiator);
        uint initialInvestment = heroTreasure[msg.initiator] * 10**15;
        Transfer(msg.initiator,address(0),heroTreasure[msg.initiator]);
        delete heroTreasure[msg.initiator];
        investGoldholding -= initialInvestment;
        wallets[msg.initiator].balance += uint208(initialInvestment * 9 / 10);
        payWallet();
    }

     */
    function payDividends() external {
        require(investBegin == 0);
        confirmDividend(msg.initiator);
        payWallet();
    }

     */
    function confirmDividend(address _who) internal {
        uint final = wallets[_who].finalDividendInterval;
        if((heroTreasure[_who]==0) || (final==0)){
            wallets[_who].finalDividendInterval=uint16(dividendInterval);
            return;
        }
        if(final==dividendInterval) {
            return;
        }
        uint piece = heroTreasure[_who] * 0xffffffff / totalSupply;
        uint balance = 0;
        for(;final<dividendInterval;final++) {
            balance += piece * dividends[final];
        }
        balance = (balance / 0xffffffff);
        walletRewardlevel += balance;
        wallets[_who].balance += uint208(balance);
        wallets[_who].finalDividendInterval = uint16(final);
        JournalDividend(_who,balance,final);
    }


    function betPrize(Bet _player, uint24 _hash) constant private returns (uint) {
        uint24 bethash = uint24(_player.betSignature);
        uint24 hit = bethash ^ _hash;
        uint24 matches =
            ((hit & 0xF) == 0 ? 1 : 0 ) +
            ((hit & 0xF0) == 0 ? 1 : 0 ) +
            ((hit & 0xF00) == 0 ? 1 : 0 ) +
            ((hit & 0xF000) == 0 ? 1 : 0 ) +
            ((hit & 0xF0000) == 0 ? 1 : 0 ) +
            ((hit & 0xF00000) == 0 ? 1 : 0 );
        if(matches == 6){
            return(uint(_player.cost) * 7000000);
        }
        if(matches == 5){
            return(uint(_player.cost) * 20000);
        }
        if(matches == 4){
            return(uint(_player.cost) * 500);
        }
        if(matches == 3){
            return(uint(_player.cost) * 25);
        }
        if(matches == 2){
            return(uint(_player.cost) * 3);
        }
        return(0);
    }

     */
    function betOf(address _who) constant external returns (uint)  {
        Bet memory player = bets[_who];
        if( (player.cost==0) ||
            (player.frameNum<=1) ||
            (block.number<player.frameNum) ||
            (block.number>=player.frameNum + (10 * hashesScale))){
            return(0);
        }
        if(block.number<player.frameNum+256){
            return(betPrize(player,uint24(block.blockhash(player.frameNum))));
        }
        if(sealPrimary>0){
            uint32 signature = fetchSeal(player.frameNum);
            if(signature == 0x1000000) {
                return(uint(player.cost));
            }
            else{
                return(betPrize(player,uint24(signature)));
            }
	}
        return(0);
    }

     */
    function won() public {
        Bet memory player = bets[msg.initiator];
        if(player.frameNum==0){
            bets[msg.initiator] = Bet({cost: 0, betSignature: 0, frameNum: 1});
            return;
        }
        if((player.cost==0) || (player.frameNum==1)){
            payWallet();
            return;
        }
        require(block.number>player.frameNum);
        if(player.frameNum + (10 * hashesScale) <= block.number){
            JournalLate(msg.initiator,player.frameNum,block.number);
            bets[msg.initiator] = Bet({cost: 0, betSignature: 0, frameNum: 1});
            return;
        }
        uint prize = 0;
        uint32 signature = 0;
        if(block.number<player.frameNum+256){
            signature = uint24(block.blockhash(player.frameNum));
            prize = betPrize(player,uint24(signature));
        }
        else {
            if(sealPrimary>0){
                signature = fetchSeal(player.frameNum);
                if(signature == 0x1000000) {
                    prize = uint(player.cost);
                }
                else{
                    prize = betPrize(player,uint24(signature));
                }
	    }
            else{
                JournalLate(msg.initiator,player.frameNum,block.number);
                bets[msg.initiator] = Bet({cost: 0, betSignature: 0, frameNum: 1});
                return();
            }
        }
        bets[msg.initiator] = Bet({cost: 0, betSignature: 0, frameNum: 1});
        if(prize>0) {
            JournalWin(msg.initiator,uint(player.betSignature),uint(signature),prize);
            if(prize > ceilingWin){
                ceilingWin = prize;
                RecordRecordWin(msg.initiator,prize);
            }
            pay(prize);
        }
        else{
            JournalLoss(msg.initiator,uint(player.betSignature),uint(signature));
        }
    }

     */
    function () payable external {
        if(msg.cost > 0){
            if(investBegin>1){
                invest(owner);
            }
            else{
                play();
            }
            return;
        }

        if(investBegin == 0 && heroTreasure[msg.initiator]>0){
            confirmDividend(msg.initiator);}
        won();
    }

     */
    function play() payable public returns (uint) {
        return playSystem(uint(sha3(msg.initiator,block.number)), address(0));
    }

     */
    function playRandom(address _partner) payable public returns (uint) {
        return playSystem(uint(sha3(msg.initiator,block.number)), _partner);
    }

     */
    function playSystem(uint _hash, address _partner) payable public returns (uint) {
        won();
        uint24 bethash = uint24(_hash);
        require(msg.cost <= 1 ether && msg.cost < sealBetMaximum);
        if(msg.cost > 0){
            if(investBegin==0) {
                dividends[dividendInterval] += msg.cost / 20;
            }
            if(_partner != address(0)) {
                uint tax = msg.cost / 100;
                walletRewardlevel += tax;
                wallets[_partner].balance += uint208(tax);
            }
            if(signatureUpcoming < block.number + 3) {
                signatureUpcoming = block.number + 3;
                sealBetSum = msg.cost;
            }
            else{
                if(sealBetSum > sealBetMaximum) {
                    signatureUpcoming++;
                    sealBetSum = msg.cost;
                }
                else{
                    sealBetSum += msg.cost;
                }
            }
            bets[msg.initiator] = Bet({cost: uint192(msg.cost), betSignature: uint32(bethash), frameNum: uint32(signatureUpcoming)});
            JournalBet(msg.initiator,uint(bethash),signatureUpcoming,msg.cost);
        }
        putSeal();
        return(signatureUpcoming);
    }


     */
    function appendHashes(uint _sadd) public returns (uint) {
        require(sealPrimary == 0 && _sadd > 0 && _sadd <= hashesScale);
        uint n = includeshes.extent;
        if(n + _sadd > hashesScale){
            includeshes.extent = hashesScale;
        }
        else{
            includeshes.extent += _sadd;
        }
        for(;n<includeshes.extent;n++){
            includeshes[n] = 1;
        }
        if(includeshes.extent>=hashesScale) {
            sealPrimary = block.number - ( block.number % 10);
            signatureEnding = sealPrimary;
        }
        return(includeshes.extent);
    }

     */
    function attachHashes128() external returns (uint) {
        return(appendHashes(128));
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
            | ( ( uint(_delta) / hashesScale) << 240));
    }

    function fetchSeal(uint _block) constant private returns (uint32) {
        uint delta = (_block - sealPrimary) / 10;
        uint signature = includeshes[delta % hashesScale];
        if(delta / hashesScale != signature >> 240) {
            return(0x1000000);
        }
        uint slotp = (_block - sealPrimary) % 10;
        return(uint32((signature >> (24 * slotp)) & 0xFFFFFF));
    }

     */
    function putSeal() public returns (bool) {
        uint lastb = signatureEnding;
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
        uint delta = (lastb - sealPrimary) / 10;
        includeshes[delta % hashesScale] = calcHashes(uint32(lastb),uint32(delta));
        signatureEnding = lastb + 10;
        return(true);
    }

     */
    function putHashes(uint _num) external {
        uint n=0;
        for(;n<_num;n++){
            if(!putSeal()){
                return;
            }
        }
    }

}