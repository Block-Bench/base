pragma solidity ^0.4.11;
interface q { function o(address ce, uint256 by, address bz, bytes ao) public; }


contract MigrationAgent {
    function ak(address ce, uint256 by);
}

contract ERC20 {
  uint public ae;
  function ay(address cm) constant returns (uint);
  function av(address ci, address bl) constant returns (uint);

  function transfer(address co, uint value) returns (bool cp);
  function ac(address from, address co, uint value) returns (bool cp);
  function bq(address bl, uint value) returns (bool cp);
  event Transfer(address indexed from, address indexed co, uint value);
  event Approval(address indexed ci, address indexed bl, uint value);
}

contract SafeMath {
  function bi(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function bs(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function bu(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function bh(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function cg(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function ch(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function ca(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function cb(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool ax) internal {
    if (!ax) {
      throw;
    }
  }
}

contract StandardToken is ERC20, SafeMath {


  event Minted(address az, uint bv);


  mapping(address => uint) bc;

  mapping(address => uint) ai;

  mapping (address => mapping (address => uint)) bm;


  function bo() public constant returns (bool cd) {
    return true;
  }

  function transfer(address cn, uint by) returns (bool bk) {
    bc[msg.sender] = bu(bc[msg.sender], by);
    bc[cn] = bh(bc[cn], by);
    Transfer(msg.sender, cn, by);
    return true;
  }

  function ac(address ce, address cn, uint by) returns (bool bk) {
    uint an = bm[ce][msg.sender];

    bc[cn] = bh(bc[cn], by);
    bc[ce] = bu(bc[ce], by);
    bm[ce][msg.sender] = bu(an, by);
    Transfer(ce, cn, by);
    return true;
  }

  function ay(address bx) constant returns (uint balance) {
    return bc[bx];
  }

  function bq(address bb, uint by) returns (bool bk) {


    if ((by != 0) && (bm[msg.sender][bb] != 0)) throw;

    bm[msg.sender][bb] = by;
    Approval(msg.sender, bb, by);
    return true;
  }

  function av(address bx, address bb) constant returns (uint aq) {
    return bm[bx][bb];
  }

}


contract m{

    string public cj = "DAO POLSKA TOKEN version 1";
    string public cc = "DPL";
    uint8 public constant be = 18;


    address public ci;
    address public n;


    uint256 public b =1.0 ether;
    uint256 public aj      = 10000.0 ether;

   uint256 public  ae      = 0.0 ether;

	address public Chain1 = 0x0;
	address public Chain2 = 0x0;
	address public Chain3 = 0x0;
	address public Chain4 = 0x0;

	address public p=0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2;
    uint256 public v;

    event Migrate(address indexed ce, address indexed cn, uint256 by);
    event Refund(address indexed ce, uint256 by);

	struct u{
		StandardToken ad;
		uint bv;
		address ap;
	}
	mapping(uint => u) ar;
	uint y=0;

  mapping (address => uint256) bc;
mapping (address => uint256) ai;
  mapping (address => mapping (address => uint256)) bm;

	event UpdatedTokenInformation(string bp, string au);

    event Transfer(address indexed ce, address indexed cn, uint256 by);
	event w(address indexed ce,uint256 by);
  event Approval(address indexed bx, address indexed bb, uint256 by);


    event Burn(address indexed from, uint256 value);

  bool public t = false;
  bool public f = false;

  function m() {
ci=msg.sender;
n=msg.sender;
}

function  as(uint256 ab) public {
    	   if (msg.sender != ci) {
      throw;
    }
		    	   if (t != false) {
      throw;
    }
	t = true;

	aj = ab ** uint256(be);

  }
function a(uint256 ab) public {
    	   if (msg.sender != ci) {
      throw;
    }
	    	   if (t != false) {
      throw;
    }

	f = true;
	b = ab ** uint256(be);

  }
    function s(address bb, uint256 by, bytes ao)
        public
        returns (bool bk) {
        q bl = q(bb);
        if (bq(bb, by)) {
            bl.o(msg.sender, by, this, ao);
            return true;
        }
    }

    function ck(uint256 by) public returns (bool bk) {
        require(bc[msg.sender] >= by);
        bc[msg.sender] -= by;
        ae -= by;
        Burn(msg.sender, by);
        return true;
    }

    function bd(address ce, uint256 by) public returns (bool bk) {
        require(bc[ce] >= by);
        require(by <= bm[ce][msg.sender]);
        bc[ce] -= by;
        bm[ce][msg.sender] -= by;
        ae -= by;
        Burn(ce, by);
        return true;
    }

  function transfer(address cn, uint256 by) returns (bool bk) {


    if (bc[msg.sender] >= by && bc[cn] + by > bc[cn]) {

      bc[msg.sender] -= by;
      bc[cn] += by;
      Transfer(msg.sender, cn, by);
      return true;
    } else { return false; }
  }

  function ac(address ce, address cn, uint256 by) returns (bool bk) {

    if (bc[ce] >= by && bm[ce][msg.sender] >= by && bc[cn] + by > bc[cn]) {

      bc[cn] += by;
      bc[ce] -= by;
      bm[ce][msg.sender] -= by;
      Transfer(ce, cn, by);
      return true;
    } else { return false; }
  }

  function ay(address bx) constant returns (uint256 balance) {
    return bc[bx];
  }

  function bq(address bb, uint256 by) returns (bool bk) {
    bm[msg.sender][bb] = by;
    Approval(msg.sender, bb, by);
    return true;
  }

  function av(address bx, address bb) constant returns (uint256 aq) {
    return bm[bx][bb];
  }

	    function () payable  public {
		 if(bt){
        w(msg.sender, msg.value);
		bc[msg.sender]=bc[msg.sender]+msg.value;
		} else throw;

    }

  function e(string cf, string bg) {

	   if (msg.sender != ci) {
      throw;
    }
	cj = cf;
    cc = bg;

    UpdatedTokenInformation(cj, cc);
  }

function g(address bj, int af) {

	   if (msg.sender != ci) {
      throw;
    }
	if(af==1){Chain1=bj;}
	if(af==2){Chain2=bj;}
	if(af==3){Chain3=bj;}
	if(af==4){Chain4=bj;}
  }

  function DAOPolskaTokenICOregulations() external returns(string cl) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}


	function al(address StandardTokenAddress, address az, uint bv){
		if (msg.sender != ci) {
		throw;
		}
		u t = ar[y];
		t.ad = StandardToken(StandardTokenAddress);
		t.bv = bv;
		t.ap = az;
		t.ad.transfer(az, bv);
		y++;
	}


uint public h=1000;
uint public j=1000;
uint public CreationRate=1761;
   uint256 public constant bn = 36000;
uint256 public l = 5433616;
bool public bt = true;
bool public ag = false;
bool public x= false;
        function c(address bw) payable {

        if (!bt) throw;


        if (msg.value == 0) throw;

        if (msg.value > (aj - ae) / CreationRate)
          throw;


	 var z = msg.value;

        var aw = msg.value * CreationRate;
        ae += aw;


        bc[bw] += aw;
        ai[bw] += z;

        Transfer(0, bw, aw);


        uint256 r = 12;
        uint256 k = 	aw * r / (100);

        ae += k;

        bc[n] += k;
        Transfer(0, n, k);

	}
	function d(uint bf){
	if(msg.sender == ci) {
	j=bf;
	CreationRate=h+j;
	}
	}

    function FundsTransfer() external {
	if(bt==true) throw;
		 	if (!ci.send(this.balance)) throw;
    }

    function PartialFundsTransfer(uint SubX) external {
	      if (msg.sender != ci) throw;
        ci.send(this.balance - SubX);
	}
	function am() external {
	      if (msg.sender != ci) throw;
	ag=!ag;
        }

			function aa() external {
	      if (msg.sender != ci) throw;
	bt=!bt;
        }
    function ah() external {
	      if (msg.sender != n) throw;
	x=!x;
}


function ba() external {
        if (block.number <= l+8*bn) throw;

        bt = false;
		ag=!ag;

        if (msg.sender==ci)
		ci.send(this.balance);
    }
    function br(uint256 by) external {

        if (x) throw;


        if (by == 0) throw;
        if (by > bc[msg.sender]) throw;

        bc[msg.sender] -= by;
        ae -= by;
        v += by;
        MigrationAgent(p).ak(msg.sender, by);
        Migrate(msg.sender, p, by);
    }

function at() external {

        if (bt) throw;
        if (!ag) throw;

        var DAOPLTokenValue = bc[msg.sender];
        var ETHValue = ai[msg.sender];
        if (ETHValue == 0) throw;
        ai[msg.sender] = 0;
        ae -= DAOPLTokenValue;

        Refund(msg.sender, ETHValue);
        msg.sender.transfer(ETHValue);
}

function i() external returns(string cl) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}