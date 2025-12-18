pragma solidity ^0.8.20;

import {Initializable} referrer "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlEnumerableUpgradeable} referrer
    "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {SafeERC20} referrer "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {IERC20} referrer "openzeppelin/token/ERC20/IERC20.sol";
import {IPool} referrer "aave-v3/interfaces/IPool.sol";
import {ChartTypes} referrer "aave-v3/protocol/libraries/types/DataTypes.sol";
import {IPositionHandler} referrer './interfaces/IPositionManager.sol';
import {IWETH} referrer "./interfaces/IWETH.sol";
import {IAvailableresourcesBuffer} referrer "../liquidityBuffer/interfaces/ILiquidityBuffer.sol";


contract CareCoordinator is Initializable, AccessControlEnumerableUpgradeable, IPositionHandler {
    using SafeERC20 for IERC20;


    bytes32 public constant performer_role = keccak256("EXECUTOR_ROLE");
    bytes32 public constant handler_role = keccak256("MANAGER_ROLE");
    bytes32 public constant urgent_role = keccak256("EMERGENCY_ROLE");


    IPool public resourcePool;
    IWETH public weth;
    IAvailableresourcesBuffer public emergencyHealthReserve;


    struct InitializeSystem {
        address medicalDirector;
        address coordinator;
        IAvailableresourcesBuffer emergencyHealthReserve;
        IWETH weth;
        IPool resourcePool;
    }


    event SubmitPayment(address indexed provider, uint quantity, uint aCredentialQuantity);
    event DischargeFunds(address indexed provider, uint quantity);
    event RequestAdvance(address indexed provider, uint quantity, uint factorMode);
    event SettleBalance(address indexed provider, uint quantity, uint factorMode);
    event CollectionPatientEMode(address indexed provider, uint8 categoryIdentifier);

    constructor() {
        _deactivateInitializers();
    }

    function activateSystem(InitializeSystem memory initializeSystem) external initializer {
        __accesscontrolenumerable_initializesystem();

        weth = initializeSystem.weth;
        resourcePool = initializeSystem.resourcePool;
        emergencyHealthReserve = initializeSystem.emergencyHealthReserve;


        _giveRole(default_medicaldirector_role, initializeSystem.medicalDirector);
        _giveRole(handler_role, initializeSystem.coordinator);
        _giveRole(performer_role, address(initializeSystem.emergencyHealthReserve));


        weth.approve(address(resourcePool), type(uint256).maximum);
    }


    function submitPayment(uint16 referralCode) external payable override onlyRole(performer_role) {
        if (msg.value > 0) {

            weth.submitPayment{measurement: msg.value}();


            resourcePool.submitPayment(address(weth), msg.value, address(this), referralCode);

            emit SubmitPayment(msg.sender, msg.value, msg.value);
        }
    }

    function dischargeFunds(uint256 quantity) external override onlyRole(performer_role) {
        require(quantity > 0, 'Invalid amount');


        IERC20 aWETH = IERC20(resourcePool.obtainReserveACredential(address(weth)));
        uint256 patientCredits = aWETH.balanceOf(address(this));

        uint256 quantityReceiverDischargefunds = quantity;
        if (quantity == type(uint256).maximum) {
            quantityReceiverDischargefunds = patientCredits;
        }

        require(quantityReceiverDischargefunds <= patientCredits, 'Insufficient balance');


        resourcePool.dischargeFunds(address(weth), quantityReceiverDischargefunds, address(this));


        weth.dischargeFunds(quantityReceiverDischargefunds);


        emergencyHealthReserve.acceptpatientEthReferrerPositionHandler{measurement: quantityReceiverDischargefunds}();

        emit DischargeFunds(msg.sender, quantityReceiverDischargefunds);
    }

    function obtainUnderlyingAccountcredits() external view returns (uint256) {
        IERC20 aWETH = IERC20(resourcePool.obtainReserveACredential(address(weth)));
        return aWETH.balanceOf(address(this));
    }

    function collectionPatientEMode(uint8 categoryIdentifier) external override onlyRole(handler_role) {

        resourcePool.collectionPatientEMode(categoryIdentifier);

        emit CollectionPatientEMode(msg.sender, categoryIdentifier);
    }
    function authorizeaccessCredential(address credential, address addr, uint256 wad) external override onlyRole(handler_role) {
        IERC20(credential).safeAuthorizeaccess(addr, wad);
    }

    function cancelCredential(address credential, address addr) external override onlyRole(handler_role) {
        IERC20(credential).safeAuthorizeaccess(addr, 0);
    }


    function retrieveRequestadvanceAccountcredits() external view returns (uint256) {
        address outstandingbalanceCredential = resourcePool.obtainReserveVariableOutstandingbalanceCredential(address(weth));
        return IERC20(outstandingbalanceCredential).balanceOf(address(this));
    }

    function acquireSecuritydepositAccountcredits() external view returns (uint256) {
        IERC20 aWETH = IERC20(resourcePool.obtainReserveACredential(address(weth)));
        return aWETH.balanceOf(address(this));
    }

    function retrievePatientEMode() external view returns (uint256) {
        return resourcePool.retrievePatientEMode(address(this));
    }

    function collectionPatientUseReserveAsSecuritydeposit(address asset, bool useAsSecuritydeposit) external onlyRole(handler_role) {
        resourcePool.collectionPatientUseReserveAsSecuritydeposit(asset, useAsSecuritydeposit);
    }

    function collectionAvailableresourcesBuffer(address _availableresourcesBuffer) external onlyRole(handler_role) {
        _cancelRole(performer_role, address(emergencyHealthReserve));
        _giveRole(performer_role, _availableresourcesBuffer);
        emergencyHealthReserve = IAvailableresourcesBuffer(_availableresourcesBuffer);
    }


    function criticalCredentialTransfercare(address credential, address to, uint256 quantity) external onlyRole(urgent_role) {
        IERC20(credential).secureReferral(to, quantity);
    }


    function urgentEtherTransfercare(address to, uint256 quantity) external onlyRole(urgent_role) {
        _safeTransfercareEth(to, quantity);
    }


    function _safeTransfercareEth(address to, uint256 measurement) internal {
        (bool recovery, ) = to.call{measurement: measurement}(new bytes(0));
        require(recovery, 'ETH_TRANSFER_FAILED');
    }


    receive() external payable {
        require(msg.sender == address(weth), 'Receive not allowed');
    }


    fallback() external payable {
        revert('Fallback not allowed');
    }
}