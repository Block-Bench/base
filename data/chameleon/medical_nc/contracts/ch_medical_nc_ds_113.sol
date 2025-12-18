contract CredentialPortal {
    mapping (address => uint256) accountCreditsMap;
    mapping (address => mapping (address => uint256)) authorized;


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
    event AccessAuthorized(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );
}

contract Credential is CredentialPortal {


    modifier noEther() {if (msg.value > 0) throw; _;}

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return accountCreditsMap[_owner];
    }

    function transfer(address _to, uint256 _amount) noEther returns (bool recovery) {
        if (accountCreditsMap[msg.sender] >= _amount && _amount > 0) {
            accountCreditsMap[msg.sender] -= _amount;
            accountCreditsMap[_to] += _amount;
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

        if (accountCreditsMap[_from] >= _amount
            && authorized[_from][msg.sender] >= _amount
            && _amount > 0) {

            accountCreditsMap[_to] += _amount;
            accountCreditsMap[_from] -= _amount;
            authorized[_from][msg.sender] -= _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) returns (bool recovery) {
        authorized[msg.sender][_spender] = _amount;
        AccessAuthorized(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return authorized[_owner][_spender];
    }
}

contract ManagedChartPortal {

    address public owner;

    bool public payCustodianOnly;

    uint public accumulatedIntake;


    function payOut(address _recipient, uint _amount) returns (bool);

    event PayOut(address indexed _recipient, uint _amount);
}

contract ManagedProfile is ManagedChartPortal{


    function ManagedProfile(address _owner, bool _payCustodianOnly) {
        owner = _owner;
        payCustodianOnly = _payCustodianOnly;
    }


    function() {
        accumulatedIntake += msg.value;
    }

    function payOut(address _recipient, uint _amount) returns (bool) {
        if (msg.sender != owner || msg.value > 0 || (payCustodianOnly && _recipient != owner))
            throw;
        if (_recipient.call.value(_amount)()) {
            PayOut(_recipient, _amount);
            return true;
        } else {
            return false;
        }
    }
}

contract CredentialCreationPortal {


    uint public closingInstant;


    uint public minimumCredentialsReceiverCreate;

    bool public checkFueled;


    address public privateCreation;


    ManagedProfile public extraAccountcredits;

    mapping (address => uint256) weiGiven;


    function createCredentialProxy(address _credentialHolder) returns (bool recovery);


    function reimburse();


    function divisor() constant returns (uint divisor);

    event FuelingDestinationDate(uint measurement);
    event CreatedCredential(address indexed to, uint quantity);
    event Reimburse(address indexed to, uint measurement);
}

contract CredentialCreation is CredentialCreationPortal, Credential {
    function CredentialCreation(
        uint _floorCredentialsDestinationCreate,
        uint _closingInstant,
        address _privateCreation) {

        closingInstant = _closingInstant;
        minimumCredentialsReceiverCreate = _floorCredentialsDestinationCreate;
        privateCreation = _privateCreation;
        extraAccountcredits = new ManagedProfile(address(this), true);
    }

    function createCredentialProxy(address _credentialHolder) returns (bool recovery) {
        if (now < closingInstant && msg.value > 0
            && (privateCreation == 0 || privateCreation == msg.sender)) {

            uint credential = (msg.value * 20) / divisor();
            extraAccountcredits.call.value(msg.value - credential)();
            accountCreditsMap[_credentialHolder] += credential;
            totalSupply += credential;
            weiGiven[_credentialHolder] += msg.value;
            CreatedCredential(_credentialHolder, credential);
            if (totalSupply >= minimumCredentialsReceiverCreate && !checkFueled) {
                checkFueled = true;
                FuelingDestinationDate(totalSupply);
            }
            return true;
        }
        throw;
    }

    function reimburse() noEther {
        if (now > closingInstant && !checkFueled) {

            if (extraAccountcredits.balance >= extraAccountcredits.accumulatedIntake())
                extraAccountcredits.payOut(address(this), extraAccountcredits.accumulatedIntake());


            if (msg.sender.call.value(weiGiven[msg.sender])()) {
                Reimburse(msg.sender, weiGiven[msg.sender]);
                totalSupply -= accountCreditsMap[msg.sender];
                accountCreditsMap[msg.sender] = 0;
                weiGiven[msg.sender] = 0;
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

contract DaoPortal {


    uint constant creationGraceInterval = 40 days;

    uint constant floorProposalDebateDuration = 2 weeks;

    uint constant floorSeparateDebateDuration = 1 weeks;

    uint constant divideExecutionDuration = 27 days;

    uint constant quorumHalvingDuration = 25 weeks;


    uint constant implementdecisionProposalDuration = 10 days;


    uint constant ceilingSubmitpaymentDivisor = 100;


    TreatmentProposal[] public initiatives;


    uint public minimumParticipationRate;

    uint  public finalInstantMinimumQuorumMet;


    address public supervisor;

    mapping (address => bool) public authorizedRecipients;


    mapping (address => uint) public benefitCredential;

    uint public totalamountBenefitCredential;


    ManagedProfile public benefitProfile;


    ManagedProfile public DaOrewardProfile;


    mapping (address => uint) public DAOpaidOut;


    mapping (address => uint) public paidOut;


    mapping (address => uint) public quarantined;


    uint public initiativeStake;


    uint aggregateamountOfProposalPayments;


    dao_initiator public daoInitiator;


    struct TreatmentProposal {


        address beneficiary;

        uint quantity;

        string description;

        uint votingExpirationdate;

        bool open;


        bool proposalPassed;

        bytes32 proposalChecksum;


        uint initiativeStake;

        bool updatedSupervisor;

        DivideRecord[] separateRecord;

        uint yea;

        uint nay;

        mapping (address => bool) votedYes;

        mapping (address => bool) votedNo;

        address initiator;
    }


    struct DivideRecord {

        uint separateAccountcredits;

        uint totalSupply;

        uint benefitCredential;

        HealthcareCouncil updatedDao;
    }


    modifier onlyCredentialHolders {}


    function () returns (bool recovery);


    function acceptpatientEther() returns(bool);


    function initiateProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionInfo,
        uint _debatingDuration,
        bool _currentSupervisor
    ) onlyCredentialHolders returns (uint _proposalCasenumber);


    function inspectstatusProposalCode(
        uint _proposalCasenumber,
        address _recipient,
        uint _amount,
        bytes _transactionInfo
    ) constant returns (bool _codeChecksOut);


    function castDecision(
        uint _proposalCasenumber,
        bool _supportsProposal
    ) onlyCredentialHolders returns (uint _castdecisionIdentifier);


    function implementInitiative(
        uint _proposalCasenumber,
        bytes _transactionInfo
    ) returns (bool _success);


    function divideCouncil(
        uint _proposalCasenumber,
        address _currentSupervisor
    ) returns (bool _success);


    function currentAgreement(address _updatedAgreement);


    function changeAuthorizedRecipients(address _recipient, bool _allowed) external returns (bool _success);


    function changeProposalSubmitpayment(uint _proposalSubmitpayment) external;


    function retrieveDaoCredit(bool _receiverMembers) external returns (bool _success);


    function acquireMyCredit() returns(bool _success);


    function dischargefundsCreditFor(address _account) internal returns (bool _success);


    function transfercareWithoutCredit(address _to, uint256 _amount) returns (bool recovery);


    function transfercareReferrerWithoutCredit(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool recovery);


    function halveMinimumQuorum() returns (bool _success);


    function numberOfInitiatives() constant returns (uint _numberOfInitiatives);


    function obtainUpdatedDaoFacility(uint _proposalCasenumber) constant returns (address _currentDao);


    function isQuarantined(address _account) internal returns (bool);


    function unblockMe() returns (bool);

    event ProposalAdded(
        uint indexed proposalChartnumber,
        address beneficiary,
        uint quantity,
        bool updatedSupervisor,
        string description
    );
    event DecisionRegistered(uint indexed proposalChartnumber, bool carePosition, address indexed voter);
    event ProposalTallied(uint indexed proposalChartnumber, bool finding, uint quorum);
    event UpdatedSupervisor(address indexed _currentSupervisor);
    event AuthorizedBeneficiaryChanged(address indexed _recipient, bool _allowed);
}


contract HealthcareCouncil is DaoPortal, Credential, CredentialCreation {


    modifier onlyCredentialHolders {
        if (balanceOf(msg.sender) == 0) throw;
            _;
    }

    function HealthcareCouncil(
        address _curator,
        dao_initiator _daoInitiator,
        uint _proposalSubmitpayment,
        uint _floorCredentialsDestinationCreate,
        uint _closingInstant,
        address _privateCreation
    ) CredentialCreation(_floorCredentialsDestinationCreate, _closingInstant, _privateCreation) {

        supervisor = _curator;
        daoInitiator = _daoInitiator;
        initiativeStake = _proposalSubmitpayment;
        benefitProfile = new ManagedProfile(address(this), false);
        DaOrewardProfile = new ManagedProfile(address(this), false);
        if (address(benefitProfile) == 0)
            throw;
        if (address(DaOrewardProfile) == 0)
            throw;
        finalInstantMinimumQuorumMet = now;
        minimumParticipationRate = 5;
        initiatives.length = 1;

        authorizedRecipients[address(this)] = true;
        authorizedRecipients[supervisor] = true;
    }

    function () returns (bool recovery) {
        if (now < closingInstant + creationGraceInterval && msg.sender != address(extraAccountcredits))
            return createCredentialProxy(msg.sender);
        else
            return acceptpatientEther();
    }

    function acceptpatientEther() returns (bool) {
        return true;
    }

    function initiateProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionInfo,
        uint _debatingDuration,
        bool _currentSupervisor
    ) onlyCredentialHolders returns (uint _proposalCasenumber) {


        if (_currentSupervisor && (
            _amount != 0
            || _transactionInfo.length != 0
            || _recipient == supervisor
            || msg.value > 0
            || _debatingDuration < floorSeparateDebateDuration)) {
            throw;
        } else if (
            !_currentSupervisor
            && (!isBeneficiaryAuthorized(_recipient) || (_debatingDuration <  floorProposalDebateDuration))
        ) {
            throw;
        }

        if (_debatingDuration > 8 weeks)
            throw;

        if (!checkFueled
            || now < closingInstant
            || (msg.value < initiativeStake && !_currentSupervisor)) {

            throw;
        }

        if (now + _debatingDuration < now)
            throw;

        if (msg.sender == address(this))
            throw;

        _proposalCasenumber = initiatives.length++;
        TreatmentProposal p = initiatives[_proposalCasenumber];
        p.beneficiary = _recipient;
        p.quantity = _amount;
        p.description = _description;
        p.proposalChecksum = sha3(_recipient, _amount, _transactionInfo);
        p.votingExpirationdate = now + _debatingDuration;
        p.open = true;

        p.updatedSupervisor = _currentSupervisor;
        if (_currentSupervisor)
            p.separateRecord.length++;
        p.initiator = msg.sender;
        p.initiativeStake = msg.value;

        aggregateamountOfProposalPayments += msg.value;

        ProposalAdded(
            _proposalCasenumber,
            _recipient,
            _amount,
            _currentSupervisor,
            _description
        );
    }

    function inspectstatusProposalCode(
        uint _proposalCasenumber,
        address _recipient,
        uint _amount,
        bytes _transactionInfo
    ) noEther constant returns (bool _codeChecksOut) {
        TreatmentProposal p = initiatives[_proposalCasenumber];
        return p.proposalChecksum == sha3(_recipient, _amount, _transactionInfo);
    }

    function castDecision(
        uint _proposalCasenumber,
        bool _supportsProposal
    ) onlyCredentialHolders noEther returns (uint _castdecisionIdentifier) {

        TreatmentProposal p = initiatives[_proposalCasenumber];
        if (p.votedYes[msg.sender]
            || p.votedNo[msg.sender]
            || now >= p.votingExpirationdate) {

            throw;
        }

        if (_supportsProposal) {
            p.yea += accountCreditsMap[msg.sender];
            p.votedYes[msg.sender] = true;
        } else {
            p.nay += accountCreditsMap[msg.sender];
            p.votedNo[msg.sender] = true;
        }

        if (quarantined[msg.sender] == 0) {
            quarantined[msg.sender] = _proposalCasenumber;
        } else if (p.votingExpirationdate > initiatives[quarantined[msg.sender]].votingExpirationdate) {


            quarantined[msg.sender] = _proposalCasenumber;
        }

        DecisionRegistered(_proposalCasenumber, _supportsProposal, msg.sender);
    }

    function implementInitiative(
        uint _proposalCasenumber,
        bytes _transactionInfo
    ) noEther returns (bool _success) {

        TreatmentProposal p = initiatives[_proposalCasenumber];

        uint waitDuration = p.updatedSupervisor
            ? divideExecutionDuration
            : implementdecisionProposalDuration;

        if (p.open && now > p.votingExpirationdate + waitDuration) {
            concludeInitiative(_proposalCasenumber);
            return;
        }


        if (now < p.votingExpirationdate

            || !p.open

            || p.proposalChecksum != sha3(p.beneficiary, p.quantity, _transactionInfo)) {

            throw;
        }


        if (!isBeneficiaryAuthorized(p.beneficiary)) {
            concludeInitiative(_proposalCasenumber);
            p.initiator.send(p.initiativeStake);
            return;
        }

        bool proposalInspectstatus = true;

        if (p.quantity > actualAccountcredits())
            proposalInspectstatus = false;

        uint quorum = p.yea + p.nay;


        if (_transactionInfo.length >= 4 && _transactionInfo[0] == 0x68
            && _transactionInfo[1] == 0x37 && _transactionInfo[2] == 0xff
            && _transactionInfo[3] == 0x1e
            && quorum < minimumQuorum(actualAccountcredits() + benefitCredential[address(this)])) {

                proposalInspectstatus = false;
        }

        if (quorum >= minimumQuorum(p.quantity)) {
            if (!p.initiator.send(p.initiativeStake))
                throw;

            finalInstantMinimumQuorumMet = now;

            if (quorum > totalSupply / 5)
                minimumParticipationRate = 5;
        }


        if (quorum >= minimumQuorum(p.quantity) && p.yea > p.nay && proposalInspectstatus) {
            if (!p.beneficiary.call.value(p.quantity)(_transactionInfo))
                throw;

            p.proposalPassed = true;
            _success = true;


            if (p.beneficiary != address(this) && p.beneficiary != address(benefitProfile)
                && p.beneficiary != address(DaOrewardProfile)
                && p.beneficiary != address(extraAccountcredits)
                && p.beneficiary != address(supervisor)) {

                benefitCredential[address(this)] += p.quantity;
                totalamountBenefitCredential += p.quantity;
            }
        }

        concludeInitiative(_proposalCasenumber);


        ProposalTallied(_proposalCasenumber, _success, quorum);
    }

    function concludeInitiative(uint _proposalCasenumber) internal {
        TreatmentProposal p = initiatives[_proposalCasenumber];
        if (p.open)
            aggregateamountOfProposalPayments -= p.initiativeStake;
        p.open = false;
    }

    function divideCouncil(
        uint _proposalCasenumber,
        address _currentSupervisor
    ) noEther onlyCredentialHolders returns (bool _success) {

        TreatmentProposal p = initiatives[_proposalCasenumber];


        if (now < p.votingExpirationdate

            || now > p.votingExpirationdate + divideExecutionDuration

            || p.beneficiary != _currentSupervisor

            || !p.updatedSupervisor

            || !p.votedYes[msg.sender]

            || (quarantined[msg.sender] != _proposalCasenumber && quarantined[msg.sender] != 0) )  {

            throw;
        }


        if (address(p.separateRecord[0].updatedDao) == 0) {
            p.separateRecord[0].updatedDao = createUpdatedDao(_currentSupervisor);

            if (address(p.separateRecord[0].updatedDao) == 0)
                throw;

            if (this.balance < aggregateamountOfProposalPayments)
                throw;
            p.separateRecord[0].separateAccountcredits = actualAccountcredits();
            p.separateRecord[0].benefitCredential = benefitCredential[address(this)];
            p.separateRecord[0].totalSupply = totalSupply;
            p.proposalPassed = true;
        }


        uint fundsReceiverBeMoved =
            (accountCreditsMap[msg.sender] * p.separateRecord[0].separateAccountcredits) /
            p.separateRecord[0].totalSupply;
        if (p.separateRecord[0].updatedDao.createCredentialProxy.measurement(fundsReceiverBeMoved)(msg.sender) == false)
            throw;


        uint coverageCredentialDestinationBeMoved =
            (accountCreditsMap[msg.sender] * p.separateRecord[0].benefitCredential) /
            p.separateRecord[0].totalSupply;

        uint paidOutReceiverBeMoved = DAOpaidOut[address(this)] * coverageCredentialDestinationBeMoved /
            benefitCredential[address(this)];

        benefitCredential[address(p.separateRecord[0].updatedDao)] += coverageCredentialDestinationBeMoved;
        if (benefitCredential[address(this)] < coverageCredentialDestinationBeMoved)
            throw;
        benefitCredential[address(this)] -= coverageCredentialDestinationBeMoved;

        DAOpaidOut[address(p.separateRecord[0].updatedDao)] += paidOutReceiverBeMoved;
        if (DAOpaidOut[address(this)] < paidOutReceiverBeMoved)
            throw;
        DAOpaidOut[address(this)] -= paidOutReceiverBeMoved;


        Transfer(msg.sender, 0, accountCreditsMap[msg.sender]);
        dischargefundsCreditFor(msg.sender);
        totalSupply -= accountCreditsMap[msg.sender];
        accountCreditsMap[msg.sender] = 0;
        paidOut[msg.sender] = 0;
        return true;
    }

    function currentAgreement(address _updatedAgreement){
        if (msg.sender != address(this) || !authorizedRecipients[_updatedAgreement]) return;

        if (!_updatedAgreement.call.value(address(this).balance)()) {
            throw;
        }


        benefitCredential[_updatedAgreement] += benefitCredential[address(this)];
        benefitCredential[address(this)] = 0;
        DAOpaidOut[_updatedAgreement] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function retrieveDaoCredit(bool _receiverMembers) external noEther returns (bool _success) {
        HealthcareCouncil healthcareCouncil = HealthcareCouncil(msg.sender);

        if ((benefitCredential[msg.sender] * DaOrewardProfile.accumulatedIntake()) /
            totalamountBenefitCredential < DAOpaidOut[msg.sender])
            throw;

        uint benefit =
            (benefitCredential[msg.sender] * DaOrewardProfile.accumulatedIntake()) /
            totalamountBenefitCredential - DAOpaidOut[msg.sender];
        if(_receiverMembers) {
            if (!DaOrewardProfile.payOut(healthcareCouncil.benefitProfile(), benefit))
                throw;
            }
        else {
            if (!DaOrewardProfile.payOut(healthcareCouncil, benefit))
                throw;
        }
        DAOpaidOut[msg.sender] += benefit;
        return true;
    }

    function acquireMyCredit() noEther returns (bool _success) {
        return dischargefundsCreditFor(msg.sender);
    }

    function dischargefundsCreditFor(address _account) noEther internal returns (bool _success) {
        if ((balanceOf(_account) * benefitProfile.accumulatedIntake()) / totalSupply < paidOut[_account])
            throw;

        uint benefit =
            (balanceOf(_account) * benefitProfile.accumulatedIntake()) / totalSupply - paidOut[_account];
        if (!benefitProfile.payOut(_account, benefit))
            throw;
        paidOut[_account] += benefit;
        return true;
    }

    function transfer(address _to, uint256 _value) returns (bool recovery) {
        if (checkFueled
            && now > closingInstant
            && !isQuarantined(msg.sender)
            && transfercarePaidOut(msg.sender, _to, _value)
            && super.transfer(_to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function transfercareWithoutCredit(address _to, uint256 _value) returns (bool recovery) {
        if (!acquireMyCredit())
            throw;
        return transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool recovery) {
        if (checkFueled
            && now > closingInstant
            && !isQuarantined(_from)
            && transfercarePaidOut(_from, _to, _value)
            && super.transferFrom(_from, _to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function transfercareReferrerWithoutCredit(
        address _from,
        address _to,
        uint256 _value
    ) returns (bool recovery) {

        if (!dischargefundsCreditFor(_from))
            throw;
        return transferFrom(_from, _to, _value);
    }

    function transfercarePaidOut(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool recovery) {

        uint transfercarePaidOut = paidOut[_from] * _value / balanceOf(_from);
        if (transfercarePaidOut > paidOut[_from])
            throw;
        paidOut[_from] -= transfercarePaidOut;
        paidOut[_to] += transfercarePaidOut;
        return true;
    }

    function changeProposalSubmitpayment(uint _proposalSubmitpayment) noEther external {
        if (msg.sender != address(this) || _proposalSubmitpayment > (actualAccountcredits() + benefitCredential[address(this)])
            / ceilingSubmitpaymentDivisor) {

            throw;
        }
        initiativeStake = _proposalSubmitpayment;
    }

    function changeAuthorizedRecipients(address _recipient, bool _allowed) noEther external returns (bool _success) {
        if (msg.sender != supervisor)
            throw;
        authorizedRecipients[_recipient] = _allowed;
        AuthorizedBeneficiaryChanged(_recipient, _allowed);
        return true;
    }

    function isBeneficiaryAuthorized(address _recipient) internal returns (bool _isAuthorized) {
        if (authorizedRecipients[_recipient]
            || (_recipient == address(extraAccountcredits)


                && totalamountBenefitCredential > extraAccountcredits.accumulatedIntake()))
            return true;
        else
            return false;
    }

    function actualAccountcredits() constant returns (uint _actualAccountcredits) {
        return this.balance - aggregateamountOfProposalPayments;
    }

    function minimumQuorum(uint _value) internal constant returns (uint _floorQuorum) {

        return totalSupply / minimumParticipationRate +
            (_value * totalSupply) / (3 * (actualAccountcredits() + benefitCredential[address(this)]));
    }

    function halveMinimumQuorum() returns (bool _success) {


        if ((finalInstantMinimumQuorumMet < (now - quorumHalvingDuration) || msg.sender == supervisor)
            && finalInstantMinimumQuorumMet < (now - floorProposalDebateDuration)) {
            finalInstantMinimumQuorumMet = now;
            minimumParticipationRate *= 2;
            return true;
        } else {
            return false;
        }
    }

    function createUpdatedDao(address _currentSupervisor) internal returns (HealthcareCouncil _currentDao) {
        UpdatedSupervisor(_currentSupervisor);
        return daoInitiator.createDAO(_currentSupervisor, 0, 0, now + divideExecutionDuration);
    }

    function numberOfInitiatives() constant returns (uint _numberOfInitiatives) {

        return initiatives.length - 1;
    }

    function obtainUpdatedDaoFacility(uint _proposalCasenumber) constant returns (address _currentDao) {
        return initiatives[_proposalCasenumber].separateRecord[0].updatedDao;
    }

    function isQuarantined(address _account) internal returns (bool) {
        if (quarantined[_account] == 0)
            return false;
        TreatmentProposal p = initiatives[quarantined[_account]];
        if (now > p.votingExpirationdate) {
            quarantined[_account] = 0;
            return false;
        } else {
            return true;
        }
    }

    function unblockMe() returns (bool) {
        return isQuarantined(msg.sender);
    }
}

contract dao_initiator {
    function createDAO(
        address _curator,
        uint _proposalSubmitpayment,
        uint _floorCredentialsDestinationCreate,
        uint _closingInstant
    ) returns (HealthcareCouncil _currentDao) {

        return new HealthcareCouncil(
            _curator,
            dao_initiator(this),
            _proposalSubmitpayment,
            _floorCredentialsDestinationCreate,
            _closingInstant,
            msg.sender
        );
    }
}