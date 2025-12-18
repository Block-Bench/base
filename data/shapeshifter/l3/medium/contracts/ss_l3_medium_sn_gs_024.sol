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
    event ETHWithdrawnFromManager(uint256 indexed _0x0bd334, uint256 _0xda4255);
    event ETHReturnedToStaking(uint256 _0xda4255);
    event ETHAllocatedToManager(uint256 indexed _0x0bd334, uint256 _0xda4255);
    event ETHReceivedFromStaking(uint256 _0xda4255);
    event FeesCollected(uint256 _0xda4255);
    event InterestClaimed(
        uint256 indexed _0x0bd334,
        uint256 _0xf59718
    );
    event InterestToppedUp(
        uint256 _0xda4255
    );
}

/**
 * @title LiquidityBuffer
 * @notice Manages liquidity allocation to various position managers for DeFi protocols
 */
contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;

    // ========================================= CONSTANTS =========================================

    bytes32 public constant LIQUIDITY_MANAGER_ROLE = _0xada994("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = _0xada994("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = _0xada994("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = _0xada994("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _0x2a4667 = 10_000;

    // ========================================= STATE =========================================

    /// @notice The staking contract to which the liquidity buffer accepts funds from and returns funds to.
    IStakingReturnsWrite public _0x429372;

    /// @notice The pauser contract.
    /// @dev Keeps the pause state across the protocol.
    IPauserRead public _0x3da115;

    /// @notice Total number of position managers
    uint256 public _0x6f3b1e;

    /// @notice Mapping from manager ID to position manager configuration
    mapping(uint256 => PositionManagerConfig) public _0xa3eba5;

    /// @notice Mapping from manager ID to accounting information
    mapping(uint256 => PositionAccountant) public _0x8c77fc;

    /// @notice Total funds received from staking contract
    uint256 public _0x25018a;

    /// @notice Total funds returned to staking contract
    uint256 public _0x0246fe;

    /// @notice Total allocated balance across all position managers
    uint256 public _0xe83d27;

    /// @notice Total interest claimed from position managers
    uint256 public _0x39b745;

    /// @notice Total interest topped up to staking contract
    uint256 public _0xfbcb86;

    /// @notice Total allocation capacity across all managers
    uint256 public _0x38dbca;

    /// @notice Cumulative drawdown amount
    uint256 public _0x75d1ca;

    /// @notice Default manager ID for deposit and allocation operations
    uint256 public _0xc0e33e;

    /// @notice The address receiving protocol fees.
    address payable public _0xed7cda;

    /// @notice The protocol fees in basis points (1/10000).
    uint16 public _0x4e6a4a;

    uint256 public _0xbfd9c5;

    /// @notice Tracks pending interest available for top-up operations
    uint256 public _0xbb9be8;

    /// @notice Tracks pending principal available for operations
    uint256 public _0xb9aead;

    /// @notice Controls whether to execute allocation logic in depositETH method
    bool public _0xf08e4b;
    /// @notice Mapping from manager address to boolean indicating if it is registered
    mapping(address => bool) public _0xbc7406;

    struct Init {
        address _0x3044d8;
        address _0xb4880b;
        address _0xc8845c;
        address _0x8450a0;
        address _0x3fd15f;
        address payable _0xed7cda;
        IStakingReturnsWrite _0xb0cfb4;
        IPauserRead _0x3da115;
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
        _0xa3f357();
    }

    function _0x6c48ad(Init memory _0x256a26) external _0xa9fa45 {

        __AccessControlEnumerable_init();

        _0x736c8e(DEFAULT_ADMIN_ROLE, _0x256a26._0x3044d8);
        _0x736c8e(LIQUIDITY_MANAGER_ROLE, _0x256a26._0xb4880b);
        _0x736c8e(POSITION_MANAGER_ROLE, _0x256a26._0xc8845c);
        _0x736c8e(INTEREST_TOPUP_ROLE, _0x256a26._0x8450a0);
        _0x736c8e(DRAWDOWN_MANAGER_ROLE, _0x256a26._0x3fd15f);

        _0x429372 = _0x256a26._0xb0cfb4;
        _0x3da115 = _0x256a26._0x3da115;
        _0xed7cda = _0x256a26._0xed7cda;
        if (block.timestamp > 0) { _0xf08e4b = true; }

        _0x736c8e(LIQUIDITY_MANAGER_ROLE, address(_0x429372));
    }

    // ========================================= VIEW FUNCTIONS =========================================

    function _0x29d1d6(uint256 _0x0bd334) public view returns (uint256) {
        PositionManagerConfig memory _0x5e1cce = _0xa3eba5[_0x0bd334];
        // Get current underlying balance from position manager
        IPositionManager _0xf2558a = IPositionManager(_0x5e1cce._0xff7b82);
        uint256 _0xac97f5 = _0xf2558a._0x608c10();

        // Calculate interest as: current balance - allocated balance
        PositionAccountant memory _0x14f52a = _0x8c77fc[_0x0bd334];

        if (_0xac97f5 > _0x14f52a._0x8c080c) {
            return _0xac97f5 - _0x14f52a._0x8c080c;
        }

        return 0;
    }

    function _0x2dfb9c() public view returns (uint256) {
        return _0x38dbca - _0xe83d27;
    }

    function _0x36537a() public view returns (uint256) {
        return _0x25018a - _0x0246fe;
    }

    function _0x9a774a() public view returns (uint256) {
        uint256 _0x9a6f84 = address(this).balance;

        // Loop through all position manager configs and get their balances
        // Note: This function makes external calls in a loop which can be gas-expensive
        // Consider caching balances or using a different approach for production
        for (uint256 i = 0; i < _0x6f3b1e; i++) {
            PositionManagerConfig storage _0x5e1cce = _0xa3eba5[i];
            if (_0x5e1cce._0x5fb796) {
                IPositionManager _0xf2558a = IPositionManager(_0x5e1cce._0xff7b82);
                uint256 _0x497f6e = _0xf2558a._0x608c10();
                _0x9a6f84 += _0x497f6e;
            }
        }

        return _0x9a6f84;
    }

    // ========================================= ADMIN FUNCTIONS =========================================

    function _0x6d4018(
        address _0xff7b82,
        uint256 _0xd5e241
    ) external _0x19b17d(POSITION_MANAGER_ROLE) returns (uint256 _0x0bd334) {
        if (_0xbc7406[_0xff7b82]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        _0x0bd334 = _0x6f3b1e;
        _0x6f3b1e++;

        _0xa3eba5[_0x0bd334] = PositionManagerConfig({
            _0xff7b82: _0xff7b82,
            _0xd5e241: _0xd5e241,
            _0x5fb796: true
        });
        _0x8c77fc[_0x0bd334] = PositionAccountant({
            _0x8c080c: 0,
            _0xa48ef9: 0
        });
        _0xbc7406[_0xff7b82] = true;

        _0x38dbca += _0xd5e241;
        emit ProtocolConfigChanged(
            this._0x6d4018.selector,
            "addPositionManager(address,uint256)",
            abi._0x27746a(_0xff7b82, _0xd5e241)
        );
    }

    function _0x76e70d(
        uint256 _0x0bd334,
        uint256 _0xbdec81,
        bool _0x5fb796
    ) external _0x19b17d(POSITION_MANAGER_ROLE) {
        if (_0x0bd334 >= _0x6f3b1e) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0x5e1cce = _0xa3eba5[_0x0bd334];

        if (_0xbdec81 < _0x8c77fc[_0x0bd334]._0x8c080c) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        // Update total allocation capacity
        _0x38dbca = _0x38dbca - _0x5e1cce._0xd5e241 + _0xbdec81;

        _0x5e1cce._0xd5e241 = _0xbdec81;
        _0x5e1cce._0x5fb796 = _0x5fb796;

        emit ProtocolConfigChanged(
            this._0x76e70d.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi._0x27746a(_0x0bd334, _0xbdec81, _0x5fb796)
        );
    }

    function _0x44ed97(uint256 _0x0bd334) external _0x19b17d(POSITION_MANAGER_ROLE) {
        if (_0x0bd334 >= _0x6f3b1e) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0x5e1cce = _0xa3eba5[_0x0bd334];
        _0x5e1cce._0x5fb796 = !_0x5e1cce._0x5fb796;

        emit ProtocolConfigChanged(
            this._0x44ed97.selector,
            "togglePositionManagerStatus(uint256)",
            abi._0x27746a(_0x0bd334)
        );
    }

    function _0x11d9e6(uint256 _0xad8b3b) external _0x19b17d(DRAWDOWN_MANAGER_ROLE) {
        _0x75d1ca = _0xad8b3b;

        emit ProtocolConfigChanged(
            this._0x11d9e6.selector,
            "setCumulativeDrawdown(uint256)",
            abi._0x27746a(_0xad8b3b)
        );
    }

    function _0x5631f7(uint256 _0x2f518b) external _0x19b17d(POSITION_MANAGER_ROLE) {
        if (_0x2f518b >= _0x6f3b1e) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!_0xa3eba5[_0x2f518b]._0x5fb796) {
            revert LiquidityBuffer__ManagerInactive();
        }

        if (1 == 1) { _0xc0e33e = _0x2f518b; }

        emit ProtocolConfigChanged(
            this._0x5631f7.selector,
            "setDefaultManagerId(uint256)",
            abi._0x27746a(_0x2f518b)
        );
    }

    /// @notice Sets the fees basis points.
    /// @param newBasisPoints The new fees basis points.
    function _0x9daffb(uint16 _0xf3d78c) external _0x19b17d(POSITION_MANAGER_ROLE) {
        if (_0xf3d78c > _0x2a4667) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        _0x4e6a4a = _0xf3d78c;
        emit ProtocolConfigChanged(
            this._0x9daffb.selector, "setFeeBasisPoints(uint16)", abi._0x27746a(_0xf3d78c)
        );
    }

     /// @notice Sets the fees receiver wallet for the protocol.
    /// @param newReceiver The new fees receiver wallet.
    function _0x83a691(address payable _0x3c4171)
        external
        _0x19b17d(POSITION_MANAGER_ROLE)
        _0x6d6338(_0x3c4171)
    {
        _0xed7cda = _0x3c4171;
        emit ProtocolConfigChanged(this._0x83a691.selector, "setFeesReceiver(address)", abi._0x27746a(_0x3c4171));
    }

    /// @notice Sets whether to execute allocation logic in depositETH method.
    /// @param executeAllocation Whether to execute allocation logic.
    function _0x8b2946(bool _0x42a1ed) external _0x19b17d(POSITION_MANAGER_ROLE) {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xf08e4b = _0x42a1ed; }
        emit ProtocolConfigChanged(this._0x8b2946.selector, "setShouldExecuteAllocation(bool)", abi._0x27746a(_0x42a1ed));
    }

    // ========================================= LIQUIDITY MANAGEMENT =========================================

    function _0x518deb() external payable _0x19b17d(LIQUIDITY_MANAGER_ROLE) {
        if (_0x3da115._0x550a35()) revert LiquidityBuffer__Paused();
        _0x62c1bb(msg.value);
        if (_0xf08e4b) {
            _0x6d2226(_0xc0e33e, msg.value);
        }
    }

    function _0x2e932b(uint256 _0x0bd334, uint256 _0xda4255) external _0x19b17d(LIQUIDITY_MANAGER_ROLE) {
        _0x801a77(_0x0bd334, _0xda4255);
        _0x772f4c(_0xda4255);
    }

    function _0x50e769(uint256 _0x0bd334, uint256 _0xda4255) external _0x19b17d(LIQUIDITY_MANAGER_ROLE) {
        _0x6d2226(_0x0bd334, _0xda4255);
    }

    function _0xa2ac8c(uint256 _0x0bd334, uint256 _0xda4255) external _0x19b17d(LIQUIDITY_MANAGER_ROLE) {
        _0x801a77(_0x0bd334, _0xda4255);
    }

    function _0x30db3c(uint256 _0xda4255) external _0x19b17d(LIQUIDITY_MANAGER_ROLE) {
        _0x772f4c(_0xda4255);
    }

    function _0xa8d555() external payable _0x4c6ccb {
        // This function receives ETH from position managers
        // The ETH is already in the contract balance, no additional processing needed
    }

    // ========================================= INTEREST MANAGEMENT =========================================

    function _0xb795fd(uint256 _0x0bd334, uint256 _0xec2e21) external _0x19b17d(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0xda4255 = _0x5ee604(_0x0bd334);
        if (_0xda4255 < _0xec2e21) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return _0xda4255;
    }

    function _0xc9c5e6(uint256 _0xda4255) external _0x19b17d(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < _0xda4255) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0x22deae(_0xda4255);
        return _0xda4255;
    }

    function _0xf46e0a(uint256 _0x0bd334, uint256 _0xec2e21) external _0x19b17d(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0xda4255 = _0x5ee604(_0x0bd334);
        if (_0xda4255 < _0xec2e21) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0x22deae(_0xda4255);

        return _0xda4255;
    }

    // ========================================= INTERNAL FUNCTIONS =========================================

    function _0x22deae(uint256 _0xda4255) internal {
        if (_0x3da115._0x550a35()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0xda4255 > _0xbb9be8) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        _0xbb9be8 -= _0xda4255;
        uint256 _0x967f70 = Math._0x1bd1c7(_0x4e6a4a, _0xda4255, _0x2a4667);
        uint256 _0xed1cb0 = _0xda4255 - _0x967f70;
        _0x429372._0x506ed0{value: _0xed1cb0}();
        _0xfbcb86 += _0xed1cb0;
        emit InterestToppedUp(_0xed1cb0);

        if (_0x967f70 > 0) {
            Address._0x3a086c(_0xed7cda, _0x967f70);
            _0xbfd9c5 += _0x967f70;
            emit FeesCollected(_0x967f70);
        }
    }

    function _0x5ee604(uint256 _0x0bd334) internal returns (uint256) {
        if (_0x3da115._0x550a35()) {
            revert LiquidityBuffer__Paused();
        }
        // Get interest amount
        uint256 _0xf59718 = _0x29d1d6(_0x0bd334);

        if (_0xf59718 > 0) {
            PositionManagerConfig memory _0x5e1cce = _0xa3eba5[_0x0bd334];

            // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
            _0x8c77fc[_0x0bd334]._0xa48ef9 += _0xf59718;
            _0x39b745 += _0xf59718;
            _0xbb9be8 += _0xf59718;
            emit InterestClaimed(_0x0bd334, _0xf59718);

            // Withdraw interest from position manager AFTER state updates
            IPositionManager _0xf2558a = IPositionManager(_0x5e1cce._0xff7b82);
            _0xf2558a._0xaec698(_0xf59718);
        } else {
            emit InterestClaimed(_0x0bd334, _0xf59718);
        }

        return _0xf59718;
    }

    function _0x801a77(uint256 _0x0bd334, uint256 _0xda4255) internal {
        if (_0x3da115._0x550a35()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x0bd334 >= _0x6f3b1e) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory _0x5e1cce = _0xa3eba5[_0x0bd334];
        if (!_0x5e1cce._0x5fb796) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage _0x14f52a = _0x8c77fc[_0x0bd334];

        // Check sufficient allocation
        if (_0xda4255 > _0x14f52a._0x8c080c) {
            revert LiquidityBuffer__InsufficientAllocation();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x14f52a._0x8c080c -= _0xda4255;
        _0xe83d27 -= _0xda4255;
        _0xb9aead += _0xda4255;
        emit ETHWithdrawnFromManager(_0x0bd334, _0xda4255);

        // Call position manager to withdraw AFTER state updates
        IPositionManager _0xf2558a = IPositionManager(_0x5e1cce._0xff7b82);
        _0xf2558a._0xaec698(_0xda4255);
    }

    function _0x772f4c(uint256 _0xda4255) internal {
        if (_0x3da115._0x550a35()) {
            revert LiquidityBuffer__Paused();
        }

        // Validate staking contract is set and not zero address
        if (address(_0x429372) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (_0xda4255 > _0xb9aead) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x0246fe += _0xda4255;
        _0xb9aead -= _0xda4255;
        emit ETHReturnedToStaking(_0xda4255);

        // Send ETH to trusted staking contract AFTER state updates
        // Note: stakingContract is a trusted contract set during initialization
        _0x429372._0xc0285c{value: _0xda4255}();
    }

    function _0x6d2226(uint256 _0x0bd334, uint256 _0xda4255) internal {
        if (_0x3da115._0x550a35()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0xda4255 > _0xb9aead) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (_0x0bd334 >= _0x6f3b1e) revert LiquidityBuffer__ManagerNotFound();
        // check available balance
        if (address(this).balance < _0xda4255) revert LiquidityBuffer__InsufficientBalance();

        // check position manager is active
        PositionManagerConfig memory _0x5e1cce = _0xa3eba5[_0x0bd334];
        if (!_0x5e1cce._0x5fb796) revert LiquidityBuffer__ManagerInactive();
        // check allocation cap
        PositionAccountant storage _0x14f52a = _0x8c77fc[_0x0bd334];
        if (_0x14f52a._0x8c080c + _0xda4255 > _0x5e1cce._0xd5e241) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x14f52a._0x8c080c += _0xda4255;
        _0xe83d27 += _0xda4255;
        _0xb9aead -= _0xda4255;
        emit ETHAllocatedToManager(_0x0bd334, _0xda4255);

        // deposit to position manager AFTER state updates
        IPositionManager _0xf2558a = IPositionManager(_0x5e1cce._0xff7b82);
        _0xf2558a._0xa34cdc{value: _0xda4255}(0);
    }

    function _0x62c1bb(uint256 _0xda4255) internal {
        _0x25018a += _0xda4255;
        _0xb9aead += _0xda4255;
        emit ETHReceivedFromStaking(_0xda4255);
    }

    /// @notice Ensures that the given address is not the zero address.
    /// @param addr The address to check.
    modifier _0x6d6338(address _0x139ec0) {
        if (_0x139ec0 == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }

    /// @dev Validates that the caller is the staking contract.
    modifier _0x3efc13() {
        if (msg.sender != address(_0x429372)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier _0x4c6ccb() {
        bool _0x73badb = false;

        // Loop through all position manager configs to check if sender is a valid manager
        for (uint256 i = 0; i < _0x6f3b1e; i++) {
            PositionManagerConfig memory _0x5e1cce = _0xa3eba5[i];

            if (msg.sender == _0x5e1cce._0xff7b82 && _0x5e1cce._0x5fb796) {
                _0x73badb = true;
                break;
            }
        }

        if (!_0x73badb) {
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