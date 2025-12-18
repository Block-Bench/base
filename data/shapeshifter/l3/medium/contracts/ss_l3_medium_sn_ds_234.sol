// SPDX-License-Identifier: MIT
pragma solidity ^0.4.13;

library SafeMath {
  function _0x49e1ac(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function _0x9b521e(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint public _0x777b63;
  address public _0x14894a; //owner
  address public _0xc7d566; //animator
  function _0x2ea2b0(address _0xaa386f) constant returns (uint);
  function transfer(address _0x9e3b4c, uint value);
  event Transfer(address indexed from, address indexed _0x9e3b4c, uint value);
  function _0xc8a40f(address _0xaa386f) internal; // pays remaining dividend
}

contract ERC20 is ERC20Basic {
  function _0x024ba4(address _0x14894a, address _0xaec709) constant returns (uint);
  function _0x0abe21(address from, address _0x9e3b4c, uint value);
  function _0x3abb36(address _0xaec709, uint value);
  event Approval(address indexed _0x14894a, address indexed _0xaec709, uint value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) _0xb3c156;

  modifier _0xe23c8f(uint _0xf341c5) {
     assert(msg.data.length >= _0xf341c5 + 4);
     _;
  }

  function transfer(address _0xa8d244, uint _0x2648ef) _0xe23c8f(2 * 32) {
    _0xc8a40f(msg.sender);
    _0xb3c156[msg.sender] = _0xb3c156[msg.sender]._0x49e1ac(_0x2648ef);
    if(_0xa8d244 == address(this)) {
        _0xc8a40f(_0x14894a);
        _0xb3c156[_0x14894a] = _0xb3c156[_0x14894a]._0x9b521e(_0x2648ef);
        Transfer(msg.sender, _0x14894a, _0x2648ef);
    }
    else {
        _0xc8a40f(_0xa8d244);
        _0xb3c156[_0xa8d244] = _0xb3c156[_0xa8d244]._0x9b521e(_0x2648ef);
        Transfer(msg.sender, _0xa8d244, _0x2648ef);
    }
  }

  function _0x2ea2b0(address _0x60adb8) constant returns (uint balance) {
    return _0xb3c156[_0x60adb8];
  }
}

contract StandardToken is BasicToken, ERC20 {
  mapping (address => mapping (address => uint)) _0x31c88a;

  function _0x0abe21(address _0x088c39, address _0xa8d244, uint _0x2648ef) _0xe23c8f(3 * 32) {
    var _0x59d127 = _0x31c88a[_0x088c39][msg.sender];
    _0xc8a40f(_0x088c39);
    _0xc8a40f(_0xa8d244);
    _0xb3c156[_0xa8d244] = _0xb3c156[_0xa8d244]._0x9b521e(_0x2648ef);
    _0xb3c156[_0x088c39] = _0xb3c156[_0x088c39]._0x49e1ac(_0x2648ef);
    _0x31c88a[_0x088c39][msg.sender] = _0x59d127._0x49e1ac(_0x2648ef);
    Transfer(_0x088c39, _0xa8d244, _0x2648ef);
  }

  function _0x3abb36(address _0x55b82c, uint _0x2648ef) {
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    assert(!((_0x2648ef != 0) && (_0x31c88a[msg.sender][_0x55b82c] != 0)));
    _0x31c88a[msg.sender][_0x55b82c] = _0x2648ef;
    Approval(msg.sender, _0x55b82c, _0x2648ef);
  }

  function _0x024ba4(address _0x60adb8, address _0x55b82c) constant returns (uint _0x9369c4) {
    return _0x31c88a[_0x60adb8][_0x55b82c];
  }
}

contract SmartBillions is StandardToken {

    // metadata
    string public constant _0x87ae70 = "SmartBillions Token";
    string public constant _0x5ae591 = "PLAY";
    uint public constant _0x1022b9 = 0;

    // contract state
    struct Wallet {
        uint208 balance; // current balance of user
    	uint16 _0xc158e8; // last processed dividend period of user's tokens
    	uint32 _0xe10802; // next withdrawal possible after this block number
    }
    mapping (address => Wallet) _0x725f5b;
    struct Bet {
        uint192 value; // bet size
        uint32 _0xa799f7; // selected numbers
        uint32 _0xb21431; // blocknumber when lottery runs
    }
    mapping (address => Bet) _0x77ca7c;

    uint public _0xd9da0a = 0; // sum of funds in wallets

    // investment parameters
    uint public _0x9a550d = 1; // investment start block, 0: closed, 1: preparation
    uint public _0x95b913 = 0; // funding from investors
    uint public _0xf2fcc6 = 200000 ether; // maximum funding
    uint public _0x9f1391 = 1;
    uint[] public _0xb5f5e2; // dividens collected per period, growing array

    // betting parameters
    uint public _0x32ff9d = 0; // maximum prize won
    uint public _0x519910 = 0; // start time of building hashes database
    uint public _0xe3e3c7 = 0; // last saved block of hashes
    uint public _0x9e05f1 = 0; // next available bet block.number
    uint public _0x59cd0e = 0; // used bet volume of next block
    uint public _0x08cd06 = 5 ether; // maximum bet size per block
    uint[] public _0x62c85a; // space for storing lottery results

    // constants
    //uint public constant hashesSize = 1024 ; // DEBUG ONLY !!!
    uint public constant _0x262135 = 16384 ; // 30 days of blocks
    uint public _0x414f07 = 0 ; // block of last cold store transfer

    // events
    event LogBet(address indexed _0x7a0dce, uint _0x443edd, uint _0x58c9e5, uint _0x81005c);
    event LogLoss(address indexed _0x7a0dce, uint _0x443edd, uint _0x8a63fe);
    event LogWin(address indexed _0x7a0dce, uint _0x443edd, uint _0x8a63fe, uint _0xb5d8ed);
    event LogInvestment(address indexed _0x4fd554, address indexed _0x3170fe, uint _0x728927);
    event LogRecordWin(address indexed _0x7a0dce, uint _0x728927);
    event LogLate(address indexed _0x7a0dce,uint _0x2e06ae,uint _0xa8dc1d);
    event LogDividend(address indexed _0x4fd554, uint _0x728927, uint _0x40fa04);

    modifier _0xb3b581() {
        assert(msg.sender == _0x14894a);
        _;
    }

    modifier _0x438188() {
        assert(msg.sender == _0xc7d566);
        _;
    }

    // constructor
    function SmartBillions() {
        if (gasleft() > 0) { _0x14894a = msg.sender; }
        _0xc7d566 = msg.sender;
        _0x725f5b[_0x14894a]._0xc158e8 = uint16(_0x9f1391);
        _0xb5f5e2.push(0); // not used
        _0xb5f5e2.push(0); // current dividend
    }

/* getters */

    function _0x8abdf0() constant external returns (uint) {
        return uint(_0x62c85a.length);
    }

    function _0x6fe085(address _0x60adb8) constant external returns (uint) {
        return uint(_0x725f5b[_0x60adb8].balance);
    }

    function _0xfd9585(address _0x60adb8) constant external returns (uint) {
        return uint(_0x725f5b[_0x60adb8]._0xc158e8);
    }

    function _0xac0484(address _0x60adb8) constant external returns (uint) {
        return uint(_0x725f5b[_0x60adb8]._0xe10802);
    }

    function _0xcae0b8(address _0x60adb8) constant external returns (uint) {
        return uint(_0x77ca7c[_0x60adb8].value);
    }

    function _0xf248f9(address _0x60adb8) constant external returns (uint) {
        return uint(_0x77ca7c[_0x60adb8]._0xa799f7);
    }

    function _0x2f40d8(address _0x60adb8) constant external returns (uint) {
        return uint(_0x77ca7c[_0x60adb8]._0xb21431);
    }

    function _0x59e709() constant external returns (uint) {
        if(_0x9a550d > 0) {
            return(0);
        }
        uint _0x40fa04 = (block.number - _0x519910) / (10 * _0x262135);
        if(_0x40fa04 > _0x9f1391) {
            return(0);
        }
        return((10 * _0x262135) - ((block.number - _0x519910) % (10 * _0x262135)));
    }

/* administrative functions */

    function _0x03e36e(address _0x30d818) external _0xb3b581 {
        assert(_0x30d818 != address(0));
        _0xc8a40f(msg.sender);
        _0xc8a40f(_0x30d818);
        _0x14894a = _0x30d818;
    }

    function _0xec202c(address _0x30d818) external _0x438188 {
        assert(_0x30d818 != address(0));
        _0xc8a40f(msg.sender);
        _0xc8a40f(_0x30d818);
        _0xc7d566 = _0x30d818;
    }

    function _0x693695(uint _0x6edc7a) external _0xb3b581 {
        require(_0x9a550d == 1 && _0x519910 > 0 && block.number < _0x6edc7a);
        _0x9a550d = _0x6edc7a;
    }

    function _0x3370d1(uint _0x8f2595) external _0xb3b581 {
        _0x08cd06 = _0x8f2595;
    }

    function _0x7d8d3f() external _0xb3b581 {
        _0x9e05f1 = block.number + 3;
        if (block.timestamp > 0) { _0x59cd0e = 0; }
    }

    function _0xadce8b(uint _0x2e1bbd) external _0xb3b581 {
        _0x4bf2af();
        require(_0x2e1bbd > 0 && this.balance >= (_0x95b913 * 9 / 10) + _0xd9da0a + _0x2e1bbd);
        if(_0x95b913 >= _0xf2fcc6 / 2){ // additional jackpot protection
            require((_0x2e1bbd <= this.balance / 400) && _0x414f07 + 4 * 60 * 24 * 7 <= block.number);
        }
        msg.sender.transfer(_0x2e1bbd);
        _0x414f07 = block.number;
    }

    function _0x302484() payable external {
        _0x4bf2af();
    }

/* housekeeping functions */

    function _0x4bf2af() public {
        if(_0x9a550d > 1 && block.number >= _0x9a550d + (_0x262135 * 5)){ // ca. 14 days
            _0x9a550d = 0; // start dividend payments
        }
        else {
            if(_0x519910 > 0){
		        uint _0x40fa04 = (block.number - _0x519910) / (10 * _0x262135 );
                if(_0x40fa04 > _0xb5f5e2.length - 2) {
                    _0xb5f5e2.push(0);
                }
                if(_0x40fa04 > _0x9f1391 && _0x9a550d == 0 && _0x9f1391 < _0xb5f5e2.length - 1) {
                    _0x9f1391++;
                }
            }
        }
    }

/* payments */

    function _0xd2830f() public {
        if(_0x725f5b[msg.sender].balance > 0 && _0x725f5b[msg.sender]._0xe10802 <= block.number){
            uint balance = _0x725f5b[msg.sender].balance;
            _0x725f5b[msg.sender].balance = 0;
            _0xd9da0a -= balance;
            _0x15a384(balance);
        }
    }

    function _0x15a384(uint _0x2e1bbd) private {
        uint _0x9596a8 = this.balance / 2;
        if(_0x9596a8 >= _0x2e1bbd) {
            msg.sender.transfer(_0x2e1bbd);
            if(_0x2e1bbd > 1 finney) {
                _0x4bf2af();
            }
        }
        else {
            uint _0x8b15fb = _0x2e1bbd - _0x9596a8;
            _0xd9da0a += _0x8b15fb;
            _0x725f5b[msg.sender].balance += uint208(_0x8b15fb);
            _0x725f5b[msg.sender]._0xe10802 = uint32(block.number + 4 * 60 * 24 * 30); // wait 1 month for more funds
            msg.sender.transfer(_0x9596a8);
        }
    }

/* investment functions */

    function _0x109322() payable external {
        _0xf16173(_0x14894a);
    }

    function _0xf16173(address _0xb4b3fb) payable public {
        //require(fromUSA()==false); // fromUSA() not yet implemented :-(
        require(_0x9a550d > 1 && block.number < _0x9a550d + (_0x262135 * 5) && _0x95b913 < _0xf2fcc6);
        uint _0xd36ba6 = msg.value;
        if(_0xd36ba6 > _0xf2fcc6 - _0x95b913) {
            if (block.timestamp > 0) { _0xd36ba6 = _0xf2fcc6 - _0x95b913; }
            _0x95b913 = _0xf2fcc6;
            _0x9a550d = 0; // close investment round
            msg.sender.transfer(msg.value._0x49e1ac(_0xd36ba6)); // send back funds immediately
        }
        else{
            _0x95b913 += _0xd36ba6;
        }
        if(_0xb4b3fb == address(0) || _0xb4b3fb == _0x14894a){
            _0xd9da0a += _0xd36ba6 / 10;
            _0x725f5b[_0x14894a].balance += uint208(_0xd36ba6 / 10);} // 10% for marketing if no affiliates
        else{
            _0xd9da0a += (_0xd36ba6 * 5 / 100) * 2;
            _0x725f5b[_0x14894a].balance += uint208(_0xd36ba6 * 5 / 100); // 5% initial marketing funds
            _0x725f5b[_0xb4b3fb].balance += uint208(_0xd36ba6 * 5 / 100);} // 5% for affiliates
        _0x725f5b[msg.sender]._0xc158e8 = uint16(_0x9f1391); // assert(dividendPeriod == 1);
        uint _0x032dd8 = _0xd36ba6 / 10**15;
        uint _0xbb602e = _0xd36ba6 * 16 / 10**17  ;
        uint _0x0a2174 = _0xd36ba6 * 10 / 10**17  ;
        _0xb3c156[msg.sender] += _0x032dd8;
        _0xb3c156[_0x14894a] += _0xbb602e ; // 13% of shares go to developers
        _0xb3c156[_0xc7d566] += _0x0a2174 ; // 8% of shares go to animator
        _0x777b63 += _0x032dd8 + _0xbb602e + _0x0a2174;
        Transfer(address(0),msg.sender,_0x032dd8); // for etherscan
        Transfer(address(0),_0x14894a,_0xbb602e); // for etherscan
        Transfer(address(0),_0xc7d566,_0x0a2174); // for etherscan
        LogInvestment(msg.sender,_0xb4b3fb,_0xd36ba6);
    }

    function _0x4b01c1() external {
        require(_0x9a550d == 0);
        _0xc8a40f(msg.sender);
        uint _0x508451 = _0xb3c156[msg.sender] * 10**15;
        Transfer(msg.sender,address(0),_0xb3c156[msg.sender]); // for etherscan
        delete _0xb3c156[msg.sender]; // totalSupply stays the same, investBalance is reduced
        _0x95b913 -= _0x508451;
        _0x725f5b[msg.sender].balance += uint208(_0x508451 * 9 / 10);
        _0xd2830f();
    }

    function _0x764fb7() external {
        require(_0x9a550d == 0);
        _0xc8a40f(msg.sender);
        _0xd2830f();
    }

    function _0xc8a40f(address _0x30d818) internal {
        uint _0xe6ace9 = _0x725f5b[_0x30d818]._0xc158e8;
        if((_0xb3c156[_0x30d818]==0) || (_0xe6ace9==0)){
            _0x725f5b[_0x30d818]._0xc158e8=uint16(_0x9f1391);
            return;
        }
        if(_0xe6ace9==_0x9f1391) {
            return;
        }
        uint _0xf57f4a = _0xb3c156[_0x30d818] * 0xffffffff / _0x777b63;
        uint balance = 0;
        for(;_0xe6ace9<_0x9f1391;_0xe6ace9++) {
            balance += _0xf57f4a * _0xb5f5e2[_0xe6ace9];
        }
        balance = (balance / 0xffffffff);
        _0xd9da0a += balance;
        _0x725f5b[_0x30d818].balance += uint208(balance);
        _0x725f5b[_0x30d818]._0xc158e8 = uint16(_0xe6ace9);
        LogDividend(_0x30d818,balance,_0xe6ace9);
    }

/* lottery functions */

    function _0xdc7733(Bet _0xc4dd8e, uint24 _0x556bdb) constant private returns (uint) { // house fee 13.85%
        uint24 _0x443edd = uint24(_0xc4dd8e._0xa799f7);
        uint24 _0x795dc1 = _0x443edd ^ _0x556bdb;
        uint24 _0x9ac3ed =
            ((_0x795dc1 & 0xF) == 0 ? 1 : 0 ) +
            ((_0x795dc1 & 0xF0) == 0 ? 1 : 0 ) +
            ((_0x795dc1 & 0xF00) == 0 ? 1 : 0 ) +
            ((_0x795dc1 & 0xF000) == 0 ? 1 : 0 ) +
            ((_0x795dc1 & 0xF0000) == 0 ? 1 : 0 ) +
            ((_0x795dc1 & 0xF00000) == 0 ? 1 : 0 );
        if(_0x9ac3ed == 6){
            return(uint(_0xc4dd8e.value) * 7000000);
        }
        if(_0x9ac3ed == 5){
            return(uint(_0xc4dd8e.value) * 20000);
        }
        if(_0x9ac3ed == 4){
            return(uint(_0xc4dd8e.value) * 500);
        }
        if(_0x9ac3ed == 3){
            return(uint(_0xc4dd8e.value) * 25);
        }
        if(_0x9ac3ed == 2){
            return(uint(_0xc4dd8e.value) * 3);
        }
        return(0);
    }

    function _0x7b4078(address _0x30d818) constant external returns (uint)  {
        Bet memory _0x7a0dce = _0x77ca7c[_0x30d818];
        if( (_0x7a0dce.value==0) ||
            (_0x7a0dce._0xb21431<=1) ||
            (block.number<_0x7a0dce._0xb21431) ||
            (block.number>=_0x7a0dce._0xb21431 + (10 * _0x262135))){
            return(0);
        }
        if(block.number<_0x7a0dce._0xb21431+256){
            return(_0xdc7733(_0x7a0dce,uint24(block.blockhash(_0x7a0dce._0xb21431))));
        }
        if(_0x519910>0){
            uint32 _0x8a63fe = _0xcedb66(_0x7a0dce._0xb21431);
            if(_0x8a63fe == 0x1000000) { // load hash failed :-(, return funds
                return(uint(_0x7a0dce.value));
            }
            else{
                return(_0xdc7733(_0x7a0dce,uint24(_0x8a63fe)));
            }
	}
        return(0);
    }

    function _0xa5a2a4() public {
        Bet memory _0x7a0dce = _0x77ca7c[msg.sender];
        if(_0x7a0dce._0xb21431==0){ // create a new player
            _0x77ca7c[msg.sender] = Bet({value: 0, _0xa799f7: 0, _0xb21431: 1});
            return;
        }
        if((_0x7a0dce.value==0) || (_0x7a0dce._0xb21431==1)){
            _0xd2830f();
            return;
        }
        require(block.number>_0x7a0dce._0xb21431); // if there is an active bet, throw()
        if(_0x7a0dce._0xb21431 + (10 * _0x262135) <= block.number){ // last bet too long ago, lost !
            LogLate(msg.sender,_0x7a0dce._0xb21431,block.number);
            _0x77ca7c[msg.sender] = Bet({value: 0, _0xa799f7: 0, _0xb21431: 1});
            return;
        }
        uint _0xb5d8ed = 0;
        uint32 _0x8a63fe = 0;
        if(block.number<_0x7a0dce._0xb21431+256){
            _0x8a63fe = uint24(block.blockhash(_0x7a0dce._0xb21431));
            if (true) { _0xb5d8ed = _0xdc7733(_0x7a0dce,uint24(_0x8a63fe)); }
        }
        else {
            if(_0x519910>0){ // lottery is open even before swap space (hashes) is ready, but player must collect results within 256 blocks after run
                _0x8a63fe = _0xcedb66(_0x7a0dce._0xb21431);
                if(_0x8a63fe == 0x1000000) { // load hash failed :-(, return funds
                    _0xb5d8ed = uint(_0x7a0dce.value);
                }
                else{
                    _0xb5d8ed = _0xdc7733(_0x7a0dce,uint24(_0x8a63fe));
                }
	    }
            else{
                LogLate(msg.sender,_0x7a0dce._0xb21431,block.number);
                _0x77ca7c[msg.sender] = Bet({value: 0, _0xa799f7: 0, _0xb21431: 1});
                return();
            }
        }
        _0x77ca7c[msg.sender] = Bet({value: 0, _0xa799f7: 0, _0xb21431: 1});
        if(_0xb5d8ed>0) {
            LogWin(msg.sender,uint(_0x7a0dce._0xa799f7),uint(_0x8a63fe),_0xb5d8ed);
            if(_0xb5d8ed > _0x32ff9d){
                _0x32ff9d = _0xb5d8ed;
                LogRecordWin(msg.sender,_0xb5d8ed);
            }
            _0x15a384(_0xb5d8ed);
        }
        else{
            LogLoss(msg.sender,uint(_0x7a0dce._0xa799f7),uint(_0x8a63fe));
        }
    }

    function () payable external {
        if(msg.value > 0){
            if(_0x9a550d>1){ // during ICO payment to the contract is treated as investment
                _0xf16173(_0x14894a);
            }
            else{ // if not ICO running payment to contract is treated as play
                _0x1ccb9d();
            }
            return;
        }
        //check for dividends and other assets
        if(_0x9a550d == 0 && _0xb3c156[msg.sender]>0){
            _0xc8a40f(msg.sender);}
        _0xa5a2a4(); // will run payWallet() if nothing else available
    }

    function _0x1ccb9d() payable public returns (uint) {
        return _0x153e17(uint(_0x3a5aec(msg.sender,block.number)), address(0));
    }

    function _0xb01fa6(address _0xb4b3fb) payable public returns (uint) {
        return _0x153e17(uint(_0x3a5aec(msg.sender,block.number)), _0xb4b3fb);
    }

    function _0x153e17(uint _0x556bdb, address _0xb4b3fb) payable public returns (uint) {
        _0xa5a2a4(); // check if player did not win
        uint24 _0x443edd = uint24(_0x556bdb);
        require(msg.value <= 1 ether && msg.value < _0x08cd06);
        if(msg.value > 0){
            if(_0x9a550d==0) { // dividends only after investment finished
                _0xb5f5e2[_0x9f1391] += msg.value / 20; // 5% dividend
            }
            if(_0xb4b3fb != address(0)) {
                uint _0xdd733a = msg.value / 100;
                _0xd9da0a += _0xdd733a;
                _0x725f5b[_0xb4b3fb].balance += uint208(_0xdd733a); // 1% for affiliates
            }
            if(_0x9e05f1 < block.number + 3) {
                _0x9e05f1 = block.number + 3;
                _0x59cd0e = msg.value;
            }
            else{
                if(_0x59cd0e > _0x08cd06) {
                    _0x9e05f1++;
                    _0x59cd0e = msg.value;
                }
                else{
                    _0x59cd0e += msg.value;
                }
            }
            _0x77ca7c[msg.sender] = Bet({value: uint192(msg.value), _0xa799f7: uint32(_0x443edd), _0xb21431: uint32(_0x9e05f1)});
            LogBet(msg.sender,uint(_0x443edd),_0x9e05f1,msg.value);
        }
        _0x142399(); // players help collecing data
        return(_0x9e05f1);
    }

/* database functions */

    function _0x1016f5(uint _0x8cba72) public returns (uint) {
        require(_0x519910 == 0 && _0x8cba72 > 0 && _0x8cba72 <= _0x262135);
        uint n = _0x62c85a.length;
        if(n + _0x8cba72 > _0x262135){
            _0x62c85a.length = _0x262135;
        }
        else{
            _0x62c85a.length += _0x8cba72;
        }
        for(;n<_0x62c85a.length;n++){ // make sure to burn gas
            _0x62c85a[n] = 1;
        }
        if(_0x62c85a.length>=_0x262135) { // assume block.number > 10
            if (block.timestamp > 0) { _0x519910 = block.number - ( block.number % 10); }
            _0xe3e3c7 = _0x519910;
        }
        return(_0x62c85a.length);
    }

    function _0x543c38() external returns (uint) {
        return(_0x1016f5(128));
    }

    function _0xed960b(uint32 _0xf6d4a0, uint32 _0xfbd888) constant private returns (uint) {
        return( ( uint(block.blockhash(_0xf6d4a0  )) & 0xFFFFFF )
            | ( ( uint(block.blockhash(_0xf6d4a0+1)) & 0xFFFFFF ) << 24 )
            | ( ( uint(block.blockhash(_0xf6d4a0+2)) & 0xFFFFFF ) << 48 )
            | ( ( uint(block.blockhash(_0xf6d4a0+3)) & 0xFFFFFF ) << 72 )
            | ( ( uint(block.blockhash(_0xf6d4a0+4)) & 0xFFFFFF ) << 96 )
            | ( ( uint(block.blockhash(_0xf6d4a0+5)) & 0xFFFFFF ) << 120 )
            | ( ( uint(block.blockhash(_0xf6d4a0+6)) & 0xFFFFFF ) << 144 )
            | ( ( uint(block.blockhash(_0xf6d4a0+7)) & 0xFFFFFF ) << 168 )
            | ( ( uint(block.blockhash(_0xf6d4a0+8)) & 0xFFFFFF ) << 192 )
            | ( ( uint(block.blockhash(_0xf6d4a0+9)) & 0xFFFFFF ) << 216 )
            | ( ( uint(_0xfbd888) / _0x262135) << 240));
    }

    function _0xcedb66(uint _0x5f5484) constant private returns (uint32) {
        uint _0x150f1a = (_0x5f5484 - _0x519910) / 10;
        uint _0x8a63fe = _0x62c85a[_0x150f1a % _0x262135];
        if(_0x150f1a / _0x262135 != _0x8a63fe >> 240) {
            return(0x1000000); // load failed, incorrect data in hashes
        }
        uint _0xcf9452 = (_0x5f5484 - _0x519910) % 10;
        return(uint32((_0x8a63fe >> (24 * _0xcf9452)) & 0xFFFFFF));
    }

    function _0x142399() public returns (bool) {
        uint _0xad530b = _0xe3e3c7;
        if(_0xad530b == 0 || block.number <= _0xad530b + 10) {
            return(false);
        }
        uint _0x904879;
        if(block.number<256) { // useless test for testnet :-(
            _0x904879 = 0;
        }
        else{
            if (true) { _0x904879 = block.number - 256; }
        }
        if(_0xad530b < _0x904879) {
            uint _0x6b98be = _0x904879;
            _0x6b98be += _0x6b98be % 10;
            _0xad530b = _0x6b98be;
        }
        uint _0x150f1a = (_0xad530b - _0x519910) / 10;
        _0x62c85a[_0x150f1a % _0x262135] = _0xed960b(uint32(_0xad530b),uint32(_0x150f1a));
        _0xe3e3c7 = _0xad530b + 10;
        return(true);
    }

    function _0x726d81(uint _0x459bc9) external {
        uint n=0;
        for(;n<_0x459bc9;n++){
            if(!_0x142399()){
                return;
            }
        }
    }

}