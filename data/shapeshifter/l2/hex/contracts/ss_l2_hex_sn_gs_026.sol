// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Initializable} from "openzeppelin-upgradeable/proxy/utils/Initializable.sol";
import {AccessControlEnumerableUpgradeable} from
    "openzeppelin-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import {SafeERC20} from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {IPool} from "aave-v3/interfaces/IPool.sol";
import {DataTypes} from "aave-v3/protocol/libraries/types/DataTypes.sol";
import {IPositionManager} from './interfaces/IPositionManager.sol';
import {IWETH} from "./interfaces/IWETH.sol";
import {ILiquidityBuffer} from "../liquidityBuffer/interfaces/ILiquidityBuffer.sol";

/**
 * @title PositionManager
 * @dev Position manager with role-based access control
 * inspired by WrappedTokenGatewayV3 0xd01607c3c5ecaba394d8be377a08590149325722
 */
contract PositionManager is Initializable, AccessControlEnumerableUpgradeable, IPositionManager {
    using SafeERC20 for IERC20;

    // Role definitions
    bytes32 public constant EXECUTOR_ROLE = _0xdc288e("EXECUTOR_ROLE");
    bytes32 public constant MANAGER_ROLE = _0xdc288e("MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = _0xdc288e("EMERGENCY_ROLE");

    // State variables
    IPool public _0x5ace4c;
    IWETH public _0x3aaae6;
    ILiquidityBuffer public _0xba5ed6;

    /// @notice Configuration for contract initialization.
    struct Init {
        address _0x8bc99c;
        address _0xb84975;
        ILiquidityBuffer _0xba5ed6;
        IWETH _0x3aaae6;
        IPool _0x5ace4c;
    }

    // Events
    event Deposit(address indexed _0x7b11f5, uint _0xee747e, uint _0x45e65c);
    event Withdraw(address indexed _0x7b11f5, uint _0xee747e);
    event Borrow(address indexed _0x7b11f5, uint _0xee747e, uint _0x8b0149);
    event Repay(address indexed _0x7b11f5, uint _0xee747e, uint _0x8b0149);
    event SetUserEMode(address indexed _0x7b11f5, uint8 _0x61deac);

    constructor() {
        _0x3fe7e5();
    }

    function _0x75d91d(Init memory _0x071d6c) external _0xb9d2cc {
        __AccessControlEnumerable_init();

        _0x3aaae6 = _0x071d6c._0x3aaae6;
        _0x5ace4c = _0x071d6c._0x5ace4c;
        _0xba5ed6 = _0x071d6c._0xba5ed6;

        // Set up roles
        _0xb780ce(DEFAULT_ADMIN_ROLE, _0x071d6c._0x8bc99c);
        _0xb780ce(MANAGER_ROLE, _0x071d6c._0xb84975);
        _0xb780ce(EXECUTOR_ROLE, address(_0x071d6c._0xba5ed6));

        // Approve pool to spend WETH
        _0x3aaae6._0x10f0b1(address(_0x5ace4c), type(uint256)._0x0b5615);
    }

    // IPositionManager Implementation

    function _0x8e8e0f(uint16 _0x3baecd) external payable override _0xa9e00a(EXECUTOR_ROLE) {
        if (msg.value > 0) {
            // Wrap ETH to WETH
            _0x3aaae6._0x8e8e0f{value: msg.value}();

            // Deposit WETH into pool
            _0x5ace4c._0x8e8e0f(address(_0x3aaae6), msg.value, address(this), _0x3baecd);

            emit Deposit(msg.sender, msg.value, msg.value);
        }
    }

    function _0xa0b4ff(uint256 _0xee747e) external override _0xa9e00a(EXECUTOR_ROLE) {
        require(_0xee747e > 0, 'Invalid _0xee747e');

        // Get aWETH token
        IERC20 _0x4f48a7 = IERC20(_0x5ace4c._0x3c389c(address(_0x3aaae6)));
        uint256 _0xb1b6c5 = _0x4f48a7._0xdc8b3e(address(this));

        uint256 _0x34c04c = _0xee747e;
        if (_0xee747e == type(uint256)._0x0b5615) {
            _0x34c04c = _0xb1b6c5;
        }

        require(_0x34c04c <= _0xb1b6c5, 'Insufficient balance');

        // Withdraw from pool
        _0x5ace4c._0xa0b4ff(address(_0x3aaae6), _0x34c04c, address(this));

        // Unwrap WETH to ETH
        _0x3aaae6._0xa0b4ff(_0x34c04c);

        // Transfer ETH to LiquidityBuffer via receiveETHFromPositionManager
        _0xba5ed6._0xf57c97{value: _0x34c04c}();

        emit Withdraw(msg.sender, _0x34c04c);
    }

    function _0x89cc10() external view returns (uint256) {
        IERC20 _0x4f48a7 = IERC20(_0x5ace4c._0x3c389c(address(_0x3aaae6)));
        return _0x4f48a7._0xdc8b3e(address(this));
    }

    function _0xbd27a7(uint8 _0x61deac) external override _0xa9e00a(MANAGER_ROLE) {
        // Set user E-mode category
        _0x5ace4c._0xbd27a7(_0x61deac);

        emit SetUserEMode(msg.sender, _0x61deac);
    }
    function _0x8e0a81(address _0x585f8c, address _0x854122, uint256 _0x09fe71) external override _0xa9e00a(MANAGER_ROLE) {
        IERC20(_0x585f8c)._0x414a2a(_0x854122, _0x09fe71);
    }

    function _0x6b24dc(address _0x585f8c, address _0x854122) external override _0xa9e00a(MANAGER_ROLE) {
        IERC20(_0x585f8c)._0x414a2a(_0x854122, 0);
    }

    // Additional helper functions

    function _0xecadf2() external view returns (uint256) {
        address _0xaa8323 = _0x5ace4c._0x4151f8(address(_0x3aaae6));
        return IERC20(_0xaa8323)._0xdc8b3e(address(this));
    }

    function _0xb4eb7d() external view returns (uint256) {
        IERC20 _0x4f48a7 = IERC20(_0x5ace4c._0x3c389c(address(_0x3aaae6)));
        return _0x4f48a7._0xdc8b3e(address(this));
    }

    function _0x46115b() external view returns (uint256) {
        return _0x5ace4c._0x46115b(address(this));
    }

    function _0x32cf89(address _0x100116, bool _0xc2e5c3) external _0xa9e00a(MANAGER_ROLE) {
        _0x5ace4c._0x32cf89(_0x100116, _0xc2e5c3);
    }

    function _0x2ae213(address _0x754cf0) external _0xa9e00a(MANAGER_ROLE) {
        _0x89d290(EXECUTOR_ROLE, address(_0xba5ed6));
        _0xb780ce(EXECUTOR_ROLE, _0x754cf0);
        _0xba5ed6 = ILiquidityBuffer(_0x754cf0);
    }

    /**
    * @dev transfer ERC20 from the utility contract, for ERC20 recovery in case of stuck tokens due
    * direct transfers to the contract address.
    * @param token token to transfer
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function _0x467184(address _0x585f8c, address _0xb9b305, uint256 _0xee747e) external _0xa9e00a(EMERGENCY_ROLE) {
        IERC20(_0x585f8c)._0x8c0c4e(_0xb9b305, _0xee747e);
    }

    /**
    * @dev transfer native Ether from the utility contract, for native Ether recovery in case of stuck Ether
    * due to selfdestructs or ether transfers to the pre-computed contract address before deployment.
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function _0x23a9a2(address _0xb9b305, uint256 _0xee747e) external _0xa9e00a(EMERGENCY_ROLE) {
        _0x8c5af8(_0xb9b305, _0xee747e);
    }

    /**
     * @dev transfer ETH to an address, revert if it fails.
     * @param to recipient of the transfer
     * @param value the amount to send
     */
    function _0x8c5af8(address _0xb9b305, uint256 value) internal {
        (bool _0x4162ab, ) = _0xb9b305.call{value: value}(new bytes(0));
        require(_0x4162ab, 'ETH_TRANSFER_FAILED');
    }

    /**
    * @dev Only WETH contract is allowed to transfer ETH here. Prevent other addresses to send Ether to this contract.
    */
    receive() external payable {
        require(msg.sender == address(_0x3aaae6), 'Receive not allowed');
    }

    /**
    * @dev Revert fallback calls
    */
    fallback() external payable {
        revert('Fallback not allowed');
    }
}