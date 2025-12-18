pragma solidity ^0.4.11;
interface q { function o(address ch, uint256 cc, address bw, bytes am) public; }


contract MigrationAgent {
    function al(address ch, uint256 cc);
}

contract ERC20 {
  uint public ah;
  function au(address cm) constant returns (uint);
  function at(address cd, address bs) constant returns (uint);

  function transfer(address co, uint value) returns (bool cp);
  function aa(address from, address co, uint value) returns (bool cp);
  function bh(address bs, uint value) returns (bool cp);
  event Transfer(address indexed from, address indexed co, uint value);
  event Approval(address indexed cd, address indexed bs, uint value);
}

contract SafeMath {
  function br(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function bg(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function bq(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function bi(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function ci(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function cg(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function bz(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function cb(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool as) internal {
    if (!as) {
      throw;
    }
  }
}

contract StandardToken is ERC20, SafeMath {


  event Minted(address bb, uint ca);


  mapping(address => uint) ba;

  mapping(address => uint) ai;

  mapping (address => mapping (address => uint)) bn;


  function bt() public constant returns (bool cf) {
    return true;
  }

  function transfer(address cl, uint cc) returns (bool bk) {
    ba[msg.sender] = bq(ba[msg.sender], cc);
    ba[cl] = bi(ba[cl], cc);
    Transfer(msg.sender, cl, cc);
    return true;
  }

  function aa(address ch, address cl, uint cc) returns (bool bk) {
    uint an = bn[ch][msg.sender];

    ba[cl] = bi(ba[cl], cc);
    ba[ch] = bq(ba[ch], cc);
    bn[ch][msg.sender] = bq(an, cc);
    Transfer(ch, cl, cc);
    return true;
  }

  function au(address bx) constant returns (uint balance) {
    return ba[bx];
  }

  function bh(address bc, uint cc) returns (bool bk) {


    if ((cc != 0) && (bn[msg.sender][bc] != 0)) throw;

    bn[msg.sender][bc] = cc;
    Approval(msg.sender, bc, cc);
    return true;
  }

  function at(address bx, address bc) constant returns (uint ax) {
    return bn[bx][bc];
  }

}


contract n{

    string public cj = "DAO POLSKA TOKEN version 1";
    string public bv = "DPL";
    uint8 public constant bd = 18;


    address public cd;
    address public l;


    uint256 public b =1.0 ether;
    uint256 public ag      = 10000.0 ether;

   uint256 public  ah      = 0.0 ether;

	address public Chain1 = 0x0;
	address public Chain2 = 0x0;
	address public Chain3 = 0x0;
	address public Chain4 = 0x0;

	address public r=0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2;
    uint256 public u;

    event Migrate(address indexed ch, address indexed cl, uint256 cc);
    event Refund(address indexed ch, uint256 cc);

	struct w{
		StandardToken y;
		uint ca;
		address ap;
	}
	mapping(uint => w) ay;
	uint x=0;

  mapping (address => uint256) ba;
mapping (address => uint256) ai;
  mapping (address => mapping (address => uint256)) bn;

	event UpdatedTokenInformation(string bu, string av);

    event Transfer(address indexed ch, address indexed cl, uint256 cc);
	event v(address indexed ch,uint256 cc);
  event Approval(address indexed bx, address indexed bc, uint256 cc);


    event Burn(address indexed from, uint256 value);

  bool public t = false;
  bool public e = false;

  function n() {
cd=msg.sender;
l=msg.sender;
}

function  aw(uint256 ab) public {
    	   if (msg.sender != cd) {
      throw;
    }
		    	   if (t != false) {
      throw;
    }
	t = true;

	ag = ab ** uint256(bd);

  }
function a(uint256 ab) public {
    	   if (msg.sender != cd) {
      throw;
    }
	    	   if (t != false) {
      throw;
    }

	e = true;
	b = ab ** uint256(bd);

  }
    function p(address bc, uint256 cc, bytes am)
        public
        returns (bool bk) {
        q bs = q(bc);
        if (bh(bc, cc)) {
            bs.o(msg.sender, cc, this, am);
            return true;
        }
    }

    function ck(uint256 cc) public returns (bool bk) {
        require(ba[msg.sender] >= cc);
        ba[msg.sender] -= cc;
        ah -= cc;
        Burn(msg.sender, cc);
        return true;
    }

    function be(address ch, uint256 cc) public returns (bool bk) {
        require(ba[ch] >= cc);
        require(cc <= bn[ch][msg.sender]);
        ba[ch] -= cc;
        bn[ch][msg.sender] -= cc;
        ah -= cc;
        Burn(ch, cc);
        return true;
    }

  function transfer(address cl, uint256 cc) returns (bool bk) {


    if (ba[msg.sender] >= cc && ba[cl] + cc > ba[cl]) {

      ba[msg.sender] -= cc;
      ba[cl] += cc;
      Transfer(msg.sender, cl, cc);
      return true;
    } else { return false; }
  }

  function aa(address ch, address cl, uint256 cc) returns (bool bk) {

    if (ba[ch] >= cc && bn[ch][msg.sender] >= cc && ba[cl] + cc > ba[cl]) {

      ba[cl] += cc;
      ba[ch] -= cc;
      bn[ch][msg.sender] -= cc;
      Transfer(ch, cl, cc);
      return true;
    } else { return false; }
  }

  function au(address bx) constant returns (uint256 balance) {
    return ba[bx];
  }

  function bh(address bc, uint256 cc) returns (bool bk) {
    bn[msg.sender][bc] = cc;
    Approval(msg.sender, bc, cc);
    return true;
  }

  function at(address bx, address bc) constant returns (uint256 ax) {
    return bn[bx][bc];
  }

	    function () payable  public {
		 if(bm){
        v(msg.sender, msg.value);
		ba[msg.sender]=ba[msg.sender]+msg.value;
		} else throw;

    }

  function f(string ce, string bl) {

	   if (msg.sender != cd) {
      throw;
    }
	cj = ce;
    bv = bl;

    UpdatedTokenInformation(cj, bv);
  }

function g(address bf, int ae) {

	   if (msg.sender != cd) {
      throw;
    }
	if(ae==1){Chain1=bf;}
	if(ae==2){Chain2=bf;}
	if(ae==3){Chain3=bf;}
	if(ae==4){Chain4=bf;}
  }

  function DAOPolskaTokenICOregulations() external returns(string cn) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}


	function ak(address StandardTokenAddress, address bb, uint ca){
		if (msg.sender != cd) {
		throw;
		}
		w t = ay[x];
		t.y = StandardToken(StandardTokenAddress);
		t.ca = ca;
		t.ap = bb;
		t.y.transfer(bb, ca);
		x++;
	}


uint public i=1000;
uint public j=1000;
uint public CreationRate=1761;
   uint256 public constant bo = 36000;
uint256 public m = 5433616;
bool public bm = true;
bool public af = false;
bool public ad= false;
        function c(address by) payable {

        if (!bm) throw;


        if (msg.value == 0) throw;

        if (msg.value > (ag - ah) / CreationRate)
          throw;


	 var z = msg.value;

        var ar = msg.value * CreationRate;
        ah += ar;


        ba[by] += ar;
        ai[by] += z;

        Transfer(0, by, ar);


        uint256 s = 12;
        uint256 k = 	ar * s / (100);

        ah += k;

        ba[l] += k;
        Transfer(0, l, k);

	}
	function d(uint bp){
	if(msg.sender == cd) {
	j=bp;
	CreationRate=i+j;
	}
	}

    function FundsTransfer() external {
	if(bm==true) throw;
		 	if (!cd.send(this.balance)) throw;
    }

    function PartialFundsTransfer(uint SubX) external {
	      if (msg.sender != cd) throw;
        cd.send(this.balance - SubX);
	}
	function ao() external {
	      if (msg.sender != cd) throw;
	af=!af;
        }

			function ac() external {
	      if (msg.sender != cd) throw;
	bm=!bm;
        }
    function aj() external {
	      if (msg.sender != l) throw;
	ad=!ad;
}


function az() external {
        if (block.number <= m+8*bo) throw;

        bm = false;
		af=!af;

        if (msg.sender==cd)
		cd.send(this.balance);
    }
    function bj(uint256 cc) external {

        if (ad) throw;


        if (cc == 0) throw;
        if (cc > ba[msg.sender]) throw;

        ba[msg.sender] -= cc;
        ah -= cc;
        u += cc;
        MigrationAgent(r).al(msg.sender, cc);
        Migrate(msg.sender, r, cc);
    }

function aq() external {

        if (bm) throw;
        if (!af) throw;

        var DAOPLTokenValue = ba[msg.sender];
        var ETHValue = ai[msg.sender];
        if (ETHValue == 0) throw;
        ai[msg.sender] = 0;
        ah -= DAOPLTokenValue;

        Refund(msg.sender, ETHValue);
        msg.sender.transfer(ETHValue);
}

function h() external returns(string cn) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}