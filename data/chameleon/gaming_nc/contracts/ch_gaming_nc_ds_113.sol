contract GemPortal {
    mapping (address => uint256) heroTreasure;
    mapping (address => mapping (address => uint256)) allowed;


    uint256 public totalSupply;


    function balanceOf(address _owner) constant returns (uint256 balance);


    function transfer(address _to, uint256 _amount) returns (bool victory);


    function transferFrom(address _from, address _to, uint256 _amount) returns (bool victory);


    function approve(address _spender, uint256 _amount) returns (bool victory);


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

contract Crystal is GemPortal {


    modifier noEther() {if (msg.value > 0) throw; _;}

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return heroTreasure[_owner];
    }

    function transfer(address _to, uint256 _amount) noEther returns (bool victory) {
        if (heroTreasure[msg.sender] >= _amount && _amount > 0) {
            heroTreasure[msg.sender] -= _amount;
            heroTreasure[_to] += _amount;
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
    ) noEther returns (bool victory) {

        if (heroTreasure[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0) {

            heroTreasure[_to] += _amount;
            heroTreasure[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) returns (bool victory) {
        allowed[msg.sender][_spender] = _amount;
        AccessAuthorized(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract ManagedCharacterPortal {

    address public owner;

    bool public payMasterOnly;

    uint public accumulatedSubmission;


    function payOut(address _recipient, uint _amount) returns (bool);

    event PayOut(address indexed _recipient, uint _amount);
}

contract ManagedCharacter is ManagedCharacterPortal{


    function ManagedCharacter(address _owner, bool _payLordOnly) {
        owner = _owner;
        payMasterOnly = _payLordOnly;
    }


    function() {
        accumulatedSubmission += msg.value;
    }

    function payOut(address _recipient, uint _amount) returns (bool) {
        if (msg.sender != owner || msg.value > 0 || (payMasterOnly && _recipient != owner))
            throw;
        if (_recipient.call.price(_amount)()) {
            PayOut(_recipient, _amount);
            return true;
        } else {
            return false;
        }
    }
}

contract MedalCreationGateway {


    uint public closingInstant;


    uint public minimumCrystalsTargetCreate;

    bool public testFueled;


    address public privateCreation;


    ManagedCharacter public extraGoldholding;

    mapping (address => uint256) weiGiven;


    function createCoinProxy(address _gemHolder) returns (bool victory);


    function refund();


    function divisor() constant returns (uint divisor);

    event FuelingTargetDate(uint price);
    event CreatedCoin(address indexed to, uint sum);
    event Refund(address indexed to, uint price);
}

contract GemCreation is MedalCreationGateway, Crystal {
    function GemCreation(
        uint _floorCrystalsTargetCreate,
        uint _closingMoment,
        address _privateCreation) {

        closingInstant = _closingMoment;
        minimumCrystalsTargetCreate = _floorCrystalsTargetCreate;
        privateCreation = _privateCreation;
        extraGoldholding = new ManagedCharacter(address(this), true);
    }

    function createCoinProxy(address _gemHolder) returns (bool victory) {
        if (now < closingInstant && msg.value > 0
            && (privateCreation == 0 || privateCreation == msg.sender)) {

            uint medal = (msg.value * 20) / divisor();
            extraGoldholding.call.price(msg.value - medal)();
            heroTreasure[_gemHolder] += medal;
            totalSupply += medal;
            weiGiven[_gemHolder] += msg.value;
            CreatedCoin(_gemHolder, medal);
            if (totalSupply >= minimumCrystalsTargetCreate && !testFueled) {
                testFueled = true;
                FuelingTargetDate(totalSupply);
            }
            return true;
        }
        throw;
    }

    function refund() noEther {
        if (now > closingInstant && !testFueled) {

            if (extraGoldholding.balance >= extraGoldholding.accumulatedSubmission())
                extraGoldholding.payOut(address(this), extraGoldholding.accumulatedSubmission());


            if (msg.sender.call.price(weiGiven[msg.sender])()) {
                Refund(msg.sender, weiGiven[msg.sender]);
                totalSupply -= heroTreasure[msg.sender];
                heroTreasure[msg.sender] = 0;
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


    uint constant creationGraceDuration = 40 days;

    uint constant floorProposalDebateInterval = 2 weeks;

    uint constant minimumSeparateDebateInterval = 1 weeks;

    uint constant divideExecutionDuration = 27 days;

    uint constant quorumHalvingInterval = 25 weeks;


    uint constant runmissionProposalInterval = 10 days;


    uint constant ceilingBankwinningsDivisor = 100;


    Proposal[] public proposals;


    uint public minimumQuorumDivisor;

    uint  public endingInstantMinimumQuorumMet;


    address public curator;

    mapping (address => bool) public allowedRecipients;


    mapping (address => uint) public prizeGem;

    uint public completePrizeCrystal;


    ManagedCharacter public bonusProfile;


    ManagedCharacter public DaOrewardCharacter;


    mapping (address => uint) public DAOpaidOut;


    mapping (address => uint) public paidOut;


    mapping (address => uint) public blocked;


    uint public proposalAddtreasure;


    uint sumOfProposalDeposits;


    dao_maker public daoFounder;


    struct Proposal {


        address receiver;

        uint sum;

        string description;

        uint votingCutofftime;

        bool open;


        bool proposalPassed;

        bytes32 proposalSeal;


        uint proposalAddtreasure;

        bool updatedCurator;

        DivideInfo[] divideDetails;

        uint yea;

        uint nay;

        mapping (address => bool) votedYes;

        mapping (address => bool) votedNo;

        address maker;
    }


    struct DivideInfo {

        uint divideLootbalance;

        uint totalSupply;

        uint prizeGem;

        DAO updatedDao;
    }


    modifier onlyTokenholders {}


    function () returns (bool victory);


    function catchrewardEther() returns(bool);


    function updatedProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionInfo,
        uint _debatingDuration,
        bool _updatedCurator
    ) onlyTokenholders returns (uint _proposalCode);


    function inspectProposalCode(
        uint _proposalCode,
        address _recipient,
        uint _amount,
        bytes _transactionInfo
    ) constant returns (bool _codeChecksOut);


    function decide(
        uint _proposalCode,
        bool _supportsProposal
    ) onlyTokenholders returns (uint _castTag);


    function performactionProposal(
        uint _proposalCode,
        bytes _transactionInfo
    ) returns (bool _success);


    function separateDao(
        uint _proposalCode,
        address _updatedCurator
    ) returns (bool _success);


    function currentAgreement(address _currentAgreement);


    function changeAllowedRecipients(address _recipient, bool _allowed) external returns (bool _success);


    function changeProposalStashrewards(uint _proposalStoreloot) external;


    function retrieveDaoTreasure(bool _targetMembers) external returns (bool _success);


    function retrieveMyBonus() returns(bool _success);


    function obtainprizeTreasureFor(address _account) internal returns (bool _success);


    function tradefundsWithoutPayout(address _to, uint256 _amount) returns (bool victory);


    function shiftgoldSourceWithoutPrize(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool victory);


    function halveFloorQuorum() returns (bool _success);


    function numberOfProposals() constant returns (uint _numberOfProposals);


    function obtainUpdatedDaoZone(uint _proposalCode) constant returns (address _updatedDao);


    function checkBlocked(address _account) internal returns (bool);


    function unblockMe() returns (bool);

    event ProposalAdded(
        uint indexed proposalCode,
        address receiver,
        uint sum,
        bool updatedCurator,
        string description
    );
    event Voted(uint indexed proposalCode, bool coordinates, address indexed voter);
    event ProposalTallied(uint indexed proposalCode, bool product, uint quorum);
    event CurrentCurator(address indexed _updatedCurator);
    event AllowedTargetChanged(address indexed _recipient, bool _allowed);
}


contract DAO is DaoPortal, Crystal, GemCreation {


    modifier onlyTokenholders {
        if (balanceOf(msg.sender) == 0) throw;
            _;
    }

    function DAO(
        address _curator,
        dao_maker _daoMaker,
        uint _proposalStoreloot,
        uint _floorCrystalsTargetCreate,
        uint _closingMoment,
        address _privateCreation
    ) GemCreation(_floorCrystalsTargetCreate, _closingMoment, _privateCreation) {

        curator = _curator;
        daoFounder = _daoMaker;
        proposalAddtreasure = _proposalStoreloot;
        bonusProfile = new ManagedCharacter(address(this), false);
        DaOrewardCharacter = new ManagedCharacter(address(this), false);
        if (address(bonusProfile) == 0)
            throw;
        if (address(DaOrewardCharacter) == 0)
            throw;
        endingInstantMinimumQuorumMet = now;
        minimumQuorumDivisor = 5;
        proposals.size = 1;

        allowedRecipients[address(this)] = true;
        allowedRecipients[curator] = true;
    }

    function () returns (bool victory) {
        if (now < closingInstant + creationGraceDuration && msg.sender != address(extraGoldholding))
            return createCoinProxy(msg.sender);
        else
            return catchrewardEther();
    }

    function catchrewardEther() returns (bool) {
        return true;
    }

    function updatedProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionInfo,
        uint _debatingDuration,
        bool _updatedCurator
    ) onlyTokenholders returns (uint _proposalCode) {


        if (_updatedCurator && (
            _amount != 0
            || _transactionInfo.size != 0
            || _recipient == curator
            || msg.value > 0
            || _debatingDuration < minimumSeparateDebateInterval)) {
            throw;
        } else if (
            !_updatedCurator
            && (!isTargetAllowed(_recipient) || (_debatingDuration <  floorProposalDebateInterval))
        ) {
            throw;
        }

        if (_debatingDuration > 8 weeks)
            throw;

        if (!testFueled
            || now < closingInstant
            || (msg.value < proposalAddtreasure && !_updatedCurator)) {

            throw;
        }

        if (now + _debatingDuration < now)
            throw;

        if (msg.sender == address(this))
            throw;

        _proposalCode = proposals.size++;
        Proposal p = proposals[_proposalCode];
        p.receiver = _recipient;
        p.sum = _amount;
        p.description = _description;
        p.proposalSeal = sha3(_recipient, _amount, _transactionInfo);
        p.votingCutofftime = now + _debatingDuration;
        p.open = true;

        p.updatedCurator = _updatedCurator;
        if (_updatedCurator)
            p.divideDetails.size++;
        p.maker = msg.sender;
        p.proposalAddtreasure = msg.value;

        sumOfProposalDeposits += msg.value;

        ProposalAdded(
            _proposalCode,
            _recipient,
            _amount,
            _updatedCurator,
            _description
        );
    }

    function inspectProposalCode(
        uint _proposalCode,
        address _recipient,
        uint _amount,
        bytes _transactionInfo
    ) noEther constant returns (bool _codeChecksOut) {
        Proposal p = proposals[_proposalCode];
        return p.proposalSeal == sha3(_recipient, _amount, _transactionInfo);
    }

    function decide(
        uint _proposalCode,
        bool _supportsProposal
    ) onlyTokenholders noEther returns (uint _castTag) {

        Proposal p = proposals[_proposalCode];
        if (p.votedYes[msg.sender]
            || p.votedNo[msg.sender]
            || now >= p.votingCutofftime) {

            throw;
        }

        if (_supportsProposal) {
            p.yea += heroTreasure[msg.sender];
            p.votedYes[msg.sender] = true;
        } else {
            p.nay += heroTreasure[msg.sender];
            p.votedNo[msg.sender] = true;
        }

        if (blocked[msg.sender] == 0) {
            blocked[msg.sender] = _proposalCode;
        } else if (p.votingCutofftime > proposals[blocked[msg.sender]].votingCutofftime) {


            blocked[msg.sender] = _proposalCode;
        }

        Voted(_proposalCode, _supportsProposal, msg.sender);
    }

    function performactionProposal(
        uint _proposalCode,
        bytes _transactionInfo
    ) noEther returns (bool _success) {

        Proposal p = proposals[_proposalCode];

        uint waitDuration = p.updatedCurator
            ? divideExecutionDuration
            : runmissionProposalInterval;

        if (p.open && now > p.votingCutofftime + waitDuration) {
            closeProposal(_proposalCode);
            return;
        }


        if (now < p.votingCutofftime

            || !p.open

            || p.proposalSeal != sha3(p.receiver, p.sum, _transactionInfo)) {

            throw;
        }


        if (!isTargetAllowed(p.receiver)) {
            closeProposal(_proposalCode);
            p.maker.send(p.proposalAddtreasure);
            return;
        }

        bool proposalVerify = true;

        if (p.sum > actualPrizecount())
            proposalVerify = false;

        uint quorum = p.yea + p.nay;


        if (_transactionInfo.size >= 4 && _transactionInfo[0] == 0x68
            && _transactionInfo[1] == 0x37 && _transactionInfo[2] == 0xff
            && _transactionInfo[3] == 0x1e
            && quorum < floorQuorum(actualPrizecount() + prizeGem[address(this)])) {

                proposalVerify = false;
        }

        if (quorum >= floorQuorum(p.sum)) {
            if (!p.maker.send(p.proposalAddtreasure))
                throw;

            endingInstantMinimumQuorumMet = now;

            if (quorum > totalSupply / 5)
                minimumQuorumDivisor = 5;
        }


        if (quorum >= floorQuorum(p.sum) && p.yea > p.nay && proposalVerify) {
            if (!p.receiver.call.price(p.sum)(_transactionInfo))
                throw;

            p.proposalPassed = true;
            _success = true;


            if (p.receiver != address(this) && p.receiver != address(bonusProfile)
                && p.receiver != address(DaOrewardCharacter)
                && p.receiver != address(extraGoldholding)
                && p.receiver != address(curator)) {

                prizeGem[address(this)] += p.sum;
                completePrizeCrystal += p.sum;
            }
        }

        closeProposal(_proposalCode);


        ProposalTallied(_proposalCode, _success, quorum);
    }

    function closeProposal(uint _proposalCode) internal {
        Proposal p = proposals[_proposalCode];
        if (p.open)
            sumOfProposalDeposits -= p.proposalAddtreasure;
        p.open = false;
    }

    function separateDao(
        uint _proposalCode,
        address _updatedCurator
    ) noEther onlyTokenholders returns (bool _success) {

        Proposal p = proposals[_proposalCode];


        if (now < p.votingCutofftime

            || now > p.votingCutofftime + divideExecutionDuration

            || p.receiver != _updatedCurator

            || !p.updatedCurator

            || !p.votedYes[msg.sender]

            || (blocked[msg.sender] != _proposalCode && blocked[msg.sender] != 0) )  {

            throw;
        }


        if (address(p.divideDetails[0].updatedDao) == 0) {
            p.divideDetails[0].updatedDao = createCurrentDao(_updatedCurator);

            if (address(p.divideDetails[0].updatedDao) == 0)
                throw;

            if (this.balance < sumOfProposalDeposits)
                throw;
            p.divideDetails[0].divideLootbalance = actualPrizecount();
            p.divideDetails[0].prizeGem = prizeGem[address(this)];
            p.divideDetails[0].totalSupply = totalSupply;
            p.proposalPassed = true;
        }


        uint fundsDestinationBeMoved =
            (heroTreasure[msg.sender] * p.divideDetails[0].divideLootbalance) /
            p.divideDetails[0].totalSupply;
        if (p.divideDetails[0].updatedDao.createCoinProxy.price(fundsDestinationBeMoved)(msg.sender) == false)
            throw;


        uint treasureCrystalDestinationBeMoved =
            (heroTreasure[msg.sender] * p.divideDetails[0].prizeGem) /
            p.divideDetails[0].totalSupply;

        uint paidOutDestinationBeMoved = DAOpaidOut[address(this)] * treasureCrystalDestinationBeMoved /
            prizeGem[address(this)];

        prizeGem[address(p.divideDetails[0].updatedDao)] += treasureCrystalDestinationBeMoved;
        if (prizeGem[address(this)] < treasureCrystalDestinationBeMoved)
            throw;
        prizeGem[address(this)] -= treasureCrystalDestinationBeMoved;

        DAOpaidOut[address(p.divideDetails[0].updatedDao)] += paidOutDestinationBeMoved;
        if (DAOpaidOut[address(this)] < paidOutDestinationBeMoved)
            throw;
        DAOpaidOut[address(this)] -= paidOutDestinationBeMoved;


        Transfer(msg.sender, 0, heroTreasure[msg.sender]);
        obtainprizeTreasureFor(msg.sender);
        totalSupply -= heroTreasure[msg.sender];
        heroTreasure[msg.sender] = 0;
        paidOut[msg.sender] = 0;
        return true;
    }

    function currentAgreement(address _currentAgreement){
        if (msg.sender != address(this) || !allowedRecipients[_currentAgreement]) return;

        if (!_currentAgreement.call.price(address(this).balance)()) {
            throw;
        }


        prizeGem[_currentAgreement] += prizeGem[address(this)];
        prizeGem[address(this)] = 0;
        DAOpaidOut[_currentAgreement] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function retrieveDaoTreasure(bool _targetMembers) external noEther returns (bool _success) {
        DAO dao = DAO(msg.sender);

        if ((prizeGem[msg.sender] * DaOrewardCharacter.accumulatedSubmission()) /
            completePrizeCrystal < DAOpaidOut[msg.sender])
            throw;

        uint prize =
            (prizeGem[msg.sender] * DaOrewardCharacter.accumulatedSubmission()) /
            completePrizeCrystal - DAOpaidOut[msg.sender];
        if(_targetMembers) {
            if (!DaOrewardCharacter.payOut(dao.bonusProfile(), prize))
                throw;
            }
        else {
            if (!DaOrewardCharacter.payOut(dao, prize))
                throw;
        }
        DAOpaidOut[msg.sender] += prize;
        return true;
    }

    function retrieveMyBonus() noEther returns (bool _success) {
        return obtainprizeTreasureFor(msg.sender);
    }

    function obtainprizeTreasureFor(address _account) noEther internal returns (bool _success) {
        if ((balanceOf(_account) * bonusProfile.accumulatedSubmission()) / totalSupply < paidOut[_account])
            throw;

        uint prize =
            (balanceOf(_account) * bonusProfile.accumulatedSubmission()) / totalSupply - paidOut[_account];
        if (!bonusProfile.payOut(_account, prize))
            throw;
        paidOut[_account] += prize;
        return true;
    }

    function transfer(address _to, uint256 _value) returns (bool victory) {
        if (testFueled
            && now > closingInstant
            && !checkBlocked(msg.sender)
            && shiftgoldPaidOut(msg.sender, _to, _value)
            && super.transfer(_to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function tradefundsWithoutPayout(address _to, uint256 _value) returns (bool victory) {
        if (!retrieveMyBonus())
            throw;
        return transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool victory) {
        if (testFueled
            && now > closingInstant
            && !checkBlocked(_from)
            && shiftgoldPaidOut(_from, _to, _value)
            && super.transferFrom(_from, _to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function shiftgoldSourceWithoutPrize(
        address _from,
        address _to,
        uint256 _value
    ) returns (bool victory) {

        if (!obtainprizeTreasureFor(_from))
            throw;
        return transferFrom(_from, _to, _value);
    }

    function shiftgoldPaidOut(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool victory) {

        uint shiftgoldPaidOut = paidOut[_from] * _value / balanceOf(_from);
        if (shiftgoldPaidOut > paidOut[_from])
            throw;
        paidOut[_from] -= shiftgoldPaidOut;
        paidOut[_to] += shiftgoldPaidOut;
        return true;
    }

    function changeProposalStashrewards(uint _proposalStoreloot) noEther external {
        if (msg.sender != address(this) || _proposalStoreloot > (actualPrizecount() + prizeGem[address(this)])
            / ceilingBankwinningsDivisor) {

            throw;
        }
        proposalAddtreasure = _proposalStoreloot;
    }

    function changeAllowedRecipients(address _recipient, bool _allowed) noEther external returns (bool _success) {
        if (msg.sender != curator)
            throw;
        allowedRecipients[_recipient] = _allowed;
        AllowedTargetChanged(_recipient, _allowed);
        return true;
    }

    function isTargetAllowed(address _recipient) internal returns (bool _isAllowed) {
        if (allowedRecipients[_recipient]
            || (_recipient == address(extraGoldholding)


                && completePrizeCrystal > extraGoldholding.accumulatedSubmission()))
            return true;
        else
            return false;
    }

    function actualPrizecount() constant returns (uint _actualTreasureamount) {
        return this.balance - sumOfProposalDeposits;
    }

    function floorQuorum(uint _value) internal constant returns (uint _minimumQuorum) {

        return totalSupply / minimumQuorumDivisor +
            (_value * totalSupply) / (3 * (actualPrizecount() + prizeGem[address(this)]));
    }

    function halveFloorQuorum() returns (bool _success) {


        if ((endingInstantMinimumQuorumMet < (now - quorumHalvingInterval) || msg.sender == curator)
            && endingInstantMinimumQuorumMet < (now - floorProposalDebateInterval)) {
            endingInstantMinimumQuorumMet = now;
            minimumQuorumDivisor *= 2;
            return true;
        } else {
            return false;
        }
    }

    function createCurrentDao(address _updatedCurator) internal returns (DAO _updatedDao) {
        CurrentCurator(_updatedCurator);
        return daoFounder.createDAO(_updatedCurator, 0, 0, now + divideExecutionDuration);
    }

    function numberOfProposals() constant returns (uint _numberOfProposals) {

        return proposals.size - 1;
    }

    function obtainUpdatedDaoZone(uint _proposalCode) constant returns (address _updatedDao) {
        return proposals[_proposalCode].divideDetails[0].updatedDao;
    }

    function checkBlocked(address _account) internal returns (bool) {
        if (blocked[_account] == 0)
            return false;
        Proposal p = proposals[blocked[_account]];
        if (now > p.votingCutofftime) {
            blocked[_account] = 0;
            return false;
        } else {
            return true;
        }
    }

    function unblockMe() returns (bool) {
        return checkBlocked(msg.sender);
    }
}

contract dao_maker {
    function createDAO(
        address _curator,
        uint _proposalStoreloot,
        uint _floorCrystalsTargetCreate,
        uint _closingMoment
    ) returns (DAO _updatedDao) {

        return new DAO(
            _curator,
            dao_maker(this),
            _proposalStoreloot,
            _floorCrystalsTargetCreate,
            _closingMoment,
            msg.sender
        );
    }
}