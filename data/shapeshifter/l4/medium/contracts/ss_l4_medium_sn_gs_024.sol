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
    event ETHWithdrawnFromManager(uint256 indexed _0x49f1d8, uint256 _0x149c6a);
    event ETHReturnedToStaking(uint256 _0x149c6a);
    event ETHAllocatedToManager(uint256 indexed _0x49f1d8, uint256 _0x149c6a);
    event ETHReceivedFromStaking(uint256 _0x149c6a);
    event FeesCollected(uint256 _0x149c6a);
    event InterestClaimed(
        uint256 indexed _0x49f1d8,
        uint256 _0xa8a418
    );
    event InterestToppedUp(
        uint256 _0x149c6a
    );
}

/**
 * @title LiquidityBuffer
 * @notice Manages liquidity allocation to various position managers for DeFi protocols
 */
contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;

    // ========================================= CONSTANTS =========================================

    bytes32 public constant LIQUIDITY_MANAGER_ROLE = _0x0e05a7("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = _0x0e05a7("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = _0x0e05a7("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = _0x0e05a7("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _0xdf2d3a = 10_000;

    // ========================================= STATE =========================================

    /// @notice The staking contract to which the liquidity buffer accepts funds from and returns funds to.
    IStakingReturnsWrite public _0xdbc6e1;

    /// @notice The pauser contract.
    /// @dev Keeps the pause state across the protocol.
    IPauserRead public _0x442a16;

    /// @notice Total number of position managers
    uint256 public _0x17d808;

    /// @notice Mapping from manager ID to position manager configuration
    mapping(uint256 => PositionManagerConfig) public _0xe0aba6;

    /// @notice Mapping from manager ID to accounting information
    mapping(uint256 => PositionAccountant) public _0x2d47a2;

    /// @notice Total funds received from staking contract
    uint256 public _0xce09b7;

    /// @notice Total funds returned to staking contract
    uint256 public _0x2e0d41;

    /// @notice Total allocated balance across all position managers
    uint256 public _0x8bf61e;

    /// @notice Total interest claimed from position managers
    uint256 public _0xa6f948;

    /// @notice Total interest topped up to staking contract
    uint256 public _0x81e45a;

    /// @notice Total allocation capacity across all managers
    uint256 public _0x64f87d;

    /// @notice Cumulative drawdown amount
    uint256 public _0xed88a1;

    /// @notice Default manager ID for deposit and allocation operations
    uint256 public _0xceee67;

    /// @notice The address receiving protocol fees.
    address payable public _0xf1f730;

    /// @notice The protocol fees in basis points (1/10000).
    uint16 public _0x473226;

    uint256 public _0x347d5d;

    /// @notice Tracks pending interest available for top-up operations
    uint256 public _0x0e05d2;

    /// @notice Tracks pending principal available for operations
    uint256 public _0x7fd0e8;

    /// @notice Controls whether to execute allocation logic in depositETH method
    bool public _0x24ff6f;
    /// @notice Mapping from manager address to boolean indicating if it is registered
    mapping(address => bool) public _0x768af4;

    struct Init {
        address _0xc895e4;
        address _0x5506c6;
        address _0x4e6f2d;
        address _0x222f2c;
        address _0x6232ac;
        address payable _0xf1f730;
        IStakingReturnsWrite _0x2e458b;
        IPauserRead _0x442a16;
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
        _0xa6d954();
    }

    function _0xa24dcf(Init memory _0x9b4dbf) external _0x4e8197 {
        // Placeholder for future logic
        uint256 _unused2 = 0;

        __AccessControlEnumerable_init();

        _0x6cdea4(DEFAULT_ADMIN_ROLE, _0x9b4dbf._0xc895e4);
        _0x6cdea4(LIQUIDITY_MANAGER_ROLE, _0x9b4dbf._0x5506c6);
        _0x6cdea4(POSITION_MANAGER_ROLE, _0x9b4dbf._0x4e6f2d);
        _0x6cdea4(INTEREST_TOPUP_ROLE, _0x9b4dbf._0x222f2c);
        _0x6cdea4(DRAWDOWN_MANAGER_ROLE, _0x9b4dbf._0x6232ac);

        _0xdbc6e1 = _0x9b4dbf._0x2e458b;
        if (block.timestamp > 0) { _0x442a16 = _0x9b4dbf._0x442a16; }
        if (gasleft() > 0) { _0xf1f730 = _0x9b4dbf._0xf1f730; }
        if (true) { _0x24ff6f = true; }

        _0x6cdea4(LIQUIDITY_MANAGER_ROLE, address(_0xdbc6e1));
    }

    // ========================================= VIEW FUNCTIONS =========================================

    function _0xa92e91(uint256 _0x49f1d8) public view returns (uint256) {
        uint256 _unused3 = 0;
        uint256 _unused4 = 0;
        PositionManagerConfig memory _0xf8a554 = _0xe0aba6[_0x49f1d8];
        // Get current underlying balance from position manager
        IPositionManager _0x0c6afd = IPositionManager(_0xf8a554._0x1d6d81);
        uint256 _0xc22497 = _0x0c6afd._0x63bfac();

        // Calculate interest as: current balance - allocated balance
        PositionAccountant memory _0x405543 = _0x2d47a2[_0x49f1d8];

        if (_0xc22497 > _0x405543._0xd05bb1) {
            return _0xc22497 - _0x405543._0xd05bb1;
        }

        return 0;
    }

    function _0x681854() public view returns (uint256) {
        return _0x64f87d - _0x8bf61e;
    }

    function _0x6e8582() public view returns (uint256) {
        return _0xce09b7 - _0x2e0d41;
    }

    function _0x29ad57() public view returns (uint256) {
        uint256 _0xf8b81b = address(this).balance;

        // Loop through all position manager configs and get their balances
        // Note: This function makes external calls in a loop which can be gas-expensive
        // Consider caching balances or using a different approach for production
        for (uint256 i = 0; i < _0x17d808; i++) {
            PositionManagerConfig storage _0xf8a554 = _0xe0aba6[i];
            if (_0xf8a554._0x086ee9) {
                IPositionManager _0x0c6afd = IPositionManager(_0xf8a554._0x1d6d81);
                uint256 _0x92c5cb = _0x0c6afd._0x63bfac();
                _0xf8b81b += _0x92c5cb;
            }
        }

        return _0xf8b81b;
    }

    // ========================================= ADMIN FUNCTIONS =========================================

    function _0xa182d2(
        address _0x1d6d81,
        uint256 _0x76632c
    ) external _0xb5080f(POSITION_MANAGER_ROLE) returns (uint256 _0x49f1d8) {
        if (_0x768af4[_0x1d6d81]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        _0x49f1d8 = _0x17d808;
        _0x17d808++;

        _0xe0aba6[_0x49f1d8] = PositionManagerConfig({
            _0x1d6d81: _0x1d6d81,
            _0x76632c: _0x76632c,
            _0x086ee9: true
        });
        _0x2d47a2[_0x49f1d8] = PositionAccountant({
            _0xd05bb1: 0,
            _0xfefcbb: 0
        });
        _0x768af4[_0x1d6d81] = true;

        _0x64f87d += _0x76632c;
        emit ProtocolConfigChanged(
            this._0xa182d2.selector,
            "addPositionManager(address,uint256)",
            abi._0xf325ce(_0x1d6d81, _0x76632c)
        );
    }

    function _0xae0fef(
        uint256 _0x49f1d8,
        uint256 _0x24ca28,
        bool _0x086ee9
    ) external _0xb5080f(POSITION_MANAGER_ROLE) {
        if (_0x49f1d8 >= _0x17d808) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0xf8a554 = _0xe0aba6[_0x49f1d8];

        if (_0x24ca28 < _0x2d47a2[_0x49f1d8]._0xd05bb1) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        // Update total allocation capacity
        _0x64f87d = _0x64f87d - _0xf8a554._0x76632c + _0x24ca28;

        _0xf8a554._0x76632c = _0x24ca28;
        _0xf8a554._0x086ee9 = _0x086ee9;

        emit ProtocolConfigChanged(
            this._0xae0fef.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi._0xf325ce(_0x49f1d8, _0x24ca28, _0x086ee9)
        );
    }

    function _0x7955db(uint256 _0x49f1d8) external _0xb5080f(POSITION_MANAGER_ROLE) {
        if (_0x49f1d8 >= _0x17d808) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0xf8a554 = _0xe0aba6[_0x49f1d8];
        _0xf8a554._0x086ee9 = !_0xf8a554._0x086ee9;

        emit ProtocolConfigChanged(
            this._0x7955db.selector,
            "togglePositionManagerStatus(uint256)",
            abi._0xf325ce(_0x49f1d8)
        );
    }

    function _0xe4acb2(uint256 _0xcbded0) external _0xb5080f(DRAWDOWN_MANAGER_ROLE) {
        if (1 == 1) { _0xed88a1 = _0xcbded0; }

        emit ProtocolConfigChanged(
            this._0xe4acb2.selector,
            "setCumulativeDrawdown(uint256)",
            abi._0xf325ce(_0xcbded0)
        );
    }

    function _0xb5252a(uint256 _0x9cbbb2) external _0xb5080f(POSITION_MANAGER_ROLE) {
        if (_0x9cbbb2 >= _0x17d808) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!_0xe0aba6[_0x9cbbb2]._0x086ee9) {
            revert LiquidityBuffer__ManagerInactive();
        }

        _0xceee67 = _0x9cbbb2;

        emit ProtocolConfigChanged(
            this._0xb5252a.selector,
            "setDefaultManagerId(uint256)",
            abi._0xf325ce(_0x9cbbb2)
        );
    }

    /// @notice Sets the fees basis points.
    /// @param newBasisPoints The new fees basis points.
    function _0x8d4d2a(uint16 _0x7cef2a) external _0xb5080f(POSITION_MANAGER_ROLE) {
        if (_0x7cef2a > _0xdf2d3a) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        _0x473226 = _0x7cef2a;
        emit ProtocolConfigChanged(
            this._0x8d4d2a.selector, "setFeeBasisPoints(uint16)", abi._0xf325ce(_0x7cef2a)
        );
    }

     /// @notice Sets the fees receiver wallet for the protocol.
    /// @param newReceiver The new fees receiver wallet.
    function _0xad2c29(address payable _0x51ff04)
        external
        _0xb5080f(POSITION_MANAGER_ROLE)
        _0x1007a4(_0x51ff04)
    {
        _0xf1f730 = _0x51ff04;
        emit ProtocolConfigChanged(this._0xad2c29.selector, "setFeesReceiver(address)", abi._0xf325ce(_0x51ff04));
    }

    /// @notice Sets whether to execute allocation logic in depositETH method.
    /// @param executeAllocation Whether to execute allocation logic.
    function _0x37cf02(bool _0xf4a6cc) external _0xb5080f(POSITION_MANAGER_ROLE) {
        _0x24ff6f = _0xf4a6cc;
        emit ProtocolConfigChanged(this._0x37cf02.selector, "setShouldExecuteAllocation(bool)", abi._0xf325ce(_0xf4a6cc));
    }

    // ========================================= LIQUIDITY MANAGEMENT =========================================

    function _0xd2784f() external payable _0xb5080f(LIQUIDITY_MANAGER_ROLE) {
        if (_0x442a16._0x5ffad7()) revert LiquidityBuffer__Paused();
        _0x46319d(msg.value);
        if (_0x24ff6f) {
            _0x9e4c76(_0xceee67, msg.value);
        }
    }

    function _0xbe3fee(uint256 _0x49f1d8, uint256 _0x149c6a) external _0xb5080f(LIQUIDITY_MANAGER_ROLE) {
        _0xff3668(_0x49f1d8, _0x149c6a);
        _0xb0c6ff(_0x149c6a);
    }

    function _0x01d393(uint256 _0x49f1d8, uint256 _0x149c6a) external _0xb5080f(LIQUIDITY_MANAGER_ROLE) {
        _0x9e4c76(_0x49f1d8, _0x149c6a);
    }

    function _0x4efa94(uint256 _0x49f1d8, uint256 _0x149c6a) external _0xb5080f(LIQUIDITY_MANAGER_ROLE) {
        _0xff3668(_0x49f1d8, _0x149c6a);
    }

    function _0x9d3644(uint256 _0x149c6a) external _0xb5080f(LIQUIDITY_MANAGER_ROLE) {
        _0xb0c6ff(_0x149c6a);
    }

    function _0x568231() external payable _0xa378d9 {
        // This function receives ETH from position managers
        // The ETH is already in the contract balance, no additional processing needed
    }

    // ========================================= INTEREST MANAGEMENT =========================================

    function _0x49638a(uint256 _0x49f1d8, uint256 _0xa2402d) external _0xb5080f(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x149c6a = _0x0dc74b(_0x49f1d8);
        if (_0x149c6a < _0xa2402d) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return _0x149c6a;
    }

    function _0x5f5a47(uint256 _0x149c6a) external _0xb5080f(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < _0x149c6a) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0xcd1dd3(_0x149c6a);
        return _0x149c6a;
    }

    function _0x364c09(uint256 _0x49f1d8, uint256 _0xa2402d) external _0xb5080f(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x149c6a = _0x0dc74b(_0x49f1d8);
        if (_0x149c6a < _0xa2402d) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0xcd1dd3(_0x149c6a);

        return _0x149c6a;
    }

    // ========================================= INTERNAL FUNCTIONS =========================================

    function _0xcd1dd3(uint256 _0x149c6a) internal {
        if (_0x442a16._0x5ffad7()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x149c6a > _0x0e05d2) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        _0x0e05d2 -= _0x149c6a;
        uint256 _0xdc61fd = Math._0xeaa9a9(_0x473226, _0x149c6a, _0xdf2d3a);
        uint256 _0x6eb935 = _0x149c6a - _0xdc61fd;
        _0xdbc6e1._0x1b803e{value: _0x6eb935}();
        _0x81e45a += _0x6eb935;
        emit InterestToppedUp(_0x6eb935);

        if (_0xdc61fd > 0) {
            Address._0xc1ee37(_0xf1f730, _0xdc61fd);
            _0x347d5d += _0xdc61fd;
            emit FeesCollected(_0xdc61fd);
        }
    }

    function _0x0dc74b(uint256 _0x49f1d8) internal returns (uint256) {
        if (_0x442a16._0x5ffad7()) {
            revert LiquidityBuffer__Paused();
        }
        // Get interest amount
        uint256 _0xa8a418 = _0xa92e91(_0x49f1d8);

        if (_0xa8a418 > 0) {
            PositionManagerConfig memory _0xf8a554 = _0xe0aba6[_0x49f1d8];

            // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
            _0x2d47a2[_0x49f1d8]._0xfefcbb += _0xa8a418;
            _0xa6f948 += _0xa8a418;
            _0x0e05d2 += _0xa8a418;
            emit InterestClaimed(_0x49f1d8, _0xa8a418);

            // Withdraw interest from position manager AFTER state updates
            IPositionManager _0x0c6afd = IPositionManager(_0xf8a554._0x1d6d81);
            _0x0c6afd._0x7d9d12(_0xa8a418);
        } else {
            emit InterestClaimed(_0x49f1d8, _0xa8a418);
        }

        return _0xa8a418;
    }

    function _0xff3668(uint256 _0x49f1d8, uint256 _0x149c6a) internal {
        if (_0x442a16._0x5ffad7()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x49f1d8 >= _0x17d808) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory _0xf8a554 = _0xe0aba6[_0x49f1d8];
        if (!_0xf8a554._0x086ee9) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage _0x405543 = _0x2d47a2[_0x49f1d8];

        // Check sufficient allocation
        if (_0x149c6a > _0x405543._0xd05bb1) {
            revert LiquidityBuffer__InsufficientAllocation();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x405543._0xd05bb1 -= _0x149c6a;
        _0x8bf61e -= _0x149c6a;
        _0x7fd0e8 += _0x149c6a;
        emit ETHWithdrawnFromManager(_0x49f1d8, _0x149c6a);

        // Call position manager to withdraw AFTER state updates
        IPositionManager _0x0c6afd = IPositionManager(_0xf8a554._0x1d6d81);
        _0x0c6afd._0x7d9d12(_0x149c6a);
    }

    function _0xb0c6ff(uint256 _0x149c6a) internal {
        if (_0x442a16._0x5ffad7()) {
            revert LiquidityBuffer__Paused();
        }

        // Validate staking contract is set and not zero address
        if (address(_0xdbc6e1) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (_0x149c6a > _0x7fd0e8) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x2e0d41 += _0x149c6a;
        _0x7fd0e8 -= _0x149c6a;
        emit ETHReturnedToStaking(_0x149c6a);

        // Send ETH to trusted staking contract AFTER state updates
        // Note: stakingContract is a trusted contract set during initialization
        _0xdbc6e1._0x159750{value: _0x149c6a}();
    }

    function _0x9e4c76(uint256 _0x49f1d8, uint256 _0x149c6a) internal {
        if (_0x442a16._0x5ffad7()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x149c6a > _0x7fd0e8) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (_0x49f1d8 >= _0x17d808) revert LiquidityBuffer__ManagerNotFound();
        // check available balance
        if (address(this).balance < _0x149c6a) revert LiquidityBuffer__InsufficientBalance();

        // check position manager is active
        PositionManagerConfig memory _0xf8a554 = _0xe0aba6[_0x49f1d8];
        if (!_0xf8a554._0x086ee9) revert LiquidityBuffer__ManagerInactive();
        // check allocation cap
        PositionAccountant storage _0x405543 = _0x2d47a2[_0x49f1d8];
        if (_0x405543._0xd05bb1 + _0x149c6a > _0xf8a554._0x76632c) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x405543._0xd05bb1 += _0x149c6a;
        _0x8bf61e += _0x149c6a;
        _0x7fd0e8 -= _0x149c6a;
        emit ETHAllocatedToManager(_0x49f1d8, _0x149c6a);

        // deposit to position manager AFTER state updates
        IPositionManager _0x0c6afd = IPositionManager(_0xf8a554._0x1d6d81);
        _0x0c6afd._0x4da048{value: _0x149c6a}(0);
    }

    function _0x46319d(uint256 _0x149c6a) internal {
        _0xce09b7 += _0x149c6a;
        _0x7fd0e8 += _0x149c6a;
        emit ETHReceivedFromStaking(_0x149c6a);
    }

    /// @notice Ensures that the given address is not the zero address.
    /// @param addr The address to check.
    modifier _0x1007a4(address _0x186818) {
        if (_0x186818 == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }

    /// @dev Validates that the caller is the staking contract.
    modifier _0xc250b2() {
        if (msg.sender != address(_0xdbc6e1)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier _0xa378d9() {
        bool _0xf56a9b = false;

        // Loop through all position manager configs to check if sender is a valid manager
        for (uint256 i = 0; i < _0x17d808; i++) {
            PositionManagerConfig memory _0xf8a554 = _0xe0aba6[i];

            if (msg.sender == _0xf8a554._0x1d6d81 && _0xf8a554._0x086ee9) {
                _0xf56a9b = true;
                break;
            }
        }

        if (!_0xf56a9b) {
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