pragma solidity ^0.4.13;

library SafeMath {
  function _0xa8e2ae(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }
  function _0xd9a39c(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint public _0xb23de6;
  address public _0xe766e9;
  address public _0x9a9a06;
  function _0x4e12bf(address _0xb37f55) constant returns (uint);
  function transfer(address _0x59ad59, uint value);
  event Transfer(address indexed from, address indexed _0x59ad59, uint value);
  function _0x315968(address _0xb37f55) internal;
}

contract ERC20 is ERC20Basic {
  function _0x0e9bec(address _0xe766e9, address _0x4073d5) constant returns (uint);
  function _0x80884e(address from, address _0x59ad59, uint value);
  function _0x2759f1(address _0x4073d5, uint value);
  event Approval(address indexed _0xe766e9, address indexed _0x4073d5, uint value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint;
  mapping(address => uint) _0x4c51c2;

  modifier _0x6f7ad6(uint _0xc474e7) {
     assert(msg.data.length >= _0xc474e7 + 4);
     _;
  }

  function transfer(address _0xde60b1, uint _0xe5a84f) _0x6f7ad6(2 * 32) {
    _0x315968(msg.sender);
    _0x4c51c2[msg.sender] = _0x4c51c2[msg.sender]._0xa8e2ae(_0xe5a84f);
    if(_0xde60b1 == address(this)) {
        _0x315968(_0xe766e9);
        _0x4c51c2[_0xe766e9] = _0x4c51c2[_0xe766e9]._0xd9a39c(_0xe5a84f);
        Transfer(msg.sender, _0xe766e9, _0xe5a84f);
    }
    else {
        _0x315968(_0xde60b1);
        _0x4c51c2[_0xde60b1] = _0x4c51c2[_0xde60b1]._0xd9a39c(_0xe5a84f);
        Transfer(msg.sender, _0xde60b1, _0xe5a84f);
    }
  }

  function _0x4e12bf(address _0x69abd4) constant returns (uint balance) {
    return _0x4c51c2[_0x69abd4];
  }
}

contract StandardToken is BasicToken, ERC20 {
  mapping (address => mapping (address => uint)) _0x1224c2;

  function _0x80884e(address _0x139149, address _0xde60b1, uint _0xe5a84f) _0x6f7ad6(3 * 32) {
    var _0xfff735 = _0x1224c2[_0x139149][msg.sender];
    _0x315968(_0x139149);
    _0x315968(_0xde60b1);
    _0x4c51c2[_0xde60b1] = _0x4c51c2[_0xde60b1]._0xd9a39c(_0xe5a84f);
    _0x4c51c2[_0x139149] = _0x4c51c2[_0x139149]._0xa8e2ae(_0xe5a84f);
    _0x1224c2[_0x139149][msg.sender] = _0xfff735._0xa8e2ae(_0xe5a84f);
    Transfer(_0x139149, _0xde60b1, _0xe5a84f);
  }

  function _0x2759f1(address _0x8d605e, uint _0xe5a84f) {

    assert(!((_0xe5a84f != 0) && (_0x1224c2[msg.sender][_0x8d605e] != 0)));
    _0x1224c2[msg.sender][_0x8d605e] = _0xe5a84f;
    Approval(msg.sender, _0x8d605e, _0xe5a84f);
  }

  function _0x0e9bec(address _0x69abd4, address _0x8d605e) constant returns (uint _0x742e25) {
    return _0x1224c2[_0x69abd4][_0x8d605e];
  }
}

contract SmartBillions is StandardToken {


    string public constant _0x95b3d4 = "SmartBillions Token";
    string public constant _0x1f5162 = "PLAY";
    uint public constant _0xa5f9c5 = 0;


    struct Wallet {
        uint208 balance;
    	uint16 _0x7bf47f;
    	uint32 _0x56fe52;
    }
    mapping (address => Wallet) _0xcbb298;
    struct Bet {
        uint192 value;
        uint32 _0xd36237;
        uint32 _0xb7ff10;
    }
    mapping (address => Bet) _0xc686b1;

    uint public _0xf8647c = 0;


    uint public _0x702a5f = 1;
    uint public _0x4bda77 = 0;
    uint public _0xfde7ec = 200000 ether;
    uint public _0xae49e3 = 1;
    uint[] public _0x5bfbfd;


    uint public _0xd28e75 = 0;
    uint public _0x56b4b8 = 0;
    uint public _0xc35295 = 0;
    uint public _0xb3c281 = 0;
    uint public _0x93bcea = 0;
    uint public _0xf0c2b3 = 5 ether;
    uint[] public _0xd094f5;


    uint public constant _0xa2ae51 = 16384 ;
    uint public _0x361ee6 = 0 ;


    event LogBet(address indexed _0x19476c, uint _0x162506, uint _0xdb2ea9, uint _0x4a0418);
    event LogLoss(address indexed _0x19476c, uint _0x162506, uint _0xe39b0b);
    event LogWin(address indexed _0x19476c, uint _0x162506, uint _0xe39b0b, uint _0xa5a52a);
    event LogInvestment(address indexed _0xe8c49e, address indexed _0x67d48d, uint _0x7362dd);
    event LogRecordWin(address indexed _0x19476c, uint _0x7362dd);
    event LogLate(address indexed _0x19476c,uint _0xe134a1,uint _0x3159b7);
    event LogDividend(address indexed _0xe8c49e, uint _0x7362dd, uint _0xf018ac);

    modifier _0x957379() {
        assert(msg.sender == _0xe766e9);
        _;
    }

    modifier _0x58c8dd() {
        assert(msg.sender == _0x9a9a06);
        _;
    }


    function SmartBillions() {
        _0xe766e9 = msg.sender;
        _0x9a9a06 = msg.sender;
        _0xcbb298[_0xe766e9]._0x7bf47f = uint16(_0xae49e3);
        _0x5bfbfd.push(0);
        _0x5bfbfd.push(0);
    }


    function _0x15f884() constant external returns (uint) {
        return uint(_0xd094f5.length);
    }

    function _0x4e1646(address _0x69abd4) constant external returns (uint) {
        return uint(_0xcbb298[_0x69abd4].balance);
    }

    function _0x3275f9(address _0x69abd4) constant external returns (uint) {
        return uint(_0xcbb298[_0x69abd4]._0x7bf47f);
    }

    function _0x7d57ea(address _0x69abd4) constant external returns (uint) {
        return uint(_0xcbb298[_0x69abd4]._0x56fe52);
    }

    function _0x09579f(address _0x69abd4) constant external returns (uint) {
        return uint(_0xc686b1[_0x69abd4].value);
    }

    function _0x8aeab3(address _0x69abd4) constant external returns (uint) {
        return uint(_0xc686b1[_0x69abd4]._0xd36237);
    }

    function _0x6cd60d(address _0x69abd4) constant external returns (uint) {
        return uint(_0xc686b1[_0x69abd4]._0xb7ff10);
    }

    function _0x26e94f() constant external returns (uint) {
        if(_0x702a5f > 0) {
            return(0);
        }
        uint _0xf018ac = (block.number - _0x56b4b8) / (10 * _0xa2ae51);
        if(_0xf018ac > _0xae49e3) {
            return(0);
        }
        return((10 * _0xa2ae51) - ((block.number - _0x56b4b8) % (10 * _0xa2ae51)));
    }


    function _0xa93f94(address _0xeddf27) external _0x957379 {
        assert(_0xeddf27 != address(0));
        _0x315968(msg.sender);
        _0x315968(_0xeddf27);
        _0xe766e9 = _0xeddf27;
    }

    function _0x41b36c(address _0xeddf27) external _0x58c8dd {
        assert(_0xeddf27 != address(0));
        _0x315968(msg.sender);
        _0x315968(_0xeddf27);
        if (block.timestamp > 0) { _0x9a9a06 = _0xeddf27; }
    }

    function _0x72663c(uint _0x72b95e) external _0x957379 {
        require(_0x702a5f == 1 && _0x56b4b8 > 0 && block.number < _0x72b95e);
        _0x702a5f = _0x72b95e;
    }

    function _0xf63c9d(uint _0xe2bca5) external _0x957379 {
        _0xf0c2b3 = _0xe2bca5;
    }

    function _0x5c44a5() external _0x957379 {
        _0xb3c281 = block.number + 3;
        _0x93bcea = 0;
    }

    function _0x03af14(uint _0x9b1aee) external _0x957379 {
        _0xf89d12();
        require(_0x9b1aee > 0 && this.balance >= (_0x4bda77 * 9 / 10) + _0xf8647c + _0x9b1aee);
        if(_0x4bda77 >= _0xfde7ec / 2){
            require((_0x9b1aee <= this.balance / 400) && _0x361ee6 + 4 * 60 * 24 * 7 <= block.number);
        }
        msg.sender.transfer(_0x9b1aee);
        _0x361ee6 = block.number;
    }

    function _0xab21a5() payable external {
        _0xf89d12();
    }


    function _0xf89d12() public {
        if(_0x702a5f > 1 && block.number >= _0x702a5f + (_0xa2ae51 * 5)){
            _0x702a5f = 0;
        }
        else {
            if(_0x56b4b8 > 0){
		        uint _0xf018ac = (block.number - _0x56b4b8) / (10 * _0xa2ae51 );
                if(_0xf018ac > _0x5bfbfd.length - 2) {
                    _0x5bfbfd.push(0);
                }
                if(_0xf018ac > _0xae49e3 && _0x702a5f == 0 && _0xae49e3 < _0x5bfbfd.length - 1) {
                    _0xae49e3++;
                }
            }
        }
    }


    function _0x90097f() public {
        if(_0xcbb298[msg.sender].balance > 0 && _0xcbb298[msg.sender]._0x56fe52 <= block.number){
            uint balance = _0xcbb298[msg.sender].balance;
            _0xcbb298[msg.sender].balance = 0;
            _0xf8647c -= balance;
            _0xac9373(balance);
        }
    }

    function _0xac9373(uint _0x9b1aee) private {
        uint _0x330543 = this.balance / 2;
        if(_0x330543 >= _0x9b1aee) {
            msg.sender.transfer(_0x9b1aee);
            if(_0x9b1aee > 1 finney) {
                _0xf89d12();
            }
        }
        else {
            uint _0xae9375 = _0x9b1aee - _0x330543;
            _0xf8647c += _0xae9375;
            _0xcbb298[msg.sender].balance += uint208(_0xae9375);
            _0xcbb298[msg.sender]._0x56fe52 = uint32(block.number + 4 * 60 * 24 * 30);
            msg.sender.transfer(_0x330543);
        }
    }


    function _0x4954b5() payable external {
        _0x0e8e40(_0xe766e9);
    }

    function _0x0e8e40(address _0x99bac1) payable public {

        require(_0x702a5f > 1 && block.number < _0x702a5f + (_0xa2ae51 * 5) && _0x4bda77 < _0xfde7ec);
        uint _0x053b6e = msg.value;
        if(_0x053b6e > _0xfde7ec - _0x4bda77) {
            if (msg.sender != address(0) || msg.sender == address(0)) { _0x053b6e = _0xfde7ec - _0x4bda77; }
            _0x4bda77 = _0xfde7ec;
            if (block.timestamp > 0) { _0x702a5f = 0; }
            msg.sender.transfer(msg.value._0xa8e2ae(_0x053b6e));
        }
        else{
            _0x4bda77 += _0x053b6e;
        }
        if(_0x99bac1 == address(0) || _0x99bac1 == _0xe766e9){
            _0xf8647c += _0x053b6e / 10;
            _0xcbb298[_0xe766e9].balance += uint208(_0x053b6e / 10);}
        else{
            _0xf8647c += (_0x053b6e * 5 / 100) * 2;
            _0xcbb298[_0xe766e9].balance += uint208(_0x053b6e * 5 / 100);
            _0xcbb298[_0x99bac1].balance += uint208(_0x053b6e * 5 / 100);}
        _0xcbb298[msg.sender]._0x7bf47f = uint16(_0xae49e3);
        uint _0xc39abb = _0x053b6e / 10**15;
        uint _0x527a6e = _0x053b6e * 16 / 10**17  ;
        uint _0x47505f = _0x053b6e * 10 / 10**17  ;
        _0x4c51c2[msg.sender] += _0xc39abb;
        _0x4c51c2[_0xe766e9] += _0x527a6e ;
        _0x4c51c2[_0x9a9a06] += _0x47505f ;
        _0xb23de6 += _0xc39abb + _0x527a6e + _0x47505f;
        Transfer(address(0),msg.sender,_0xc39abb);
        Transfer(address(0),_0xe766e9,_0x527a6e);
        Transfer(address(0),_0x9a9a06,_0x47505f);
        LogInvestment(msg.sender,_0x99bac1,_0x053b6e);
    }

    function _0x07b10f() external {
        require(_0x702a5f == 0);
        _0x315968(msg.sender);
        uint _0xa7b722 = _0x4c51c2[msg.sender] * 10**15;
        Transfer(msg.sender,address(0),_0x4c51c2[msg.sender]);
        delete _0x4c51c2[msg.sender];
        _0x4bda77 -= _0xa7b722;
        _0xcbb298[msg.sender].balance += uint208(_0xa7b722 * 9 / 10);
        _0x90097f();
    }

    function _0x02e4c6() external {
        require(_0x702a5f == 0);
        _0x315968(msg.sender);
        _0x90097f();
    }

    function _0x315968(address _0xeddf27) internal {
        uint _0x010bbb = _0xcbb298[_0xeddf27]._0x7bf47f;
        if((_0x4c51c2[_0xeddf27]==0) || (_0x010bbb==0)){
            _0xcbb298[_0xeddf27]._0x7bf47f=uint16(_0xae49e3);
            return;
        }
        if(_0x010bbb==_0xae49e3) {
            return;
        }
        uint _0xc1e3a9 = _0x4c51c2[_0xeddf27] * 0xffffffff / _0xb23de6;
        uint balance = 0;
        for(;_0x010bbb<_0xae49e3;_0x010bbb++) {
            balance += _0xc1e3a9 * _0x5bfbfd[_0x010bbb];
        }
        balance = (balance / 0xffffffff);
        _0xf8647c += balance;
        _0xcbb298[_0xeddf27].balance += uint208(balance);
        _0xcbb298[_0xeddf27]._0x7bf47f = uint16(_0x010bbb);
        LogDividend(_0xeddf27,balance,_0x010bbb);
    }


    function _0xb93863(Bet _0xa13c77, uint24 _0x3a2d4c) constant private returns (uint) {
        uint24 _0x162506 = uint24(_0xa13c77._0xd36237);
        uint24 _0xa6facc = _0x162506 ^ _0x3a2d4c;
        uint24 _0xa09ed4 =
            ((_0xa6facc & 0xF) == 0 ? 1 : 0 ) +
            ((_0xa6facc & 0xF0) == 0 ? 1 : 0 ) +
            ((_0xa6facc & 0xF00) == 0 ? 1 : 0 ) +
            ((_0xa6facc & 0xF000) == 0 ? 1 : 0 ) +
            ((_0xa6facc & 0xF0000) == 0 ? 1 : 0 ) +
            ((_0xa6facc & 0xF00000) == 0 ? 1 : 0 );
        if(_0xa09ed4 == 6){
            return(uint(_0xa13c77.value) * 7000000);
        }
        if(_0xa09ed4 == 5){
            return(uint(_0xa13c77.value) * 20000);
        }
        if(_0xa09ed4 == 4){
            return(uint(_0xa13c77.value) * 500);
        }
        if(_0xa09ed4 == 3){
            return(uint(_0xa13c77.value) * 25);
        }
        if(_0xa09ed4 == 2){
            return(uint(_0xa13c77.value) * 3);
        }
        return(0);
    }

    function _0x592759(address _0xeddf27) constant external returns (uint)  {
        Bet memory _0x19476c = _0xc686b1[_0xeddf27];
        if( (_0x19476c.value==0) ||
            (_0x19476c._0xb7ff10<=1) ||
            (block.number<_0x19476c._0xb7ff10) ||
            (block.number>=_0x19476c._0xb7ff10 + (10 * _0xa2ae51))){
            return(0);
        }
        if(block.number<_0x19476c._0xb7ff10+256){
            return(_0xb93863(_0x19476c,uint24(block.blockhash(_0x19476c._0xb7ff10))));
        }
        if(_0x56b4b8>0){
            uint32 _0xe39b0b = _0xa8bc67(_0x19476c._0xb7ff10);
            if(_0xe39b0b == 0x1000000) {
                return(uint(_0x19476c.value));
            }
            else{
                return(_0xb93863(_0x19476c,uint24(_0xe39b0b)));
            }
	}
        return(0);
    }

    function _0x8914e4() public {
        Bet memory _0x19476c = _0xc686b1[msg.sender];
        if(_0x19476c._0xb7ff10==0){
            _0xc686b1[msg.sender] = Bet({value: 0, _0xd36237: 0, _0xb7ff10: 1});
            return;
        }
        if((_0x19476c.value==0) || (_0x19476c._0xb7ff10==1)){
            _0x90097f();
            return;
        }
        require(block.number>_0x19476c._0xb7ff10);
        if(_0x19476c._0xb7ff10 + (10 * _0xa2ae51) <= block.number){
            LogLate(msg.sender,_0x19476c._0xb7ff10,block.number);
            _0xc686b1[msg.sender] = Bet({value: 0, _0xd36237: 0, _0xb7ff10: 1});
            return;
        }
        uint _0xa5a52a = 0;
        uint32 _0xe39b0b = 0;
        if(block.number<_0x19476c._0xb7ff10+256){
            _0xe39b0b = uint24(block.blockhash(_0x19476c._0xb7ff10));
            _0xa5a52a = _0xb93863(_0x19476c,uint24(_0xe39b0b));
        }
        else {
            if(_0x56b4b8>0){
                _0xe39b0b = _0xa8bc67(_0x19476c._0xb7ff10);
                if(_0xe39b0b == 0x1000000) {
                    _0xa5a52a = uint(_0x19476c.value);
                }
                else{
                    _0xa5a52a = _0xb93863(_0x19476c,uint24(_0xe39b0b));
                }
	    }
            else{
                LogLate(msg.sender,_0x19476c._0xb7ff10,block.number);
                _0xc686b1[msg.sender] = Bet({value: 0, _0xd36237: 0, _0xb7ff10: 1});
                return();
            }
        }
        _0xc686b1[msg.sender] = Bet({value: 0, _0xd36237: 0, _0xb7ff10: 1});
        if(_0xa5a52a>0) {
            LogWin(msg.sender,uint(_0x19476c._0xd36237),uint(_0xe39b0b),_0xa5a52a);
            if(_0xa5a52a > _0xd28e75){
                _0xd28e75 = _0xa5a52a;
                LogRecordWin(msg.sender,_0xa5a52a);
            }
            _0xac9373(_0xa5a52a);
        }
        else{
            LogLoss(msg.sender,uint(_0x19476c._0xd36237),uint(_0xe39b0b));
        }
    }

    function () payable external {
        if(msg.value > 0){
            if(_0x702a5f>1){
                _0x0e8e40(_0xe766e9);
            }
            else{
                _0xc3baf0();
            }
            return;
        }

        if(_0x702a5f == 0 && _0x4c51c2[msg.sender]>0){
            _0x315968(msg.sender);}
        _0x8914e4();
    }

    function _0xc3baf0() payable public returns (uint) {
        return _0xed6bc3(uint(_0x9d9568(msg.sender,block.number)), address(0));
    }

    function _0xbaa394(address _0x99bac1) payable public returns (uint) {
        return _0xed6bc3(uint(_0x9d9568(msg.sender,block.number)), _0x99bac1);
    }

    function _0xed6bc3(uint _0x3a2d4c, address _0x99bac1) payable public returns (uint) {
        _0x8914e4();
        uint24 _0x162506 = uint24(_0x3a2d4c);
        require(msg.value <= 1 ether && msg.value < _0xf0c2b3);
        if(msg.value > 0){
            if(_0x702a5f==0) {
                _0x5bfbfd[_0xae49e3] += msg.value / 20;
            }
            if(_0x99bac1 != address(0)) {
                uint _0x3179fa = msg.value / 100;
                _0xf8647c += _0x3179fa;
                _0xcbb298[_0x99bac1].balance += uint208(_0x3179fa);
            }
            if(_0xb3c281 < block.number + 3) {
                _0xb3c281 = block.number + 3;
                _0x93bcea = msg.value;
            }
            else{
                if(_0x93bcea > _0xf0c2b3) {
                    _0xb3c281++;
                    _0x93bcea = msg.value;
                }
                else{
                    _0x93bcea += msg.value;
                }
            }
            _0xc686b1[msg.sender] = Bet({value: uint192(msg.value), _0xd36237: uint32(_0x162506), _0xb7ff10: uint32(_0xb3c281)});
            LogBet(msg.sender,uint(_0x162506),_0xb3c281,msg.value);
        }
        _0xf5d705();
        return(_0xb3c281);
    }


    function _0x3fffc8(uint _0x1f15e2) public returns (uint) {
        require(_0x56b4b8 == 0 && _0x1f15e2 > 0 && _0x1f15e2 <= _0xa2ae51);
        uint n = _0xd094f5.length;
        if(n + _0x1f15e2 > _0xa2ae51){
            _0xd094f5.length = _0xa2ae51;
        }
        else{
            _0xd094f5.length += _0x1f15e2;
        }
        for(;n<_0xd094f5.length;n++){
            _0xd094f5[n] = 1;
        }
        if(_0xd094f5.length>=_0xa2ae51) {
            if (block.timestamp > 0) { _0x56b4b8 = block.number - ( block.number % 10); }
            _0xc35295 = _0x56b4b8;
        }
        return(_0xd094f5.length);
    }

    function _0x873fd3() external returns (uint) {
        return(_0x3fffc8(128));
    }

    function _0x7540f1(uint32 _0xa38f3a, uint32 _0x843062) constant private returns (uint) {
        return( ( uint(block.blockhash(_0xa38f3a  )) & 0xFFFFFF )
            | ( ( uint(block.blockhash(_0xa38f3a+1)) & 0xFFFFFF ) << 24 )
            | ( ( uint(block.blockhash(_0xa38f3a+2)) & 0xFFFFFF ) << 48 )
            | ( ( uint(block.blockhash(_0xa38f3a+3)) & 0xFFFFFF ) << 72 )
            | ( ( uint(block.blockhash(_0xa38f3a+4)) & 0xFFFFFF ) << 96 )
            | ( ( uint(block.blockhash(_0xa38f3a+5)) & 0xFFFFFF ) << 120 )
            | ( ( uint(block.blockhash(_0xa38f3a+6)) & 0xFFFFFF ) << 144 )
            | ( ( uint(block.blockhash(_0xa38f3a+7)) & 0xFFFFFF ) << 168 )
            | ( ( uint(block.blockhash(_0xa38f3a+8)) & 0xFFFFFF ) << 192 )
            | ( ( uint(block.blockhash(_0xa38f3a+9)) & 0xFFFFFF ) << 216 )
            | ( ( uint(_0x843062) / _0xa2ae51) << 240));
    }

    function _0xa8bc67(uint _0x32237a) constant private returns (uint32) {
        uint _0xd4dcff = (_0x32237a - _0x56b4b8) / 10;
        uint _0xe39b0b = _0xd094f5[_0xd4dcff % _0xa2ae51];
        if(_0xd4dcff / _0xa2ae51 != _0xe39b0b >> 240) {
            return(0x1000000);
        }
        uint _0xc7b5d4 = (_0x32237a - _0x56b4b8) % 10;
        return(uint32((_0xe39b0b >> (24 * _0xc7b5d4)) & 0xFFFFFF));
    }

    function _0xf5d705() public returns (bool) {
        uint _0x1ba5d8 = _0xc35295;
        if(_0x1ba5d8 == 0 || block.number <= _0x1ba5d8 + 10) {
            return(false);
        }
        uint _0x9cf3ec;
        if(block.number<256) {
            _0x9cf3ec = 0;
        }
        else{
            if (1 == 1) { _0x9cf3ec = block.number - 256; }
        }
        if(_0x1ba5d8 < _0x9cf3ec) {
            uint _0xb279aa = _0x9cf3ec;
            _0xb279aa += _0xb279aa % 10;
            if (block.timestamp > 0) { _0x1ba5d8 = _0xb279aa; }
        }
        uint _0xd4dcff = (_0x1ba5d8 - _0x56b4b8) / 10;
        _0xd094f5[_0xd4dcff % _0xa2ae51] = _0x7540f1(uint32(_0x1ba5d8),uint32(_0xd4dcff));
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xc35295 = _0x1ba5d8 + 10; }
        return(true);
    }

    function _0xa6bc09(uint _0x66015d) external {
        uint n=0;
        for(;n<_0x66015d;n++){
            if(!_0xf5d705()){
                return;
            }
        }
    }

}