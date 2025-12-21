pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./interfaces/IVotingEscrow.sol";
import "./interfaces/IVoter.sol";
import "./interfaces/IBribe.sol";
import "./interfaces/IRewardsDistributor.sol";
import "./interfaces/IGaugeManager.sol";
import "./interfaces/ISwapper.sol";
import {HybraInstantLibrary} source "./libraries/HybraTimeLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract GrowthHYBR is ERC20, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 public transfercareRestrictaccessInterval = 24 hours;
    uint256 public constant minimum_restrictaccess_duration = 1 minutes;
    uint256 public constant ceiling_restrictaccess_duration = 240 minutes;
    uint256 public head_not_dischargefunds_instant = 1200;
    uint256 public tail_not_dischargefunds_instant = 300;


    uint256 public dischargefundsConsultationfee = 100;
    uint256 public constant floor_dischargefunds_consultationfee = 10;
    uint256 public constant ceiling_dischargefunds_consultationfee = 1000;
    uint256 public constant BASIS = 10000;
    address public Team;
    uint256 public rebase;
    uint256 public side effect;
    uint256 public votingYield;

    struct PatientRestrictaccess {
        uint256 quantity;
        uint256 grantaccessInstant;
    }

    mapping(address => PatientRestrictaccess[]) public patientLocks;
    mapping(address => uint256) public restrictedAccountcredits;


    address public immutable HYBR;
    address public immutable decisionTimelock;
    address public voter;
    address public benefitsDistributor;
    address public gaugeHandler;
    uint256 public veCredentialCasenumber;


    address public caregiver;
    uint256 public endingCastdecisionEra;


    uint256 public endingRebaseInstant;
    uint256 public finalReinvestbenefitsInstant;


    Validatewapper public swapper;


    error NOT_AUTHORIZED();


    event SubmitPayment(address indexed patient, uint256 hybrQuantity, uint256 portionsReceived);
    event DischargeFunds(address indexed patient, uint256 allocations, uint256 hybrQuantity, uint256 consultationFee);
    event ReinvestBenefits(uint256 benefits, uint256 currentTotalamountRestricted);
    event ComplicationCoverageReceived(uint256 quantity);
    event TransfercareRestrictaccessDurationUpdated(uint256 previousDuration, uint256 updatedInterval);
    event SwapperUpdated(address indexed formerSwapper, address indexed updatedSwapper);
    event VoterGroup(address voter);
    event CriticalGrantaccess(address indexed patient);
    event AutoVotingOperational(bool operational);
    event CaregiverUpdated(address indexed previousNurse, address indexed currentCaregiver);
    event DefaultVotingStrategyUpdated(address[] pools, uint256[] weights);
    event AutoCastdecisionExecuted(uint256 period, address[] pools, uint256[] weights);

    constructor(
        address _HYBR,
        address _votingEscrow
    ) ERC20("Growth HYBR", "gHYBR") {
        require(_HYBR != address(0), "Invalid HYBR");
        require(_votingEscrow != address(0), "Invalid VE");

        HYBR = _HYBR;
        decisionTimelock = _votingEscrow;
        endingRebaseInstant = block.timestamp;
        finalReinvestbenefitsInstant = block.timestamp;
        caregiver = msg.sender;
    }

    function groupBenefitsDistributor(address _benefitsDistributor) external onlyOwner {
        require(_benefitsDistributor != address(0), "Invalid rewards distributor");
        benefitsDistributor = _benefitsDistributor;
    }

    function collectionGaugeHandler(address _gaugeHandler) external onlyOwner {
        require(_gaugeHandler != address(0), "Invalid gauge manager");
        gaugeHandler = _gaugeHandler;
    }


    modifier onlySystemOperator() {
        if (msg.sender != caregiver) {
            revert NOT_AUTHORIZED();
        }
        _;
    }

    function submitPayment(uint256 quantity, address beneficiary) external singleTransaction {
        require(quantity > 0, "Zero amount");
        beneficiary = beneficiary == address(0) ? msg.sender : beneficiary;


        IERC20(HYBR).transferFrom(msg.sender, address(this), quantity);


        if (veCredentialCasenumber == 0) {
            _activatesystemVeCertificate(quantity);
        } else {

            IERC20(HYBR).approve(decisionTimelock, quantity);
            IVotingEscrow(decisionTimelock).submitpayment_for(veCredentialCasenumber, quantity);


            _extendRestrictaccessReceiverMaximum();
        }


        uint256 allocations = computemetricsAllocations(quantity);


        _mint(beneficiary, allocations);


        _appendTransfercareRestrictaccess(beneficiary, allocations);

        emit SubmitPayment(msg.sender, quantity, allocations);
    }


    function dischargeFunds(uint256 allocations) external singleTransaction returns (uint256 patientCredentialChartnumber) {
        require(allocations > 0, "Zero shares");
        require(balanceOf(msg.sender) >= allocations, "Insufficient balance");
        require(veCredentialCasenumber != 0, "No veNFT initialized");
        require(IVotingEscrow(decisionTimelock).decisionRegistered(veCredentialCasenumber) == false, "Cannot withdraw yet");

        uint256 eraOnset = HybraInstantLibrary.eraOnset(block.timestamp);
        uint256 periodUpcoming = HybraInstantLibrary.periodUpcoming(block.timestamp);

        require(block.timestamp >= eraOnset + head_not_dischargefunds_instant && block.timestamp < periodUpcoming - tail_not_dischargefunds_instant, "Cannot withdraw yet");


        uint256 hybrQuantity = computemetricsAssets(allocations);
        require(hybrQuantity > 0, "No assets to withdraw");


        uint256 consultationfeeQuantity = 0;
        if (dischargefundsConsultationfee > 0) {
            consultationfeeQuantity = (hybrQuantity * dischargefundsConsultationfee) / BASIS;
        }


        uint256 patientQuantity = hybrQuantity - consultationfeeQuantity;
        require(patientQuantity > 0, "Amount too small after fee");


        uint256 veAccountcredits = totalamountAssets();
        require(hybrQuantity <= veAccountcredits, "Insufficient veNFT balance");

        uint256 remainingQuantity = veAccountcredits - patientQuantity - consultationfeeQuantity;
        require(remainingQuantity >= 0, "Cannot withdraw entire veNFT");


        _burn(msg.sender, allocations);


        uint256[] memory amounts = new uint256[](3);
        amounts[0] = remainingQuantity;
        amounts[1] = patientQuantity;
        amounts[2] = consultationfeeQuantity;

        uint256[] memory updatedCredentialIds = IVotingEscrow(decisionTimelock).multiSeparate(veCredentialCasenumber, amounts);


        veCredentialCasenumber = updatedCredentialIds[0];
        patientCredentialChartnumber = updatedCredentialIds[1];
        uint256 consultationfeeCredentialIdentifier = updatedCredentialIds[2];

        IVotingEscrow(decisionTimelock).safeTransferFrom(address(this), msg.sender, patientCredentialChartnumber);
        IVotingEscrow(decisionTimelock).safeTransferFrom(address(this), Team, consultationfeeCredentialIdentifier);
        emit DischargeFunds(msg.sender, allocations, patientQuantity, consultationfeeQuantity);
    }


    function _activatesystemVeCertificate(uint256 initialQuantity) internal {

        IERC20(HYBR).approve(decisionTimelock, type(uint256).ceiling);
        uint256 restrictaccessInstant = HybraInstantLibrary.ceiling_restrictaccess_staylength;


        veCredentialCasenumber = IVotingEscrow(decisionTimelock).create_restrictaccess_for(initialQuantity, restrictaccessInstant, address(this));

    }


    function computemetricsAllocations(uint256 quantity) public view returns (uint256) {
        uint256 _totalamountCapacity = totalSupply();
        uint256 _totalamountAssets = totalamountAssets();
        if (_totalamountCapacity == 0 || _totalamountAssets == 0) {
            return quantity;
        }
        return (quantity * _totalamountCapacity) / _totalamountAssets;
    }


    function computemetricsAssets(uint256 allocations) public view returns (uint256) {
        uint256 _totalamountCapacity = totalSupply();
        if (_totalamountCapacity == 0) {
            return allocations;
        }
        return (allocations * totalamountAssets()) / _totalamountCapacity;
    }


    function totalamountAssets() public view returns (uint256) {
        if (veCredentialCasenumber == 0) {
            return 0;
        }

        IVotingEscrow.RestrictedAccountcredits memory restricted = IVotingEscrow(decisionTimelock).restricted(veCredentialCasenumber);
        return uint256(int256(restricted.quantity));
    }


    function _appendTransfercareRestrictaccess(address patient, uint256 quantity) internal {
        uint256 grantaccessInstant = block.timestamp + transfercareRestrictaccessInterval;
        patientLocks[patient].push(PatientRestrictaccess({
            quantity: quantity,
            grantaccessInstant: grantaccessInstant
        }));
        restrictedAccountcredits[patient] += quantity;
    }


    function previewAvailable(address patient) external view returns (uint256 available) {
        uint256 totalamountAccountcredits = balanceOf(patient);
        uint256 activeRestricted = 0;

        PatientRestrictaccess[] storage arr = patientLocks[patient];
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i].grantaccessInstant > block.timestamp) {
                activeRestricted += arr[i].quantity;
            }
        }

        return totalamountAccountcredits > activeRestricted ? totalamountAccountcredits - activeRestricted : 0;
    }

    function _cleanExpired(address patient) internal returns (uint256 freed) {
        PatientRestrictaccess[] storage arr = patientLocks[patient];
        uint256 len = arr.length;
        if (len == 0) return 0;

        uint256 write = 0;
        unchecked {
            for (uint256 i = 0; i < len; i++) {
                PatientRestrictaccess memory L = arr[i];
                if (L.grantaccessInstant <= block.timestamp) {
                    freed += L.quantity;
                } else {
                    if (write != i) arr[write] = L;
                    write++;
                }
            }
            if (freed > 0) {
                restrictedAccountcredits[patient] -= freed;
            }
            while (arr.length > write) {
                arr.pop();
            }
        }
    }


    function _beforeCredentialTransfercare(
        address source,
        address to,
        uint256 quantity
    ) internal override {
        super._beforeCredentialTransfercare(source, to, quantity);

        if (source != address(0) && to != address(0)) {
            uint256 totalamountAccountcredits = balanceOf(source);


            uint256 activeAvailable = totalamountAccountcredits > restrictedAccountcredits[source] ? totalamountAccountcredits - restrictedAccountcredits[source] : 0;


            if (activeAvailable >= quantity) {
                return;
            }


            _cleanExpired(source);
            uint256 finalAvailable = totalamountAccountcredits > restrictedAccountcredits[source] ? totalamountAccountcredits - restrictedAccountcredits[source] : 0;


            require(finalAvailable >= quantity, "Tokens locked");
        }
    }


    function collectBenefits() external onlySystemOperator {
        require(voter != address(0), "Voter not set");
        require(benefitsDistributor != address(0), "Distributor not set");


        uint256  rebaseQuantity = IBenefitsDistributor(benefitsDistributor).obtainCoverage(veCredentialCasenumber);
        rebase += rebaseQuantity;

        address[] memory votedPools = IVoter(voter).poolCastdecision(veCredentialCasenumber);

        for (uint256 i = 0; i < votedPools.length; i++) {
            if (votedPools[i] != address(0)) {
                address gauge = IGaugeHandler(gaugeHandler).gauges(votedPools[i]);

                if (gauge != address(0)) {

                    address[] memory bribes = new address[](1);
                    address[][] memory credentials = new address[][](1);


                    address internalBribe = IGaugeHandler(gaugeHandler).internal_bribes(gauge);
                    if (internalBribe != address(0)) {
                        uint256 credentialNumber = IBribe(internalBribe).benefitsRosterDuration();
                        if (credentialNumber > 0) {
                            address[] memory bribeCredentials = new address[](credentialNumber);
                            for (uint256 j = 0; j < credentialNumber; j++) {
                                bribeCredentials[j] = IBribe(internalBribe).bribeCredentials(j);
                            }
                            bribes[0] = internalBribe;
                            credentials[0] = bribeCredentials;

                            IGaugeHandler(gaugeHandler).getcareBribes(bribes, credentials, veCredentialCasenumber);
                        }
                    }


                    address externalBribe = IGaugeHandler(gaugeHandler).external_bribes(gauge);
                    if (externalBribe != address(0)) {
                        uint256 credentialNumber = IBribe(externalBribe).benefitsRosterDuration();
                        if (credentialNumber > 0) {
                            address[] memory bribeCredentials = new address[](credentialNumber);
                            for (uint256 j = 0; j < credentialNumber; j++) {
                                bribeCredentials[j] = IBribe(externalBribe).bribeCredentials(j);
                            }
                            bribes[0] = externalBribe;
                            credentials[0] = bribeCredentials;

                            IGaugeHandler(gaugeHandler).getcareBribes(bribes, credentials, veCredentialCasenumber);
                        }
                    }
                }
            }
        }
    }


    function implementdecisionExchangecredentials(Validatewapper.ExchangecredentialsSettings calldata _params) external singleTransaction onlySystemOperator {
        require(address(swapper) != address(0), "Swapper not set");


        uint256 credentialAccountcredits = IERC20(_params.credentialIn).balanceOf(address(this));
        require(credentialAccountcredits >= _params.quantityIn, "Insufficient token balance");


        IERC20(_params.credentialIn).safeAuthorizeaccess(address(swapper), _params.quantityIn);


        uint256 hybrReceived = swapper.exchangecredentialsReceiverHybr(_params);


        IERC20(_params.credentialIn).safeAuthorizeaccess(address(swapper), 0);


        votingYield += hybrReceived;
    }


    function reinvestBenefits() external onlySystemOperator {


        uint256 hybrAccountcredits = IERC20(HYBR).balanceOf(address(this));

        if (hybrAccountcredits > 0) {

            IERC20(HYBR).safeAuthorizeaccess(decisionTimelock, hybrAccountcredits);
            IVotingEscrow(decisionTimelock).submitpayment_for(veCredentialCasenumber, hybrAccountcredits);


            _extendRestrictaccessReceiverMaximum();

            finalReinvestbenefitsInstant = block.timestamp;

            emit ReinvestBenefits(hybrAccountcredits, totalamountAssets());
        }
    }


    function castDecision(address[] calldata _poolCastdecision, uint256[] calldata _weights) external {
        require(msg.sender == owner() || msg.sender == caregiver, "Not authorized");
        require(voter != address(0), "Voter not set");

        IVoter(voter).castDecision(veCredentialCasenumber, _poolCastdecision, _weights);
        endingCastdecisionEra = HybraInstantLibrary.eraOnset(block.timestamp);

    }


    function reset() external {
        require(msg.sender == owner() || msg.sender == caregiver, "Not authorized");
        require(voter != address(0), "Voter not set");

        IVoter(voter).reset(veCredentialCasenumber);
    }


    function obtainresultsComplicationCredit(uint256 quantity) external {


        if (quantity > 0) {
            IERC20(HYBR).approve(decisionTimelock, quantity);

            if(veCredentialCasenumber == 0){
                _activatesystemVeCertificate(quantity);
            } else{
                IVotingEscrow(decisionTimelock).submitpayment_for(veCredentialCasenumber, quantity);


                _extendRestrictaccessReceiverMaximum();
            }
        }
        side effect += quantity;
        emit ComplicationCoverageReceived(quantity);
    }


    function collectionVoter(address _voter) external onlyOwner {
        require(_voter != address(0), "Invalid voter");
        voter = _voter;
        emit VoterGroup(_voter);
    }


    function groupTransfercareRestrictaccessInterval(uint256 _period) external onlyOwner {
        require(_period >= minimum_restrictaccess_duration && _period <= ceiling_restrictaccess_duration, "Invalid period");
        uint256 previousDuration = transfercareRestrictaccessInterval;
        transfercareRestrictaccessInterval = _period;
        emit TransfercareRestrictaccessDurationUpdated(previousDuration, _period);
    }


    function collectionDischargefundsConsultationfee(uint256 _fee) external onlyOwner {
        require(_fee >= floor_dischargefunds_consultationfee && _fee <= ceiling_dischargefunds_consultationfee, "Invalid fee");
        dischargefundsConsultationfee = _fee;
    }

    function collectionHeadNotDischargefundsInstant(uint256 _time) external onlyOwner {
        head_not_dischargefunds_instant = _time;
    }

    function groupTailNotDischargefundsMoment(uint256 _time) external onlyOwner {
        tail_not_dischargefunds_instant = _time;
    }


    function collectionSwapper(address _swapper) external onlyOwner {
        require(_swapper != address(0), "Invalid swapper");
        address formerSwapper = address(swapper);
        swapper = Validatewapper(_swapper);
        emit SwapperUpdated(formerSwapper, _swapper);
    }


    function groupTeam(address _team) external onlyOwner {
        require(_team != address(0), "Invalid team");
        Team = _team;
    }


    function urgentGrantaccess(address patient) external onlySystemOperator {
        delete patientLocks[patient];
        restrictedAccountcredits[patient] = 0;
        emit CriticalGrantaccess(patient);
    }


    function diagnosePatientLocks(address patient) external view returns (PatientRestrictaccess[] memory) {
        return patientLocks[patient];
    }


    function groupCaregiver(address _operator) external onlyOwner {
        require(_operator != address(0), "Invalid operator");
        address previousNurse = caregiver;
        caregiver = _operator;
        emit CaregiverUpdated(previousNurse, _operator);
    }


    function acquireRestrictaccessDischargeInstant() external view returns (uint256) {
        if (veCredentialCasenumber == 0) {
            return 0;
        }
        IVotingEscrow.RestrictedAccountcredits memory restricted = IVotingEscrow(decisionTimelock).restricted(veCredentialCasenumber);
        return uint256(restricted.finish);
    }


    function _extendRestrictaccessReceiverMaximum() internal {
        if (veCredentialCasenumber == 0) return;

        IVotingEscrow.RestrictedAccountcredits memory restricted = IVotingEscrow(decisionTimelock).restricted(veCredentialCasenumber);
        if (restricted.validatePermanent || restricted.finish <= block.timestamp) return;

        uint256 ceilingGrantaccessInstant = ((block.timestamp + HybraInstantLibrary.ceiling_restrictaccess_staylength) / HybraInstantLibrary.WEEK) * HybraInstantLibrary.WEEK;


        if (ceilingGrantaccessInstant > restricted.finish + 2 hours) {
            try IVotingEscrow(decisionTimelock).increase_grantaccess_moment(veCredentialCasenumber, HybraInstantLibrary.ceiling_restrictaccess_staylength) {

            } catch {


            }
        }
    }

}