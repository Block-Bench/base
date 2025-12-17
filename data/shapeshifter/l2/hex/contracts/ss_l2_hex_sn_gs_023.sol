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
    event ETHWithdrawnFromManager(uint256 indexed _0x125a90, uint256 _0x01788f);
    event ETHReturnedToStaking(uint256 _0x01788f);
    event ETHAllocatedToManager(uint256 indexed _0x125a90, uint256 _0x01788f);
    event ETHReceivedFromStaking(uint256 _0x01788f);
    event FeesCollected(uint256 _0x01788f);
    event InterestClaimed(
        uint256 indexed _0x125a90,
        uint256 _0xe3caa0
    );
    event InterestToppedUp(
        uint256 _0x01788f
    );
}

/**
 * @title LiquidityBuffer
 * @notice Manages liquidity allocation to various position managers for DeFi protocols
 */
contract LiquidityBuffer is Initializable, AccessControlEnumerableUpgradeable, ILiquidityBuffer, LiquidityBufferEvents, ProtocolEvents {
    using Address for address;

    // ========================================= CONSTANTS =========================================

    bytes32 public constant LIQUIDITY_MANAGER_ROLE = _0x84bd24("LIQUIDITY_MANAGER_ROLE");
    bytes32 public constant POSITION_MANAGER_ROLE = _0x84bd24("POSITION_MANAGER_ROLE");
    bytes32 public constant INTEREST_TOPUP_ROLE = _0x84bd24("INTEREST_TOPUP_ROLE");
    bytes32 public constant DRAWDOWN_MANAGER_ROLE = _0x84bd24("DRAWDOWN_MANAGER_ROLE");

    uint16 internal constant _0xabe5f4 = 10_000;

    // ========================================= STATE =========================================

    /// @notice The staking contract to which the liquidity buffer accepts funds from and returns funds to.
    IStakingReturnsWrite public _0x530446;

    /// @notice The pauser contract.
    /// @dev Keeps the pause state across the protocol.
    IPauserRead public _0x161e56;

    /// @notice Total number of position managers
    uint256 public _0x17372c;

    /// @notice Mapping from manager ID to position manager configuration
    mapping(uint256 => PositionManagerConfig) public _0xd88f6e;

    /// @notice Mapping from manager ID to accounting information
    mapping(uint256 => PositionAccountant) public _0xa32ae8;

    /// @notice Total funds received from staking contract
    uint256 public _0xae2ece;

    /// @notice Total funds returned to staking contract
    uint256 public _0xbbb561;

    /// @notice Total allocated balance across all position managers
    uint256 public _0xc3d4b7;

    /// @notice Total interest claimed from position managers
    uint256 public _0x7c5faa;

    /// @notice Total interest topped up to staking contract
    uint256 public _0xed511b;

    /// @notice Total allocation capacity across all managers
    uint256 public _0xa11c92;

    /// @notice Cumulative drawdown amount
    uint256 public _0x48cb83;

    /// @notice Default manager ID for deposit and allocation operations
    uint256 public _0xb62c1c;

    /// @notice The address receiving protocol fees.
    address payable public _0x407052;

    /// @notice The protocol fees in basis points (1/10000).
    uint16 public _0x6b2b8e;

    uint256 public _0x467ed7;

    /// @notice Tracks pending interest available for top-up operations
    uint256 public _0xc731b9;

    /// @notice Tracks pending principal available for operations
    uint256 public _0x45575e;

    /// @notice Controls whether to execute allocation logic in depositETH method
    bool public _0x753b9f;
    /// @notice Mapping from manager address to boolean indicating if it is registered
    mapping(address => bool) public _0x7c8185;

    struct Init {
        address _0xbc00b3;
        address _0x155f29;
        address _0x32b6f6;
        address _0x801a10;
        address _0x298cfd;
        address payable _0x407052;
        IStakingReturnsWrite _0x0cdb09;
        IPauserRead _0x161e56;
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
        _0xb06df2();
    }

    function _0x129766(Init memory _0xd6e174) external _0x65be36 {

        __AccessControlEnumerable_init();

        _0x2f5def(DEFAULT_ADMIN_ROLE, _0xd6e174._0xbc00b3);
        _0x2f5def(LIQUIDITY_MANAGER_ROLE, _0xd6e174._0x155f29);
        _0x2f5def(POSITION_MANAGER_ROLE, _0xd6e174._0x32b6f6);
        _0x2f5def(INTEREST_TOPUP_ROLE, _0xd6e174._0x801a10);
        _0x2f5def(DRAWDOWN_MANAGER_ROLE, _0xd6e174._0x298cfd);

        _0x530446 = _0xd6e174._0x0cdb09;
        _0x161e56 = _0xd6e174._0x161e56;
        _0x407052 = _0xd6e174._0x407052;
        _0x753b9f = true;

        _0x2f5def(LIQUIDITY_MANAGER_ROLE, address(_0x530446));
    }

    // ========================================= VIEW FUNCTIONS =========================================

    function _0xf1baf0(uint256 _0x125a90) public view returns (uint256) {
        PositionManagerConfig memory _0xa218ae = _0xd88f6e[_0x125a90];
        // Get current underlying balance from position manager
        IPositionManager _0x7d3d1c = IPositionManager(_0xa218ae._0x47f4e1);
        uint256 _0x044b98 = _0x7d3d1c._0x592080();

        // Calculate interest as: current balance - allocated balance
        PositionAccountant memory _0x72a46d = _0xa32ae8[_0x125a90];

        if (_0x044b98 > _0x72a46d._0x9bc38b) {
            return _0x044b98 - _0x72a46d._0x9bc38b;
        }

        return 0;
    }

    function _0x3e90c5() public view returns (uint256) {
        return _0xa11c92 - _0xc3d4b7;
    }

    function _0xf0f2da() public view returns (uint256) {
        return _0xae2ece - _0xbbb561;
    }

    function _0xb834f4() public view returns (uint256) {
        uint256 _0x45c1f5 = address(this).balance;

        // Loop through all position manager configs and get their balances
        // Note: This function makes external calls in a loop which can be gas-expensive
        // Consider caching balances or using a different approach for production
        for (uint256 i = 0; i < _0x17372c; i++) {
            PositionManagerConfig storage _0xa218ae = _0xd88f6e[i];
            if (_0xa218ae._0x67c8f7) {
                IPositionManager _0x7d3d1c = IPositionManager(_0xa218ae._0x47f4e1);
                uint256 _0x4f8c3e = _0x7d3d1c._0x592080();
                _0x45c1f5 += _0x4f8c3e;
            }
        }

        return _0x45c1f5;
    }

    // ========================================= ADMIN FUNCTIONS =========================================

    function _0xcc8630(
        address _0x47f4e1,
        uint256 _0x3126b6
    ) external _0x7b751d(POSITION_MANAGER_ROLE) returns (uint256 _0x125a90) {
        if (_0x7c8185[_0x47f4e1]) revert LiquidityBuffer__ManagerAlreadyRegistered();
        _0x125a90 = _0x17372c;
        _0x17372c++;

        _0xd88f6e[_0x125a90] = PositionManagerConfig({
            _0x47f4e1: _0x47f4e1,
            _0x3126b6: _0x3126b6,
            _0x67c8f7: true
        });
        _0xa32ae8[_0x125a90] = PositionAccountant({
            _0x9bc38b: 0,
            _0x2f9abd: 0
        });
        _0x7c8185[_0x47f4e1] = true;

        _0xa11c92 += _0x3126b6;
        emit ProtocolConfigChanged(
            this._0xcc8630.selector,
            "addPositionManager(address,uint256)",
            abi._0xa1d743(_0x47f4e1, _0x3126b6)
        );
    }

    function _0x1ed670(
        uint256 _0x125a90,
        uint256 _0xed6297,
        bool _0x67c8f7
    ) external _0x7b751d(POSITION_MANAGER_ROLE) {
        if (_0x125a90 >= _0x17372c) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0xa218ae = _0xd88f6e[_0x125a90];

        if (_0xed6297 < _0xa32ae8[_0x125a90]._0x9bc38b) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        // Update total allocation capacity
        _0xa11c92 = _0xa11c92 - _0xa218ae._0x3126b6 + _0xed6297;

        _0xa218ae._0x3126b6 = _0xed6297;
        _0xa218ae._0x67c8f7 = _0x67c8f7;

        emit ProtocolConfigChanged(
            this._0x1ed670.selector,
            "updatePositionManager(uint256,uint256,bool)",
            abi._0xa1d743(_0x125a90, _0xed6297, _0x67c8f7)
        );
    }

    function _0x65c333(uint256 _0x125a90) external _0x7b751d(POSITION_MANAGER_ROLE) {
        if (_0x125a90 >= _0x17372c) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        PositionManagerConfig storage _0xa218ae = _0xd88f6e[_0x125a90];
        _0xa218ae._0x67c8f7 = !_0xa218ae._0x67c8f7;

        emit ProtocolConfigChanged(
            this._0x65c333.selector,
            "togglePositionManagerStatus(uint256)",
            abi._0xa1d743(_0x125a90)
        );
    }

    function _0x8a289d(uint256 _0x572cf1) external _0x7b751d(DRAWDOWN_MANAGER_ROLE) {
        _0x48cb83 = _0x572cf1;

        emit ProtocolConfigChanged(
            this._0x8a289d.selector,
            "setCumulativeDrawdown(uint256)",
            abi._0xa1d743(_0x572cf1)
        );
    }

    function _0x8c375e(uint256 _0x5cb7d2) external _0x7b751d(POSITION_MANAGER_ROLE) {
        if (_0x5cb7d2 >= _0x17372c) {
            revert LiquidityBuffer__ManagerNotFound();
        }

        if (!_0xd88f6e[_0x5cb7d2]._0x67c8f7) {
            revert LiquidityBuffer__ManagerInactive();
        }

        _0xb62c1c = _0x5cb7d2;

        emit ProtocolConfigChanged(
            this._0x8c375e.selector,
            "setDefaultManagerId(uint256)",
            abi._0xa1d743(_0x5cb7d2)
        );
    }

    /// @notice Sets the fees basis points.
    /// @param newBasisPoints The new fees basis points.
    function _0x374063(uint16 _0x7f7408) external _0x7b751d(POSITION_MANAGER_ROLE) {
        if (_0x7f7408 > _0xabe5f4) {
            revert LiquidityBuffer__InvalidConfiguration();
        }

        _0x6b2b8e = _0x7f7408;
        emit ProtocolConfigChanged(
            this._0x374063.selector, "setFeeBasisPoints(uint16)", abi._0xa1d743(_0x7f7408)
        );
    }

     /// @notice Sets the fees receiver wallet for the protocol.
    /// @param newReceiver The new fees receiver wallet.
    function _0xb13da6(address payable _0xdc9a76)
        external
        _0x7b751d(POSITION_MANAGER_ROLE)
        _0xc8a9c9(_0xdc9a76)
    {
        _0x407052 = _0xdc9a76;
        emit ProtocolConfigChanged(this._0xb13da6.selector, "setFeesReceiver(address)", abi._0xa1d743(_0xdc9a76));
    }

    /// @notice Sets whether to execute allocation logic in depositETH method.
    /// @param executeAllocation Whether to execute allocation logic.
    function _0xd2b6bf(bool _0xb9c8aa) external _0x7b751d(POSITION_MANAGER_ROLE) {
        _0x753b9f = _0xb9c8aa;
        emit ProtocolConfigChanged(this._0xd2b6bf.selector, "setShouldExecuteAllocation(bool)", abi._0xa1d743(_0xb9c8aa));
    }

    // ========================================= LIQUIDITY MANAGEMENT =========================================

    function _0x5803a3() external payable _0x7b751d(LIQUIDITY_MANAGER_ROLE) {
        if (_0x161e56._0x7c4d5e()) revert LiquidityBuffer__Paused();
        _0x3e05bd(msg.value);
        if (_0x753b9f) {
            _0x99b43d(_0xb62c1c, msg.value);
        }
    }

    function _0x5bdea8(uint256 _0x125a90, uint256 _0x01788f) external _0x7b751d(LIQUIDITY_MANAGER_ROLE) {
        _0x08bd4e(_0x125a90, _0x01788f);
        _0x32b726(_0x01788f);
    }

    function _0x839718(uint256 _0x125a90, uint256 _0x01788f) external _0x7b751d(LIQUIDITY_MANAGER_ROLE) {
        _0x99b43d(_0x125a90, _0x01788f);
    }

    function _0x88ec6e(uint256 _0x125a90, uint256 _0x01788f) external _0x7b751d(LIQUIDITY_MANAGER_ROLE) {
        _0x08bd4e(_0x125a90, _0x01788f);
    }

    function _0x538fb0(uint256 _0x01788f) external _0x7b751d(LIQUIDITY_MANAGER_ROLE) {
        _0x32b726(_0x01788f);
    }

    function _0x9d0efe() external payable _0x948289 {
        // This function receives ETH from position managers
        // The ETH is already in the contract balance, no additional processing needed
    }

    // ========================================= INTEREST MANAGEMENT =========================================

    function _0x304d7f(uint256 _0x125a90, uint256 _0xba5b5d) external _0x7b751d(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x01788f = _0xa87473(_0x125a90);
        if (_0x01788f < _0xba5b5d) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        return _0x01788f;
    }

    function _0x18a0d0(uint256 _0x01788f) external _0x7b751d(INTEREST_TOPUP_ROLE) returns (uint256) {
        if (address(this).balance < _0x01788f) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0xce66d3(_0x01788f);
        return _0x01788f;
    }

    function _0x3b8b73(uint256 _0x125a90, uint256 _0xba5b5d) external _0x7b751d(INTEREST_TOPUP_ROLE) returns (uint256) {
        uint256 _0x01788f = _0xa87473(_0x125a90);
        if (_0x01788f < _0xba5b5d) {
            revert LiquidityBuffer__InsufficientBalance();
        }
        _0xce66d3(_0x01788f);

        return _0x01788f;
    }

    // ========================================= INTERNAL FUNCTIONS =========================================

    function _0xce66d3(uint256 _0x01788f) internal {
        if (_0x161e56._0x7c4d5e()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x01788f > _0xc731b9) {
            revert LiquidityBuffer__ExceedsPendingInterest();
        }
        _0xc731b9 -= _0x01788f;
        uint256 _0xe52afa = Math._0x003c07(_0x6b2b8e, _0x01788f, _0xabe5f4);
        uint256 _0x4d44c6 = _0x01788f - _0xe52afa;
        _0x530446._0x41d886{value: _0x4d44c6}();
        _0xed511b += _0x4d44c6;
        emit InterestToppedUp(_0x4d44c6);

        if (_0xe52afa > 0) {
            Address._0x1b7cda(_0x407052, _0xe52afa);
            _0x467ed7 += _0xe52afa;
            emit FeesCollected(_0xe52afa);
        }
    }

    function _0xa87473(uint256 _0x125a90) internal returns (uint256) {
        if (_0x161e56._0x7c4d5e()) {
            revert LiquidityBuffer__Paused();
        }
        // Get interest amount
        uint256 _0xe3caa0 = _0xf1baf0(_0x125a90);

        if (_0xe3caa0 > 0) {
            PositionManagerConfig memory _0xa218ae = _0xd88f6e[_0x125a90];

            // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
            _0xa32ae8[_0x125a90]._0x2f9abd += _0xe3caa0;
            _0x7c5faa += _0xe3caa0;
            _0xc731b9 += _0xe3caa0;
            emit InterestClaimed(_0x125a90, _0xe3caa0);

            // Withdraw interest from position manager AFTER state updates
            IPositionManager _0x7d3d1c = IPositionManager(_0xa218ae._0x47f4e1);
            _0x7d3d1c._0xbb760e(_0xe3caa0);
        } else {
            emit InterestClaimed(_0x125a90, _0xe3caa0);
        }

        return _0xe3caa0;
    }

    function _0x08bd4e(uint256 _0x125a90, uint256 _0x01788f) internal {
        if (_0x161e56._0x7c4d5e()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x125a90 >= _0x17372c) revert LiquidityBuffer__ManagerNotFound();
        PositionManagerConfig memory _0xa218ae = _0xd88f6e[_0x125a90];
        if (!_0xa218ae._0x67c8f7) revert LiquidityBuffer__ManagerInactive();
        PositionAccountant storage _0x72a46d = _0xa32ae8[_0x125a90];

        // Check sufficient allocation
        if (_0x01788f > _0x72a46d._0x9bc38b) {
            revert LiquidityBuffer__InsufficientAllocation();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x72a46d._0x9bc38b -= _0x01788f;
        _0xc3d4b7 -= _0x01788f;
        _0x45575e += _0x01788f;
        emit ETHWithdrawnFromManager(_0x125a90, _0x01788f);

        // Call position manager to withdraw AFTER state updates
        IPositionManager _0x7d3d1c = IPositionManager(_0xa218ae._0x47f4e1);
        _0x7d3d1c._0xbb760e(_0x01788f);
    }

    function _0x32b726(uint256 _0x01788f) internal {
        if (_0x161e56._0x7c4d5e()) {
            revert LiquidityBuffer__Paused();
        }

        // Validate staking contract is set and not zero address
        if (address(_0x530446) == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }

        if (_0x01788f > _0x45575e) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0xbbb561 += _0x01788f;
        _0x45575e -= _0x01788f;
        emit ETHReturnedToStaking(_0x01788f);

        // Send ETH to trusted staking contract AFTER state updates
        // Note: stakingContract is a trusted contract set during initialization
        _0x530446._0x770714{value: _0x01788f}();
    }

    function _0x99b43d(uint256 _0x125a90, uint256 _0x01788f) internal {
        if (_0x161e56._0x7c4d5e()) {
            revert LiquidityBuffer__Paused();
        }
        if (_0x01788f > _0x45575e) {
            revert LiquidityBuffer__ExceedsPendingPrincipal();
        }

        if (_0x125a90 >= _0x17372c) revert LiquidityBuffer__ManagerNotFound();
        // check available balance
        if (address(this).balance < _0x01788f) revert LiquidityBuffer__InsufficientBalance();

        // check position manager is active
        PositionManagerConfig memory _0xa218ae = _0xd88f6e[_0x125a90];
        if (!_0xa218ae._0x67c8f7) revert LiquidityBuffer__ManagerInactive();
        // check allocation cap
        PositionAccountant storage _0x72a46d = _0xa32ae8[_0x125a90];
        if (_0x72a46d._0x9bc38b + _0x01788f > _0xa218ae._0x3126b6) {
            revert LiquidityBuffer__ExceedsAllocationCap();
        }

        // Update accounting BEFORE external call (Checks-Effects-Interactions pattern)
        _0x72a46d._0x9bc38b += _0x01788f;
        _0xc3d4b7 += _0x01788f;
        _0x45575e -= _0x01788f;
        emit ETHAllocatedToManager(_0x125a90, _0x01788f);

        // deposit to position manager AFTER state updates
        IPositionManager _0x7d3d1c = IPositionManager(_0xa218ae._0x47f4e1);
        _0x7d3d1c._0x7f121f{value: _0x01788f}(0);
    }

    function _0x3e05bd(uint256 _0x01788f) internal {
        _0xae2ece += _0x01788f;
        _0x45575e += _0x01788f;
        emit ETHReceivedFromStaking(_0x01788f);
    }

    /// @notice Ensures that the given address is not the zero address.
    /// @param addr The address to check.
    modifier _0xc8a9c9(address _0x254f3d) {
        if (_0x254f3d == address(0)) {
            revert LiquidityBuffer__ZeroAddress();
        }
        _;
    }

    /// @dev Validates that the caller is the staking contract.
    modifier _0x5733cb() {
        if (msg.sender != address(_0x530446)) {
            revert LiquidityBuffer__NotStakingContract();
        }
        _;
    }

    modifier _0x948289() {
        bool _0xfb674c = false;

        // Loop through all position manager configs to check if sender is a valid manager
        for (uint256 i = 0; i < _0x17372c; i++) {
            PositionManagerConfig memory _0xa218ae = _0xd88f6e[i];

            if (msg.sender == _0xa218ae._0x47f4e1 && _0xa218ae._0x67c8f7) {
                _0xfb674c = true;
                break;
            }
        }

        if (!_0xfb674c) {
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