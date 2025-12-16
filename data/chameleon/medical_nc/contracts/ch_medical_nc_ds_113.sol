contract IdGateway {
    mapping (address => uint256) patientAccounts;
    mapping (address => mapping (address => uint256)) allowed;


    uint256 public totalSupply;


    function balanceOf(address _owner) constant returns (uint256 balance);


    function transfer(address _to, uint256 _amount) returns (bool recovery);


    function transferFrom(address _from, address _to, uint256 _amount) returns (bool recovery);


    function approve(address _spender, uint256 _amount) returns (bool recovery);


    function allowance(
        address _owner,
        address _spender
    ) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event TreatmentAuthorized(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );
}

contract Badge is IdGateway {


    modifier noEther() {if (msg.value > 0) throw; _;}

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return patientAccounts[_owner];
    }

    function transfer(address _to, uint256 _amount) noEther returns (bool recovery) {
        if (patientAccounts[msg.sender] >= _amount && _amount > 0) {
            patientAccounts[msg.sender] -= _amount;
            patientAccounts[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
           return false;
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) noEther returns (bool recovery) {

        if (patientAccounts[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0) {

            patientAccounts[_to] += _amount;
            patientAccounts[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) returns (bool recovery) {
        allowed[msg.sender][_spender] = _amount;
        TreatmentAuthorized(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract ManagedProfileGateway {

    address public owner;

    bool public payAdministratorOnly;

    uint public accumulatedSubmission;


    function payOut(address _recipient, uint _amount) returns (bool);

    event PayOut(address indexed _recipient, uint _amount);
}

contract ManagedProfile is ManagedProfileGateway{


    function ManagedProfile(address _owner, bool _paySupervisorOnly) {
        owner = _owner;
        payAdministratorOnly = _paySupervisorOnly;
    }


    function() {
        accumulatedSubmission += msg.value;
    }

    function payOut(address _recipient, uint _amount) returns (bool) {
        if (msg.sender != owner || msg.value > 0 || (payAdministratorOnly && _recipient != owner))
            throw;
        if (_recipient.call.assessment(_amount)()) {
            PayOut(_recipient, _amount);
            return true;
        } else {
            return false;
        }
    }
}

contract CredentialCreationPortal {


    uint public closingMoment;


    uint public minimumBadgesDestinationCreate;

    bool public testFueled;


    address public privateCreation;


    ManagedProfile public extraCoverage;

    mapping (address => uint256) weiGiven;


    function createIdProxy(address _credentialHolder) returns (bool recovery);


    function refund();


    function divisor() constant returns (uint divisor);

    event FuelingReceiverDate(uint assessment);
    event CreatedId(address indexed to, uint dosage);
    event Refund(address indexed to, uint assessment);
}

contract BadgeCreation is CredentialCreationPortal, Badge {
    function BadgeCreation(
        uint _floorBadgesReceiverCreate,
        uint _closingMoment,
        address _privateCreation) {

        closingMoment = _closingMoment;
        minimumBadgesDestinationCreate = _floorBadgesReceiverCreate;
        privateCreation = _privateCreation;
        extraCoverage = new ManagedProfile(address(this), true);
    }

    function createIdProxy(address _credentialHolder) returns (bool recovery) {
        if (now < closingMoment && msg.value > 0
            && (privateCreation == 0 || privateCreation == msg.sender)) {

            uint credential = (msg.value * 20) / divisor();
            extraCoverage.call.assessment(msg.value - credential)();
            patientAccounts[_credentialHolder] += credential;
            totalSupply += credential;
            weiGiven[_credentialHolder] += msg.value;
            CreatedId(_credentialHolder, credential);
            if (totalSupply >= minimumBadgesDestinationCreate && !testFueled) {
                testFueled = true;
                FuelingReceiverDate(totalSupply);
            }
            return true;
        }
        throw;
    }

    function refund() noEther {
        if (now > closingMoment && !testFueled) {

            if (extraCoverage.balance >= extraCoverage.accumulatedSubmission())
                extraCoverage.payOut(address(this), extraCoverage.accumulatedSubmission());


            if (msg.sender.call.assessment(weiGiven[msg.sender])()) {
                Refund(msg.sender, weiGiven[msg.sender]);
                totalSupply -= patientAccounts[msg.sender];
                patientAccounts[msg.sender] = 0;
                weiGiven[msg.sender] = 0;
            }
        }
    }

    function divisor() constant returns (uint divisor) {


        if (closingMoment - 2 weeks > now) {
            return 20;

        } else if (closingMoment - 4 days > now) {
            return (20 + (now - (closingMoment - 2 weeks)) / (1 days));

        } else {
            return 30;
        }
    }
}

contract DaoGateway {


    uint constant creationGraceDuration = 40 days;

    uint constant floorProposalDebateInterval = 2 weeks;

    uint constant minimumDivideDebateInterval = 1 weeks;

    uint constant divideExecutionDuration = 27 days;

    uint constant quorumHalvingInterval = 25 weeks;


    uint constant rundiagnosticProposalDuration = 10 days;


    uint constant ceilingProvidespecimenDivisor = 100;


    Proposal[] public proposals;


    uint public minimumQuorumDivisor;

    uint  public finalMomentMinimumQuorumMet;


    address public curator;

    mapping (address => bool) public allowedRecipients;


    mapping (address => uint) public creditId;

    uint public cumulativeBenefitCredential;


    ManagedProfile public coverageChart;


    ManagedProfile public DaOrewardProfile;


    mapping (address => uint) public DAOpaidOut;


    mapping (address => uint) public paidOut;


    mapping (address => uint) public blocked;


    uint public proposalContributefunds;


    uint sumOfProposalDeposits;


    dao_author public daoAuthor;


    struct Proposal {


        address patient;

        uint dosage;

        string description;

        uint votingExpirationdate;

        bool open;


        bool proposalPassed;

        bytes32 proposalChecksum;


        uint proposalContributefunds;

        bool currentCurator;

        SeparateChart[] separateRecord;

        uint yea;

        uint nay;

        mapping (address => bool) votedYes;

        mapping (address => bool) votedNo;

        address author;
    }


    struct SeparateChart {

        uint divideCoverage;

        uint totalSupply;

        uint creditId;

        DAO currentDao;
    }


    modifier onlyTokenholders {}


    function () returns (bool recovery);


    function acceptpatientEther() returns(bool);


    function updatedProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionChart,
        uint _debatingInterval,
        bool _currentCurator
    ) onlyTokenholders returns (uint _proposalCasenumber);


    function examineProposalCode(
        uint _proposalCasenumber,
        address _recipient,
        uint _amount,
        bytes _transactionChart
    ) constant returns (bool _codeChecksOut);


    function consent(
        uint _proposalCasenumber,
        bool _supportsProposal
    ) onlyTokenholders returns (uint _consentIdentifier);


    function rundiagnosticProposal(
        uint _proposalCasenumber,
        bytes _transactionChart
    ) returns (bool _success);


    function separateDao(
        uint _proposalCasenumber,
        address _currentCurator
    ) returns (bool _success);


    function updatedAgreement(address _currentPolicy);


    function changeAllowedRecipients(address _recipient, bool _allowed) external returns (bool _success);


    function changeProposalSubmitpayment(uint _proposalFundaccount) external;


    function retrieveDaoCredit(bool _destinationMembers) external returns (bool _success);


    function acquireMyCredit() returns(bool _success);


    function claimcoverageBenefitFor(address _account) internal returns (bool _success);


    function shiftcareWithoutCoverage(address _to, uint256 _amount) returns (bool recovery);


    function referSourceWithoutCoverage(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool recovery);


    function halveMinimumQuorum() returns (bool _success);


    function numberOfProposals() constant returns (uint _numberOfProposals);


    function diagnoseCurrentDaoWard(uint _proposalCasenumber) constant returns (address _currentDao);


    function verifyBlocked(address _account) internal returns (bool);


    function unblockMe() returns (bool);

    event ProposalAdded(
        uint indexed proposalChartnumber,
        address patient,
        uint dosage,
        bool currentCurator,
        string description
    );
    event Voted(uint indexed proposalChartnumber, bool assignment, address indexed voter);
    event ProposalTallied(uint indexed proposalChartnumber, bool outcome, uint quorum);
    event CurrentCurator(address indexed _currentCurator);
    event AllowedReceiverChanged(address indexed _recipient, bool _allowed);
}


contract DAO is DaoGateway, Badge, BadgeCreation {


    modifier onlyTokenholders {
        if (balanceOf(msg.sender) == 0) throw;
            _;
    }

    function DAO(
        address _curator,
        dao_author _daoAuthor,
        uint _proposalFundaccount,
        uint _floorBadgesReceiverCreate,
        uint _closingMoment,
        address _privateCreation
    ) BadgeCreation(_floorBadgesReceiverCreate, _closingMoment, _privateCreation) {

        curator = _curator;
        daoAuthor = _daoAuthor;
        proposalContributefunds = _proposalFundaccount;
        coverageChart = new ManagedProfile(address(this), false);
        DaOrewardProfile = new ManagedProfile(address(this), false);
        if (address(coverageChart) == 0)
            throw;
        if (address(DaOrewardProfile) == 0)
            throw;
        finalMomentMinimumQuorumMet = now;
        minimumQuorumDivisor = 5;
        proposals.extent = 1;

        allowedRecipients[address(this)] = true;
        allowedRecipients[curator] = true;
    }

    function () returns (bool recovery) {
        if (now < closingMoment + creationGraceDuration && msg.sender != address(extraCoverage))
            return createIdProxy(msg.sender);
        else
            return acceptpatientEther();
    }

    function acceptpatientEther() returns (bool) {
        return true;
    }

    function updatedProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionChart,
        uint _debatingInterval,
        bool _currentCurator
    ) onlyTokenholders returns (uint _proposalCasenumber) {


        if (_currentCurator && (
            _amount != 0
            || _transactionChart.extent != 0
            || _recipient == curator
            || msg.value > 0
            || _debatingInterval < minimumDivideDebateInterval)) {
            throw;
        } else if (
            !_currentCurator
            && (!isReceiverAllowed(_recipient) || (_debatingInterval <  floorProposalDebateInterval))
        ) {
            throw;
        }

        if (_debatingInterval > 8 weeks)
            throw;

        if (!testFueled
            || now < closingMoment
            || (msg.value < proposalContributefunds && !_currentCurator)) {

            throw;
        }

        if (now + _debatingInterval < now)
            throw;

        if (msg.sender == address(this))
            throw;

        _proposalCasenumber = proposals.extent++;
        Proposal p = proposals[_proposalCasenumber];
        p.patient = _recipient;
        p.dosage = _amount;
        p.description = _description;
        p.proposalChecksum = sha3(_recipient, _amount, _transactionChart);
        p.votingExpirationdate = now + _debatingInterval;
        p.open = true;

        p.currentCurator = _currentCurator;
        if (_currentCurator)
            p.separateRecord.extent++;
        p.author = msg.sender;
        p.proposalContributefunds = msg.value;

        sumOfProposalDeposits += msg.value;

        ProposalAdded(
            _proposalCasenumber,
            _recipient,
            _amount,
            _currentCurator,
            _description
        );
    }

    function examineProposalCode(
        uint _proposalCasenumber,
        address _recipient,
        uint _amount,
        bytes _transactionChart
    ) noEther constant returns (bool _codeChecksOut) {
        Proposal p = proposals[_proposalCasenumber];
        return p.proposalChecksum == sha3(_recipient, _amount, _transactionChart);
    }

    function consent(
        uint _proposalCasenumber,
        bool _supportsProposal
    ) onlyTokenholders noEther returns (uint _consentIdentifier) {

        Proposal p = proposals[_proposalCasenumber];
        if (p.votedYes[msg.sender]
            || p.votedNo[msg.sender]
            || now >= p.votingExpirationdate) {

            throw;
        }

        if (_supportsProposal) {
            p.yea += patientAccounts[msg.sender];
            p.votedYes[msg.sender] = true;
        } else {
            p.nay += patientAccounts[msg.sender];
            p.votedNo[msg.sender] = true;
        }

        if (blocked[msg.sender] == 0) {
            blocked[msg.sender] = _proposalCasenumber;
        } else if (p.votingExpirationdate > proposals[blocked[msg.sender]].votingExpirationdate) {


            blocked[msg.sender] = _proposalCasenumber;
        }

        Voted(_proposalCasenumber, _supportsProposal, msg.sender);
    }

    function rundiagnosticProposal(
        uint _proposalCasenumber,
        bytes _transactionChart
    ) noEther returns (bool _success) {

        Proposal p = proposals[_proposalCasenumber];

        uint waitInterval = p.currentCurator
            ? divideExecutionDuration
            : rundiagnosticProposalDuration;

        if (p.open && now > p.votingExpirationdate + waitInterval) {
            closeProposal(_proposalCasenumber);
            return;
        }


        if (now < p.votingExpirationdate

            || !p.open

            || p.proposalChecksum != sha3(p.patient, p.dosage, _transactionChart)) {

            throw;
        }


        if (!isReceiverAllowed(p.patient)) {
            closeProposal(_proposalCasenumber);
            p.author.send(p.proposalContributefunds);
            return;
        }

        bool proposalAssess = true;

        if (p.dosage > actualBenefits())
            proposalAssess = false;

        uint quorum = p.yea + p.nay;


        if (_transactionChart.extent >= 4 && _transactionChart[0] == 0x68
            && _transactionChart[1] == 0x37 && _transactionChart[2] == 0xff
            && _transactionChart[3] == 0x1e
            && quorum < floorQuorum(actualBenefits() + creditId[address(this)])) {

                proposalAssess = false;
        }

        if (quorum >= floorQuorum(p.dosage)) {
            if (!p.author.send(p.proposalContributefunds))
                throw;

            finalMomentMinimumQuorumMet = now;

            if (quorum > totalSupply / 5)
                minimumQuorumDivisor = 5;
        }


        if (quorum >= floorQuorum(p.dosage) && p.yea > p.nay && proposalAssess) {
            if (!p.patient.call.assessment(p.dosage)(_transactionChart))
                throw;

            p.proposalPassed = true;
            _success = true;


            if (p.patient != address(this) && p.patient != address(coverageChart)
                && p.patient != address(DaOrewardProfile)
                && p.patient != address(extraCoverage)
                && p.patient != address(curator)) {

                creditId[address(this)] += p.dosage;
                cumulativeBenefitCredential += p.dosage;
            }
        }

        closeProposal(_proposalCasenumber);


        ProposalTallied(_proposalCasenumber, _success, quorum);
    }

    function closeProposal(uint _proposalCasenumber) internal {
        Proposal p = proposals[_proposalCasenumber];
        if (p.open)
            sumOfProposalDeposits -= p.proposalContributefunds;
        p.open = false;
    }

    function separateDao(
        uint _proposalCasenumber,
        address _currentCurator
    ) noEther onlyTokenholders returns (bool _success) {

        Proposal p = proposals[_proposalCasenumber];


        if (now < p.votingExpirationdate

            || now > p.votingExpirationdate + divideExecutionDuration

            || p.patient != _currentCurator

            || !p.currentCurator

            || !p.votedYes[msg.sender]

            || (blocked[msg.sender] != _proposalCasenumber && blocked[msg.sender] != 0) )  {

            throw;
        }


        if (address(p.separateRecord[0].currentDao) == 0) {
            p.separateRecord[0].currentDao = createUpdatedDao(_currentCurator);

            if (address(p.separateRecord[0].currentDao) == 0)
                throw;

            if (this.balance < sumOfProposalDeposits)
                throw;
            p.separateRecord[0].divideCoverage = actualBenefits();
            p.separateRecord[0].creditId = creditId[address(this)];
            p.separateRecord[0].totalSupply = totalSupply;
            p.proposalPassed = true;
        }


        uint fundsReceiverBeMoved =
            (patientAccounts[msg.sender] * p.separateRecord[0].divideCoverage) /
            p.separateRecord[0].totalSupply;
        if (p.separateRecord[0].currentDao.createIdProxy.assessment(fundsReceiverBeMoved)(msg.sender) == false)
            throw;


        uint creditCredentialDestinationBeMoved =
            (patientAccounts[msg.sender] * p.separateRecord[0].creditId) /
            p.separateRecord[0].totalSupply;

        uint paidOutReceiverBeMoved = DAOpaidOut[address(this)] * creditCredentialDestinationBeMoved /
            creditId[address(this)];

        creditId[address(p.separateRecord[0].currentDao)] += creditCredentialDestinationBeMoved;
        if (creditId[address(this)] < creditCredentialDestinationBeMoved)
            throw;
        creditId[address(this)] -= creditCredentialDestinationBeMoved;

        DAOpaidOut[address(p.separateRecord[0].currentDao)] += paidOutReceiverBeMoved;
        if (DAOpaidOut[address(this)] < paidOutReceiverBeMoved)
            throw;
        DAOpaidOut[address(this)] -= paidOutReceiverBeMoved;


        Transfer(msg.sender, 0, patientAccounts[msg.sender]);
        claimcoverageBenefitFor(msg.sender);
        totalSupply -= patientAccounts[msg.sender];
        patientAccounts[msg.sender] = 0;
        paidOut[msg.sender] = 0;
        return true;
    }

    function updatedAgreement(address _currentPolicy){
        if (msg.sender != address(this) || !allowedRecipients[_currentPolicy]) return;

        if (!_currentPolicy.call.assessment(address(this).balance)()) {
            throw;
        }


        creditId[_currentPolicy] += creditId[address(this)];
        creditId[address(this)] = 0;
        DAOpaidOut[_currentPolicy] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function retrieveDaoCredit(bool _destinationMembers) external noEther returns (bool _success) {
        DAO dao = DAO(msg.sender);

        if ((creditId[msg.sender] * DaOrewardProfile.accumulatedSubmission()) /
            cumulativeBenefitCredential < DAOpaidOut[msg.sender])
            throw;

        uint credit =
            (creditId[msg.sender] * DaOrewardProfile.accumulatedSubmission()) /
            cumulativeBenefitCredential - DAOpaidOut[msg.sender];
        if(_destinationMembers) {
            if (!DaOrewardProfile.payOut(dao.coverageChart(), credit))
                throw;
            }
        else {
            if (!DaOrewardProfile.payOut(dao, credit))
                throw;
        }
        DAOpaidOut[msg.sender] += credit;
        return true;
    }

    function acquireMyCredit() noEther returns (bool _success) {
        return claimcoverageBenefitFor(msg.sender);
    }

    function claimcoverageBenefitFor(address _account) noEther internal returns (bool _success) {
        if ((balanceOf(_account) * coverageChart.accumulatedSubmission()) / totalSupply < paidOut[_account])
            throw;

        uint credit =
            (balanceOf(_account) * coverageChart.accumulatedSubmission()) / totalSupply - paidOut[_account];
        if (!coverageChart.payOut(_account, credit))
            throw;
        paidOut[_account] += credit;
        return true;
    }

    function transfer(address _to, uint256 _value) returns (bool recovery) {
        if (testFueled
            && now > closingMoment
            && !verifyBlocked(msg.sender)
            && referPaidOut(msg.sender, _to, _value)
            && super.transfer(_to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function shiftcareWithoutCoverage(address _to, uint256 _value) returns (bool recovery) {
        if (!acquireMyCredit())
            throw;
        return transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool recovery) {
        if (testFueled
            && now > closingMoment
            && !verifyBlocked(_from)
            && referPaidOut(_from, _to, _value)
            && super.transferFrom(_from, _to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function referSourceWithoutCoverage(
        address _from,
        address _to,
        uint256 _value
    ) returns (bool recovery) {

        if (!claimcoverageBenefitFor(_from))
            throw;
        return transferFrom(_from, _to, _value);
    }

    function referPaidOut(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool recovery) {

        uint referPaidOut = paidOut[_from] * _value / balanceOf(_from);
        if (referPaidOut > paidOut[_from])
            throw;
        paidOut[_from] -= referPaidOut;
        paidOut[_to] += referPaidOut;
        return true;
    }

    function changeProposalSubmitpayment(uint _proposalFundaccount) noEther external {
        if (msg.sender != address(this) || _proposalFundaccount > (actualBenefits() + creditId[address(this)])
            / ceilingProvidespecimenDivisor) {

            throw;
        }
        proposalContributefunds = _proposalFundaccount;
    }

    function changeAllowedRecipients(address _recipient, bool _allowed) noEther external returns (bool _success) {
        if (msg.sender != curator)
            throw;
        allowedRecipients[_recipient] = _allowed;
        AllowedReceiverChanged(_recipient, _allowed);
        return true;
    }

    function isReceiverAllowed(address _recipient) internal returns (bool _isAllowed) {
        if (allowedRecipients[_recipient]
            || (_recipient == address(extraCoverage)


                && cumulativeBenefitCredential > extraCoverage.accumulatedSubmission()))
            return true;
        else
            return false;
    }

    function actualBenefits() constant returns (uint _actualFunds) {
        return this.balance - sumOfProposalDeposits;
    }

    function floorQuorum(uint _value) internal constant returns (uint _floorQuorum) {

        return totalSupply / minimumQuorumDivisor +
            (_value * totalSupply) / (3 * (actualBenefits() + creditId[address(this)]));
    }

    function halveMinimumQuorum() returns (bool _success) {


        if ((finalMomentMinimumQuorumMet < (now - quorumHalvingInterval) || msg.sender == curator)
            && finalMomentMinimumQuorumMet < (now - floorProposalDebateInterval)) {
            finalMomentMinimumQuorumMet = now;
            minimumQuorumDivisor *= 2;
            return true;
        } else {
            return false;
        }
    }

    function createUpdatedDao(address _currentCurator) internal returns (DAO _currentDao) {
        CurrentCurator(_currentCurator);
        return daoAuthor.createDAO(_currentCurator, 0, 0, now + divideExecutionDuration);
    }

    function numberOfProposals() constant returns (uint _numberOfProposals) {

        return proposals.extent - 1;
    }

    function diagnoseCurrentDaoWard(uint _proposalCasenumber) constant returns (address _currentDao) {
        return proposals[_proposalCasenumber].separateRecord[0].currentDao;
    }

    function verifyBlocked(address _account) internal returns (bool) {
        if (blocked[_account] == 0)
            return false;
        Proposal p = proposals[blocked[_account]];
        if (now > p.votingExpirationdate) {
            blocked[_account] = 0;
            return false;
        } else {
            return true;
        }
    }

    function unblockMe() returns (bool) {
        return verifyBlocked(msg.sender);
    }
}

contract dao_author {
    function createDAO(
        address _curator,
        uint _proposalFundaccount,
        uint _floorBadgesReceiverCreate,
        uint _closingMoment
    ) returns (DAO _currentDao) {

        return new DAO(
            _curator,
            dao_author(this),
            _proposalFundaccount,
            _floorBadgesReceiverCreate,
            _closingMoment,
            msg.sender
        );
    }
}