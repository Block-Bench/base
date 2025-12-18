pragma solidity ^0.4.11;
interface _0x638cdc { function _0x61313f(address _0x0a07c0, uint256 _0x8b5127, address _0x2b2687, bytes _0x831409) public; }

// title Migration Agent interface
contract MigrationAgent {
    function _0x59f8a3(address _0x0a07c0, uint256 _0x8b5127);
}

contract ERC20 {
  uint public _0x6770d6;
  function _0xed1a74(address _0x84d806) constant returns (uint);
  function _0xd1b087(address _0x50b343, address _0xe8a472) constant returns (uint);

  function transfer(address _0xa150d2, uint value) returns (bool _0xdf22bd);
  function _0x93f1d1(address from, address _0xa150d2, uint value) returns (bool _0xdf22bd);
  function _0x809481(address _0xe8a472, uint value) returns (bool _0xdf22bd);
  event Transfer(address indexed from, address indexed _0xa150d2, uint value);
  event Approval(address indexed _0x50b343, address indexed _0xe8a472, uint value);
}

contract SafeMath {
  function _0xf44e2c(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function _0xe6a717(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function _0x5505dd(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function _0x3f3c39(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function _0x3547e4(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function _0x75c12d(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function _0x570d08(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function _0xb83b46(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool _0x12e92c) internal {
    if (!_0x12e92c) {
      throw;
    }
  }
}

contract StandardToken is ERC20, SafeMath {

  /* Token supply got increased and a new owner received these tokens */
  event Minted(address _0x86872a, uint _0x40ed20);

  /* Actual balances of token holders */
  mapping(address => uint) _0xdc45ac;
  // what exaclt ether was sent
  mapping(address => uint) _0x8183ca;
  /* approve() allowances */
  mapping (address => mapping (address => uint)) _0x43e565;

  /* Interface declaration */
  function _0x4a537f() public constant returns (bool _0x50b2d0) {
    return true;
  }

  function transfer(address _0x9e38dc, uint _0x8b5127) returns (bool _0xf8159e) {
    _0xdc45ac[msg.sender] = _0x5505dd(_0xdc45ac[msg.sender], _0x8b5127);
    _0xdc45ac[_0x9e38dc] = _0x3f3c39(_0xdc45ac[_0x9e38dc], _0x8b5127);
    Transfer(msg.sender, _0x9e38dc, _0x8b5127);
    return true;
  }

  function _0x93f1d1(address _0x0a07c0, address _0x9e38dc, uint _0x8b5127) returns (bool _0xf8159e) {
    uint _0x387fcb = _0x43e565[_0x0a07c0][msg.sender];

    _0xdc45ac[_0x9e38dc] = _0x3f3c39(_0xdc45ac[_0x9e38dc], _0x8b5127);
    _0xdc45ac[_0x0a07c0] = _0x5505dd(_0xdc45ac[_0x0a07c0], _0x8b5127);
    _0x43e565[_0x0a07c0][msg.sender] = _0x5505dd(_0x387fcb, _0x8b5127);
    Transfer(_0x0a07c0, _0x9e38dc, _0x8b5127);
    return true;
  }

  function _0xed1a74(address _0xf74087) constant returns (uint balance) {
    return _0xdc45ac[_0xf74087];
  }

  function _0x809481(address _0xea8b9b, uint _0x8b5127) returns (bool _0xf8159e) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    if ((_0x8b5127 != 0) && (_0x43e565[msg.sender][_0xea8b9b] != 0)) throw;

    _0x43e565[msg.sender][_0xea8b9b] = _0x8b5127;
    Approval(msg.sender, _0xea8b9b, _0x8b5127);
    return true;
  }

  function _0xd1b087(address _0xf74087, address _0xea8b9b) constant returns (uint _0xbcb84f) {
    return _0x43e565[_0xf74087][_0xea8b9b];
  }

}

//  daoPOLSKAtokens
contract _0x68c7d9{

    string public _0x5d068e = "DAO POLSKA TOKEN version 1";
    string public _0x71fff8 = "DPL";
    uint8 public constant _0xd1a7ea = 18;  // 18 decimal places, the same as ETC/ETH/HEE.

    // Receives
    address public _0x50b343;
    address public _0x845707;
    // The current total token supply.

    uint256 public _0xb77863 =1.0 ether;
    uint256 public _0xba1367      = 10000.0 ether;
	//totalSupply
   uint256 public  _0x6770d6      = 0.0 ether;
	//chains:
	address public Chain1 = 0x0;
	address public Chain2 = 0x0;
	address public Chain3 = 0x0;
	address public Chain4 = 0x0;

	address public _0x42fa2a=0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2;
    uint256 public _0x1b5101;

    event Migrate(address indexed _0x0a07c0, address indexed _0x9e38dc, uint256 _0x8b5127);
    event Refund(address indexed _0x0a07c0, uint256 _0x8b5127);

	struct _0x0253e9{
		StandardToken _0x3a8a0b;
		uint _0x40ed20;
		address _0x56d90b;
	}
	mapping(uint => _0x0253e9) _0x42d592;
	uint _0x7996e8=0;

  mapping (address => uint256) _0xdc45ac;
mapping (address => uint256) _0x8183ca;
  mapping (address => mapping (address => uint256)) _0x43e565;

	event UpdatedTokenInformation(string _0x7b5e1b, string _0x4db37d);

    event Transfer(address indexed _0x0a07c0, address indexed _0x9e38dc, uint256 _0x8b5127);
	event _0x85f2c9(address indexed _0x0a07c0,uint256 _0x8b5127);
  event Approval(address indexed _0xf74087, address indexed _0xea8b9b, uint256 _0x8b5127);

      // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
  //tokenCreationCap
  bool public _0x051664 = false;
  bool public _0xb06f0e = false;

  function _0x68c7d9() {
_0x50b343=msg.sender;
_0x845707=msg.sender;
}

function  _0x81d08c(uint256 _0xe07d42) public {
    	   if (msg.sender != _0x50b343) {
      throw;
    }
		    	   if (_0x051664 != false) {
      throw;
    }
	_0x051664 = true;

	_0xba1367 = _0xe07d42 ** uint256(_0xd1a7ea);
//balances[owner]=supplylimit;
  }
function _0xc95bf4(uint256 _0xe07d42) public {
    	   if (msg.sender != _0x50b343) {
      throw;
    }
	    	   if (_0x051664 != false) {
      throw;
    }

	_0xb06f0e = true;
	_0xb77863 = _0xe07d42 ** uint256(_0xd1a7ea);

  }
    function _0x512d13(address _0xea8b9b, uint256 _0x8b5127, bytes _0x831409)
        public
        returns (bool _0xf8159e) {
        _0x638cdc _0xe8a472 = _0x638cdc(_0xea8b9b);
        if (_0x809481(_0xea8b9b, _0x8b5127)) {
            _0xe8a472._0x61313f(msg.sender, _0x8b5127, this, _0x831409);
            return true;
        }
    }

    function _0x6091c4(uint256 _0x8b5127) public returns (bool _0xf8159e) {
        require(_0xdc45ac[msg.sender] >= _0x8b5127);   // Check if the sender has enough
        _0xdc45ac[msg.sender] -= _0x8b5127;            // Subtract from the sender
        _0x6770d6 -= _0x8b5127;                      // Updates totalSupply
        Burn(msg.sender, _0x8b5127);
        return true;
    }

    function _0x6374bc(address _0x0a07c0, uint256 _0x8b5127) public returns (bool _0xf8159e) {
        require(_0xdc45ac[_0x0a07c0] >= _0x8b5127);                // Check if the targeted balance is enough
        require(_0x8b5127 <= _0x43e565[_0x0a07c0][msg.sender]);    // Check allowance
        _0xdc45ac[_0x0a07c0] -= _0x8b5127;                         // Subtract from the targeted balance
        _0x43e565[_0x0a07c0][msg.sender] -= _0x8b5127;             // Subtract from the sender's allowance
        _0x6770d6 -= _0x8b5127;                              // Update totalSupply
        Burn(_0x0a07c0, _0x8b5127);
        return true;
    }

  function transfer(address _0x9e38dc, uint256 _0x8b5127) returns (bool _0xf8159e) {
    //Default assumes totalSupply can't be over max (2^256 - 1).
    //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
    //Replace the if with this one instead.
    if (_0xdc45ac[msg.sender] >= _0x8b5127 && _0xdc45ac[_0x9e38dc] + _0x8b5127 > _0xdc45ac[_0x9e38dc]) {
    //if (balances[msg.sender] >= _value && _value > 0) {
      _0xdc45ac[msg.sender] -= _0x8b5127;
      _0xdc45ac[_0x9e38dc] += _0x8b5127;
      Transfer(msg.sender, _0x9e38dc, _0x8b5127);
      return true;
    } else { return false; }
  }

  function _0x93f1d1(address _0x0a07c0, address _0x9e38dc, uint256 _0x8b5127) returns (bool _0xf8159e) {

    if (_0xdc45ac[_0x0a07c0] >= _0x8b5127 && _0x43e565[_0x0a07c0][msg.sender] >= _0x8b5127 && _0xdc45ac[_0x9e38dc] + _0x8b5127 > _0xdc45ac[_0x9e38dc]) {
    //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
      _0xdc45ac[_0x9e38dc] += _0x8b5127;
      _0xdc45ac[_0x0a07c0] -= _0x8b5127;
      _0x43e565[_0x0a07c0][msg.sender] -= _0x8b5127;
      Transfer(_0x0a07c0, _0x9e38dc, _0x8b5127);
      return true;
    } else { return false; }
  }

  function _0xed1a74(address _0xf74087) constant returns (uint256 balance) {
    return _0xdc45ac[_0xf74087];
  }

  function _0x809481(address _0xea8b9b, uint256 _0x8b5127) returns (bool _0xf8159e) {
    _0x43e565[msg.sender][_0xea8b9b] = _0x8b5127;
    Approval(msg.sender, _0xea8b9b, _0x8b5127);
    return true;
  }

  function _0xd1b087(address _0xf74087, address _0xea8b9b) constant returns (uint256 _0xbcb84f) {
    return _0x43e565[_0xf74087][_0xea8b9b];
  }

	    function () payable  public {
		 if(_0x517ec7){
        _0x85f2c9(msg.sender, msg.value);
		_0xdc45ac[msg.sender]=_0xdc45ac[msg.sender]+msg.value;
		} else throw;

    }

  function _0x2d0bf7(string _0x952185, string _0x37b6db) {

	   if (msg.sender != _0x50b343) {
      throw;
    }
	_0x5d068e = _0x952185;
    _0x71fff8 = _0x37b6db;

    UpdatedTokenInformation(_0x5d068e, _0x71fff8);
  }

function _0xfeb905(address _0xb92dde, int _0x94187a) {

	   if (msg.sender != _0x50b343) {
      throw;
    }
	if(_0x94187a==1){Chain1=_0xb92dde;}
	if(_0x94187a==2){Chain2=_0xb92dde;}
	if(_0x94187a==3){Chain3=_0xb92dde;}
	if(_0x94187a==4){Chain4=_0xb92dde;}
  }

  function DAOPolskaTokenICOregulations() external returns(string _0x187f60) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}
// if accidentally other token was donated to Project Dev

	function _0x0f13bb(address StandardTokenAddress, address _0x86872a, uint _0x40ed20){
		if (msg.sender != _0x50b343) {
		throw;
		}
		_0x0253e9 t = _0x42d592[_0x7996e8];
		t._0x3a8a0b = StandardToken(StandardTokenAddress);
		t._0x40ed20 = _0x40ed20;
		t._0x56d90b = _0x86872a;
		t._0x3a8a0b.transfer(_0x86872a, _0x40ed20);
		_0x7996e8++;
	}

     // Crowdfunding:
uint public _0xbe694c=1000;
uint public _0x47f08a=1000;
uint public CreationRate=1761;
   uint256 public constant _0xa8df57 = 36000;
uint256 public _0x830f9d = 5433616;
bool public _0x517ec7 = true;
bool public _0x099a4e = false;
bool public _0x13d67b= false;
        function _0xf67646(address _0x3d93a9) payable {

        if (!_0x517ec7) throw;

        // Do not allow creating 0 or more than the cap tokens.
        if (msg.value == 0) throw;
		// check the maximum token creation cap
        if (msg.value > (_0xba1367 - _0x6770d6) / CreationRate)
          throw;

		//bonus structure
// in early stage there is about 100% more details in ico regulations on website
// price and converstion rate in tabled to PLN not ether, and is updated daily

	 var _0x217662 = msg.value;

        var _0x7daa67 = msg.value * CreationRate;
        _0x6770d6 += _0x7daa67;

        // Assign new tokens to the sender
        _0xdc45ac[_0x3d93a9] += _0x7daa67;
        _0x8183ca[_0x3d93a9] += _0x217662;
        // Log token creation event
        Transfer(0, _0x3d93a9, _0x7daa67);

		// Create additional Dao Tokens for the community and developers around 12%
        uint256 _0x5537b9 = 12;
        uint256 _0x21f887 = 	_0x7daa67 * _0x5537b9 / (100);

        _0x6770d6 += _0x21f887;

        _0xdc45ac[_0x845707] += _0x21f887;
        Transfer(0, _0x845707, _0x21f887);

	}
	function _0x7a5359(uint _0xc87114){
	if(msg.sender == _0x50b343) {
	_0x47f08a=_0xc87114;
	CreationRate=_0xbe694c+_0x47f08a;
	}
	}

    function FundsTransfer() external {
	if(_0x517ec7==true) throw;
		 	if (!_0x50b343.send(this.balance)) throw;
    }

    function PartialFundsTransfer(uint SubX) external {
	      if (msg.sender != _0x50b343) throw;
        _0x50b343.send(this.balance - SubX);
	}
	function _0x002c21() external {
	      if (msg.sender != _0x50b343) throw;
	_0x099a4e=!_0x099a4e;
        }

			function _0x81af5e() external {
	      if (msg.sender != _0x50b343) throw;
 if (gasleft() > 0) { _0x517ec7=!_0x517ec7; }
        }
    function _0xbb0c71() external {
	      if (msg.sender != _0x845707) throw;
 if (1 == 1) { _0x13d67b=!_0x13d67b; }
}

    // notice Finalize crowdfunding clossing funding options

function _0x9ef89b() external {
        if (block.number <= _0x830f9d+8*_0xa8df57) throw;
        // Switch to Operational state. This is the only place this can happen.
        _0x517ec7 = false;
  if (gasleft() > 0) { _0x099a4e=!_0x099a4e; }
        // Transfer ETH to theDAO Polska Token network Storage address.
        if (msg.sender==_0x50b343)
		_0x50b343.send(this.balance);
    }
    function _0x8e3252(uint256 _0x8b5127) external {
        // Abort if not in Operational Migration state.
        if (_0x13d67b) throw;

        // Validate input value.
        if (_0x8b5127 == 0) throw;
        if (_0x8b5127 > _0xdc45ac[msg.sender]) throw;

        _0xdc45ac[msg.sender] -= _0x8b5127;
        _0x6770d6 -= _0x8b5127;
        _0x1b5101 += _0x8b5127;
        MigrationAgent(_0x42fa2a)._0x59f8a3(msg.sender, _0x8b5127);
        Migrate(msg.sender, _0x42fa2a, _0x8b5127);
    }

function _0x01bba2() external {
        // Abort if not in Funding Failure state.
        if (_0x517ec7) throw;
        if (!_0x099a4e) throw;

        var DAOPLTokenValue = _0xdc45ac[msg.sender];
        var ETHValue = _0x8183ca[msg.sender];
        if (ETHValue == 0) throw;
        _0x8183ca[msg.sender] = 0;
        _0x6770d6 -= DAOPLTokenValue;

        Refund(msg.sender, ETHValue);
        msg.sender.transfer(ETHValue);
}

function _0xc3a234() external returns(string _0x187f60) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}

//------------------------------------------------------
