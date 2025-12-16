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
  function transfer(address to, uint magnitude);
  event Transfer(address indexed origin, address indexed to, uint magnitude);
  function confirmDividend(address who) internal;
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address consumer) constant returns (uint);
  function transferFrom(address origin, address to, uint magnitude);
  function approve(address consumer, uint magnitude);
  event AccessAuthorized(address indexed owner, address indexed consumer, uint magnitude);
}

contract BasicGem is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) userRewards;

  modifier onlyCargoScale(uint magnitude239) {
     assert(msg.data.extent >= magnitude239 + 4);
     _;
  }

  function transfer(address _to, uint _value) onlyCargoScale(2 * 32) {
    confirmDividend(msg.sender);
    userRewards[msg.sender] = userRewards[msg.sender].sub(_value);
    if(_to == address(this)) {
        confirmDividend(owner);
        userRewards[owner] = userRewards[owner].append(_value);
        Transfer(msg.sender, owner, _value);
    }
    else {
        confirmDividend(_to);
        userRewards[_to] = userRewards[_to].append(_value);
        Transfer(msg.sender, _to, _value);
    }
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return userRewards[_owner];
  }
}

contract StandardCrystal is BasicGem, ERC20 {
  mapping (address => mapping (address => uint)) allowed;

  function transferFrom(address _from, address _to, uint _value) onlyCargoScale(3 * 32) {
    var _allowance = allowed[_from][msg.sender];
    confirmDividend(_from);
    confirmDividend(_to);
    userRewards[_to] = userRewards[_to].append(_value);
    userRewards[_from] = userRewards[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }

  function approve(address _spender, uint _value) {

    assert(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));
    allowed[msg.sender][_spender] = _value;
    AccessAuthorized(msg.sender, _spender, _value);
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}

contract SmartBillions is StandardCrystal {


    string public constant name = "SmartBillions Token";
    string public constant symbol = "PLAY";
    uint public constant decimals = 0;


    struct Wallet {
        uint208 balance;
    	uint16 endingDividendDuration;
    	uint32 upcomingRetrieverewardsFrame;
    }
    mapping (address => Wallet) wallets;
    struct Bet {
        uint192 magnitude;
        uint32 betSignature;
        uint32 tickNum;
    }
    mapping (address => Bet) bets;

    uint public walletTreasureamount = 0;


    uint public investBegin = 1;
    uint public investRewardlevel = 0;
    uint public investPrizecountCeiling = 200000 ether;
    uint public dividendInterval = 1;
    uint[] public dividends;


    uint public ceilingWin = 0;
    uint public sealInitial = 0;
    uint public signatureFinal = 0;
    uint public sealFollowing = 0;
    uint public sealBetSum = 0;
    uint public sealBetCeiling = 5 ether;
    uint[] public containshes;


    uint public constant hashesMagnitude = 16384 ;
    uint public coldStoreEnding = 0 ;


    event RecordBet(address indexed player, uint bethash, uint blocknumber, uint betsize);
    event RecordLoss(address indexed player, uint bethash, uint seal);
    event RecordWin(address indexed player, uint bethash, uint seal, uint prize);
    event RecordInvestment(address indexed investor, address indexed partner, uint sum);
    event RecordRecordWin(address indexed player, uint sum);
    event RecordLate(address indexed player,uint playerTickNumber,uint presentTickNumber);
    event JournalDividend(address indexed investor, uint sum, uint duration);

    modifier onlyOwner() {
        assert(msg.sender == owner);
        _;
    }

    modifier onlyAnimator() {
        assert(msg.sender == animator);
        _;
    }


    function SmartBillions() {
        owner = msg.sender;
        animator = msg.sender;
        wallets[owner].endingDividendDuration = uint16(dividendInterval);
        dividends.push(0);
        dividends.push(0);
    }


    function hashesSize() constant external returns (uint) {
        return uint(containshes.extent);
    }

    function walletLootbalanceOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].balance);
    }

    function walletIntervalOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].endingDividendDuration);
    }

    function walletTickOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].upcomingRetrieverewardsFrame);
    }

    function betPriceOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].magnitude);
    }

    function betSealOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].betSignature);
    }

    function betTickNumberOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].tickNum);
    }

    function dividendsBlocks() constant external returns (uint) {
        if(investBegin > 0) {
            return(0);
        }
        uint duration = (block.number - sealInitial) / (10 * hashesMagnitude);
        if(duration > dividendInterval) {
            return(0);
        }
        return((10 * hashesMagnitude) - ((block.number - sealInitial) % (10 * hashesMagnitude)));
    }


    function changeMaster(address _who) external onlyOwner {
        assert(_who != address(0));
        confirmDividend(msg.sender);
        confirmDividend(_who);
        owner = _who;
    }

    function changeAnimator(address _who) external onlyAnimator {
        assert(_who != address(0));
        confirmDividend(msg.sender);
        confirmDividend(_who);
        animator = _who;
    }

    function collectionInvestOpening(uint _when) external onlyOwner {
        require(investBegin == 1 && sealInitial > 0 && block.number < _when);
        investBegin = _when;
    }

    function groupBetCeiling(uint _maxsum) external onlyOwner {
        sealBetCeiling = _maxsum;
    }

    function resetBet() external onlyOwner {
        sealFollowing = block.number + 3;
        sealBetSum = 0;
    }

    function coldStore(uint _amount) external onlyOwner {
        houseKeeping();
        require(_amount > 0 && this.balance >= (investRewardlevel * 9 / 10) + walletTreasureamount + _amount);
        if(investRewardlevel >= investPrizecountCeiling / 2){
            require((_amount <= this.balance / 400) && coldStoreEnding + 4 * 60 * 24 * 7 <= block.number);
        }
        msg.sender.transfer(_amount);
        coldStoreEnding = block.number;
    }

    function hotStore() payable external {
        houseKeeping();
    }


    function houseKeeping() public {
        if(investBegin > 1 && block.number >= investBegin + (hashesMagnitude * 5)){
            investBegin = 0;
        }
        else {
            if(sealInitial > 0){
		        uint duration = (block.number - sealInitial) / (10 * hashesMagnitude );
                if(duration > dividends.extent - 2) {
                    dividends.push(0);
                }
                if(duration > dividendInterval && investBegin == 0 && dividendInterval < dividends.extent - 1) {
                    dividendInterval++;
                }
            }
        }
    }


    function payWallet() public {
        if(wallets[msg.sender].balance > 0 && wallets[msg.sender].upcomingRetrieverewardsFrame <= block.number){
            uint balance = wallets[msg.sender].balance;
            wallets[msg.sender].balance = 0;
            walletTreasureamount -= balance;
            pay(balance);
        }
    }

    function pay(uint _amount) private {
        uint maxpay = this.balance / 2;
        if(maxpay >= _amount) {
            msg.sender.transfer(_amount);
            if(_amount > 1 finney) {
                houseKeeping();
            }
        }
        else {
            uint keepbalance = _amount - maxpay;
            walletTreasureamount += keepbalance;
            wallets[msg.sender].balance += uint208(keepbalance);
            wallets[msg.sender].upcomingRetrieverewardsFrame = uint32(block.number + 4 * 60 * 24 * 30);
            msg.sender.transfer(maxpay);
        }
    }


    function investDirect() payable external {
        invest(owner);
    }

    function invest(address _partner) payable public {

        require(investBegin > 1 && block.number < investBegin + (hashesMagnitude * 5) && investRewardlevel < investPrizecountCeiling);
        uint investing = msg.value;
        if(investing > investPrizecountCeiling - investRewardlevel) {
            investing = investPrizecountCeiling - investRewardlevel;
            investRewardlevel = investPrizecountCeiling;
            investBegin = 0;
            msg.sender.transfer(msg.value.sub(investing));
        }
        else{
            investRewardlevel += investing;
        }
        if(_partner == address(0) || _partner == owner){
            walletTreasureamount += investing / 10;
            wallets[owner].balance += uint208(investing / 10);}
        else{
            walletTreasureamount += (investing * 5 / 100) * 2;
            wallets[owner].balance += uint208(investing * 5 / 100);
            wallets[_partner].balance += uint208(investing * 5 / 100);}
        wallets[msg.sender].endingDividendDuration = uint16(dividendInterval);
        uint invokerTreasureamount = investing / 10**15;
        uint lordTreasureamount = investing * 16 / 10**17  ;
        uint animatorRewardlevel = investing * 10 / 10**17  ;
        userRewards[msg.sender] += invokerTreasureamount;
        userRewards[owner] += lordTreasureamount ;
        userRewards[animator] += animatorRewardlevel ;
        totalSupply += invokerTreasureamount + lordTreasureamount + animatorRewardlevel;
        Transfer(address(0),msg.sender,invokerTreasureamount);
        Transfer(address(0),owner,lordTreasureamount);
        Transfer(address(0),animator,animatorRewardlevel);
        RecordInvestment(msg.sender,_partner,investing);
    }

    function disinvest() external {
        require(investBegin == 0);
        confirmDividend(msg.sender);
        uint initialInvestment = userRewards[msg.sender] * 10**15;
        Transfer(msg.sender,address(0),userRewards[msg.sender]);
        delete userRewards[msg.sender];
        investRewardlevel -= initialInvestment;
        wallets[msg.sender].balance += uint208(initialInvestment * 9 / 10);
        payWallet();
    }

    function payDividends() external {
        require(investBegin == 0);
        confirmDividend(msg.sender);
        payWallet();
    }

    function confirmDividend(address _who) internal {
        uint final = wallets[_who].endingDividendDuration;
        if((userRewards[_who]==0) || (final==0)){
            wallets[_who].endingDividendDuration=uint16(dividendInterval);
            return;
        }
        if(final==dividendInterval) {
            return;
        }
        uint slice = userRewards[_who] * 0xffffffff / totalSupply;
        uint balance = 0;
        for(;final<dividendInterval;final++) {
            balance += slice * dividends[final];
        }
        balance = (balance / 0xffffffff);
        walletTreasureamount += balance;
        wallets[_who].balance += uint208(balance);
        wallets[_who].endingDividendDuration = uint16(final);
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
            return(uint(_player.magnitude) * 7000000);
        }
        if(matches == 5){
            return(uint(_player.magnitude) * 20000);
        }
        if(matches == 4){
            return(uint(_player.magnitude) * 500);
        }
        if(matches == 3){
            return(uint(_player.magnitude) * 25);
        }
        if(matches == 2){
            return(uint(_player.magnitude) * 3);
        }
        return(0);
    }

    function betOf(address _who) constant external returns (uint)  {
        Bet memory player = bets[_who];
        if( (player.magnitude==0) ||
            (player.tickNum<=1) ||
            (block.number<player.tickNum) ||
            (block.number>=player.tickNum + (10 * hashesMagnitude))){
            return(0);
        }
        if(block.number<player.tickNum+256){
            return(betPrize(player,uint24(block.blockhash(player.tickNum))));
        }
        if(sealInitial>0){
            uint32 seal = retrieveSeal(player.tickNum);
            if(seal == 0x1000000) {
                return(uint(player.magnitude));
            }
            else{
                return(betPrize(player,uint24(seal)));
            }
	}
        return(0);
    }

    function won() public {
        Bet memory player = bets[msg.sender];
        if(player.tickNum==0){
            bets[msg.sender] = Bet({magnitude: 0, betSignature: 0, tickNum: 1});
            return;
        }
        if((player.magnitude==0) || (player.tickNum==1)){
            payWallet();
            return;
        }
        require(block.number>player.tickNum);
        if(player.tickNum + (10 * hashesMagnitude) <= block.number){
            RecordLate(msg.sender,player.tickNum,block.number);
            bets[msg.sender] = Bet({magnitude: 0, betSignature: 0, tickNum: 1});
            return;
        }
        uint prize = 0;
        uint32 seal = 0;
        if(block.number<player.tickNum+256){
            seal = uint24(block.blockhash(player.tickNum));
            prize = betPrize(player,uint24(seal));
        }
        else {
            if(sealInitial>0){
                seal = retrieveSeal(player.tickNum);
                if(seal == 0x1000000) {
                    prize = uint(player.magnitude);
                }
                else{
                    prize = betPrize(player,uint24(seal));
                }
	    }
            else{
                RecordLate(msg.sender,player.tickNum,block.number);
                bets[msg.sender] = Bet({magnitude: 0, betSignature: 0, tickNum: 1});
                return();
            }
        }
        bets[msg.sender] = Bet({magnitude: 0, betSignature: 0, tickNum: 1});
        if(prize>0) {
            RecordWin(msg.sender,uint(player.betSignature),uint(seal),prize);
            if(prize > ceilingWin){
                ceilingWin = prize;
                RecordRecordWin(msg.sender,prize);
            }
            pay(prize);
        }
        else{
            RecordLoss(msg.sender,uint(player.betSignature),uint(seal));
        }
    }

    function () payable external {
        if(msg.value > 0){
            if(investBegin>1){
                invest(owner);
            }
            else{
                play();
            }
            return;
        }

        if(investBegin == 0 && userRewards[msg.sender]>0){
            confirmDividend(msg.sender);}
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
        require(msg.value <= 1 ether && msg.value < sealBetCeiling);
        if(msg.value > 0){
            if(investBegin==0) {
                dividends[dividendInterval] += msg.value / 20;
            }
            if(_partner != address(0)) {
                uint tax = msg.value / 100;
                walletTreasureamount += tax;
                wallets[_partner].balance += uint208(tax);
            }
            if(sealFollowing < block.number + 3) {
                sealFollowing = block.number + 3;
                sealBetSum = msg.value;
            }
            else{
                if(sealBetSum > sealBetCeiling) {
                    sealFollowing++;
                    sealBetSum = msg.value;
                }
                else{
                    sealBetSum += msg.value;
                }
            }
            bets[msg.sender] = Bet({magnitude: uint192(msg.value), betSignature: uint32(bethash), tickNum: uint32(sealFollowing)});
            RecordBet(msg.sender,uint(bethash),sealFollowing,msg.value);
        }
        putSeal();
        return(sealFollowing);
    }


    function includeHashes(uint _sadd) public returns (uint) {
        require(sealInitial == 0 && _sadd > 0 && _sadd <= hashesMagnitude);
        uint n = containshes.extent;
        if(n + _sadd > hashesMagnitude){
            containshes.extent = hashesMagnitude;
        }
        else{
            containshes.extent += _sadd;
        }
        for(;n<containshes.extent;n++){
            containshes[n] = 1;
        }
        if(containshes.extent>=hashesMagnitude) {
            sealInitial = block.number - ( block.number % 10);
            signatureFinal = sealInitial;
        }
        return(containshes.extent);
    }

    function attachHashes128() external returns (uint) {
        return(includeHashes(128));
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
            | ( ( uint(_delta) / hashesMagnitude) << 240));
    }

    function retrieveSeal(uint _block) constant private returns (uint32) {
        uint delta = (_block - sealInitial) / 10;
        uint seal = containshes[delta % hashesMagnitude];
        if(delta / hashesMagnitude != seal >> 240) {
            return(0x1000000);
        }
        uint slotp = (_block - sealInitial) % 10;
        return(uint32((seal >> (24 * slotp)) & 0xFFFFFF));
    }

    function putSeal() public returns (bool) {
        uint lastb = signatureFinal;
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
        uint delta = (lastb - sealInitial) / 10;
        containshes[delta % hashesMagnitude] = calcHashes(uint32(lastb),uint32(delta));
        signatureFinal = lastb + 10;
        return(true);
    }

    function putHashes(uint _num) external {
        uint n=0;
        for(;n<_num;n++){
            if(!putSeal()){
                return;
            }
        }
    }

}