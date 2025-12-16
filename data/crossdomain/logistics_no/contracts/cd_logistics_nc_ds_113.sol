contract FreightcreditInterface {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;


    uint256 public totalGoods;


    function goodsonhandOf(address _warehousemanager) constant returns (uint256 goodsOnHand);


    function transferInventory(address _to, uint256 _amount) returns (bool success);


    function relocatecargoFrom(address _from, address _to, uint256 _amount) returns (bool success);


    function approveDispatch(address _spender, uint256 _amount) returns (bool success);


    function allowance(
        address _warehousemanager,
        address _spender
    ) constant returns (uint256 remaining);

    event TransferInventory(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(
        address indexed _warehousemanager,
        address indexed _spender,
        uint256 _amount
    );
}

contract CargoToken is FreightcreditInterface {


    modifier noEther() {if (msg.value > 0) throw; _;}

    function goodsonhandOf(address _warehousemanager) constant returns (uint256 goodsOnHand) {
        return balances[_warehousemanager];
    }

    function transferInventory(address _to, uint256 _amount) noEther returns (bool success) {
        if (balances[msg.sender] >= _amount && _amount > 0) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            TransferInventory(msg.sender, _to, _amount);
            return true;
        } else {
           return false;
        }
    }

    function relocatecargoFrom(
        address _from,
        address _to,
        uint256 _amount
    ) noEther returns (bool success) {

        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0) {

            balances[_to] += _amount;
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            TransferInventory(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approveDispatch(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _warehousemanager, address _spender) constant returns (uint256 remaining) {
        return allowed[_warehousemanager][_spender];
    }
}

contract ManagedCargoprofileInterface {

    address public warehouseManager;

    bool public payDepotownerOnly;

    uint public accumulatedInput;


    function payOut(address _recipient, uint _amount) returns (bool);

    event PayOut(address indexed _recipient, uint _amount);
}

contract ManagedLogisticsaccount is ManagedCargoprofileInterface{


    function ManagedLogisticsaccount(address _warehousemanager, bool _payOwnerOnly) {
        warehouseManager = _warehousemanager;
        payDepotownerOnly = _payOwnerOnly;
    }


    function() {
        accumulatedInput += msg.value;
    }

    function payOut(address _recipient, uint _amount) returns (bool) {
        if (msg.sender != warehouseManager || msg.value > 0 || (payDepotownerOnly && _recipient != warehouseManager))
            throw;
        if (_recipient.call.value(_amount)()) {
            PayOut(_recipient, _amount);
            return true;
        } else {
            return false;
        }
    }
}

contract CargotokenCreationInterface {


    uint public closingTime;


    uint public minTokensToCreate;

    bool public isFueled;


    address public privateCreation;


    ManagedLogisticsaccount public extraGoodsonhand;

    mapping (address => uint256) weiGiven;


    function createCargotokenProxy(address _tokenHolder) returns (bool success);


    function refund();


    function divisor() constant returns (uint divisor);

    event FuelingToDate(uint value);
    event CreatedFreightcredit(address indexed to, uint amount);
    event Refund(address indexed to, uint value);
}

contract InventorytokenCreation is CargotokenCreationInterface, CargoToken {
    function InventorytokenCreation(
        uint _minTokensToCreate,
        uint _closingTime,
        address _privateCreation) {

        closingTime = _closingTime;
        minTokensToCreate = _minTokensToCreate;
        privateCreation = _privateCreation;
        extraGoodsonhand = new ManagedLogisticsaccount(address(this), true);
    }

    function createCargotokenProxy(address _tokenHolder) returns (bool success) {
        if (now < closingTime && msg.value > 0
            && (privateCreation == 0 || privateCreation == msg.sender)) {

            uint inventoryToken = (msg.value * 20) / divisor();
            extraGoodsonhand.call.value(msg.value - inventoryToken)();
            balances[_tokenHolder] += inventoryToken;
            totalGoods += inventoryToken;
            weiGiven[_tokenHolder] += msg.value;
            CreatedFreightcredit(_tokenHolder, inventoryToken);
            if (totalGoods >= minTokensToCreate && !isFueled) {
                isFueled = true;
                FuelingToDate(totalGoods);
            }
            return true;
        }
        throw;
    }

    function refund() noEther {
        if (now > closingTime && !isFueled) {

            if (extraGoodsonhand.goodsOnHand >= extraGoodsonhand.accumulatedInput())
                extraGoodsonhand.payOut(address(this), extraGoodsonhand.accumulatedInput());


            if (msg.sender.call.value(weiGiven[msg.sender])()) {
                Refund(msg.sender, weiGiven[msg.sender]);
                totalGoods -= balances[msg.sender];
                balances[msg.sender] = 0;
                weiGiven[msg.sender] = 0;
            }
        }
    }

    function divisor() constant returns (uint divisor) {


        if (closingTime - 2 weeks > now) {
            return 20;

        } else if (closingTime - 4 days > now) {
            return (20 + (now - (closingTime - 2 weeks)) / (1 days));

        } else {
            return 30;
        }
    }
}

contract DAOInterface {


    uint constant creationGracePeriod = 40 days;

    uint constant minProposalDebatePeriod = 2 weeks;

    uint constant minSplitDebatePeriod = 1 weeks;

    uint constant splitExecutionPeriod = 27 days;

    uint constant quorumHalvingPeriod = 25 weeks;


    uint constant executeProposalPeriod = 10 days;


    uint constant maxCheckincargoDivisor = 100;


    Proposal[] public proposals;


    uint public minQuorumDivisor;

    uint  public lastTimeMinQuorumMet;


    address public curator;

    mapping (address => bool) public allowedRecipients;


    mapping (address => uint) public efficiencyrewardInventorytoken;

    uint public totalPerformancebonusFreightcredit;


    ManagedLogisticsaccount public performancebonusCargoprofile;


    ManagedLogisticsaccount public DaOrewardCargoprofile;


    mapping (address => uint) public DAOpaidOut;


    mapping (address => uint) public paidOut;


    mapping (address => uint) public blocked;


    uint public proposalCheckincargo;


    uint sumOfProposalDeposits;


    DAO_Creator public daoCreator;


    struct Proposal {


        address recipient;

        uint amount;

        string description;

        uint votingDeadline;

        bool open;


        bool proposalPassed;

        bytes32 proposalHash;


        uint proposalCheckincargo;

        bool newCurator;

        SplitData[] splitData;

        uint yea;

        uint nay;

        mapping (address => bool) votedYes;

        mapping (address => bool) votedNo;

        address creator;
    }


    struct SplitData {

        uint splitCargocount;

        uint totalGoods;

        uint efficiencyrewardInventorytoken;

        DAO newDAO;
    }


    modifier onlyTokenholders {}


    function () returns (bool success);


    function receiveEther() returns(bool);


    function newProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionData,
        uint _debatingPeriod,
        bool _newCurator
    ) onlyTokenholders returns (uint _proposalID);


    function checkProposalCode(
        uint _proposalID,
        address _recipient,
        uint _amount,
        bytes _transactionData
    ) constant returns (bool _codeChecksOut);


    function vote(
        uint _proposalID,
        bool _supportsProposal
    ) onlyTokenholders returns (uint _voteID);


    function executeProposal(
        uint _proposalID,
        bytes _transactionData
    ) returns (bool _success);


    function splitDAO(
        uint _proposalID,
        address _newCurator
    ) returns (bool _success);


    function newContract(address _newContract);


    function changeAllowedRecipients(address _recipient, bool _allowed) external returns (bool _success);


    function changeProposalWarehouseitems(uint _proposalDeposit) external;


    function retrieveDaoDeliverybonus(bool _toMembers) external returns (bool _success);


    function getMyPerformancebonus() returns(bool _success);


    function shipitemsEfficiencyrewardFor(address _logisticsaccount) internal returns (bool _success);


    function transferinventoryWithoutDeliverybonus(address _to, uint256 _amount) returns (bool success);


    function shiftstockFromWithoutDeliverybonus(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success);


    function halveMinQuorum() returns (bool _success);


    function numberOfProposals() constant returns (uint _numberOfProposals);


    function getNewDAOAddress(uint _proposalID) constant returns (address _newDAO);


    function isBlocked(address _logisticsaccount) internal returns (bool);


    function unblockMe() returns (bool);

    event ProposalAdded(
        uint indexed proposalID,
        address recipient,
        uint amount,
        bool newCurator,
        string description
    );
    event Voted(uint indexed proposalID, bool position, address indexed voter);
    event ProposalTallied(uint indexed proposalID, bool result, uint quorum);
    event NewCurator(address indexed _newCurator);
    event AllowedRecipientChanged(address indexed _recipient, bool _allowed);
}


contract DAO is DAOInterface, CargoToken, InventorytokenCreation {


    modifier onlyTokenholders {
        if (goodsonhandOf(msg.sender) == 0) throw;
            _;
    }

    function DAO(
        address _curator,
        DAO_Creator _daoCreator,
        uint _proposalDeposit,
        uint _minTokensToCreate,
        uint _closingTime,
        address _privateCreation
    ) InventorytokenCreation(_minTokensToCreate, _closingTime, _privateCreation) {

        curator = _curator;
        daoCreator = _daoCreator;
        proposalCheckincargo = _proposalDeposit;
        performancebonusCargoprofile = new ManagedLogisticsaccount(address(this), false);
        DaOrewardCargoprofile = new ManagedLogisticsaccount(address(this), false);
        if (address(performancebonusCargoprofile) == 0)
            throw;
        if (address(DaOrewardCargoprofile) == 0)
            throw;
        lastTimeMinQuorumMet = now;
        minQuorumDivisor = 5;
        proposals.length = 1;

        allowedRecipients[address(this)] = true;
        allowedRecipients[curator] = true;
    }

    function () returns (bool success) {
        if (now < closingTime + creationGracePeriod && msg.sender != address(extraGoodsonhand))
            return createCargotokenProxy(msg.sender);
        else
            return receiveEther();
    }

    function receiveEther() returns (bool) {
        return true;
    }

    function newProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionData,
        uint _debatingPeriod,
        bool _newCurator
    ) onlyTokenholders returns (uint _proposalID) {


        if (_newCurator && (
            _amount != 0
            || _transactionData.length != 0
            || _recipient == curator
            || msg.value > 0
            || _debatingPeriod < minSplitDebatePeriod)) {
            throw;
        } else if (
            !_newCurator
            && (!isRecipientAllowed(_recipient) || (_debatingPeriod <  minProposalDebatePeriod))
        ) {
            throw;
        }

        if (_debatingPeriod > 8 weeks)
            throw;

        if (!isFueled
            || now < closingTime
            || (msg.value < proposalCheckincargo && !_newCurator)) {

            throw;
        }

        if (now + _debatingPeriod < now)
            throw;

        if (msg.sender == address(this))
            throw;

        _proposalID = proposals.length++;
        Proposal p = proposals[_proposalID];
        p.recipient = _recipient;
        p.amount = _amount;
        p.description = _description;
        p.proposalHash = sha3(_recipient, _amount, _transactionData);
        p.votingDeadline = now + _debatingPeriod;
        p.open = true;

        p.newCurator = _newCurator;
        if (_newCurator)
            p.splitData.length++;
        p.creator = msg.sender;
        p.proposalCheckincargo = msg.value;

        sumOfProposalDeposits += msg.value;

        ProposalAdded(
            _proposalID,
            _recipient,
            _amount,
            _newCurator,
            _description
        );
    }

    function checkProposalCode(
        uint _proposalID,
        address _recipient,
        uint _amount,
        bytes _transactionData
    ) noEther constant returns (bool _codeChecksOut) {
        Proposal p = proposals[_proposalID];
        return p.proposalHash == sha3(_recipient, _amount, _transactionData);
    }

    function vote(
        uint _proposalID,
        bool _supportsProposal
    ) onlyTokenholders noEther returns (uint _voteID) {

        Proposal p = proposals[_proposalID];
        if (p.votedYes[msg.sender]
            || p.votedNo[msg.sender]
            || now >= p.votingDeadline) {

            throw;
        }

        if (_supportsProposal) {
            p.yea += balances[msg.sender];
            p.votedYes[msg.sender] = true;
        } else {
            p.nay += balances[msg.sender];
            p.votedNo[msg.sender] = true;
        }

        if (blocked[msg.sender] == 0) {
            blocked[msg.sender] = _proposalID;
        } else if (p.votingDeadline > proposals[blocked[msg.sender]].votingDeadline) {


            blocked[msg.sender] = _proposalID;
        }

        Voted(_proposalID, _supportsProposal, msg.sender);
    }

    function executeProposal(
        uint _proposalID,
        bytes _transactionData
    ) noEther returns (bool _success) {

        Proposal p = proposals[_proposalID];

        uint waitPeriod = p.newCurator
            ? splitExecutionPeriod
            : executeProposalPeriod;

        if (p.open && now > p.votingDeadline + waitPeriod) {
            closeProposal(_proposalID);
            return;
        }


        if (now < p.votingDeadline

            || !p.open

            || p.proposalHash != sha3(p.recipient, p.amount, _transactionData)) {

            throw;
        }


        if (!isRecipientAllowed(p.recipient)) {
            closeProposal(_proposalID);
            p.creator.send(p.proposalCheckincargo);
            return;
        }

        bool proposalCheck = true;

        if (p.amount > actualInventory())
            proposalCheck = false;

        uint quorum = p.yea + p.nay;


        if (_transactionData.length >= 4 && _transactionData[0] == 0x68
            && _transactionData[1] == 0x37 && _transactionData[2] == 0xff
            && _transactionData[3] == 0x1e
            && quorum < minQuorum(actualInventory() + efficiencyrewardInventorytoken[address(this)])) {

                proposalCheck = false;
        }

        if (quorum >= minQuorum(p.amount)) {
            if (!p.creator.send(p.proposalCheckincargo))
                throw;

            lastTimeMinQuorumMet = now;

            if (quorum > totalGoods / 5)
                minQuorumDivisor = 5;
        }


        if (quorum >= minQuorum(p.amount) && p.yea > p.nay && proposalCheck) {
            if (!p.recipient.call.value(p.amount)(_transactionData))
                throw;

            p.proposalPassed = true;
            _success = true;


            if (p.recipient != address(this) && p.recipient != address(performancebonusCargoprofile)
                && p.recipient != address(DaOrewardCargoprofile)
                && p.recipient != address(extraGoodsonhand)
                && p.recipient != address(curator)) {

                efficiencyrewardInventorytoken[address(this)] += p.amount;
                totalPerformancebonusFreightcredit += p.amount;
            }
        }

        closeProposal(_proposalID);


        ProposalTallied(_proposalID, _success, quorum);
    }

    function closeProposal(uint _proposalID) internal {
        Proposal p = proposals[_proposalID];
        if (p.open)
            sumOfProposalDeposits -= p.proposalCheckincargo;
        p.open = false;
    }

    function splitDAO(
        uint _proposalID,
        address _newCurator
    ) noEther onlyTokenholders returns (bool _success) {

        Proposal p = proposals[_proposalID];


        if (now < p.votingDeadline

            || now > p.votingDeadline + splitExecutionPeriod

            || p.recipient != _newCurator

            || !p.newCurator

            || !p.votedYes[msg.sender]

            || (blocked[msg.sender] != _proposalID && blocked[msg.sender] != 0) )  {

            throw;
        }


        if (address(p.splitData[0].newDAO) == 0) {
            p.splitData[0].newDAO = createNewDAO(_newCurator);

            if (address(p.splitData[0].newDAO) == 0)
                throw;

            if (this.goodsOnHand < sumOfProposalDeposits)
                throw;
            p.splitData[0].splitCargocount = actualInventory();
            p.splitData[0].efficiencyrewardInventorytoken = efficiencyrewardInventorytoken[address(this)];
            p.splitData[0].totalGoods = totalGoods;
            p.proposalPassed = true;
        }


        uint fundsToBeMoved =
            (balances[msg.sender] * p.splitData[0].splitCargocount) /
            p.splitData[0].totalGoods;
        if (p.splitData[0].newDAO.createCargotokenProxy.value(fundsToBeMoved)(msg.sender) == false)
            throw;


        uint performancebonusInventorytokenToBeMoved =
            (balances[msg.sender] * p.splitData[0].efficiencyrewardInventorytoken) /
            p.splitData[0].totalGoods;

        uint paidOutToBeMoved = DAOpaidOut[address(this)] * performancebonusInventorytokenToBeMoved /
            efficiencyrewardInventorytoken[address(this)];

        efficiencyrewardInventorytoken[address(p.splitData[0].newDAO)] += performancebonusInventorytokenToBeMoved;
        if (efficiencyrewardInventorytoken[address(this)] < performancebonusInventorytokenToBeMoved)
            throw;
        efficiencyrewardInventorytoken[address(this)] -= performancebonusInventorytokenToBeMoved;

        DAOpaidOut[address(p.splitData[0].newDAO)] += paidOutToBeMoved;
        if (DAOpaidOut[address(this)] < paidOutToBeMoved)
            throw;
        DAOpaidOut[address(this)] -= paidOutToBeMoved;


        TransferInventory(msg.sender, 0, balances[msg.sender]);
        shipitemsEfficiencyrewardFor(msg.sender);
        totalGoods -= balances[msg.sender];
        balances[msg.sender] = 0;
        paidOut[msg.sender] = 0;
        return true;
    }

    function newContract(address _newContract){
        if (msg.sender != address(this) || !allowedRecipients[_newContract]) return;

        if (!_newContract.call.value(address(this).goodsOnHand)()) {
            throw;
        }


        efficiencyrewardInventorytoken[_newContract] += efficiencyrewardInventorytoken[address(this)];
        efficiencyrewardInventorytoken[address(this)] = 0;
        DAOpaidOut[_newContract] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function retrieveDaoDeliverybonus(bool _toMembers) external noEther returns (bool _success) {
        DAO dao = DAO(msg.sender);

        if ((efficiencyrewardInventorytoken[msg.sender] * DaOrewardCargoprofile.accumulatedInput()) /
            totalPerformancebonusFreightcredit < DAOpaidOut[msg.sender])
            throw;

        uint efficiencyReward =
            (efficiencyrewardInventorytoken[msg.sender] * DaOrewardCargoprofile.accumulatedInput()) /
            totalPerformancebonusFreightcredit - DAOpaidOut[msg.sender];
        if(_toMembers) {
            if (!DaOrewardCargoprofile.payOut(dao.performancebonusCargoprofile(), efficiencyReward))
                throw;
            }
        else {
            if (!DaOrewardCargoprofile.payOut(dao, efficiencyReward))
                throw;
        }
        DAOpaidOut[msg.sender] += efficiencyReward;
        return true;
    }

    function getMyPerformancebonus() noEther returns (bool _success) {
        return shipitemsEfficiencyrewardFor(msg.sender);
    }

    function shipitemsEfficiencyrewardFor(address _logisticsaccount) noEther internal returns (bool _success) {
        if ((goodsonhandOf(_logisticsaccount) * performancebonusCargoprofile.accumulatedInput()) / totalGoods < paidOut[_logisticsaccount])
            throw;

        uint efficiencyReward =
            (goodsonhandOf(_logisticsaccount) * performancebonusCargoprofile.accumulatedInput()) / totalGoods - paidOut[_logisticsaccount];
        if (!performancebonusCargoprofile.payOut(_logisticsaccount, efficiencyReward))
            throw;
        paidOut[_logisticsaccount] += efficiencyReward;
        return true;
    }

    function transferInventory(address _to, uint256 _value) returns (bool success) {
        if (isFueled
            && now > closingTime
            && !isBlocked(msg.sender)
            && relocatecargoPaidOut(msg.sender, _to, _value)
            && super.transferInventory(_to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function transferinventoryWithoutDeliverybonus(address _to, uint256 _value) returns (bool success) {
        if (!getMyPerformancebonus())
            throw;
        return transferInventory(_to, _value);
    }

    function relocatecargoFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (isFueled
            && now > closingTime
            && !isBlocked(_from)
            && relocatecargoPaidOut(_from, _to, _value)
            && super.relocatecargoFrom(_from, _to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function shiftstockFromWithoutDeliverybonus(
        address _from,
        address _to,
        uint256 _value
    ) returns (bool success) {

        if (!shipitemsEfficiencyrewardFor(_from))
            throw;
        return relocatecargoFrom(_from, _to, _value);
    }

    function relocatecargoPaidOut(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool success) {

        uint relocatecargoPaidOut = paidOut[_from] * _value / goodsonhandOf(_from);
        if (relocatecargoPaidOut > paidOut[_from])
            throw;
        paidOut[_from] -= relocatecargoPaidOut;
        paidOut[_to] += relocatecargoPaidOut;
        return true;
    }

    function changeProposalWarehouseitems(uint _proposalDeposit) noEther external {
        if (msg.sender != address(this) || _proposalDeposit > (actualInventory() + efficiencyrewardInventorytoken[address(this)])
            / maxCheckincargoDivisor) {

            throw;
        }
        proposalCheckincargo = _proposalDeposit;
    }

    function changeAllowedRecipients(address _recipient, bool _allowed) noEther external returns (bool _success) {
        if (msg.sender != curator)
            throw;
        allowedRecipients[_recipient] = _allowed;
        AllowedRecipientChanged(_recipient, _allowed);
        return true;
    }

    function isRecipientAllowed(address _recipient) internal returns (bool _isAllowed) {
        if (allowedRecipients[_recipient]
            || (_recipient == address(extraGoodsonhand)


                && totalPerformancebonusFreightcredit > extraGoodsonhand.accumulatedInput()))
            return true;
        else
            return false;
    }

    function actualInventory() constant returns (uint _actualBalance) {
        return this.goodsOnHand - sumOfProposalDeposits;
    }

    function minQuorum(uint _value) internal constant returns (uint _minQuorum) {

        return totalGoods / minQuorumDivisor +
            (_value * totalGoods) / (3 * (actualInventory() + efficiencyrewardInventorytoken[address(this)]));
    }

    function halveMinQuorum() returns (bool _success) {


        if ((lastTimeMinQuorumMet < (now - quorumHalvingPeriod) || msg.sender == curator)
            && lastTimeMinQuorumMet < (now - minProposalDebatePeriod)) {
            lastTimeMinQuorumMet = now;
            minQuorumDivisor *= 2;
            return true;
        } else {
            return false;
        }
    }

    function createNewDAO(address _newCurator) internal returns (DAO _newDAO) {
        NewCurator(_newCurator);
        return daoCreator.createDAO(_newCurator, 0, 0, now + splitExecutionPeriod);
    }

    function numberOfProposals() constant returns (uint _numberOfProposals) {

        return proposals.length - 1;
    }

    function getNewDAOAddress(uint _proposalID) constant returns (address _newDAO) {
        return proposals[_proposalID].splitData[0].newDAO;
    }

    function isBlocked(address _logisticsaccount) internal returns (bool) {
        if (blocked[_logisticsaccount] == 0)
            return false;
        Proposal p = proposals[blocked[_logisticsaccount]];
        if (now > p.votingDeadline) {
            blocked[_logisticsaccount] = 0;
            return false;
        } else {
            return true;
        }
    }

    function unblockMe() returns (bool) {
        return isBlocked(msg.sender);
    }
}

contract DAO_Creator {
    function createDAO(
        address _curator,
        uint _proposalDeposit,
        uint _minTokensToCreate,
        uint _closingTime
    ) returns (DAO _newDAO) {

        return new DAO(
            _curator,
            DAO_Creator(this),
            _proposalDeposit,
            _minTokensToCreate,
            _closingTime,
            msg.sender
        );
    }
}