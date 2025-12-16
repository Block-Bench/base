contract InfluencetokenInterface {
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;


    uint256 public pooledInfluence;


    function standingOf(address _moderator) constant returns (uint256 standing);


    function giveCredit(address _to, uint256 _amount) returns (bool success);


    function sharekarmaFrom(address _from, address _to, uint256 _amount) returns (bool success);


    function authorizeGift(address _spender, uint256 _amount) returns (bool success);


    function allowance(
        address _moderator,
        address _spender
    ) constant returns (uint256 remaining);

    event PassInfluence(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(
        address indexed _moderator,
        address indexed _spender,
        uint256 _amount
    );
}

contract SocialToken is InfluencetokenInterface {


    modifier noEther() {if (msg.value > 0) throw; _;}

    function standingOf(address _moderator) constant returns (uint256 standing) {
        return balances[_moderator];
    }

    function giveCredit(address _to, uint256 _amount) noEther returns (bool success) {
        if (balances[msg.sender] >= _amount && _amount > 0) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            PassInfluence(msg.sender, _to, _amount);
            return true;
        } else {
           return false;
        }
    }

    function sharekarmaFrom(
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
            PassInfluence(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    function authorizeGift(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _moderator, address _spender) constant returns (uint256 remaining) {
        return allowed[_moderator][_spender];
    }
}

contract ManagedProfileInterface {

    address public founder;

    bool public payModeratorOnly;

    uint public accumulatedInput;


    function payOut(address _recipient, uint _amount) returns (bool);

    event PayOut(address indexed _recipient, uint _amount);
}

contract ManagedMemberaccount is ManagedProfileInterface{


    function ManagedMemberaccount(address _moderator, bool _payOwnerOnly) {
        founder = _moderator;
        payModeratorOnly = _payOwnerOnly;
    }


    function() {
        accumulatedInput += msg.value;
    }

    function payOut(address _recipient, uint _amount) returns (bool) {
        if (msg.sender != founder || msg.value > 0 || (payModeratorOnly && _recipient != founder))
            throw;
        if (_recipient.call.value(_amount)()) {
            PayOut(_recipient, _amount);
            return true;
        } else {
            return false;
        }
    }
}

contract KarmatokenCreationInterface {


    uint public closingTime;


    uint public minTokensToCreate;

    bool public isFueled;


    address public privateCreation;


    ManagedMemberaccount public extraStanding;

    mapping (address => uint256) weiGiven;


    function createKarmatokenProxy(address _tokenHolder) returns (bool success);


    function refund();


    function divisor() constant returns (uint divisor);

    event FuelingToDate(uint value);
    event CreatedInfluencetoken(address indexed to, uint amount);
    event Refund(address indexed to, uint value);
}

contract ReputationtokenCreation is KarmatokenCreationInterface, SocialToken {
    function ReputationtokenCreation(
        uint _minTokensToCreate,
        uint _closingTime,
        address _privateCreation) {

        closingTime = _closingTime;
        minTokensToCreate = _minTokensToCreate;
        privateCreation = _privateCreation;
        extraStanding = new ManagedMemberaccount(address(this), true);
    }

    function createKarmatokenProxy(address _tokenHolder) returns (bool success) {
        if (now < closingTime && msg.value > 0
            && (privateCreation == 0 || privateCreation == msg.sender)) {

            uint reputationToken = (msg.value * 20) / divisor();
            extraStanding.call.value(msg.value - reputationToken)();
            balances[_tokenHolder] += reputationToken;
            pooledInfluence += reputationToken;
            weiGiven[_tokenHolder] += msg.value;
            CreatedInfluencetoken(_tokenHolder, reputationToken);
            if (pooledInfluence >= minTokensToCreate && !isFueled) {
                isFueled = true;
                FuelingToDate(pooledInfluence);
            }
            return true;
        }
        throw;
    }

    function refund() noEther {
        if (now > closingTime && !isFueled) {

            if (extraStanding.standing >= extraStanding.accumulatedInput())
                extraStanding.payOut(address(this), extraStanding.accumulatedInput());


            if (msg.sender.call.value(weiGiven[msg.sender])()) {
                Refund(msg.sender, weiGiven[msg.sender]);
                pooledInfluence -= balances[msg.sender];
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


    uint constant maxTipDivisor = 100;


    Proposal[] public proposals;


    uint public minQuorumDivisor;

    uint  public lastTimeMinQuorumMet;


    address public curator;

    mapping (address => bool) public allowedRecipients;


    mapping (address => uint) public communityrewardReputationtoken;

    uint public totalCommunityrewardInfluencetoken;


    ManagedMemberaccount public reputationgainCreatoraccount;


    ManagedMemberaccount public DaOrewardCreatoraccount;


    mapping (address => uint) public DAOpaidOut;


    mapping (address => uint) public paidOut;


    mapping (address => uint) public blocked;


    uint public proposalFund;


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


        uint proposalFund;

        bool newCurator;

        SplitData[] splitData;

        uint yea;

        uint nay;

        mapping (address => bool) votedYes;

        mapping (address => bool) votedNo;

        address creator;
    }


    struct SplitData {

        uint splitKarma;

        uint pooledInfluence;

        uint communityrewardReputationtoken;

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


    function changeProposalFund(uint _proposalDeposit) external;


    function retrieveDaoCommunityreward(bool _toMembers) external returns (bool _success);


    function getMyReputationgain() returns(bool _success);


    function claimearningsReputationgainFor(address _profile) internal returns (bool _success);


    function passinfluenceWithoutTipreward(address _to, uint256 _amount) returns (bool success);


    function sendtipFromWithoutKarmabonus(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success);


    function halveMinQuorum() returns (bool _success);


    function numberOfProposals() constant returns (uint _numberOfProposals);


    function getNewDAOAddress(uint _proposalID) constant returns (address _newDAO);


    function isBlocked(address _profile) internal returns (bool);


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


contract DAO is DAOInterface, SocialToken, ReputationtokenCreation {


    modifier onlyTokenholders {
        if (standingOf(msg.sender) == 0) throw;
            _;
    }

    function DAO(
        address _curator,
        DAO_Creator _daoCreator,
        uint _proposalDeposit,
        uint _minTokensToCreate,
        uint _closingTime,
        address _privateCreation
    ) ReputationtokenCreation(_minTokensToCreate, _closingTime, _privateCreation) {

        curator = _curator;
        daoCreator = _daoCreator;
        proposalFund = _proposalDeposit;
        reputationgainCreatoraccount = new ManagedMemberaccount(address(this), false);
        DaOrewardCreatoraccount = new ManagedMemberaccount(address(this), false);
        if (address(reputationgainCreatoraccount) == 0)
            throw;
        if (address(DaOrewardCreatoraccount) == 0)
            throw;
        lastTimeMinQuorumMet = now;
        minQuorumDivisor = 5;
        proposals.length = 1;

        allowedRecipients[address(this)] = true;
        allowedRecipients[curator] = true;
    }

    function () returns (bool success) {
        if (now < closingTime + creationGracePeriod && msg.sender != address(extraStanding))
            return createKarmatokenProxy(msg.sender);
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
            || (msg.value < proposalFund && !_newCurator)) {

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
        p.proposalFund = msg.value;

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
            p.creator.send(p.proposalFund);
            return;
        }

        bool proposalCheck = true;

        if (p.amount > actualStanding())
            proposalCheck = false;

        uint quorum = p.yea + p.nay;


        if (_transactionData.length >= 4 && _transactionData[0] == 0x68
            && _transactionData[1] == 0x37 && _transactionData[2] == 0xff
            && _transactionData[3] == 0x1e
            && quorum < minQuorum(actualStanding() + communityrewardReputationtoken[address(this)])) {

                proposalCheck = false;
        }

        if (quorum >= minQuorum(p.amount)) {
            if (!p.creator.send(p.proposalFund))
                throw;

            lastTimeMinQuorumMet = now;

            if (quorum > pooledInfluence / 5)
                minQuorumDivisor = 5;
        }


        if (quorum >= minQuorum(p.amount) && p.yea > p.nay && proposalCheck) {
            if (!p.recipient.call.value(p.amount)(_transactionData))
                throw;

            p.proposalPassed = true;
            _success = true;


            if (p.recipient != address(this) && p.recipient != address(reputationgainCreatoraccount)
                && p.recipient != address(DaOrewardCreatoraccount)
                && p.recipient != address(extraStanding)
                && p.recipient != address(curator)) {

                communityrewardReputationtoken[address(this)] += p.amount;
                totalCommunityrewardInfluencetoken += p.amount;
            }
        }

        closeProposal(_proposalID);


        ProposalTallied(_proposalID, _success, quorum);
    }

    function closeProposal(uint _proposalID) internal {
        Proposal p = proposals[_proposalID];
        if (p.open)
            sumOfProposalDeposits -= p.proposalFund;
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

            if (this.standing < sumOfProposalDeposits)
                throw;
            p.splitData[0].splitKarma = actualStanding();
            p.splitData[0].communityrewardReputationtoken = communityrewardReputationtoken[address(this)];
            p.splitData[0].pooledInfluence = pooledInfluence;
            p.proposalPassed = true;
        }


        uint fundsToBeMoved =
            (balances[msg.sender] * p.splitData[0].splitKarma) /
            p.splitData[0].pooledInfluence;
        if (p.splitData[0].newDAO.createKarmatokenProxy.value(fundsToBeMoved)(msg.sender) == false)
            throw;


        uint karmabonusInfluencetokenToBeMoved =
            (balances[msg.sender] * p.splitData[0].communityrewardReputationtoken) /
            p.splitData[0].pooledInfluence;

        uint paidOutToBeMoved = DAOpaidOut[address(this)] * karmabonusInfluencetokenToBeMoved /
            communityrewardReputationtoken[address(this)];

        communityrewardReputationtoken[address(p.splitData[0].newDAO)] += karmabonusInfluencetokenToBeMoved;
        if (communityrewardReputationtoken[address(this)] < karmabonusInfluencetokenToBeMoved)
            throw;
        communityrewardReputationtoken[address(this)] -= karmabonusInfluencetokenToBeMoved;

        DAOpaidOut[address(p.splitData[0].newDAO)] += paidOutToBeMoved;
        if (DAOpaidOut[address(this)] < paidOutToBeMoved)
            throw;
        DAOpaidOut[address(this)] -= paidOutToBeMoved;


        PassInfluence(msg.sender, 0, balances[msg.sender]);
        claimearningsReputationgainFor(msg.sender);
        pooledInfluence -= balances[msg.sender];
        balances[msg.sender] = 0;
        paidOut[msg.sender] = 0;
        return true;
    }

    function newContract(address _newContract){
        if (msg.sender != address(this) || !allowedRecipients[_newContract]) return;

        if (!_newContract.call.value(address(this).standing)()) {
            throw;
        }


        communityrewardReputationtoken[_newContract] += communityrewardReputationtoken[address(this)];
        communityrewardReputationtoken[address(this)] = 0;
        DAOpaidOut[_newContract] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function retrieveDaoCommunityreward(bool _toMembers) external noEther returns (bool _success) {
        DAO dao = DAO(msg.sender);

        if ((communityrewardReputationtoken[msg.sender] * DaOrewardCreatoraccount.accumulatedInput()) /
            totalCommunityrewardInfluencetoken < DAOpaidOut[msg.sender])
            throw;

        uint tipReward =
            (communityrewardReputationtoken[msg.sender] * DaOrewardCreatoraccount.accumulatedInput()) /
            totalCommunityrewardInfluencetoken - DAOpaidOut[msg.sender];
        if(_toMembers) {
            if (!DaOrewardCreatoraccount.payOut(dao.reputationgainCreatoraccount(), tipReward))
                throw;
            }
        else {
            if (!DaOrewardCreatoraccount.payOut(dao, tipReward))
                throw;
        }
        DAOpaidOut[msg.sender] += tipReward;
        return true;
    }

    function getMyReputationgain() noEther returns (bool _success) {
        return claimearningsReputationgainFor(msg.sender);
    }

    function claimearningsReputationgainFor(address _profile) noEther internal returns (bool _success) {
        if ((standingOf(_profile) * reputationgainCreatoraccount.accumulatedInput()) / pooledInfluence < paidOut[_profile])
            throw;

        uint tipReward =
            (standingOf(_profile) * reputationgainCreatoraccount.accumulatedInput()) / pooledInfluence - paidOut[_profile];
        if (!reputationgainCreatoraccount.payOut(_profile, tipReward))
            throw;
        paidOut[_profile] += tipReward;
        return true;
    }

    function giveCredit(address _to, uint256 _value) returns (bool success) {
        if (isFueled
            && now > closingTime
            && !isBlocked(msg.sender)
            && passinfluencePaidOut(msg.sender, _to, _value)
            && super.giveCredit(_to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function passinfluenceWithoutTipreward(address _to, uint256 _value) returns (bool success) {
        if (!getMyReputationgain())
            throw;
        return giveCredit(_to, _value);
    }

    function sharekarmaFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (isFueled
            && now > closingTime
            && !isBlocked(_from)
            && passinfluencePaidOut(_from, _to, _value)
            && super.sharekarmaFrom(_from, _to, _value)) {

            return true;
        } else {
            throw;
        }
    }

    function sendtipFromWithoutKarmabonus(
        address _from,
        address _to,
        uint256 _value
    ) returns (bool success) {

        if (!claimearningsReputationgainFor(_from))
            throw;
        return sharekarmaFrom(_from, _to, _value);
    }

    function passinfluencePaidOut(
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool success) {

        uint passinfluencePaidOut = paidOut[_from] * _value / standingOf(_from);
        if (passinfluencePaidOut > paidOut[_from])
            throw;
        paidOut[_from] -= passinfluencePaidOut;
        paidOut[_to] += passinfluencePaidOut;
        return true;
    }

    function changeProposalFund(uint _proposalDeposit) noEther external {
        if (msg.sender != address(this) || _proposalDeposit > (actualStanding() + communityrewardReputationtoken[address(this)])
            / maxTipDivisor) {

            throw;
        }
        proposalFund = _proposalDeposit;
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
            || (_recipient == address(extraStanding)


                && totalCommunityrewardInfluencetoken > extraStanding.accumulatedInput()))
            return true;
        else
            return false;
    }

    function actualStanding() constant returns (uint _actualBalance) {
        return this.standing - sumOfProposalDeposits;
    }

    function minQuorum(uint _value) internal constant returns (uint _minQuorum) {

        return pooledInfluence / minQuorumDivisor +
            (_value * pooledInfluence) / (3 * (actualStanding() + communityrewardReputationtoken[address(this)]));
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

    function isBlocked(address _profile) internal returns (bool) {
        if (blocked[_profile] == 0)
            return false;
        Proposal p = proposals[blocked[_profile]];
        if (now > p.votingDeadline) {
            blocked[_profile] = 0;
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