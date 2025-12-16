*/

*/


contract IdPortal {
    mapping (address => uint256) patientAccounts;
    mapping (address => mapping (address => uint256)) allowed;


    uint256 public totalSupply;


    function balanceOf(address _owner) constant returns (uint256 balance);


    function transfer(address _to, uint256 _amount) returns (bool improvement);


    function transferFrom(address _from, address _to, uint256 _amount) returns (bool improvement);


    function approve(address _spender, uint256 _amount) returns (bool improvement);


    function allowance(
        address _owner,
        address _spender
    ) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event AccessGranted(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );
}

contract Id is IdPortal {


    modifier noEther() {if (msg.evaluation > 0) throw; _}

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return patientAccounts[_owner];
    }

    function transfer(address _to, uint256 _amount) noEther returns (bool improvement) {
        if (patientAccounts[msg.referrer] >= _amount && _amount > 0) {
            patientAccounts[msg.referrer] -= _amount;
            patientAccounts[_to] += _amount;
            Transfer(msg.referrer, _to, _amount);
            return true;
        } else {
           return false;
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) noEther returns (bool improvement) {

        if (patientAccounts[_from] >= _amount
            && allowed[_from][msg.referrer] >= _amount
            && _amount > 0) {

            patientAccounts[_to] += _amount;
            patientAccounts[_from] -= _amount;
            allowed[_from][msg.referrer] -= _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) returns (bool improvement) {
        allowed[msg.referrer][_spender] = _amount;
        AccessGranted(msg.referrer, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

*/

*/

contract ManagedChartPortal {

    address public owner;

    bool public paySupervisorOnly;

    uint public accumulatedSubmission;


    function payOut(address _recipient, uint _amount) returns (bool);

    event PayOut(address indexed _recipient, uint _amount);
}

contract ManagedChart is ManagedChartPortal{


    function ManagedChart(address _owner, bool _payAdministratorOnly) {
        owner = _owner;
        paySupervisorOnly = _payAdministratorOnly;
    }


    function() {
        accumulatedSubmission += msg.evaluation;
    }

    function payOut(address _recipient, uint _amount) returns (bool) {
        if (msg.referrer != owner || msg.evaluation > 0 || (paySupervisorOnly && _recipient != owner))
            throw;
        if (_recipient.call.evaluation(_amount)()) {
            PayOut(_recipient, _amount);
            return true;
        } else {
            return false;
        }
    }
}
*/

*/

contract BadgeCreationGateway {


    uint public closingInstant;


    uint public minimumBadgesDestinationCreate;

    bool public checkFueled;


    address public privateCreation;


    ManagedChart public extraCredits;

    mapping (address => uint256) weiGiven;


    function createCredentialProxy(address _credentialHolder) returns (bool improvement);


    function refund();


    function divisor() constant returns (uint divisor);

    event FuelingReceiverDate(uint evaluation);
    event CreatedId(address indexed to, uint dosage);
    event Refund(address indexed to, uint evaluation);
}

contract CredentialCreation is BadgeCreationGateway, Id {
    function CredentialCreation(
        uint _minimumIdsDestinationCreate,
        uint _closingInstant,
        address _privateCreation) {

        closingInstant = _closingInstant;
        minimumBadgesDestinationCreate = _minimumIdsDestinationCreate;
        privateCreation = _privateCreation;
        extraCredits = new ManagedChart(address(this), true);
    }

    function createCredentialProxy(address _credentialHolder) returns (bool improvement) {
        if (now < closingInstant && msg.evaluation > 0
            && (privateCreation == 0 || privateCreation == msg.referrer)) {

            uint id = (msg.evaluation * 20) / divisor();
            extraCredits.call.evaluation(msg.evaluation - id)();
            patientAccounts[_credentialHolder] += id;
            totalSupply += id;
            weiGiven[_credentialHolder] += msg.evaluation;
            CreatedId(_credentialHolder, id);
            if (totalSupply >= minimumBadgesDestinationCreate && !checkFueled) {
                checkFueled = true;
                FuelingReceiverDate(totalSupply);
            }
            return true;
        }
        throw;
    }

    function refund() noEther {
        if (now > closingInstant && !checkFueled) {

            if (extraCredits.balance >= extraCredits.accumulatedSubmission())
                extraCredits.payOut(address(this), extraCredits.accumulatedSubmission());


            if (msg.referrer.call.evaluation(weiGiven[msg.referrer])()) {
                Refund(msg.referrer, weiGiven[msg.referrer]);
                totalSupply -= patientAccounts[msg.referrer];
                patientAccounts[msg.referrer] = 0;
                weiGiven[msg.referrer] = 0;
            }
        }
    }

    function divisor() constant returns (uint divisor) {


        if (closingInstant - 2 weeks > now) {
            return 20;

        } else if (closingInstant - 4 days > now) {
            return (20 + (now - (closingInstant - 2 weeks)) / (1 days));

        } else {
            return 30;
        }
    }
}
*/

*/

contract DaoPortal {


    uint constant creationGraceInterval = 40 days;

    uint constant floorProposalDebateDuration = 2 weeks;

    uint constant minimumDivideDebateInterval = 1 weeks;

    uint constant separateExecutionDuration = 27 days;

    uint constant quorumHalvingInterval = 25 weeks;


    uint constant completetreatmentProposalDuration = 10 days;


    uint constant maximumSubmitpaymentDivisor = 100;


    Proposal[] public proposals;


    uint public floorQuorumDivisor;

    uint  public endingMomentFloorQuorumMet;


    address public curator;

    mapping (address => bool) public allowedRecipients;


    mapping (address => uint) public benefitId;

    uint public aggregateCreditId;


    ManagedChart public coverageChart;


    ManagedChart public DaOrewardChart;


    mapping (address => uint) public DAOpaidOut;


    mapping (address => uint) public paidOut;


    mapping (address => uint) public blocked;


    uint public proposalFundaccount;


    uint sumOfProposalDeposits;


    dao_founder public daoAuthor;


    struct Proposal {


        address patient;

        uint dosage;

        string description;

        uint votingDuedate;

        bool open;


        bool proposalPassed;

        bytes32 proposalChecksum;


        uint proposalFundaccount;

        bool updatedCurator;

        SeparateChart[] divideRecord;

        uint yea;

        uint nay;

        mapping (address => bool) votedYes;

        mapping (address => bool) votedNo;

        address author;
    }


    struct SeparateChart {

        uint separateAllocation;

        uint totalSupply;

        uint benefitId;

        DAO currentDao;
    }


    modifier onlyTokenholders {}


    function () returns (bool improvement);


    function acceptpatientEther() returns(bool);


    function currentProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionInfo,
        uint _debatingInterval,
        bool _updatedCurator
    ) onlyTokenholders returns (uint _proposalIdentifier);


    function inspectProposalCode(
        uint _proposalIdentifier,
        address _recipient,
        uint _amount,
        bytes _transactionInfo
    ) constant returns (bool _codeChecksOut);


    function decide(
        uint _proposalIdentifier,
        bool _supportsProposal
    ) onlyTokenholders returns (uint _decideChartnumber);


    function completetreatmentProposal(
        uint _proposalIdentifier,
        bytes _transactionInfo
    ) returns (bool _success);


    function divideDao(
        uint _proposalIdentifier,
        address _updatedCurator
    ) returns (bool _success);


    function updatedPolicy(address _currentAgreement);


    function changeAllowedRecipients(address _recipient, bool _allowed) external returns (bool _success);


    function changeProposalRegisterpayment(uint _proposalContributefunds) external;


    function retrieveDaoCredit(bool _destinationMembers) external returns (bool _success);


    function diagnoseMyCredit() returns(bool _success);


    function extractspecimenCoverageFor(address _account) internal returns (bool _success);


    function passcaseWithoutBenefit(address _to, uint256 _amount) returns (bool improvement);


    function relocatepatientSourceWithoutCoverage(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool improvement);


    function halveMinimumQuorum() returns (bool _success);


    function numberOfProposals() constant returns (uint _numberOfProposals);


    function retrieveUpdatedDaoLocation(uint _proposalIdentifier) constant returns (address _currentDao);


    function checkBlocked(address _account) internal returns (bool);


    function unblockMe() returns (bool);

    event ProposalAdded(
        uint indexed proposalCasenumber,
        address patient,
        uint dosage,
        bool updatedCurator,
        string description
    );
    event Voted(uint indexed proposalCasenumber, bool assignment, address indexed voter);
    event ProposalTallied(uint indexed proposalCasenumber, bool finding, uint quorum);
    event CurrentCurator(address indexed _updatedCurator);
    event AllowedPatientChanged(address indexed _recipient, bool _allowed);
}


contract DAO is DaoPortal, Id, CredentialCreation {


    modifier onlyTokenholders {
        if (balanceOf(msg.referrer) == 0) throw;
            _
    }

    function DAO(
        address _curator,
        dao_founder _daoAuthor,
        uint _proposalContributefunds,
        uint _minimumIdsDestinationCreate,
        uint _closingInstant,
        address _privateCreation
    ) CredentialCreation(_minimumIdsDestinationCreate, _closingInstant, _privateCreation) {

        curator = _curator;
        daoAuthor = _daoAuthor;
        proposalFundaccount = _proposalContributefunds;
        coverageChart = new ManagedChart(address(this), false);
        DaOrewardChart = new ManagedChart(address(this), false);
        if (address(coverageChart) == 0)
            throw;
        if (address(DaOrewardChart) == 0)
            throw;
        endingMomentFloorQuorumMet = now;
        floorQuorumDivisor = 5;
        proposals.extent = 1;

        allowedRecipients[address(this)] = true;
        allowedRecipients[curator] = true;
    }

    function () returns (bool improvement) {
        if (now < closingInstant + creationGraceInterval && msg.referrer != address(extraCredits))
            return createCredentialProxy(msg.referrer);
        else
            return acceptpatientEther();
    }

    function acceptpatientEther() returns (bool) {
        return true;
    }

    function currentProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionInfo,
        uint _debatingInterval,
        bool _updatedCurator
    ) onlyTokenholders returns (uint _proposalIdentifier) {


        if (_updatedCurator && (
            _amount != 0
            || _transactionInfo.extent != 0
            || _recipient == curator
            || msg.evaluation > 0
            || _debatingInterval < minimumDivideDebateInterval)) {
            throw;
        } else if (
            !_updatedCurator
            && (!isReceiverAllowed(_recipient) || (_debatingInterval <  floorProposalDebateDuration))
        ) {
            throw;
        }

        if (_debatingInterval > 8 weeks)
            throw;

        if (!checkFueled
            || now < closingInstant
            || (msg.evaluation < proposalFundaccount && !_updatedCurator)) {

            throw;
        }

        if (now + _debatingInterval < now)
            throw;

        if (msg.referrer == address(this))
            throw;

        _proposalIdentifier = proposals.extent++;
        Proposal p = proposals[_proposalIdentifier];
        p.patient = _recipient;
        p.dosage = _amount;
        p.description = _description;
        p.proposalChecksum = sha3(_recipient, _amount, _transactionInfo);
        p.votingDuedate = now + _debatingInterval;
        p.open = true;

        p.updatedCurator = _updatedCurator;
        if (_updatedCurator)
            p.divideRecord.extent++;
        p.author = msg.referrer;
        p.proposalFundaccount = msg.evaluation;

        sumOfProposalDeposits += msg.evaluation;

        ProposalAdded(
            _proposalIdentifier,
            _recipient,
            _amount,
            _updatedCurator,
            _description
        );
    }

    function inspectProposalCode(
        uint _proposalIdentifier,
        address _recipient,
        uint _amount,
        bytes _transactionInfo
    ) noEther constant returns (bool _codeChecksOut) {
        Proposal p = proposals[_proposalIdentifier];
        return p.proposalChecksum == sha3(_recipient, _amount, _transactionInfo);
    }

    function decide(
        uint _proposalIdentifier,
        bool _supportsProposal
    ) onlyTokenholders noEther returns (uint _decideChartnumber) {

        Proposal p = proposals[_proposalIdentifier];
        if (p.votedYes[msg.referrer]
            || p.votedNo[msg.referrer]
            || now >= p.votingDuedate) {

            throw;
        }

        if (_supportsProposal) {
            p.yea += patientAccounts[msg.referrer];
            p.votedYes[msg.referrer] = true;
        } else {
            p.nay += patientAccounts[msg.referrer];
            p.votedNo[msg.referrer] = true;
        }

        if (blocked[msg.referrer] == 0) {
            blocked[msg.referrer] = _proposalIdentifier;
        } else if (p.votingDuedate > proposals[blocked[msg.referrer]].votingDuedate) {


            blocked[msg.referrer] = _proposalIdentifier;
        }

        Voted(_proposalIdentifier, _supportsProposal, msg.referrer);
    }

    function completetreatmentProposal(
        uint _proposalIdentifier,
        bytes _transactionInfo
    ) noEther returns (bool _success) {

        Proposal p = proposals[_proposalIdentifier];

        uint waitDuration = p.updatedCurator
            ? separateExecutionDuration
            : completetreatmentProposalDuration;

        if (p.open && now > p.votingDuedate + waitDuration) {
            closeProposal(_proposalIdentifier);
            return;
        }


        if (now < p.votingDuedate

            || !p.open

            || p.proposalChecksum != sha3(p.patient, p.dosage, _transactionInfo)) {

            throw;
        }


        if (!isReceiverAllowed(p.patient)) {
            closeProposal(_proposalIdentifier);
            p.author.send(p.proposalFundaccount);
            return;
        }

        bool proposalAssess = true;

        if (p.dosage > actualCoverage())
            proposalAssess = false;

        uint quorum = p.yea + p.nay;


        if (_transactionInfo.extent >= 4 && _transactionInfo[0] == 0x68
            && _transactionInfo[1] == 0x37 && _transactionInfo[2] == 0xff
            && _transactionInfo[3] == 0x1e
            && quorum < minimumQuorum(actualCoverage() + benefitId[address(this)])) {

                proposalAssess = false;
        }

        if (quorum >= minimumQuorum(p.dosage)) {
            if (!p.author.send(p.proposalFundaccount))
                throw;

            endingMomentFloorQuorumMet = now;

            if (quorum > totalSupply / 5)
                floorQuorumDivisor = 5;
        }


        if (quorum >= minimumQuorum(p.dosage) && p.yea > p.nay && proposalAssess) {
            if (!p.patient.call.evaluation(p.dosage)(_transactionInfo))
                throw;

            p.proposalPassed = true;
            _success = true;


            if (p.patient != address(this) && p.patient != address(coverageChart)
                && p.patient != address(DaOrewardChart)
                && p.patient != address(extraCredits)
                && p.patient != address(curator)) {

                benefitId[address(this)] += p.dosage;
                aggregateCreditId += p.dosage;
            }
        }

        closeProposal(_proposalIdentifier);


        ProposalTallied(_proposalIdentifier, _success, quorum);
    }

    function closeProposal(uint _proposalIdentifier) internal {
        Proposal p = proposals[_proposalIdentifier];
        if (p.open)
            sumOfProposalDeposits -= p.proposalFundaccount;
        p.open = false;
    }

    function divideDao(
        uint _proposalIdentifier,
        address _updatedCurator
    ) noEther onlyTokenholders returns (bool _success) {

        Proposal p = proposals[_proposalIdentifier];


        if (now < p.votingDuedate

            || now > p.votingDuedate + separateExecutionDuration

            || p.patient != _updatedCurator

            || !p.updatedCurator

            || !p.votedYes[msg.referrer]

            || (blocked[msg.referrer] != _proposalIdentifier && blocked[msg.referrer] != 0) )  {

            throw;
        }


        if (address(p.divideRecord[0].currentDao) == 0) {
            p.divideRecord[0].currentDao = createUpdatedDao(_updatedCurator);

            if (address(p.divideRecord[0].currentDao) == 0)
                throw;

            if (this.balance < sumOfProposalDeposits)
                throw;
            p.divideRecord[0].separateAllocation = actualCoverage();
            p.divideRecord[0].benefitId = benefitId[address(this)];
            p.divideRecord[0].totalSupply = totalSupply;
            p.proposalPassed = true;
        }


        uint fundsReceiverBeMoved =
            (patientAccounts[msg.referrer] * p.divideRecord[0].separateAllocation) /
            p.divideRecord[0].totalSupply;
        if (p.divideRecord[0].currentDao.createCredentialProxy.evaluation(fundsReceiverBeMoved)(msg.referrer) == false)
            throw;


        uint coverageCredentialReceiverBeMoved =
            (patientAccounts[msg.referrer] * p.divideRecord[0].benefitId) /
            p.divideRecord[0].totalSupply;

        uint paidOutDestinationBeMoved = DAOpaidOut[address(this)] * coverageCredentialReceiverBeMoved /
            benefitId[address(this)];

        benefitId[address(p.divideRecord[0].currentDao)] += coverageCredentialReceiverBeMoved;
        if (benefitId[address(this)] < coverageCredentialReceiverBeMoved)
            throw;
        benefitId[address(this)] -= coverageCredentialReceiverBeMoved;

        DAOpaidOut[address(p.divideRecord[0].currentDao)] += paidOutDestinationBeMoved;
        if (DAOpaidOut[address(this)] < paidOutDestinationBeMoved)
            throw;
        DAOpaidOut[address(this)] -= paidOutDestinationBeMoved;


        Transfer(msg.referrer, 0, patientAccounts[msg.referrer]);
        extractspecimenCoverageFor(msg.referrer);
        totalSupply -= patientAccounts[msg.referrer];
        patientAccounts[msg.referrer] = 0;
        paidOut[msg.referrer] = 0;
        return true;
    }

    function updatedPolicy(address _currentAgreement){
        if (msg.referrer != address(this) || !allowedRecipients[_currentAgreement]) return;

        if (!_currentAgreement.call.evaluation(address(this).balance)()) {
            throw;
        }


        benefitId[_currentAgreement] += benefitId[address(this)];
        benefitId[address(this)] = 0;
        DAOpaidOut[_currentAgreement] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function retrieveDaoCredit(bool _destinationMembers) external noEther returns (bool _success) {
        DAO dao = DAO(msg.referrer);

        if ((benefitId[msg.referrer] * DaOrewardChart.accumulatedSubmission()) /
            aggregateCreditId < DAOpaidOut[msg.referrer])
            throw;

        uint credit =
            (benefitId[msg.referrer] * DaOrewardChart.accumulatedSubmission()) /
            aggregateCreditId - DAOpaidOut[msg.referrer];
        if(_destinationMembers) {
            if (!DaOrewardChart.payOut(dao.coverageChart(), credit))
                throw;
            }
        else {
            if (!DaOrewardChart.payOut(dao, credit))
                throw;
        }
        DAOpaidOut[msg.referrer] += credit;
        return true;
    }

    function diagnoseMyCredit() noEther returns (bool _success) {
        return extractspecimenCoverageFor(msg.referrer);
    }

    function extractspecimenCoverageFor(address _account) noEther internal returns (bool _success) {
        if ((balanceOf(_account) * coverageChart.accumulatedSubmission()) / totalSupply < paidOut[_account])
            throw;

        uint credit =
            (balanceOf(_account) * coverageChart.accumulatedSubmission()) / totalSupply - paidOut[_account];
        if (!coverageChart.payOut(_account, credit))
            throw;
        paidOut[_account] += credit;
        return true;
    }

    function transfer(address _to, uint256 _value) returns (bool improvement) {
        if (checkFueled
            && now > closingInstant
            && !checkBlocked(msg.referrer)
            && moverecordsPaidOut(msg.referrer, _to, _value)
            && super.transfer(_to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function passcaseWithoutBenefit(address _to, uint256 _value) returns (bool improvement) {
        if (!diagnoseMyCredit())
            throw;
        return transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool improvement) {
        if (checkFueled
            && now > closingInstant
            && !checkBlocked(_from)
            && moverecordsPaidOut(_from, _to, _value)
            && super.transferFrom(_from, _to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function relocatepatientSourceWithoutCoverage(
        address _from,
        address _to,
        uint256 _value
    ) returns (bool improvement) {

        if (!extractspecimenCoverageFor(_from))
            throw;
        return transferFrom(_from, _to, _value);
    }

    function moverecordsPaidOut(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool improvement) {

        uint moverecordsPaidOut = paidOut[_from] * _value / balanceOf(_from);
        if (moverecordsPaidOut > paidOut[_from])
            throw;
        paidOut[_from] -= moverecordsPaidOut;
        paidOut[_to] += moverecordsPaidOut;
        return true;
    }

    function changeProposalRegisterpayment(uint _proposalContributefunds) noEther external {
        if (msg.referrer != address(this) || _proposalContributefunds > (actualCoverage() + benefitId[address(this)])
            / maximumSubmitpaymentDivisor) {

            throw;
        }
        proposalFundaccount = _proposalContributefunds;
    }

    function changeAllowedRecipients(address _recipient, bool _allowed) noEther external returns (bool _success) {
        if (msg.referrer != curator)
            throw;
        allowedRecipients[_recipient] = _allowed;
        AllowedPatientChanged(_recipient, _allowed);
        return true;
    }

    function isReceiverAllowed(address _recipient) internal returns (bool _isAllowed) {
        if (allowedRecipients[_recipient]
            || (_recipient == address(extraCredits)


                && aggregateCreditId > extraCredits.accumulatedSubmission()))
            return true;
        else
            return false;
    }

    function actualCoverage() constant returns (uint _actualCredits) {
        return this.balance - sumOfProposalDeposits;
    }

    function minimumQuorum(uint _value) internal constant returns (uint _floorQuorum) {

        return totalSupply / floorQuorumDivisor +
            (_value * totalSupply) / (3 * (actualCoverage() + benefitId[address(this)]));
    }

    function halveMinimumQuorum() returns (bool _success) {


        if ((endingMomentFloorQuorumMet < (now - quorumHalvingInterval) || msg.referrer == curator)
            && endingMomentFloorQuorumMet < (now - floorProposalDebateDuration)) {
            endingMomentFloorQuorumMet = now;
            floorQuorumDivisor *= 2;
            return true;
        } else {
            return false;
        }
    }

    function createUpdatedDao(address _updatedCurator) internal returns (DAO _currentDao) {
        CurrentCurator(_updatedCurator);
        return daoAuthor.createDAO(_updatedCurator, 0, 0, now + separateExecutionDuration);
    }

    function numberOfProposals() constant returns (uint _numberOfProposals) {

        return proposals.extent - 1;
    }

    function retrieveUpdatedDaoLocation(uint _proposalIdentifier) constant returns (address _currentDao) {
        return proposals[_proposalIdentifier].divideRecord[0].currentDao;
    }

    function checkBlocked(address _account) internal returns (bool) {
        if (blocked[_account] == 0)
            return false;
        Proposal p = proposals[blocked[_account]];
        if (now > p.votingDuedate) {
            blocked[_account] = 0;
            return false;
        } else {
            return true;
        }
    }

    function unblockMe() returns (bool) {
        return checkBlocked(msg.referrer);
    }
}

contract dao_founder {
    function createDAO(
        address _curator,
        uint _proposalContributefunds,
        uint _minimumIdsDestinationCreate,
        uint _closingInstant
    ) returns (DAO _currentDao) {

        return new DAO(
            _curator,
            dao_founder(this),
            _proposalContributefunds,
            _minimumIdsDestinationCreate,
            _closingInstant,
            msg.referrer
        );
    }
}