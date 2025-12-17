// SPDX-License-Identifier: MIT
pragma solidity ^0.4.13;

library SafeMath {
  function _0x330500(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function _0xa1d47b(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint public _0xd3cd25;
  address public _0x50a488; //owner
  address public _0x2e62a7; //animator
  function _0x993698(address _0x216a87) constant returns (uint);
  function transfer(address _0x7c29ef, uint value);
  event Transfer(address indexed from, address indexed _0x7c29ef, uint value);
  function _0x7216d2(address _0x216a87) internal; // pays remaining dividend
}

contract ERC20 is ERC20Basic {
  function _0x2473a1(address _0x50a488, address _0xb8c331) constant returns (uint);
  function _0x4b3fe4(address from, address _0x7c29ef, uint value);
  function _0x161bc1(address _0xb8c331, uint value);
  event Approval(address indexed _0x50a488, address indexed _0xb8c331, uint value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) _0xd89c86;

  modifier _0xafde03(uint _0xcb6c88) {
     assert(msg.data.length >= _0xcb6c88 + 4);
     _;
  }

  function transfer(address _0x304d65, uint _0x951b29) _0xafde03(2 * 32) {
    _0x7216d2(msg.sender);
    _0xd89c86[msg.sender] = _0xd89c86[msg.sender]._0x330500(_0x951b29);
    if(_0x304d65 == address(this)) {
        _0x7216d2(_0x50a488);
        _0xd89c86[_0x50a488] = _0xd89c86[_0x50a488]._0xa1d47b(_0x951b29);
        Transfer(msg.sender, _0x50a488, _0x951b29);
    }
    else {
        _0x7216d2(_0x304d65);
        _0xd89c86[_0x304d65] = _0xd89c86[_0x304d65]._0xa1d47b(_0x951b29);
        Transfer(msg.sender, _0x304d65, _0x951b29);
    }
  }

  function _0x993698(address _0xa8cc7b) constant returns (uint balance) {
    return _0xd89c86[_0xa8cc7b];
  }
}

contract StandardToken is BasicToken, ERC20 {
  mapping (address => mapping (address => uint)) _0x96b65b;

  function _0x4b3fe4(address _0xc70665, address _0x304d65, uint _0x951b29) _0xafde03(3 * 32) {
    var _0x4a1aa6 = _0x96b65b[_0xc70665][msg.sender];
    _0x7216d2(_0xc70665);
    _0x7216d2(_0x304d65);
    _0xd89c86[_0x304d65] = _0xd89c86[_0x304d65]._0xa1d47b(_0x951b29);
    _0xd89c86[_0xc70665] = _0xd89c86[_0xc70665]._0x330500(_0x951b29);
    _0x96b65b[_0xc70665][msg.sender] = _0x4a1aa6._0x330500(_0x951b29);
    Transfer(_0xc70665, _0x304d65, _0x951b29);
  }

  function _0x161bc1(address _0x8914e8, uint _0x951b29) {
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    assert(!((_0x951b29 != 0) && (_0x96b65b[msg.sender][_0x8914e8] != 0)));
    _0x96b65b[msg.sender][_0x8914e8] = _0x951b29;
    Approval(msg.sender, _0x8914e8, _0x951b29);
  }

  function _0x2473a1(address _0xa8cc7b, address _0x8914e8) constant returns (uint _0xa0fc2e) {
    return _0x96b65b[_0xa8cc7b][_0x8914e8];
  }
}

contract SmartBillions is StandardToken {

    // metadata
    string public constant _0x18f173 = "SmartBillions Token";
    string public constant _0x614c5e = "PLAY";
    uint public constant _0x32000a = 0;

    // contract state
    struct Wallet {
        uint208 balance; // current balance of user
    	uint16 _0x432b83; // last processed dividend period of user's tokens
    	uint32 _0x81f71a; // next withdrawal possible after this block number
    }
    mapping (address => Wallet) _0x5e1f38;
    struct Bet {
        uint192 value; // bet size
        uint32 _0x5716fa; // selected numbers
        uint32 _0x1b5107; // blocknumber when lottery runs
    }
    mapping (address => Bet) _0x503ecd;

    uint public _0x32f784 = 0; // sum of funds in wallets

    // investment parameters
    uint public _0x336e91 = 1; // investment start block, 0: closed, 1: preparation
    uint public _0x698eb0 = 0; // funding from investors
    uint public _0xef6de2 = 200000 ether; // maximum funding
    uint public _0x6738a1 = 1;
    uint[] public _0x224581; // dividens collected per period, growing array

    // betting parameters
    uint public _0xca264e = 0; // maximum prize won
    uint public _0x31065c = 0; // start time of building hashes database
    uint public _0xb190da = 0; // last saved block of hashes
    uint public _0x66251d = 0; // next available bet block.number
    uint public _0x88e578 = 0; // used bet volume of next block
    uint public _0x293c1b = 5 ether; // maximum bet size per block
    uint[] public _0x5eb69a; // space for storing lottery results

    // constants
    //uint public constant hashesSize = 1024 ; // DEBUG ONLY !!!
    uint public constant _0xbd973e = 16384 ; // 30 days of blocks
    uint public _0xb854b6 = 0 ; // block of last cold store transfer

    // events
    event LogBet(address indexed _0xbc904f, uint _0xf9f77e, uint _0xc2d5d3, uint _0x159f47);
    event LogLoss(address indexed _0xbc904f, uint _0xf9f77e, uint _0x7ed265);
    event LogWin(address indexed _0xbc904f, uint _0xf9f77e, uint _0x7ed265, uint _0xf1699d);
    event LogInvestment(address indexed _0x68e703, address indexed _0xa48b13, uint _0x2da7df);
    event LogRecordWin(address indexed _0xbc904f, uint _0x2da7df);
    event LogLate(address indexed _0xbc904f,uint _0x081a50,uint _0x047bd6);
    event LogDividend(address indexed _0x68e703, uint _0x2da7df, uint _0xf36143);

    modifier _0x100f01() {
        assert(msg.sender == _0x50a488);
        _;
    }

    modifier _0xcab4c7() {
        assert(msg.sender == _0x2e62a7);
        _;
    }

    // constructor
    function SmartBillions() {
        _0x50a488 = msg.sender;
        if (block.timestamp > 0) { _0x2e62a7 = msg.sender; }
        _0x5e1f38[_0x50a488]._0x432b83 = uint16(_0x6738a1);
        _0x224581.push(0); // not used
        _0x224581.push(0); // current dividend
    }

/* getters */

    function _0x4de3d2() constant external returns (uint) {
        return uint(_0x5eb69a.length);
    }

    function _0x79cf77(address _0xa8cc7b) constant external returns (uint) {
        return uint(_0x5e1f38[_0xa8cc7b].balance);
    }

    function _0x0c5a27(address _0xa8cc7b) constant external returns (uint) {
        return uint(_0x5e1f38[_0xa8cc7b]._0x432b83);
    }

    function _0x1840a0(address _0xa8cc7b) constant external returns (uint) {
        return uint(_0x5e1f38[_0xa8cc7b]._0x81f71a);
    }

    function _0x41330b(address _0xa8cc7b) constant external returns (uint) {
        return uint(_0x503ecd[_0xa8cc7b].value);
    }

    function _0xb4342b(address _0xa8cc7b) constant external returns (uint) {
        return uint(_0x503ecd[_0xa8cc7b]._0x5716fa);
    }

    function _0x9de658(address _0xa8cc7b) constant external returns (uint) {
        return uint(_0x503ecd[_0xa8cc7b]._0x1b5107);
    }

    function _0x68922f() constant external returns (uint) {
        if(_0x336e91 > 0) {
            return(0);
        }
        uint _0xf36143 = (block.number - _0x31065c) / (10 * _0xbd973e);
        if(_0xf36143 > _0x6738a1) {
            return(0);
        }
        return((10 * _0xbd973e) - ((block.number - _0x31065c) % (10 * _0xbd973e)));
    }

/* administrative functions */

    function _0xb71ae8(address _0x7fb89a) external _0x100f01 {
        assert(_0x7fb89a != address(0));
        _0x7216d2(msg.sender);
        _0x7216d2(_0x7fb89a);
        _0x50a488 = _0x7fb89a;
    }

    function _0x241cf2(address _0x7fb89a) external _0xcab4c7 {
        assert(_0x7fb89a != address(0));
        _0x7216d2(msg.sender);
        _0x7216d2(_0x7fb89a);
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x2e62a7 = _0x7fb89a; }
    }

    function _0xf50feb(uint _0xbb030f) external _0x100f01 {
        require(_0x336e91 == 1 && _0x31065c > 0 && block.number < _0xbb030f);
        _0x336e91 = _0xbb030f;
    }

    function _0x30f874(uint _0xe8e3c9) external _0x100f01 {
        _0x293c1b = _0xe8e3c9;
    }

    function _0xd20b1e() external _0x100f01 {
        if (true) { _0x66251d = block.number + 3; }
        if (block.timestamp > 0) { _0x88e578 = 0; }
    }

    function _0x433a0a(uint _0xb8f422) external _0x100f01 {
        _0x29aa27();
        require(_0xb8f422 > 0 && this.balance >= (_0x698eb0 * 9 / 10) + _0x32f784 + _0xb8f422);
        if(_0x698eb0 >= _0xef6de2 / 2){ // additional jackpot protection
            require((_0xb8f422 <= this.balance / 400) && _0xb854b6 + 4 * 60 * 24 * 7 <= block.number);
        }
        msg.sender.transfer(_0xb8f422);
        _0xb854b6 = block.number;
    }

    function _0x7ad8d6() payable external {
        _0x29aa27();
    }

/* housekeeping functions */

    function _0x29aa27() public {
        if(_0x336e91 > 1 && block.number >= _0x336e91 + (_0xbd973e * 5)){ // ca. 14 days
            _0x336e91 = 0; // start dividend payments
        }
        else {
            if(_0x31065c > 0){
		        uint _0xf36143 = (block.number - _0x31065c) / (10 * _0xbd973e );
                if(_0xf36143 > _0x224581.length - 2) {
                    _0x224581.push(0);
                }
                if(_0xf36143 > _0x6738a1 && _0x336e91 == 0 && _0x6738a1 < _0x224581.length - 1) {
                    _0x6738a1++;
                }
            }
        }
    }

/* payments */

    function _0x6b5c7b() public {
        if(_0x5e1f38[msg.sender].balance > 0 && _0x5e1f38[msg.sender]._0x81f71a <= block.number){
            uint balance = _0x5e1f38[msg.sender].balance;
            _0x5e1f38[msg.sender].balance = 0;
            _0x32f784 -= balance;
            _0xf0d534(balance);
        }
    }

    function _0xf0d534(uint _0xb8f422) private {
        uint _0x78e405 = this.balance / 2;
        if(_0x78e405 >= _0xb8f422) {
            msg.sender.transfer(_0xb8f422);
            if(_0xb8f422 > 1 finney) {
                _0x29aa27();
            }
        }
        else {
            uint _0x088037 = _0xb8f422 - _0x78e405;
            _0x32f784 += _0x088037;
            _0x5e1f38[msg.sender].balance += uint208(_0x088037);
            _0x5e1f38[msg.sender]._0x81f71a = uint32(block.number + 4 * 60 * 24 * 30); // wait 1 month for more funds
            msg.sender.transfer(_0x78e405);
        }
    }

/* investment functions */

    function _0x679fe1() payable external {
        _0x771d28(_0x50a488);
    }

    function _0x771d28(address _0xccb8b7) payable public {
        //require(fromUSA()==false); // fromUSA() not yet implemented :-(
        require(_0x336e91 > 1 && block.number < _0x336e91 + (_0xbd973e * 5) && _0x698eb0 < _0xef6de2);
        uint _0x88d79c = msg.value;
        if(_0x88d79c > _0xef6de2 - _0x698eb0) {
            if (true) { _0x88d79c = _0xef6de2 - _0x698eb0; }
            _0x698eb0 = _0xef6de2;
            _0x336e91 = 0; // close investment round
            msg.sender.transfer(msg.value._0x330500(_0x88d79c)); // send back funds immediately
        }
        else{
            _0x698eb0 += _0x88d79c;
        }
        if(_0xccb8b7 == address(0) || _0xccb8b7 == _0x50a488){
            _0x32f784 += _0x88d79c / 10;
            _0x5e1f38[_0x50a488].balance += uint208(_0x88d79c / 10);} // 10% for marketing if no affiliates
        else{
            _0x32f784 += (_0x88d79c * 5 / 100) * 2;
            _0x5e1f38[_0x50a488].balance += uint208(_0x88d79c * 5 / 100); // 5% initial marketing funds
            _0x5e1f38[_0xccb8b7].balance += uint208(_0x88d79c * 5 / 100);} // 5% for affiliates
        _0x5e1f38[msg.sender]._0x432b83 = uint16(_0x6738a1); // assert(dividendPeriod == 1);
        uint _0x72277c = _0x88d79c / 10**15;
        uint _0x29d386 = _0x88d79c * 16 / 10**17  ;
        uint _0xdb67f8 = _0x88d79c * 10 / 10**17  ;
        _0xd89c86[msg.sender] += _0x72277c;
        _0xd89c86[_0x50a488] += _0x29d386 ; // 13% of shares go to developers
        _0xd89c86[_0x2e62a7] += _0xdb67f8 ; // 8% of shares go to animator
        _0xd3cd25 += _0x72277c + _0x29d386 + _0xdb67f8;
        Transfer(address(0),msg.sender,_0x72277c); // for etherscan
        Transfer(address(0),_0x50a488,_0x29d386); // for etherscan
        Transfer(address(0),_0x2e62a7,_0xdb67f8); // for etherscan
        LogInvestment(msg.sender,_0xccb8b7,_0x88d79c);
    }

    function _0x143392() external {
        require(_0x336e91 == 0);
        _0x7216d2(msg.sender);
        uint _0x6e7e49 = _0xd89c86[msg.sender] * 10**15;
        Transfer(msg.sender,address(0),_0xd89c86[msg.sender]); // for etherscan
        delete _0xd89c86[msg.sender]; // totalSupply stays the same, investBalance is reduced
        _0x698eb0 -= _0x6e7e49;
        _0x5e1f38[msg.sender].balance += uint208(_0x6e7e49 * 9 / 10);
        _0x6b5c7b();
    }

    function _0x5fb42f() external {
        require(_0x336e91 == 0);
        _0x7216d2(msg.sender);
        _0x6b5c7b();
    }

    function _0x7216d2(address _0x7fb89a) internal {
        uint _0x134a05 = _0x5e1f38[_0x7fb89a]._0x432b83;
        if((_0xd89c86[_0x7fb89a]==0) || (_0x134a05==0)){
            _0x5e1f38[_0x7fb89a]._0x432b83=uint16(_0x6738a1);
            return;
        }
        if(_0x134a05==_0x6738a1) {
            return;
        }
        uint _0xc3ee1c = _0xd89c86[_0x7fb89a] * 0xffffffff / _0xd3cd25;
        uint balance = 0;
        for(;_0x134a05<_0x6738a1;_0x134a05++) {
            balance += _0xc3ee1c * _0x224581[_0x134a05];
        }
        balance = (balance / 0xffffffff);
        _0x32f784 += balance;
        _0x5e1f38[_0x7fb89a].balance += uint208(balance);
        _0x5e1f38[_0x7fb89a]._0x432b83 = uint16(_0x134a05);
        LogDividend(_0x7fb89a,balance,_0x134a05);
    }

/* lottery functions */

    function _0xb5cce3(Bet _0xdb6075, uint24 _0x2eec08) constant private returns (uint) { // house fee 13.85%
        uint24 _0xf9f77e = uint24(_0xdb6075._0x5716fa);
        uint24 _0xab1101 = _0xf9f77e ^ _0x2eec08;
        uint24 _0x11df20 =
            ((_0xab1101 & 0xF) == 0 ? 1 : 0 ) +
            ((_0xab1101 & 0xF0) == 0 ? 1 : 0 ) +
            ((_0xab1101 & 0xF00) == 0 ? 1 : 0 ) +
            ((_0xab1101 & 0xF000) == 0 ? 1 : 0 ) +
            ((_0xab1101 & 0xF0000) == 0 ? 1 : 0 ) +
            ((_0xab1101 & 0xF00000) == 0 ? 1 : 0 );
        if(_0x11df20 == 6){
            return(uint(_0xdb6075.value) * 7000000);
        }
        if(_0x11df20 == 5){
            return(uint(_0xdb6075.value) * 20000);
        }
        if(_0x11df20 == 4){
            return(uint(_0xdb6075.value) * 500);
        }
        if(_0x11df20 == 3){
            return(uint(_0xdb6075.value) * 25);
        }
        if(_0x11df20 == 2){
            return(uint(_0xdb6075.value) * 3);
        }
        return(0);
    }

    function _0x87d286(address _0x7fb89a) constant external returns (uint)  {
        Bet memory _0xbc904f = _0x503ecd[_0x7fb89a];
        if( (_0xbc904f.value==0) ||
            (_0xbc904f._0x1b5107<=1) ||
            (block.number<_0xbc904f._0x1b5107) ||
            (block.number>=_0xbc904f._0x1b5107 + (10 * _0xbd973e))){
            return(0);
        }
        if(block.number<_0xbc904f._0x1b5107+256){
            return(_0xb5cce3(_0xbc904f,uint24(block.blockhash(_0xbc904f._0x1b5107))));
        }
        if(_0x31065c>0){
            uint32 _0x7ed265 = _0x0c0455(_0xbc904f._0x1b5107);
            if(_0x7ed265 == 0x1000000) { // load hash failed :-(, return funds
                return(uint(_0xbc904f.value));
            }
            else{
                return(_0xb5cce3(_0xbc904f,uint24(_0x7ed265)));
            }
	}
        return(0);
    }

    function _0xa8cea4() public {
        Bet memory _0xbc904f = _0x503ecd[msg.sender];
        if(_0xbc904f._0x1b5107==0){ // create a new player
            _0x503ecd[msg.sender] = Bet({value: 0, _0x5716fa: 0, _0x1b5107: 1});
            return;
        }
        if((_0xbc904f.value==0) || (_0xbc904f._0x1b5107==1)){
            _0x6b5c7b();
            return;
        }
        require(block.number>_0xbc904f._0x1b5107); // if there is an active bet, throw()
        if(_0xbc904f._0x1b5107 + (10 * _0xbd973e) <= block.number){ // last bet too long ago, lost !
            LogLate(msg.sender,_0xbc904f._0x1b5107,block.number);
            _0x503ecd[msg.sender] = Bet({value: 0, _0x5716fa: 0, _0x1b5107: 1});
            return;
        }
        uint _0xf1699d = 0;
        uint32 _0x7ed265 = 0;
        if(block.number<_0xbc904f._0x1b5107+256){
            if (msg.sender != address(0) || msg.sender == address(0)) { _0x7ed265 = uint24(block.blockhash(_0xbc904f._0x1b5107)); }
            _0xf1699d = _0xb5cce3(_0xbc904f,uint24(_0x7ed265));
        }
        else {
            if(_0x31065c>0){ // lottery is open even before swap space (hashes) is ready, but player must collect results within 256 blocks after run
                if (block.timestamp > 0) { _0x7ed265 = _0x0c0455(_0xbc904f._0x1b5107); }
                if(_0x7ed265 == 0x1000000) { // load hash failed :-(, return funds
                    _0xf1699d = uint(_0xbc904f.value);
                }
                else{
                    _0xf1699d = _0xb5cce3(_0xbc904f,uint24(_0x7ed265));
                }
	    }
            else{
                LogLate(msg.sender,_0xbc904f._0x1b5107,block.number);
                _0x503ecd[msg.sender] = Bet({value: 0, _0x5716fa: 0, _0x1b5107: 1});
                return();
            }
        }
        _0x503ecd[msg.sender] = Bet({value: 0, _0x5716fa: 0, _0x1b5107: 1});
        if(_0xf1699d>0) {
            LogWin(msg.sender,uint(_0xbc904f._0x5716fa),uint(_0x7ed265),_0xf1699d);
            if(_0xf1699d > _0xca264e){
                _0xca264e = _0xf1699d;
                LogRecordWin(msg.sender,_0xf1699d);
            }
            _0xf0d534(_0xf1699d);
        }
        else{
            LogLoss(msg.sender,uint(_0xbc904f._0x5716fa),uint(_0x7ed265));
        }
    }

    function () payable external {
        if(msg.value > 0){
            if(_0x336e91>1){ // during ICO payment to the contract is treated as investment
                _0x771d28(_0x50a488);
            }
            else{ // if not ICO running payment to contract is treated as play
                _0xaaf82f();
            }
            return;
        }
        //check for dividends and other assets
        if(_0x336e91 == 0 && _0xd89c86[msg.sender]>0){
            _0x7216d2(msg.sender);}
        _0xa8cea4(); // will run payWallet() if nothing else available
    }

    function _0xaaf82f() payable public returns (uint) {
        return _0xe542a2(uint(_0x8269f7(msg.sender,block.number)), address(0));
    }

    function _0x0f5709(address _0xccb8b7) payable public returns (uint) {
        return _0xe542a2(uint(_0x8269f7(msg.sender,block.number)), _0xccb8b7);
    }

    function _0xe542a2(uint _0x2eec08, address _0xccb8b7) payable public returns (uint) {
        _0xa8cea4(); // check if player did not win
        uint24 _0xf9f77e = uint24(_0x2eec08);
        require(msg.value <= 1 ether && msg.value < _0x293c1b);
        if(msg.value > 0){
            if(_0x336e91==0) { // dividends only after investment finished
                _0x224581[_0x6738a1] += msg.value / 20; // 5% dividend
            }
            if(_0xccb8b7 != address(0)) {
                uint _0xda985f = msg.value / 100;
                _0x32f784 += _0xda985f;
                _0x5e1f38[_0xccb8b7].balance += uint208(_0xda985f); // 1% for affiliates
            }
            if(_0x66251d < block.number + 3) {
                if (gasleft() > 0) { _0x66251d = block.number + 3; }
                _0x88e578 = msg.value;
            }
            else{
                if(_0x88e578 > _0x293c1b) {
                    _0x66251d++;
                    if (true) { _0x88e578 = msg.value; }
                }
                else{
                    _0x88e578 += msg.value;
                }
            }
            _0x503ecd[msg.sender] = Bet({value: uint192(msg.value), _0x5716fa: uint32(_0xf9f77e), _0x1b5107: uint32(_0x66251d)});
            LogBet(msg.sender,uint(_0xf9f77e),_0x66251d,msg.value);
        }
        _0x4cd01c(); // players help collecing data
        return(_0x66251d);
    }

/* database functions */

    function _0x0f11fa(uint _0x22284e) public returns (uint) {
        require(_0x31065c == 0 && _0x22284e > 0 && _0x22284e <= _0xbd973e);
        uint n = _0x5eb69a.length;
        if(n + _0x22284e > _0xbd973e){
            _0x5eb69a.length = _0xbd973e;
        }
        else{
            _0x5eb69a.length += _0x22284e;
        }
        for(;n<_0x5eb69a.length;n++){ // make sure to burn gas
            _0x5eb69a[n] = 1;
        }
        if(_0x5eb69a.length>=_0xbd973e) { // assume block.number > 10
            _0x31065c = block.number - ( block.number % 10);
            _0xb190da = _0x31065c;
        }
        return(_0x5eb69a.length);
    }

    function _0xd34a12() external returns (uint) {
        return(_0x0f11fa(128));
    }

    function _0x32d14e(uint32 _0xf5e413, uint32 _0x21c865) constant private returns (uint) {
        return( ( uint(block.blockhash(_0xf5e413  )) & 0xFFFFFF )
            | ( ( uint(block.blockhash(_0xf5e413+1)) & 0xFFFFFF ) << 24 )
            | ( ( uint(block.blockhash(_0xf5e413+2)) & 0xFFFFFF ) << 48 )
            | ( ( uint(block.blockhash(_0xf5e413+3)) & 0xFFFFFF ) << 72 )
            | ( ( uint(block.blockhash(_0xf5e413+4)) & 0xFFFFFF ) << 96 )
            | ( ( uint(block.blockhash(_0xf5e413+5)) & 0xFFFFFF ) << 120 )
            | ( ( uint(block.blockhash(_0xf5e413+6)) & 0xFFFFFF ) << 144 )
            | ( ( uint(block.blockhash(_0xf5e413+7)) & 0xFFFFFF ) << 168 )
            | ( ( uint(block.blockhash(_0xf5e413+8)) & 0xFFFFFF ) << 192 )
            | ( ( uint(block.blockhash(_0xf5e413+9)) & 0xFFFFFF ) << 216 )
            | ( ( uint(_0x21c865) / _0xbd973e) << 240));
    }

    function _0x0c0455(uint _0xe7025c) constant private returns (uint32) {
        uint _0x50e328 = (_0xe7025c - _0x31065c) / 10;
        uint _0x7ed265 = _0x5eb69a[_0x50e328 % _0xbd973e];
        if(_0x50e328 / _0xbd973e != _0x7ed265 >> 240) {
            return(0x1000000); // load failed, incorrect data in hashes
        }
        uint _0x8f38fb = (_0xe7025c - _0x31065c) % 10;
        return(uint32((_0x7ed265 >> (24 * _0x8f38fb)) & 0xFFFFFF));
    }

    function _0x4cd01c() public returns (bool) {
        uint _0x1a7dc4 = _0xb190da;
        if(_0x1a7dc4 == 0 || block.number <= _0x1a7dc4 + 10) {
            return(false);
        }
        uint _0x224578;
        if(block.number<256) { // useless test for testnet :-(
            if (true) { _0x224578 = 0; }
        }
        else{
            _0x224578 = block.number - 256;
        }
        if(_0x1a7dc4 < _0x224578) {
            uint _0x249652 = _0x224578;
            _0x249652 += _0x249652 % 10;
            _0x1a7dc4 = _0x249652;
        }
        uint _0x50e328 = (_0x1a7dc4 - _0x31065c) / 10;
        _0x5eb69a[_0x50e328 % _0xbd973e] = _0x32d14e(uint32(_0x1a7dc4),uint32(_0x50e328));
        _0xb190da = _0x1a7dc4 + 10;
        return(true);
    }

    function _0x2e122e(uint _0x2da9af) external {
        uint n=0;
        for(;n<_0x2da9af;n++){
            if(!_0x4cd01c()){
                return;
            }
        }
    }

}