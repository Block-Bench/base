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
    event ETHWithdrawnFromManager(uint256 indexed _0xa1d9f6, uint256 _0x7642ae);
    event ETHReturnedToStaking(uint256 _0x7642ae);
    event ETHAllocatedToManager(uint256 indexed _0xa1d9f6, uint256 _0x7642ae);
    event ETHReceivedFromStaking(uint256 _0x7642ae);
    event FeesCollected(uint256 _0x7642ae);
    event InterestClaimed(
        uint256 indexed _0xa1d9f6,
        uint256 _0x9933ae
    );
    event InterestToppedUp(
        uint256 _0x7642ae
    );
}

/**
 * @title LiquidityBuffer
 * @notice Manages liquidity allocation to various position managers for DeFi protocols
 */
contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;

    // ========================================= CONSTANTS =========================================

    bytes32 public constant LIQUIDITY_MANAGER_ROLE = _0x8ef8b2("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = _0x8ef8b2("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = _0x8ef8b2("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = _0x8ef8b2("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _0xfd58ec = 10_000;

    // ========================================= STATE =========================================

    /// @notice The staking contract to which the liquidity buffer accepts funds from and returns funds to.
    IStakingReturnsWrite public _0x4d8e5a;

    /// @notice The pauser contract.
    /// @dev Keeps the pause state across the protocol.
    IPauserRead public _0x3996e2;

    /// @notice Total number of position managers
    uint256 public _0x04243c;

    /// @notice Mapping from manager ID to position manager configuration
    mapping(uint256 => PositionManagerConfig) public _0xb921a2;

    /// @notice Mapping from manager ID to accounting information
    mapping(uint256 => PositionAccountant) public _0x516574;

    /// @notice Total funds received from staking contract
    uint256 public _0xe2b8c7;

    /// @notice Total funds returned to staking contract
    uint256 public _0x35c7a7;

    /// @notice Total allocated balance across all position managers
    uint256 public _0xa6ea61;

    /// @notice Total interest claimed from position managers
    uint256 public _0xbf8105;

    /// @notice Total interest topped up to staking contract
    uint256 public _0xc95aa9;

    /// @notice Total allocation capacity across all managers
    uint256 public _0xfbab03;

    /// @notice Cumulative drawdown amount
    uint256 public _0x697e52;

    /// @notice Default manager ID for deposit and allocation operations
    uint256 public _0x9afe27;

    /// @notice The address receiving protocol fees.
    address payable public _0x0a4c39;

    /// @notice The protocol fees in basis points (1/10000).
    uint16 public _0xb7718b;

    uint256 public _0xbd39c8;

    /// @notice Tracks pending interest available for top-up operations
    uint256 public _0x87747f;

    /// @notice Tracks pending principal available for operations
    uint256 public _0x86f130;

    /// @notice Controls whether to execute allocation logic in depositETH method
    bool public _0x1b3282;
    /// @notice Mapping from manager address to boolean indicating if it is registered
    mapping(address => bool) public _0x461b62;

    struct Init {
        address _0x532ec9;
        address _0x1ff12d;
        address _0x9d7122;
        address _0x648072;
        address _0x21e209;
        address payable _0x0a4c39;
        IStakingReturnsWrite _0xc16f40;
        IPauserRead _0x3996e2;
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
        _0x02c43f();
    }

    function _0xccb00c(Init memory _0x281fc4) external _0xdda540 {

        __AccessControlEnumerable_init();

        _0x9541e0(DEFAULT_ADMIN_ROLE, _0x281fc4._0x532ec9);
        _0x9541e0(LIQUIDITY_MANAGER_ROLE, _0x281fc4._0x1ff12d);
        _0x9541e0(POSITION_MANAGER_ROLE, _0x281fc4._0x9d7122);
        _0x9541e0(INTEREST_TOPUP_ROLE, _0x281fc4._0x648072);
        _0x9541e0(DRAWDOWN_MANAGER_ROLE, _0x281fc4._0x21e209);

        _0x4d8e5a = _0x281fc4._0xc16f40;
        _0x3996e2 = _0x281fc4._0x3996e2;
        _0x0a4c39 = _0x281fc4._0x0a4c39;
        _0x1b3282 = true;

        _0x9541e0(LIQUIDITY_MANAGER_ROLE, address(_0x4d8e5a));
    }

    // ========================================= VIEW FUNCTIONS =========================================

    function _0xd96209(uint256 _0xa1d9f6) public view returns (uint256) {
        PositionManagerConfig memory _0x254748 = _0xb921a2[_0xa1d9f6];
        // Get current underlying balance from position manager
        IPositionManager _0x5afd4a = IPositionManager(_0x254748._0x165bea);
        uint256 _0x308158 = _0x5afd4a._0xfee02a();

        // Calculate interest as: current balance - allocated balance
        PositionAccountant memory _0xd9be2d = _0x516574[_0xa1d9f6];

        if (_0x308158 > _0xd9be2d._0xad3e20) {
            return _0x308158 - _0xd9be2d._0xad3e20;
        }

        return 0;
    }

    function _0x429ab0() public view returns (uint256) {
        return _0xfbab03 - _0xa6ea61;
    }

    function _0x9e1352() public view returns (uint256) {
        return _0xe2b8c7 - _0x35c7a7;
    }

    function _0x695264() public view returns (uint256) {
        uint256 _0x3b849d = address(this).balance;

        // Loop through all position manager configs and get their balances
        // Note: This function makes external calls in a loop which can be gas-expensive
        // Consider caching balances or using a different approach for production
        for (uint256 i = 0; i < _0x04243c; i++) {
            PositionManagerConfig storage _0x254748 = _0xb921a2[i];
            if (_0x254748._0xe166a1) {
                IPositionManager _0x5afd4a = IPositionManager(_0x254748._0x165bea);
                uint256 _0xe7490a = _0x5afd4a._0xfee02a();
                _0x3b849d += _0xe7490a;
            }
        }

        return _0x3b849d;
    }

    // ========================================= ADMIN FUNCTIONS =========================================

    function _0xa35db6(
        address _0x165bea,
        uint256 _0x3ceec9
    ) external _0x332c69(POSITION_MANAGER_ROLE) returns (uint256 _0xa1d9f6) {
        if (_0x461b62[_0x165bea]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        _0xa1d9f6 = _0x04243c;
        _0x04243c++;

        _0xb921a2[_0xa1d9f6] = PositionManagerConfig({
            _0x165bea: _0x165bea,
            _0x3ceec9: _0x3ceec9,
            _0xe166a1: true
        });
        _0x516574[_0xa1d9f6] = PositionAccountant({
            _0xad3e20: 0,
            _0x977834: 0
        });
        _0x461b62[_0x165bea] = true;

        _0xfbab03 += _0x3ceec9;
        emit ProtocolConfigChanged(
            this._0xa35db6.selector,
            "addPositionManager(address,uint256)",
            abi._0xbc7e2a(_0x165bea, _0x3ceec9)
        );
    }

    function _0x52910f(
        uint256 _0xa1d9f6,
        uint256 _0x530970,
        bool _0xe166a1
    ) external _0x332c69(POSITION_MANAGER_ROLE) {
        if (_0xa1d9f6 >= _0x04243c) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0x254748 = _0xb921a2[_0xa1d9f6];

        if (_0x530970 < _0x516574[_0xa1d9f6]._0xad3e20) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        // Update total allocation capacity
        _0xfbab03 = _0xfbab03 - _0x254748._0x3ceec9 + _0x530970;

        _0x254748._0x3ceec9 = _0x530970;
        _0x254748._0xe166a1 = _0xe166a1;

        emit ProtocolConfigChanged(
            this._0x52910f.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi._0xbc7e2a(_0xa1d9f6, _0x530970, _0xe166a1)
        );
    }

    function _0xb3e4b4(uint256 _0xa1d9f6) external _0x332c69(POSITION_MANAGER_ROLE) {
        if (_0xa1d9f6 >= _0x04243c) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0x254748 = _0xb921a2[_0xa1d9f6];
        _0x254748._0xe166a1 = !_0x254748._0xe166a1;

        emit ProtocolConfigChanged(
            this._0xb3e4b4.selector,
            "togglePositionManagerStatus(uint256)",
            abi._0xbc7e2a(_0xa1d9f6)
        );
    }

    function _0xe5c12a(uint256 _0xefc623) external _0x332c69(DRAWDOWN_MANAGER_ROLE) {
        _0x697e52 = _0xefc623;

        emit ProtocolConfigChanged(
            this._0xe5c12a.selector,
            "setCumulativeDrawdown(uint256)",
            abi._0xbc7e2a(_0xefc623)
        );
    }

    function _0x70970c(uint256 _0x1f24b2) external _0x332c69(POSITION_MANAGER_ROLE) {
        if (_0x1f24b2 >= _0x04243c) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!_0xb921a2[_0x1f24b2]._0xe166a1) {
            revert LiquidityBuffer__ManagerInactive();
        }

        _0x9afe27 = _0x1f24b2;

        emit ProtocolConfigChanged(
            this._0x70970c.selector,
            "setDefaultManagerId(uint256)",
            abi._0xbc7e2a(_0x1f24b2)
        );
    }

    /// @notice Sets the fees basis points.
    /// @param newBasisPoints The new fees basis points.
    function _0x17c208(uint16 _0xdca10b) external _0x332c69(POSITION_MANAGER_ROLE) {
        if (_0xdca10b > _0xfd58ec) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        _0xb7718b = _0xdca10b;
        emit ProtocolConfigChanged(
            this._0x17c208.selector, "setFeeBasisPoints(uint16)", abi._0xbc7e2a(_0xdca10b)
        );
    }

     /// @notice Sets the fees receiver wallet for the protocol.
    /// @param newReceiver The new fees receiver wallet.
    function _0xb6abb8(address payable _0xa52eb9)
        external
        _0x332c69(POSITION_MANAGER_ROLE)
        _0x9efee8(_0xa52eb9)
    {
        _0x0a4c39 = _0xa52eb9;
        emit ProtocolConfigChanged(this._0xb6abb8.selector, "setFeesReceiver(address)", abi._0xbc7e2a(_0xa52eb9));
    }

    /// @notice Sets whether to execute allocation logic in depositETH method.
    /// @param executeAllocation Whether to execute allocation logic.
    function _0xfdfc5c(bool _0xe7ba37) external _0x332c69(POSITION_MANAGER_ROLE) {
        _0x1b3282 = _0xe7ba37;
        emit ProtocolConfigChanged(this._0xfdfc5c.selector, "setShouldExecuteAllocation(bool)", abi._0xbc7e2a(_0xe7ba37));
    }

    // ========================================= LIQUIDITY MANAGEMENT =========================================

    function _0x9dc560() external payable _0x332c69(LIQUIDITY_MANAGER_ROLE) {
        if (_0x3996e2._0xcbc9bb()) revert LiquidityBuffer__Paused();
        _0x9ac58d(msg.value);
        if (_0x1b3282) {
            _0x0482ee(_0x9afe27, msg.value);
        }
    }

    function _0x62d802(uint256 _0xa1d9f6, uint256 _0x7642ae) external _0x332c69(LIQUIDITY_MANAGER_ROLE) {
        _0x26ece1(_0xa1d9f6, _0x7642ae);
        _0xc23a68(_0x7642ae);
    }

    function _0x2870c8(uint256 _0xa1d9f6, uint256 _0x7642ae) external _0x332c69(LIQUIDITY_MANAGER_ROLE) {
        _0x0482ee(_0xa1d9f6, _0x7642ae);
    }

    function _0xff009e(uint256 _0xa1d9f6, uint256 _0x7642ae) external _0x332c69(LIQUIDITY_MANAGER_ROLE) {
        _0x26ece1(_0xa1d9f6, _0x7642ae);
    }

    function _0x9cffa7(uint256 _0x7642ae) external _0x332c69(LIQUIDITY_MANAGER_ROLE) {
        _0xc23a68(_0x7642ae);
    }

    function _0x280195() external payable _0x2861d2 {
        // This function receives ETH from position managers
        // The ETH is already in the contract balance, no additional processing needed
    }

    // ========================================= INTEREST MANAGEMENT =========================================

    function _0xdfc23b(uint256 _0xa1d9f6, uint256 _0x1b9643) external _0x332c69(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x7642ae = _0xaa0bfd(_0xa1d9f6);
        if (_0x7642ae < _0x1b9643) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return _0x7642ae;
    }

    function _0x50da36(uint256 _0x7642ae) external _0x332c69(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < _0x7642ae) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0x2aeba8(_0x7642ae);
        return _0x7642ae;
    }

    function _0x6787d4(uint256 _0xa1d9f6, uint256 _0x1b9643) external _0x332c69(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x7642ae = _0xaa0bfd(_0xa1d9f6);
        if (_0x7642ae < _0x1b9643) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0x2aeba8(_0x7642ae);

        return _0x7642ae;
    }

    // ========================================= INTERNAL FUNCTIONS =========================================

    function _0x2aeba8(uint256 _0x7642ae) internal {
        if (_0x3996e2._0xcbc9bb()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x7642ae > _0x87747f) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        _0x87747f -= _0x7642ae;
        uint256 _0x50bea9 = Math._0x1ab0cd(_0xb7718b, _0x7642ae, _0xfd58ec);
        uint256 _0x913715 = _0x7642ae - _0x50bea9;
        _0x4d8e5a._0x3dfc24{value: _0x913715}();
        _0xc95aa9 += _0x913715;
        emit InterestToppedUp(_0x913715);

        if (_0x50bea9 > 0) {
            Address._0xf49b97(_0x0a4c39, _0x50bea9);
            _0xbd39c8 += _0x50bea9;
            emit FeesCollected(_0x50bea9);
        }
    }

    function _0xaa0bfd(uint256 _0xa1d9f6) internal returns (uint256) {
        if (_0x3996e2._0xcbc9bb()) {
            revert LiquidityBuffer__Paused();
        }
        // Get interest amount
        uint256 _0x9933ae = _0xd96209(_0xa1d9f6);

        if (_0x9933ae > 0) {
            PositionManagerConfig memory _0x254748 = _0xb921a2[_0xa1d9f6];

            // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
            _0x516574[_0xa1d9f6]._0x977834 += _0x9933ae;
            _0xbf8105 += _0x9933ae;
            _0x87747f += _0x9933ae;
            emit InterestClaimed(_0xa1d9f6, _0x9933ae);

            // Withdraw interest from position manager AFTER state updates
            IPositionManager _0x5afd4a = IPositionManager(_0x254748._0x165bea);
            _0x5afd4a._0xc7f3a5(_0x9933ae);
        } else {
            emit InterestClaimed(_0xa1d9f6, _0x9933ae);
        }

        return _0x9933ae;
    }

    function _0x26ece1(uint256 _0xa1d9f6, uint256 _0x7642ae) internal {
        if (_0x3996e2._0xcbc9bb()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0xa1d9f6 >= _0x04243c) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory _0x254748 = _0xb921a2[_0xa1d9f6];
        if (!_0x254748._0xe166a1) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage _0xd9be2d = _0x516574[_0xa1d9f6];

        // Check sufficient allocation
        if (_0x7642ae > _0xd9be2d._0xad3e20) {
            revert LiquidityBuffer__InsufficientAllocation();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0xd9be2d._0xad3e20 -= _0x7642ae;
        _0xa6ea61 -= _0x7642ae;
        _0x86f130 += _0x7642ae;
        emit ETHWithdrawnFromManager(_0xa1d9f6, _0x7642ae);

        // Call position manager to withdraw AFTER state updates
        IPositionManager _0x5afd4a = IPositionManager(_0x254748._0x165bea);
        _0x5afd4a._0xc7f3a5(_0x7642ae);
    }

    function _0xc23a68(uint256 _0x7642ae) internal {
        if (_0x3996e2._0xcbc9bb()) {
            revert LiquidityBuffer__Paused();
        }

        // Validate staking contract is set and not zero address
        if (address(_0x4d8e5a) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (_0x7642ae > _0x86f130) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x35c7a7 += _0x7642ae;
        _0x86f130 -= _0x7642ae;
        emit ETHReturnedToStaking(_0x7642ae);

        // Send ETH to trusted staking contract AFTER state updates
        // Note: stakingContract is a trusted contract set during initialization
        _0x4d8e5a._0x0a19f3{value: _0x7642ae}();
    }

    function _0x0482ee(uint256 _0xa1d9f6, uint256 _0x7642ae) internal {
        if (_0x3996e2._0xcbc9bb()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x7642ae > _0x86f130) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (_0xa1d9f6 >= _0x04243c) revert LiquidityBuffer__ManagerNotFound();
        // check available balance
        if (address(this).balance < _0x7642ae) revert LiquidityBuffer__InsufficientBalance();

        // check position manager is active
        PositionManagerConfig memory _0x254748 = _0xb921a2[_0xa1d9f6];
        if (!_0x254748._0xe166a1) revert LiquidityBuffer__ManagerInactive();
        // check allocation cap
        PositionAccountant storage _0xd9be2d = _0x516574[_0xa1d9f6];
        if (_0xd9be2d._0xad3e20 + _0x7642ae > _0x254748._0x3ceec9) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0xd9be2d._0xad3e20 += _0x7642ae;
        _0xa6ea61 += _0x7642ae;
        _0x86f130 -= _0x7642ae;
        emit ETHAllocatedToManager(_0xa1d9f6, _0x7642ae);

        // deposit to position manager AFTER state updates
        IPositionManager _0x5afd4a = IPositionManager(_0x254748._0x165bea);
        _0x5afd4a._0x55e3c2{value: _0x7642ae}(0);
    }

    function _0x9ac58d(uint256 _0x7642ae) internal {
        _0xe2b8c7 += _0x7642ae;
        _0x86f130 += _0x7642ae;
        emit ETHReceivedFromStaking(_0x7642ae);
    }

    /// @notice Ensures that the given address is not the zero address.
    /// @param addr The address to check.
    modifier _0x9efee8(address _0xdcca83) {
        if (_0xdcca83 == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }

    /// @dev Validates that the caller is the staking contract.
    modifier _0xff4ee2() {
        if (msg.sender != address(_0x4d8e5a)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier _0x2861d2() {
        bool _0x0aab08 = false;

        // Loop through all position manager configs to check if sender is a valid manager
        for (uint256 i = 0; i < _0x04243c; i++) {
            PositionManagerConfig memory _0x254748 = _0xb921a2[i];

            if (msg.sender == _0x254748._0x165bea && _0x254748._0xe166a1) {
                _0x0aab08 = true;
                break;
            }
        }

        if (!_0x0aab08) {
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