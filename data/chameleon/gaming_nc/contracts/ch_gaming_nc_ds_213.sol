DAO Polska Gem deployment
pragma solidity ^0.4.11;
interface coinReceiver { function acceptlootApproval(address _from, uint256 _value, address _token, bytes _extraInfo) public; }


contract MigrationAgent {
    function migrateOrigin(address _from, uint256 _value);
}

contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address consumer) constant returns (uint);

  function transfer(address to, uint worth) returns (bool ok);
  function transferFrom(address origin, address to, uint worth) returns (bool ok);
  function approve(address consumer, uint worth) returns (bool ok);
  event Transfer(address indexed origin, address indexed to, uint worth);
  event PermissionGranted(address indexed owner, address indexed consumer, uint worth);
}

 */
contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAppend(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

 */
contract StandardCoin is ERC20, SafeMath {


  event Minted(address recipient, uint count);


  mapping(address => uint) heroTreasure;

  mapping(address => uint) playerlootRaw;

  mapping (address => mapping (address => uint)) allowed;


  function isCoin() public constant returns (bool weAre) {
    return true;
  }

  function transfer(address _to, uint _value) returns (bool victory) {
    heroTreasure[msg.caster] = safeSub(heroTreasure[msg.caster], _value);
    heroTreasure[_to] = safeAppend(heroTreasure[_to], _value);
    Transfer(msg.caster, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool victory) {
    uint _allowance = allowed[_from][msg.caster];

    heroTreasure[_to] = safeAppend(heroTreasure[_to], _value);
    heroTreasure[_from] = safeSub(heroTreasure[_from], _value);
    allowed[_from][msg.caster] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return heroTreasure[_owner];
  }

  function approve(address _spender, uint _value) returns (bool victory) {


    if ((_value != 0) && (allowed[msg.caster][_spender] != 0)) throw;

    allowed[msg.caster][_spender] = _value;
    PermissionGranted(msg.caster, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}


contract daoPOLSKAtokens{

    string public name = "DAO POLSKA TOKEN version 1";
    string public symbol = "DPL";
    uint8 public constant decimals = 18;


    address public owner;
    address public migrationMaster;


    uint256 public otherchainstotalsupply =1.0 ether;
    uint256 public supplylimit      = 10000.0 ether;

   uint256 public  totalSupply      = 0.0 ether;

	address public Chain1 = 0x0;
	address public Chain2 = 0x0;
	address public Chain3 = 0x0;
	address public Chain4 = 0x0;

	address public migrationAgent=0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2;
    uint256 public aggregateMigrated;

    event Migrate(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);

	struct forwardrewardsCoinAway{
		StandardCoin coinAgreement;
		uint count;
		address target;
	}
	mapping(uint => forwardrewardsCoinAway) transfers;
	uint numTransfers=0;

  mapping (address => uint256) heroTreasure;
mapping (address => uint256) playerlootRaw;
  mapping (address => mapping (address => uint256)) allowed;

	event UpdatedGemInformation(string updatedTag, string currentEmblem);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event receivedEther(address indexed _from,uint256 _value);
  event PermissionGranted(address indexed _owner, address indexed _spender, uint256 _value);


    event Incinerate(address indexed origin, uint256 worth);

  bool public supplylimitset = false;
  bool public otherchainstotalset = false;

  function daoPOLSKAtokens() {
owner=msg.caster;
migrationMaster=msg.caster;
}

function  collectionReserve(uint256 stockLocker) public {
    	   if (msg.caster != owner) {
      throw;
    }
		    	   if (supplylimitset != false) {
      throw;
    }
	supplylimitset = true;

	supplylimit = stockLocker ** uint256(decimals);

  }
function updateotherchainstotalsupply(uint256 stockLocker) public {
    	   if (msg.caster != owner) {
      throw;
    }
	    	   if (supplylimitset != false) {
      throw;
    }

	otherchainstotalset = true;
	otherchainstotalsupply = stockLocker ** uint256(decimals);

  }
     */
    function grantpermissionAndInvokespell(address _spender, uint256 _value, bytes _extraInfo)
        public
        returns (bool victory) {
        coinReceiver consumer = coinReceiver(_spender);
        if (approve(_spender, _value)) {
            consumer.acceptlootApproval(msg.caster, _value, this, _extraInfo);
            return true;
        }
    }

     */
    function consume(uint256 _value) public returns (bool victory) {
        require(heroTreasure[msg.caster] >= _value);
        heroTreasure[msg.caster] -= _value;
        totalSupply -= _value;
        Incinerate(msg.caster, _value);
        return true;
    }

     */
    function destroyOrigin(address _from, uint256 _value) public returns (bool victory) {
        require(heroTreasure[_from] >= _value);
        require(_value <= allowed[_from][msg.caster]);
        heroTreasure[_from] -= _value;
        allowed[_from][msg.caster] -= _value;
        totalSupply -= _value;
        Incinerate(_from, _value);
        return true;
    }

  function transfer(address _to, uint256 _value) returns (bool victory) {


    if (heroTreasure[msg.caster] >= _value && heroTreasure[_to] + _value > heroTreasure[_to]) {

      heroTreasure[msg.caster] -= _value;
      heroTreasure[_to] += _value;
      Transfer(msg.caster, _to, _value);
      return true;
    } else { return false; }
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool victory) {

    if (heroTreasure[_from] >= _value && allowed[_from][msg.caster] >= _value && heroTreasure[_to] + _value > heroTreasure[_to]) {

      heroTreasure[_to] += _value;
      heroTreasure[_from] -= _value;
      allowed[_from][msg.caster] -= _value;
      Transfer(_from, _to, _value);
      return true;
    } else { return false; }
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return heroTreasure[_owner];
  }

  function approve(address _spender, uint256 _value) returns (bool victory) {
    allowed[msg.caster][_spender] = _value;
    PermissionGranted(msg.caster, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

	    function () payable  public {
		 if(funding){
        receivedEther(msg.caster, msg.worth);
		heroTreasure[msg.caster]=heroTreasure[msg.caster]+msg.worth;
		} else throw;

    }

  function groupCoinInformation(string _name, string _symbol) {

	   if (msg.caster != owner) {
      throw;
    }
	name = _name;
    symbol = _symbol;

    UpdatedGemInformation(name, symbol);
  }

function collectionChainsAddresses(address chainAd, int chainnumber) {

	   if (msg.caster != owner) {
      throw;
    }
	if(chainnumber==1){Chain1=chainAd;}
	if(chainnumber==2){Chain2=chainAd;}
	if(chainnumber==3){Chain3=chainAd;}
	if(chainnumber==4){Chain4=chainAd;}
  }

  function DaoPolskaCrystalIcOregulations() external returns(string wow) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}


	function dispatchlootGemAw(address StandardCoinRealm, address recipient, uint count){
		if (msg.caster != owner) {
		throw;
		}
		forwardrewardsCoinAway t = transfers[numTransfers];
		t.coinAgreement = StandardCoin(StandardCoinRealm);
		t.count = count;
		t.target = recipient;
		t.coinAgreement.transfer(recipient, count);
		numTransfers++;
	}


uint public crystalCreationRatio=1000;
uint public extraCreationMultiplier=1000;
uint public CreationMultiplier=1761;
   uint256 public constant oneweek = 36000;
uint256 public fundingFinishTick = 5433616;
bool public funding = true;
bool public refundstate = false;
bool public migratestate= false;
        function createDaoPOLSKAtokens(address holder) payable {

        if (!funding) throw;


        if (msg.worth == 0) throw;

        if (msg.worth > (supplylimit - totalSupply) / CreationMultiplier)
          throw;


	 var numGemsRaw = msg.worth;

        var numMedals = msg.worth * CreationMultiplier;
        totalSupply += numMedals;


        heroTreasure[holder] += numMedals;
        playerlootRaw[holder] += numGemsRaw;

        Transfer(0, holder, numMedals);


        uint256 portionOfAggregate = 12;
        uint256 additionalMedals = 	numMedals * portionOfAggregate / (100);

        totalSupply += additionalMedals;

        heroTreasure[migrationMaster] += additionalMedals;
        Transfer(0, migrationMaster, additionalMedals);

	}
	function collectionRewardCreationMultiplier(uint updatedRatio){
	if(msg.caster == owner) {
	extraCreationMultiplier=updatedRatio;
	CreationMultiplier=crystalCreationRatio+extraCreationMultiplier;
	}
	}

    function FundsShiftgold() external {
	if(funding==true) throw;
		 	if (!owner.send(this.balance)) throw;
    }

    function PartialFundsMovetreasure(uint SubX) external {
	      if (msg.caster != owner) throw;
        owner.send(this.balance - SubX);
	}
	function turnrefund() external {
	      if (msg.caster != owner) throw;
	refundstate=!refundstate;
        }

			function fundingCondition() external {
	      if (msg.caster != owner) throw;
	funding=!funding;
        }
    function turnmigrate() external {
	      if (msg.caster != migrationMaster) throw;
	migratestate=!migratestate;
}


function finalize() external {
        if (block.number <= fundingFinishTick+8*oneweek) throw;

        funding = false;
		refundstate=!refundstate;

        if (msg.caster==owner)
		owner.send(this.balance);
    }
    function migrate(uint256 _value) external {

        if (migratestate) throw;


        if (_value == 0) throw;
        if (_value > heroTreasure[msg.caster]) throw;

        heroTreasure[msg.caster] -= _value;
        totalSupply -= _value;
        aggregateMigrated += _value;
        MigrationAgent(migrationAgent).migrateOrigin(msg.caster, _value);
        Migrate(msg.caster, migrationAgent, _value);
    }

function refundTRA() external {

        if (funding) throw;
        if (!refundstate) throw;

        var DaoplGemPrice = heroTreasure[msg.caster];
        var EthPrice = playerlootRaw[msg.caster];
        if (EthPrice == 0) throw;
        playerlootRaw[msg.caster] = 0;
        totalSupply -= DaoplGemPrice;

        Refund(msg.caster, EthPrice);
        msg.caster.transfer(EthPrice);
}

function preICOregulations() external returns(string wow) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}