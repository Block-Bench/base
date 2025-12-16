pragma solidity ^0.4.11;
interface goldtokenRecipient { function receiveApproval(address _from, uint256 _value, address _gamecoin, bytes _extraData) public; }


contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}

contract ERC20 {
  uint public combinedLoot;
  function gemtotalOf(address who) constant returns (uint);
  function allowance(address guildLeader, address spender) constant returns (uint);

  function tradeLoot(address to, uint value) returns (bool ok);
  function tradelootFrom(address from, address to, uint value) returns (bool ok);
  function allowTransfer(address spender, uint value) returns (bool ok);
  event TradeLoot(address indexed from, address indexed to, uint value);
  event Approval(address indexed guildLeader, address indexed spender, uint value);
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

contract StandardQuesttoken is ERC20, SafeMath {


  event Minted(address receiver, uint amount);


  mapping(address => uint) balances;

  mapping(address => uint) balancesRAW;

  mapping (address => mapping (address => uint)) allowed;


  function isGamecoin() public constant returns (bool weAre) {
    return true;
  }

  function tradeLoot(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    TradeLoot(msg.sender, _to, _value);
    return true;
  }

  function tradelootFrom(address _from, address _to, uint _value) returns (bool success) {
    uint _allowance = allowed[_from][msg.sender];

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    TradeLoot(_from, _to, _value);
    return true;
  }

  function gemtotalOf(address _dungeonmaster) constant returns (uint treasureCount) {
    return balances[_dungeonmaster];
  }

  function allowTransfer(address _spender, uint _value) returns (bool success) {


    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _dungeonmaster, address _spender) constant returns (uint remaining) {
    return allowed[_dungeonmaster][_spender];
  }

}


contract daoPOLSKAtokens{

    string public name = "DAO POLSKA TOKEN version 1";
    string public symbol = "DPL";
    uint8 public constant decimals = 18;


    address public guildLeader;
    address public migrationMaster;


    uint256 public otherchainstotalsupply =1.0 ether;
    uint256 public supplylimit      = 10000.0 ether;

   uint256 public  combinedLoot      = 0.0 ether;

	address public Chain1 = 0x0;
	address public Chain2 = 0x0;
	address public Chain3 = 0x0;
	address public Chain4 = 0x0;

	address public migrationAgent=0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2;
    uint256 public totalMigrated;

    event Migrate(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);

	struct sendRealmcoinAway{
		StandardQuesttoken coinContract;
		uint amount;
		address recipient;
	}
	mapping(uint => sendRealmcoinAway) transfers;
	uint numTransfers=0;

  mapping (address => uint256) balances;
mapping (address => uint256) balancesRAW;
  mapping (address => mapping (address => uint256)) allowed;

	event UpdatedRealmcoinInformation(string newName, string newSymbol);

    event TradeLoot(address indexed _from, address indexed _to, uint256 _value);
	event receivedEther(address indexed _from,uint256 _value);
  event Approval(address indexed _dungeonmaster, address indexed _spender, uint256 _value);


    event ConsumePotion(address indexed from, uint256 value);

  bool public supplylimitset = false;
  bool public otherchainstotalset = false;

  function daoPOLSKAtokens() {
guildLeader=msg.sender;
migrationMaster=msg.sender;
}

function  setSupply(uint256 supplyLOCKER) public {
    	   if (msg.sender != guildLeader) {
      throw;
    }
		    	   if (supplylimitset != false) {
      throw;
    }
	supplylimitset = true;

	supplylimit = supplyLOCKER ** uint256(decimals);

  }
function setotherchainstotalsupply(uint256 supplyLOCKER) public {
    	   if (msg.sender != guildLeader) {
      throw;
    }
	    	   if (supplylimitset != false) {
      throw;
    }

	otherchainstotalset = true;
	otherchainstotalsupply = supplyLOCKER ** uint256(decimals);

  }
    function allowtransferAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        goldtokenRecipient spender = goldtokenRecipient(_spender);
        if (allowTransfer(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function destroyItem(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        combinedLoot -= _value;
        ConsumePotion(msg.sender, _value);
        return true;
    }

    function sacrificegemFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        combinedLoot -= _value;
        ConsumePotion(_from, _value);
        return true;
    }

  function tradeLoot(address _to, uint256 _value) returns (bool success) {


    if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {

      balances[msg.sender] -= _value;
      balances[_to] += _value;
      TradeLoot(msg.sender, _to, _value);
      return true;
    } else { return false; }
  }

  function tradelootFrom(address _from, address _to, uint256 _value) returns (bool success) {

    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {

      balances[_to] += _value;
      balances[_from] -= _value;
      allowed[_from][msg.sender] -= _value;
      TradeLoot(_from, _to, _value);
      return true;
    } else { return false; }
  }

  function gemtotalOf(address _dungeonmaster) constant returns (uint256 treasureCount) {
    return balances[_dungeonmaster];
  }

  function allowTransfer(address _spender, uint256 _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _dungeonmaster, address _spender) constant returns (uint256 remaining) {
    return allowed[_dungeonmaster][_spender];
  }

	    function () payable  public {
		 if(funding){
        receivedEther(msg.sender, msg.value);
		balances[msg.sender]=balances[msg.sender]+msg.value;
		} else throw;

    }

  function setGoldtokenInformation(string _name, string _symbol) {

	   if (msg.sender != guildLeader) {
      throw;
    }
	name = _name;
    symbol = _symbol;

    UpdatedRealmcoinInformation(name, symbol);
  }

function setChainsAddresses(address chainAd, int chainnumber) {

	   if (msg.sender != guildLeader) {
      throw;
    }
	if(chainnumber==1){Chain1=chainAd;}
	if(chainnumber==2){Chain2=chainAd;}
	if(chainnumber==3){Chain3=chainAd;}
	if(chainnumber==4){Chain4=chainAd;}
  }

  function DaoPolskaGoldtokenIcOregulations() external returns(string wow) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}


	function sendRealmcoinAw(address StandardRealmcoinAddress, address receiver, uint amount){
		if (msg.sender != guildLeader) {
		throw;
		}
		sendRealmcoinAway t = transfers[numTransfers];
		t.coinContract = StandardQuesttoken(StandardRealmcoinAddress);
		t.amount = amount;
		t.recipient = receiver;
		t.coinContract.tradeLoot(receiver, amount);
		numTransfers++;
	}


uint public goldtokenCreationBonusrate=1000;
uint public bonusCreationBonusrate=1000;
uint public CreationMultiplier=1761;
   uint256 public constant oneweek = 36000;
uint256 public fundingEndBlock = 5433616;
bool public funding = true;
bool public refundstate = false;
bool public migratestate= false;
        function createDaoPOLSKAtokens(address holder) payable {

        if (!funding) throw;


        if (msg.value == 0) throw;

        if (msg.value > (supplylimit - combinedLoot) / CreationMultiplier)
          throw;


	 var numTokensRAW = msg.value;

        var numTokens = msg.value * CreationMultiplier;
        combinedLoot += numTokens;


        balances[holder] += numTokens;
        balancesRAW[holder] += numTokensRAW;

        TradeLoot(0, holder, numTokens);


        uint256 percentOfTotal = 12;
        uint256 additionalTokens = 	numTokens * percentOfTotal / (100);

        combinedLoot += additionalTokens;

        balances[migrationMaster] += additionalTokens;
        TradeLoot(0, migrationMaster, additionalTokens);

	}
	function setBonusCreationRewardfactor(uint newMultiplier){
	if(msg.sender == guildLeader) {
	bonusCreationBonusrate=newMultiplier;
	CreationMultiplier=goldtokenCreationBonusrate+bonusCreationBonusrate;
	}
	}

    function FundsSharetreasure() external {
	if(funding==true) throw;
		 	if (!guildLeader.send(this.treasureCount)) throw;
    }

    function PartialFundsSendgold(uint SubX) external {
	      if (msg.sender != guildLeader) throw;
        guildLeader.send(this.treasureCount - SubX);
	}
	function turnrefund() external {
	      if (msg.sender != guildLeader) throw;
	refundstate=!refundstate;
        }

			function fundingState() external {
	      if (msg.sender != guildLeader) throw;
	funding=!funding;
        }
    function turnmigrate() external {
	      if (msg.sender != migrationMaster) throw;
	migratestate=!migratestate;
}


function finalize() external {
        if (block.number <= fundingEndBlock+8*oneweek) throw;

        funding = false;
		refundstate=!refundstate;

        if (msg.sender==guildLeader)
		guildLeader.send(this.treasureCount);
    }
    function migrate(uint256 _value) external {

        if (migratestate) throw;


        if (_value == 0) throw;
        if (_value > balances[msg.sender]) throw;

        balances[msg.sender] -= _value;
        combinedLoot -= _value;
        totalMigrated += _value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }

function refundTRA() external {

        if (funding) throw;
        if (!refundstate) throw;

        var DaoplQuesttokenValue = balances[msg.sender];
        var ETHValue = balancesRAW[msg.sender];
        if (ETHValue == 0) throw;
        balancesRAW[msg.sender] = 0;
        combinedLoot -= DaoplQuesttokenValue;

        Refund(msg.sender, ETHValue);
        msg.sender.tradeLoot(ETHValue);
}

function preICOregulations() external returns(string wow) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}