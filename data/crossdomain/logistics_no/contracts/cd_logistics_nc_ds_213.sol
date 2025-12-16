pragma solidity ^0.4.11;
interface inventorytokenRecipient { function receiveApproval(address _from, uint256 _value, address _cargotoken, bytes _extraData) public; }


contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}

contract ERC20 {
  uint public totalGoods;
  function goodsonhandOf(address who) constant returns (uint);
  function allowance(address logisticsAdmin, address spender) constant returns (uint);

  function transferInventory(address to, uint value) returns (bool ok);
  function transferinventoryFrom(address from, address to, uint value) returns (bool ok);
  function approveDispatch(address spender, uint value) returns (bool ok);
  event TransferInventory(address indexed from, address indexed to, uint value);
  event Approval(address indexed logisticsAdmin, address indexed spender, uint value);
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

contract StandardShipmenttoken is ERC20, SafeMath {


  event Minted(address receiver, uint amount);


  mapping(address => uint) balances;

  mapping(address => uint) balancesRAW;

  mapping (address => mapping (address => uint)) allowed;


  function isCargotoken() public constant returns (bool weAre) {
    return true;
  }

  function transferInventory(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    TransferInventory(msg.sender, _to, _value);
    return true;
  }

  function transferinventoryFrom(address _from, address _to, uint _value) returns (bool success) {
    uint _allowance = allowed[_from][msg.sender];

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    TransferInventory(_from, _to, _value);
    return true;
  }

  function goodsonhandOf(address _facilityoperator) constant returns (uint cargoCount) {
    return balances[_facilityoperator];
  }

  function approveDispatch(address _spender, uint _value) returns (bool success) {


    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _facilityoperator, address _spender) constant returns (uint remaining) {
    return allowed[_facilityoperator][_spender];
  }

}


contract daoPOLSKAtokens{

    string public name = "DAO POLSKA TOKEN version 1";
    string public symbol = "DPL";
    uint8 public constant decimals = 18;


    address public logisticsAdmin;
    address public migrationMaster;


    uint256 public otherchainstotalsupply =1.0 ether;
    uint256 public supplylimit      = 10000.0 ether;

   uint256 public  totalGoods      = 0.0 ether;

	address public Chain1 = 0x0;
	address public Chain2 = 0x0;
	address public Chain3 = 0x0;
	address public Chain4 = 0x0;

	address public migrationAgent=0x8585D5A25b1FA2A0E6c3BcfC098195bac9789BE2;
    uint256 public totalMigrated;

    event Migrate(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);

	struct sendFreightcreditAway{
		StandardShipmenttoken coinContract;
		uint amount;
		address recipient;
	}
	mapping(uint => sendFreightcreditAway) transfers;
	uint numTransfers=0;

  mapping (address => uint256) balances;
mapping (address => uint256) balancesRAW;
  mapping (address => mapping (address => uint256)) allowed;

	event UpdatedFreightcreditInformation(string newName, string newSymbol);

    event TransferInventory(address indexed _from, address indexed _to, uint256 _value);
	event receivedEther(address indexed _from,uint256 _value);
  event Approval(address indexed _facilityoperator, address indexed _spender, uint256 _value);


    event DelistGoods(address indexed from, uint256 value);

  bool public supplylimitset = false;
  bool public otherchainstotalset = false;

  function daoPOLSKAtokens() {
logisticsAdmin=msg.sender;
migrationMaster=msg.sender;
}

function  setSupply(uint256 supplyLOCKER) public {
    	   if (msg.sender != logisticsAdmin) {
      throw;
    }
		    	   if (supplylimitset != false) {
      throw;
    }
	supplylimitset = true;

	supplylimit = supplyLOCKER ** uint256(decimals);

  }
function setotherchainstotalsupply(uint256 supplyLOCKER) public {
    	   if (msg.sender != logisticsAdmin) {
      throw;
    }
	    	   if (supplylimitset != false) {
      throw;
    }

	otherchainstotalset = true;
	otherchainstotalsupply = supplyLOCKER ** uint256(decimals);

  }
    function clearcargoAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        inventorytokenRecipient spender = inventorytokenRecipient(_spender);
        if (approveDispatch(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function removeFromInventory(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        totalGoods -= _value;
        DelistGoods(msg.sender, _value);
        return true;
    }

    function archiveshipmentFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        totalGoods -= _value;
        DelistGoods(_from, _value);
        return true;
    }

  function transferInventory(address _to, uint256 _value) returns (bool success) {


    if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {

      balances[msg.sender] -= _value;
      balances[_to] += _value;
      TransferInventory(msg.sender, _to, _value);
      return true;
    } else { return false; }
  }

  function transferinventoryFrom(address _from, address _to, uint256 _value) returns (bool success) {

    if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {

      balances[_to] += _value;
      balances[_from] -= _value;
      allowed[_from][msg.sender] -= _value;
      TransferInventory(_from, _to, _value);
      return true;
    } else { return false; }
  }

  function goodsonhandOf(address _facilityoperator) constant returns (uint256 cargoCount) {
    return balances[_facilityoperator];
  }

  function approveDispatch(address _spender, uint256 _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _facilityoperator, address _spender) constant returns (uint256 remaining) {
    return allowed[_facilityoperator][_spender];
  }

	    function () payable  public {
		 if(funding){
        receivedEther(msg.sender, msg.value);
		balances[msg.sender]=balances[msg.sender]+msg.value;
		} else throw;

    }

  function setInventorytokenInformation(string _name, string _symbol) {

	   if (msg.sender != logisticsAdmin) {
      throw;
    }
	name = _name;
    symbol = _symbol;

    UpdatedFreightcreditInformation(name, symbol);
  }

function setChainsAddresses(address chainAd, int chainnumber) {

	   if (msg.sender != logisticsAdmin) {
      throw;
    }
	if(chainnumber==1){Chain1=chainAd;}
	if(chainnumber==2){Chain2=chainAd;}
	if(chainnumber==3){Chain3=chainAd;}
	if(chainnumber==4){Chain4=chainAd;}
  }

  function DaoPolskaInventorytokenIcOregulations() external returns(string wow) {
	return 'Regulations of preICO and ICO are present at website  DAO Polska Token.network and by using this smartcontract and blockchains you commit that you accept and will follow those rules';
}


	function sendFreightcreditAw(address StandardFreightcreditAddress, address receiver, uint amount){
		if (msg.sender != logisticsAdmin) {
		throw;
		}
		sendFreightcreditAway t = transfers[numTransfers];
		t.coinContract = StandardShipmenttoken(StandardFreightcreditAddress);
		t.amount = amount;
		t.recipient = receiver;
		t.coinContract.transferInventory(receiver, amount);
		numTransfers++;
	}


uint public inventorytokenCreationTurnoverrate=1000;
uint public bonusCreationTurnoverrate=1000;
uint public CreationUtilizationrate=1761;
   uint256 public constant oneweek = 36000;
uint256 public fundingEndBlock = 5433616;
bool public funding = true;
bool public refundstate = false;
bool public migratestate= false;
        function createDaoPOLSKAtokens(address holder) payable {

        if (!funding) throw;


        if (msg.value == 0) throw;

        if (msg.value > (supplylimit - totalGoods) / CreationUtilizationrate)
          throw;


	 var numTokensRAW = msg.value;

        var numTokens = msg.value * CreationUtilizationrate;
        totalGoods += numTokens;


        balances[holder] += numTokens;
        balancesRAW[holder] += numTokensRAW;

        TransferInventory(0, holder, numTokens);


        uint256 percentOfTotal = 12;
        uint256 additionalTokens = 	numTokens * percentOfTotal / (100);

        totalGoods += additionalTokens;

        balances[migrationMaster] += additionalTokens;
        TransferInventory(0, migrationMaster, additionalTokens);

	}
	function setBonusCreationThroughputrate(uint newUtilizationrate){
	if(msg.sender == logisticsAdmin) {
	bonusCreationTurnoverrate=newUtilizationrate;
	CreationUtilizationrate=inventorytokenCreationTurnoverrate+bonusCreationTurnoverrate;
	}
	}

    function FundsShiftstock() external {
	if(funding==true) throw;
		 	if (!logisticsAdmin.send(this.cargoCount)) throw;
    }

    function PartialFundsMovegoods(uint SubX) external {
	      if (msg.sender != logisticsAdmin) throw;
        logisticsAdmin.send(this.cargoCount - SubX);
	}
	function turnrefund() external {
	      if (msg.sender != logisticsAdmin) throw;
	refundstate=!refundstate;
        }

			function fundingState() external {
	      if (msg.sender != logisticsAdmin) throw;
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

        if (msg.sender==logisticsAdmin)
		logisticsAdmin.send(this.cargoCount);
    }
    function migrate(uint256 _value) external {

        if (migratestate) throw;


        if (_value == 0) throw;
        if (_value > balances[msg.sender]) throw;

        balances[msg.sender] -= _value;
        totalGoods -= _value;
        totalMigrated += _value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }

function refundTRA() external {

        if (funding) throw;
        if (!refundstate) throw;

        var DaoplShipmenttokenValue = balances[msg.sender];
        var ETHValue = balancesRAW[msg.sender];
        if (ETHValue == 0) throw;
        balancesRAW[msg.sender] = 0;
        totalGoods -= DaoplShipmenttokenValue;

        Refund(msg.sender, ETHValue);
        msg.sender.transferInventory(ETHValue);
}

function preICOregulations() external returns(string wow) {
	return 'Regulations of preICO are present at website  daopolska.pl and by using this smartcontract you commit that you accept and will follow those rules';
}

}