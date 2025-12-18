pragma solidity ^0.4.11;
interface _0x67917b { function _0x8c637d(address _0xd5478b, uint256 _0x6eb94b, address _0x875e57, bytes _0xa56714) public; }


contract MigrationAgent {
    function _0x7d5b84(address _0xd5478b, uint256 _0x6eb94b);
}

contract ERC20 {
  uint public _0x5377ae;
  function _0x5cd55a(address _0xb15432) constant returns (uint);
  function _0x997be2(address _0x86cea3, address _0x8d84b9) constant returns (uint);

  function transfer(address _0x242693, uint value) returns (bool _0x465002);
  function _0x508f02(address from, address _0x242693, uint value) returns (bool _0x465002);
  function _0x480702(address _0x8d84b9, uint value) returns (bool _0x465002);
  event Transfer(address indexed from, address indexed _0x242693, uint value);
  event Approval(address indexed _0x86cea3, address indexed _0x8d84b9, uint value);
}

contract SafeMath {
  function _0xc515e1(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function _0xda1c37(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function _0x76f49f(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function _0x8fdcac(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function _0x986989(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function _0x8ed9aa(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function _0x88c75c(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function _0x3d874f(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool _0xad8df8) internal {
    if (!_0xad8df8) {
      throw;
    }
  }
}

contract StandardToken is ERC20, SafeMath {


  event Minted(address _0x9412e9, uint _0x9b7fc5);


  mapping(address => uint) _0xb2b00c;

  mapping(address => uint) _0x98a855;

  mapping (address => mapping (address => uint)) _0x20ae63;


  function _0xeb10d6() public constant returns (bool _0xdcb297) {
    return true;
  }

  function transfer(address _0x816862, uint _0x6eb94b) returns (bool _0xa78c70) {
    _0xb2b00c[msg.sender] = _0x76f49f(_0xb2b00c[msg.sender], _0x6eb94b);
    _0xb2b00c[_0x816862] = _0x8fdcac(_0xb2b00c[_0x816862], _0x6eb94b);
    Transfer(msg.sender, _0x816862, _0x6eb94b);
    return true;
  }

  function _0x508f02(address _0xd5478b, address _0x816862, uint _0x6eb94b) returns (bool _0xa78c70) {
    uint _0x9b5ad9 = _0x20ae63[_0xd5478b][msg.sender];

    _0xb2b00c[_0x816862] = _0x8fdcac(_0xb2b00c[_0x816862], _0x6eb94b);
    _0xb2b00c[_0xd5478b] = _0x76f49f(_0xb2b00c[_0xd5478b], _0x6eb94b);
    _0x20ae63[_0xd5478b][msg.sender] = _0x76f49f(_0x9b5ad9, _0x6eb94b);
    Transfer(_0xd5478b, _0x816862, _0x6eb94b);
    return true;
  }

  function _0x5cd55a(address _0x46e93d) constant returns (uint balance) {
    return _0xb2b00c[_0x46e93d];
  }

  function _0x480702(address _0xc810d1, uint _0x6eb94b) returns (bool _0xa78c70) {


    if ((_0x6eb94b != 0) && (_0x20ae63[msg.sender][_0xc810d1] != 0)) throw;

    _0x20ae63[msg.sender][_0xc810d1] = _0x6eb94b;
    Approval(msg.sender, _0xc810d1, _0x6eb94b);
    return true;
  }

  function _0x997be2(address _0x46e93d, address _0xc810d1) constant returns (uint _0x6c733e) {
    return _0x20ae63[_0x46e93d][_0xc810d1];
  }

}


contract _0xc3b408{

    string public _0x965e06 = "DAO POLSKA TOKEN version 1";
    string public _0xc8e010 = "DPL";
    uint8 public constant _0xf1991c = 18;


    address public _0x86cea3;
    address public _0x2457b3;


    uint256 public _0x15b1df =1.0 ether;
    uint256 public _0x5597ba      = 10000.0 ether;

   uint256 public  _0x5377ae      = 0.0 ether;

	address public Chain1 = 0x0;
	address public Chain2 = 0x0;
	address public Chain3 = 0x0;
	address public Chain4 = 0x0;

	address public _0x3d8361=0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2;
    uint256 public _0x36299b;

    event Migrate(address indexed _0xd5478b, address indexed _0x816862, uint256 _0x6eb94b);
    event Refund(address indexed _0xd5478b, uint256 _0x6eb94b);

	struct _0x8343e7{
		StandardToken _0x085b51;
		uint _0x9b7fc5;
		address _0xe8440f;
	}
	mapping(uint => _0x8343e7) _0xeaac40;
	uint _0x8d6efc=0;

  mapping (address => uint256) _0xb2b00c;
mapping (address => uint256) _0x98a855;
  mapping (address => mapping (address => uint256)) _0x20ae63;

	event UpdatedTokenInformation(string _0xc3051a, string _0xbe1a8b);

    event Transfer(address indexed _0xd5478b, address indexed _0x816862, uint256 _0x6eb94b);
	event _0x4845db(address indexed _0xd5478b,uint256 _0x6eb94b);
  event Approval(address indexed _0x46e93d, address indexed _0xc810d1, uint256 _0x6eb94b);


    event Burn(address indexed from, uint256 value);

  bool public _0x48bdb6 = false;
  bool public _0x707874 = false;

  function _0xc3b408() {
_0x86cea3=msg.sender;
_0x2457b3=msg.sender;
}

function  _0x6ff5bf(uint256 _0x16cc4b) public {
    	   if (msg.sender != _0x86cea3) {
      throw;
    }
		    	   if (_0x48bdb6 != false) {
      throw;
    }
 if (1 == 1) { _0x48bdb6 = true; }

	_0x5597ba = _0x16cc4b ** uint256(_0xf1991c);

  }
function _0xf24620(uint256 _0x16cc4b) public {
    	   if (msg.sender != _0x86cea3) {
      throw;
    }
	    	   if (_0x48bdb6 != false) {
      throw;
    }

	_0x707874 = true;
 if (true) { _0x15b1df = _0x16cc4b ** uint256(_0xf1991c); }

  }
    function _0x8851f8(address _0xc810d1, uint256 _0x6eb94b, bytes _0xa56714)
        public
        returns (bool _0xa78c70) {
        _0x67917b _0x8d84b9 = _0x67917b(_0xc810d1);
        if (_0x480702(_0xc810d1, _0x6eb94b)) {
            _0x8d84b9._0x8c637d(msg.sender, _0x6eb94b, this, _0xa56714);
            return true;
        }
    }

    function _0x35b6c2(uint256 _0x6eb94b) public returns (bool _0xa78c70) {
        require(_0xb2b00c[msg.sender] >= _0x6eb94b);
        _0xb2b00c[msg.sender] -= _0x6eb94b;
        _0x5377ae -= _0x6eb94b;
        Burn(msg.sender, _0x6eb94b);
        return true;
    }

    function _0xd237e5(address _0xd5478b, uint256 _0x6eb94b) public returns (bool _0xa78c70) {
        require(_0xb2b00c[_0xd5478b] >= _0x6eb94b);
        require(_0x6eb94b <= _0x20ae63[_0xd5478b][msg.sender]);
        _0xb2b00c[_0xd5478b] -= _0x6eb94b;
        _0x20ae63[_0xd5478b][msg.sender] -= _0x6eb94b;
        _0x5377ae -= _0x6eb94b;
        Burn(_0xd5478b, _0x6eb94b);
        return true;
    }

  function transfer(address _0x816862, uint256 _0x6eb94b) returns (bool _0xa78c70) {


    if (_0xb2b00c[msg.sender] >= _0x6eb94b && _0xb2b00c[_0x816862] + _0x6eb94b > _0xb2b00c[_0x816862]) {

      _0xb2b00c[msg.sender] -= _0x6eb94b;
      _0xb2b00c[_0x816862] += _0x6eb94b;
      Transfer(msg.sender, _0x816862, _0x6eb94b);
      return true;
    } else { return false; }
  }

  function _0x508f02(address _0xd5478b, address _0x816862, uint256 _0x6eb94b) returns (bool _0xa78c70) {

    if (_0xb2b00c[_0xd5478b] >= _0x6eb94b && _0x20ae63[_0xd5478b][msg.sender] >= _0x6eb94b && _0xb2b00c[_0x816862] + _0x6eb94b > _0xb2b00c[_0x816862]) {

      _0xb2b00c[_0x816862] += _0x6eb94b;
      _0xb2b00c[_0xd5478b] -= _0x6eb94b;
      _0x20ae63[_0xd5478b][msg.sender] -= _0x6eb94b;
      Transfer(_0xd5478b, _0x816862, _0x6eb94b);
      return true;
    } else { return false; }
  }

  function _0x5cd55a(address _0x46e93d) constant returns (uint256 balance) {
    return _0xb2b00c[_0x46e93d];
  }

  function _0x480702(address _0xc810d1, uint256 _0x6eb94b) returns (bool _0xa78c70) {
    _0x20ae63[msg.sender][_0xc810d1] = _0x6eb94b;
    Approval(msg.sender, _0xc810d1, _0x6eb94b);
    return true;
  }

  function _0x997be2(address _0x46e93d, address _0xc810d1) constant returns (uint256 _0x6c733e) {
    return _0x20ae63[_0x46e93d][_0xc810d1];
  }

	    function () payable  public {
		 if(_0x1195b7){
        _0x4845db(msg.sender, msg.value);
		_0xb2b00c[msg.sender]=_0xb2b00c[msg.sender]+msg.value;
		} else throw;

    }

  function _0xa94539(string _0xd2893e, string _0xacdba5) {

	   if (msg.sender != _0x86cea3) {
      throw;
    }
	_0x965e06 = _0xd2893e;
    if (1 == 1) { _0xc8e010 = _0xacdba5; }

    UpdatedTokenInformation(_0x965e06, _0xc8e010);
  }

function _0x366a70(address _0x148e1a, int _0xa506f1) {

	   if (msg.sender != _0x86cea3) {
      throw;
    }
	if(_0xa506f1==1){Chain1=_0x148e1a;}
	if(_0xa506f1==2){Chain2=_0x148e1a;}
	if(_0xa506f1==3){Chain3=_0x148e1a;}
	if(_0xa506f1==4){Chain4=_0x148e1a;}
  }

  function DAOPolskaTokenICOregulations() external returns(string _0x1e32d5) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}


	function _0x11c431(address StandardTokenAddress, address _0x9412e9, uint _0x9b7fc5){
		if (msg.sender != _0x86cea3) {
		throw;
		}
		_0x8343e7 t = _0xeaac40[_0x8d6efc];
		t._0x085b51 = StandardToken(StandardTokenAddress);
		t._0x9b7fc5 = _0x9b7fc5;
		t._0xe8440f = _0x9412e9;
		t._0x085b51.transfer(_0x9412e9, _0x9b7fc5);
		_0x8d6efc++;
	}


uint public _0x65f257=1000;
uint public _0xd1f615=1000;
uint public CreationRate=1761;
   uint256 public constant _0xd4c37f = 36000;
uint256 public _0x5b631b = 5433616;
bool public _0x1195b7 = true;
bool public _0x40209d = false;
bool public _0xa31716= false;
        function _0x2f269b(address _0x67fd2a) payable {

        if (!_0x1195b7) throw;


        if (msg.value == 0) throw;

        if (msg.value > (_0x5597ba - _0x5377ae) / CreationRate)
          throw;


	 var _0x2f7300 = msg.value;

        var _0xdde9d2 = msg.value * CreationRate;
        _0x5377ae += _0xdde9d2;


        _0xb2b00c[_0x67fd2a] += _0xdde9d2;
        _0x98a855[_0x67fd2a] += _0x2f7300;

        Transfer(0, _0x67fd2a, _0xdde9d2);


        uint256 _0xb2ddd5 = 12;
        uint256 _0x6d384d = 	_0xdde9d2 * _0xb2ddd5 / (100);

        _0x5377ae += _0x6d384d;

        _0xb2b00c[_0x2457b3] += _0x6d384d;
        Transfer(0, _0x2457b3, _0x6d384d);

	}
	function _0x329b4d(uint _0xa0f9e7){
	if(msg.sender == _0x86cea3) {
	_0xd1f615=_0xa0f9e7;
	CreationRate=_0x65f257+_0xd1f615;
	}
	}

    function FundsTransfer() external {
	if(_0x1195b7==true) throw;
		 	if (!_0x86cea3.send(this.balance)) throw;
    }

    function PartialFundsTransfer(uint SubX) external {
	      if (msg.sender != _0x86cea3) throw;
        _0x86cea3.send(this.balance - SubX);
	}
	function _0xa53ce8() external {
	      if (msg.sender != _0x86cea3) throw;
	_0x40209d=!_0x40209d;
        }

			function _0x3a23dd() external {
	      if (msg.sender != _0x86cea3) throw;
	_0x1195b7=!_0x1195b7;
        }
    function _0xe91295() external {
	      if (msg.sender != _0x2457b3) throw;
	_0xa31716=!_0xa31716;
}


function _0xa16087() external {
        if (block.number <= _0x5b631b+8*_0xd4c37f) throw;

        _0x1195b7 = false;
		_0x40209d=!_0x40209d;

        if (msg.sender==_0x86cea3)
		_0x86cea3.send(this.balance);
    }
    function _0x47851b(uint256 _0x6eb94b) external {

        if (_0xa31716) throw;


        if (_0x6eb94b == 0) throw;
        if (_0x6eb94b > _0xb2b00c[msg.sender]) throw;

        _0xb2b00c[msg.sender] -= _0x6eb94b;
        _0x5377ae -= _0x6eb94b;
        _0x36299b += _0x6eb94b;
        MigrationAgent(_0x3d8361)._0x7d5b84(msg.sender, _0x6eb94b);
        Migrate(msg.sender, _0x3d8361, _0x6eb94b);
    }

function _0x1bcb26() external {

        if (_0x1195b7) throw;
        if (!_0x40209d) throw;

        var DAOPLTokenValue = _0xb2b00c[msg.sender];
        var ETHValue = _0x98a855[msg.sender];
        if (ETHValue == 0) throw;
        _0x98a855[msg.sender] = 0;
        _0x5377ae -= DAOPLTokenValue;

        Refund(msg.sender, ETHValue);
        msg.sender.transfer(ETHValue);
}

function _0x99b6ee() external returns(string _0x1e32d5) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}