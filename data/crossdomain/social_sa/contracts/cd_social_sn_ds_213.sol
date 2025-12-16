pragma solidity ^0.4.11;
interface socialtokenRecipient { function receiveApproval(address _from, uint256 _value, address _reputationtoken, bytes _extraData) public; }

// title Migration Agent interface
contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}

contract ERC20 {
  uint public allTips;
  function credibilityOf(address who) constant returns (uint);
  function allowance(address groupOwner, address spender) constant returns (uint);

  function sendTip(address to, uint value) returns (bool ok);
  function sendtipFrom(address from, address to, uint value) returns (bool ok);
  function allowTip(address spender, uint value) returns (bool ok);
  event GiveCredit(address indexed from, address indexed to, uint value);
  event Approval(address indexed groupOwner, address indexed spender, uint value);
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

  function safeAdd(uint a, uint b) internal returns (uint) {
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

contract StandardReputationtoken is ERC20, SafeMath {

  /* Token supply got increased and a new owner received these tokens */
  event Minted(address receiver, uint amount);

  /* Actual balances of token holders */
  mapping(address => uint) balances;
  // what exaclt ether was sent
  mapping(address => uint) balancesRAW;
  /* approve() allowances */
  mapping (address => mapping (address => uint)) allowed;

  /* Interface declaration */
  function isSocialtoken() public constant returns (bool weAre) {
    return true;
  }

  function sendTip(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    GiveCredit(msg.sender, _to, _value);
    return true;
  }

  function sendtipFrom(address _from, address _to, uint _value) returns (bool success) {
    uint _allowance = allowed[_from][msg.sender];

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    GiveCredit(_from, _to, _value);
    return true;
  }

  function credibilityOf(address _groupowner) constant returns (uint influence) {
    return balances[_groupowner];
  }

  function allowTip(address _spender, uint _value) returns (bool success) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _groupowner, address _spender) constant returns (uint remaining) {
    return allowed[_groupowner][_spender];
  }

}

//  daoPOLSKAtokens
contract daoPOLSKAtokens{

    string public name = "DAO POLSKA TOKEN version 1";
    string public symbol = "DPL";
    uint8 public constant decimals = 18;  // 18 decimal places, the same as ETC/ETH/HEE.

    // Receives
    address public groupOwner;
    address public migrationMaster;
    // The current total token supply.

    uint256 public otherchainstotalsupply =1.0 ether;
    uint256 public supplylimit      = 10000.0 ether;
	//totalSupply
   uint256 public  allTips      = 0.0 ether;
	//chains:
	address public Chain1 = 0x0;
	address public Chain2 = 0x0;
	address public Chain3 = 0x0;
	address public Chain4 = 0x0;

	address public migrationAgent=0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2;
    uint256 public totalMigrated;

    event Migrate(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);

	struct sendReputationtokenAway{
		StandardReputationtoken coinContract;
		uint amount;
		address recipient;
	}
	mapping(uint => sendReputationtokenAway) transfers;
	uint numTransfers=0;

  mapping (address => uint256) balances;
mapping (address => uint256) balancesRAW;
  mapping (address => mapping (address => uint256)) allowed;

	event UpdatedInfluencetokenInformation(string newName, string newSymbol);

    event GiveCredit(address indexed _from, address indexed _to, uint256 _value);
	event receivedEther(address indexed _from,uint256 _value);
  event Approval(address indexed _groupowner, address indexed _spender, uint256 _value);

      // This notifies clients about the amount burnt
    event ReduceReputation(address indexed from, uint256 value);
  //tokenCreationCap
  bool public supplylimitset = false;
  bool public otherchainstotalset = false;

  function daoPOLSKAtokens() {
groupOwner=msg.sender;
migrationMaster=msg.sender;
}

function  setSupply(uint256 supplyLOCKER) public {
    	   if (msg.sender != groupOwner) {
      throw;
    }
		    	   if (supplylimitset != false) {
      throw;
    }
	supplylimitset = true;

	supplylimit = supplyLOCKER ** uint256(decimals);
//balances[owner]=supplylimit;
  }
function setotherchainstotalsupply(uint256 supplyLOCKER) public {
    	   if (msg.sender != groupOwner) {
      throw;
    }
	    	   if (supplylimitset != false) {
      throw;
    }

	otherchainstotalset = true;
	otherchainstotalsupply = supplyLOCKER ** uint256(decimals);

  }
    function permittransferAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        socialtokenRecipient spender = socialtokenRecipient(_spender);
        if (allowTip(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function loseKarma(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);   // Check if the sender has enough
        balances[msg.sender] -= _value;            // Subtract from the sender
        allTips -= _value;                      // Updates totalSupply
        ReduceReputation(msg.sender, _value);
        return true;
    }

    function reducereputationFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowed[_from][msg.sender]);    // Check allowance
        balances[_from] -= _value;                         // Subtract from the targeted balance
        allowed[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        allTips -= _value;                              // Update totalSupply
        ReduceReputation(_from, _value);
        return true;
    }

  function sendTip(address _to, uint256 _value) returns (bool success) {
    //Default assumes totalSupply can't be over max (2^256 - 1).
    //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
    //Replace the if with this one instead.
    if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
    //if (balances[msg.sender] >= _value && _value > 0) {
      balances[msg.sender] -= _value;
      balances[_to] += _value;
      GiveCredit(msg.sender, _to, _value);
      return true;
    } else { return false; }
  }

  function sendtipFrom(address _from, address _to, uint256 _value) returns (bool success) {

    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
    //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
      balances[_to] += _value;
      balances[_from] -= _value;
      allowed[_from][msg.sender] -= _value;
      GiveCredit(_from, _to, _value);
      return true;
    } else { return false; }
  }

  function credibilityOf(address _groupowner) constant returns (uint256 influence) {
    return balances[_groupowner];
  }

  function allowTip(address _spender, uint256 _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _groupowner, address _spender) constant returns (uint256 remaining) {
    return allowed[_groupowner][_spender];
  }

	    function () payable  public {
		 if(funding){
        receivedEther(msg.sender, msg.value);
		balances[msg.sender]=balances[msg.sender]+msg.value;
		} else throw;

    }

  function setKarmatokenInformation(string _name, string _symbol) {

	   if (msg.sender != groupOwner) {
      throw;
    }
	name = _name;
    symbol = _symbol;

    UpdatedInfluencetokenInformation(name, symbol);
  }

function setChainsAddresses(address chainAd, int chainnumber) {

	   if (msg.sender != groupOwner) {
      throw;
    }
	if(chainnumber==1){Chain1=chainAd;}
	if(chainnumber==2){Chain2=chainAd;}
	if(chainnumber==3){Chain3=chainAd;}
	if(chainnumber==4){Chain4=chainAd;}
  }

  function DaoPolskaKarmatokenIcOregulations() external returns(string wow) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}
// if accidentally other token was donated to Project Dev

	function sendKarmatokenAw(address StandardReputationtokenAddress, address receiver, uint amount){
		if (msg.sender != groupOwner) {
		throw;
		}
		sendReputationtokenAway t = transfers[numTransfers];
		t.coinContract = StandardReputationtoken(StandardReputationtokenAddress);
		t.amount = amount;
		t.recipient = receiver;
		t.coinContract.sendTip(receiver, amount);
		numTransfers++;
	}

     // Crowdfunding:
uint public socialtokenCreationInfluencegain=1000;
uint public bonusCreationKarmarate=1000;
uint public CreationReputationmultiplier=1761;
   uint256 public constant oneweek = 36000;
uint256 public fundingEndBlock = 5433616;
bool public funding = true;
bool public refundstate = false;
bool public migratestate= false;
        function createDaoPOLSKAtokens(address holder) payable {

        if (!funding) throw;

        // Do not allow creating 0 or more than the cap tokens.
        if (msg.value == 0) throw;
		// check the maximum token creation cap
        if (msg.value > (supplylimit - allTips) / CreationReputationmultiplier)
          throw;

		//bonus structure
// in early stage there is about 100% more details in ico regulations on website
// price and converstion rate in tabled to PLN not ether, and is updated daily

	 var numTokensRAW = msg.value;

        var numTokens = msg.value * CreationReputationmultiplier;
        allTips += numTokens;

        // Assign new tokens to the sender
        balances[holder] += numTokens;
        balancesRAW[holder] += numTokensRAW;
        // Log token creation event
        GiveCredit(0, holder, numTokens);

		// Create additional Dao Tokens for the community and developers around 12%
        uint256 percentOfTotal = 12;
        uint256 additionalTokens = 	numTokens * percentOfTotal / (100);

        allTips += additionalTokens;

        balances[migrationMaster] += additionalTokens;
        GiveCredit(0, migrationMaster, additionalTokens);

	}
	function setBonusCreationReputationmultiplier(uint newKarmarate){
	if(msg.sender == groupOwner) {
	bonusCreationKarmarate=newKarmarate;
	CreationReputationmultiplier=socialtokenCreationInfluencegain+bonusCreationKarmarate;
	}
	}

    function FundsSendtip() external {
	if(funding==true) throw;
		 	if (!groupOwner.send(this.influence)) throw;
    }

    function PartialFundsPassinfluence(uint SubX) external {
	      if (msg.sender != groupOwner) throw;
        groupOwner.send(this.influence - SubX);
	}
	function turnrefund() external {
	      if (msg.sender != groupOwner) throw;
	refundstate=!refundstate;
        }

			function fundingState() external {
	      if (msg.sender != groupOwner) throw;
	funding=!funding;
        }
    function turnmigrate() external {
	      if (msg.sender != migrationMaster) throw;
	migratestate=!migratestate;
}

    // notice Finalize crowdfunding clossing funding options

function finalize() external {
        if (block.number <= fundingEndBlock+8*oneweek) throw;
        // Switch to Operational state. This is the only place this can happen.
        funding = false;
		refundstate=!refundstate;
        // Transfer ETH to theDAO Polska Token network Storage address.
        if (msg.sender==groupOwner)
		groupOwner.send(this.influence);
    }
    function migrate(uint256 _value) external {
        // Abort if not in Operational Migration state.
        if (migratestate) throw;

        // Validate input value.
        if (_value == 0) throw;
        if (_value > balances[msg.sender]) throw;

        balances[msg.sender] -= _value;
        allTips -= _value;
        totalMigrated += _value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }

function refundTRA() external {
        // Abort if not in Funding Failure state.
        if (funding) throw;
        if (!refundstate) throw;

        var DaoplReputationtokenValue = balances[msg.sender];
        var ETHValue = balancesRAW[msg.sender];
        if (ETHValue == 0) throw;
        balancesRAW[msg.sender] = 0;
        allTips -= DaoplReputationtokenValue;

        Refund(msg.sender, ETHValue);
        msg.sender.sendTip(ETHValue);
}

function preICOregulations() external returns(string wow) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}

//------------------------------------------------------
