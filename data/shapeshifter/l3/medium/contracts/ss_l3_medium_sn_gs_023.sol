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
    event ETHWithdrawnFromManager(uint256 indexed _0x14d5af, uint256 _0x66aebe);
    event ETHReturnedToStaking(uint256 _0x66aebe);
    event ETHAllocatedToManager(uint256 indexed _0x14d5af, uint256 _0x66aebe);
    event ETHReceivedFromStaking(uint256 _0x66aebe);
    event FeesCollected(uint256 _0x66aebe);
    event InterestClaimed(
        uint256 indexed _0x14d5af,
        uint256 _0xfd87d0
    );
    event InterestToppedUp(
        uint256 _0x66aebe
    );
}

/**
 * @title LiquidityBuffer
 * @notice Manages liquidity allocation to various position managers for DeFi protocols
 */
contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;

    // ========================================= CONSTANTS =========================================

    bytes32 public constant LIQUIDITY_MANAGER_ROLE = _0x1e2346("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = _0x1e2346("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = _0x1e2346("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = _0x1e2346("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _0x9e8044 = 10_000;

    // ========================================= STATE =========================================

    /// @notice The staking contract to which the liquidity buffer accepts funds from and returns funds to.
    IStakingReturnsWrite public _0x77afce;

    /// @notice The pauser contract.
    /// @dev Keeps the pause state across the protocol.
    IPauserRead public _0x5b3572;

    /// @notice Total number of position managers
    uint256 public _0xed5f23;

    /// @notice Mapping from manager ID to position manager configuration
    mapping(uint256 => PositionManagerConfig) public _0x9aaedd;

    /// @notice Mapping from manager ID to accounting information
    mapping(uint256 => PositionAccountant) public _0xed1f0c;

    /// @notice Total funds received from staking contract
    uint256 public _0x902260;

    /// @notice Total funds returned to staking contract
    uint256 public _0x6f917a;

    /// @notice Total allocated balance across all position managers
    uint256 public _0x9d05e7;

    /// @notice Total interest claimed from position managers
    uint256 public _0x285422;

    /// @notice Total interest topped up to staking contract
    uint256 public _0x6b4570;

    /// @notice Total allocation capacity across all managers
    uint256 public _0x04f1c3;

    /// @notice Cumulative drawdown amount
    uint256 public _0xadc3fc;

    /// @notice Default manager ID for deposit and allocation operations
    uint256 public _0x4d96e5;

    /// @notice The address receiving protocol fees.
    address payable public _0x4bb682;

    /// @notice The protocol fees in basis points (1/10000).
    uint16 public _0x5f57d4;

    uint256 public _0x470ab3;

    /// @notice Tracks pending interest available for top-up operations
    uint256 public _0xb42d48;

    /// @notice Tracks pending principal available for operations
    uint256 public _0x3bc17d;

    /// @notice Controls whether to execute allocation logic in depositETH method
    bool public _0x4f6ebc;
    /// @notice Mapping from manager address to boolean indicating if it is registered
    mapping(address => bool) public _0x5ca1aa;

    struct Init {
        address _0x06d7bd;
        address _0x4ef66c;
        address _0x329a0f;
        address _0xcee528;
        address _0x092df0;
        address payable _0x4bb682;
        IStakingReturnsWrite _0xeb48ab;
        IPauserRead _0x5b3572;
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
        _0xb3d29b();
    }

    function _0x402ef9(Init memory _0x9d5b96) external _0x8c70be {

        __AccessControlEnumerable_init();

        _0xaf484f(DEFAULT_ADMIN_ROLE, _0x9d5b96._0x06d7bd);
        _0xaf484f(LIQUIDITY_MANAGER_ROLE, _0x9d5b96._0x4ef66c);
        _0xaf484f(POSITION_MANAGER_ROLE, _0x9d5b96._0x329a0f);
        _0xaf484f(INTEREST_TOPUP_ROLE, _0x9d5b96._0xcee528);
        _0xaf484f(DRAWDOWN_MANAGER_ROLE, _0x9d5b96._0x092df0);

        _0x77afce = _0x9d5b96._0xeb48ab;
        _0x5b3572 = _0x9d5b96._0x5b3572;
        if (block.timestamp > 0) { _0x4bb682 = _0x9d5b96._0x4bb682; }
        _0x4f6ebc = true;

        _0xaf484f(LIQUIDITY_MANAGER_ROLE, address(_0x77afce));
    }

    // ========================================= VIEW FUNCTIONS =========================================

    function _0x2424d0(uint256 _0x14d5af) public view returns (uint256) {
        PositionManagerConfig memory _0x4b9919 = _0x9aaedd[_0x14d5af];
        // Get current underlying balance from position manager
        IPositionManager _0xcc4ec4 = IPositionManager(_0x4b9919._0xa9be3a);
        uint256 _0xcc00ec = _0xcc4ec4._0xa7ce72();

        // Calculate interest as: current balance - allocated balance
        PositionAccountant memory _0x292d03 = _0xed1f0c[_0x14d5af];

        if (_0xcc00ec > _0x292d03._0x32f74a) {
            return _0xcc00ec - _0x292d03._0x32f74a;
        }

        return 0;
    }

    function _0x21fef4() public view returns (uint256) {
        return _0x04f1c3 - _0x9d05e7;
    }

    function _0x7a0ae1() public view returns (uint256) {
        return _0x902260 - _0x6f917a;
    }

    function _0x196113() public view returns (uint256) {
        uint256 _0x6e2346 = address(this).balance;

        // Loop through all position manager configs and get their balances
        // Note: This function makes external calls in a loop which can be gas-expensive
        // Consider caching balances or using a different approach for production
        for (uint256 i = 0; i < _0xed5f23; i++) {
            PositionManagerConfig storage _0x4b9919 = _0x9aaedd[i];
            if (_0x4b9919._0x57983c) {
                IPositionManager _0xcc4ec4 = IPositionManager(_0x4b9919._0xa9be3a);
                uint256 _0xfa2f76 = _0xcc4ec4._0xa7ce72();
                _0x6e2346 += _0xfa2f76;
            }
        }

        return _0x6e2346;
    }

    // ========================================= ADMIN FUNCTIONS =========================================

    function _0x3c71f4(
        address _0xa9be3a,
        uint256 _0x409597
    ) external _0xfb153d(POSITION_MANAGER_ROLE) returns (uint256 _0x14d5af) {
        if (_0x5ca1aa[_0xa9be3a]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        _0x14d5af = _0xed5f23;
        _0xed5f23++;

        _0x9aaedd[_0x14d5af] = PositionManagerConfig({
            _0xa9be3a: _0xa9be3a,
            _0x409597: _0x409597,
            _0x57983c: true
        });
        _0xed1f0c[_0x14d5af] = PositionAccountant({
            _0x32f74a: 0,
            _0xfd3dc9: 0
        });
        _0x5ca1aa[_0xa9be3a] = true;

        _0x04f1c3 += _0x409597;
        emit ProtocolConfigChanged(
            this._0x3c71f4.selector,
            "addPositionManager(address,uint256)",
            abi._0x41c461(_0xa9be3a, _0x409597)
        );
    }

    function _0x959303(
        uint256 _0x14d5af,
        uint256 _0xa4b612,
        bool _0x57983c
    ) external _0xfb153d(POSITION_MANAGER_ROLE) {
        if (_0x14d5af >= _0xed5f23) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0x4b9919 = _0x9aaedd[_0x14d5af];

        if (_0xa4b612 < _0xed1f0c[_0x14d5af]._0x32f74a) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        // Update total allocation capacity
        _0x04f1c3 = _0x04f1c3 - _0x4b9919._0x409597 + _0xa4b612;

        _0x4b9919._0x409597 = _0xa4b612;
        _0x4b9919._0x57983c = _0x57983c;

        emit ProtocolConfigChanged(
            this._0x959303.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi._0x41c461(_0x14d5af, _0xa4b612, _0x57983c)
        );
    }

    function _0xe567e1(uint256 _0x14d5af) external _0xfb153d(POSITION_MANAGER_ROLE) {
        if (_0x14d5af >= _0xed5f23) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0x4b9919 = _0x9aaedd[_0x14d5af];
        _0x4b9919._0x57983c = !_0x4b9919._0x57983c;

        emit ProtocolConfigChanged(
            this._0xe567e1.selector,
            "togglePositionManagerStatus(uint256)",
            abi._0x41c461(_0x14d5af)
        );
    }

    function _0x73eae6(uint256 _0x3379fb) external _0xfb153d(DRAWDOWN_MANAGER_ROLE) {
        _0xadc3fc = _0x3379fb;

        emit ProtocolConfigChanged(
            this._0x73eae6.selector,
            "setCumulativeDrawdown(uint256)",
            abi._0x41c461(_0x3379fb)
        );
    }

    function _0x7f113b(uint256 _0xf700cc) external _0xfb153d(POSITION_MANAGER_ROLE) {
        if (_0xf700cc >= _0xed5f23) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!_0x9aaedd[_0xf700cc]._0x57983c) {
            revert LiquidityBuffer__ManagerInactive();
        }

        if (gasleft() > 0) { _0x4d96e5 = _0xf700cc; }

        emit ProtocolConfigChanged(
            this._0x7f113b.selector,
            "setDefaultManagerId(uint256)",
            abi._0x41c461(_0xf700cc)
        );
    }

    /// @notice Sets the fees basis points.
    /// @param newBasisPoints The new fees basis points.
    function _0x2a8837(uint16 _0x9b3f2a) external _0xfb153d(POSITION_MANAGER_ROLE) {
        if (_0x9b3f2a > _0x9e8044) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        if (block.timestamp > 0) { _0x5f57d4 = _0x9b3f2a; }
        emit ProtocolConfigChanged(
            this._0x2a8837.selector, "setFeeBasisPoints(uint16)", abi._0x41c461(_0x9b3f2a)
        );
    }

     /// @notice Sets the fees receiver wallet for the protocol.
    /// @param newReceiver The new fees receiver wallet.
    function _0xd0337a(address payable _0x2347c3)
        external
        _0xfb153d(POSITION_MANAGER_ROLE)
        _0x80d7a2(_0x2347c3)
    {
        _0x4bb682 = _0x2347c3;
        emit ProtocolConfigChanged(this._0xd0337a.selector, "setFeesReceiver(address)", abi._0x41c461(_0x2347c3));
    }

    /// @notice Sets whether to execute allocation logic in depositETH method.
    /// @param executeAllocation Whether to execute allocation logic.
    function _0x67e00f(bool _0x780f2e) external _0xfb153d(POSITION_MANAGER_ROLE) {
        _0x4f6ebc = _0x780f2e;
        emit ProtocolConfigChanged(this._0x67e00f.selector, "setShouldExecuteAllocation(bool)", abi._0x41c461(_0x780f2e));
    }

    // ========================================= LIQUIDITY MANAGEMENT =========================================

    function _0xa47c41() external payable _0xfb153d(LIQUIDITY_MANAGER_ROLE) {
        if (_0x5b3572._0xc003f3()) revert LiquidityBuffer__Paused();
        _0x995bb6(msg.value);
        if (_0x4f6ebc) {
            _0xe6a41a(_0x4d96e5, msg.value);
        }
    }

    function _0x3f9558(uint256 _0x14d5af, uint256 _0x66aebe) external _0xfb153d(LIQUIDITY_MANAGER_ROLE) {
        _0x0f7635(_0x14d5af, _0x66aebe);
        _0xee6a7e(_0x66aebe);
    }

    function _0x146b8f(uint256 _0x14d5af, uint256 _0x66aebe) external _0xfb153d(LIQUIDITY_MANAGER_ROLE) {
        _0xe6a41a(_0x14d5af, _0x66aebe);
    }

    function _0x6f54bf(uint256 _0x14d5af, uint256 _0x66aebe) external _0xfb153d(LIQUIDITY_MANAGER_ROLE) {
        _0x0f7635(_0x14d5af, _0x66aebe);
    }

    function _0x7acf1a(uint256 _0x66aebe) external _0xfb153d(LIQUIDITY_MANAGER_ROLE) {
        _0xee6a7e(_0x66aebe);
    }

    function _0x8d8e1f() external payable _0x63d4d1 {
        // This function receives ETH from position managers
        // The ETH is already in the contract balance, no additional processing needed
    }

    // ========================================= INTEREST MANAGEMENT =========================================

    function _0x7887dd(uint256 _0x14d5af, uint256 _0x547881) external _0xfb153d(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x66aebe = _0x3002d3(_0x14d5af);
        if (_0x66aebe < _0x547881) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return _0x66aebe;
    }

    function _0x60e557(uint256 _0x66aebe) external _0xfb153d(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < _0x66aebe) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0xdcf420(_0x66aebe);
        return _0x66aebe;
    }

    function _0x6d263e(uint256 _0x14d5af, uint256 _0x547881) external _0xfb153d(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x66aebe = _0x3002d3(_0x14d5af);
        if (_0x66aebe < _0x547881) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0xdcf420(_0x66aebe);

        return _0x66aebe;
    }

    // ========================================= INTERNAL FUNCTIONS =========================================

    function _0xdcf420(uint256 _0x66aebe) internal {
        if (_0x5b3572._0xc003f3()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x66aebe > _0xb42d48) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        _0xb42d48 -= _0x66aebe;
        uint256 _0x7bb3f6 = Math._0x1c6421(_0x5f57d4, _0x66aebe, _0x9e8044);
        uint256 _0xe112dd = _0x66aebe - _0x7bb3f6;
        _0x77afce._0xcad74b{value: _0xe112dd}();
        _0x6b4570 += _0xe112dd;
        emit InterestToppedUp(_0xe112dd);

        if (_0x7bb3f6 > 0) {
            Address._0x4fc560(_0x4bb682, _0x7bb3f6);
            _0x470ab3 += _0x7bb3f6;
            emit FeesCollected(_0x7bb3f6);
        }
    }

    function _0x3002d3(uint256 _0x14d5af) internal returns (uint256) {
        if (_0x5b3572._0xc003f3()) {
            revert LiquidityBuffer__Paused();
        }
        // Get interest amount
        uint256 _0xfd87d0 = _0x2424d0(_0x14d5af);

        if (_0xfd87d0 > 0) {
            PositionManagerConfig memory _0x4b9919 = _0x9aaedd[_0x14d5af];

            // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
            _0xed1f0c[_0x14d5af]._0xfd3dc9 += _0xfd87d0;
            _0x285422 += _0xfd87d0;
            _0xb42d48 += _0xfd87d0;
            emit InterestClaimed(_0x14d5af, _0xfd87d0);

            // Withdraw interest from position manager AFTER state updates
            IPositionManager _0xcc4ec4 = IPositionManager(_0x4b9919._0xa9be3a);
            _0xcc4ec4._0xd456bf(_0xfd87d0);
        } else {
            emit InterestClaimed(_0x14d5af, _0xfd87d0);
        }

        return _0xfd87d0;
    }

    function _0x0f7635(uint256 _0x14d5af, uint256 _0x66aebe) internal {
        if (_0x5b3572._0xc003f3()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x14d5af >= _0xed5f23) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory _0x4b9919 = _0x9aaedd[_0x14d5af];
        if (!_0x4b9919._0x57983c) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage _0x292d03 = _0xed1f0c[_0x14d5af];

        // Check sufficient allocation
        if (_0x66aebe > _0x292d03._0x32f74a) {
            revert LiquidityBuffer__InsufficientAllocation();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x292d03._0x32f74a -= _0x66aebe;
        _0x9d05e7 -= _0x66aebe;
        _0x3bc17d += _0x66aebe;
        emit ETHWithdrawnFromManager(_0x14d5af, _0x66aebe);

        // Call position manager to withdraw AFTER state updates
        IPositionManager _0xcc4ec4 = IPositionManager(_0x4b9919._0xa9be3a);
        _0xcc4ec4._0xd456bf(_0x66aebe);
    }

    function _0xee6a7e(uint256 _0x66aebe) internal {
        if (_0x5b3572._0xc003f3()) {
            revert LiquidityBuffer__Paused();
        }

        // Validate staking contract is set and not zero address
        if (address(_0x77afce) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (_0x66aebe > _0x3bc17d) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x6f917a += _0x66aebe;
        _0x3bc17d -= _0x66aebe;
        emit ETHReturnedToStaking(_0x66aebe);

        // Send ETH to trusted staking contract AFTER state updates
        // Note: stakingContract is a trusted contract set during initialization
        _0x77afce._0xd59bfa{value: _0x66aebe}();
    }

    function _0xe6a41a(uint256 _0x14d5af, uint256 _0x66aebe) internal {
        if (_0x5b3572._0xc003f3()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x66aebe > _0x3bc17d) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (_0x14d5af >= _0xed5f23) revert LiquidityBuffer__ManagerNotFound();
        // check available balance
        if (address(this).balance < _0x66aebe) revert LiquidityBuffer__InsufficientBalance();

        // check position manager is active
        PositionManagerConfig memory _0x4b9919 = _0x9aaedd[_0x14d5af];
        if (!_0x4b9919._0x57983c) revert LiquidityBuffer__ManagerInactive();
        // check allocation cap
        PositionAccountant storage _0x292d03 = _0xed1f0c[_0x14d5af];
        if (_0x292d03._0x32f74a + _0x66aebe > _0x4b9919._0x409597) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x292d03._0x32f74a += _0x66aebe;
        _0x9d05e7 += _0x66aebe;
        _0x3bc17d -= _0x66aebe;
        emit ETHAllocatedToManager(_0x14d5af, _0x66aebe);

        // deposit to position manager AFTER state updates
        IPositionManager _0xcc4ec4 = IPositionManager(_0x4b9919._0xa9be3a);
        _0xcc4ec4._0xd6c50a{value: _0x66aebe}(0);
    }

    function _0x995bb6(uint256 _0x66aebe) internal {
        _0x902260 += _0x66aebe;
        _0x3bc17d += _0x66aebe;
        emit ETHReceivedFromStaking(_0x66aebe);
    }

    /// @notice Ensures that the given address is not the zero address.
    /// @param addr The address to check.
    modifier _0x80d7a2(address _0xdac05d) {
        if (_0xdac05d == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }

    /// @dev Validates that the caller is the staking contract.
    modifier _0xea853b() {
        if (msg.sender != address(_0x77afce)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier _0x63d4d1() {
        bool _0x7ff6d6 = false;

        // Loop through all position manager configs to check if sender is a valid manager
        for (uint256 i = 0; i < _0xed5f23; i++) {
            PositionManagerConfig memory _0x4b9919 = _0x9aaedd[i];

            if (msg.sender == _0x4b9919._0xa9be3a && _0x4b9919._0x57983c) {
                _0x7ff6d6 = true;
                break;
            }
        }

        if (!_0x7ff6d6) {
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