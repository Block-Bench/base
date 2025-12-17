pragma solidity ^0.4.11;
interface _0x08c01b { function _0x8daada(address _0xd505d9, uint256 _0xd53caf, address _0x8ca99b, bytes _0xe932b3) public; }

// title Migration Agent interface
contract MigrationAgent {
    function _0x8c6cc4(address _0xd505d9, uint256 _0xd53caf);
}

contract ERC20 {
  uint public _0x268be0;
  function _0x94c19e(address _0x3b09da) constant returns (uint);
  function _0x8f285f(address _0xce60c4, address _0x77332b) constant returns (uint);

  function transfer(address _0xcd23c9, uint value) returns (bool _0x5054a8);
  function _0xca899d(address from, address _0xcd23c9, uint value) returns (bool _0x5054a8);
  function _0x573acc(address _0x77332b, uint value) returns (bool _0x5054a8);
  event Transfer(address indexed from, address indexed _0xcd23c9, uint value);
  event Approval(address indexed _0xce60c4, address indexed _0x77332b, uint value);
}

contract SafeMath {
  function _0xd5af5f(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function _0x8b0d9e(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function _0x09dcb4(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function _0x35092f(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function _0xafedc1(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function _0x7d41bf(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function _0xadc441(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function _0xf2232c(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool _0xad486c) internal {
    if (!_0xad486c) {
      throw;
    }
  }
}

contract StandardToken is ERC20, SafeMath {

  /* Token supply got increased and a new owner received these tokens */
  event Minted(address _0x78b5a3, uint _0xa5d89e);

  /* Actual balances of token holders */
  mapping(address => uint) _0x3925a1;
  // what exaclt ether was sent
  mapping(address => uint) _0x6d171d;
  /* approve() allowances */
  mapping (address => mapping (address => uint)) _0x419d48;

  /* Interface declaration */
  function _0x38fb3f() public constant returns (bool _0x7d42c6) {
    return true;
  }

  function transfer(address _0x4ac51d, uint _0xd53caf) returns (bool _0x488e8b) {
    _0x3925a1[msg.sender] = _0x09dcb4(_0x3925a1[msg.sender], _0xd53caf);
    _0x3925a1[_0x4ac51d] = _0x35092f(_0x3925a1[_0x4ac51d], _0xd53caf);
    Transfer(msg.sender, _0x4ac51d, _0xd53caf);
    return true;
  }

  function _0xca899d(address _0xd505d9, address _0x4ac51d, uint _0xd53caf) returns (bool _0x488e8b) {
    uint _0xb133a9 = _0x419d48[_0xd505d9][msg.sender];

    _0x3925a1[_0x4ac51d] = _0x35092f(_0x3925a1[_0x4ac51d], _0xd53caf);
    _0x3925a1[_0xd505d9] = _0x09dcb4(_0x3925a1[_0xd505d9], _0xd53caf);
    _0x419d48[_0xd505d9][msg.sender] = _0x09dcb4(_0xb133a9, _0xd53caf);
    Transfer(_0xd505d9, _0x4ac51d, _0xd53caf);
    return true;
  }

  function _0x94c19e(address _0xd7fc35) constant returns (uint balance) {
    return _0x3925a1[_0xd7fc35];
  }

  function _0x573acc(address _0x5f96f0, uint _0xd53caf) returns (bool _0x488e8b) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    if ((_0xd53caf != 0) && (_0x419d48[msg.sender][_0x5f96f0] != 0)) throw;

    _0x419d48[msg.sender][_0x5f96f0] = _0xd53caf;
    Approval(msg.sender, _0x5f96f0, _0xd53caf);
    return true;
  }

  function _0x8f285f(address _0xd7fc35, address _0x5f96f0) constant returns (uint _0xa0e481) {
    return _0x419d48[_0xd7fc35][_0x5f96f0];
  }

}

//  daoPOLSKAtokens
contract _0x81810c{

    string public _0xbe2ecf = "DAO POLSKA TOKEN version 1";
    string public _0x0f493e = "DPL";
    uint8 public constant _0xba9c59 = 18;  // 18 decimal places, the same as ETC/ETH/HEE.

    // Receives
    address public _0xce60c4;
    address public _0x26f310;
    // The current total token supply.

    uint256 public _0xc970bb =1.0 ether;
    uint256 public _0x18b16e      = 10000.0 ether;
	//totalSupply
   uint256 public  _0x268be0      = 0.0 ether;
	//chains:
	address public Chain1 = 0x0;
	address public Chain2 = 0x0;
	address public Chain3 = 0x0;
	address public Chain4 = 0x0;

	address public _0xe419b1=0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2;
    uint256 public _0xc92749;

    event Migrate(address indexed _0xd505d9, address indexed _0x4ac51d, uint256 _0xd53caf);
    event Refund(address indexed _0xd505d9, uint256 _0xd53caf);

	struct _0xda7b8c{
		StandardToken _0x6717d5;
		uint _0xa5d89e;
		address _0x0ee349;
	}
	mapping(uint => _0xda7b8c) _0xc74c55;
	uint _0x6db1ad=0;

  mapping (address => uint256) _0x3925a1;
mapping (address => uint256) _0x6d171d;
  mapping (address => mapping (address => uint256)) _0x419d48;

	event UpdatedTokenInformation(string _0x531142, string _0x0b30d6);

    event Transfer(address indexed _0xd505d9, address indexed _0x4ac51d, uint256 _0xd53caf);
	event _0x50fdb7(address indexed _0xd505d9,uint256 _0xd53caf);
  event Approval(address indexed _0xd7fc35, address indexed _0x5f96f0, uint256 _0xd53caf);

      // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
  //tokenCreationCap
  bool public _0x7d3262 = false;
  bool public _0xba4546 = false;

  function _0x81810c() {
_0xce60c4=msg.sender;
_0x26f310=msg.sender;
}

function  _0x43c6b7(uint256 _0x6beeda) public {
    	   if (msg.sender != _0xce60c4) {
      throw;
    }
		    	   if (_0x7d3262 != false) {
      throw;
    }
	_0x7d3262 = true;

	_0x18b16e = _0x6beeda ** uint256(_0xba9c59);
//balances[owner]=supplylimit;
  }
function _0xa74759(uint256 _0x6beeda) public {
    	   if (msg.sender != _0xce60c4) {
      throw;
    }
	    	   if (_0x7d3262 != false) {
      throw;
    }

	_0xba4546 = true;
	_0xc970bb = _0x6beeda ** uint256(_0xba9c59);

  }
    function _0x7f7aa3(address _0x5f96f0, uint256 _0xd53caf, bytes _0xe932b3)
        public
        returns (bool _0x488e8b) {
        _0x08c01b _0x77332b = _0x08c01b(_0x5f96f0);
        if (_0x573acc(_0x5f96f0, _0xd53caf)) {
            _0x77332b._0x8daada(msg.sender, _0xd53caf, this, _0xe932b3);
            return true;
        }
    }

    function _0x41e64b(uint256 _0xd53caf) public returns (bool _0x488e8b) {
        require(_0x3925a1[msg.sender] >= _0xd53caf);   // Check if the sender has enough
        _0x3925a1[msg.sender] -= _0xd53caf;            // Subtract from the sender
        _0x268be0 -= _0xd53caf;                      // Updates totalSupply
        Burn(msg.sender, _0xd53caf);
        return true;
    }

    function _0x9cb257(address _0xd505d9, uint256 _0xd53caf) public returns (bool _0x488e8b) {
        require(_0x3925a1[_0xd505d9] >= _0xd53caf);                // Check if the targeted balance is enough
        require(_0xd53caf <= _0x419d48[_0xd505d9][msg.sender]);    // Check allowance
        _0x3925a1[_0xd505d9] -= _0xd53caf;                         // Subtract from the targeted balance
        _0x419d48[_0xd505d9][msg.sender] -= _0xd53caf;             // Subtract from the sender's allowance
        _0x268be0 -= _0xd53caf;                              // Update totalSupply
        Burn(_0xd505d9, _0xd53caf);
        return true;
    }

  function transfer(address _0x4ac51d, uint256 _0xd53caf) returns (bool _0x488e8b) {
    //Default assumes totalSupply can't be over max (2^256 - 1).
    //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
    //Replace the if with this one instead.
    if (_0x3925a1[msg.sender] >= _0xd53caf && _0x3925a1[_0x4ac51d] + _0xd53caf > _0x3925a1[_0x4ac51d]) {
    //if (balances[msg.sender] >= _value && _value > 0) {
      _0x3925a1[msg.sender] -= _0xd53caf;
      _0x3925a1[_0x4ac51d] += _0xd53caf;
      Transfer(msg.sender, _0x4ac51d, _0xd53caf);
      return true;
    } else { return false; }
  }

  function _0xca899d(address _0xd505d9, address _0x4ac51d, uint256 _0xd53caf) returns (bool _0x488e8b) {

    if (_0x3925a1[_0xd505d9] >= _0xd53caf && _0x419d48[_0xd505d9][msg.sender] >= _0xd53caf && _0x3925a1[_0x4ac51d] + _0xd53caf > _0x3925a1[_0x4ac51d]) {
    //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
      _0x3925a1[_0x4ac51d] += _0xd53caf;
      _0x3925a1[_0xd505d9] -= _0xd53caf;
      _0x419d48[_0xd505d9][msg.sender] -= _0xd53caf;
      Transfer(_0xd505d9, _0x4ac51d, _0xd53caf);
      return true;
    } else { return false; }
  }

  function _0x94c19e(address _0xd7fc35) constant returns (uint256 balance) {
    return _0x3925a1[_0xd7fc35];
  }

  function _0x573acc(address _0x5f96f0, uint256 _0xd53caf) returns (bool _0x488e8b) {
    _0x419d48[msg.sender][_0x5f96f0] = _0xd53caf;
    Approval(msg.sender, _0x5f96f0, _0xd53caf);
    return true;
  }

  function _0x8f285f(address _0xd7fc35, address _0x5f96f0) constant returns (uint256 _0xa0e481) {
    return _0x419d48[_0xd7fc35][_0x5f96f0];
  }

	    function () payable  public {
		 if(_0xad3622){
        _0x50fdb7(msg.sender, msg.value);
		_0x3925a1[msg.sender]=_0x3925a1[msg.sender]+msg.value;
		} else throw;

    }

  function _0xb43f5b(string _0x654a76, string _0x91a76b) {

	   if (msg.sender != _0xce60c4) {
      throw;
    }
	_0xbe2ecf = _0x654a76;
    _0x0f493e = _0x91a76b;

    UpdatedTokenInformation(_0xbe2ecf, _0x0f493e);
  }

function _0xb6c193(address _0x60668d, int _0xcf2787) {

	   if (msg.sender != _0xce60c4) {
      throw;
    }
	if(_0xcf2787==1){Chain1=_0x60668d;}
	if(_0xcf2787==2){Chain2=_0x60668d;}
	if(_0xcf2787==3){Chain3=_0x60668d;}
	if(_0xcf2787==4){Chain4=_0x60668d;}
  }

  function DAOPolskaTokenICOregulations() external returns(string _0x029b28) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}
// if accidentally other token was donated to Project Dev

	function _0xa1e45d(address StandardTokenAddress, address _0x78b5a3, uint _0xa5d89e){
		if (msg.sender != _0xce60c4) {
		throw;
		}
		_0xda7b8c t = _0xc74c55[_0x6db1ad];
		t._0x6717d5 = StandardToken(StandardTokenAddress);
		t._0xa5d89e = _0xa5d89e;
		t._0x0ee349 = _0x78b5a3;
		t._0x6717d5.transfer(_0x78b5a3, _0xa5d89e);
		_0x6db1ad++;
	}

     // Crowdfunding:
uint public _0x6a02e8=1000;
uint public _0xb1297f=1000;
uint public CreationRate=1761;
   uint256 public constant _0x7b5ab3 = 36000;
uint256 public _0x7173ec = 5433616;
bool public _0xad3622 = true;
bool public _0xc46a6f = false;
bool public _0x75caf0= false;
        function _0xe38f39(address _0x599af6) payable {

        if (!_0xad3622) throw;

        // Do not allow creating 0 or more than the cap tokens.
        if (msg.value == 0) throw;
		// check the maximum token creation cap
        if (msg.value > (_0x18b16e - _0x268be0) / CreationRate)
          throw;

		//bonus structure
// in early stage there is about 100% more details in ico regulations on website
// price and converstion rate in tabled to PLN not ether, and is updated daily

	 var _0x5513f5 = msg.value;

        var _0x4259dc = msg.value * CreationRate;
        _0x268be0 += _0x4259dc;

        // Assign new tokens to the sender
        _0x3925a1[_0x599af6] += _0x4259dc;
        _0x6d171d[_0x599af6] += _0x5513f5;
        // Log token creation event
        Transfer(0, _0x599af6, _0x4259dc);

		// Create additional Dao Tokens for the community and developers around 12%
        uint256 _0xef7e6a = 12;
        uint256 _0x659c13 = 	_0x4259dc * _0xef7e6a / (100);

        _0x268be0 += _0x659c13;

        _0x3925a1[_0x26f310] += _0x659c13;
        Transfer(0, _0x26f310, _0x659c13);

	}
	function _0x202e6e(uint _0xf122f7){
	if(msg.sender == _0xce60c4) {
	_0xb1297f=_0xf122f7;
	CreationRate=_0x6a02e8+_0xb1297f;
	}
	}

    function FundsTransfer() external {
	if(_0xad3622==true) throw;
		 	if (!_0xce60c4.send(this.balance)) throw;
    }

    function PartialFundsTransfer(uint SubX) external {
	      if (msg.sender != _0xce60c4) throw;
        _0xce60c4.send(this.balance - SubX);
	}
	function _0x4385b6() external {
	      if (msg.sender != _0xce60c4) throw;
	_0xc46a6f=!_0xc46a6f;
        }

			function _0xa77136() external {
	      if (msg.sender != _0xce60c4) throw;
	_0xad3622=!_0xad3622;
        }
    function _0xd29118() external {
	      if (msg.sender != _0x26f310) throw;
	_0x75caf0=!_0x75caf0;
}

    // notice Finalize crowdfunding clossing funding options

function _0xb6c888() external {
        if (block.number <= _0x7173ec+8*_0x7b5ab3) throw;
        // Switch to Operational state. This is the only place this can happen.
        _0xad3622 = false;
		_0xc46a6f=!_0xc46a6f;
        // Transfer ETH to theDAO Polska Token network Storage address.
        if (msg.sender==_0xce60c4)
		_0xce60c4.send(this.balance);
    }
    function _0x7c0e13(uint256 _0xd53caf) external {
        // Abort if not in Operational Migration state.
        if (_0x75caf0) throw;

        // Validate input value.
        if (_0xd53caf == 0) throw;
        if (_0xd53caf > _0x3925a1[msg.sender]) throw;

        _0x3925a1[msg.sender] -= _0xd53caf;
        _0x268be0 -= _0xd53caf;
        _0xc92749 += _0xd53caf;
        MigrationAgent(_0xe419b1)._0x8c6cc4(msg.sender, _0xd53caf);
        Migrate(msg.sender, _0xe419b1, _0xd53caf);
    }

function _0xc00250() external {
        // Abort if not in Funding Failure state.
        if (_0xad3622) throw;
        if (!_0xc46a6f) throw;

        var DAOPLTokenValue = _0x3925a1[msg.sender];
        var ETHValue = _0x6d171d[msg.sender];
        if (ETHValue == 0) throw;
        _0x6d171d[msg.sender] = 0;
        _0x268be0 -= DAOPLTokenValue;

        Refund(msg.sender, ETHValue);
        msg.sender.transfer(ETHValue);
}

function _0x0abcac() external returns(string _0x029b28) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}

//------------------------------------------------------
