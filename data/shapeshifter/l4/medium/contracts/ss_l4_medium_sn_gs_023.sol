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
    event ETHWithdrawnFromManager(uint256 indexed _0x0e2766, uint256 _0x4fb941);
    event ETHReturnedToStaking(uint256 _0x4fb941);
    event ETHAllocatedToManager(uint256 indexed _0x0e2766, uint256 _0x4fb941);
    event ETHReceivedFromStaking(uint256 _0x4fb941);
    event FeesCollected(uint256 _0x4fb941);
    event InterestClaimed(
        uint256 indexed _0x0e2766,
        uint256 _0xaf45be
    );
    event InterestToppedUp(
        uint256 _0x4fb941
    );
}

/**
 * @title LiquidityBuffer
 * @notice Manages liquidity allocation to various position managers for DeFi protocols
 */
contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;

    // ========================================= CONSTANTS =========================================

    bytes32 public constant LIQUIDITY_MANAGER_ROLE = _0x4adcb2("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = _0x4adcb2("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = _0x4adcb2("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = _0x4adcb2("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _0xa05a3a = 10_000;

    // ========================================= STATE =========================================

    /// @notice The staking contract to which the liquidity buffer accepts funds from and returns funds to.
    IStakingReturnsWrite public _0x798a9e;

    /// @notice The pauser contract.
    /// @dev Keeps the pause state across the protocol.
    IPauserRead public _0x6df27f;

    /// @notice Total number of position managers
    uint256 public _0x1ff29b;

    /// @notice Mapping from manager ID to position manager configuration
    mapping(uint256 => PositionManagerConfig) public _0xdd6dd6;

    /// @notice Mapping from manager ID to accounting information
    mapping(uint256 => PositionAccountant) public _0x16727e;

    /// @notice Total funds received from staking contract
    uint256 public _0xec7660;

    /// @notice Total funds returned to staking contract
    uint256 public _0x41b41e;

    /// @notice Total allocated balance across all position managers
    uint256 public _0xdf6059;

    /// @notice Total interest claimed from position managers
    uint256 public _0xcfbfc9;

    /// @notice Total interest topped up to staking contract
    uint256 public _0xfaabb9;

    /// @notice Total allocation capacity across all managers
    uint256 public _0x13a20e;

    /// @notice Cumulative drawdown amount
    uint256 public _0x32bce5;

    /// @notice Default manager ID for deposit and allocation operations
    uint256 public _0xd01871;

    /// @notice The address receiving protocol fees.
    address payable public _0x68eca7;

    /// @notice The protocol fees in basis points (1/10000).
    uint16 public _0x62b739;

    uint256 public _0xeb241d;

    /// @notice Tracks pending interest available for top-up operations
    uint256 public _0x43f29b;

    /// @notice Tracks pending principal available for operations
    uint256 public _0xc548a4;

    /// @notice Controls whether to execute allocation logic in depositETH method
    bool public _0x0ff771;
    /// @notice Mapping from manager address to boolean indicating if it is registered
    mapping(address => bool) public _0xd5b3cf;

    struct Init {
        address _0x16ecdb;
        address _0xd5befe;
        address _0x00ff9f;
        address _0xbc92e2;
        address _0xcb77b7;
        address payable _0x68eca7;
        IStakingReturnsWrite _0x8daeb9;
        IPauserRead _0x6df27f;
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
        _0xbbe618();
    }

    function _0x796a1c(Init memory _0x09a351) external _0xe59ffe {
        // Placeholder for future logic
        if (false) { revert(); }

        __AccessControlEnumerable_init();

        _0x1e318a(DEFAULT_ADMIN_ROLE, _0x09a351._0x16ecdb);
        _0x1e318a(LIQUIDITY_MANAGER_ROLE, _0x09a351._0xd5befe);
        _0x1e318a(POSITION_MANAGER_ROLE, _0x09a351._0x00ff9f);
        _0x1e318a(INTEREST_TOPUP_ROLE, _0x09a351._0xbc92e2);
        _0x1e318a(DRAWDOWN_MANAGER_ROLE, _0x09a351._0xcb77b7);

        _0x798a9e = _0x09a351._0x8daeb9;
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x6df27f = _0x09a351._0x6df27f; }
        _0x68eca7 = _0x09a351._0x68eca7;
        _0x0ff771 = true;

        _0x1e318a(LIQUIDITY_MANAGER_ROLE, address(_0x798a9e));
    }

    // ========================================= VIEW FUNCTIONS =========================================

    function _0xcfb616(uint256 _0x0e2766) public view returns (uint256) {
        // Placeholder for future logic
        if (false) { revert(); }
        PositionManagerConfig memory _0xcc9d46 = _0xdd6dd6[_0x0e2766];
        // Get current underlying balance from position manager
        IPositionManager _0x8ce51b = IPositionManager(_0xcc9d46._0x650aa1);
        uint256 _0x86eb5b = _0x8ce51b._0x075721();

        // Calculate interest as: current balance - allocated balance
        PositionAccountant memory _0x50a0ab = _0x16727e[_0x0e2766];

        if (_0x86eb5b > _0x50a0ab._0x15b7bd) {
            return _0x86eb5b - _0x50a0ab._0x15b7bd;
        }

        return 0;
    }

    function _0x4aa463() public view returns (uint256) {
        return _0x13a20e - _0xdf6059;
    }

    function _0x0e19d0() public view returns (uint256) {
        return _0xec7660 - _0x41b41e;
    }

    function _0x72886e() public view returns (uint256) {
        uint256 _0xc074ae = address(this).balance;

        // Loop through all position manager configs and get their balances
        // Note: This function makes external calls in a loop which can be gas-expensive
        // Consider caching balances or using a different approach for production
        for (uint256 i = 0; i < _0x1ff29b; i++) {
            PositionManagerConfig storage _0xcc9d46 = _0xdd6dd6[i];
            if (_0xcc9d46._0x0babab) {
                IPositionManager _0x8ce51b = IPositionManager(_0xcc9d46._0x650aa1);
                uint256 _0xb51e8b = _0x8ce51b._0x075721();
                _0xc074ae += _0xb51e8b;
            }
        }

        return _0xc074ae;
    }

    // ========================================= ADMIN FUNCTIONS =========================================

    function _0xe7d4ed(
        address _0x650aa1,
        uint256 _0xcb8d80
    ) external _0x6eecb8(POSITION_MANAGER_ROLE) returns (uint256 _0x0e2766) {
        if (_0xd5b3cf[_0x650aa1]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        _0x0e2766 = _0x1ff29b;
        _0x1ff29b++;

        _0xdd6dd6[_0x0e2766] = PositionManagerConfig({
            _0x650aa1: _0x650aa1,
            _0xcb8d80: _0xcb8d80,
            _0x0babab: true
        });
        _0x16727e[_0x0e2766] = PositionAccountant({
            _0x15b7bd: 0,
            _0x64f010: 0
        });
        _0xd5b3cf[_0x650aa1] = true;

        _0x13a20e += _0xcb8d80;
        emit ProtocolConfigChanged(
            this._0xe7d4ed.selector,
            "addPositionManager(address,uint256)",
            abi._0xe36bfb(_0x650aa1, _0xcb8d80)
        );
    }

    function _0xd4ce16(
        uint256 _0x0e2766,
        uint256 _0xab0d71,
        bool _0x0babab
    ) external _0x6eecb8(POSITION_MANAGER_ROLE) {
        if (_0x0e2766 >= _0x1ff29b) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0xcc9d46 = _0xdd6dd6[_0x0e2766];

        if (_0xab0d71 < _0x16727e[_0x0e2766]._0x15b7bd) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        // Update total allocation capacity
        _0x13a20e = _0x13a20e - _0xcc9d46._0xcb8d80 + _0xab0d71;

        _0xcc9d46._0xcb8d80 = _0xab0d71;
        _0xcc9d46._0x0babab = _0x0babab;

        emit ProtocolConfigChanged(
            this._0xd4ce16.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi._0xe36bfb(_0x0e2766, _0xab0d71, _0x0babab)
        );
    }

    function _0xf61de9(uint256 _0x0e2766) external _0x6eecb8(POSITION_MANAGER_ROLE) {
        if (_0x0e2766 >= _0x1ff29b) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0xcc9d46 = _0xdd6dd6[_0x0e2766];
        _0xcc9d46._0x0babab = !_0xcc9d46._0x0babab;

        emit ProtocolConfigChanged(
            this._0xf61de9.selector,
            "togglePositionManagerStatus(uint256)",
            abi._0xe36bfb(_0x0e2766)
        );
    }

    function _0x7291dd(uint256 _0x729076) external _0x6eecb8(DRAWDOWN_MANAGER_ROLE) {
        if (block.timestamp > 0) { _0x32bce5 = _0x729076; }

        emit ProtocolConfigChanged(
            this._0x7291dd.selector,
            "setCumulativeDrawdown(uint256)",
            abi._0xe36bfb(_0x729076)
        );
    }

    function _0x8c50c9(uint256 _0x2c1a7d) external _0x6eecb8(POSITION_MANAGER_ROLE) {
        if (_0x2c1a7d >= _0x1ff29b) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!_0xdd6dd6[_0x2c1a7d]._0x0babab) {
            revert LiquidityBuffer__ManagerInactive();
        }

        _0xd01871 = _0x2c1a7d;

        emit ProtocolConfigChanged(
            this._0x8c50c9.selector,
            "setDefaultManagerId(uint256)",
            abi._0xe36bfb(_0x2c1a7d)
        );
    }

    /// @notice Sets the fees basis points.
    /// @param newBasisPoints The new fees basis points.
    function _0xa60488(uint16 _0x5f855d) external _0x6eecb8(POSITION_MANAGER_ROLE) {
        if (_0x5f855d > _0xa05a3a) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        if (true) { _0x62b739 = _0x5f855d; }
        emit ProtocolConfigChanged(
            this._0xa60488.selector, "setFeeBasisPoints(uint16)", abi._0xe36bfb(_0x5f855d)
        );
    }

     /// @notice Sets the fees receiver wallet for the protocol.
    /// @param newReceiver The new fees receiver wallet.
    function _0x4784d3(address payable _0x8919fb)
        external
        _0x6eecb8(POSITION_MANAGER_ROLE)
        _0x6fa733(_0x8919fb)
    {
        _0x68eca7 = _0x8919fb;
        emit ProtocolConfigChanged(this._0x4784d3.selector, "setFeesReceiver(address)", abi._0xe36bfb(_0x8919fb));
    }

    /// @notice Sets whether to execute allocation logic in depositETH method.
    /// @param executeAllocation Whether to execute allocation logic.
    function _0xef53bf(bool _0x6ae2b6) external _0x6eecb8(POSITION_MANAGER_ROLE) {
        _0x0ff771 = _0x6ae2b6;
        emit ProtocolConfigChanged(this._0xef53bf.selector, "setShouldExecuteAllocation(bool)", abi._0xe36bfb(_0x6ae2b6));
    }

    // ========================================= LIQUIDITY MANAGEMENT =========================================

    function _0xc800f0() external payable _0x6eecb8(LIQUIDITY_MANAGER_ROLE) {
        if (_0x6df27f._0xdbfeae()) revert LiquidityBuffer__Paused();
        _0x9f73f1(msg.value);
        if (_0x0ff771) {
            _0x64b529(_0xd01871, msg.value);
        }
    }

    function _0x9b8bd1(uint256 _0x0e2766, uint256 _0x4fb941) external _0x6eecb8(LIQUIDITY_MANAGER_ROLE) {
        _0x803c03(_0x0e2766, _0x4fb941);
        _0xd0fccc(_0x4fb941);
    }

    function _0xffb591(uint256 _0x0e2766, uint256 _0x4fb941) external _0x6eecb8(LIQUIDITY_MANAGER_ROLE) {
        _0x64b529(_0x0e2766, _0x4fb941);
    }

    function _0xde221e(uint256 _0x0e2766, uint256 _0x4fb941) external _0x6eecb8(LIQUIDITY_MANAGER_ROLE) {
        _0x803c03(_0x0e2766, _0x4fb941);
    }

    function _0xe0b392(uint256 _0x4fb941) external _0x6eecb8(LIQUIDITY_MANAGER_ROLE) {
        _0xd0fccc(_0x4fb941);
    }

    function _0xe42d13() external payable _0x37103b {
        // This function receives ETH from position managers
        // The ETH is already in the contract balance, no additional processing needed
    }

    // ========================================= INTEREST MANAGEMENT =========================================

    function _0xc31498(uint256 _0x0e2766, uint256 _0x00e4f4) external _0x6eecb8(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x4fb941 = _0x289e5b(_0x0e2766);
        if (_0x4fb941 < _0x00e4f4) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return _0x4fb941;
    }

    function _0x38c72b(uint256 _0x4fb941) external _0x6eecb8(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < _0x4fb941) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0xd5b932(_0x4fb941);
        return _0x4fb941;
    }

    function _0x370596(uint256 _0x0e2766, uint256 _0x00e4f4) external _0x6eecb8(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x4fb941 = _0x289e5b(_0x0e2766);
        if (_0x4fb941 < _0x00e4f4) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0xd5b932(_0x4fb941);

        return _0x4fb941;
    }

    // ========================================= INTERNAL FUNCTIONS =========================================

    function _0xd5b932(uint256 _0x4fb941) internal {
        if (_0x6df27f._0xdbfeae()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x4fb941 > _0x43f29b) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        _0x43f29b -= _0x4fb941;
        uint256 _0x4d20e6 = Math._0x5ace61(_0x62b739, _0x4fb941, _0xa05a3a);
        uint256 _0xf37235 = _0x4fb941 - _0x4d20e6;
        _0x798a9e._0x2e67b5{value: _0xf37235}();
        _0xfaabb9 += _0xf37235;
        emit InterestToppedUp(_0xf37235);

        if (_0x4d20e6 > 0) {
            Address._0xe4b4e1(_0x68eca7, _0x4d20e6);
            _0xeb241d += _0x4d20e6;
            emit FeesCollected(_0x4d20e6);
        }
    }

    function _0x289e5b(uint256 _0x0e2766) internal returns (uint256) {
        if (_0x6df27f._0xdbfeae()) {
            revert LiquidityBuffer__Paused();
        }
        // Get interest amount
        uint256 _0xaf45be = _0xcfb616(_0x0e2766);

        if (_0xaf45be > 0) {
            PositionManagerConfig memory _0xcc9d46 = _0xdd6dd6[_0x0e2766];

            // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
            _0x16727e[_0x0e2766]._0x64f010 += _0xaf45be;
            _0xcfbfc9 += _0xaf45be;
            _0x43f29b += _0xaf45be;
            emit InterestClaimed(_0x0e2766, _0xaf45be);

            // Withdraw interest from position manager AFTER state updates
            IPositionManager _0x8ce51b = IPositionManager(_0xcc9d46._0x650aa1);
            _0x8ce51b._0xf4ce92(_0xaf45be);
        } else {
            emit InterestClaimed(_0x0e2766, _0xaf45be);
        }

        return _0xaf45be;
    }

    function _0x803c03(uint256 _0x0e2766, uint256 _0x4fb941) internal {
        if (_0x6df27f._0xdbfeae()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x0e2766 >= _0x1ff29b) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory _0xcc9d46 = _0xdd6dd6[_0x0e2766];
        if (!_0xcc9d46._0x0babab) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage _0x50a0ab = _0x16727e[_0x0e2766];

        // Check sufficient allocation
        if (_0x4fb941 > _0x50a0ab._0x15b7bd) {
            revert LiquidityBuffer__InsufficientAllocation();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x50a0ab._0x15b7bd -= _0x4fb941;
        _0xdf6059 -= _0x4fb941;
        _0xc548a4 += _0x4fb941;
        emit ETHWithdrawnFromManager(_0x0e2766, _0x4fb941);

        // Call position manager to withdraw AFTER state updates
        IPositionManager _0x8ce51b = IPositionManager(_0xcc9d46._0x650aa1);
        _0x8ce51b._0xf4ce92(_0x4fb941);
    }

    function _0xd0fccc(uint256 _0x4fb941) internal {
        if (_0x6df27f._0xdbfeae()) {
            revert LiquidityBuffer__Paused();
        }

        // Validate staking contract is set and not zero address
        if (address(_0x798a9e) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (_0x4fb941 > _0xc548a4) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x41b41e += _0x4fb941;
        _0xc548a4 -= _0x4fb941;
        emit ETHReturnedToStaking(_0x4fb941);

        // Send ETH to trusted staking contract AFTER state updates
        // Note: stakingContract is a trusted contract set during initialization
        _0x798a9e._0x4e9a16{value: _0x4fb941}();
    }

    function _0x64b529(uint256 _0x0e2766, uint256 _0x4fb941) internal {
        if (_0x6df27f._0xdbfeae()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x4fb941 > _0xc548a4) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (_0x0e2766 >= _0x1ff29b) revert LiquidityBuffer__ManagerNotFound();
        // check available balance
        if (address(this).balance < _0x4fb941) revert LiquidityBuffer__InsufficientBalance();

        // check position manager is active
        PositionManagerConfig memory _0xcc9d46 = _0xdd6dd6[_0x0e2766];
        if (!_0xcc9d46._0x0babab) revert LiquidityBuffer__ManagerInactive();
        // check allocation cap
        PositionAccountant storage _0x50a0ab = _0x16727e[_0x0e2766];
        if (_0x50a0ab._0x15b7bd + _0x4fb941 > _0xcc9d46._0xcb8d80) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x50a0ab._0x15b7bd += _0x4fb941;
        _0xdf6059 += _0x4fb941;
        _0xc548a4 -= _0x4fb941;
        emit ETHAllocatedToManager(_0x0e2766, _0x4fb941);

        // deposit to position manager AFTER state updates
        IPositionManager _0x8ce51b = IPositionManager(_0xcc9d46._0x650aa1);
        _0x8ce51b._0x6e36e4{value: _0x4fb941}(0);
    }

    function _0x9f73f1(uint256 _0x4fb941) internal {
        _0xec7660 += _0x4fb941;
        _0xc548a4 += _0x4fb941;
        emit ETHReceivedFromStaking(_0x4fb941);
    }

    /// @notice Ensures that the given address is not the zero address.
    /// @param addr The address to check.
    modifier _0x6fa733(address _0xb0aceb) {
        if (_0xb0aceb == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }

    /// @dev Validates that the caller is the staking contract.
    modifier _0x5bff1f() {
        if (msg.sender != address(_0x798a9e)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier _0x37103b() {
        bool _0x9f86e0 = false;

        // Loop through all position manager configs to check if sender is a valid manager
        for (uint256 i = 0; i < _0x1ff29b; i++) {
            PositionManagerConfig memory _0xcc9d46 = _0xdd6dd6[i];

            if (msg.sender == _0xcc9d46._0x650aa1 && _0xcc9d46._0x0babab) {
                _0x9f86e0 = true;
                break;
            }
        }

        if (!_0x9f86e0) {
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