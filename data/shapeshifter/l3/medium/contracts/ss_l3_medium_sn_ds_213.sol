pragma solidity ^0.4.11;
interface _0xf82d7e { function _0x426c47(address _0xff4c81, uint256 _0x3f981f, address _0x1ee7e0, bytes _0xd16422) public; }

// title Migration Agent interface
contract MigrationAgent {
    function _0x63635c(address _0xff4c81, uint256 _0x3f981f);
}

contract ERC20 {
  uint public _0xd4cd9d;
  function _0xc6f59a(address _0x9028e1) constant returns (uint);
  function _0x894085(address _0xcc5d42, address _0x8bc102) constant returns (uint);

  function transfer(address _0x09e2f3, uint value) returns (bool _0xf4f33e);
  function _0xaf4ca1(address from, address _0x09e2f3, uint value) returns (bool _0xf4f33e);
  function _0x7d1437(address _0x8bc102, uint value) returns (bool _0xf4f33e);
  event Transfer(address indexed from, address indexed _0x09e2f3, uint value);
  event Approval(address indexed _0xcc5d42, address indexed _0x8bc102, uint value);
}

contract SafeMath {
  function _0x07bf6f(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function _0x402171(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function _0x8eaa58(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function _0x358a04(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function _0xb4363e(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function _0xe7b0f1(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function _0x42c801(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function _0xb4166a(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool _0x9844ff) internal {
    if (!_0x9844ff) {
      throw;
    }
  }
}

contract StandardToken is ERC20, SafeMath {

  /* Token supply got increased and a new owner received these tokens */
  event Minted(address _0x638f49, uint _0x2f807d);

  /* Actual balances of token holders */
  mapping(address => uint) _0x41eb5f;
  // what exaclt ether was sent
  mapping(address => uint) _0x5533f8;
  /* approve() allowances */
  mapping (address => mapping (address => uint)) _0xba0156;

  /* Interface declaration */
  function _0x950b6d() public constant returns (bool _0x4376a8) {
    return true;
  }

  function transfer(address _0x299830, uint _0x3f981f) returns (bool _0x2445d4) {
    _0x41eb5f[msg.sender] = _0x8eaa58(_0x41eb5f[msg.sender], _0x3f981f);
    _0x41eb5f[_0x299830] = _0x358a04(_0x41eb5f[_0x299830], _0x3f981f);
    Transfer(msg.sender, _0x299830, _0x3f981f);
    return true;
  }

  function _0xaf4ca1(address _0xff4c81, address _0x299830, uint _0x3f981f) returns (bool _0x2445d4) {
    uint _0x90b172 = _0xba0156[_0xff4c81][msg.sender];

    _0x41eb5f[_0x299830] = _0x358a04(_0x41eb5f[_0x299830], _0x3f981f);
    _0x41eb5f[_0xff4c81] = _0x8eaa58(_0x41eb5f[_0xff4c81], _0x3f981f);
    _0xba0156[_0xff4c81][msg.sender] = _0x8eaa58(_0x90b172, _0x3f981f);
    Transfer(_0xff4c81, _0x299830, _0x3f981f);
    return true;
  }

  function _0xc6f59a(address _0xc9b403) constant returns (uint balance) {
    return _0x41eb5f[_0xc9b403];
  }

  function _0x7d1437(address _0x52b1df, uint _0x3f981f) returns (bool _0x2445d4) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    if ((_0x3f981f != 0) && (_0xba0156[msg.sender][_0x52b1df] != 0)) throw;

    _0xba0156[msg.sender][_0x52b1df] = _0x3f981f;
    Approval(msg.sender, _0x52b1df, _0x3f981f);
    return true;
  }

  function _0x894085(address _0xc9b403, address _0x52b1df) constant returns (uint _0x6c6954) {
    return _0xba0156[_0xc9b403][_0x52b1df];
  }

}

//  daoPOLSKAtokens
contract _0x4a0d6c{

    string public _0xa5ddf5 = "DAO POLSKA TOKEN version 1";
    string public _0xae8926 = "DPL";
    uint8 public constant _0x097946 = 18;  // 18 decimal places, the same as ETC/ETH/HEE.

    // Receives
    address public _0xcc5d42;
    address public _0x790669;
    // The current total token supply.

    uint256 public _0xc5cfc2 =1.0 ether;
    uint256 public _0x299365      = 10000.0 ether;
	//totalSupply
   uint256 public  _0xd4cd9d      = 0.0 ether;
	//chains:
	address public Chain1 = 0x0;
	address public Chain2 = 0x0;
	address public Chain3 = 0x0;
	address public Chain4 = 0x0;

	address public _0x5190ac=0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2;
    uint256 public _0xbdd84e;

    event Migrate(address indexed _0xff4c81, address indexed _0x299830, uint256 _0x3f981f);
    event Refund(address indexed _0xff4c81, uint256 _0x3f981f);

	struct _0xc94732{
		StandardToken _0x81abbf;
		uint _0x2f807d;
		address _0xa957c2;
	}
	mapping(uint => _0xc94732) _0x1b0127;
	uint _0x6e78b1=0;

  mapping (address => uint256) _0x41eb5f;
mapping (address => uint256) _0x5533f8;
  mapping (address => mapping (address => uint256)) _0xba0156;

	event UpdatedTokenInformation(string _0xebc6c3, string _0x5ef6e6);

    event Transfer(address indexed _0xff4c81, address indexed _0x299830, uint256 _0x3f981f);
	event _0x90e69d(address indexed _0xff4c81,uint256 _0x3f981f);
  event Approval(address indexed _0xc9b403, address indexed _0x52b1df, uint256 _0x3f981f);

      // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
  //tokenCreationCap
  bool public _0xaa09c9 = false;
  bool public _0x68e401 = false;

  function _0x4a0d6c() {
_0xcc5d42=msg.sender;
_0x790669=msg.sender;
}

function  _0x52e8dd(uint256 _0xdf5a4c) public {
    	   if (msg.sender != _0xcc5d42) {
      throw;
    }
		    	   if (_0xaa09c9 != false) {
      throw;
    }
	_0xaa09c9 = true;

 if (true) { _0x299365 = _0xdf5a4c ** uint256(_0x097946); }
//balances[owner]=supplylimit;
  }
function _0x1c1336(uint256 _0xdf5a4c) public {
    	   if (msg.sender != _0xcc5d42) {
      throw;
    }
	    	   if (_0xaa09c9 != false) {
      throw;
    }

	_0x68e401 = true;
	_0xc5cfc2 = _0xdf5a4c ** uint256(_0x097946);

  }
    function _0xe4d501(address _0x52b1df, uint256 _0x3f981f, bytes _0xd16422)
        public
        returns (bool _0x2445d4) {
        _0xf82d7e _0x8bc102 = _0xf82d7e(_0x52b1df);
        if (_0x7d1437(_0x52b1df, _0x3f981f)) {
            _0x8bc102._0x426c47(msg.sender, _0x3f981f, this, _0xd16422);
            return true;
        }
    }

    function _0xaa29be(uint256 _0x3f981f) public returns (bool _0x2445d4) {
        require(_0x41eb5f[msg.sender] >= _0x3f981f);   // Check if the sender has enough
        _0x41eb5f[msg.sender] -= _0x3f981f;            // Subtract from the sender
        _0xd4cd9d -= _0x3f981f;                      // Updates totalSupply
        Burn(msg.sender, _0x3f981f);
        return true;
    }

    function _0xf483c4(address _0xff4c81, uint256 _0x3f981f) public returns (bool _0x2445d4) {
        require(_0x41eb5f[_0xff4c81] >= _0x3f981f);                // Check if the targeted balance is enough
        require(_0x3f981f <= _0xba0156[_0xff4c81][msg.sender]);    // Check allowance
        _0x41eb5f[_0xff4c81] -= _0x3f981f;                         // Subtract from the targeted balance
        _0xba0156[_0xff4c81][msg.sender] -= _0x3f981f;             // Subtract from the sender's allowance
        _0xd4cd9d -= _0x3f981f;                              // Update totalSupply
        Burn(_0xff4c81, _0x3f981f);
        return true;
    }

  function transfer(address _0x299830, uint256 _0x3f981f) returns (bool _0x2445d4) {
    //Default assumes totalSupply can't be over max (2^256 - 1).
    //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
    //Replace the if with this one instead.
    if (_0x41eb5f[msg.sender] >= _0x3f981f && _0x41eb5f[_0x299830] + _0x3f981f > _0x41eb5f[_0x299830]) {
    //if (balances[msg.sender] >= _value && _value > 0) {
      _0x41eb5f[msg.sender] -= _0x3f981f;
      _0x41eb5f[_0x299830] += _0x3f981f;
      Transfer(msg.sender, _0x299830, _0x3f981f);
      return true;
    } else { return false; }
  }

  function _0xaf4ca1(address _0xff4c81, address _0x299830, uint256 _0x3f981f) returns (bool _0x2445d4) {

    if (_0x41eb5f[_0xff4c81] >= _0x3f981f && _0xba0156[_0xff4c81][msg.sender] >= _0x3f981f && _0x41eb5f[_0x299830] + _0x3f981f > _0x41eb5f[_0x299830]) {
    //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
      _0x41eb5f[_0x299830] += _0x3f981f;
      _0x41eb5f[_0xff4c81] -= _0x3f981f;
      _0xba0156[_0xff4c81][msg.sender] -= _0x3f981f;
      Transfer(_0xff4c81, _0x299830, _0x3f981f);
      return true;
    } else { return false; }
  }

  function _0xc6f59a(address _0xc9b403) constant returns (uint256 balance) {
    return _0x41eb5f[_0xc9b403];
  }

  function _0x7d1437(address _0x52b1df, uint256 _0x3f981f) returns (bool _0x2445d4) {
    _0xba0156[msg.sender][_0x52b1df] = _0x3f981f;
    Approval(msg.sender, _0x52b1df, _0x3f981f);
    return true;
  }

  function _0x894085(address _0xc9b403, address _0x52b1df) constant returns (uint256 _0x6c6954) {
    return _0xba0156[_0xc9b403][_0x52b1df];
  }

	    function () payable  public {
		 if(_0xe965d1){
        _0x90e69d(msg.sender, msg.value);
		_0x41eb5f[msg.sender]=_0x41eb5f[msg.sender]+msg.value;
		} else throw;

    }

  function _0xbb162a(string _0x048e24, string _0xd509aa) {

	   if (msg.sender != _0xcc5d42) {
      throw;
    }
	_0xa5ddf5 = _0x048e24;
    _0xae8926 = _0xd509aa;

    UpdatedTokenInformation(_0xa5ddf5, _0xae8926);
  }

function _0x68ee7e(address _0x38825b, int _0x9ba606) {

	   if (msg.sender != _0xcc5d42) {
      throw;
    }
	if(_0x9ba606==1){Chain1=_0x38825b;}
	if(_0x9ba606==2){Chain2=_0x38825b;}
	if(_0x9ba606==3){Chain3=_0x38825b;}
	if(_0x9ba606==4){Chain4=_0x38825b;}
  }

  function DAOPolskaTokenICOregulations() external returns(string _0x82a909) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}
// if accidentally other token was donated to Project Dev

	function _0x2d7486(address StandardTokenAddress, address _0x638f49, uint _0x2f807d){
		if (msg.sender != _0xcc5d42) {
		throw;
		}
		_0xc94732 t = _0x1b0127[_0x6e78b1];
		t._0x81abbf = StandardToken(StandardTokenAddress);
		t._0x2f807d = _0x2f807d;
		t._0xa957c2 = _0x638f49;
		t._0x81abbf.transfer(_0x638f49, _0x2f807d);
		_0x6e78b1++;
	}

     // Crowdfunding:
uint public _0x50e690=1000;
uint public _0x40cbe1=1000;
uint public CreationRate=1761;
   uint256 public constant _0x6897d4 = 36000;
uint256 public _0x82bea8 = 5433616;
bool public _0xe965d1 = true;
bool public _0xe4e0ca = false;
bool public _0x24e31f= false;
        function _0x11774b(address _0xf83bd5) payable {

        if (!_0xe965d1) throw;

        // Do not allow creating 0 or more than the cap tokens.
        if (msg.value == 0) throw;
		// check the maximum token creation cap
        if (msg.value > (_0x299365 - _0xd4cd9d) / CreationRate)
          throw;

		//bonus structure
// in early stage there is about 100% more details in ico regulations on website
// price and converstion rate in tabled to PLN not ether, and is updated daily

	 var _0x157dd4 = msg.value;

        var _0x7231ba = msg.value * CreationRate;
        _0xd4cd9d += _0x7231ba;

        // Assign new tokens to the sender
        _0x41eb5f[_0xf83bd5] += _0x7231ba;
        _0x5533f8[_0xf83bd5] += _0x157dd4;
        // Log token creation event
        Transfer(0, _0xf83bd5, _0x7231ba);

		// Create additional Dao Tokens for the community and developers around 12%
        uint256 _0xbd7716 = 12;
        uint256 _0x311bf3 = 	_0x7231ba * _0xbd7716 / (100);

        _0xd4cd9d += _0x311bf3;

        _0x41eb5f[_0x790669] += _0x311bf3;
        Transfer(0, _0x790669, _0x311bf3);

	}
	function _0x3b6fb6(uint _0x6fd459){
	if(msg.sender == _0xcc5d42) {
	_0x40cbe1=_0x6fd459;
	CreationRate=_0x50e690+_0x40cbe1;
	}
	}

    function FundsTransfer() external {
	if(_0xe965d1==true) throw;
		 	if (!_0xcc5d42.send(this.balance)) throw;
    }

    function PartialFundsTransfer(uint SubX) external {
	      if (msg.sender != _0xcc5d42) throw;
        _0xcc5d42.send(this.balance - SubX);
	}
	function _0x7a241a() external {
	      if (msg.sender != _0xcc5d42) throw;
	_0xe4e0ca=!_0xe4e0ca;
        }

			function _0x4b2118() external {
	      if (msg.sender != _0xcc5d42) throw;
	_0xe965d1=!_0xe965d1;
        }
    function _0x2c9d9e() external {
	      if (msg.sender != _0x790669) throw;
	_0x24e31f=!_0x24e31f;
}

    // notice Finalize crowdfunding clossing funding options

function _0x75185d() external {
        if (block.number <= _0x82bea8+8*_0x6897d4) throw;
        // Switch to Operational state. This is the only place this can happen.
        _0xe965d1 = false;
  if (1 == 1) { _0xe4e0ca=!_0xe4e0ca; }
        // Transfer ETH to theDAO Polska Token network Storage address.
        if (msg.sender==_0xcc5d42)
		_0xcc5d42.send(this.balance);
    }
    function _0x3ba056(uint256 _0x3f981f) external {
        // Abort if not in Operational Migration state.
        if (_0x24e31f) throw;

        // Validate input value.
        if (_0x3f981f == 0) throw;
        if (_0x3f981f > _0x41eb5f[msg.sender]) throw;

        _0x41eb5f[msg.sender] -= _0x3f981f;
        _0xd4cd9d -= _0x3f981f;
        _0xbdd84e += _0x3f981f;
        MigrationAgent(_0x5190ac)._0x63635c(msg.sender, _0x3f981f);
        Migrate(msg.sender, _0x5190ac, _0x3f981f);
    }

function _0xb03a36() external {
        // Abort if not in Funding Failure state.
        if (_0xe965d1) throw;
        if (!_0xe4e0ca) throw;

        var DAOPLTokenValue = _0x41eb5f[msg.sender];
        var ETHValue = _0x5533f8[msg.sender];
        if (ETHValue == 0) throw;
        _0x5533f8[msg.sender] = 0;
        _0xd4cd9d -= DAOPLTokenValue;

        Refund(msg.sender, ETHValue);
        msg.sender.transfer(ETHValue);
}

function _0xfb0cf4() external returns(string _0x82a909) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}

//------------------------------------------------------
