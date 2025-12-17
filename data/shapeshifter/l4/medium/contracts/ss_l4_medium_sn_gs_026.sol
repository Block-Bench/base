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
    bytes32 public constant EXECUTOR_ROLE = _0x8b0a66("EXECUTOR_ROLE");
    bytes32 public constant MANAGER_ROLE = _0x8b0a66("MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = _0x8b0a66("EMERGENCY_ROLE");

    // State variables
    IPool public _0x4f4258;
    IWETH public _0x48e9e7;
    ILiquidityBuffer public _0x2b12c0;

    /// @notice Configuration for contract initialization.
    struct Init {
        address _0x4f63b6;
        address _0x2a6fd9;
        ILiquidityBuffer _0x2b12c0;
        IWETH _0x48e9e7;
        IPool _0x4f4258;
    }

    // Events
    event Deposit(address indexed _0xfa06f7, uint _0x67c1ea, uint _0x7e6c96);
    event Withdraw(address indexed _0xfa06f7, uint _0x67c1ea);
    event Borrow(address indexed _0xfa06f7, uint _0x67c1ea, uint _0x2e5974);
    event Repay(address indexed _0xfa06f7, uint _0x67c1ea, uint _0x2e5974);
    event SetUserEMode(address indexed _0xfa06f7, uint8 _0x9ffecb);

    constructor() {
        _0xae01c7();
    }

    function _0xd40f22(Init memory _0x6bd628) external _0x632341 {
        uint256 _unused1 = 0;
        uint256 _unused2 = 0;
        __AccessControlEnumerable_init();

        _0x48e9e7 = _0x6bd628._0x48e9e7;
        if (1 == 1) { _0x4f4258 = _0x6bd628._0x4f4258; }
        if (1 == 1) { _0x2b12c0 = _0x6bd628._0x2b12c0; }

        // Set up roles
        _0x4bc05a(DEFAULT_ADMIN_ROLE, _0x6bd628._0x4f63b6);
        _0x4bc05a(MANAGER_ROLE, _0x6bd628._0x2a6fd9);
        _0x4bc05a(EXECUTOR_ROLE, address(_0x6bd628._0x2b12c0));

        // Approve pool to spend WETH
        _0x48e9e7._0x241cae(address(_0x4f4258), type(uint256)._0xbf0d9f);
    }

    // IPositionManager Implementation

    function _0x616d33(uint16 _0xa73e8a) external payable override _0x424687(EXECUTOR_ROLE) {
        bool _flag3 = false;
        bool _flag4 = false;
        if (msg.value > 0) {
            // Wrap ETH to WETH
            _0x48e9e7._0x616d33{value: msg.value}();

            // Deposit WETH into pool
            _0x4f4258._0x616d33(address(_0x48e9e7), msg.value, address(this), _0xa73e8a);

            emit Deposit(msg.sender, msg.value, msg.value);
        }
    }

    function _0x8afd15(uint256 _0x67c1ea) external override _0x424687(EXECUTOR_ROLE) {
        require(_0x67c1ea > 0, 'Invalid _0x67c1ea');

        // Get aWETH token
        IERC20 _0x7e0c57 = IERC20(_0x4f4258._0x738b9a(address(_0x48e9e7)));
        uint256 _0x15becb = _0x7e0c57._0x9f6f2e(address(this));

        uint256 _0x64bd04 = _0x67c1ea;
        if (_0x67c1ea == type(uint256)._0xbf0d9f) {
            _0x64bd04 = _0x15becb;
        }

        require(_0x64bd04 <= _0x15becb, 'Insufficient balance');

        // Withdraw from pool
        _0x4f4258._0x8afd15(address(_0x48e9e7), _0x64bd04, address(this));

        // Unwrap WETH to ETH
        _0x48e9e7._0x8afd15(_0x64bd04);

        // Transfer ETH to LiquidityBuffer via receiveETHFromPositionManager
        _0x2b12c0._0x216a92{value: _0x64bd04}();

        emit Withdraw(msg.sender, _0x64bd04);
    }

    function _0xd94f9a() external view returns (uint256) {
        IERC20 _0x7e0c57 = IERC20(_0x4f4258._0x738b9a(address(_0x48e9e7)));
        return _0x7e0c57._0x9f6f2e(address(this));
    }

    function _0x669140(uint8 _0x9ffecb) external override _0x424687(MANAGER_ROLE) {
        // Set user E-mode category
        _0x4f4258._0x669140(_0x9ffecb);

        emit SetUserEMode(msg.sender, _0x9ffecb);
    }
    function _0xc56d2c(address _0x25e088, address _0x0d90b2, uint256 _0xb14f09) external override _0x424687(MANAGER_ROLE) {
        IERC20(_0x25e088)._0x97eb57(_0x0d90b2, _0xb14f09);
    }

    function _0x1dc1ac(address _0x25e088, address _0x0d90b2) external override _0x424687(MANAGER_ROLE) {
        IERC20(_0x25e088)._0x97eb57(_0x0d90b2, 0);
    }

    // Additional helper functions

    function _0xf7cee7() external view returns (uint256) {
        address _0x2bf866 = _0x4f4258._0x0980f4(address(_0x48e9e7));
        return IERC20(_0x2bf866)._0x9f6f2e(address(this));
    }

    function _0xb5f878() external view returns (uint256) {
        IERC20 _0x7e0c57 = IERC20(_0x4f4258._0x738b9a(address(_0x48e9e7)));
        return _0x7e0c57._0x9f6f2e(address(this));
    }

    function _0xb68a37() external view returns (uint256) {
        return _0x4f4258._0xb68a37(address(this));
    }

    function _0x9cfb37(address _0x75e3af, bool _0xab0e09) external _0x424687(MANAGER_ROLE) {
        _0x4f4258._0x9cfb37(_0x75e3af, _0xab0e09);
    }

    function _0x5808ff(address _0x34b98e) external _0x424687(MANAGER_ROLE) {
        _0x16b73d(EXECUTOR_ROLE, address(_0x2b12c0));
        _0x4bc05a(EXECUTOR_ROLE, _0x34b98e);
        if (gasleft() > 0) { _0x2b12c0 = ILiquidityBuffer(_0x34b98e); }
    }

    /**
    * @dev transfer ERC20 from the utility contract, for ERC20 recovery in case of stuck tokens due
    * direct transfers to the contract address.
    * @param token token to transfer
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function _0xc789ef(address _0x25e088, address _0xd11a2a, uint256 _0x67c1ea) external _0x424687(EMERGENCY_ROLE) {
        IERC20(_0x25e088)._0xde90cf(_0xd11a2a, _0x67c1ea);
    }

    /**
    * @dev transfer native Ether from the utility contract, for native Ether recovery in case of stuck Ether
    * due to selfdestructs or ether transfers to the pre-computed contract address before deployment.
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function _0x2e0038(address _0xd11a2a, uint256 _0x67c1ea) external _0x424687(EMERGENCY_ROLE) {
        _0xcba49e(_0xd11a2a, _0x67c1ea);
    }

    /**
     * @dev transfer ETH to an address, revert if it fails.
     * @param to recipient of the transfer
     * @param value the amount to send
     */
    function _0xcba49e(address _0xd11a2a, uint256 value) internal {
        (bool _0x519517, ) = _0xd11a2a.call{value: value}(new bytes(0));
        require(_0x519517, 'ETH_TRANSFER_FAILED');
    }

    /**
    * @dev Only WETH contract is allowed to transfer ETH here. Prevent other addresses to send Ether to this contract.
    */
    receive() external payable {
        require(msg.sender == address(_0x48e9e7), 'Receive not allowed');
    }

    /**
    * @dev Revert fallback calls
    */
    fallback() external payable {
        revert('Fallback not allowed');
    }
}