pragma solidity ^0.4.11;
interface _0xb56631 { function _0xb7232f(address _0x662af7, uint256 _0xb5cde1, address _0x117102, bytes _0xc57494) public; }


contract MigrationAgent {
    function _0x96f80f(address _0x662af7, uint256 _0xb5cde1);
}

contract ERC20 {
  uint public _0xa49594;
  function _0xe64295(address _0xc93394) constant returns (uint);
  function _0x63869e(address _0xcecb78, address _0x3d5d07) constant returns (uint);

  function transfer(address _0x4561cc, uint value) returns (bool _0xac5674);
  function _0x11791b(address from, address _0x4561cc, uint value) returns (bool _0xac5674);
  function _0xc091e7(address _0x3d5d07, uint value) returns (bool _0xac5674);
  event Transfer(address indexed from, address indexed _0x4561cc, uint value);
  event Approval(address indexed _0xcecb78, address indexed _0x3d5d07, uint value);
}

contract SafeMath {
  function _0x3b8275(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function _0x0a9ff8(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function _0xf135ae(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function _0x65470b(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function _0x95cd4d(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function _0x912ba4(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function _0xd72478(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function _0x2746f1(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool _0xcb03e2) internal {
    if (!_0xcb03e2) {
      throw;
    }
  }
}

contract StandardToken is ERC20, SafeMath {


  event Minted(address _0x95d0a3, uint _0x8a1e1a);


  mapping(address => uint) _0xe807ae;

  mapping(address => uint) _0xb15aa7;

  mapping (address => mapping (address => uint)) _0x39e417;


  function _0xe51787() public constant returns (bool _0xb25497) {
    return true;
  }

  function transfer(address _0xd6c8ac, uint _0xb5cde1) returns (bool _0x6487dc) {
    _0xe807ae[msg.sender] = _0xf135ae(_0xe807ae[msg.sender], _0xb5cde1);
    _0xe807ae[_0xd6c8ac] = _0x65470b(_0xe807ae[_0xd6c8ac], _0xb5cde1);
    Transfer(msg.sender, _0xd6c8ac, _0xb5cde1);
    return true;
  }

  function _0x11791b(address _0x662af7, address _0xd6c8ac, uint _0xb5cde1) returns (bool _0x6487dc) {
    uint _0xfb039a = _0x39e417[_0x662af7][msg.sender];

    _0xe807ae[_0xd6c8ac] = _0x65470b(_0xe807ae[_0xd6c8ac], _0xb5cde1);
    _0xe807ae[_0x662af7] = _0xf135ae(_0xe807ae[_0x662af7], _0xb5cde1);
    _0x39e417[_0x662af7][msg.sender] = _0xf135ae(_0xfb039a, _0xb5cde1);
    Transfer(_0x662af7, _0xd6c8ac, _0xb5cde1);
    return true;
  }

  function _0xe64295(address _0x68677b) constant returns (uint balance) {
    return _0xe807ae[_0x68677b];
  }

  function _0xc091e7(address _0xe87490, uint _0xb5cde1) returns (bool _0x6487dc) {


    if ((_0xb5cde1 != 0) && (_0x39e417[msg.sender][_0xe87490] != 0)) throw;

    _0x39e417[msg.sender][_0xe87490] = _0xb5cde1;
    Approval(msg.sender, _0xe87490, _0xb5cde1);
    return true;
  }

  function _0x63869e(address _0x68677b, address _0xe87490) constant returns (uint _0xdbdd77) {
    return _0x39e417[_0x68677b][_0xe87490];
  }

}


contract _0x02500e{

    string public _0x625302 = "DAO POLSKA TOKEN version 1";
    string public _0xc5d323 = "DPL";
    uint8 public constant _0xc6cc5e = 18;


    address public _0xcecb78;
    address public _0x940649;


    uint256 public _0x16ea5d =1.0 ether;
    uint256 public _0xd05d18      = 10000.0 ether;

   uint256 public  _0xa49594      = 0.0 ether;

	address public Chain1 = 0x0;
	address public Chain2 = 0x0;
	address public Chain3 = 0x0;
	address public Chain4 = 0x0;

	address public _0x8e8d1e=0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2;
    uint256 public _0x4f7c7a;

    event Migrate(address indexed _0x662af7, address indexed _0xd6c8ac, uint256 _0xb5cde1);
    event Refund(address indexed _0x662af7, uint256 _0xb5cde1);

	struct _0xe83bc6{
		StandardToken _0xbd6f20;
		uint _0x8a1e1a;
		address _0x3c3652;
	}
	mapping(uint => _0xe83bc6) _0x6287eb;
	uint _0x481606=0;

  mapping (address => uint256) _0xe807ae;
mapping (address => uint256) _0xb15aa7;
  mapping (address => mapping (address => uint256)) _0x39e417;

	event UpdatedTokenInformation(string _0x3d8b0a, string _0xfb7abf);

    event Transfer(address indexed _0x662af7, address indexed _0xd6c8ac, uint256 _0xb5cde1);
	event _0x359e42(address indexed _0x662af7,uint256 _0xb5cde1);
  event Approval(address indexed _0x68677b, address indexed _0xe87490, uint256 _0xb5cde1);


    event Burn(address indexed from, uint256 value);

  bool public _0xc1931a = false;
  bool public _0xe83672 = false;

  function _0x02500e() {
_0xcecb78=msg.sender;
_0x940649=msg.sender;
}

function  _0x8b1f59(uint256 _0x105d2e) public {
    	   if (msg.sender != _0xcecb78) {
      throw;
    }
		    	   if (_0xc1931a != false) {
      throw;
    }
 if (gasleft() > 0) { _0xc1931a = true; }

	_0xd05d18 = _0x105d2e ** uint256(_0xc6cc5e);

  }
function _0x8f29a7(uint256 _0x105d2e) public {
    	   if (msg.sender != _0xcecb78) {
      throw;
    }
	    	   if (_0xc1931a != false) {
      throw;
    }

	_0xe83672 = true;
	_0x16ea5d = _0x105d2e ** uint256(_0xc6cc5e);

  }
    function _0xf64e70(address _0xe87490, uint256 _0xb5cde1, bytes _0xc57494)
        public
        returns (bool _0x6487dc) {
        _0xb56631 _0x3d5d07 = _0xb56631(_0xe87490);
        if (_0xc091e7(_0xe87490, _0xb5cde1)) {
            _0x3d5d07._0xb7232f(msg.sender, _0xb5cde1, this, _0xc57494);
            return true;
        }
    }

    function _0x946523(uint256 _0xb5cde1) public returns (bool _0x6487dc) {
        require(_0xe807ae[msg.sender] >= _0xb5cde1);
        _0xe807ae[msg.sender] -= _0xb5cde1;
        _0xa49594 -= _0xb5cde1;
        Burn(msg.sender, _0xb5cde1);
        return true;
    }

    function _0xd36ffc(address _0x662af7, uint256 _0xb5cde1) public returns (bool _0x6487dc) {
        require(_0xe807ae[_0x662af7] >= _0xb5cde1);
        require(_0xb5cde1 <= _0x39e417[_0x662af7][msg.sender]);
        _0xe807ae[_0x662af7] -= _0xb5cde1;
        _0x39e417[_0x662af7][msg.sender] -= _0xb5cde1;
        _0xa49594 -= _0xb5cde1;
        Burn(_0x662af7, _0xb5cde1);
        return true;
    }

  function transfer(address _0xd6c8ac, uint256 _0xb5cde1) returns (bool _0x6487dc) {


    if (_0xe807ae[msg.sender] >= _0xb5cde1 && _0xe807ae[_0xd6c8ac] + _0xb5cde1 > _0xe807ae[_0xd6c8ac]) {

      _0xe807ae[msg.sender] -= _0xb5cde1;
      _0xe807ae[_0xd6c8ac] += _0xb5cde1;
      Transfer(msg.sender, _0xd6c8ac, _0xb5cde1);
      return true;
    } else { return false; }
  }

  function _0x11791b(address _0x662af7, address _0xd6c8ac, uint256 _0xb5cde1) returns (bool _0x6487dc) {

    if (_0xe807ae[_0x662af7] >= _0xb5cde1 && _0x39e417[_0x662af7][msg.sender] >= _0xb5cde1 && _0xe807ae[_0xd6c8ac] + _0xb5cde1 > _0xe807ae[_0xd6c8ac]) {

      _0xe807ae[_0xd6c8ac] += _0xb5cde1;
      _0xe807ae[_0x662af7] -= _0xb5cde1;
      _0x39e417[_0x662af7][msg.sender] -= _0xb5cde1;
      Transfer(_0x662af7, _0xd6c8ac, _0xb5cde1);
      return true;
    } else { return false; }
  }

  function _0xe64295(address _0x68677b) constant returns (uint256 balance) {
    return _0xe807ae[_0x68677b];
  }

  function _0xc091e7(address _0xe87490, uint256 _0xb5cde1) returns (bool _0x6487dc) {
    _0x39e417[msg.sender][_0xe87490] = _0xb5cde1;
    Approval(msg.sender, _0xe87490, _0xb5cde1);
    return true;
  }

  function _0x63869e(address _0x68677b, address _0xe87490) constant returns (uint256 _0xdbdd77) {
    return _0x39e417[_0x68677b][_0xe87490];
  }

	    function () payable  public {
		 if(_0x367041){
        _0x359e42(msg.sender, msg.value);
		_0xe807ae[msg.sender]=_0xe807ae[msg.sender]+msg.value;
		} else throw;

    }

  function _0xca7a9b(string _0x9ddbde, string _0xea7ea3) {

	   if (msg.sender != _0xcecb78) {
      throw;
    }
	_0x625302 = _0x9ddbde;
    _0xc5d323 = _0xea7ea3;

    UpdatedTokenInformation(_0x625302, _0xc5d323);
  }

function _0x1ddf7a(address _0x9cd0d8, int _0xa4a533) {

	   if (msg.sender != _0xcecb78) {
      throw;
    }
	if(_0xa4a533==1){Chain1=_0x9cd0d8;}
	if(_0xa4a533==2){Chain2=_0x9cd0d8;}
	if(_0xa4a533==3){Chain3=_0x9cd0d8;}
	if(_0xa4a533==4){Chain4=_0x9cd0d8;}
  }

  function DAOPolskaTokenICOregulations() external returns(string _0x2897a8) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}


	function _0x861e39(address StandardTokenAddress, address _0x95d0a3, uint _0x8a1e1a){
		if (msg.sender != _0xcecb78) {
		throw;
		}
		_0xe83bc6 t = _0x6287eb[_0x481606];
		t._0xbd6f20 = StandardToken(StandardTokenAddress);
		t._0x8a1e1a = _0x8a1e1a;
		t._0x3c3652 = _0x95d0a3;
		t._0xbd6f20.transfer(_0x95d0a3, _0x8a1e1a);
		_0x481606++;
	}


uint public _0x9e9d9e=1000;
uint public _0x7312ee=1000;
uint public CreationRate=1761;
   uint256 public constant _0x7ef115 = 36000;
uint256 public _0x34b2b5 = 5433616;
bool public _0x367041 = true;
bool public _0x24df68 = false;
bool public _0x40c8ec= false;
        function _0xd0fb45(address _0x742179) payable {

        if (!_0x367041) throw;


        if (msg.value == 0) throw;

        if (msg.value > (_0xd05d18 - _0xa49594) / CreationRate)
          throw;


	 var _0x7a89dc = msg.value;

        var _0xae6a04 = msg.value * CreationRate;
        _0xa49594 += _0xae6a04;


        _0xe807ae[_0x742179] += _0xae6a04;
        _0xb15aa7[_0x742179] += _0x7a89dc;

        Transfer(0, _0x742179, _0xae6a04);


        uint256 _0xd42a5d = 12;
        uint256 _0x02f479 = 	_0xae6a04 * _0xd42a5d / (100);

        _0xa49594 += _0x02f479;

        _0xe807ae[_0x940649] += _0x02f479;
        Transfer(0, _0x940649, _0x02f479);

	}
	function _0xbfbf0d(uint _0x3d196e){
	if(msg.sender == _0xcecb78) {
 if (gasleft() > 0) { _0x7312ee=_0x3d196e; }
	CreationRate=_0x9e9d9e+_0x7312ee;
	}
	}

    function FundsTransfer() external {
	if(_0x367041==true) throw;
		 	if (!_0xcecb78.send(this.balance)) throw;
    }

    function PartialFundsTransfer(uint SubX) external {
	      if (msg.sender != _0xcecb78) throw;
        _0xcecb78.send(this.balance - SubX);
	}
	function _0x5703e3() external {
	      if (msg.sender != _0xcecb78) throw;
 if (gasleft() > 0) { _0x24df68=!_0x24df68; }
        }

			function _0x8c574b() external {
	      if (msg.sender != _0xcecb78) throw;
	_0x367041=!_0x367041;
        }
    function _0x7ea69b() external {
	      if (msg.sender != _0x940649) throw;
 if (1 == 1) { _0x40c8ec=!_0x40c8ec; }
}


function _0x5cb7d3() external {
        if (block.number <= _0x34b2b5+8*_0x7ef115) throw;

        if (1 == 1) { _0x367041 = false; }
  if (msg.sender != address(0) || msg.sender == address(0)) { _0x24df68=!_0x24df68; }

        if (msg.sender==_0xcecb78)
		_0xcecb78.send(this.balance);
    }
    function _0xa40823(uint256 _0xb5cde1) external {

        if (_0x40c8ec) throw;


        if (_0xb5cde1 == 0) throw;
        if (_0xb5cde1 > _0xe807ae[msg.sender]) throw;

        _0xe807ae[msg.sender] -= _0xb5cde1;
        _0xa49594 -= _0xb5cde1;
        _0x4f7c7a += _0xb5cde1;
        MigrationAgent(_0x8e8d1e)._0x96f80f(msg.sender, _0xb5cde1);
        Migrate(msg.sender, _0x8e8d1e, _0xb5cde1);
    }

function _0x37f503() external {

        if (_0x367041) throw;
        if (!_0x24df68) throw;

        var DAOPLTokenValue = _0xe807ae[msg.sender];
        var ETHValue = _0xb15aa7[msg.sender];
        if (ETHValue == 0) throw;
        _0xb15aa7[msg.sender] = 0;
        _0xa49594 -= DAOPLTokenValue;

        Refund(msg.sender, ETHValue);
        msg.sender.transfer(ETHValue);
}

function _0xe2dd04() external returns(string _0x2897a8) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}