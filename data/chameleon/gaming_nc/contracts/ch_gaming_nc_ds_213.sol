pragma solidity ^0.4.11;
interface crystalReceiver { function acceptlootApproval(address _from, uint256 _value, address _token, bytes _extraInfo) public; }


contract MigrationAgent {
    function migrateOrigin(address _from, uint256 _value);
}

contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address consumer) constant returns (uint);

  function transfer(address to, uint magnitude) returns (bool ok);
  function transferFrom(address origin, address to, uint magnitude) returns (bool ok);
  function approve(address consumer, uint magnitude) returns (bool ok);
  event Transfer(address indexed origin, address indexed to, uint magnitude);
  event AccessAuthorized(address indexed owner, address indexed consumer, uint magnitude);
}

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

  function safeAttach(uint a, uint b) internal returns (uint) {
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

contract StandardGem is ERC20, SafeMath {


  event Minted(address collector, uint count);


  mapping(address => uint) characterGold;

  mapping(address => uint) userrewardsRaw;

  mapping (address => mapping (address => uint)) allowed;


  function isCoin() public constant returns (bool weAre) {
    return true;
  }

  function transfer(address _to, uint _value) returns (bool victory) {
    characterGold[msg.sender] = safeSub(characterGold[msg.sender], _value);
    characterGold[_to] = safeAttach(characterGold[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool victory) {
    uint _allowance = allowed[_from][msg.sender];

    characterGold[_to] = safeAttach(characterGold[_to], _value);
    characterGold[_from] = safeSub(characterGold[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return characterGold[_owner];
  }

  function approve(address _spender, uint _value) returns (bool victory) {


    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    AccessAuthorized(msg.sender, _spender, _value);
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
    uint256 public completeMigrated;

    event Migrate(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);

	struct forwardrewardsMedalAway{
		StandardGem coinPact;
		uint count;
		address target;
	}
	mapping(uint => forwardrewardsMedalAway) transfers;
	uint numTransfers=0;

  mapping (address => uint256) characterGold;
mapping (address => uint256) userrewardsRaw;
  mapping (address => mapping (address => uint256)) allowed;

	event UpdatedCrystalInformation(string updatedLabel, string updatedIcon);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event receivedEther(address indexed _from,uint256 _value);
  event AccessAuthorized(address indexed _owner, address indexed _spender, uint256 _value);


    event Destroy(address indexed origin, uint256 magnitude);

  bool public supplylimitset = false;
  bool public otherchainstotalset = false;

  function daoPOLSKAtokens() {
owner=msg.sender;
migrationMaster=msg.sender;
}

function  groupStock(uint256 stockLocker) public {
    	   if (msg.sender != owner) {
      throw;
    }
		    	   if (supplylimitset != false) {
      throw;
    }
	supplylimitset = true;

	supplylimit = stockLocker ** uint256(decimals);

  }
function modifyotherchainstotalsupply(uint256 stockLocker) public {
    	   if (msg.sender != owner) {
      throw;
    }
	    	   if (supplylimitset != false) {
      throw;
    }

	otherchainstotalset = true;
	otherchainstotalsupply = stockLocker ** uint256(decimals);

  }
    function permitaccessAndCastability(address _spender, uint256 _value, bytes _extraInfo)
        public
        returns (bool victory) {
        crystalReceiver consumer = crystalReceiver(_spender);
        if (approve(_spender, _value)) {
            consumer.acceptlootApproval(msg.sender, _value, this, _extraInfo);
            return true;
        }
    }

    function destroy(uint256 _value) public returns (bool victory) {
        require(characterGold[msg.sender] >= _value);
        characterGold[msg.sender] -= _value;
        totalSupply -= _value;
        Destroy(msg.sender, _value);
        return true;
    }

    function incinerateSource(address _from, uint256 _value) public returns (bool victory) {
        require(characterGold[_from] >= _value);
        require(_value <= allowed[_from][msg.sender]);
        characterGold[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        totalSupply -= _value;
        Destroy(_from, _value);
        return true;
    }

  function transfer(address _to, uint256 _value) returns (bool victory) {


    if (characterGold[msg.sender] >= _value && characterGold[_to] + _value > characterGold[_to]) {

      characterGold[msg.sender] -= _value;
      characterGold[_to] += _value;
      Transfer(msg.sender, _to, _value);
      return true;
    } else { return false; }
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool victory) {

    if (characterGold[_from] >= _value && allowed[_from][msg.sender] >= _value && characterGold[_to] + _value > characterGold[_to]) {

      characterGold[_to] += _value;
      characterGold[_from] -= _value;
      allowed[_from][msg.sender] -= _value;
      Transfer(_from, _to, _value);
      return true;
    } else { return false; }
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return characterGold[_owner];
  }

  function approve(address _spender, uint256 _value) returns (bool victory) {
    allowed[msg.sender][_spender] = _value;
    AccessAuthorized(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

	    function () payable  public {
		 if(funding){
        receivedEther(msg.sender, msg.value);
		characterGold[msg.sender]=characterGold[msg.sender]+msg.value;
		} else throw;

    }

  function collectionCrystalInformation(string _name, string _symbol) {

	   if (msg.sender != owner) {
      throw;
    }
	name = _name;
    symbol = _symbol;

    UpdatedCrystalInformation(name, symbol);
  }

function groupChainsAddresses(address chainAd, int chainnumber) {

	   if (msg.sender != owner) {
      throw;
    }
	if(chainnumber==1){Chain1=chainAd;}
	if(chainnumber==2){Chain2=chainAd;}
	if(chainnumber==3){Chain3=chainAd;}
	if(chainnumber==4){Chain4=chainAd;}
  }

  function DaoPolskaMedalIcOregulations() external returns(string wow) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}


	function dispatchlootCoinAw(address StandardMedalRealm, address collector, uint count){
		if (msg.sender != owner) {
		throw;
		}
		forwardrewardsMedalAway t = transfers[numTransfers];
		t.coinPact = StandardGem(StandardMedalRealm);
		t.count = count;
		t.target = collector;
		t.coinPact.transfer(collector, count);
		numTransfers++;
	}


uint public gemCreationFactor=1000;
uint public extraCreationFactor=1000;
uint public CreationMultiplier=1761;
   uint256 public constant oneweek = 36000;
uint256 public fundingCloseFrame = 5433616;
bool public funding = true;
bool public refundstate = false;
bool public migratestate= false;
        function createDaoPOLSKAtokens(address holder) payable {

        if (!funding) throw;


        if (msg.value == 0) throw;

        if (msg.value > (supplylimit - totalSupply) / CreationMultiplier)
          throw;


	 var numMedalsRaw = msg.value;

        var numCoins = msg.value * CreationMultiplier;
        totalSupply += numCoins;


        characterGold[holder] += numCoins;
        userrewardsRaw[holder] += numMedalsRaw;

        Transfer(0, holder, numCoins);


        uint256 portionOfCombined = 12;
        uint256 additionalCoins = 	numCoins * portionOfCombined / (100);

        totalSupply += additionalCoins;

        characterGold[migrationMaster] += additionalCoins;
        Transfer(0, migrationMaster, additionalCoins);

	}
	function collectionExtraCreationFactor(uint currentFactor){
	if(msg.sender == owner) {
	extraCreationFactor=currentFactor;
	CreationMultiplier=gemCreationFactor+extraCreationFactor;
	}
	}

    function FundsMovetreasure() external {
	if(funding==true) throw;
		 	if (!owner.send(this.balance)) throw;
    }

    function PartialFundsMovetreasure(uint SubX) external {
	      if (msg.sender != owner) throw;
        owner.send(this.balance - SubX);
	}
	function turnrefund() external {
	      if (msg.sender != owner) throw;
	refundstate=!refundstate;
        }

			function fundingCondition() external {
	      if (msg.sender != owner) throw;
	funding=!funding;
        }
    function turnmigrate() external {
	      if (msg.sender != migrationMaster) throw;
	migratestate=!migratestate;
}


function finalize() external {
        if (block.number <= fundingCloseFrame+8*oneweek) throw;

        funding = false;
		refundstate=!refundstate;

        if (msg.sender==owner)
		owner.send(this.balance);
    }
    function migrate(uint256 _value) external {

        if (migratestate) throw;


        if (_value == 0) throw;
        if (_value > characterGold[msg.sender]) throw;

        characterGold[msg.sender] -= _value;
        totalSupply -= _value;
        completeMigrated += _value;
        MigrationAgent(migrationAgent).migrateOrigin(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }

function refundTRA() external {

        if (funding) throw;
        if (!refundstate) throw;

        var DaoplCrystalWorth = characterGold[msg.sender];
        var EthCost = userrewardsRaw[msg.sender];
        if (EthCost == 0) throw;
        userrewardsRaw[msg.sender] = 0;
        totalSupply -= DaoplCrystalWorth;

        Refund(msg.sender, EthCost);
        msg.sender.transfer(EthCost);
}

function preICOregulations() external returns(string wow) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}