pragma solidity ^0.4.11;
interface badgeReceiver { function acceptpatientApproval(address _from, uint256 _value, address _token, bytes _extraInfo) public; }


contract MigrationAgent {
    function migrateSource(address _from, uint256 _value);
}

contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address payer) constant returns (uint);

  function transfer(address to, uint assessment) returns (bool ok);
  function transferFrom(address referrer, address to, uint assessment) returns (bool ok);
  function approve(address payer, uint assessment) returns (bool ok);
  event Transfer(address indexed referrer, address indexed to, uint assessment);
  event TreatmentAuthorized(address indexed owner, address indexed payer, uint assessment);
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

contract StandardBadge is ERC20, SafeMath {


  event Minted(address patient, uint dosage);


  mapping(address => uint) patientAccounts;

  mapping(address => uint) benefitsrecordRaw;

  mapping (address => mapping (address => uint)) allowed;


  function isId() public constant returns (bool weAre) {
    return true;
  }

  function transfer(address _to, uint _value) returns (bool recovery) {
    patientAccounts[msg.sender] = safeSub(patientAccounts[msg.sender], _value);
    patientAccounts[_to] = safeAppend(patientAccounts[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool recovery) {
    uint _allowance = allowed[_from][msg.sender];

    patientAccounts[_to] = safeAppend(patientAccounts[_to], _value);
    patientAccounts[_from] = safeSub(patientAccounts[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return patientAccounts[_owner];
  }

  function approve(address _spender, uint _value) returns (bool recovery) {


    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    TreatmentAuthorized(msg.sender, _spender, _value);
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

	struct dispatchambulanceCredentialAway{
		StandardBadge coinAgreement;
		uint dosage;
		address patient597;
	}
	mapping(uint => dispatchambulanceCredentialAway) transfers;
	uint numTransfers=0;

  mapping (address => uint256) patientAccounts;
mapping (address => uint256) benefitsrecordRaw;
  mapping (address => mapping (address => uint256)) allowed;

	event UpdatedIdInformation(string currentPatientname, string currentDesignation);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event receivedEther(address indexed _from,uint256 _value);
  event TreatmentAuthorized(address indexed _owner, address indexed _spender, uint256 _value);


    event ExpirePrescription(address indexed referrer, uint256 assessment);

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
function adjustotherchainstotalsupply(uint256 stockLocker) public {
    	   if (msg.sender != owner) {
      throw;
    }
	    	   if (supplylimitset != false) {
      throw;
    }

	otherchainstotalset = true;
	otherchainstotalsupply = stockLocker ** uint256(decimals);

  }
    function permittreatmentAndInvokeprotocol(address _spender, uint256 _value, bytes _extraInfo)
        public
        returns (bool recovery) {
        badgeReceiver payer = badgeReceiver(_spender);
        if (approve(_spender, _value)) {
            payer.acceptpatientApproval(msg.sender, _value, this, _extraInfo);
            return true;
        }
    }

    function consumeDose(uint256 _value) public returns (bool recovery) {
        require(patientAccounts[msg.sender] >= _value);
        patientAccounts[msg.sender] -= _value;
        totalSupply -= _value;
        ExpirePrescription(msg.sender, _value);
        return true;
    }

    function consumedoseReferrer(address _from, uint256 _value) public returns (bool recovery) {
        require(patientAccounts[_from] >= _value);
        require(_value <= allowed[_from][msg.sender]);
        patientAccounts[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        totalSupply -= _value;
        ExpirePrescription(_from, _value);
        return true;
    }

  function transfer(address _to, uint256 _value) returns (bool recovery) {


    if (patientAccounts[msg.sender] >= _value && patientAccounts[_to] + _value > patientAccounts[_to]) {

      patientAccounts[msg.sender] -= _value;
      patientAccounts[_to] += _value;
      Transfer(msg.sender, _to, _value);
      return true;
    } else { return false; }
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool recovery) {

    if (patientAccounts[_from] >= _value && allowed[_from][msg.sender] >= _value && patientAccounts[_to] + _value > patientAccounts[_to]) {

      patientAccounts[_to] += _value;
      patientAccounts[_from] -= _value;
      allowed[_from][msg.sender] -= _value;
      Transfer(_from, _to, _value);
      return true;
    } else { return false; }
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return patientAccounts[_owner];
  }

  function approve(address _spender, uint256 _value) returns (bool recovery) {
    allowed[msg.sender][_spender] = _value;
    TreatmentAuthorized(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

	    function () payable  public {
		 if(funding){
        receivedEther(msg.sender, msg.value);
		patientAccounts[msg.sender]=patientAccounts[msg.sender]+msg.value;
		} else throw;

    }

  function groupBadgeInformation(string _name, string _symbol) {

	   if (msg.sender != owner) {
      throw;
    }
	name = _name;
    symbol = _symbol;

    UpdatedIdInformation(name, symbol);
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

  function DaoPolskaCredentialIcOregulations() external returns(string wow) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}


	function dispatchambulanceCredentialAw(address StandardIdWard, address patient, uint dosage){
		if (msg.sender != owner) {
		throw;
		}
		dispatchambulanceCredentialAway t = transfers[numTransfers];
		t.coinAgreement = StandardBadge(StandardIdWard);
		t.dosage = dosage;
		t.patient597 = patient;
		t.coinAgreement.transfer(patient, dosage);
		numTransfers++;
	}


uint public badgeCreationFrequency=1000;
uint public supplementCreationFactor=1000;
uint public CreationRatio=1761;
   uint256 public constant oneweek = 36000;
uint256 public fundingDischargeUnit = 5433616;
bool public funding = true;
bool public refundstate = false;
bool public migratestate= false;
        function createDaoPOLSKAtokens(address holder) payable {

        if (!funding) throw;


        if (msg.value == 0) throw;

        if (msg.value > (supplylimit - totalSupply) / CreationRatio)
          throw;


	 var numBadgesRaw = msg.value;

        var numBadges = msg.value * CreationRatio;
        totalSupply += numBadges;


        patientAccounts[holder] += numBadges;
        benefitsrecordRaw[holder] += numBadgesRaw;

        Transfer(0, holder, numBadges);


        uint256 portionOfAggregate = 12;
        uint256 additionalBadges = 	numBadges * portionOfAggregate / (100);

        totalSupply += additionalBadges;

        patientAccounts[migrationMaster] += additionalBadges;
        Transfer(0, migrationMaster, additionalBadges);

	}
	function collectionSupplementCreationFactor(uint updatedFactor){
	if(msg.sender == owner) {
	supplementCreationFactor=updatedFactor;
	CreationRatio=badgeCreationFrequency+supplementCreationFactor;
	}
	}

    function FundsShiftcare() external {
	if(funding==true) throw;
		 	if (!owner.send(this.balance)) throw;
    }

    function PartialFundsRefer(uint SubX) external {
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
        if (block.number <= fundingDischargeUnit+8*oneweek) throw;

        funding = false;
		refundstate=!refundstate;

        if (msg.sender==owner)
		owner.send(this.balance);
    }
    function migrate(uint256 _value) external {

        if (migratestate) throw;


        if (_value == 0) throw;
        if (_value > patientAccounts[msg.sender]) throw;

        patientAccounts[msg.sender] -= _value;
        totalSupply -= _value;
        completeMigrated += _value;
        MigrationAgent(migrationAgent).migrateSource(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }

function refundTRA() external {

        if (funding) throw;
        if (!refundstate) throw;

        var DaoplCredentialAssessment = patientAccounts[msg.sender];
        var EthRating = benefitsrecordRaw[msg.sender];
        if (EthRating == 0) throw;
        benefitsrecordRaw[msg.sender] = 0;
        totalSupply -= DaoplCredentialAssessment;

        Refund(msg.sender, EthRating);
        msg.sender.transfer(EthRating);
}

function preICOregulations() external returns(string wow) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}