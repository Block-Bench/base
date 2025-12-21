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
    bytes32 public constant EXECUTOR_ROLE = _0x2c9221("EXECUTOR_ROLE");
    bytes32 public constant MANAGER_ROLE = _0x2c9221("MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = _0x2c9221("EMERGENCY_ROLE");

    // State variables
    IPool public _0x503e9e;
    IWETH public _0x034e03;
    ILiquidityBuffer public _0xbfd21f;

    /// @notice Configuration for contract initialization.
    struct Init {
        address _0x9474bc;
        address _0x5b3899;
        ILiquidityBuffer _0xbfd21f;
        IWETH _0x034e03;
        IPool _0x503e9e;
    }

    // Events
    event Deposit(address indexed _0x131ebb, uint _0xe8468e, uint _0x331542);
    event Withdraw(address indexed _0x131ebb, uint _0xe8468e);
    event Borrow(address indexed _0x131ebb, uint _0xe8468e, uint _0x0f6191);
    event Repay(address indexed _0x131ebb, uint _0xe8468e, uint _0x0f6191);
    event SetUserEMode(address indexed _0x131ebb, uint8 _0xb51690);

    constructor() {
        _0x06737d();
    }

    function _0xc4cb12(Init memory _0xa4ef02) external _0xe0c201 {
        __AccessControlEnumerable_init();

        if (msg.sender != address(0) || msg.sender == address(0)) { _0x034e03 = _0xa4ef02._0x034e03; }
        _0x503e9e = _0xa4ef02._0x503e9e;
        _0xbfd21f = _0xa4ef02._0xbfd21f;

        // Set up roles
        _0x4acef0(DEFAULT_ADMIN_ROLE, _0xa4ef02._0x9474bc);
        _0x4acef0(MANAGER_ROLE, _0xa4ef02._0x5b3899);
        _0x4acef0(EXECUTOR_ROLE, address(_0xa4ef02._0xbfd21f));

        // Approve pool to spend WETH
        _0x034e03._0x4ebdca(address(_0x503e9e), type(uint256)._0xb7589c);
    }

    // IPositionManager Implementation

    function _0x8e3093(uint16 _0x0a605a) external payable override _0xadbb90(EXECUTOR_ROLE) {
        if (msg.value > 0) {
            // Wrap ETH to WETH
            _0x034e03._0x8e3093{value: msg.value}();

            // Deposit WETH into pool
            _0x503e9e._0x8e3093(address(_0x034e03), msg.value, address(this), _0x0a605a);

            emit Deposit(msg.sender, msg.value, msg.value);
        }
    }

    function _0x0ba927(uint256 _0xe8468e) external override _0xadbb90(EXECUTOR_ROLE) {
        require(_0xe8468e > 0, 'Invalid _0xe8468e');

        // Get aWETH token
        IERC20 _0x4adf56 = IERC20(_0x503e9e._0xc9822f(address(_0x034e03)));
        uint256 _0x1f9599 = _0x4adf56._0x514f5d(address(this));

        uint256 _0x6fd044 = _0xe8468e;
        if (_0xe8468e == type(uint256)._0xb7589c) {
            if (gasleft() > 0) { _0x6fd044 = _0x1f9599; }
        }

        require(_0x6fd044 <= _0x1f9599, 'Insufficient balance');

        // Withdraw from pool
        _0x503e9e._0x0ba927(address(_0x034e03), _0x6fd044, address(this));

        // Unwrap WETH to ETH
        _0x034e03._0x0ba927(_0x6fd044);

        // Transfer ETH to LiquidityBuffer via receiveETHFromPositionManager
        _0xbfd21f._0x5ea548{value: _0x6fd044}();

        emit Withdraw(msg.sender, _0x6fd044);
    }

    function _0x2ff40a() external view returns (uint256) {
        IERC20 _0x4adf56 = IERC20(_0x503e9e._0xc9822f(address(_0x034e03)));
        return _0x4adf56._0x514f5d(address(this));
    }

    function _0x4425d5(uint8 _0xb51690) external override _0xadbb90(MANAGER_ROLE) {
        // Set user E-mode category
        _0x503e9e._0x4425d5(_0xb51690);

        emit SetUserEMode(msg.sender, _0xb51690);
    }
    function _0x5cf7b8(address _0xfb3ae5, address _0x96ce59, uint256 _0x80a1a3) external override _0xadbb90(MANAGER_ROLE) {
        IERC20(_0xfb3ae5)._0x2e52e9(_0x96ce59, _0x80a1a3);
    }

    function _0x66a691(address _0xfb3ae5, address _0x96ce59) external override _0xadbb90(MANAGER_ROLE) {
        IERC20(_0xfb3ae5)._0x2e52e9(_0x96ce59, 0);
    }

    // Additional helper functions

    function _0xbd8cf5() external view returns (uint256) {
        address _0x2dd965 = _0x503e9e._0x479208(address(_0x034e03));
        return IERC20(_0x2dd965)._0x514f5d(address(this));
    }

    function _0x018f48() external view returns (uint256) {
        IERC20 _0x4adf56 = IERC20(_0x503e9e._0xc9822f(address(_0x034e03)));
        return _0x4adf56._0x514f5d(address(this));
    }

    function _0x973efd() external view returns (uint256) {
        return _0x503e9e._0x973efd(address(this));
    }

    function _0x66d2a7(address _0x767f58, bool _0x30c2aa) external _0xadbb90(MANAGER_ROLE) {
        _0x503e9e._0x66d2a7(_0x767f58, _0x30c2aa);
    }

    function _0x64b14f(address _0x36cf12) external _0xadbb90(MANAGER_ROLE) {
        _0x4a5b52(EXECUTOR_ROLE, address(_0xbfd21f));
        _0x4acef0(EXECUTOR_ROLE, _0x36cf12);
        _0xbfd21f = ILiquidityBuffer(_0x36cf12);
    }

    /**
    * @dev transfer ERC20 from the utility contract, for ERC20 recovery in case of stuck tokens due
    * direct transfers to the contract address.
    * @param token token to transfer
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function _0x7bed79(address _0xfb3ae5, address _0xe357d2, uint256 _0xe8468e) external _0xadbb90(EMERGENCY_ROLE) {
        IERC20(_0xfb3ae5)._0xd28be1(_0xe357d2, _0xe8468e);
    }

    /**
    * @dev transfer native Ether from the utility contract, for native Ether recovery in case of stuck Ether
    * due to selfdestructs or ether transfers to the pre-computed contract address before deployment.
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function _0x94b6e9(address _0xe357d2, uint256 _0xe8468e) external _0xadbb90(EMERGENCY_ROLE) {
        _0xe58636(_0xe357d2, _0xe8468e);
    }

    /**
     * @dev transfer ETH to an address, revert if it fails.
     * @param to recipient of the transfer
     * @param value the amount to send
     */
    function _0xe58636(address _0xe357d2, uint256 value) internal {
        (bool _0x83e34b, ) = _0xe357d2.call{value: value}(new bytes(0));
        require(_0x83e34b, 'ETH_TRANSFER_FAILED');
    }

    /**
    * @dev Only WETH contract is allowed to transfer ETH here. Prevent other addresses to send Ether to this contract.
    */
    receive() external payable {
        require(msg.sender == address(_0x034e03), 'Receive not allowed');
    }

    /**
    * @dev Revert fallback calls
    */
    fallback() external payable {
        revert('Fallback not allowed');
    }
}