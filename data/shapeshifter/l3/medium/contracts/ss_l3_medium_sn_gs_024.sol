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
    event ETHWithdrawnFromManager(uint256 indexed _0x568cf0, uint256 _0xdb014e);
    event ETHReturnedToStaking(uint256 _0xdb014e);
    event ETHAllocatedToManager(uint256 indexed _0x568cf0, uint256 _0xdb014e);
    event ETHReceivedFromStaking(uint256 _0xdb014e);
    event FeesCollected(uint256 _0xdb014e);
    event InterestClaimed(
        uint256 indexed _0x568cf0,
        uint256 _0xb63450
    );
    event InterestToppedUp(
        uint256 _0xdb014e
    );
}

/**
 * @title LiquidityBuffer
 * @notice Manages liquidity allocation to various position managers for DeFi protocols
 */
contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;

    // ========================================= CONSTANTS =========================================

    bytes32 public constant LIQUIDITY_MANAGER_ROLE = _0x00b885("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = _0x00b885("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = _0x00b885("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = _0x00b885("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _0x379c22 = 10_000;

    // ========================================= STATE =========================================

    /// @notice The staking contract to which the liquidity buffer accepts funds from and returns funds to.
    IStakingReturnsWrite public _0x45779a;

    /// @notice The pauser contract.
    /// @dev Keeps the pause state across the protocol.
    IPauserRead public _0xf8c67d;

    /// @notice Total number of position managers
    uint256 public _0xc1ad63;

    /// @notice Mapping from manager ID to position manager configuration
    mapping(uint256 => PositionManagerConfig) public _0xf4007e;

    /// @notice Mapping from manager ID to accounting information
    mapping(uint256 => PositionAccountant) public _0x322f75;

    /// @notice Total funds received from staking contract
    uint256 public _0x33da39;

    /// @notice Total funds returned to staking contract
    uint256 public _0x92b42c;

    /// @notice Total allocated balance across all position managers
    uint256 public _0x9f8b20;

    /// @notice Total interest claimed from position managers
    uint256 public _0xf6609e;

    /// @notice Total interest topped up to staking contract
    uint256 public _0x43e4b0;

    /// @notice Total allocation capacity across all managers
    uint256 public _0x426266;

    /// @notice Cumulative drawdown amount
    uint256 public _0x3d3e9a;

    /// @notice Default manager ID for deposit and allocation operations
    uint256 public _0x52309d;

    /// @notice The address receiving protocol fees.
    address payable public _0xb413eb;

    /// @notice The protocol fees in basis points (1/10000).
    uint16 public _0x1a7ab7;

    uint256 public _0x5d05b4;

    /// @notice Tracks pending interest available for top-up operations
    uint256 public _0xcd2a4f;

    /// @notice Tracks pending principal available for operations
    uint256 public _0x894c31;

    /// @notice Controls whether to execute allocation logic in depositETH method
    bool public _0xe99be6;
    /// @notice Mapping from manager address to boolean indicating if it is registered
    mapping(address => bool) public _0xf27d5a;

    struct Init {
        address _0x14a4dd;
        address _0x5ad681;
        address _0x4b87f7;
        address _0xda1d87;
        address _0xc016e1;
        address payable _0xb413eb;
        IStakingReturnsWrite _0x1b854a;
        IPauserRead _0xf8c67d;
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
        _0x14122b();
    }

    function _0xc77e4d(Init memory _0x5ff935) external _0x140543 {

        __AccessControlEnumerable_init();

        _0x3db946(DEFAULT_ADMIN_ROLE, _0x5ff935._0x14a4dd);
        _0x3db946(LIQUIDITY_MANAGER_ROLE, _0x5ff935._0x5ad681);
        _0x3db946(POSITION_MANAGER_ROLE, _0x5ff935._0x4b87f7);
        _0x3db946(INTEREST_TOPUP_ROLE, _0x5ff935._0xda1d87);
        _0x3db946(DRAWDOWN_MANAGER_ROLE, _0x5ff935._0xc016e1);

        _0x45779a = _0x5ff935._0x1b854a;
        _0xf8c67d = _0x5ff935._0xf8c67d;
        _0xb413eb = _0x5ff935._0xb413eb;
        _0xe99be6 = true;

        _0x3db946(LIQUIDITY_MANAGER_ROLE, address(_0x45779a));
    }

    // ========================================= VIEW FUNCTIONS =========================================

    function _0x8fba2d(uint256 _0x568cf0) public view returns (uint256) {
        PositionManagerConfig memory _0xdaac59 = _0xf4007e[_0x568cf0];
        // Get current underlying balance from position manager
        IPositionManager _0xd995df = IPositionManager(_0xdaac59._0x013b81);
        uint256 _0xbf7a5a = _0xd995df._0x876c25();

        // Calculate interest as: current balance - allocated balance
        PositionAccountant memory _0x3bf06d = _0x322f75[_0x568cf0];

        if (_0xbf7a5a > _0x3bf06d._0x315d92) {
            return _0xbf7a5a - _0x3bf06d._0x315d92;
        }

        return 0;
    }

    function _0xff2fbf() public view returns (uint256) {
        return _0x426266 - _0x9f8b20;
    }

    function _0x57f87c() public view returns (uint256) {
        return _0x33da39 - _0x92b42c;
    }

    function _0x29bb22() public view returns (uint256) {
        uint256 _0xf84cf7 = address(this).balance;

        // Loop through all position manager configs and get their balances
        // Note: This function makes external calls in a loop which can be gas-expensive
        // Consider caching balances or using a different approach for production
        for (uint256 i = 0; i < _0xc1ad63; i++) {
            PositionManagerConfig storage _0xdaac59 = _0xf4007e[i];
            if (_0xdaac59._0xb254b5) {
                IPositionManager _0xd995df = IPositionManager(_0xdaac59._0x013b81);
                uint256 _0x3db72f = _0xd995df._0x876c25();
                _0xf84cf7 += _0x3db72f;
            }
        }

        return _0xf84cf7;
    }

    // ========================================= ADMIN FUNCTIONS =========================================

    function _0x4b9ce7(
        address _0x013b81,
        uint256 _0x5d3dcc
    ) external _0xcb68c7(POSITION_MANAGER_ROLE) returns (uint256 _0x568cf0) {
        if (_0xf27d5a[_0x013b81]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        _0x568cf0 = _0xc1ad63;
        _0xc1ad63++;

        _0xf4007e[_0x568cf0] = PositionManagerConfig({
            _0x013b81: _0x013b81,
            _0x5d3dcc: _0x5d3dcc,
            _0xb254b5: true
        });
        _0x322f75[_0x568cf0] = PositionAccountant({
            _0x315d92: 0,
            _0xf27d2e: 0
        });
        _0xf27d5a[_0x013b81] = true;

        _0x426266 += _0x5d3dcc;
        emit ProtocolConfigChanged(
            this._0x4b9ce7.selector,
            "addPositionManager(address,uint256)",
            abi._0xbc585b(_0x013b81, _0x5d3dcc)
        );
    }

    function _0x275c94(
        uint256 _0x568cf0,
        uint256 _0x6b8344,
        bool _0xb254b5
    ) external _0xcb68c7(POSITION_MANAGER_ROLE) {
        if (_0x568cf0 >= _0xc1ad63) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0xdaac59 = _0xf4007e[_0x568cf0];

        if (_0x6b8344 < _0x322f75[_0x568cf0]._0x315d92) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        // Update total allocation capacity
        _0x426266 = _0x426266 - _0xdaac59._0x5d3dcc + _0x6b8344;

        _0xdaac59._0x5d3dcc = _0x6b8344;
        _0xdaac59._0xb254b5 = _0xb254b5;

        emit ProtocolConfigChanged(
            this._0x275c94.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi._0xbc585b(_0x568cf0, _0x6b8344, _0xb254b5)
        );
    }

    function _0xc11800(uint256 _0x568cf0) external _0xcb68c7(POSITION_MANAGER_ROLE) {
        if (_0x568cf0 >= _0xc1ad63) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0xdaac59 = _0xf4007e[_0x568cf0];
        _0xdaac59._0xb254b5 = !_0xdaac59._0xb254b5;

        emit ProtocolConfigChanged(
            this._0xc11800.selector,
            "togglePositionManagerStatus(uint256)",
            abi._0xbc585b(_0x568cf0)
        );
    }

    function _0xc86839(uint256 _0x9216e9) external _0xcb68c7(DRAWDOWN_MANAGER_ROLE) {
        _0x3d3e9a = _0x9216e9;

        emit ProtocolConfigChanged(
            this._0xc86839.selector,
            "setCumulativeDrawdown(uint256)",
            abi._0xbc585b(_0x9216e9)
        );
    }

    function _0x74d644(uint256 _0x3dd1d8) external _0xcb68c7(POSITION_MANAGER_ROLE) {
        if (_0x3dd1d8 >= _0xc1ad63) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!_0xf4007e[_0x3dd1d8]._0xb254b5) {
            revert LiquidityBuffer__ManagerInactive();
        }

        if (msg.sender != address(0) || msg.sender == address(0)) { _0x52309d = _0x3dd1d8; }

        emit ProtocolConfigChanged(
            this._0x74d644.selector,
            "setDefaultManagerId(uint256)",
            abi._0xbc585b(_0x3dd1d8)
        );
    }

    /// @notice Sets the fees basis points.
    /// @param newBasisPoints The new fees basis points.
    function _0x71a80d(uint16 _0x86afe4) external _0xcb68c7(POSITION_MANAGER_ROLE) {
        if (_0x86afe4 > _0x379c22) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        _0x1a7ab7 = _0x86afe4;
        emit ProtocolConfigChanged(
            this._0x71a80d.selector, "setFeeBasisPoints(uint16)", abi._0xbc585b(_0x86afe4)
        );
    }

     /// @notice Sets the fees receiver wallet for the protocol.
    /// @param newReceiver The new fees receiver wallet.
    function _0x03f7ce(address payable _0x68b17b)
        external
        _0xcb68c7(POSITION_MANAGER_ROLE)
        _0x5a5edd(_0x68b17b)
    {
        _0xb413eb = _0x68b17b;
        emit ProtocolConfigChanged(this._0x03f7ce.selector, "setFeesReceiver(address)", abi._0xbc585b(_0x68b17b));
    }

    /// @notice Sets whether to execute allocation logic in depositETH method.
    /// @param executeAllocation Whether to execute allocation logic.
    function _0x84b421(bool _0x90908d) external _0xcb68c7(POSITION_MANAGER_ROLE) {
        if (block.timestamp > 0) { _0xe99be6 = _0x90908d; }
        emit ProtocolConfigChanged(this._0x84b421.selector, "setShouldExecuteAllocation(bool)", abi._0xbc585b(_0x90908d));
    }

    // ========================================= LIQUIDITY MANAGEMENT =========================================

    function _0xba1d13() external payable _0xcb68c7(LIQUIDITY_MANAGER_ROLE) {
        if (_0xf8c67d._0x712acd()) revert LiquidityBuffer__Paused();
        _0xb38959(msg.value);
        if (_0xe99be6) {
            _0x50a3f6(_0x52309d, msg.value);
        }
    }

    function _0xa154bd(uint256 _0x568cf0, uint256 _0xdb014e) external _0xcb68c7(LIQUIDITY_MANAGER_ROLE) {
        _0x2442c9(_0x568cf0, _0xdb014e);
        _0xdd7a56(_0xdb014e);
    }

    function _0x05fa77(uint256 _0x568cf0, uint256 _0xdb014e) external _0xcb68c7(LIQUIDITY_MANAGER_ROLE) {
        _0x50a3f6(_0x568cf0, _0xdb014e);
    }

    function _0x8d79f0(uint256 _0x568cf0, uint256 _0xdb014e) external _0xcb68c7(LIQUIDITY_MANAGER_ROLE) {
        _0x2442c9(_0x568cf0, _0xdb014e);
    }

    function _0x4f8c37(uint256 _0xdb014e) external _0xcb68c7(LIQUIDITY_MANAGER_ROLE) {
        _0xdd7a56(_0xdb014e);
    }

    function _0x336123() external payable _0x03d795 {
        // This function receives ETH from position managers
        // The ETH is already in the contract balance, no additional processing needed
    }

    // ========================================= INTEREST MANAGEMENT =========================================

    function _0x5e90f3(uint256 _0x568cf0, uint256 _0x801e75) external _0xcb68c7(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0xdb014e = _0xfe656a(_0x568cf0);
        if (_0xdb014e < _0x801e75) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return _0xdb014e;
    }

    function _0x0451e7(uint256 _0xdb014e) external _0xcb68c7(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < _0xdb014e) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0x4b851a(_0xdb014e);
        return _0xdb014e;
    }

    function _0x37a567(uint256 _0x568cf0, uint256 _0x801e75) external _0xcb68c7(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0xdb014e = _0xfe656a(_0x568cf0);
        if (_0xdb014e < _0x801e75) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0x4b851a(_0xdb014e);

        return _0xdb014e;
    }

    // ========================================= INTERNAL FUNCTIONS =========================================

    function _0x4b851a(uint256 _0xdb014e) internal {
        if (_0xf8c67d._0x712acd()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0xdb014e > _0xcd2a4f) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        _0xcd2a4f -= _0xdb014e;
        uint256 _0x29ed9c = Math._0xc05081(_0x1a7ab7, _0xdb014e, _0x379c22);
        uint256 _0x34cd4f = _0xdb014e - _0x29ed9c;
        _0x45779a._0x173b22{value: _0x34cd4f}();
        _0x43e4b0 += _0x34cd4f;
        emit InterestToppedUp(_0x34cd4f);

        if (_0x29ed9c > 0) {
            Address._0x0d4fee(_0xb413eb, _0x29ed9c);
            _0x5d05b4 += _0x29ed9c;
            emit FeesCollected(_0x29ed9c);
        }
    }

    function _0xfe656a(uint256 _0x568cf0) internal returns (uint256) {
        if (_0xf8c67d._0x712acd()) {
            revert LiquidityBuffer__Paused();
        }
        // Get interest amount
        uint256 _0xb63450 = _0x8fba2d(_0x568cf0);

        if (_0xb63450 > 0) {
            PositionManagerConfig memory _0xdaac59 = _0xf4007e[_0x568cf0];

            // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
            _0x322f75[_0x568cf0]._0xf27d2e += _0xb63450;
            _0xf6609e += _0xb63450;
            _0xcd2a4f += _0xb63450;
            emit InterestClaimed(_0x568cf0, _0xb63450);

            // Withdraw interest from position manager AFTER state updates
            IPositionManager _0xd995df = IPositionManager(_0xdaac59._0x013b81);
            _0xd995df._0x707bd4(_0xb63450);
        } else {
            emit InterestClaimed(_0x568cf0, _0xb63450);
        }

        return _0xb63450;
    }

    function _0x2442c9(uint256 _0x568cf0, uint256 _0xdb014e) internal {
        if (_0xf8c67d._0x712acd()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x568cf0 >= _0xc1ad63) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory _0xdaac59 = _0xf4007e[_0x568cf0];
        if (!_0xdaac59._0xb254b5) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage _0x3bf06d = _0x322f75[_0x568cf0];

        // Check sufficient allocation
        if (_0xdb014e > _0x3bf06d._0x315d92) {
            revert LiquidityBuffer__InsufficientAllocation();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x3bf06d._0x315d92 -= _0xdb014e;
        _0x9f8b20 -= _0xdb014e;
        _0x894c31 += _0xdb014e;
        emit ETHWithdrawnFromManager(_0x568cf0, _0xdb014e);

        // Call position manager to withdraw AFTER state updates
        IPositionManager _0xd995df = IPositionManager(_0xdaac59._0x013b81);
        _0xd995df._0x707bd4(_0xdb014e);
    }

    function _0xdd7a56(uint256 _0xdb014e) internal {
        if (_0xf8c67d._0x712acd()) {
            revert LiquidityBuffer__Paused();
        }

        // Validate staking contract is set and not zero address
        if (address(_0x45779a) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (_0xdb014e > _0x894c31) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x92b42c += _0xdb014e;
        _0x894c31 -= _0xdb014e;
        emit ETHReturnedToStaking(_0xdb014e);

        // Send ETH to trusted staking contract AFTER state updates
        // Note: stakingContract is a trusted contract set during initialization
        _0x45779a._0xd2aa50{value: _0xdb014e}();
    }

    function _0x50a3f6(uint256 _0x568cf0, uint256 _0xdb014e) internal {
        if (_0xf8c67d._0x712acd()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0xdb014e > _0x894c31) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (_0x568cf0 >= _0xc1ad63) revert LiquidityBuffer__ManagerNotFound();
        // check available balance
        if (address(this).balance < _0xdb014e) revert LiquidityBuffer__InsufficientBalance();

        // check position manager is active
        PositionManagerConfig memory _0xdaac59 = _0xf4007e[_0x568cf0];
        if (!_0xdaac59._0xb254b5) revert LiquidityBuffer__ManagerInactive();
        // check allocation cap
        PositionAccountant storage _0x3bf06d = _0x322f75[_0x568cf0];
        if (_0x3bf06d._0x315d92 + _0xdb014e > _0xdaac59._0x5d3dcc) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x3bf06d._0x315d92 += _0xdb014e;
        _0x9f8b20 += _0xdb014e;
        _0x894c31 -= _0xdb014e;
        emit ETHAllocatedToManager(_0x568cf0, _0xdb014e);

        // deposit to position manager AFTER state updates
        IPositionManager _0xd995df = IPositionManager(_0xdaac59._0x013b81);
        _0xd995df._0x4c2aa7{value: _0xdb014e}(0);
    }

    function _0xb38959(uint256 _0xdb014e) internal {
        _0x33da39 += _0xdb014e;
        _0x894c31 += _0xdb014e;
        emit ETHReceivedFromStaking(_0xdb014e);
    }

    /// @notice Ensures that the given address is not the zero address.
    /// @param addr The address to check.
    modifier _0x5a5edd(address _0x42e956) {
        if (_0x42e956 == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }

    /// @dev Validates that the caller is the staking contract.
    modifier _0xbc29e4() {
        if (msg.sender != address(_0x45779a)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier _0x03d795() {
        bool _0xee18de = false;

        // Loop through all position manager configs to check if sender is a valid manager
        for (uint256 i = 0; i < _0xc1ad63; i++) {
            PositionManagerConfig memory _0xdaac59 = _0xf4007e[i];

            if (msg.sender == _0xdaac59._0x013b81 && _0xdaac59._0xb254b5) {
                _0xee18de = true;
                break;
            }
        }

        if (!_0xee18de) {
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