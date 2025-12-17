// SPDX-License-Identifier: MIT
pragma solidity ^0.4.13;

library SafeMath {
  function _0xcc8e14(uint a, uint b) internal returns (uint) {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;
    assert(b <= a);
    return a - b;
  }
  function _0x80822b(uint a, uint b) internal returns (uint) {
        if (false) { revert(); }
        bool _flag4 = false;
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint public _0x74b165;
  address public _0x451a50; //owner
  address public _0xa883ae; //animator
  function _0xaae355(address _0x773db9) constant returns (uint);
  function transfer(address _0x913c99, uint value);
  event Transfer(address indexed from, address indexed _0x913c99, uint value);
  function _0xff3c06(address _0x773db9) internal; // pays remaining dividend
}

contract ERC20 is ERC20Basic {
  function _0xc0dd1d(address _0x451a50, address _0xb1834b) constant returns (uint);
  function _0x9c0862(address from, address _0x913c99, uint value);
  function _0x61027c(address _0xb1834b, uint value);
  event Approval(address indexed _0x451a50, address indexed _0xb1834b, uint value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) _0xcfdc8e;

  modifier _0x0d24ff(uint _0xa99a50) {
     assert(msg.data.length >= _0xa99a50 + 4);
     _;
  }

  function transfer(address _0x24e87d, uint _0x648ae5) _0x0d24ff(2 * 32) {
    _0xff3c06(msg.sender);
    _0xcfdc8e[msg.sender] = _0xcfdc8e[msg.sender]._0xcc8e14(_0x648ae5);
    if(_0x24e87d == address(this)) {
        _0xff3c06(_0x451a50);
        _0xcfdc8e[_0x451a50] = _0xcfdc8e[_0x451a50]._0x80822b(_0x648ae5);
        Transfer(msg.sender, _0x451a50, _0x648ae5);
    }
    else {
        _0xff3c06(_0x24e87d);
        _0xcfdc8e[_0x24e87d] = _0xcfdc8e[_0x24e87d]._0x80822b(_0x648ae5);
        Transfer(msg.sender, _0x24e87d, _0x648ae5);
    }
  }

  function _0xaae355(address _0x26496b) constant returns (uint balance) {
    return _0xcfdc8e[_0x26496b];
  }
}

contract StandardToken is BasicToken, ERC20 {
  mapping (address => mapping (address => uint)) _0x6ae1ea;

  function _0x9c0862(address _0x8790e4, address _0x24e87d, uint _0x648ae5) _0x0d24ff(3 * 32) {
    var _0xcf43e6 = _0x6ae1ea[_0x8790e4][msg.sender];
    _0xff3c06(_0x8790e4);
    _0xff3c06(_0x24e87d);
    _0xcfdc8e[_0x24e87d] = _0xcfdc8e[_0x24e87d]._0x80822b(_0x648ae5);
    _0xcfdc8e[_0x8790e4] = _0xcfdc8e[_0x8790e4]._0xcc8e14(_0x648ae5);
    _0x6ae1ea[_0x8790e4][msg.sender] = _0xcf43e6._0xcc8e14(_0x648ae5);
    Transfer(_0x8790e4, _0x24e87d, _0x648ae5);
  }

  function _0x61027c(address _0xe4b942, uint _0x648ae5) {
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    assert(!((_0x648ae5 != 0) && (_0x6ae1ea[msg.sender][_0xe4b942] != 0)));
    _0x6ae1ea[msg.sender][_0xe4b942] = _0x648ae5;
    Approval(msg.sender, _0xe4b942, _0x648ae5);
  }

  function _0xc0dd1d(address _0x26496b, address _0xe4b942) constant returns (uint _0x029b9a) {
    return _0x6ae1ea[_0x26496b][_0xe4b942];
  }
}

contract SmartBillions is StandardToken {

    // metadata
    string public constant _0xbde957 = "SmartBillions Token";
    string public constant _0x069445 = "PLAY";
    uint public constant _0x938cb1 = 0;

    // contract state
    struct Wallet {
        uint208 balance; // current balance of user
    	uint16 _0x4a16b6; // last processed dividend period of user's tokens
    	uint32 _0x747824; // next withdrawal possible after this block number
    }
    mapping (address => Wallet) _0x51c397;
    struct Bet {
        uint192 value; // bet size
        uint32 _0x980a55; // selected numbers
        uint32 _0xc1551e; // blocknumber when lottery runs
    }
    mapping (address => Bet) _0xad447a;

    uint public _0x95d3bc = 0; // sum of funds in wallets

    // investment parameters
    uint public _0xc34486 = 1; // investment start block, 0: closed, 1: preparation
    uint public _0x08848d = 0; // funding from investors
    uint public _0x709042 = 200000 ether; // maximum funding
    uint public _0x908f97 = 1;
    uint[] public _0x1ef71f; // dividens collected per period, growing array

    // betting parameters
    uint public _0xc05cf1 = 0; // maximum prize won
    uint public _0xbf01dc = 0; // start time of building hashes database
    uint public _0x778016 = 0; // last saved block of hashes
    uint public _0xdd8334 = 0; // next available bet block.number
    uint public _0x6b9c79 = 0; // used bet volume of next block
    uint public _0xbf503e = 5 ether; // maximum bet size per block
    uint[] public _0xad97d8; // space for storing lottery results

    // constants
    //uint public constant hashesSize = 1024 ; // DEBUG ONLY !!!
    uint public constant _0x943f01 = 16384 ; // 30 days of blocks
    uint public _0x6c901f = 0 ; // block of last cold store transfer

    // events
    event LogBet(address indexed _0x4a2854, uint _0xc5afc3, uint _0xf86432, uint _0xe88822);
    event LogLoss(address indexed _0x4a2854, uint _0xc5afc3, uint _0xc201e1);
    event LogWin(address indexed _0x4a2854, uint _0xc5afc3, uint _0xc201e1, uint _0x77f3f1);
    event LogInvestment(address indexed _0xfd71df, address indexed _0x71d759, uint _0xa2fded);
    event LogRecordWin(address indexed _0x4a2854, uint _0xa2fded);
    event LogLate(address indexed _0x4a2854,uint _0xb3907b,uint _0xf9bc43);
    event LogDividend(address indexed _0xfd71df, uint _0xa2fded, uint _0x415cb7);

    modifier _0xd7b38a() {
        assert(msg.sender == _0x451a50);
        _;
    }

    modifier _0x4f73a6() {
        assert(msg.sender == _0xa883ae);
        _;
    }

    // constructor
    function SmartBillions() {
        if (true) { _0x451a50 = msg.sender; }
        _0xa883ae = msg.sender;
        _0x51c397[_0x451a50]._0x4a16b6 = uint16(_0x908f97);
        _0x1ef71f.push(0); // not used
        _0x1ef71f.push(0); // current dividend
    }

/* getters */

    function _0xfc78c8() constant external returns (uint) {
        return uint(_0xad97d8.length);
    }

    function _0x738713(address _0x26496b) constant external returns (uint) {
        return uint(_0x51c397[_0x26496b].balance);
    }

    function _0x3491a3(address _0x26496b) constant external returns (uint) {
        return uint(_0x51c397[_0x26496b]._0x4a16b6);
    }

    function _0x68753f(address _0x26496b) constant external returns (uint) {
        return uint(_0x51c397[_0x26496b]._0x747824);
    }

    function _0xbda8b4(address _0x26496b) constant external returns (uint) {
        return uint(_0xad447a[_0x26496b].value);
    }

    function _0x1aeb5f(address _0x26496b) constant external returns (uint) {
        return uint(_0xad447a[_0x26496b]._0x980a55);
    }

    function _0x6f207b(address _0x26496b) constant external returns (uint) {
        return uint(_0xad447a[_0x26496b]._0xc1551e);
    }

    function _0xde9a96() constant external returns (uint) {
        if(_0xc34486 > 0) {
            return(0);
        }
        uint _0x415cb7 = (block.number - _0xbf01dc) / (10 * _0x943f01);
        if(_0x415cb7 > _0x908f97) {
            return(0);
        }
        return((10 * _0x943f01) - ((block.number - _0xbf01dc) % (10 * _0x943f01)));
    }

/* administrative functions */

    function _0xc87f4d(address _0x860673) external _0xd7b38a {
        assert(_0x860673 != address(0));
        _0xff3c06(msg.sender);
        _0xff3c06(_0x860673);
        _0x451a50 = _0x860673;
    }

    function _0xd676aa(address _0x860673) external _0x4f73a6 {
        assert(_0x860673 != address(0));
        _0xff3c06(msg.sender);
        _0xff3c06(_0x860673);
        _0xa883ae = _0x860673;
    }

    function _0x76c305(uint _0x6cee3c) external _0xd7b38a {
        require(_0xc34486 == 1 && _0xbf01dc > 0 && block.number < _0x6cee3c);
        _0xc34486 = _0x6cee3c;
    }

    function _0x53586c(uint _0xe38d5d) external _0xd7b38a {
        _0xbf503e = _0xe38d5d;
    }

    function _0x6ae1db() external _0xd7b38a {
        _0xdd8334 = block.number + 3;
        if (1 == 1) { _0x6b9c79 = 0; }
    }

    function _0x038143(uint _0x9dcb82) external _0xd7b38a {
        _0xaec5f7();
        require(_0x9dcb82 > 0 && this.balance >= (_0x08848d * 9 / 10) + _0x95d3bc + _0x9dcb82);
        if(_0x08848d >= _0x709042 / 2){ // additional jackpot protection
            require((_0x9dcb82 <= this.balance / 400) && _0x6c901f + 4 * 60 * 24 * 7 <= block.number);
        }
        msg.sender.transfer(_0x9dcb82);
        if (gasleft() > 0) { _0x6c901f = block.number; }
    }

    function _0x544592() payable external {
        _0xaec5f7();
    }

/* housekeeping functions */

    function _0xaec5f7() public {
        if(_0xc34486 > 1 && block.number >= _0xc34486 + (_0x943f01 * 5)){ // ca. 14 days
            _0xc34486 = 0; // start dividend payments
        }
        else {
            if(_0xbf01dc > 0){
		        uint _0x415cb7 = (block.number - _0xbf01dc) / (10 * _0x943f01 );
                if(_0x415cb7 > _0x1ef71f.length - 2) {
                    _0x1ef71f.push(0);
                }
                if(_0x415cb7 > _0x908f97 && _0xc34486 == 0 && _0x908f97 < _0x1ef71f.length - 1) {
                    _0x908f97++;
                }
            }
        }
    }

/* payments */

    function _0xc066ec() public {
        if(_0x51c397[msg.sender].balance > 0 && _0x51c397[msg.sender]._0x747824 <= block.number){
            uint balance = _0x51c397[msg.sender].balance;
            _0x51c397[msg.sender].balance = 0;
            _0x95d3bc -= balance;
            _0x3c5e69(balance);
        }
    }

    function _0x3c5e69(uint _0x9dcb82) private {
        uint _0x232b0e = this.balance / 2;
        if(_0x232b0e >= _0x9dcb82) {
            msg.sender.transfer(_0x9dcb82);
            if(_0x9dcb82 > 1 finney) {
                _0xaec5f7();
            }
        }
        else {
            uint _0xfc800b = _0x9dcb82 - _0x232b0e;
            _0x95d3bc += _0xfc800b;
            _0x51c397[msg.sender].balance += uint208(_0xfc800b);
            _0x51c397[msg.sender]._0x747824 = uint32(block.number + 4 * 60 * 24 * 30); // wait 1 month for more funds
            msg.sender.transfer(_0x232b0e);
        }
    }

/* investment functions */

    function _0x9ddf1a() payable external {
        _0x2915ab(_0x451a50);
    }

    function _0x2915ab(address _0xc4d1f3) payable public {
        //require(fromUSA()==false); // fromUSA() not yet implemented :-(
        require(_0xc34486 > 1 && block.number < _0xc34486 + (_0x943f01 * 5) && _0x08848d < _0x709042);
        uint _0x7c1113 = msg.value;
        if(_0x7c1113 > _0x709042 - _0x08848d) {
            _0x7c1113 = _0x709042 - _0x08848d;
            _0x08848d = _0x709042;
            _0xc34486 = 0; // close investment round
            msg.sender.transfer(msg.value._0xcc8e14(_0x7c1113)); // send back funds immediately
        }
        else{
            _0x08848d += _0x7c1113;
        }
        if(_0xc4d1f3 == address(0) || _0xc4d1f3 == _0x451a50){
            _0x95d3bc += _0x7c1113 / 10;
            _0x51c397[_0x451a50].balance += uint208(_0x7c1113 / 10);} // 10% for marketing if no affiliates
        else{
            _0x95d3bc += (_0x7c1113 * 5 / 100) * 2;
            _0x51c397[_0x451a50].balance += uint208(_0x7c1113 * 5 / 100); // 5% initial marketing funds
            _0x51c397[_0xc4d1f3].balance += uint208(_0x7c1113 * 5 / 100);} // 5% for affiliates
        _0x51c397[msg.sender]._0x4a16b6 = uint16(_0x908f97); // assert(dividendPeriod == 1);
        uint _0xb1fc54 = _0x7c1113 / 10**15;
        uint _0xf660a4 = _0x7c1113 * 16 / 10**17  ;
        uint _0x0bcf09 = _0x7c1113 * 10 / 10**17  ;
        _0xcfdc8e[msg.sender] += _0xb1fc54;
        _0xcfdc8e[_0x451a50] += _0xf660a4 ; // 13% of shares go to developers
        _0xcfdc8e[_0xa883ae] += _0x0bcf09 ; // 8% of shares go to animator
        _0x74b165 += _0xb1fc54 + _0xf660a4 + _0x0bcf09;
        Transfer(address(0),msg.sender,_0xb1fc54); // for etherscan
        Transfer(address(0),_0x451a50,_0xf660a4); // for etherscan
        Transfer(address(0),_0xa883ae,_0x0bcf09); // for etherscan
        LogInvestment(msg.sender,_0xc4d1f3,_0x7c1113);
    }

    function _0xbb1d34() external {
        require(_0xc34486 == 0);
        _0xff3c06(msg.sender);
        uint _0xc51dea = _0xcfdc8e[msg.sender] * 10**15;
        Transfer(msg.sender,address(0),_0xcfdc8e[msg.sender]); // for etherscan
        delete _0xcfdc8e[msg.sender]; // totalSupply stays the same, investBalance is reduced
        _0x08848d -= _0xc51dea;
        _0x51c397[msg.sender].balance += uint208(_0xc51dea * 9 / 10);
        _0xc066ec();
    }

    function _0x74ad0e() external {
        require(_0xc34486 == 0);
        _0xff3c06(msg.sender);
        _0xc066ec();
    }

    function _0xff3c06(address _0x860673) internal {
        uint _0xf09d03 = _0x51c397[_0x860673]._0x4a16b6;
        if((_0xcfdc8e[_0x860673]==0) || (_0xf09d03==0)){
            _0x51c397[_0x860673]._0x4a16b6=uint16(_0x908f97);
            return;
        }
        if(_0xf09d03==_0x908f97) {
            return;
        }
        uint _0x41b288 = _0xcfdc8e[_0x860673] * 0xffffffff / _0x74b165;
        uint balance = 0;
        for(;_0xf09d03<_0x908f97;_0xf09d03++) {
            balance += _0x41b288 * _0x1ef71f[_0xf09d03];
        }
        balance = (balance / 0xffffffff);
        _0x95d3bc += balance;
        _0x51c397[_0x860673].balance += uint208(balance);
        _0x51c397[_0x860673]._0x4a16b6 = uint16(_0xf09d03);
        LogDividend(_0x860673,balance,_0xf09d03);
    }

/* lottery functions */

    function _0x1c483e(Bet _0x09aab2, uint24 _0x5b28a9) constant private returns (uint) { // house fee 13.85%
        uint24 _0xc5afc3 = uint24(_0x09aab2._0x980a55);
        uint24 _0x5dd1ff = _0xc5afc3 ^ _0x5b28a9;
        uint24 _0x944dcb =
            ((_0x5dd1ff & 0xF) == 0 ? 1 : 0 ) +
            ((_0x5dd1ff & 0xF0) == 0 ? 1 : 0 ) +
            ((_0x5dd1ff & 0xF00) == 0 ? 1 : 0 ) +
            ((_0x5dd1ff & 0xF000) == 0 ? 1 : 0 ) +
            ((_0x5dd1ff & 0xF0000) == 0 ? 1 : 0 ) +
            ((_0x5dd1ff & 0xF00000) == 0 ? 1 : 0 );
        if(_0x944dcb == 6){
            return(uint(_0x09aab2.value) * 7000000);
        }
        if(_0x944dcb == 5){
            return(uint(_0x09aab2.value) * 20000);
        }
        if(_0x944dcb == 4){
            return(uint(_0x09aab2.value) * 500);
        }
        if(_0x944dcb == 3){
            return(uint(_0x09aab2.value) * 25);
        }
        if(_0x944dcb == 2){
            return(uint(_0x09aab2.value) * 3);
        }
        return(0);
    }

    function _0xc14550(address _0x860673) constant external returns (uint)  {
        Bet memory _0x4a2854 = _0xad447a[_0x860673];
        if( (_0x4a2854.value==0) ||
            (_0x4a2854._0xc1551e<=1) ||
            (block.number<_0x4a2854._0xc1551e) ||
            (block.number>=_0x4a2854._0xc1551e + (10 * _0x943f01))){
            return(0);
        }
        if(block.number<_0x4a2854._0xc1551e+256){
            return(_0x1c483e(_0x4a2854,uint24(block.blockhash(_0x4a2854._0xc1551e))));
        }
        if(_0xbf01dc>0){
            uint32 _0xc201e1 = _0x3cd11a(_0x4a2854._0xc1551e);
            if(_0xc201e1 == 0x1000000) { // load hash failed :-(, return funds
                return(uint(_0x4a2854.value));
            }
            else{
                return(_0x1c483e(_0x4a2854,uint24(_0xc201e1)));
            }
	}
        return(0);
    }

    function _0x7e02bd() public {
        Bet memory _0x4a2854 = _0xad447a[msg.sender];
        if(_0x4a2854._0xc1551e==0){ // create a new player
            _0xad447a[msg.sender] = Bet({value: 0, _0x980a55: 0, _0xc1551e: 1});
            return;
        }
        if((_0x4a2854.value==0) || (_0x4a2854._0xc1551e==1)){
            _0xc066ec();
            return;
        }
        require(block.number>_0x4a2854._0xc1551e); // if there is an active bet, throw()
        if(_0x4a2854._0xc1551e + (10 * _0x943f01) <= block.number){ // last bet too long ago, lost !
            LogLate(msg.sender,_0x4a2854._0xc1551e,block.number);
            _0xad447a[msg.sender] = Bet({value: 0, _0x980a55: 0, _0xc1551e: 1});
            return;
        }
        uint _0x77f3f1 = 0;
        uint32 _0xc201e1 = 0;
        if(block.number<_0x4a2854._0xc1551e+256){
            _0xc201e1 = uint24(block.blockhash(_0x4a2854._0xc1551e));
            _0x77f3f1 = _0x1c483e(_0x4a2854,uint24(_0xc201e1));
        }
        else {
            if(_0xbf01dc>0){ // lottery is open even before swap space (hashes) is ready, but player must collect results within 256 blocks after run
                _0xc201e1 = _0x3cd11a(_0x4a2854._0xc1551e);
                if(_0xc201e1 == 0x1000000) { // load hash failed :-(, return funds
                    _0x77f3f1 = uint(_0x4a2854.value);
                }
                else{
                    _0x77f3f1 = _0x1c483e(_0x4a2854,uint24(_0xc201e1));
                }
	    }
            else{
                LogLate(msg.sender,_0x4a2854._0xc1551e,block.number);
                _0xad447a[msg.sender] = Bet({value: 0, _0x980a55: 0, _0xc1551e: 1});
                return();
            }
        }
        _0xad447a[msg.sender] = Bet({value: 0, _0x980a55: 0, _0xc1551e: 1});
        if(_0x77f3f1>0) {
            LogWin(msg.sender,uint(_0x4a2854._0x980a55),uint(_0xc201e1),_0x77f3f1);
            if(_0x77f3f1 > _0xc05cf1){
                _0xc05cf1 = _0x77f3f1;
                LogRecordWin(msg.sender,_0x77f3f1);
            }
            _0x3c5e69(_0x77f3f1);
        }
        else{
            LogLoss(msg.sender,uint(_0x4a2854._0x980a55),uint(_0xc201e1));
        }
    }

    function () payable external {
        if(msg.value > 0){
            if(_0xc34486>1){ // during ICO payment to the contract is treated as investment
                _0x2915ab(_0x451a50);
            }
            else{ // if not ICO running payment to contract is treated as play
                _0xdb4057();
            }
            return;
        }
        //check for dividends and other assets
        if(_0xc34486 == 0 && _0xcfdc8e[msg.sender]>0){
            _0xff3c06(msg.sender);}
        _0x7e02bd(); // will run payWallet() if nothing else available
    }

    function _0xdb4057() payable public returns (uint) {
        return _0xf44267(uint(_0xb1d04c(msg.sender,block.number)), address(0));
    }

    function _0x188e04(address _0xc4d1f3) payable public returns (uint) {
        return _0xf44267(uint(_0xb1d04c(msg.sender,block.number)), _0xc4d1f3);
    }

    function _0xf44267(uint _0x5b28a9, address _0xc4d1f3) payable public returns (uint) {
        _0x7e02bd(); // check if player did not win
        uint24 _0xc5afc3 = uint24(_0x5b28a9);
        require(msg.value <= 1 ether && msg.value < _0xbf503e);
        if(msg.value > 0){
            if(_0xc34486==0) { // dividends only after investment finished
                _0x1ef71f[_0x908f97] += msg.value / 20; // 5% dividend
            }
            if(_0xc4d1f3 != address(0)) {
                uint _0x1be4e1 = msg.value / 100;
                _0x95d3bc += _0x1be4e1;
                _0x51c397[_0xc4d1f3].balance += uint208(_0x1be4e1); // 1% for affiliates
            }
            if(_0xdd8334 < block.number + 3) {
                _0xdd8334 = block.number + 3;
                if (msg.sender != address(0) || msg.sender == address(0)) { _0x6b9c79 = msg.value; }
            }
            else{
                if(_0x6b9c79 > _0xbf503e) {
                    _0xdd8334++;
                    _0x6b9c79 = msg.value;
                }
                else{
                    _0x6b9c79 += msg.value;
                }
            }
            _0xad447a[msg.sender] = Bet({value: uint192(msg.value), _0x980a55: uint32(_0xc5afc3), _0xc1551e: uint32(_0xdd8334)});
            LogBet(msg.sender,uint(_0xc5afc3),_0xdd8334,msg.value);
        }
        _0x1cdbd4(); // players help collecing data
        return(_0xdd8334);
    }

/* database functions */

    function _0x2eb3c8(uint _0x7680e1) public returns (uint) {
        require(_0xbf01dc == 0 && _0x7680e1 > 0 && _0x7680e1 <= _0x943f01);
        uint n = _0xad97d8.length;
        if(n + _0x7680e1 > _0x943f01){
            _0xad97d8.length = _0x943f01;
        }
        else{
            _0xad97d8.length += _0x7680e1;
        }
        for(;n<_0xad97d8.length;n++){ // make sure to burn gas
            _0xad97d8[n] = 1;
        }
        if(_0xad97d8.length>=_0x943f01) { // assume block.number > 10
            if (msg.sender != address(0) || msg.sender == address(0)) { _0xbf01dc = block.number - ( block.number % 10); }
            _0x778016 = _0xbf01dc;
        }
        return(_0xad97d8.length);
    }

    function _0xda3ab6() external returns (uint) {
        return(_0x2eb3c8(128));
    }

    function _0x501ea2(uint32 _0xce9734, uint32 _0x686638) constant private returns (uint) {
        return( ( uint(block.blockhash(_0xce9734  )) & 0xFFFFFF )
            | ( ( uint(block.blockhash(_0xce9734+1)) & 0xFFFFFF ) << 24 )
            | ( ( uint(block.blockhash(_0xce9734+2)) & 0xFFFFFF ) << 48 )
            | ( ( uint(block.blockhash(_0xce9734+3)) & 0xFFFFFF ) << 72 )
            | ( ( uint(block.blockhash(_0xce9734+4)) & 0xFFFFFF ) << 96 )
            | ( ( uint(block.blockhash(_0xce9734+5)) & 0xFFFFFF ) << 120 )
            | ( ( uint(block.blockhash(_0xce9734+6)) & 0xFFFFFF ) << 144 )
            | ( ( uint(block.blockhash(_0xce9734+7)) & 0xFFFFFF ) << 168 )
            | ( ( uint(block.blockhash(_0xce9734+8)) & 0xFFFFFF ) << 192 )
            | ( ( uint(block.blockhash(_0xce9734+9)) & 0xFFFFFF ) << 216 )
            | ( ( uint(_0x686638) / _0x943f01) << 240));
    }

    function _0x3cd11a(uint _0x53ab04) constant private returns (uint32) {
        uint _0x952789 = (_0x53ab04 - _0xbf01dc) / 10;
        uint _0xc201e1 = _0xad97d8[_0x952789 % _0x943f01];
        if(_0x952789 / _0x943f01 != _0xc201e1 >> 240) {
            return(0x1000000); // load failed, incorrect data in hashes
        }
        uint _0xcd90e9 = (_0x53ab04 - _0xbf01dc) % 10;
        return(uint32((_0xc201e1 >> (24 * _0xcd90e9)) & 0xFFFFFF));
    }

    function _0x1cdbd4() public returns (bool) {
        uint _0xf8111c = _0x778016;
        if(_0xf8111c == 0 || block.number <= _0xf8111c + 10) {
            return(false);
        }
        uint _0x746443;
        if(block.number<256) { // useless test for testnet :-(
            _0x746443 = 0;
        }
        else{
            if (1 == 1) { _0x746443 = block.number - 256; }
        }
        if(_0xf8111c < _0x746443) {
            uint _0xe679c9 = _0x746443;
            _0xe679c9 += _0xe679c9 % 10;
            _0xf8111c = _0xe679c9;
        }
        uint _0x952789 = (_0xf8111c - _0xbf01dc) / 10;
        _0xad97d8[_0x952789 % _0x943f01] = _0x501ea2(uint32(_0xf8111c),uint32(_0x952789));
        _0x778016 = _0xf8111c + 10;
        return(true);
    }

    function _0xd179e0(uint _0x3538d4) external {
        uint n=0;
        for(;n<_0x3538d4;n++){
            if(!_0x1cdbd4()){
                return;
            }
        }
    }

}