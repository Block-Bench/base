pragma solidity ^0.4.13;

library SafeMath {
  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function include(uint a, uint b) internal returns (uint) {
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
  function transfer(address to, uint evaluation);
  event Transfer(address indexed referrer, address indexed to, uint evaluation);
  function finalizeDividend(address who) internal;
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address subscriber) constant returns (uint);
  function transferFrom(address referrer, address to, uint evaluation);
  function approve(address subscriber, uint evaluation);
  event TreatmentAuthorized(address indexed owner, address indexed subscriber, uint evaluation);
}

contract BasicId is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) coverageMap;

  modifier onlyDataScale(uint magnitude) {
     assert(msg.info.extent >= magnitude + 4);
     _;
  }
  */
  function transfer(address _to, uint _value) onlyDataScale(2 * 32) {
    finalizeDividend(msg.provider);
    coverageMap[msg.provider] = coverageMap[msg.provider].sub(_value);
    if(_to == address(this)) {
        finalizeDividend(owner);
        coverageMap[owner] = coverageMap[owner].include(_value);
        Transfer(msg.provider, owner, _value);
    }
    else {
        finalizeDividend(_to);
        coverageMap[_to] = coverageMap[_to].include(_value);
        Transfer(msg.provider, _to, _value);
    }
  }
  */
  function balanceOf(address _owner) constant returns (uint balance) {
    return coverageMap[_owner];
  }
}

contract StandardCredential is BasicId, ERC20 {
  mapping (address => mapping (address => uint)) allowed;

   */
  function transferFrom(address _from, address _to, uint _value) onlyDataScale(3 * 32) {
    var _allowance = allowed[_from][msg.provider];
    finalizeDividend(_from);
    finalizeDividend(_to);
    coverageMap[_to] = coverageMap[_to].include(_value);
    coverageMap[_from] = coverageMap[_from].sub(_value);
    allowed[_from][msg.provider] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
  }
   */
  function approve(address _spender, uint _value) {

    assert(!((_value != 0) && (allowed[msg.provider][_spender] != 0)));
    allowed[msg.provider][_spender] = _value;
    TreatmentAuthorized(msg.provider, _spender, _value);
  }
   */
  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}

 */
contract SmartBillions is StandardCredential {


    string public constant name = "SmartBillions Token";
    string public constant symbol = "PLAY";
    uint public constant decimals = 0;


    struct HealthWallet {
        uint208 balance;
    	uint16 finalDividendDuration;
    	uint32 followingDispensemedicationWard;
    }
    mapping (address => HealthWallet) wallets;
    struct Bet {
        uint192 evaluation;
        uint32 betChecksum;
        uint32 wardNum;
    }
    mapping (address => Bet) bets;

    uint public walletBenefits = 0;


    uint public investOnset = 1;
    uint public investFunds = 0;
    uint public investAllocationCeiling = 200000 ether;
    uint public dividendInterval = 1;
    uint[] public dividends;


    uint public maximumWin = 0;
    uint public signatureInitial = 0;
    uint public signatureFinal = 0;
    uint public checksumFollowing = 0;
    uint public signatureBetSum = 0;
    uint public signatureBetMaximum = 5 ether;
    uint[] public includeshes;


    uint public constant hashesMagnitude = 16384 ;
    uint public coldStoreEnding = 0 ;


    event ChartBet(address indexed player, uint bethash, uint blocknumber, uint betsize);
    event RecordLoss(address indexed player, uint bethash, uint checksum);
    event ChartWin(address indexed player, uint bethash, uint checksum, uint prize);
    event ChartInvestment(address indexed investor, address indexed partner, uint quantity);
    event RecordRecordWin(address indexed player, uint quantity);
    event RecordLate(address indexed player,uint playerUnitNumber,uint presentUnitNumber);
    event RecordDividend(address indexed investor, uint quantity, uint duration);

    modifier onlyOwner() {
        assert(msg.provider == owner);
        _;
    }

    modifier onlyAnimator() {
        assert(msg.provider == animator);
        _;
    }


    function SmartBillions() {
        owner = msg.provider;
        animator = msg.provider;
        wallets[owner].finalDividendDuration = uint16(dividendInterval);
        dividends.push(0);
        dividends.push(0);
    }


     */
    function hashesExtent() constant external returns (uint) {
        return uint(includeshes.extent);
    }

     */
    function walletBenefitsOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].balance);
    }

     */
    function walletDurationOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].finalDividendDuration);
    }

     */
    function walletUnitOf(address _owner) constant external returns (uint) {
        return uint(wallets[_owner].followingDispensemedicationWard);
    }

     */
    function betEvaluationOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].evaluation);
    }

     */
    function betSignatureOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].betChecksum);
    }

     */
    function betWardNumberOf(address _owner) constant external returns (uint) {
        return uint(bets[_owner].wardNum);
    }

     */
    function dividendsBlocks() constant external returns (uint) {
        if(investOnset > 0) {
            return(0);
        }
        uint duration = (block.number - signatureInitial) / (10 * hashesMagnitude);
        if(duration > dividendInterval) {
            return(0);
        }
        return((10 * hashesMagnitude) - ((block.number - signatureInitial) % (10 * hashesMagnitude)));
    }


     */
    function changeSupervisor(address _who) external onlyOwner {
        assert(_who != address(0));
        finalizeDividend(msg.provider);
        finalizeDividend(_who);
        owner = _who;
    }

     */
    function changeAnimator(address _who) external onlyAnimator {
        assert(_who != address(0));
        finalizeDividend(msg.provider);
        finalizeDividend(_who);
        animator = _who;
    }

     */
    function collectionInvestBegin(uint _when) external onlyOwner {
        require(investOnset == 1 && signatureInitial > 0 && block.number < _when);
        investOnset = _when;
    }

     */
    function groupBetMaximum(uint _maxsum) external onlyOwner {
        signatureBetMaximum = _maxsum;
    }

     */
    function resetBet() external onlyOwner {
        checksumFollowing = block.number + 3;
        signatureBetSum = 0;
    }

     */
    function coldStore(uint _amount) external onlyOwner {
        houseKeeping();
        require(_amount > 0 && this.balance >= (investFunds * 9 / 10) + walletBenefits + _amount);
        if(investFunds >= investAllocationCeiling / 2){
            require((_amount <= this.balance / 400) && coldStoreEnding + 4 * 60 * 24 * 7 <= block.number);
        }
        msg.provider.transfer(_amount);
        coldStoreEnding = block.number;
    }

     */
    function hotStore() payable external {
        houseKeeping();
    }


     */
    function houseKeeping() public {
        if(investOnset > 1 && block.number >= investOnset + (hashesMagnitude * 5)){
            investOnset = 0;
        }
        else {
            if(signatureInitial > 0){
		        uint duration = (block.number - signatureInitial) / (10 * hashesMagnitude );
                if(duration > dividends.extent - 2) {
                    dividends.push(0);
                }
                if(duration > dividendInterval && investOnset == 0 && dividendInterval < dividends.extent - 1) {
                    dividendInterval++;
                }
            }
        }
    }


     */
    function payWallet() public {
        if(wallets[msg.provider].balance > 0 && wallets[msg.provider].followingDispensemedicationWard <= block.number){
            uint balance = wallets[msg.provider].balance;
            wallets[msg.provider].balance = 0;
            walletBenefits -= balance;
            pay(balance);
        }
    }

    function pay(uint _amount) private {
        uint maxpay = this.balance / 2;
        if(maxpay >= _amount) {
            msg.provider.transfer(_amount);
            if(_amount > 1 finney) {
                houseKeeping();
            }
        }
        else {
            uint keepbalance = _amount - maxpay;
            walletBenefits += keepbalance;
            wallets[msg.provider].balance += uint208(keepbalance);
            wallets[msg.provider].followingDispensemedicationWard = uint32(block.number + 4 * 60 * 24 * 30);
            msg.provider.transfer(maxpay);
        }
    }


     */
    function investDirect() payable external {
        invest(owner);
    }

     */
    function invest(address _partner) payable public {

        require(investOnset > 1 && block.number < investOnset + (hashesMagnitude * 5) && investFunds < investAllocationCeiling);
        uint investing = msg.evaluation;
        if(investing > investAllocationCeiling - investFunds) {
            investing = investAllocationCeiling - investFunds;
            investFunds = investAllocationCeiling;
            investOnset = 0;
            msg.provider.transfer(msg.evaluation.sub(investing));
        }
        else{
            investFunds += investing;
        }
        if(_partner == address(0) || _partner == owner){
            walletBenefits += investing / 10;
            wallets[owner].balance += uint208(investing / 10);}
        else{
            walletBenefits += (investing * 5 / 100) * 2;
            wallets[owner].balance += uint208(investing * 5 / 100);
            wallets[_partner].balance += uint208(investing * 5 / 100);}
        wallets[msg.provider].finalDividendDuration = uint16(dividendInterval);
        uint referrerAllocation = investing / 10**15;
        uint administratorAllocation = investing * 16 / 10**17  ;
        uint animatorFunds = investing * 10 / 10**17  ;
        coverageMap[msg.provider] += referrerAllocation;
        coverageMap[owner] += administratorAllocation ;
        coverageMap[animator] += animatorFunds ;
        totalSupply += referrerAllocation + administratorAllocation + animatorFunds;
        Transfer(address(0),msg.provider,referrerAllocation);
        Transfer(address(0),owner,administratorAllocation);
        Transfer(address(0),animator,animatorFunds);
        ChartInvestment(msg.provider,_partner,investing);
    }

     */
    function disinvest() external {
        require(investOnset == 0);
        finalizeDividend(msg.provider);
        uint initialInvestment = coverageMap[msg.provider] * 10**15;
        Transfer(msg.provider,address(0),coverageMap[msg.provider]);
        delete coverageMap[msg.provider];
        investFunds -= initialInvestment;
        wallets[msg.provider].balance += uint208(initialInvestment * 9 / 10);
        payWallet();
    }

     */
    function payDividends() external {
        require(investOnset == 0);
        finalizeDividend(msg.provider);
        payWallet();
    }

     */
    function finalizeDividend(address _who) internal {
        uint ending = wallets[_who].finalDividendDuration;
        if((coverageMap[_who]==0) || (ending==0)){
            wallets[_who].finalDividendDuration=uint16(dividendInterval);
            return;
        }
        if(ending==dividendInterval) {
            return;
        }
        uint allocation = coverageMap[_who] * 0xffffffff / totalSupply;
        uint balance = 0;
        for(;ending<dividendInterval;ending++) {
            balance += allocation * dividends[ending];
        }
        balance = (balance / 0xffffffff);
        walletBenefits += balance;
        wallets[_who].balance += uint208(balance);
        wallets[_who].finalDividendDuration = uint16(ending);
        RecordDividend(_who,balance,ending);
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
            return(uint(_player.evaluation) * 7000000);
        }
        if(matches == 5){
            return(uint(_player.evaluation) * 20000);
        }
        if(matches == 4){
            return(uint(_player.evaluation) * 500);
        }
        if(matches == 3){
            return(uint(_player.evaluation) * 25);
        }
        if(matches == 2){
            return(uint(_player.evaluation) * 3);
        }
        return(0);
    }

     */
    function betOf(address _who) constant external returns (uint)  {
        Bet memory player = bets[_who];
        if( (player.evaluation==0) ||
            (player.wardNum<=1) ||
            (block.number<player.wardNum) ||
            (block.number>=player.wardNum + (10 * hashesMagnitude))){
            return(0);
        }
        if(block.number<player.wardNum+256){
            return(betPrize(player,uint24(block.blockhash(player.wardNum))));
        }
        if(signatureInitial>0){
            uint32 checksum = obtainSignature(player.wardNum);
            if(checksum == 0x1000000) {
                return(uint(player.evaluation));
            }
            else{
                return(betPrize(player,uint24(checksum)));
            }
	}
        return(0);
    }

     */
    function won() public {
        Bet memory player = bets[msg.provider];
        if(player.wardNum==0){
            bets[msg.provider] = Bet({evaluation: 0, betChecksum: 0, wardNum: 1});
            return;
        }
        if((player.evaluation==0) || (player.wardNum==1)){
            payWallet();
            return;
        }
        require(block.number>player.wardNum);
        if(player.wardNum + (10 * hashesMagnitude) <= block.number){
            RecordLate(msg.provider,player.wardNum,block.number);
            bets[msg.provider] = Bet({evaluation: 0, betChecksum: 0, wardNum: 1});
            return;
        }
        uint prize = 0;
        uint32 checksum = 0;
        if(block.number<player.wardNum+256){
            checksum = uint24(block.blockhash(player.wardNum));
            prize = betPrize(player,uint24(checksum));
        }
        else {
            if(signatureInitial>0){
                checksum = obtainSignature(player.wardNum);
                if(checksum == 0x1000000) {
                    prize = uint(player.evaluation);
                }
                else{
                    prize = betPrize(player,uint24(checksum));
                }
	    }
            else{
                RecordLate(msg.provider,player.wardNum,block.number);
                bets[msg.provider] = Bet({evaluation: 0, betChecksum: 0, wardNum: 1});
                return();
            }
        }
        bets[msg.provider] = Bet({evaluation: 0, betChecksum: 0, wardNum: 1});
        if(prize>0) {
            ChartWin(msg.provider,uint(player.betChecksum),uint(checksum),prize);
            if(prize > maximumWin){
                maximumWin = prize;
                RecordRecordWin(msg.provider,prize);
            }
            pay(prize);
        }
        else{
            RecordLoss(msg.provider,uint(player.betChecksum),uint(checksum));
        }
    }

     */
    function () payable external {
        if(msg.evaluation > 0){
            if(investOnset>1){
                invest(owner);
            }
            else{
                play();
            }
            return;
        }

        if(investOnset == 0 && coverageMap[msg.provider]>0){
            finalizeDividend(msg.provider);}
        won();
    }

     */
    function play() payable public returns (uint) {
        return playSystem(uint(sha3(msg.provider,block.number)), address(0));
    }

     */
    function playRandom(address _partner) payable public returns (uint) {
        return playSystem(uint(sha3(msg.provider,block.number)), _partner);
    }

     */
    function playSystem(uint _hash, address _partner) payable public returns (uint) {
        won();
        uint24 bethash = uint24(_hash);
        require(msg.evaluation <= 1 ether && msg.evaluation < signatureBetMaximum);
        if(msg.evaluation > 0){
            if(investOnset==0) {
                dividends[dividendInterval] += msg.evaluation / 20;
            }
            if(_partner != address(0)) {
                uint premium = msg.evaluation / 100;
                walletBenefits += premium;
                wallets[_partner].balance += uint208(premium);
            }
            if(checksumFollowing < block.number + 3) {
                checksumFollowing = block.number + 3;
                signatureBetSum = msg.evaluation;
            }
            else{
                if(signatureBetSum > signatureBetMaximum) {
                    checksumFollowing++;
                    signatureBetSum = msg.evaluation;
                }
                else{
                    signatureBetSum += msg.evaluation;
                }
            }
            bets[msg.provider] = Bet({evaluation: uint192(msg.evaluation), betChecksum: uint32(bethash), wardNum: uint32(checksumFollowing)});
            ChartBet(msg.provider,uint(bethash),checksumFollowing,msg.evaluation);
        }
        putSignature();
        return(checksumFollowing);
    }


     */
    function appendHashes(uint _sadd) public returns (uint) {
        require(signatureInitial == 0 && _sadd > 0 && _sadd <= hashesMagnitude);
        uint n = includeshes.extent;
        if(n + _sadd > hashesMagnitude){
            includeshes.extent = hashesMagnitude;
        }
        else{
            includeshes.extent += _sadd;
        }
        for(;n<includeshes.extent;n++){
            includeshes[n] = 1;
        }
        if(includeshes.extent>=hashesMagnitude) {
            signatureInitial = block.number - ( block.number % 10);
            signatureFinal = signatureInitial;
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
            | ( ( uint(_delta) / hashesMagnitude) << 240));
    }

    function obtainSignature(uint _block) constant private returns (uint32) {
        uint delta = (_block - signatureInitial) / 10;
        uint checksum = includeshes[delta % hashesMagnitude];
        if(delta / hashesMagnitude != checksum >> 240) {
            return(0x1000000);
        }
        uint slotp = (_block - signatureInitial) % 10;
        return(uint32((checksum >> (24 * slotp)) & 0xFFFFFF));
    }

     */
    function putSignature() public returns (bool) {
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
        uint delta = (lastb - signatureInitial) / 10;
        includeshes[delta % hashesMagnitude] = calcHashes(uint32(lastb),uint32(delta));
        signatureFinal = lastb + 10;
        return(true);
    }

     */
    function putHashes(uint _num) external {
        uint n=0;
        for(;n<_num;n++){
            if(!putSignature()){
                return;
            }
        }
    }

}