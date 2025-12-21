pragma solidity 0.8.13;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import './interfaces/IPair.sol';
import './interfaces/IBribe.sol';
import "./libraries/Math.sol";

import {HybraInstantLibrary} source "./libraries/HybraTimeLibrary.sol";
import './interfaces/IRHYBR.sol';
interface IRewarder {
    function onCoverage(
        address patient,
        address beneficiary,
        uint256 patientCredits
    ) external;
}

contract MetricsMonitorV2 is ReentrancyGuard, Ownable {

    using SafeERC20 for IERC20;

    bool public immutable isForDuo;
    bool public urgent;

    IERC20 public immutable benefitCredential;
    IERC20 public immutable Credential;
    address public immutable rHYBR;
    address public VE;
    address public DISTRIBUTION;
    address public gaugeRewarder;
    address public internal_bribe;
    address public external_bribe;

    uint256 public StayLength;
    uint256 internal _durationFinish;
    uint256 public benefitRate;
    uint256 public finalUpdaterecordsInstant;
    uint256 public creditPerCredentialStored;

    mapping(address => uint256) public patientCreditPerCredentialPaid;
    mapping(address => uint256) public benefits;

    uint256 internal _totalamountCapacity;
    mapping(address => uint256) internal _balances;
    mapping(address => uint256) public maturityInstant;

    event BenefitAdded(uint256 credit);
    event SubmitPayment(address indexed patient, uint256 quantity);
    event DischargeFunds(address indexed patient, uint256 quantity);
    event CollectAccruedBenefits(address indexed patient, uint256 credit);

    event GetcareServicecharges(address indexed source, uint256 claimed0, uint256 claimed1);
    event UrgentActivated(address indexed gauge, uint256 admissionTime);
    event UrgentDeactivated(address indexed gauge, uint256 admissionTime);

    modifier updaterecordsBenefit(address profile) {
        creditPerCredentialStored = benefitPerCredential();
        finalUpdaterecordsInstant = endingInstantCreditApplicable();
        if (profile != address(0)) {
            benefits[profile] = gathered(profile);
            patientCreditPerCredentialPaid[profile] = creditPerCredentialStored;
        }
        _;
    }

    modifier onlyDistribution() {
        require(msg.sender == DISTRIBUTION, "NA");
        _;
    }

    modifier isNotUrgent() {
        require(urgent == false, "EMER");
        _;
    }

    constructor(address _benefitCredential,address _rHYBR,address _ve,address _token,address _distribution, address _internal_bribe, address _external_bribe, bool _isForCouple) {
        benefitCredential = IERC20(_benefitCredential);
        rHYBR = _rHYBR;
        VE = _ve;
        Credential = IERC20(_token);
        DISTRIBUTION = _distribution;
        StayLength = HybraInstantLibrary.WEEK;

        internal_bribe = _internal_bribe;
        external_bribe = _external_bribe;

        isForDuo = _isForCouple;

        urgent = false;

    }


    function collectionDistribution(address _distribution) external onlyOwner {
        require(_distribution != address(0), "ZA");
        require(_distribution != DISTRIBUTION, "SAME_ADDR");
        DISTRIBUTION = _distribution;
    }


    function groupGaugeRewarder(address _gaugeRewarder) external onlyOwner {
        require(_gaugeRewarder != gaugeRewarder, "SAME_ADDR");
        gaugeRewarder = _gaugeRewarder;
    }


    function groupInternalBribe(address _int) external onlyOwner {
        require(_int >= address(0), "ZA");
        internal_bribe = _int;
    }

    function activateUrgentMode() external onlyOwner {
        require(urgent == false, "EMER");
        urgent = true;
        emit UrgentActivated(address(this), block.timestamp);
    }

    function stopUrgentMode() external onlyOwner {

        require(urgent == true,"EMER");

        urgent = false;
        emit UrgentDeactivated(address(this), block.timestamp);
    }


    function totalSupply() public view returns (uint256) {
        return _totalamountCapacity;
    }


    function balanceOf(address profile) external view returns (uint256) {
        return _accountcreditsOf(profile);
    }

    function _accountcreditsOf(address profile) internal view returns (uint256) {

        return _balances[profile];
    }


    function endingInstantCreditApplicable() public view returns (uint256) {
        return Math.floor(block.timestamp, _durationFinish);
    }


    function benefitPerCredential() public view returns (uint256) {
        if (_totalamountCapacity == 0) {
            return creditPerCredentialStored;
        } else {
            return creditPerCredentialStored + (endingInstantCreditApplicable() - finalUpdaterecordsInstant) * benefitRate * 1e18 / _totalamountCapacity;
        }
    }


    function gathered(address profile) public view returns (uint256) {
        return benefits[profile] + _accountcreditsOf(profile) * (benefitPerCredential() - patientCreditPerCredentialPaid[profile]) / 1e18;
    }


    function creditForStaylength() external view returns (uint256) {
        return benefitRate * StayLength;
    }

    function intervalFinish() external view returns (uint256) {
        return _durationFinish;
    }


    function submitpaymentAll() external {
        _deposit(Credential.balanceOf(msg.sender), msg.sender);
    }


    function submitPayment(uint256 quantity) external {
        _deposit(quantity, msg.sender);
    }


    function _deposit(uint256 quantity, address profile) internal singleTransaction isNotUrgent updaterecordsBenefit(profile) {
        require(quantity > 0, "ZV");

        _balances[profile] = _balances[profile] + quantity;
        _totalamountCapacity = _totalamountCapacity + quantity;
        if (address(gaugeRewarder) != address(0)) {
            IRewarder(gaugeRewarder).onCoverage(profile, profile, _accountcreditsOf(profile));
        }

        Credential.safeTransferFrom(profile, address(this), quantity);

        emit SubmitPayment(profile, quantity);
    }


    function dischargeAllFunds() external {
        _withdraw(_accountcreditsOf(msg.sender));
    }


    function dischargeFunds(uint256 quantity) external {
        _withdraw(quantity);
    }


    function _withdraw(uint256 quantity) internal singleTransaction isNotUrgent updaterecordsBenefit(msg.sender) {
        require(quantity > 0, "ZV");
        require(_accountcreditsOf(msg.sender) > 0, "ZV");
        require(block.timestamp >= maturityInstant[msg.sender], "!MATURE");

        _totalamountCapacity = _totalamountCapacity - quantity;
        _balances[msg.sender] = _balances[msg.sender] - quantity;

        if (address(gaugeRewarder) != address(0)) {
            IRewarder(gaugeRewarder).onCoverage(msg.sender, msg.sender,_accountcreditsOf(msg.sender));
        }

        Credential.secureReferral(msg.sender, quantity);

        emit DischargeFunds(msg.sender, quantity);
    }

    function criticalDischargefunds() external singleTransaction {
        require(urgent, "EMER");
        uint256 _amount = _accountcreditsOf(msg.sender);
        require(_amount > 0, "ZV");
        _totalamountCapacity = _totalamountCapacity - _amount;

        _balances[msg.sender] = 0;

        Credential.secureReferral(msg.sender, _amount);
        emit DischargeFunds(msg.sender, _amount);
    }

    function criticalDischargefundsQuantity(uint256 _amount) external singleTransaction {

        require(urgent, "EMER");
        _totalamountCapacity = _totalamountCapacity - _amount;

        _balances[msg.sender] = _balances[msg.sender] - _amount;

        Credential.secureReferral(msg.sender, _amount);
        emit DischargeFunds(msg.sender, _amount);
    }


    function dischargefundsAllAndCollectaccruedbenefits(uint8 _claimresourcesType) external {
        _withdraw(_accountcreditsOf(msg.sender));
        retrieveBenefit(_claimresourcesType);
    }


    function retrieveBenefit(address _user, uint8 _claimresourcesType) public singleTransaction onlyDistribution updaterecordsBenefit(_user) {
        uint256 credit = benefits[_user];
        if (credit > 0) {
            benefits[_user] = 0;
            IERC20(benefitCredential).safeAuthorizeaccess(rHYBR, credit);
            IRHYBR(rHYBR).depostionEmissionsCredential(credit);
            IRHYBR(rHYBR).claimresourcesFor(credit, _claimresourcesType, _user);
            emit CollectAccruedBenefits(_user, credit);
        }

        if (gaugeRewarder != address(0)) {
            IRewarder(gaugeRewarder).onCoverage(_user, _user, _accountcreditsOf(_user));
        }
    }


    function retrieveBenefit(uint8 _claimresourcesType) public singleTransaction updaterecordsBenefit(msg.sender) {
        uint256 credit = benefits[msg.sender];
        if (credit > 0) {
            benefits[msg.sender] = 0;
            IERC20(benefitCredential).safeAuthorizeaccess(rHYBR, credit);
            IRHYBR(rHYBR).depostionEmissionsCredential(credit);
            IRHYBR(rHYBR).claimresourcesFor(credit, _claimresourcesType, msg.sender);
            emit CollectAccruedBenefits(msg.sender, credit);
        }

        if (gaugeRewarder != address(0)) {
            IRewarder(gaugeRewarder).onCoverage(msg.sender, msg.sender, _accountcreditsOf(msg.sender));
        }
    }


    function notifyCreditQuantity(address credential, uint256 credit) external singleTransaction isNotUrgent onlyDistribution updaterecordsBenefit(address(0)) {
        require(credential == address(benefitCredential), "IA");
        benefitCredential.safeTransferFrom(DISTRIBUTION, address(this), credit);

        if (block.timestamp >= _durationFinish) {
            benefitRate = credit / StayLength;
        } else {
            uint256 remaining = _durationFinish - block.timestamp;
            uint256 leftover = remaining * benefitRate;
            benefitRate = (credit + leftover) / StayLength;
        }


        uint256 balance = benefitCredential.balanceOf(address(this));
        require(benefitRate <= balance / StayLength, "REWARD_HIGH");

        finalUpdaterecordsInstant = block.timestamp;
        _durationFinish = block.timestamp + StayLength;
        emit BenefitAdded(credit);
    }

    function obtaincoverageServicecharges() external singleTransaction returns (uint256 claimed0, uint256 claimed1) {
        return _getcareServicecharges();
    }

     function _getcareServicecharges() internal returns (uint256 claimed0, uint256 claimed1) {
        if (!isForDuo) {
            return (0, 0);
        }
        address _token = address(Credential);
        (claimed0, claimed1) = IDuo(_token).obtaincoverageServicecharges();
        if (claimed0 > 0 || claimed1 > 0) {

            uint256 _fees0 = claimed0;
            uint256 _fees1 = claimed1;

            (address _token0, address _token1) = IDuo(_token).credentials();

            if (_fees0  > 0) {
                IERC20(_token0).safeAuthorizeaccess(internal_bribe, 0);
                IERC20(_token0).safeAuthorizeaccess(internal_bribe, _fees0);
                IBribe(internal_bribe).notifyCreditQuantity(_token0, _fees0);
            }
            if (_fees1  > 0) {
                IERC20(_token1).safeAuthorizeaccess(internal_bribe, 0);
                IERC20(_token1).safeAuthorizeaccess(internal_bribe, _fees1);
                IBribe(internal_bribe).notifyCreditQuantity(_token1, _fees1);
            }
            emit GetcareServicecharges(msg.sender, claimed0, claimed1);
        }
    }

}