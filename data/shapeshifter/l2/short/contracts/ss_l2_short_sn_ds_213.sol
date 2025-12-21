pragma solidity ^0.4.11;
interface q { function m(address cg, uint256 bv, address bw, bytes ao) public; }

// title Migration Agent interface
contract MigrationAgent {
    function ak(address cg, uint256 bv);
}

contract ERC20 {
  uint public ai;
  function aw(address cn) constant returns (uint);
  function as(address ci, address bj) constant returns (uint);

  function transfer(address cp, uint value) returns (bool co);
  function ac(address from, address cp, uint value) returns (bool co);
  function bh(address bj, uint value) returns (bool co);
  event Transfer(address indexed from, address indexed cp, uint value);
  event Approval(address indexed ci, address indexed bj, uint value);
}

contract SafeMath {
  function bp(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function bi(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function bu(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function bk(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function cd(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function ch(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function bz(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function cc(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool ar) internal {
    if (!ar) {
      throw;
    }
  }
}

contract StandardToken is ERC20, SafeMath {

  /* Token supply got increased and a new owner received these tokens */
  event Minted(address az, uint by);

  /* Actual balances of token holders */
  mapping(address => uint) bc;
  // what exaclt ether was sent
  mapping(address => uint) ag;
  /* approve() allowances */
  mapping (address => mapping (address => uint)) br;

  /* Interface declaration */
  function bt() public constant returns (bool cf) {
    return true;
  }

  function transfer(address cm, uint bv) returns (bool bn) {
    bc[msg.sender] = bu(bc[msg.sender], bv);
    bc[cm] = bk(bc[cm], bv);
    Transfer(msg.sender, cm, bv);
    return true;
  }

  function ac(address cg, address cm, uint bv) returns (bool bn) {
    uint am = br[cg][msg.sender];

    bc[cm] = bk(bc[cm], bv);
    bc[cg] = bu(bc[cg], bv);
    br[cg][msg.sender] = bu(am, bv);
    Transfer(cg, cm, bv);
    return true;
  }

  function aw(address cb) constant returns (uint balance) {
    return bc[cb];
  }

  function bh(address bd, uint bv) returns (bool bn) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    if ((bv != 0) && (br[msg.sender][bd] != 0)) throw;

    br[msg.sender][bd] = bv;
    Approval(msg.sender, bd, bv);
    return true;
  }

  function as(address cb, address bd) constant returns (uint av) {
    return br[cb][bd];
  }

}

//  daoPOLSKAtokens
contract o{

    string public ck = "DAO POLSKA TOKEN version 1";
    string public bx = "DPL";
    uint8 public constant ba = 18;  // 18 decimal places, the same as ETC/ETH/HEE.

    // Receives
    address public ci;
    address public l;
    // The current total token supply.

    uint256 public b =1.0 ether;
    uint256 public aj      = 10000.0 ether;
	//totalSupply
   uint256 public  ai      = 0.0 ether;
	//chains:
	address public Chain1 = 0x0;
	address public Chain2 = 0x0;
	address public Chain3 = 0x0;
	address public Chain4 = 0x0;

	address public s=0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2;
    uint256 public w;

    event Migrate(address indexed cg, address indexed cm, uint256 bv);
    event Refund(address indexed cg, uint256 bv);

	struct v{
		StandardToken y;
		uint by;
		address at;
	}
	mapping(uint => v) ay;
	uint z=0;

  mapping (address => uint256) bc;
mapping (address => uint256) ag;
  mapping (address => mapping (address => uint256)) br;

	event UpdatedTokenInformation(string bm, string ax);

    event Transfer(address indexed cg, address indexed cm, uint256 bv);
	event u(address indexed cg,uint256 bv);
  event Approval(address indexed cb, address indexed bd, uint256 bv);

      // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
  //tokenCreationCap
  bool public r = false;
  bool public f = false;

  function o() {
ci=msg.sender;
l=msg.sender;
}

function  aq(uint256 ad) public {
    	   if (msg.sender != ci) {
      throw;
    }
		    	   if (r != false) {
      throw;
    }
	r = true;

	aj = ad ** uint256(ba);
//balances[owner]=supplylimit;
  }
function a(uint256 ad) public {
    	   if (msg.sender != ci) {
      throw;
    }
	    	   if (r != false) {
      throw;
    }

	f = true;
	b = ad ** uint256(ba);

  }
    function p(address bd, uint256 bv, bytes ao)
        public
        returns (bool bn) {
        q bj = q(bd);
        if (bh(bd, bv)) {
            bj.m(msg.sender, bv, this, ao);
            return true;
        }
    }

    function cj(uint256 bv) public returns (bool bn) {
        require(bc[msg.sender] >= bv);   // Check if the sender has enough
        bc[msg.sender] -= bv;            // Subtract from the sender
        ai -= bv;                      // Updates totalSupply
        Burn(msg.sender, bv);
        return true;
    }

    function bb(address cg, uint256 bv) public returns (bool bn) {
        require(bc[cg] >= bv);                // Check if the targeted balance is enough
        require(bv <= br[cg][msg.sender]);    // Check allowance
        bc[cg] -= bv;                         // Subtract from the targeted balance
        br[cg][msg.sender] -= bv;             // Subtract from the sender's allowance
        ai -= bv;                              // Update totalSupply
        Burn(cg, bv);
        return true;
    }

  function transfer(address cm, uint256 bv) returns (bool bn) {
    //Default assumes totalSupply can't be over max (2^256 - 1).
    //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
    //Replace the if with this one instead.
    if (bc[msg.sender] >= bv && bc[cm] + bv > bc[cm]) {
    //if (balances[msg.sender] >= _value && _value > 0) {
      bc[msg.sender] -= bv;
      bc[cm] += bv;
      Transfer(msg.sender, cm, bv);
      return true;
    } else { return false; }
  }

  function ac(address cg, address cm, uint256 bv) returns (bool bn) {

    if (bc[cg] >= bv && br[cg][msg.sender] >= bv && bc[cm] + bv > bc[cm]) {
    //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
      bc[cm] += bv;
      bc[cg] -= bv;
      br[cg][msg.sender] -= bv;
      Transfer(cg, cm, bv);
      return true;
    } else { return false; }
  }

  function aw(address cb) constant returns (uint256 balance) {
    return bc[cb];
  }

  function bh(address bd, uint256 bv) returns (bool bn) {
    br[msg.sender][bd] = bv;
    Approval(msg.sender, bd, bv);
    return true;
  }

  function as(address cb, address bd) constant returns (uint256 av) {
    return br[cb][bd];
  }

	    function () payable  public {
		 if(bo){
        u(msg.sender, msg.value);
		bc[msg.sender]=bc[msg.sender]+msg.value;
		} else throw;

    }

  function e(string ce, string bg) {

	   if (msg.sender != ci) {
      throw;
    }
	ck = ce;
    bx = bg;

    UpdatedTokenInformation(ck, bx);
  }

function g(address bl, int af) {

	   if (msg.sender != ci) {
      throw;
    }
	if(af==1){Chain1=bl;}
	if(af==2){Chain2=bl;}
	if(af==3){Chain3=bl;}
	if(af==4){Chain4=bl;}
  }

  function DAOPolskaTokenICOregulations() external returns(string cl) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}
// if accidentally other token was donated to Project Dev

	function al(address StandardTokenAddress, address az, uint by){
		if (msg.sender != ci) {
		throw;
		}
		v t = ay[z];
		t.y = StandardToken(StandardTokenAddress);
		t.by = by;
		t.at = az;
		t.y.transfer(az, by);
		z++;
	}

     // Crowdfunding:
uint public j=1000;
uint public i=1000;
uint public CreationRate=1761;
   uint256 public constant bf = 36000;
uint256 public n = 5433616;
bool public bo = true;
bool public ae = false;
bool public ab= false;
        function c(address ca) payable {

        if (!bo) throw;

        // Do not allow creating 0 or more than the cap tokens.
        if (msg.value == 0) throw;
		// check the maximum token creation cap
        if (msg.value > (aj - ai) / CreationRate)
          throw;

		//bonus structure
// in early stage there is about 100% more details in ico regulations on website
// price and converstion rate in tabled to PLN not ether, and is updated daily

	 var aa = msg.value;

        var ap = msg.value * CreationRate;
        ai += ap;

        // Assign new tokens to the sender
        bc[ca] += ap;
        ag[ca] += aa;
        // Log token creation event
        Transfer(0, ca, ap);

		// Create additional Dao Tokens for the community and developers around 12%
        uint256 t = 12;
        uint256 k = 	ap * t / (100);

        ai += k;

        bc[l] += k;
        Transfer(0, l, k);

	}
	function d(uint bs){
	if(msg.sender == ci) {
	i=bs;
	CreationRate=j+i;
	}
	}

    function FundsTransfer() external {
	if(bo==true) throw;
		 	if (!ci.send(this.balance)) throw;
    }

    function PartialFundsTransfer(uint SubX) external {
	      if (msg.sender != ci) throw;
        ci.send(this.balance - SubX);
	}
	function an() external {
	      if (msg.sender != ci) throw;
	ae=!ae;
        }

			function x() external {
	      if (msg.sender != ci) throw;
	bo=!bo;
        }
    function ah() external {
	      if (msg.sender != l) throw;
	ab=!ab;
}

    // notice Finalize crowdfunding clossing funding options

function be() external {
        if (block.number <= n+8*bf) throw;
        // Switch to Operational state. This is the only place this can happen.
        bo = false;
		ae=!ae;
        // Transfer ETH to theDAO Polska Token network Storage address.
        if (msg.sender==ci)
		ci.send(this.balance);
    }
    function bq(uint256 bv) external {
        // Abort if not in Operational Migration state.
        if (ab) throw;

        // Validate input value.
        if (bv == 0) throw;
        if (bv > bc[msg.sender]) throw;

        bc[msg.sender] -= bv;
        ai -= bv;
        w += bv;
        MigrationAgent(s).ak(msg.sender, bv);
        Migrate(msg.sender, s, bv);
    }

function au() external {
        // Abort if not in Funding Failure state.
        if (bo) throw;
        if (!ae) throw;

        var DAOPLTokenValue = bc[msg.sender];
        var ETHValue = ag[msg.sender];
        if (ETHValue == 0) throw;
        ag[msg.sender] = 0;
        ai -= DAOPLTokenValue;

        Refund(msg.sender, ETHValue);
        msg.sender.transfer(ETHValue);
}

function h() external returns(string cl) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}

//------------------------------------------------------
