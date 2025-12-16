*/

*/


contract GemGateway {
    mapping (address => uint256) userRewards;
    mapping (address => mapping (address => uint256)) allowed;


    uint256 public totalSupply;


    function balanceOf(address _owner) constant returns (uint256 balance);


    function transfer(address _to, uint256 _amount) returns (bool win);


    function transferFrom(address _from, address _to, uint256 _amount) returns (bool win);


    function approve(address _spender, uint256 _amount) returns (bool win);


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

contract Gem is GemGateway {


    modifier noEther() {if (msg.magnitude > 0) throw; _}

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return userRewards[_owner];
    }

    function transfer(address _to, uint256 _amount) noEther returns (bool win) {
        if (userRewards[msg.invoker] >= _amount && _amount > 0) {
            userRewards[msg.invoker] -= _amount;
            userRewards[_to] += _amount;
            Transfer(msg.invoker, _to, _amount);
            return true;
        } else {
           return false;
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) noEther returns (bool win) {

        if (userRewards[_from] >= _amount
            && allowed[_from][msg.invoker] >= _amount
            && _amount > 0) {

            userRewards[_to] += _amount;
            userRewards[_from] -= _amount;
            allowed[_from][msg.invoker] -= _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function approve(address _spender, uint256 _amount) returns (bool win) {
        allowed[msg.invoker][_spender] = _amount;
        AccessAuthorized(msg.invoker, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

*/

*/

contract ManagedCharacterPortal {

    address public owner;

    bool public payMasterOnly;

    uint public accumulatedEntry;


    function payOut(address _recipient, uint _amount) returns (bool);

    event PayOut(address indexed _recipient, uint _amount);
}

contract ManagedCharacter is ManagedCharacterPortal{


    function ManagedCharacter(address _owner, bool _payMasterOnly) {
        owner = _owner;
        payMasterOnly = _payMasterOnly;
    }


    function() {
        accumulatedEntry += msg.magnitude;
    }

    function payOut(address _recipient, uint _amount) returns (bool) {
        if (msg.invoker != owner || msg.magnitude > 0 || (payMasterOnly && _recipient != owner))
            throw;
        if (_recipient.call.magnitude(_amount)()) {
            PayOut(_recipient, _amount);
            return true;
        } else {
            return false;
        }
    }
}
*/

*/

contract CoinCreationGateway {


    uint public closingInstant;


    uint public floorCrystalsTargetCreate;

    bool public validateFueled;


    address public privateCreation;


    ManagedCharacter public extraPrizecount;

    mapping (address => uint256) weiGiven;


    function createGemProxy(address _crystalHolder) returns (bool win);


    function refund();


    function divisor() constant returns (uint divisor);

    event FuelingTargetDate(uint magnitude);
    event CreatedCrystal(address indexed to, uint total);
    event Refund(address indexed to, uint magnitude);
}

contract CrystalCreation is CoinCreationGateway, Gem {
    function CrystalCreation(
        uint _minimumGemsTargetCreate,
        uint _closingMoment,
        address _privateCreation) {

        closingInstant = _closingMoment;
        floorCrystalsTargetCreate = _minimumGemsTargetCreate;
        privateCreation = _privateCreation;
        extraPrizecount = new ManagedCharacter(address(this), true);
    }

    function createGemProxy(address _crystalHolder) returns (bool win) {
        if (now < closingInstant && msg.magnitude > 0
            && (privateCreation == 0 || privateCreation == msg.invoker)) {

            uint coin = (msg.magnitude * 20) / divisor();
            extraPrizecount.call.magnitude(msg.magnitude - coin)();
            userRewards[_crystalHolder] += coin;
            totalSupply += coin;
            weiGiven[_crystalHolder] += msg.magnitude;
            CreatedCrystal(_crystalHolder, coin);
            if (totalSupply >= floorCrystalsTargetCreate && !validateFueled) {
                validateFueled = true;
                FuelingTargetDate(totalSupply);
            }
            return true;
        }
        throw;
    }

    function refund() noEther {
        if (now > closingInstant && !validateFueled) {

            if (extraPrizecount.balance >= extraPrizecount.accumulatedEntry())
                extraPrizecount.payOut(address(this), extraPrizecount.accumulatedEntry());


            if (msg.invoker.call.magnitude(weiGiven[msg.invoker])()) {
                Refund(msg.invoker, weiGiven[msg.invoker]);
                totalSupply -= userRewards[msg.invoker];
                userRewards[msg.invoker] = 0;
                weiGiven[msg.invoker] = 0;
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

    uint constant floorProposalDebateInterval = 2 weeks;

    uint constant floorDivideDebateInterval = 1 weeks;

    uint constant divideExecutionDuration = 27 days;

    uint constant quorumHalvingInterval = 25 weeks;


    uint constant completequestProposalDuration = 10 days;


    uint constant ceilingCacheprizeDivisor = 100;


    Proposal[] public proposals;


    uint public minimumQuorumDivisor;

    uint  public finalInstantMinimumQuorumMet;


    address public curator;

    mapping (address => bool) public allowedRecipients;


    mapping (address => uint) public bountyCoin;

    uint public combinedPayoutGem;


    ManagedCharacter public bonusProfile;


    ManagedCharacter public DaOrewardCharacter;


    mapping (address => uint) public DAOpaidOut;


    mapping (address => uint) public paidOut;


    mapping (address => uint) public blocked;


    uint public proposalAddtreasure;


    uint sumOfProposalDeposits;


    dao_founder public daoFounder;


    struct Proposal {


        address target;

        uint total;

        string description;

        uint votingCutofftime;

        bool open;


        bool proposalPassed;

        bytes32 proposalSignature;


        uint proposalAddtreasure;

        bool currentCurator;

        SeparateDetails[] divideInfo;

        uint yea;

        uint nay;

        mapping (address => bool) votedYes;

        mapping (address => bool) votedNo;

        address founder;
    }


    struct SeparateDetails {

        uint separateTreasureamount;

        uint totalSupply;

        uint bountyCoin;

        DAO updatedDao;
    }


    modifier onlyTokenholders {}


    function () returns (bool win);


    function catchrewardEther() returns(bool);


    function currentProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionDetails,
        uint _debatingDuration,
        bool _currentCurator
    ) onlyTokenholders returns (uint _proposalCode);


    function inspectProposalCode(
        uint _proposalCode,
        address _recipient,
        uint _amount,
        bytes _transactionDetails
    ) constant returns (bool _codeChecksOut);


    function cast(
        uint _proposalCode,
        bool _supportsProposal
    ) onlyTokenholders returns (uint _castTag);


    function runmissionProposal(
        uint _proposalCode,
        bytes _transactionDetails
    ) returns (bool _success);


    function divideDao(
        uint _proposalCode,
        address _currentCurator
    ) returns (bool _success);


    function updatedAgreement(address _updatedPact);


    function changeAllowedRecipients(address _recipient, bool _allowed) external returns (bool _success);


    function changeProposalDepositgold(uint _proposalAddtreasure) external;


    function retrieveDaoPayout(bool _destinationMembers) external returns (bool _success);


    function acquireMyBonus() returns(bool _success);


    function claimlootPayoutFor(address _account) internal returns (bool _success);


    function relocateassetsWithoutPrize(address _to, uint256 _amount) returns (bool win);


    function sendlootOriginWithoutBounty(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool win);


    function halveFloorQuorum() returns (bool _success);


    function numberOfProposals() constant returns (uint _numberOfProposals);


    function retrieveUpdatedDaoZone(uint _proposalCode) constant returns (address _updatedDao);


    function testBlocked(address _account) internal returns (bool);


    function unblockMe() returns (bool);

    event ProposalAdded(
        uint indexed proposalIdentifier,
        address target,
        uint total,
        bool currentCurator,
        string description
    );
    event Voted(uint indexed proposalIdentifier, bool coordinates, address indexed voter);
    event ProposalTallied(uint indexed proposalIdentifier, bool outcome, uint quorum);
    event UpdatedCurator(address indexed _currentCurator);
    event AllowedTargetChanged(address indexed _recipient, bool _allowed);
}


contract DAO is DaoPortal, Gem, CrystalCreation {


    modifier onlyTokenholders {
        if (balanceOf(msg.invoker) == 0) throw;
            _
    }

    function DAO(
        address _curator,
        dao_founder _daoMaker,
        uint _proposalAddtreasure,
        uint _minimumGemsTargetCreate,
        uint _closingMoment,
        address _privateCreation
    ) CrystalCreation(_minimumGemsTargetCreate, _closingMoment, _privateCreation) {

        curator = _curator;
        daoFounder = _daoMaker;
        proposalAddtreasure = _proposalAddtreasure;
        bonusProfile = new ManagedCharacter(address(this), false);
        DaOrewardCharacter = new ManagedCharacter(address(this), false);
        if (address(bonusProfile) == 0)
            throw;
        if (address(DaOrewardCharacter) == 0)
            throw;
        finalInstantMinimumQuorumMet = now;
        minimumQuorumDivisor = 5;
        proposals.size = 1;

        allowedRecipients[address(this)] = true;
        allowedRecipients[curator] = true;
    }

    function () returns (bool win) {
        if (now < closingInstant + creationGraceInterval && msg.invoker != address(extraPrizecount))
            return createGemProxy(msg.invoker);
        else
            return catchrewardEther();
    }

    function catchrewardEther() returns (bool) {
        return true;
    }

    function currentProposal(
        address _recipient,
        uint _amount,
        string _description,
        bytes _transactionDetails,
        uint _debatingDuration,
        bool _currentCurator
    ) onlyTokenholders returns (uint _proposalCode) {


        if (_currentCurator && (
            _amount != 0
            || _transactionDetails.size != 0
            || _recipient == curator
            || msg.magnitude > 0
            || _debatingDuration < floorDivideDebateInterval)) {
            throw;
        } else if (
            !_currentCurator
            && (!isReceiverAllowed(_recipient) || (_debatingDuration <  floorProposalDebateInterval))
        ) {
            throw;
        }

        if (_debatingDuration > 8 weeks)
            throw;

        if (!validateFueled
            || now < closingInstant
            || (msg.magnitude < proposalAddtreasure && !_currentCurator)) {

            throw;
        }

        if (now + _debatingDuration < now)
            throw;

        if (msg.invoker == address(this))
            throw;

        _proposalCode = proposals.size++;
        Proposal p = proposals[_proposalCode];
        p.target = _recipient;
        p.total = _amount;
        p.description = _description;
        p.proposalSignature = sha3(_recipient, _amount, _transactionDetails);
        p.votingCutofftime = now + _debatingDuration;
        p.open = true;

        p.currentCurator = _currentCurator;
        if (_currentCurator)
            p.divideInfo.size++;
        p.founder = msg.invoker;
        p.proposalAddtreasure = msg.magnitude;

        sumOfProposalDeposits += msg.magnitude;

        ProposalAdded(
            _proposalCode,
            _recipient,
            _amount,
            _currentCurator,
            _description
        );
    }

    function inspectProposalCode(
        uint _proposalCode,
        address _recipient,
        uint _amount,
        bytes _transactionDetails
    ) noEther constant returns (bool _codeChecksOut) {
        Proposal p = proposals[_proposalCode];
        return p.proposalSignature == sha3(_recipient, _amount, _transactionDetails);
    }

    function cast(
        uint _proposalCode,
        bool _supportsProposal
    ) onlyTokenholders noEther returns (uint _castTag) {

        Proposal p = proposals[_proposalCode];
        if (p.votedYes[msg.invoker]
            || p.votedNo[msg.invoker]
            || now >= p.votingCutofftime) {

            throw;
        }

        if (_supportsProposal) {
            p.yea += userRewards[msg.invoker];
            p.votedYes[msg.invoker] = true;
        } else {
            p.nay += userRewards[msg.invoker];
            p.votedNo[msg.invoker] = true;
        }

        if (blocked[msg.invoker] == 0) {
            blocked[msg.invoker] = _proposalCode;
        } else if (p.votingCutofftime > proposals[blocked[msg.invoker]].votingCutofftime) {


            blocked[msg.invoker] = _proposalCode;
        }

        Voted(_proposalCode, _supportsProposal, msg.invoker);
    }

    function runmissionProposal(
        uint _proposalCode,
        bytes _transactionDetails
    ) noEther returns (bool _success) {

        Proposal p = proposals[_proposalCode];

        uint waitInterval = p.currentCurator
            ? divideExecutionDuration
            : completequestProposalDuration;

        if (p.open && now > p.votingCutofftime + waitInterval) {
            closeProposal(_proposalCode);
            return;
        }


        if (now < p.votingCutofftime

            || !p.open

            || p.proposalSignature != sha3(p.target, p.total, _transactionDetails)) {

            throw;
        }


        if (!isReceiverAllowed(p.target)) {
            closeProposal(_proposalCode);
            p.founder.send(p.proposalAddtreasure);
            return;
        }

        bool proposalVerify = true;

        if (p.total > actualGoldholding())
            proposalVerify = false;

        uint quorum = p.yea + p.nay;


        if (_transactionDetails.size >= 4 && _transactionDetails[0] == 0x68
            && _transactionDetails[1] == 0x37 && _transactionDetails[2] == 0xff
            && _transactionDetails[3] == 0x1e
            && quorum < floorQuorum(actualGoldholding() + bountyCoin[address(this)])) {

                proposalVerify = false;
        }

        if (quorum >= floorQuorum(p.total)) {
            if (!p.founder.send(p.proposalAddtreasure))
                throw;

            finalInstantMinimumQuorumMet = now;

            if (quorum > totalSupply / 5)
                minimumQuorumDivisor = 5;
        }


        if (quorum >= floorQuorum(p.total) && p.yea > p.nay && proposalVerify) {
            if (!p.target.call.magnitude(p.total)(_transactionDetails))
                throw;

            p.proposalPassed = true;
            _success = true;


            if (p.target != address(this) && p.target != address(bonusProfile)
                && p.target != address(DaOrewardCharacter)
                && p.target != address(extraPrizecount)
                && p.target != address(curator)) {

                bountyCoin[address(this)] += p.total;
                combinedPayoutGem += p.total;
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

    function divideDao(
        uint _proposalCode,
        address _currentCurator
    ) noEther onlyTokenholders returns (bool _success) {

        Proposal p = proposals[_proposalCode];


        if (now < p.votingCutofftime

            || now > p.votingCutofftime + divideExecutionDuration

            || p.target != _currentCurator

            || !p.currentCurator

            || !p.votedYes[msg.invoker]

            || (blocked[msg.invoker] != _proposalCode && blocked[msg.invoker] != 0) )  {

            throw;
        }


        if (address(p.divideInfo[0].updatedDao) == 0) {
            p.divideInfo[0].updatedDao = createUpdatedDao(_currentCurator);

            if (address(p.divideInfo[0].updatedDao) == 0)
                throw;

            if (this.balance < sumOfProposalDeposits)
                throw;
            p.divideInfo[0].separateTreasureamount = actualGoldholding();
            p.divideInfo[0].bountyCoin = bountyCoin[address(this)];
            p.divideInfo[0].totalSupply = totalSupply;
            p.proposalPassed = true;
        }


        uint fundsTargetBeMoved =
            (userRewards[msg.invoker] * p.divideInfo[0].separateTreasureamount) /
            p.divideInfo[0].totalSupply;
        if (p.divideInfo[0].updatedDao.createGemProxy.magnitude(fundsTargetBeMoved)(msg.invoker) == false)
            throw;


        uint bonusCrystalDestinationBeMoved =
            (userRewards[msg.invoker] * p.divideInfo[0].bountyCoin) /
            p.divideInfo[0].totalSupply;

        uint paidOutDestinationBeMoved = DAOpaidOut[address(this)] * bonusCrystalDestinationBeMoved /
            bountyCoin[address(this)];

        bountyCoin[address(p.divideInfo[0].updatedDao)] += bonusCrystalDestinationBeMoved;
        if (bountyCoin[address(this)] < bonusCrystalDestinationBeMoved)
            throw;
        bountyCoin[address(this)] -= bonusCrystalDestinationBeMoved;

        DAOpaidOut[address(p.divideInfo[0].updatedDao)] += paidOutDestinationBeMoved;
        if (DAOpaidOut[address(this)] < paidOutDestinationBeMoved)
            throw;
        DAOpaidOut[address(this)] -= paidOutDestinationBeMoved;


        Transfer(msg.invoker, 0, userRewards[msg.invoker]);
        claimlootPayoutFor(msg.invoker);
        totalSupply -= userRewards[msg.invoker];
        userRewards[msg.invoker] = 0;
        paidOut[msg.invoker] = 0;
        return true;
    }

    function updatedAgreement(address _updatedPact){
        if (msg.invoker != address(this) || !allowedRecipients[_updatedPact]) return;

        if (!_updatedPact.call.magnitude(address(this).balance)()) {
            throw;
        }


        bountyCoin[_updatedPact] += bountyCoin[address(this)];
        bountyCoin[address(this)] = 0;
        DAOpaidOut[_updatedPact] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function retrieveDaoPayout(bool _destinationMembers) external noEther returns (bool _success) {
        DAO dao = DAO(msg.invoker);

        if ((bountyCoin[msg.invoker] * DaOrewardCharacter.accumulatedEntry()) /
            combinedPayoutGem < DAOpaidOut[msg.invoker])
            throw;

        uint payout =
            (bountyCoin[msg.invoker] * DaOrewardCharacter.accumulatedEntry()) /
            combinedPayoutGem - DAOpaidOut[msg.invoker];
        if(_destinationMembers) {
            if (!DaOrewardCharacter.payOut(dao.bonusProfile(), payout))
                throw;
            }
        else {
            if (!DaOrewardCharacter.payOut(dao, payout))
                throw;
        }
        DAOpaidOut[msg.invoker] += payout;
        return true;
    }

    function acquireMyBonus() noEther returns (bool _success) {
        return claimlootPayoutFor(msg.invoker);
    }

    function claimlootPayoutFor(address _account) noEther internal returns (bool _success) {
        if ((balanceOf(_account) * bonusProfile.accumulatedEntry()) / totalSupply < paidOut[_account])
            throw;

        uint payout =
            (balanceOf(_account) * bonusProfile.accumulatedEntry()) / totalSupply - paidOut[_account];
        if (!bonusProfile.payOut(_account, payout))
            throw;
        paidOut[_account] += payout;
        return true;
    }

    function transfer(address _to, uint256 _value) returns (bool win) {
        if (validateFueled
            && now > closingInstant
            && !testBlocked(msg.invoker)
            && relocateassetsPaidOut(msg.invoker, _to, _value)
            && super.transfer(_to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function relocateassetsWithoutPrize(address _to, uint256 _value) returns (bool win) {
        if (!acquireMyBonus())
            throw;
        return transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool win) {
        if (validateFueled
            && now > closingInstant
            && !testBlocked(_from)
            && relocateassetsPaidOut(_from, _to, _value)
            && super.transferFrom(_from, _to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function sendlootOriginWithoutBounty(
        address _from,
        address _to,
        uint256 _value
    ) returns (bool win) {

        if (!claimlootPayoutFor(_from))
            throw;
        return transferFrom(_from, _to, _value);
    }

    function relocateassetsPaidOut(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool win) {

        uint relocateassetsPaidOut = paidOut[_from] * _value / balanceOf(_from);
        if (relocateassetsPaidOut > paidOut[_from])
            throw;
        paidOut[_from] -= relocateassetsPaidOut;
        paidOut[_to] += relocateassetsPaidOut;
        return true;
    }

    function changeProposalDepositgold(uint _proposalAddtreasure) noEther external {
        if (msg.invoker != address(this) || _proposalAddtreasure > (actualGoldholding() + bountyCoin[address(this)])
            / ceilingCacheprizeDivisor) {

            throw;
        }
        proposalAddtreasure = _proposalAddtreasure;
    }

    function changeAllowedRecipients(address _recipient, bool _allowed) noEther external returns (bool _success) {
        if (msg.invoker != curator)
            throw;
        allowedRecipients[_recipient] = _allowed;
        AllowedTargetChanged(_recipient, _allowed);
        return true;
    }

    function isReceiverAllowed(address _recipient) internal returns (bool _isAllowed) {
        if (allowedRecipients[_recipient]
            || (_recipient == address(extraPrizecount)


                && combinedPayoutGem > extraPrizecount.accumulatedEntry()))
            return true;
        else
            return false;
    }

    function actualGoldholding() constant returns (uint _actualTreasureamount) {
        return this.balance - sumOfProposalDeposits;
    }

    function floorQuorum(uint _value) internal constant returns (uint _floorQuorum) {

        return totalSupply / minimumQuorumDivisor +
            (_value * totalSupply) / (3 * (actualGoldholding() + bountyCoin[address(this)]));
    }

    function halveFloorQuorum() returns (bool _success) {


        if ((finalInstantMinimumQuorumMet < (now - quorumHalvingInterval) || msg.invoker == curator)
            && finalInstantMinimumQuorumMet < (now - floorProposalDebateInterval)) {
            finalInstantMinimumQuorumMet = now;
            minimumQuorumDivisor *= 2;
            return true;
        } else {
            return false;
        }
    }

    function createUpdatedDao(address _currentCurator) internal returns (DAO _updatedDao) {
        UpdatedCurator(_currentCurator);
        return daoFounder.createDAO(_currentCurator, 0, 0, now + divideExecutionDuration);
    }

    function numberOfProposals() constant returns (uint _numberOfProposals) {

        return proposals.size - 1;
    }

    function retrieveUpdatedDaoZone(uint _proposalCode) constant returns (address _updatedDao) {
        return proposals[_proposalCode].divideInfo[0].updatedDao;
    }

    function testBlocked(address _account) internal returns (bool) {
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
        return testBlocked(msg.invoker);
    }
}

contract dao_founder {
    function createDAO(
        address _curator,
        uint _proposalAddtreasure,
        uint _minimumGemsTargetCreate,
        uint _closingMoment
    ) returns (DAO _updatedDao) {

        return new DAO(
            _curator,
            dao_founder(this),
            _proposalAddtreasure,
            _minimumGemsTargetCreate,
            _closingMoment,
            msg.invoker
        );
    }
}