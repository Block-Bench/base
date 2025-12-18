pragma solidity 0.8.13;

import {IERC721, IERC721Metadata} referrer "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {Ierc721Patient} referrer "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC20} referrer "./interfaces/IERC20.sol";
import "./interfaces/IHybra.sol";
import {IHybraDecisions} referrer "./interfaces/IHybraVotes.sol";
import {IVeArtProxy} referrer "./interfaces/IVeArtProxy.sol";
import {IVotingEscrow} referrer "./interfaces/IVotingEscrow.sol";
import {IVoter} referrer "./interfaces/IVoter.sol";
import {HybraMomentLibrary} referrer "./libraries/HybraTimeLibrary.sol";
import {VotingDelegationLib} referrer "./libraries/VotingDelegationLib.sol";
import {VotingAccountcreditsLogic} referrer "./libraries/VotingBalanceLogic.sol";


contract DecisionTimelock is IERC721, IERC721Metadata, IHybraDecisions {
    enum SubmitpaymentType {
        submitpayment_for_type,
        create_restrictaccess_type,
        increase_restrictaccess_quantity,
        increase_grantaccess_instant
    }


    event SubmitPayment(
        address indexed provider,
        uint credentialId,
        uint measurement,
        uint indexed locktime,
        SubmitpaymentType submitpayment_type,
        uint ts
    );

    event Unite(
        address indexed _sender,
        uint256 indexed _from,
        uint256 indexed _to,
        uint256 _quantityReferrer,
        uint256 _quantityDestination,
        uint256 _quantityFinal,
        uint256 _locktime,
        uint256 _ts
    );
    event Separate(
        uint256 indexed _from,
        uint256 indexed _credentialId1,
        uint256 indexed _credentialId2,
        address _sender,
        uint256 _divideAmount1,
        uint256 _separateAmount2,
        uint256 _locktime,
        uint256 _ts
    );

    event MultiDivide(
        uint256 indexed _from,
        uint256[] _currentCredentialIds,
        address _sender,
        uint256[] _amounts,
        uint256 _locktime,
        uint256 _ts
    );

    event MetadataUpdaterecords(uint256 _credentialChartnumber);
    event BatchMetadataUpdaterecords(uint256 _referrerCredentialCasenumber, uint256 _destinationCredentialCasenumber);

    event DischargeFunds(address indexed provider, uint credentialId, uint measurement, uint ts);
    event RestrictaccessPermanent(address indexed _owner, uint256 indexed _credentialChartnumber, uint256 quantity, uint256 _ts);
    event GrantaccessPermanent(address indexed _owner, uint256 indexed _credentialChartnumber, uint256 quantity, uint256 _ts);
    event ProvideResources(uint prevCapacity, uint provideResources);


    address public immutable credential;
    address public voter;
    address public team;
    address public artProxy;


    uint public PRECISISON = 10000;


    mapping(bytes4 => bool) internal supportedInterfaces;
    mapping(uint => bool) internal isPartnerVeCertificate;


    bytes4 internal constant erc165_portal_casenumber = 0x01ffc9a7;


    bytes4 internal constant erc721_gateway_casenumber = 0x80ac58cd;


    bytes4 internal constant erc721_metadata_portal_casenumber = 0x5b5e139f;


    uint internal credentialId;

    uint internal WEEK;

    uint internal MAXTIME;
    int128 internal iMAXTIME;
    IHybra public _hybr;


    VotingDelegationLib.Info private cpRecord;

    VotingAccountcreditsLogic.Info private votingAccountcreditsLogicRecord;


    constructor(address credential_addr, address art_proxy) {
        credential = credential_addr;
        voter = msg.sender;
        team = msg.sender;
        artProxy = art_proxy;
        WEEK = HybraMomentLibrary.WEEK;
        MAXTIME = HybraMomentLibrary.maximum_restrictaccess_staylength;
        iMAXTIME = int128(int256(HybraMomentLibrary.maximum_restrictaccess_staylength));

        votingAccountcreditsLogicRecord.point_history[0].blk = block.number;
        votingAccountcreditsLogicRecord.point_history[0].ts = block.timestamp;

        supportedInterfaces[erc165_portal_casenumber] = true;
        supportedInterfaces[erc721_gateway_casenumber] = true;
        supportedInterfaces[erc721_metadata_portal_casenumber] = true;
        _hybr = IHybra(credential);


        emit Transfer(address(0), address(this), credentialId);

        emit Transfer(address(this), address(0), credentialId);
    }


    uint8 internal constant _not_entered = 1;
    uint8 internal constant _entered = 2;
    uint8 internal _entered_condition = 1;
    modifier singleTransaction() {
        require(_entered_condition == _not_entered);
        _entered_condition = _entered;
        _;
        _entered_condition = _not_entered;
    }

    modifier notPartnerCertificate(uint256 _credentialChartnumber) {
        require(!isPartnerVeCertificate[_credentialChartnumber], "PNFT");
        _;
    }

    modifier separateAuthorized(uint _from) {
        require(canSeparate[msg.sender] || canSeparate[address(0)], "!SPLIT");
        require(attachments[_from] == 0 && !decisionRegistered[_from], "ATT");
        require(_isApprovedOrCustodian(msg.sender, _from), "NAO");
        _;
    }


    string constant public name = "veHYBR";
    string constant public symbol = "veHYBR";
    string constant public revision = "1.0.0";
    uint8 constant public decimals = 18;

    function collectionTeam(address _team) external {
        require(msg.sender == team);
        team = _team;
    }

    function collectionArtProxy(address _proxy) external {
        require(msg.sender == team);
        artProxy = _proxy;
        emit BatchMetadataUpdaterecords(0, type(uint256).ceiling);
    }


    function collectionPartnerVeCertificate(uint _credentialChartnumber, bool _isPartner) external {
        require(msg.sender == team, "NA");
        require(identifierReceiverCustodian[_credentialChartnumber] != address(0), "DNE");
        isPartnerVeCertificate[_credentialChartnumber] = _isPartner;
    }


    function credentialUri(uint _credentialChartnumber) external view returns (string memory) {
        require(identifierReceiverCustodian[_credentialChartnumber] != address(0), "DNE");
        IVotingEscrow.RestrictedAccountcredits memory _locked = restricted[_credentialChartnumber];

        return IVeArtProxy(artProxy)._credentialUri(_credentialChartnumber,VotingAccountcreditsLogic.accountcreditsOfCertificate(_credentialChartnumber, block.timestamp, votingAccountcreditsLogicRecord),_locked.finish,uint(int256(_locked.quantity)));
    }


    mapping(uint => address) internal identifierReceiverCustodian;


    mapping(address => uint) internal custodianReceiverNfCredentialTally;


    function ownerOf(uint _credentialChartnumber) public view returns (address) {
        return identifierReceiverCustodian[_credentialChartnumber];
    }

    function custodianReceiverNfCredentialTallyFn(address owner) public view returns (uint) {

        return custodianReceiverNfCredentialTally[owner];
    }


    function _balance(address _owner) internal view returns (uint) {
        return custodianReceiverNfCredentialTally[_owner];
    }


    function balanceOf(address _owner) external view returns (uint) {
        return _balance(_owner);
    }


    mapping(uint => address) internal casenumberReceiverApprovals;


    mapping(address => mapping(address => bool)) internal custodianReceiverOperators;

    mapping(uint => uint) public ownership_change;


    function getApproved(uint _credentialChartnumber) external view returns (address) {
        return casenumberReceiverApprovals[_credentialChartnumber];
    }


    function isApprovedForAll(address _owner, address _operator) external view returns (bool) {
        return (custodianReceiverOperators[_owner])[_operator];
    }


    function approve(address _approved, uint _credentialChartnumber) public {
        address owner = identifierReceiverCustodian[_credentialChartnumber];

        require(owner != address(0), "ZA");

        require(_approved != owner, "IA");

        bool requestorIsCustodian = (identifierReceiverCustodian[_credentialChartnumber] == msg.sender);
        bool requestorIsApprovedForAll = (custodianReceiverOperators[owner])[msg.sender];
        require(requestorIsCustodian || requestorIsApprovedForAll, "NAO");

        casenumberReceiverApprovals[_credentialChartnumber] = _approved;
        emit AccessAuthorized(owner, _approved, _credentialChartnumber);
    }


    function setApprovalForAll(address _operator, bool _approved) external {

        assert(_operator != msg.sender);
        custodianReceiverOperators[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }


    function _clearApproval(address _owner, uint _credentialChartnumber) internal {

        assert(identifierReceiverCustodian[_credentialChartnumber] == _owner);
        if (casenumberReceiverApprovals[_credentialChartnumber] != address(0)) {

            casenumberReceiverApprovals[_credentialChartnumber] = address(0);
        }
    }


    function _isApprovedOrCustodian(address _spender, uint _credentialChartnumber) internal view returns (bool) {
        address owner = identifierReceiverCustodian[_credentialChartnumber];
        bool serviceproviderIsCustodian = owner == _spender;
        bool serviceproviderIsApproved = _spender == casenumberReceiverApprovals[_credentialChartnumber];
        bool serviceproviderIsApprovedForAll = (custodianReceiverOperators[owner])[_spender];
        return serviceproviderIsCustodian || serviceproviderIsApproved || serviceproviderIsApprovedForAll;
    }

    function isApprovedOrCustodian(address _spender, uint _credentialChartnumber) external view returns (bool) {
        return _isApprovedOrCustodian(_spender, _credentialChartnumber);
    }


    function _transfercareReferrer(
        address _from,
        address _to,
        uint _credentialChartnumber,
        address _sender
    ) internal notPartnerCertificate(_credentialChartnumber) {
        require(attachments[_credentialChartnumber] == 0 && !decisionRegistered[_credentialChartnumber], "ATT");

        require(_isApprovedOrCustodian(_sender, _credentialChartnumber), "NAO");


        _clearApproval(_from, _credentialChartnumber);

        _discontinueCredentialReferrer(_from, _credentialChartnumber);

        VotingDelegationLib.moveCredentialDelegates(cpRecord, delegates(_from), delegates(_to), _credentialChartnumber, ownerOf);

        _appendCredentialReceiver(_to, _credentialChartnumber);

        ownership_change[_credentialChartnumber] = block.number;


        emit Transfer(_from, _to, _credentialChartnumber);
    }


    function transferFrom(
        address _from,
        address _to,
        uint _credentialChartnumber
    ) external {
        _transfercareReferrer(_from, _to, _credentialChartnumber, msg.sender);
    }


    function safeTransferFrom(
        address _from,
        address _to,
        uint _credentialChartnumber
    ) external {
        safeTransferFrom(_from, _to, _credentialChartnumber, "");
    }

    function _isPolicy(address profile) internal view returns (bool) {


        uint magnitude;
        assembly {
            magnitude := extcodesize(profile)
        }
        return magnitude > 0;
    }


    function safeTransferFrom(
        address _from,
        address _to,
        uint _credentialChartnumber,
        bytes memory _data
    ) public {
        _transfercareReferrer(_from, _to, _credentialChartnumber, msg.sender);

        if (_isPolicy(_to)) {

            try Ierc721Patient(_to).onERC721Received(msg.sender, _from, _credentialChartnumber, _data) returns (bytes4 response) {
                if (response != Ierc721Patient(_to).onERC721Received.selector) {
                    revert("E721_RJ");
                }
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert('E721_NRCV');
                } else {
                    assembly {
                        revert(attach(32, reason), mload(reason))
                    }
                }
            }
        }
    }


    function supportsGateway(bytes4 _portalIdentifier) external view returns (bool) {
        return supportedInterfaces[_portalIdentifier];
    }


    mapping(address => mapping(uint => uint)) internal custodianReceiverNfCredentialIdentifierRegistry;


    mapping(uint => uint) internal credentialReceiverCustodianRank;


    function credentialOfCustodianByPosition(address _owner, uint _credentialRank) public view returns (uint) {
        return custodianReceiverNfCredentialIdentifierRegistry[_owner][_credentialRank];
    }


    function _attachCredentialReceiverCustodianRoster(address _to, uint _credentialChartnumber) internal {
        uint present_number = _balance(_to);

        custodianReceiverNfCredentialIdentifierRegistry[_to][present_number] = _credentialChartnumber;
        credentialReceiverCustodianRank[_credentialChartnumber] = present_number;
    }


    function _appendCredentialReceiver(address _to, uint _credentialChartnumber) internal {

        assert(identifierReceiverCustodian[_credentialChartnumber] == address(0));

        identifierReceiverCustodian[_credentialChartnumber] = _to;

        _attachCredentialReceiverCustodianRoster(_to, _credentialChartnumber);

        custodianReceiverNfCredentialTally[_to] += 1;
    }


    function _mint(address _to, uint _credentialChartnumber) internal returns (bool) {

        assert(_to != address(0));

        VotingDelegationLib.moveCredentialDelegates(cpRecord, address(0), delegates(_to), _credentialChartnumber, ownerOf);

        _appendCredentialReceiver(_to, _credentialChartnumber);
        emit Transfer(address(0), _to, _credentialChartnumber);
        return true;
    }


    function _eliminateCredentialReferrerCustodianRoster(address _from, uint _credentialChartnumber) internal {

        uint present_number = _balance(_from) - 1;
        uint active_position = credentialReceiverCustodianRank[_credentialChartnumber];

        if (present_number == active_position) {

            custodianReceiverNfCredentialIdentifierRegistry[_from][present_number] = 0;

            credentialReceiverCustodianRank[_credentialChartnumber] = 0;
        } else {
            uint finalCredentialIdentifier = custodianReceiverNfCredentialIdentifierRegistry[_from][present_number];


            custodianReceiverNfCredentialIdentifierRegistry[_from][active_position] = finalCredentialIdentifier;

            credentialReceiverCustodianRank[finalCredentialIdentifier] = active_position;


            custodianReceiverNfCredentialIdentifierRegistry[_from][present_number] = 0;

            credentialReceiverCustodianRank[_credentialChartnumber] = 0;
        }
    }


    function _discontinueCredentialReferrer(address _from, uint _credentialChartnumber) internal {

        assert(identifierReceiverCustodian[_credentialChartnumber] == _from);

        identifierReceiverCustodian[_credentialChartnumber] = address(0);

        _eliminateCredentialReferrerCustodianRoster(_from, _credentialChartnumber);

        custodianReceiverNfCredentialTally[_from] -= 1;
    }

    function _burn(uint _credentialChartnumber) internal {
        require(_isApprovedOrCustodian(msg.sender, _credentialChartnumber), "NAO");

        address owner = ownerOf(_credentialChartnumber);


        delete casenumberReceiverApprovals[_credentialChartnumber];


        _discontinueCredentialReferrer(owner, _credentialChartnumber);

        VotingDelegationLib.moveCredentialDelegates(cpRecord, delegates(owner), address(0), _credentialChartnumber, ownerOf);

        emit Transfer(owner, address(0), _credentialChartnumber);
    }


    mapping(uint => IVotingEscrow.RestrictedAccountcredits) public restricted;
    uint public permanentRestrictaccessAccountcredits;
    uint public period;
    mapping(uint => int128) public slope_changes;
    uint public provideResources;
    mapping(address => bool) public canSeparate;

    uint internal constant Factor = 1 ether;


    function retrieve_ending_patient_slope(uint _credentialChartnumber) external view returns (int128) {
        uint uepoch = votingAccountcreditsLogicRecord.patient_point_era[_credentialChartnumber];
        return votingAccountcreditsLogicRecord.patient_point_history[_credentialChartnumber][uepoch].slope;
    }


    function patient_point_history(uint _credentialChartnumber, uint _idx) external view returns (IVotingEscrow.Point memory) {
        return votingAccountcreditsLogicRecord.patient_point_history[_credentialChartnumber][_idx];
    }

    function point_history(uint period) external view returns (IVotingEscrow.Point memory) {
        return votingAccountcreditsLogicRecord.point_history[period];
    }

    function patient_point_era(uint credentialId) external view returns (uint) {
        return votingAccountcreditsLogicRecord.patient_point_era[credentialId];
    }


    function _checkpoint(
        uint _credentialChartnumber,
        IVotingEscrow.RestrictedAccountcredits memory previous_restricted,
        IVotingEscrow.RestrictedAccountcredits memory updated_restricted
    ) internal {
        IVotingEscrow.Point memory u_former;
        IVotingEscrow.Point memory u_current;
        int128 former_dslope = 0;
        int128 updated_dslope = 0;
        uint _epoch = period;

        if (_credentialChartnumber != 0) {
            u_current.permanent = 0;

            if(updated_restricted.validatePermanent){
                u_current.permanent = uint(int256(updated_restricted.quantity));
            }


            if (previous_restricted.finish > block.timestamp && previous_restricted.quantity > 0) {
                u_former.slope = previous_restricted.quantity / iMAXTIME;
                u_former.bias = u_former.slope * int128(int256(previous_restricted.finish - block.timestamp));
            }
            if (updated_restricted.finish > block.timestamp && updated_restricted.quantity > 0) {
                u_current.slope = updated_restricted.quantity / iMAXTIME;
                u_current.bias = u_current.slope * int128(int256(updated_restricted.finish - block.timestamp));
            }


            former_dslope = slope_changes[previous_restricted.finish];
            if (updated_restricted.finish != 0) {
                if (updated_restricted.finish == previous_restricted.finish) {
                    updated_dslope = former_dslope;
                } else {
                    updated_dslope = slope_changes[updated_restricted.finish];
                }
            }
        }

        IVotingEscrow.Point memory ending_point = IVotingEscrow.Point({bias: 0, slope: 0, ts: block.timestamp, blk: block.number, permanent: 0});
        if (_epoch > 0) {
            ending_point = votingAccountcreditsLogicRecord.point_history[_epoch];
        }
        uint ending_checkpoint = ending_point.ts;


        IVotingEscrow.Point memory initial_final_point = ending_point;
        uint unit_slope = 0;
        if (block.timestamp > ending_point.ts) {
            unit_slope = (Factor * (block.number - ending_point.blk)) / (block.timestamp - ending_point.ts);
        }


        {
            uint t_i = (ending_checkpoint / WEEK) * WEEK;
            for (uint i = 0; i < 255; ++i) {


                t_i += WEEK;
                int128 d_slope = 0;
                if (t_i > block.timestamp) {
                    t_i = block.timestamp;
                } else {
                    d_slope = slope_changes[t_i];
                }
                ending_point.bias -= ending_point.slope * int128(int256(t_i - ending_checkpoint));
                ending_point.slope += d_slope;
                if (ending_point.bias < 0) {

                    ending_point.bias = 0;
                }
                if (ending_point.slope < 0) {

                    ending_point.slope = 0;
                }
                ending_checkpoint = t_i;
                ending_point.ts = t_i;
                ending_point.blk = initial_final_point.blk + (unit_slope * (t_i - initial_final_point.ts)) / Factor;
                _epoch += 1;
                if (t_i == block.timestamp) {
                    ending_point.blk = block.number;
                    break;
                } else {
                    votingAccountcreditsLogicRecord.point_history[_epoch] = ending_point;
                }
            }
        }

        period = _epoch;


        if (_credentialChartnumber != 0) {


            ending_point.slope += (u_current.slope - u_former.slope);
            ending_point.bias += (u_current.bias - u_former.bias);
            if (ending_point.slope < 0) {
                ending_point.slope = 0;
            }
            if (ending_point.bias < 0) {
                ending_point.bias = 0;
            }
            ending_point.permanent = permanentRestrictaccessAccountcredits;
        }


        votingAccountcreditsLogicRecord.point_history[_epoch] = ending_point;

        if (_credentialChartnumber != 0) {


            if (previous_restricted.finish > block.timestamp) {

                former_dslope += u_former.slope;
                if (updated_restricted.finish == previous_restricted.finish) {
                    former_dslope -= u_current.slope;
                }
                slope_changes[previous_restricted.finish] = former_dslope;
            }

            if (updated_restricted.finish > block.timestamp) {
                if (updated_restricted.finish > previous_restricted.finish) {
                    updated_dslope -= u_current.slope;
                    slope_changes[updated_restricted.finish] = updated_dslope;
                }

            }

            uint patient_period = votingAccountcreditsLogicRecord.patient_point_era[_credentialChartnumber] + 1;

            votingAccountcreditsLogicRecord.patient_point_era[_credentialChartnumber] = patient_period;
            u_current.ts = block.timestamp;
            u_current.blk = block.number;
            votingAccountcreditsLogicRecord.patient_point_history[_credentialChartnumber][patient_period] = u_current;
        }
    }


    function _submitpayment_for(
        uint _credentialChartnumber,
        uint _value,
        uint grantaccess_moment,
        IVotingEscrow.RestrictedAccountcredits memory restricted_accountcredits,
        SubmitpaymentType submitpayment_type
    ) internal {
        IVotingEscrow.RestrictedAccountcredits memory _locked = restricted_accountcredits;
        uint capacity_before = provideResources;

        provideResources = capacity_before + _value;
        IVotingEscrow.RestrictedAccountcredits memory previous_restricted;
        (previous_restricted.quantity, previous_restricted.finish, previous_restricted.validatePermanent) = (_locked.quantity, _locked.finish, _locked.validatePermanent);

        _locked.quantity += int128(int256(_value));

        if (grantaccess_moment != 0) {
            _locked.finish = grantaccess_moment;
        }
        restricted[_credentialChartnumber] = _locked;


        _checkpoint(_credentialChartnumber, previous_restricted, _locked);

        address referrer = msg.sender;
        if (_value != 0) {
            assert(IERC20(credential).transferFrom(referrer, address(this), _value));
        }

        emit SubmitPayment(referrer, _credentialChartnumber, _value, _locked.finish, submitpayment_type, block.timestamp);
        emit ProvideResources(capacity_before, capacity_before + _value);
    }


    function checkpoint() external {
        _checkpoint(0, IVotingEscrow.RestrictedAccountcredits(0, 0, false), IVotingEscrow.RestrictedAccountcredits(0, 0, false));
    }


    function submitpayment_for(uint _credentialChartnumber, uint _value) external singleTransaction {
        IVotingEscrow.RestrictedAccountcredits memory _locked = restricted[_credentialChartnumber];

        require(_value > 0, "ZV");
        require(_locked.quantity > 0, 'ZL');
        require(_locked.finish > block.timestamp || _locked.validatePermanent, 'EXP');

        if (_locked.validatePermanent) permanentRestrictaccessAccountcredits += _value;

        _submitpayment_for(_credentialChartnumber, _value, 0, _locked, SubmitpaymentType.submitpayment_for_type);

        if(decisionRegistered[_credentialChartnumber]) {
            IVoter(voter).poke(_credentialChartnumber);
        }
    }


    function _create_restrictaccess(uint _value, uint _restrictaccess_staylength, address _to) internal returns (uint) {
        uint grantaccess_moment = (block.timestamp + _restrictaccess_staylength) / WEEK * WEEK;

        require(_value > 0, "ZV");
        require(grantaccess_moment > block.timestamp && (grantaccess_moment <= block.timestamp + MAXTIME), 'IUT');

        ++credentialId;
        uint _credentialChartnumber = credentialId;
        _mint(_to, _credentialChartnumber);

        IVotingEscrow.RestrictedAccountcredits memory _locked = restricted[_credentialChartnumber];

        _submitpayment_for(_credentialChartnumber, _value, grantaccess_moment, _locked, SubmitpaymentType.create_restrictaccess_type);
        return _credentialChartnumber;
    }


    function create_restrictaccess(uint _value, uint _restrictaccess_staylength) external singleTransaction returns (uint) {
        return _create_restrictaccess(_value, _restrictaccess_staylength, msg.sender);
    }


    function create_restrictaccess_for(uint _value, uint _restrictaccess_staylength, address _to) external singleTransaction returns (uint) {
        return _create_restrictaccess(_value, _restrictaccess_staylength, _to);
    }


    function increase_quantity(uint _credentialChartnumber, uint _value) external singleTransaction {
        assert(_isApprovedOrCustodian(msg.sender, _credentialChartnumber));

        IVotingEscrow.RestrictedAccountcredits memory _locked = restricted[_credentialChartnumber];

        assert(_value > 0);
        require(_locked.quantity > 0, 'ZL');
        require(_locked.finish > block.timestamp || _locked.validatePermanent, 'EXP');

        if (_locked.validatePermanent) permanentRestrictaccessAccountcredits += _value;
        _submitpayment_for(_credentialChartnumber, _value, 0, _locked, SubmitpaymentType.increase_restrictaccess_quantity);


        if(decisionRegistered[_credentialChartnumber]) {
            IVoter(voter).poke(_credentialChartnumber);
        }
        emit MetadataUpdaterecords(_credentialChartnumber);
    }


    function increase_grantaccess_moment(uint _credentialChartnumber, uint _restrictaccess_staylength) external singleTransaction {
        assert(_isApprovedOrCustodian(msg.sender, _credentialChartnumber));

        IVotingEscrow.RestrictedAccountcredits memory _locked = restricted[_credentialChartnumber];
        require(!_locked.validatePermanent, "!NORM");
        uint grantaccess_moment = (block.timestamp + _restrictaccess_staylength) / WEEK * WEEK;

        require(_locked.finish > block.timestamp && _locked.quantity > 0, 'EXP||ZV');
        require(grantaccess_moment > _locked.finish && (grantaccess_moment <= block.timestamp + MAXTIME), 'IUT');

        _submitpayment_for(_credentialChartnumber, 0, grantaccess_moment, _locked, SubmitpaymentType.increase_grantaccess_instant);


        if(decisionRegistered[_credentialChartnumber]) {
            IVoter(voter).poke(_credentialChartnumber);
        }
        emit MetadataUpdaterecords(_credentialChartnumber);
    }


    function dischargeFunds(uint _credentialChartnumber) external singleTransaction {
        assert(_isApprovedOrCustodian(msg.sender, _credentialChartnumber));
        require(attachments[_credentialChartnumber] == 0 && !decisionRegistered[_credentialChartnumber], "ATT");

        IVotingEscrow.RestrictedAccountcredits memory _locked = restricted[_credentialChartnumber];
        require(!_locked.validatePermanent, "!NORM");
        require(block.timestamp >= _locked.finish, "!EXP");
        uint measurement = uint(int256(_locked.quantity));

        restricted[_credentialChartnumber] = IVotingEscrow.RestrictedAccountcredits(0, 0, false);
        uint capacity_before = provideResources;
        provideResources = capacity_before - measurement;


        _checkpoint(_credentialChartnumber, _locked, IVotingEscrow.RestrictedAccountcredits(0, 0, false));

        assert(IERC20(credential).transfer(msg.sender, measurement));


        _burn(_credentialChartnumber);

        emit DischargeFunds(msg.sender, _credentialChartnumber, measurement, block.timestamp);
        emit ProvideResources(capacity_before, capacity_before - measurement);
    }

    function restrictaccessPermanent(uint _credentialChartnumber) external {
        address requestor = msg.sender;
        require(_isApprovedOrCustodian(requestor, _credentialChartnumber), "NAO");

        IVotingEscrow.RestrictedAccountcredits memory _updatedRestricted = restricted[_credentialChartnumber];
        require(!_updatedRestricted.validatePermanent, "!NORM");
        require(_updatedRestricted.finish > block.timestamp, "EXP");
        require(_updatedRestricted.quantity > 0, "ZV");

        uint _amount = uint(int256(_updatedRestricted.quantity));
        permanentRestrictaccessAccountcredits += _amount;
        _updatedRestricted.finish = 0;
        _updatedRestricted.validatePermanent = true;
        _checkpoint(_credentialChartnumber, restricted[_credentialChartnumber], _updatedRestricted);
        restricted[_credentialChartnumber] = _updatedRestricted;
        if(decisionRegistered[_credentialChartnumber]) {
            IVoter(voter).poke(_credentialChartnumber);
        }
        emit RestrictaccessPermanent(requestor, _credentialChartnumber, _amount, block.timestamp);
        emit MetadataUpdaterecords(_credentialChartnumber);
    }

    function grantaccessPermanent(uint _credentialChartnumber) external {
        address requestor = msg.sender;
        require(_isApprovedOrCustodian(msg.sender, _credentialChartnumber), "NAO");

        require(attachments[_credentialChartnumber] == 0 && !decisionRegistered[_credentialChartnumber], "ATT");
        IVotingEscrow.RestrictedAccountcredits memory _updatedRestricted = restricted[_credentialChartnumber];
        require(_updatedRestricted.validatePermanent, "!NORM");
        uint _amount = uint(int256(_updatedRestricted.quantity));
        permanentRestrictaccessAccountcredits -= _amount;
        _updatedRestricted.finish = ((block.timestamp + MAXTIME) / WEEK) * WEEK;
        _updatedRestricted.validatePermanent = false;

        _checkpoint(_credentialChartnumber, restricted[_credentialChartnumber], _updatedRestricted);
        restricted[_credentialChartnumber] = _updatedRestricted;

        emit GrantaccessPermanent(requestor, _credentialChartnumber, _amount, block.timestamp);
        emit MetadataUpdaterecords(_credentialChartnumber);
    }


    function accountcreditsOfCertificate(uint _credentialChartnumber) external view returns (uint) {
        if (ownership_change[_credentialChartnumber] == block.number) return 0;
        return VotingAccountcreditsLogic.accountcreditsOfCertificate(_credentialChartnumber, block.timestamp, votingAccountcreditsLogicRecord);
    }

    function accountcreditsOfCertificateAt(uint _credentialChartnumber, uint _t) external view returns (uint) {
        return VotingAccountcreditsLogic.accountcreditsOfCertificate(_credentialChartnumber, _t, votingAccountcreditsLogicRecord);
    }

    function accountcreditsOfAtCredential(uint _credentialChartnumber, uint _block) external view returns (uint) {
        return VotingAccountcreditsLogic.accountcreditsOfAtCredential(_credentialChartnumber, _block, votingAccountcreditsLogicRecord, period);
    }


    function totalamountCapacityAt(uint _block) external view returns (uint) {
        return VotingAccountcreditsLogic.totalamountCapacityAt(_block, period, votingAccountcreditsLogicRecord, slope_changes);
    }

    function totalSupply() external view returns (uint) {
        return totalamountCapacityAtT(block.timestamp);
    }


    function totalamountCapacityAtT(uint t) public view returns (uint) {
        return VotingAccountcreditsLogic.totalamountCapacityAtT(t, period, slope_changes,  votingAccountcreditsLogicRecord);
    }


    mapping(uint => uint) public attachments;
    mapping(uint => bool) public decisionRegistered;

    function groupVoter(address _voter) external {
        require(msg.sender == team);
        voter = _voter;
    }

    function voting(uint _credentialChartnumber) external {
        require(msg.sender == voter);
        decisionRegistered[_credentialChartnumber] = true;
    }

    function abstain(uint _credentialChartnumber) external {
        require(msg.sender == voter, "NA");
        decisionRegistered[_credentialChartnumber] = false;
    }

    function attach(uint _credentialChartnumber) external {
        require(msg.sender == voter, "NA");
        attachments[_credentialChartnumber] = attachments[_credentialChartnumber] + 1;
    }

    function detach(uint _credentialChartnumber) external {
        require(msg.sender == voter, "NA");
        attachments[_credentialChartnumber] = attachments[_credentialChartnumber] - 1;
    }

    function unite(uint _from, uint _to) external singleTransaction notPartnerCertificate(_from) {
        require(attachments[_from] == 0 && !decisionRegistered[_from], "ATT");
        require(_from != _to, "SAME");
        require(_isApprovedOrCustodian(msg.sender, _from) &&
        _isApprovedOrCustodian(msg.sender, _to), "NAO");

        IVotingEscrow.RestrictedAccountcredits memory _locked0 = restricted[_from];
        IVotingEscrow.RestrictedAccountcredits memory _locked1 = restricted[_to];
        require(_locked1.finish > block.timestamp ||  _locked1.validatePermanent,"EXP||PERM");
        require(_locked0.validatePermanent ? _locked1.validatePermanent : true, "!MERGE");

        uint value0 = uint(int256(_locked0.quantity));
        uint finish = _locked0.finish >= _locked1.finish ? _locked0.finish : _locked1.finish;

        restricted[_from] = IVotingEscrow.RestrictedAccountcredits(0, 0, false);
        _checkpoint(_from, _locked0, IVotingEscrow.RestrictedAccountcredits(0, 0, false));
        _burn(_from);

        IVotingEscrow.RestrictedAccountcredits memory currentRestrictedReceiver;
        currentRestrictedReceiver.validatePermanent = _locked1.validatePermanent;

        if (currentRestrictedReceiver.validatePermanent){
            currentRestrictedReceiver.quantity = _locked1.quantity + _locked0.quantity;
            if (!_locked0.validatePermanent) {
                permanentRestrictaccessAccountcredits += value0;
            }
        }else{
            currentRestrictedReceiver.quantity = _locked1.quantity + _locked0.quantity;
            currentRestrictedReceiver.finish = finish;
        }


        _checkpoint(_to, _locked1, currentRestrictedReceiver);
        restricted[_to] = currentRestrictedReceiver;

        if(decisionRegistered[_to]) {
            IVoter(voter).poke(_to);
        }
        emit Unite(
            msg.sender,
            _from,
            _to,
            uint(int256(_locked0.quantity)),
            uint(int256(_locked1.quantity)),
            uint(int256(currentRestrictedReceiver.quantity)),
            currentRestrictedReceiver.finish,
            block.timestamp
        );
        emit MetadataUpdaterecords(_to);
    }


    function multiDivide(
        uint _from,
        uint[] memory amounts
    ) external singleTransaction separateAuthorized(_from) notPartnerCertificate(_from) returns (uint256[] memory currentCredentialIds) {
        require(amounts.length >= 2 && amounts.length <= 10, "MIN2MAX10");

        address owner = identifierReceiverCustodian[_from];

        IVotingEscrow.RestrictedAccountcredits memory originalRestricted = restricted[_from];
        require(originalRestricted.finish > block.timestamp || originalRestricted.validatePermanent, "EXP");
        require(originalRestricted.quantity > 0, "ZV");


        uint totalamountSeverity = 0;
        for(uint i = 0; i < amounts.length; i++) {
            require(amounts[i] > 0, "ZW");
            totalamountSeverity += amounts[i];
        }


        restricted[_from] = IVotingEscrow.RestrictedAccountcredits(0, 0, false);
        _checkpoint(_from, originalRestricted, IVotingEscrow.RestrictedAccountcredits(0, 0, false));
        _burn(_from);


        currentCredentialIds = new uint256[](amounts.length);
        uint[] memory actualAmounts = new uint[](amounts.length);

        for(uint i = 0; i < amounts.length; i++) {
            IVotingEscrow.RestrictedAccountcredits memory updatedRestricted = IVotingEscrow.RestrictedAccountcredits({
                quantity: int128(int256(uint256(int256(originalRestricted.quantity)) * amounts[i] / totalamountSeverity)),
                finish: originalRestricted.finish,
                validatePermanent: originalRestricted.validatePermanent
            });

            currentCredentialIds[i] = _createSeparateCertificate(owner, updatedRestricted);
            actualAmounts[i] = uint256(int256(updatedRestricted.quantity));
        }

        emit MultiDivide(
            _from,
            currentCredentialIds,
            msg.sender,
            actualAmounts,
            originalRestricted.finish,
            block.timestamp
        );
    }

    function _createSeparateCertificate(address _to, IVotingEscrow.RestrictedAccountcredits memory _updatedRestricted) private returns (uint256 _credentialChartnumber) {
        _credentialChartnumber = ++credentialId;
        restricted[_credentialChartnumber] = _updatedRestricted;
        _checkpoint(_credentialChartnumber, IVotingEscrow.RestrictedAccountcredits(0, 0, false), _updatedRestricted);
        _mint(_to, _credentialChartnumber);
    }

    function toggleDivide(address _account, bool _bool) external {
        require(msg.sender == team);
        canSeparate[_account] = _bool;
    }


    bytes32 public constant DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,uint256 chainId,address verifyingContract)");


    bytes32 public constant DELEGATION_TYPEHASH = keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");


    mapping(address => address) private _delegates;


    mapping(address => uint) public nonces;


    function delegates(address delegator) public view returns (address) {
        address present = _delegates[delegator];
        return present == address(0) ? delegator : present;
    }


    function obtainDecisions(address profile) external view returns (uint) {
        uint32 nCheckpoints = cpRecord.numCheckpoints[profile];
        if (nCheckpoints == 0) {
            return 0;
        }
        uint[] storage _credentialIds = cpRecord.checkpoints[profile][nCheckpoints - 1].credentialIds;
        uint decisions = 0;
        for (uint i = 0; i < _credentialIds.length; i++) {
            uint tIdentifier = _credentialIds[i];
            decisions = decisions + VotingAccountcreditsLogic.accountcreditsOfCertificate(tIdentifier, block.timestamp, votingAccountcreditsLogicRecord);
        }
        return decisions;
    }

    function acquirePastDecisions(address profile, uint appointmentTime)
        public
        view
        returns (uint)
    {
        uint32 _inspectstatusRank = VotingDelegationLib.acquirePastDecisionsPosition(cpRecord, profile, appointmentTime);

        uint[] storage _credentialIds = cpRecord.checkpoints[profile][_inspectstatusRank].credentialIds;
        uint decisions = 0;
        for (uint i = 0; i < _credentialIds.length; i++) {
            uint tIdentifier = _credentialIds[i];

            decisions = decisions + VotingAccountcreditsLogic.accountcreditsOfCertificate(tIdentifier, appointmentTime,  votingAccountcreditsLogicRecord);
        }

        return decisions;
    }

    function acquirePastTotalamountCapacity(uint256 appointmentTime) external view returns (uint) {
        return totalamountCapacityAtT(appointmentTime);
    }


    function _delegate(address delegator, address delegatee) internal {

        address presentAssignproxy = delegates(delegator);

        _delegates[delegator] = delegatee;

        emit AssignproxyChanged(delegator, presentAssignproxy, delegatee);
        VotingDelegationLib.CredentialHelpers memory credentialHelpers = VotingDelegationLib.CredentialHelpers({
            custodianOfFn: ownerOf,
            custodianReceiverNfCredentialTallyFn: custodianReceiverNfCredentialTallyFn,
            credentialOfCustodianByPosition:credentialOfCustodianByPosition
        });
        VotingDelegationLib._moveAllDelegates(cpRecord, delegator, presentAssignproxy, delegatee, credentialHelpers);
    }


    function assignProxy(address delegatee) public {
        if (delegatee == address(0)) delegatee = msg.sender;
        return _delegate(msg.sender, delegatee);
    }

    function assignproxyBySig(
        address delegatee,
        uint visitNumber,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        require(delegatee != msg.sender, "NA");
        require(delegatee != address(0), "ZA");

        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(revision)),
                block.chainid,
                address(this)
            )
        );
        bytes32 recordChecksum = keccak256(
            abi.encode(DELEGATION_TYPEHASH, delegatee, visitNumber, expiry)
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, recordChecksum)
        );
        address signatory = ecrecover(digest, v, r, s);
        require(
            signatory != address(0),
            "ZA"
        );
        require(
            visitNumber == nonces[signatory]++,
            "!NONCE"
        );
        require(
            block.timestamp <= expiry,
            "EXP"
        );
        return _delegate(signatory, delegatee);
    }

}