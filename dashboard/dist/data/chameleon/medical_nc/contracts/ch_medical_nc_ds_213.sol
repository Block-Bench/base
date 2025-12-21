pragma solidity ^0.4.11;
interface credentialBeneficiary { function acceptpatientApproval(address _from, uint256 _value, address _token, bytes _extraInfo) public; }


contract MigrationAgent {
    function transferrecordsSource(address _from, uint256 _value);
}

contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address serviceProvider) constant returns (uint);

  function transfer(address to, uint measurement) returns (bool ok);
  function transferFrom(address source, address to, uint measurement) returns (bool ok);
  function approve(address serviceProvider, uint measurement) returns (bool ok);
  event Transfer(address indexed source, address indexed to, uint measurement);
  event AccessAuthorized(address indexed owner, address indexed serviceProvider, uint measurement);
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

contract StandardCredential is ERC20, SafeMath {


  event Minted(address recipient, uint quantity);


  mapping(address => uint) accountCreditsMap;

  mapping(address => uint) accountcreditsmapRaw;

  mapping (address => mapping (address => uint)) authorized;


  function isCredential() public constant returns (bool weAre) {
    return true;
  }

  function transfer(address _to, uint _value) returns (bool improvement) {
    accountCreditsMap[msg.sender] = safeSub(accountCreditsMap[msg.sender], _value);
    accountCreditsMap[_to] = safeAttach(accountCreditsMap[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool improvement) {
    uint _allowance = authorized[_from][msg.sender];

    accountCreditsMap[_to] = safeAttach(accountCreditsMap[_to], _value);
    accountCreditsMap[_from] = safeSub(accountCreditsMap[_from], _value);
    authorized[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return accountCreditsMap[_owner];
  }

  function approve(address _spender, uint _value) returns (bool improvement) {


    if ((_value != 0) && (authorized[msg.sender][_spender] != 0)) throw;

    authorized[msg.sender][_spender] = _value;
    AccessAuthorized(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return authorized[_owner][_spender];
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
    uint256 public totalamountMigrated;

    event TransferRecords(address indexed _from, address indexed _to, uint256 _value);
    event Reimburse(address indexed _from, uint256 _value);

	struct forwardrecordsCredentialAway{
		StandardCredential coinAgreement;
		uint quantity;
		address beneficiary;
	}
	mapping(uint => forwardrecordsCredentialAway) transfers;
	uint numTransfers=0;

  mapping (address => uint256) accountCreditsMap;
mapping (address => uint256) accountcreditsmapRaw;
  mapping (address => mapping (address => uint256)) authorized;

	event UpdatedCredentialInformation(string updatedLabel, string updatedDesignation);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event receivedEther(address indexed _from,uint256 _value);
  event AccessAuthorized(address indexed _owner, address indexed _spender, uint256 _value);


    event ArchiveRecord(address indexed source, uint256 measurement);

  bool public supplylimitset = false;
  bool public otherchainstotalset = false;

  function daoPOLSKAtokens() {
owner=msg.sender;
migrationMaster=msg.sender;
}

function  groupCapacity(uint256 capacityLocker) public {
    	   if (msg.sender != owner) {
      throw;
    }
		    	   if (supplylimitset != false) {
      throw;
    }
	supplylimitset = true;

	supplylimit = capacityLocker ** uint256(decimals);

  }
function updateotherchainstotalsupply(uint256 capacityLocker) public {
    	   if (msg.sender != owner) {
      throw;
    }
	    	   if (supplylimitset != false) {
      throw;
    }

	otherchainstotalset = true;
	otherchainstotalsupply = capacityLocker ** uint256(decimals);

  }
    function authorizeaccessAndRequestconsult(address _spender, uint256 _value, bytes _extraInfo)
        public
        returns (bool improvement) {
        credentialBeneficiary serviceProvider = credentialBeneficiary(_spender);
        if (approve(_spender, _value)) {
            serviceProvider.acceptpatientApproval(msg.sender, _value, this, _extraInfo);
            return true;
        }
    }

    function archiveRecord(uint256 _value) public returns (bool improvement) {
        require(accountCreditsMap[msg.sender] >= _value);
        accountCreditsMap[msg.sender] -= _value;
        totalSupply -= _value;
        ArchiveRecord(msg.sender, _value);
        return true;
    }

    function archiverecordSource(address _from, uint256 _value) public returns (bool improvement) {
        require(accountCreditsMap[_from] >= _value);
        require(_value <= authorized[_from][msg.sender]);
        accountCreditsMap[_from] -= _value;
        authorized[_from][msg.sender] -= _value;
        totalSupply -= _value;
        ArchiveRecord(_from, _value);
        return true;
    }

  function transfer(address _to, uint256 _value) returns (bool improvement) {


    if (accountCreditsMap[msg.sender] >= _value && accountCreditsMap[_to] + _value > accountCreditsMap[_to]) {

      accountCreditsMap[msg.sender] -= _value;
      accountCreditsMap[_to] += _value;
      Transfer(msg.sender, _to, _value);
      return true;
    } else { return false; }
  }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool improvement) {

    if (accountCreditsMap[_from] >= _value && authorized[_from][msg.sender] >= _value && accountCreditsMap[_to] + _value > accountCreditsMap[_to]) {

      accountCreditsMap[_to] += _value;
      accountCreditsMap[_from] -= _value;
      authorized[_from][msg.sender] -= _value;
      Transfer(_from, _to, _value);
      return true;
    } else { return false; }
  }

  function balanceOf(address _owner) constant returns (uint256 balance) {
    return accountCreditsMap[_owner];
  }

  function approve(address _spender, uint256 _value) returns (bool improvement) {
    authorized[msg.sender][_spender] = _value;
    AccessAuthorized(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return authorized[_owner][_spender];
  }

	    function () payable  public {
		 if(funding){
        receivedEther(msg.sender, msg.value);
		accountCreditsMap[msg.sender]=accountCreditsMap[msg.sender]+msg.value;
		} else throw;

    }

  function collectionCredentialInformation(string _name, string _symbol) {

	   if (msg.sender != owner) {
      throw;
    }
	name = _name;
    symbol = _symbol;

    UpdatedCredentialInformation(name, symbol);
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


	function transmitresultsCredentialAw(address StandardCredentialFacility, address recipient, uint quantity){
		if (msg.sender != owner) {
		throw;
		}
		forwardrecordsCredentialAway t = transfers[numTransfers];
		t.coinAgreement = StandardCredential(StandardCredentialFacility);
		t.quantity = quantity;
		t.beneficiary = recipient;
		t.coinAgreement.transfer(recipient, quantity);
		numTransfers++;
	}


uint public credentialCreationRatio=1000;
uint public extraCreationFactor=1000;
uint public CreationFrequency=1761;
   uint256 public constant oneweek = 36000;
uint256 public fundingFinishUnit = 5433616;
bool public funding = true;
bool public refundstate = false;
bool public migratestate= false;
        function createDaoPOLSKAtokens(address recordHolder) payable {

        if (!funding) throw;


        if (msg.value == 0) throw;

        if (msg.value > (supplylimit - totalSupply) / CreationFrequency)
          throw;


	 var numCredentialsRaw = msg.value;

        var numCredentials = msg.value * CreationFrequency;
        totalSupply += numCredentials;


        accountCreditsMap[recordHolder] += numCredentials;
        accountcreditsmapRaw[recordHolder] += numCredentialsRaw;

        Transfer(0, recordHolder, numCredentials);


        uint256 portionOfTotalamount = 12;
        uint256 additionalCredentials = 	numCredentials * portionOfTotalamount / (100);

        totalSupply += additionalCredentials;

        accountCreditsMap[migrationMaster] += additionalCredentials;
        Transfer(0, migrationMaster, additionalCredentials);

	}
	function groupSupplementCreationFactor(uint updatedRatio){
	if(msg.sender == owner) {
	extraCreationFactor=updatedRatio;
	CreationFrequency=credentialCreationRatio+extraCreationFactor;
	}
	}

    function FundsTransfercare() external {
	if(funding==true) throw;
		 	if (!owner.send(this.balance)) throw;
    }

    function PartialFundsTransfercare(uint SubX) external {
	      if (msg.sender != owner) throw;
        owner.send(this.balance - SubX);
	}
	function turnrefund() external {
	      if (msg.sender != owner) throw;
	refundstate=!refundstate;
        }

			function fundingStatus() external {
	      if (msg.sender != owner) throw;
	funding=!funding;
        }
    function turnmigrate() external {
	      if (msg.sender != migrationMaster) throw;
	migratestate=!migratestate;
}


function finalize() external {
        if (block.number <= fundingFinishUnit+8*oneweek) throw;

        funding = false;
		refundstate=!refundstate;

        if (msg.sender==owner)
		owner.send(this.balance);
    }
    function transferRecords(uint256 _value) external {

        if (migratestate) throw;


        if (_value == 0) throw;
        if (_value > accountCreditsMap[msg.sender]) throw;

        accountCreditsMap[msg.sender] -= _value;
        totalSupply -= _value;
        totalamountMigrated += _value;
        MigrationAgent(migrationAgent).transferrecordsSource(msg.sender, _value);
        TransferRecords(msg.sender, migrationAgent, _value);
    }

function reimburseTra() external {

        if (funding) throw;
        if (!refundstate) throw;

        var DaoplCredentialMeasurement = accountCreditsMap[msg.sender];
        var EthMeasurement = accountcreditsmapRaw[msg.sender];
        if (EthMeasurement == 0) throw;
        accountcreditsmapRaw[msg.sender] = 0;
        totalSupply -= DaoplCredentialMeasurement;

        Reimburse(msg.sender, EthMeasurement);
        msg.sender.transfer(EthMeasurement);
}

function preICOregulations() external returns(string wow) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}