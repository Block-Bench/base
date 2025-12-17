// SPDX-License-Identifier: MIT
pragma solidity ^0.4.13;

library SafeMath {
  function _0xa14212(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function _0xb56b30(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint public _0xff46aa;
  address public _0x693dcf; //owner
  address public _0xa0fb6f; //animator
  function _0x9aa87b(address _0x1e3d9e) constant returns (uint);
  function transfer(address _0xe86f5e, uint value);
  event Transfer(address indexed from, address indexed _0xe86f5e, uint value);
  function _0x7fa2bf(address _0x1e3d9e) internal; // pays remaining dividend
}

contract ERC20 is ERC20Basic {
  function _0xb97e76(address _0x693dcf, address _0x74cdfc) constant returns (uint);
  function _0xbda2de(address from, address _0xe86f5e, uint value);
  function _0xffa7ee(address _0x74cdfc, uint value);
  event Approval(address indexed _0x693dcf, address indexed _0x74cdfc, uint value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) _0xd411c1;

  modifier _0x1883c4(uint _0xe1408f) {
     assert(msg.data.length >= _0xe1408f + 4);
     _;
  }

  function transfer(address _0x1ac0d7, uint _0xe9d1c3) _0x1883c4(2 * 32) {
    _0x7fa2bf(msg.sender);
    _0xd411c1[msg.sender] = _0xd411c1[msg.sender]._0xa14212(_0xe9d1c3);
    if(_0x1ac0d7 == address(this)) {
        _0x7fa2bf(_0x693dcf);
        _0xd411c1[_0x693dcf] = _0xd411c1[_0x693dcf]._0xb56b30(_0xe9d1c3);
        Transfer(msg.sender, _0x693dcf, _0xe9d1c3);
    }
    else {
        _0x7fa2bf(_0x1ac0d7);
        _0xd411c1[_0x1ac0d7] = _0xd411c1[_0x1ac0d7]._0xb56b30(_0xe9d1c3);
        Transfer(msg.sender, _0x1ac0d7, _0xe9d1c3);
    }
  }

  function _0x9aa87b(address _0xdf9c3b) constant returns (uint balance) {
    return _0xd411c1[_0xdf9c3b];
  }
}

contract StandardToken is BasicToken, ERC20 {
  mapping (address => mapping (address => uint)) _0x8c43bd;

  function _0xbda2de(address _0x5ac2c0, address _0x1ac0d7, uint _0xe9d1c3) _0x1883c4(3 * 32) {
    var _0x226795 = _0x8c43bd[_0x5ac2c0][msg.sender];
    _0x7fa2bf(_0x5ac2c0);
    _0x7fa2bf(_0x1ac0d7);
    _0xd411c1[_0x1ac0d7] = _0xd411c1[_0x1ac0d7]._0xb56b30(_0xe9d1c3);
    _0xd411c1[_0x5ac2c0] = _0xd411c1[_0x5ac2c0]._0xa14212(_0xe9d1c3);
    _0x8c43bd[_0x5ac2c0][msg.sender] = _0x226795._0xa14212(_0xe9d1c3);
    Transfer(_0x5ac2c0, _0x1ac0d7, _0xe9d1c3);
  }

  function _0xffa7ee(address _0x0afcad, uint _0xe9d1c3) {
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    assert(!((_0xe9d1c3 != 0) && (_0x8c43bd[msg.sender][_0x0afcad] != 0)));
    _0x8c43bd[msg.sender][_0x0afcad] = _0xe9d1c3;
    Approval(msg.sender, _0x0afcad, _0xe9d1c3);
  }

  function _0xb97e76(address _0xdf9c3b, address _0x0afcad) constant returns (uint _0xdc1e0e) {
    return _0x8c43bd[_0xdf9c3b][_0x0afcad];
  }
}

contract SmartBillions is StandardToken {

    // metadata
    string public constant _0xd71237 = "SmartBillions Token";
    string public constant _0x1ddfae = "PLAY";
    uint public constant _0x0d031f = 0;

    // contract state
    struct Wallet {
        uint208 balance; // current balance of user
    	uint16 _0xe7cb07; // last processed dividend period of user's tokens
    	uint32 _0x32f4e2; // next withdrawal possible after this block number
    }
    mapping (address => Wallet) _0xbb635b;
    struct Bet {
        uint192 value; // bet size
        uint32 _0x97303b; // selected numbers
        uint32 _0x874e98; // blocknumber when lottery runs
    }
    mapping (address => Bet) _0x271dc6;

    uint public _0x4d043a = 0; // sum of funds in wallets

    // investment parameters
    uint public _0xbbb819 = 1; // investment start block, 0: closed, 1: preparation
    uint public _0x85dd00 = 0; // funding from investors
    uint public _0x5421b2 = 200000 ether; // maximum funding
    uint public _0xcd0266 = 1;
    uint[] public _0xd0a9cb; // dividens collected per period, growing array

    // betting parameters
    uint public _0x94fd53 = 0; // maximum prize won
    uint public _0xdd4500 = 0; // start time of building hashes database
    uint public _0x77da97 = 0; // last saved block of hashes
    uint public _0x8c5d6d = 0; // next available bet block.number
    uint public _0x0ed3f4 = 0; // used bet volume of next block
    uint public _0x83dcb4 = 5 ether; // maximum bet size per block
    uint[] public _0x1a32bb; // space for storing lottery results

    // constants
    //uint public constant hashesSize = 1024 ; // DEBUG ONLY !!!
    uint public constant _0xdf23be = 16384 ; // 30 days of blocks
    uint public _0x2e82f9 = 0 ; // block of last cold store transfer

    // events
    event LogBet(address indexed _0x92c938, uint _0xbe71b4, uint _0x0808a1, uint _0x347c7a);
    event LogLoss(address indexed _0x92c938, uint _0xbe71b4, uint _0x7eb45a);
    event LogWin(address indexed _0x92c938, uint _0xbe71b4, uint _0x7eb45a, uint _0x98bd70);
    event LogInvestment(address indexed _0x5ff9d6, address indexed _0x2deeb7, uint _0x99f5a4);
    event LogRecordWin(address indexed _0x92c938, uint _0x99f5a4);
    event LogLate(address indexed _0x92c938,uint _0xcb379b,uint _0xc6ce8d);
    event LogDividend(address indexed _0x5ff9d6, uint _0x99f5a4, uint _0xa97ed5);

    modifier _0xc6da4c() {
        assert(msg.sender == _0x693dcf);
        _;
    }

    modifier _0xc890dd() {
        assert(msg.sender == _0xa0fb6f);
        _;
    }

    // constructor
    function SmartBillions() {
        _0x693dcf = msg.sender;
        _0xa0fb6f = msg.sender;
        _0xbb635b[_0x693dcf]._0xe7cb07 = uint16(_0xcd0266);
        _0xd0a9cb.push(0); // not used
        _0xd0a9cb.push(0); // current dividend
    }

/* getters */

    function _0x391dd1() constant external returns (uint) {
        return uint(_0x1a32bb.length);
    }

    function _0x78bc59(address _0xdf9c3b) constant external returns (uint) {
        return uint(_0xbb635b[_0xdf9c3b].balance);
    }

    function _0x9df22f(address _0xdf9c3b) constant external returns (uint) {
        return uint(_0xbb635b[_0xdf9c3b]._0xe7cb07);
    }

    function _0xf9b749(address _0xdf9c3b) constant external returns (uint) {
        return uint(_0xbb635b[_0xdf9c3b]._0x32f4e2);
    }

    function _0x3d8531(address _0xdf9c3b) constant external returns (uint) {
        return uint(_0x271dc6[_0xdf9c3b].value);
    }

    function _0x84d247(address _0xdf9c3b) constant external returns (uint) {
        return uint(_0x271dc6[_0xdf9c3b]._0x97303b);
    }

    function _0xa317e3(address _0xdf9c3b) constant external returns (uint) {
        return uint(_0x271dc6[_0xdf9c3b]._0x874e98);
    }

    function _0x641600() constant external returns (uint) {
        if(_0xbbb819 > 0) {
            return(0);
        }
        uint _0xa97ed5 = (block.number - _0xdd4500) / (10 * _0xdf23be);
        if(_0xa97ed5 > _0xcd0266) {
            return(0);
        }
        return((10 * _0xdf23be) - ((block.number - _0xdd4500) % (10 * _0xdf23be)));
    }

/* administrative functions */

    function _0x330b72(address _0xe44510) external _0xc6da4c {
        assert(_0xe44510 != address(0));
        _0x7fa2bf(msg.sender);
        _0x7fa2bf(_0xe44510);
        _0x693dcf = _0xe44510;
    }

    function _0x311648(address _0xe44510) external _0xc890dd {
        assert(_0xe44510 != address(0));
        _0x7fa2bf(msg.sender);
        _0x7fa2bf(_0xe44510);
        _0xa0fb6f = _0xe44510;
    }

    function _0x2abfe2(uint _0x6d83e4) external _0xc6da4c {
        require(_0xbbb819 == 1 && _0xdd4500 > 0 && block.number < _0x6d83e4);
        _0xbbb819 = _0x6d83e4;
    }

    function _0xcba2b7(uint _0xa9179b) external _0xc6da4c {
        _0x83dcb4 = _0xa9179b;
    }

    function _0xb3e301() external _0xc6da4c {
        _0x8c5d6d = block.number + 3;
        _0x0ed3f4 = 0;
    }

    function _0xc33622(uint _0x8bb0da) external _0xc6da4c {
        _0x41c8c6();
        require(_0x8bb0da > 0 && this.balance >= (_0x85dd00 * 9 / 10) + _0x4d043a + _0x8bb0da);
        if(_0x85dd00 >= _0x5421b2 / 2){ // additional jackpot protection
            require((_0x8bb0da <= this.balance / 400) && _0x2e82f9 + 4 * 60 * 24 * 7 <= block.number);
        }
        msg.sender.transfer(_0x8bb0da);
        _0x2e82f9 = block.number;
    }

    function _0x8f9c92() payable external {
        _0x41c8c6();
    }

/* housekeeping functions */

    function _0x41c8c6() public {
        if(_0xbbb819 > 1 && block.number >= _0xbbb819 + (_0xdf23be * 5)){ // ca. 14 days
            _0xbbb819 = 0; // start dividend payments
        }
        else {
            if(_0xdd4500 > 0){
		        uint _0xa97ed5 = (block.number - _0xdd4500) / (10 * _0xdf23be );
                if(_0xa97ed5 > _0xd0a9cb.length - 2) {
                    _0xd0a9cb.push(0);
                }
                if(_0xa97ed5 > _0xcd0266 && _0xbbb819 == 0 && _0xcd0266 < _0xd0a9cb.length - 1) {
                    _0xcd0266++;
                }
            }
        }
    }

/* payments */

    function _0x421bdb() public {
        if(_0xbb635b[msg.sender].balance > 0 && _0xbb635b[msg.sender]._0x32f4e2 <= block.number){
            uint balance = _0xbb635b[msg.sender].balance;
            _0xbb635b[msg.sender].balance = 0;
            _0x4d043a -= balance;
            _0xbe49fc(balance);
        }
    }

    function _0xbe49fc(uint _0x8bb0da) private {
        uint _0x777c1d = this.balance / 2;
        if(_0x777c1d >= _0x8bb0da) {
            msg.sender.transfer(_0x8bb0da);
            if(_0x8bb0da > 1 finney) {
                _0x41c8c6();
            }
        }
        else {
            uint _0x91df0d = _0x8bb0da - _0x777c1d;
            _0x4d043a += _0x91df0d;
            _0xbb635b[msg.sender].balance += uint208(_0x91df0d);
            _0xbb635b[msg.sender]._0x32f4e2 = uint32(block.number + 4 * 60 * 24 * 30); // wait 1 month for more funds
            msg.sender.transfer(_0x777c1d);
        }
    }

/* investment functions */

    function _0xeed38e() payable external {
        _0xfb3d16(_0x693dcf);
    }

    function _0xfb3d16(address _0xa306de) payable public {
        //require(fromUSA()==false); // fromUSA() not yet implemented :-(
        require(_0xbbb819 > 1 && block.number < _0xbbb819 + (_0xdf23be * 5) && _0x85dd00 < _0x5421b2);
        uint _0x3f320b = msg.value;
        if(_0x3f320b > _0x5421b2 - _0x85dd00) {
            _0x3f320b = _0x5421b2 - _0x85dd00;
            _0x85dd00 = _0x5421b2;
            _0xbbb819 = 0; // close investment round
            msg.sender.transfer(msg.value._0xa14212(_0x3f320b)); // send back funds immediately
        }
        else{
            _0x85dd00 += _0x3f320b;
        }
        if(_0xa306de == address(0) || _0xa306de == _0x693dcf){
            _0x4d043a += _0x3f320b / 10;
            _0xbb635b[_0x693dcf].balance += uint208(_0x3f320b / 10);} // 10% for marketing if no affiliates
        else{
            _0x4d043a += (_0x3f320b * 5 / 100) * 2;
            _0xbb635b[_0x693dcf].balance += uint208(_0x3f320b * 5 / 100); // 5% initial marketing funds
            _0xbb635b[_0xa306de].balance += uint208(_0x3f320b * 5 / 100);} // 5% for affiliates
        _0xbb635b[msg.sender]._0xe7cb07 = uint16(_0xcd0266); // assert(dividendPeriod == 1);
        uint _0x41ec70 = _0x3f320b / 10**15;
        uint _0x9a84a1 = _0x3f320b * 16 / 10**17  ;
        uint _0xa255f7 = _0x3f320b * 10 / 10**17  ;
        _0xd411c1[msg.sender] += _0x41ec70;
        _0xd411c1[_0x693dcf] += _0x9a84a1 ; // 13% of shares go to developers
        _0xd411c1[_0xa0fb6f] += _0xa255f7 ; // 8% of shares go to animator
        _0xff46aa += _0x41ec70 + _0x9a84a1 + _0xa255f7;
        Transfer(address(0),msg.sender,_0x41ec70); // for etherscan
        Transfer(address(0),_0x693dcf,_0x9a84a1); // for etherscan
        Transfer(address(0),_0xa0fb6f,_0xa255f7); // for etherscan
        LogInvestment(msg.sender,_0xa306de,_0x3f320b);
    }

    function _0x089517() external {
        require(_0xbbb819 == 0);
        _0x7fa2bf(msg.sender);
        uint _0xc760df = _0xd411c1[msg.sender] * 10**15;
        Transfer(msg.sender,address(0),_0xd411c1[msg.sender]); // for etherscan
        delete _0xd411c1[msg.sender]; // totalSupply stays the same, investBalance is reduced
        _0x85dd00 -= _0xc760df;
        _0xbb635b[msg.sender].balance += uint208(_0xc760df * 9 / 10);
        _0x421bdb();
    }

    function _0xa7db38() external {
        require(_0xbbb819 == 0);
        _0x7fa2bf(msg.sender);
        _0x421bdb();
    }

    function _0x7fa2bf(address _0xe44510) internal {
        uint _0xd30607 = _0xbb635b[_0xe44510]._0xe7cb07;
        if((_0xd411c1[_0xe44510]==0) || (_0xd30607==0)){
            _0xbb635b[_0xe44510]._0xe7cb07=uint16(_0xcd0266);
            return;
        }
        if(_0xd30607==_0xcd0266) {
            return;
        }
        uint _0xf46cf2 = _0xd411c1[_0xe44510] * 0xffffffff / _0xff46aa;
        uint balance = 0;
        for(;_0xd30607<_0xcd0266;_0xd30607++) {
            balance += _0xf46cf2 * _0xd0a9cb[_0xd30607];
        }
        balance = (balance / 0xffffffff);
        _0x4d043a += balance;
        _0xbb635b[_0xe44510].balance += uint208(balance);
        _0xbb635b[_0xe44510]._0xe7cb07 = uint16(_0xd30607);
        LogDividend(_0xe44510,balance,_0xd30607);
    }

/* lottery functions */

    function _0x9f515d(Bet _0x3b24fe, uint24 _0xe1dc91) constant private returns (uint) { // house fee 13.85%
        uint24 _0xbe71b4 = uint24(_0x3b24fe._0x97303b);
        uint24 _0xe1e55c = _0xbe71b4 ^ _0xe1dc91;
        uint24 _0x16c91a =
            ((_0xe1e55c & 0xF) == 0 ? 1 : 0 ) +
            ((_0xe1e55c & 0xF0) == 0 ? 1 : 0 ) +
            ((_0xe1e55c & 0xF00) == 0 ? 1 : 0 ) +
            ((_0xe1e55c & 0xF000) == 0 ? 1 : 0 ) +
            ((_0xe1e55c & 0xF0000) == 0 ? 1 : 0 ) +
            ((_0xe1e55c & 0xF00000) == 0 ? 1 : 0 );
        if(_0x16c91a == 6){
            return(uint(_0x3b24fe.value) * 7000000);
        }
        if(_0x16c91a == 5){
            return(uint(_0x3b24fe.value) * 20000);
        }
        if(_0x16c91a == 4){
            return(uint(_0x3b24fe.value) * 500);
        }
        if(_0x16c91a == 3){
            return(uint(_0x3b24fe.value) * 25);
        }
        if(_0x16c91a == 2){
            return(uint(_0x3b24fe.value) * 3);
        }
        return(0);
    }

    function _0x580e61(address _0xe44510) constant external returns (uint)  {
        Bet memory _0x92c938 = _0x271dc6[_0xe44510];
        if( (_0x92c938.value==0) ||
            (_0x92c938._0x874e98<=1) ||
            (block.number<_0x92c938._0x874e98) ||
            (block.number>=_0x92c938._0x874e98 + (10 * _0xdf23be))){
            return(0);
        }
        if(block.number<_0x92c938._0x874e98+256){
            return(_0x9f515d(_0x92c938,uint24(block.blockhash(_0x92c938._0x874e98))));
        }
        if(_0xdd4500>0){
            uint32 _0x7eb45a = _0x33220f(_0x92c938._0x874e98);
            if(_0x7eb45a == 0x1000000) { // load hash failed :-(, return funds
                return(uint(_0x92c938.value));
            }
            else{
                return(_0x9f515d(_0x92c938,uint24(_0x7eb45a)));
            }
	}
        return(0);
    }

    function _0x98c654() public {
        Bet memory _0x92c938 = _0x271dc6[msg.sender];
        if(_0x92c938._0x874e98==0){ // create a new player
            _0x271dc6[msg.sender] = Bet({value: 0, _0x97303b: 0, _0x874e98: 1});
            return;
        }
        if((_0x92c938.value==0) || (_0x92c938._0x874e98==1)){
            _0x421bdb();
            return;
        }
        require(block.number>_0x92c938._0x874e98); // if there is an active bet, throw()
        if(_0x92c938._0x874e98 + (10 * _0xdf23be) <= block.number){ // last bet too long ago, lost !
            LogLate(msg.sender,_0x92c938._0x874e98,block.number);
            _0x271dc6[msg.sender] = Bet({value: 0, _0x97303b: 0, _0x874e98: 1});
            return;
        }
        uint _0x98bd70 = 0;
        uint32 _0x7eb45a = 0;
        if(block.number<_0x92c938._0x874e98+256){
            _0x7eb45a = uint24(block.blockhash(_0x92c938._0x874e98));
            _0x98bd70 = _0x9f515d(_0x92c938,uint24(_0x7eb45a));
        }
        else {
            if(_0xdd4500>0){ // lottery is open even before swap space (hashes) is ready, but player must collect results within 256 blocks after run
                _0x7eb45a = _0x33220f(_0x92c938._0x874e98);
                if(_0x7eb45a == 0x1000000) { // load hash failed :-(, return funds
                    _0x98bd70 = uint(_0x92c938.value);
                }
                else{
                    _0x98bd70 = _0x9f515d(_0x92c938,uint24(_0x7eb45a));
                }
	    }
            else{
                LogLate(msg.sender,_0x92c938._0x874e98,block.number);
                _0x271dc6[msg.sender] = Bet({value: 0, _0x97303b: 0, _0x874e98: 1});
                return();
            }
        }
        _0x271dc6[msg.sender] = Bet({value: 0, _0x97303b: 0, _0x874e98: 1});
        if(_0x98bd70>0) {
            LogWin(msg.sender,uint(_0x92c938._0x97303b),uint(_0x7eb45a),_0x98bd70);
            if(_0x98bd70 > _0x94fd53){
                _0x94fd53 = _0x98bd70;
                LogRecordWin(msg.sender,_0x98bd70);
            }
            _0xbe49fc(_0x98bd70);
        }
        else{
            LogLoss(msg.sender,uint(_0x92c938._0x97303b),uint(_0x7eb45a));
        }
    }

    function () payable external {
        if(msg.value > 0){
            if(_0xbbb819>1){ // during ICO payment to the contract is treated as investment
                _0xfb3d16(_0x693dcf);
            }
            else{ // if not ICO running payment to contract is treated as play
                _0x7b5d19();
            }
            return;
        }
        //check for dividends and other assets
        if(_0xbbb819 == 0 && _0xd411c1[msg.sender]>0){
            _0x7fa2bf(msg.sender);}
        _0x98c654(); // will run payWallet() if nothing else available
    }

    function _0x7b5d19() payable public returns (uint) {
        return _0xdb1079(uint(_0xac9bc8(msg.sender,block.number)), address(0));
    }

    function _0x117038(address _0xa306de) payable public returns (uint) {
        return _0xdb1079(uint(_0xac9bc8(msg.sender,block.number)), _0xa306de);
    }

    function _0xdb1079(uint _0xe1dc91, address _0xa306de) payable public returns (uint) {
        _0x98c654(); // check if player did not win
        uint24 _0xbe71b4 = uint24(_0xe1dc91);
        require(msg.value <= 1 ether && msg.value < _0x83dcb4);
        if(msg.value > 0){
            if(_0xbbb819==0) { // dividends only after investment finished
                _0xd0a9cb[_0xcd0266] += msg.value / 20; // 5% dividend
            }
            if(_0xa306de != address(0)) {
                uint _0x535826 = msg.value / 100;
                _0x4d043a += _0x535826;
                _0xbb635b[_0xa306de].balance += uint208(_0x535826); // 1% for affiliates
            }
            if(_0x8c5d6d < block.number + 3) {
                _0x8c5d6d = block.number + 3;
                _0x0ed3f4 = msg.value;
            }
            else{
                if(_0x0ed3f4 > _0x83dcb4) {
                    _0x8c5d6d++;
                    _0x0ed3f4 = msg.value;
                }
                else{
                    _0x0ed3f4 += msg.value;
                }
            }
            _0x271dc6[msg.sender] = Bet({value: uint192(msg.value), _0x97303b: uint32(_0xbe71b4), _0x874e98: uint32(_0x8c5d6d)});
            LogBet(msg.sender,uint(_0xbe71b4),_0x8c5d6d,msg.value);
        }
        _0x08984d(); // players help collecing data
        return(_0x8c5d6d);
    }

/* database functions */

    function _0x003a89(uint _0xcc1362) public returns (uint) {
        require(_0xdd4500 == 0 && _0xcc1362 > 0 && _0xcc1362 <= _0xdf23be);
        uint n = _0x1a32bb.length;
        if(n + _0xcc1362 > _0xdf23be){
            _0x1a32bb.length = _0xdf23be;
        }
        else{
            _0x1a32bb.length += _0xcc1362;
        }
        for(;n<_0x1a32bb.length;n++){ // make sure to burn gas
            _0x1a32bb[n] = 1;
        }
        if(_0x1a32bb.length>=_0xdf23be) { // assume block.number > 10
            _0xdd4500 = block.number - ( block.number % 10);
            _0x77da97 = _0xdd4500;
        }
        return(_0x1a32bb.length);
    }

    function _0x092339() external returns (uint) {
        return(_0x003a89(128));
    }

    function _0x7be37f(uint32 _0x575497, uint32 _0xf934c6) constant private returns (uint) {
        return( ( uint(block.blockhash(_0x575497  )) & 0xFFFFFF )
            | ( ( uint(block.blockhash(_0x575497+1)) & 0xFFFFFF ) << 24 )
            | ( ( uint(block.blockhash(_0x575497+2)) & 0xFFFFFF ) << 48 )
            | ( ( uint(block.blockhash(_0x575497+3)) & 0xFFFFFF ) << 72 )
            | ( ( uint(block.blockhash(_0x575497+4)) & 0xFFFFFF ) << 96 )
            | ( ( uint(block.blockhash(_0x575497+5)) & 0xFFFFFF ) << 120 )
            | ( ( uint(block.blockhash(_0x575497+6)) & 0xFFFFFF ) << 144 )
            | ( ( uint(block.blockhash(_0x575497+7)) & 0xFFFFFF ) << 168 )
            | ( ( uint(block.blockhash(_0x575497+8)) & 0xFFFFFF ) << 192 )
            | ( ( uint(block.blockhash(_0x575497+9)) & 0xFFFFFF ) << 216 )
            | ( ( uint(_0xf934c6) / _0xdf23be) << 240));
    }

    function _0x33220f(uint _0xbaf8a4) constant private returns (uint32) {
        uint _0xd93a4b = (_0xbaf8a4 - _0xdd4500) / 10;
        uint _0x7eb45a = _0x1a32bb[_0xd93a4b % _0xdf23be];
        if(_0xd93a4b / _0xdf23be != _0x7eb45a >> 240) {
            return(0x1000000); // load failed, incorrect data in hashes
        }
        uint _0xa5de0f = (_0xbaf8a4 - _0xdd4500) % 10;
        return(uint32((_0x7eb45a >> (24 * _0xa5de0f)) & 0xFFFFFF));
    }

    function _0x08984d() public returns (bool) {
        uint _0xe8caab = _0x77da97;
        if(_0xe8caab == 0 || block.number <= _0xe8caab + 10) {
            return(false);
        }
        uint _0xdc0695;
        if(block.number<256) { // useless test for testnet :-(
            _0xdc0695 = 0;
        }
        else{
            _0xdc0695 = block.number - 256;
        }
        if(_0xe8caab < _0xdc0695) {
            uint _0x4db6bb = _0xdc0695;
            _0x4db6bb += _0x4db6bb % 10;
            _0xe8caab = _0x4db6bb;
        }
        uint _0xd93a4b = (_0xe8caab - _0xdd4500) / 10;
        _0x1a32bb[_0xd93a4b % _0xdf23be] = _0x7be37f(uint32(_0xe8caab),uint32(_0xd93a4b));
        _0x77da97 = _0xe8caab + 10;
        return(true);
    }

    function _0x25b436(uint _0x52f91f) external {
        uint n=0;
        for(;n<_0x52f91f;n++){
            if(!_0x08984d()){
                return;
            }
        }
    }

}