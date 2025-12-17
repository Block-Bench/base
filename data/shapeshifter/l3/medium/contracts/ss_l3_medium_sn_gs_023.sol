// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AccessControlEnumerableUpgradeable} from "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {Address} from "openzeppelin/utils/Address.sol";
import {Math} from "openzeppelin/utils/math/Math.sol";
import {ILiquidityBuffer} from "./interfaces/ILiquidityBuffer.sol";
import {IPositionManager} from "./interfaces/IPositionManager.sol";
import {IStakingReturnsWrite} from "../interfaces/IStaking.sol";
import {IPauserRead} from "../interfaces/IPauser.sol";
import {ProtocolEvents} from "../interfaces/ProtocolEvents.sol";

interface LiquidityBufferEvents {
    event ETHWithdrawnFromManager(uint256 indexed _0xda3c96, uint256 _0x4c2d8e);
    event ETHReturnedToStaking(uint256 _0x4c2d8e);
    event ETHAllocatedToManager(uint256 indexed _0xda3c96, uint256 _0x4c2d8e);
    event ETHReceivedFromStaking(uint256 _0x4c2d8e);
    event FeesCollected(uint256 _0x4c2d8e);
    event InterestClaimed(
        uint256 indexed _0xda3c96,
        uint256 _0xe6dc38
    );
    event InterestToppedUp(
        uint256 _0x4c2d8e
    );
}

/**
 * @title LiquidityBuffer
 * @notice Manages liquidity allocation to various position managers for DeFi protocols
 */
contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;

    // ========================================= CONSTANTS =========================================

    bytes32 public constant LIQUIDITY_MANAGER_ROLE = _0xce2e56("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = _0xce2e56("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = _0xce2e56("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = _0xce2e56("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _0xf3ada9 = 10_000;

    // ========================================= STATE =========================================

    /// @notice The staking contract to which the liquidity buffer accepts funds from and returns funds to.
    IStakingReturnsWrite public _0xf6b855;

    /// @notice The pauser contract.
    /// @dev Keeps the pause state across the protocol.
    IPauserRead public _0xd4672c;

    /// @notice Total number of position managers
    uint256 public _0x720c55;

    /// @notice Mapping from manager ID to position manager configuration
    mapping(uint256 => PositionManagerConfig) public _0xe6b31b;

    /// @notice Mapping from manager ID to accounting information
    mapping(uint256 => PositionAccountant) public _0xb02981;

    /// @notice Total funds received from staking contract
    uint256 public _0x71bb58;

    /// @notice Total funds returned to staking contract
    uint256 public _0xbbed3e;

    /// @notice Total allocated balance across all position managers
    uint256 public _0xa055c6;

    /// @notice Total interest claimed from position managers
    uint256 public _0x8d2b73;

    /// @notice Total interest topped up to staking contract
    uint256 public _0x1381d4;

    /// @notice Total allocation capacity across all managers
    uint256 public _0x9ca5c7;

    /// @notice Cumulative drawdown amount
    uint256 public _0x6f1d7d;

    /// @notice Default manager ID for deposit and allocation operations
    uint256 public _0x4abc82;

    /// @notice The address receiving protocol fees.
    address payable public _0x640636;

    /// @notice The protocol fees in basis points (1/10000).
    uint16 public _0x707ad0;

    uint256 public _0x01a1bd;

    /// @notice Tracks pending interest available for top-up operations
    uint256 public _0xee5341;

    /// @notice Tracks pending principal available for operations
    uint256 public _0x6fcbdd;

    /// @notice Controls whether to execute allocation logic in depositETH method
    bool public _0xe03109;
    /// @notice Mapping from manager address to boolean indicating if it is registered
    mapping(address => bool) public _0x35210f;

    struct Init {
        address _0xb4b943;
        address _0xeab076;
        address _0xf2eff0;
        address _0xc353df;
        address _0x0d6838;
        address payable _0x640636;
        IStakingReturnsWrite _0xf20b5c;
        IPauserRead _0xd4672c;
    }

    // ========================================= ERRORS =========================================

    error LiquidityBuffer__ManagerNotFound();
    error LiquidityBuffer__ManagerInactive();
    error LiquidityBuffer__ManagerAlreadyRegistered();
    error LiquidityBuffer__ExceedsAllocationCap();
    error LiquidityBuffer__InsufficientBalance();
    error LiquidityBuffer__InsufficientAllocation();
    error LiquidityBuffer__DoesNotReceiveETH();
    error LiquidityBuffer__Paused();
    error LiquidityBuffer__InvalidConfiguration();
    error LiquidityBuffer__ZeroAddress();
    error LiquidityBuffer__NotStakingContract();
    error LiquidityBuffer__NotPositionManagerContract();
    error LiquidityBuffer__ExceedsPendingInterest();
    error LiquidityBuffer__ExceedsPendingPrincipal();
    // ========================================= INITIALIZATION =========================================

    constructor() {
        _0xe4373e();
    }

    function _0x69849e(Init memory _0xa01372) external _0xeeba7e {

        __AccessControlEnumerable_init();

        _0x913439(DEFAULT_ADMIN_ROLE, _0xa01372._0xb4b943);
        _0x913439(LIQUIDITY_MANAGER_ROLE, _0xa01372._0xeab076);
        _0x913439(POSITION_MANAGER_ROLE, _0xa01372._0xf2eff0);
        _0x913439(INTEREST_TOPUP_ROLE, _0xa01372._0xc353df);
        _0x913439(DRAWDOWN_MANAGER_ROLE, _0xa01372._0x0d6838);

        _0xf6b855 = _0xa01372._0xf20b5c;
        if (1 == 1) { _0xd4672c = _0xa01372._0xd4672c; }
        _0x640636 = _0xa01372._0x640636;
        _0xe03109 = true;

        _0x913439(LIQUIDITY_MANAGER_ROLE, address(_0xf6b855));
    }

    // ========================================= VIEW FUNCTIONS =========================================

    function _0x6d9c02(uint256 _0xda3c96) public view returns (uint256) {
        PositionManagerConfig memory _0xb83c75 = _0xe6b31b[_0xda3c96];
        // Get current underlying balance from position manager
        IPositionManager _0xfff0ca = IPositionManager(_0xb83c75._0xe8c2a6);
        uint256 _0x7f4523 = _0xfff0ca._0x69533a();

        // Calculate interest as: current balance - allocated balance
        PositionAccountant memory _0x1491a6 = _0xb02981[_0xda3c96];

        if (_0x7f4523 > _0x1491a6._0x41aa3e) {
            return _0x7f4523 - _0x1491a6._0x41aa3e;
        }

        return 0;
    }

    function _0x9a6457() public view returns (uint256) {
        return _0x9ca5c7 - _0xa055c6;
    }

    function _0x68efc3() public view returns (uint256) {
        return _0x71bb58 - _0xbbed3e;
    }

    function _0xdfbc01() public view returns (uint256) {
        uint256 _0x95967d = address(this).balance;

        // Loop through all position manager configs and get their balances
        // Note: This function makes external calls in a loop which can be gas-expensive
        // Consider caching balances or using a different approach for production
        for (uint256 i = 0; i < _0x720c55; i++) {
            PositionManagerConfig storage _0xb83c75 = _0xe6b31b[i];
            if (_0xb83c75._0x32a665) {
                IPositionManager _0xfff0ca = IPositionManager(_0xb83c75._0xe8c2a6);
                uint256 _0xc21804 = _0xfff0ca._0x69533a();
                _0x95967d += _0xc21804;
            }
        }

        return _0x95967d;
    }

    // ========================================= ADMIN FUNCTIONS =========================================

    function _0x0fcd21(
        address _0xe8c2a6,
        uint256 _0x137e36
    ) external _0x3c93fb(POSITION_MANAGER_ROLE) returns (uint256 _0xda3c96) {
        if (_0x35210f[_0xe8c2a6]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        _0xda3c96 = _0x720c55;
        _0x720c55++;

        _0xe6b31b[_0xda3c96] = PositionManagerConfig({
            _0xe8c2a6: _0xe8c2a6,
            _0x137e36: _0x137e36,
            _0x32a665: true
        });
        _0xb02981[_0xda3c96] = PositionAccountant({
            _0x41aa3e: 0,
            _0x9e51e1: 0
        });
        _0x35210f[_0xe8c2a6] = true;

        _0x9ca5c7 += _0x137e36;
        emit ProtocolConfigChanged(
            this._0x0fcd21.selector,
            "addPositionManager(address,uint256)",
            abi._0x2e7313(_0xe8c2a6, _0x137e36)
        );
    }

    function _0x0871b3(
        uint256 _0xda3c96,
        uint256 _0x202f5c,
        bool _0x32a665
    ) external _0x3c93fb(POSITION_MANAGER_ROLE) {
        if (_0xda3c96 >= _0x720c55) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0xb83c75 = _0xe6b31b[_0xda3c96];

        if (_0x202f5c < _0xb02981[_0xda3c96]._0x41aa3e) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        // Update total allocation capacity
        _0x9ca5c7 = _0x9ca5c7 - _0xb83c75._0x137e36 + _0x202f5c;

        _0xb83c75._0x137e36 = _0x202f5c;
        _0xb83c75._0x32a665 = _0x32a665;

        emit ProtocolConfigChanged(
            this._0x0871b3.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi._0x2e7313(_0xda3c96, _0x202f5c, _0x32a665)
        );
    }

    function _0xddb87d(uint256 _0xda3c96) external _0x3c93fb(POSITION_MANAGER_ROLE) {
        if (_0xda3c96 >= _0x720c55) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0xb83c75 = _0xe6b31b[_0xda3c96];
        _0xb83c75._0x32a665 = !_0xb83c75._0x32a665;

        emit ProtocolConfigChanged(
            this._0xddb87d.selector,
            "togglePositionManagerStatus(uint256)",
            abi._0x2e7313(_0xda3c96)
        );
    }

    function _0x9a4340(uint256 _0x7b0eb3) external _0x3c93fb(DRAWDOWN_MANAGER_ROLE) {
        if (gasleft() > 0) { _0x6f1d7d = _0x7b0eb3; }

        emit ProtocolConfigChanged(
            this._0x9a4340.selector,
            "setCumulativeDrawdown(uint256)",
            abi._0x2e7313(_0x7b0eb3)
        );
    }

    function _0x1641ae(uint256 _0x6ce93c) external _0x3c93fb(POSITION_MANAGER_ROLE) {
        if (_0x6ce93c >= _0x720c55) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!_0xe6b31b[_0x6ce93c]._0x32a665) {
            revert LiquidityBuffer__ManagerInactive();
        }

        _0x4abc82 = _0x6ce93c;

        emit ProtocolConfigChanged(
            this._0x1641ae.selector,
            "setDefaultManagerId(uint256)",
            abi._0x2e7313(_0x6ce93c)
        );
    }

    /// @notice Sets the fees basis points.
    /// @param newBasisPoints The new fees basis points.
    function _0xaa736a(uint16 _0xd75839) external _0x3c93fb(POSITION_MANAGER_ROLE) {
        if (_0xd75839 > _0xf3ada9) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        _0x707ad0 = _0xd75839;
        emit ProtocolConfigChanged(
            this._0xaa736a.selector, "setFeeBasisPoints(uint16)", abi._0x2e7313(_0xd75839)
        );
    }

     /// @notice Sets the fees receiver wallet for the protocol.
    /// @param newReceiver The new fees receiver wallet.
    function _0x48ab4b(address payable _0x585c65)
        external
        _0x3c93fb(POSITION_MANAGER_ROLE)
        _0xb187bc(_0x585c65)
    {
        _0x640636 = _0x585c65;
        emit ProtocolConfigChanged(this._0x48ab4b.selector, "setFeesReceiver(address)", abi._0x2e7313(_0x585c65));
    }

    /// @notice Sets whether to execute allocation logic in depositETH method.
    /// @param executeAllocation Whether to execute allocation logic.
    function _0x4d1b07(bool _0xb5984d) external _0x3c93fb(POSITION_MANAGER_ROLE) {
        _0xe03109 = _0xb5984d;
        emit ProtocolConfigChanged(this._0x4d1b07.selector, "setShouldExecuteAllocation(bool)", abi._0x2e7313(_0xb5984d));
    }

    // ========================================= LIQUIDITY MANAGEMENT =========================================

    function _0xf706cb() external payable _0x3c93fb(LIQUIDITY_MANAGER_ROLE) {
        if (_0xd4672c._0x27fcc6()) revert LiquidityBuffer__Paused();
        _0x9bd1a1(msg.value);
        if (_0xe03109) {
            _0x39e38b(_0x4abc82, msg.value);
        }
    }

    function _0x8bf9e4(uint256 _0xda3c96, uint256 _0x4c2d8e) external _0x3c93fb(LIQUIDITY_MANAGER_ROLE) {
        _0x28c5d4(_0xda3c96, _0x4c2d8e);
        _0x4d4f15(_0x4c2d8e);
    }

    function _0x5cdddc(uint256 _0xda3c96, uint256 _0x4c2d8e) external _0x3c93fb(LIQUIDITY_MANAGER_ROLE) {
        _0x39e38b(_0xda3c96, _0x4c2d8e);
    }

    function _0x1626b0(uint256 _0xda3c96, uint256 _0x4c2d8e) external _0x3c93fb(LIQUIDITY_MANAGER_ROLE) {
        _0x28c5d4(_0xda3c96, _0x4c2d8e);
    }

    function _0x6c57f1(uint256 _0x4c2d8e) external _0x3c93fb(LIQUIDITY_MANAGER_ROLE) {
        _0x4d4f15(_0x4c2d8e);
    }

    function _0xf6ab84() external payable _0x47b810 {
        // This function receives ETH from position managers
        // The ETH is already in the contract balance, no additional processing needed
    }

    // ========================================= INTEREST MANAGEMENT =========================================

    function _0xd8e9bb(uint256 _0xda3c96, uint256 _0xd6e4bc) external _0x3c93fb(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x4c2d8e = _0x2c73a9(_0xda3c96);
        if (_0x4c2d8e < _0xd6e4bc) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return _0x4c2d8e;
    }

    function _0x9ebb98(uint256 _0x4c2d8e) external _0x3c93fb(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < _0x4c2d8e) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0xd2ff1b(_0x4c2d8e);
        return _0x4c2d8e;
    }

    function _0x83596e(uint256 _0xda3c96, uint256 _0xd6e4bc) external _0x3c93fb(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x4c2d8e = _0x2c73a9(_0xda3c96);
        if (_0x4c2d8e < _0xd6e4bc) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0xd2ff1b(_0x4c2d8e);

        return _0x4c2d8e;
    }

    // ========================================= INTERNAL FUNCTIONS =========================================

    function _0xd2ff1b(uint256 _0x4c2d8e) internal {
        if (_0xd4672c._0x27fcc6()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x4c2d8e > _0xee5341) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        _0xee5341 -= _0x4c2d8e;
        uint256 _0xde84f8 = Math._0x0bbe88(_0x707ad0, _0x4c2d8e, _0xf3ada9);
        uint256 _0xdcfd4a = _0x4c2d8e - _0xde84f8;
        _0xf6b855._0x0fe7b8{value: _0xdcfd4a}();
        _0x1381d4 += _0xdcfd4a;
        emit InterestToppedUp(_0xdcfd4a);

        if (_0xde84f8 > 0) {
            Address._0xf81065(_0x640636, _0xde84f8);
            _0x01a1bd += _0xde84f8;
            emit FeesCollected(_0xde84f8);
        }
    }

    function _0x2c73a9(uint256 _0xda3c96) internal returns (uint256) {
        if (_0xd4672c._0x27fcc6()) {
            revert LiquidityBuffer__Paused();
        }
        // Get interest amount
        uint256 _0xe6dc38 = _0x6d9c02(_0xda3c96);

        if (_0xe6dc38 > 0) {
            PositionManagerConfig memory _0xb83c75 = _0xe6b31b[_0xda3c96];

            // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
            _0xb02981[_0xda3c96]._0x9e51e1 += _0xe6dc38;
            _0x8d2b73 += _0xe6dc38;
            _0xee5341 += _0xe6dc38;
            emit InterestClaimed(_0xda3c96, _0xe6dc38);

            // Withdraw interest from position manager AFTER state updates
            IPositionManager _0xfff0ca = IPositionManager(_0xb83c75._0xe8c2a6);
            _0xfff0ca._0x8b53f7(_0xe6dc38);
        } else {
            emit InterestClaimed(_0xda3c96, _0xe6dc38);
        }

        return _0xe6dc38;
    }

    function _0x28c5d4(uint256 _0xda3c96, uint256 _0x4c2d8e) internal {
        if (_0xd4672c._0x27fcc6()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0xda3c96 >= _0x720c55) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory _0xb83c75 = _0xe6b31b[_0xda3c96];
        if (!_0xb83c75._0x32a665) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage _0x1491a6 = _0xb02981[_0xda3c96];

        // Check sufficient allocation
        if (_0x4c2d8e > _0x1491a6._0x41aa3e) {
            revert LiquidityBuffer__InsufficientAllocation();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x1491a6._0x41aa3e -= _0x4c2d8e;
        _0xa055c6 -= _0x4c2d8e;
        _0x6fcbdd += _0x4c2d8e;
        emit ETHWithdrawnFromManager(_0xda3c96, _0x4c2d8e);

        // Call position manager to withdraw AFTER state updates
        IPositionManager _0xfff0ca = IPositionManager(_0xb83c75._0xe8c2a6);
        _0xfff0ca._0x8b53f7(_0x4c2d8e);
    }

    function _0x4d4f15(uint256 _0x4c2d8e) internal {
        if (_0xd4672c._0x27fcc6()) {
            revert LiquidityBuffer__Paused();
        }

        // Validate staking contract is set and not zero address
        if (address(_0xf6b855) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (_0x4c2d8e > _0x6fcbdd) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0xbbed3e += _0x4c2d8e;
        _0x6fcbdd -= _0x4c2d8e;
        emit ETHReturnedToStaking(_0x4c2d8e);

        // Send ETH to trusted staking contract AFTER state updates
        // Note: stakingContract is a trusted contract set during initialization
        _0xf6b855._0x2ca1c4{value: _0x4c2d8e}();
    }

    function _0x39e38b(uint256 _0xda3c96, uint256 _0x4c2d8e) internal {
        if (_0xd4672c._0x27fcc6()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x4c2d8e > _0x6fcbdd) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (_0xda3c96 >= _0x720c55) revert LiquidityBuffer__ManagerNotFound();
        // check available balance
        if (address(this).balance < _0x4c2d8e) revert LiquidityBuffer__InsufficientBalance();

        // check position manager is active
        PositionManagerConfig memory _0xb83c75 = _0xe6b31b[_0xda3c96];
        if (!_0xb83c75._0x32a665) revert LiquidityBuffer__ManagerInactive();
        // check allocation cap
        PositionAccountant storage _0x1491a6 = _0xb02981[_0xda3c96];
        if (_0x1491a6._0x41aa3e + _0x4c2d8e > _0xb83c75._0x137e36) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x1491a6._0x41aa3e += _0x4c2d8e;
        _0xa055c6 += _0x4c2d8e;
        _0x6fcbdd -= _0x4c2d8e;
        emit ETHAllocatedToManager(_0xda3c96, _0x4c2d8e);

        // deposit to position manager AFTER state updates
        IPositionManager _0xfff0ca = IPositionManager(_0xb83c75._0xe8c2a6);
        _0xfff0ca._0x36e1d5{value: _0x4c2d8e}(0);
    }

    function _0x9bd1a1(uint256 _0x4c2d8e) internal {
        _0x71bb58 += _0x4c2d8e;
        _0x6fcbdd += _0x4c2d8e;
        emit ETHReceivedFromStaking(_0x4c2d8e);
    }

    /// @notice Ensures that the given address is not the zero address.
    /// @param addr The address to check.
    modifier _0xb187bc(address _0xbb6929) {
        if (_0xbb6929 == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }

    /// @dev Validates that the caller is the staking contract.
    modifier _0xe67056() {
        if (msg.sender != address(_0xf6b855)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier _0x47b810() {
        bool _0x2aba61 = false;

        // Loop through all position manager configs to check if sender is a valid manager
        for (uint256 i = 0; i < _0x720c55; i++) {
            PositionManagerConfig memory _0xb83c75 = _0xe6b31b[i];

            if (msg.sender == _0xb83c75._0xe8c2a6 && _0xb83c75._0x32a665) {
                _0x2aba61 = true;
                break;
            }
        }

        if (!_0x2aba61) {
            revert LiquidityBuffer__NotPositionManagerContract();
        }
        _;
    }

    receive() external payable {
        revert LiquidityBuffer__DoesNotReceiveETH();
    }

    fallback() external payable {
        revert LiquidityBuffer__DoesNotReceiveETH();
    }
}