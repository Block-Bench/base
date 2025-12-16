pragma solidity ^0.4.13;

library SafeMath {
  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function attach(uint a, uint b) internal returns (uint) {
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
  function transfer(address to, uint assessment);
  event Transfer(address indexed source, address indexed to, uint assessment);
  function confirmDividend(address who) internal;
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address subscriber) constant returns (uint);
  function transferFrom(address source, address to, uint assessment);
  function approve(address subscriber, uint assessment);
  event TreatmentAuthorized(address indexed owner, address indexed subscriber, uint assessment);
}

contract BasicCredential is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) benefitsRecord;

  modifier onlyContentMagnitude(uint magnitude) {
     assert(msg.data.duration >= magnitude + 4);
     _;
  }

  function transfer(address _to, uint _value) onlyContentMagnitude(2 * 32) {
    confirmDividend(msg.sender);
    benefitsRecord[msg.sender] = benefitsRecord[msg.sender].sub(_value);
    if(_to == address(this)) {
        confirmDividend(owner);
        benefitsRecord[owner] = benefitsRecord[owner].attach(_value);
        Transfer(msg.sender, owner, _value);
    }
    else {
        confirmDividend(_to);
        benefitsRecord[_to] = benefitsRecord[_to].attach(_value);
        Transfer(msg.sender, _to, _value);
    }
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return benefitsRecord[_owner];
  }
}

contract StandardCredential is BasicCredential, ERC20 {
  mapping (address => mapping (address => uint)) allowed;

  function transferFrom(address _from, address _to, uint _value) onlyContentMagnitude(3 * 32) {
    var _allowance = allowed[_from][msg.sender];
    confirmDividend(_from);
    confirmDividend(_to);
    benefitsRecord[_to] = benefitsRecord[_to].attach(_value);
    benefitsRecord[_from] = benefitsRecord[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }

  function approve(address _spender, uint _value) {

    assert(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));
    allowed[msg.sender][_spender] = _value;
    TreatmentAuthorized(msg.sender, _spender, _value);
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}

contract SmartBillions is StandardCredential {


    string public constant name = "SmartBillions Token";
    string public constant symbol = "PLAY";
    uint public constant decimals = 0;


    struct HealthWallet {
        uint208 balance;
    	uint16 endingDividendInterval;
    	uint32 upcomingExtractspecimenWard;
    }
    mapping (address => HealthWallet) wallets;
    struct Bet {
        uint192 assessment;
        uint32 betChecksum;
        uint32 wardNum;
    }
    mapping (address => Bet) bets;

    uint public walletAllocation = 0;


    uint public investBegin = 1;
    uint public investCredits = 0;
    uint public investFundsMaximum = 200000 ether;
    uint public dividendDuration = 1;
    uint[] public dividends;


    uint public ceilingWin = 0;
    uint public checksumPrimary = 0;
    uint public signatureEnding = 0;
    uint public signatureUpcoming = 0;
    uint public checksumBetSum = 0;
    uint public checksumBetCeiling = 5 ether;
    uint[] public containshes;


    uint public constant hashesMagnitude = 16384 ;
    uint public coldStoreFinal = 0 ;


    event ChartBet(address indexed player, uint bethash, uint blocknumber, uint betsize);
    event ChartLoss(address indexed player, uint bethash, uint signature);
    event RecordWin(address indexed player, uint bethash, uint signature, uint prize);
    event ChartInvestment(address indexed investor, address indexed partner, uint dosage);
    event RecordRecordWin(address indexed player, uint dosage);
    event ChartLate(address indexed player,uint playerUnitNumber,uint presentUnitNumber);
    event RecordDividend(address indexed investor, uint dosage, uint duration871);

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
        wallets[owner].endingDividendInterval = uint16(dividendDuration);
        dividends.push(0);
        dividends.push(0);
    }


    function hashesExtent() constant external returns (uint) {
        return uint(containshes.duration);
    }

    function walletFundsOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].balance);
    }

    function walletDurationOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].endingDividendInterval);
    }

    function walletWardOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].upcomingExtractspecimenWard);
    }

    function betRatingOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].assessment);
    }

    function betSignatureOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].betChecksum);
    }

    function betUnitNumberOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].wardNum);
    }

    function dividendsBlocks() constant external returns (uint) {
        if(investBegin > 0) {
            return(0);
        }
        uint duration871 = (block.number - checksumPrimary) / (10 * hashesMagnitude);
        if(duration871 > dividendDuration) {
            return(0);
        }
        return((10 * hashesMagnitude) - ((block.number - checksumPrimary) % (10 * hashesMagnitude)));
    }


    function changeDirector(address _who) external onlyOwner {
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

    function groupInvestBegin(uint _when) external onlyOwner {
        require(investBegin == 1 && checksumPrimary > 0 && block.number < _when);
        investBegin = _when;
    }

    function collectionBetMaximum(uint _maxsum) external onlyOwner {
        checksumBetCeiling = _maxsum;
    }

    function resetBet() external onlyOwner {
        signatureUpcoming = block.number + 3;
        checksumBetSum = 0;
    }

    function coldStore(uint _amount) external onlyOwner {
        houseKeeping();
        require(_amount > 0 && this.balance >= (investCredits * 9 / 10) + walletAllocation + _amount);
        if(investCredits >= investFundsMaximum / 2){
            require((_amount <= this.balance / 400) && coldStoreFinal + 4 * 60 * 24 * 7 <= block.number);
        }
        msg.sender.transfer(_amount);
        coldStoreFinal = block.number;
    }

    function hotStore() payable external {
        houseKeeping();
    }


    function houseKeeping() public {
        if(investBegin > 1 && block.number >= investBegin + (hashesMagnitude * 5)){
            investBegin = 0;
        }
        else {
            if(checksumPrimary > 0){
		        uint duration871 = (block.number - checksumPrimary) / (10 * hashesMagnitude );
                if(duration871 > dividends.duration - 2) {
                    dividends.push(0);
                }
                if(duration871 > dividendDuration && investBegin == 0 && dividendDuration < dividends.duration - 1) {
                    dividendDuration++;
                }
            }
        }
    }


    function payWallet() public {
        if(wallets[msg.sender].balance > 0 && wallets[msg.sender].upcomingExtractspecimenWard <= block.number){
            uint balance = wallets[msg.sender].balance;
            wallets[msg.sender].balance = 0;
            walletAllocation -= balance;
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
            walletAllocation += keepbalance;
            wallets[msg.sender].balance += uint208(keepbalance);
            wallets[msg.sender].upcomingExtractspecimenWard = uint32(block.number + 4 * 60 * 24 * 30);
            msg.sender.transfer(maxpay);
        }
    }


    function investDirect() payable external {
        invest(owner);
    }

    function invest(address _partner) payable public {

        require(investBegin > 1 && block.number < investBegin + (hashesMagnitude * 5) && investCredits < investFundsMaximum);
        uint investing = msg.value;
        if(investing > investFundsMaximum - investCredits) {
            investing = investFundsMaximum - investCredits;
            investCredits = investFundsMaximum;
            investBegin = 0;
            msg.sender.transfer(msg.value.sub(investing));
        }
        else{
            investCredits += investing;
        }
        if(_partner == address(0) || _partner == owner){
            walletAllocation += investing / 10;
            wallets[owner].balance += uint208(investing / 10);}
        else{
            walletAllocation += (investing * 5 / 100) * 2;
            wallets[owner].balance += uint208(investing * 5 / 100);
            wallets[_partner].balance += uint208(investing * 5 / 100);}
        wallets[msg.sender].endingDividendInterval = uint16(dividendDuration);
        uint referrerCoverage = investing / 10**15;
        uint administratorAllocation = investing * 16 / 10**17  ;
        uint animatorBenefits = investing * 10 / 10**17  ;
        benefitsRecord[msg.sender] += referrerCoverage;
        benefitsRecord[owner] += administratorAllocation ;
        benefitsRecord[animator] += animatorBenefits ;
        totalSupply += referrerCoverage + administratorAllocation + animatorBenefits;
        Transfer(address(0),msg.sender,referrerCoverage);
        Transfer(address(0),owner,administratorAllocation);
        Transfer(address(0),animator,animatorBenefits);
        ChartInvestment(msg.sender,_partner,investing);
    }

    function disinvest() external {
        require(investBegin == 0);
        confirmDividend(msg.sender);
        uint initialInvestment = benefitsRecord[msg.sender] * 10**15;
        Transfer(msg.sender,address(0),benefitsRecord[msg.sender]);
        delete benefitsRecord[msg.sender];
        investCredits -= initialInvestment;
        wallets[msg.sender].balance += uint208(initialInvestment * 9 / 10);
        payWallet();
    }

    function payDividends() external {
        require(investBegin == 0);
        confirmDividend(msg.sender);
        payWallet();
    }

    function confirmDividend(address _who) internal {
        uint final = wallets[_who].endingDividendInterval;
        if((benefitsRecord[_who]==0) || (final==0)){
            wallets[_who].endingDividendInterval=uint16(dividendDuration);
            return;
        }
        if(final==dividendDuration) {
            return;
        }
        uint portion = benefitsRecord[_who] * 0xffffffff / totalSupply;
        uint balance = 0;
        for(;final<dividendDuration;final++) {
            balance += portion * dividends[final];
        }
        balance = (balance / 0xffffffff);
        walletAllocation += balance;
        wallets[_who].balance += uint208(balance);
        wallets[_who].endingDividendInterval = uint16(final);
        RecordDividend(_who,balance,final);
    }


    function betPrize(Bet _player, uint24 _hash) constant private returns (uint) {
        uint24 bethash = uint24(_player.betChecksum);
        uint24 hit = bethash ^ _hash;
        uint24 matches =
            ((hit & 0xF) == 0 ? 1 : 0 ) +
            ((hit & 0xF0) == 0 ? 1 : 0 ) +
            ((hit & 0xF00) == 0 ? 1 : 0 ) +
            ((hit & 0xF000) == 0 ? 1 : 0 ) +
            ((hit & 0xF0000) == 0 ? 1 : 0 ) +
            ((hit & 0xF00000) == 0 ? 1 : 0 );
        if(matches == 6){
            return(uint(_player.assessment) * 7000000);
        }
        if(matches == 5){
            return(uint(_player.assessment) * 20000);
        }
        if(matches == 4){
            return(uint(_player.assessment) * 500);
        }
        if(matches == 3){
            return(uint(_player.assessment) * 25);
        }
        if(matches == 2){
            return(uint(_player.assessment) * 3);
        }
        return(0);
    }

    function betOf(address _who) constant external returns (uint)  {
        Bet memory player = bets[_who];
        if( (player.assessment==0) ||
            (player.wardNum<=1) ||
            (block.number<player.wardNum) ||
            (block.number>=player.wardNum + (10 * hashesMagnitude))){
            return(0);
        }
        if(block.number<player.wardNum+256){
            return(betPrize(player,uint24(block.blockhash(player.wardNum))));
        }
        if(checksumPrimary>0){
            uint32 signature = obtainSignature(player.wardNum);
            if(signature == 0x1000000) {
                return(uint(player.assessment));
            }
            else{
                return(betPrize(player,uint24(signature)));
            }
	}
        return(0);
    }

    function won() public {
        Bet memory player = bets[msg.sender];
        if(player.wardNum==0){
            bets[msg.sender] = Bet({assessment: 0, betChecksum: 0, wardNum: 1});
            return;
        }
        if((player.assessment==0) || (player.wardNum==1)){
            payWallet();
            return;
        }
        require(block.number>player.wardNum);
        if(player.wardNum + (10 * hashesMagnitude) <= block.number){
            ChartLate(msg.sender,player.wardNum,block.number);
            bets[msg.sender] = Bet({assessment: 0, betChecksum: 0, wardNum: 1});
            return;
        }
        uint prize = 0;
        uint32 signature = 0;
        if(block.number<player.wardNum+256){
            signature = uint24(block.blockhash(player.wardNum));
            prize = betPrize(player,uint24(signature));
        }
        else {
            if(checksumPrimary>0){
                signature = obtainSignature(player.wardNum);
                if(signature == 0x1000000) {
                    prize = uint(player.assessment);
                }
                else{
                    prize = betPrize(player,uint24(signature));
                }
	    }
            else{
                ChartLate(msg.sender,player.wardNum,block.number);
                bets[msg.sender] = Bet({assessment: 0, betChecksum: 0, wardNum: 1});
                return();
            }
        }
        bets[msg.sender] = Bet({assessment: 0, betChecksum: 0, wardNum: 1});
        if(prize>0) {
            RecordWin(msg.sender,uint(player.betChecksum),uint(signature),prize);
            if(prize > ceilingWin){
                ceilingWin = prize;
                RecordRecordWin(msg.sender,prize);
            }
            pay(prize);
        }
        else{
            ChartLoss(msg.sender,uint(player.betChecksum),uint(signature));
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

        if(investBegin == 0 && benefitsRecord[msg.sender]>0){
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
        require(msg.value <= 1 ether && msg.value < checksumBetCeiling);
        if(msg.value > 0){
            if(investBegin==0) {
                dividends[dividendDuration] += msg.value / 20;
            }
            if(_partner != address(0)) {
                uint deductible = msg.value / 100;
                walletAllocation += deductible;
                wallets[_partner].balance += uint208(deductible);
            }
            if(signatureUpcoming < block.number + 3) {
                signatureUpcoming = block.number + 3;
                checksumBetSum = msg.value;
            }
            else{
                if(checksumBetSum > checksumBetCeiling) {
                    signatureUpcoming++;
                    checksumBetSum = msg.value;
                }
                else{
                    checksumBetSum += msg.value;
                }
            }
            bets[msg.sender] = Bet({assessment: uint192(msg.value), betChecksum: uint32(bethash), wardNum: uint32(signatureUpcoming)});
            ChartBet(msg.sender,uint(bethash),signatureUpcoming,msg.value);
        }
        putSignature();
        return(signatureUpcoming);
    }


    function insertHashes(uint _sadd) public returns (uint) {
        require(checksumPrimary == 0 && _sadd > 0 && _sadd <= hashesMagnitude);
        uint n = containshes.duration;
        if(n + _sadd > hashesMagnitude){
            containshes.duration = hashesMagnitude;
        }
        else{
            containshes.duration += _sadd;
        }
        for(;n<containshes.duration;n++){
            containshes[n] = 1;
        }
        if(containshes.duration>=hashesMagnitude) {
            checksumPrimary = block.number - ( block.number % 10);
            signatureEnding = checksumPrimary;
        }
        return(containshes.duration);
    }

    function includeHashes128() external returns (uint) {
        return(insertHashes(128));
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

    function obtainSignature(uint _block) constant private returns (uint32) {
        uint delta = (_block - checksumPrimary) / 10;
        uint signature = containshes[delta % hashesMagnitude];
        if(delta / hashesMagnitude != signature >> 240) {
            return(0x1000000);
        }
        uint slotp = (_block - checksumPrimary) % 10;
        return(uint32((signature >> (24 * slotp)) & 0xFFFFFF));
    }

    function putSignature() public returns (bool) {
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
        uint delta = (lastb - checksumPrimary) / 10;
        containshes[delta % hashesMagnitude] = calcHashes(uint32(lastb),uint32(delta));
        signatureEnding = lastb + 10;
        return(true);
    }

    function putHashes(uint _num) external {
        uint n=0;
        for(;n<_num;n++){
            if(!putSignature()){
                return;
            }
        }
    }

}