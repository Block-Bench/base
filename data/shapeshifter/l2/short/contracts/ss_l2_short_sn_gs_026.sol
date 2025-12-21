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
    bytes32 public constant EXECUTOR_ROLE = ag("EXECUTOR_ROLE");
    bytes32 public constant MANAGER_ROLE = ag("MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = ag("EMERGENCY_ROLE");

    // State variables
    IPool public av;
    IWETH public au;
    ILiquidityBuffer public o;

    /// @notice Configuration for contract initialization.
    struct Init {
        address as;
        address an;
        ILiquidityBuffer o;
        IWETH au;
        IPool av;
    }

    // Events
    event Deposit(address indexed ap, uint ao, uint r);
    event Withdraw(address indexed ap, uint ao);
    event Borrow(address indexed ap, uint ao, uint ai);
    event Repay(address indexed ap, uint ao, uint ai);
    event SetUserEMode(address indexed ap, uint8 ac);

    constructor() {
        h();
    }

    function ad(Init memory ax) external w {
        __AccessControlEnumerable_init();

        au = ax.au;
        av = ax.av;
        o = ax.o;

        // Set up roles
        ab(DEFAULT_ADMIN_ROLE, ax.as);
        ab(MANAGER_ROLE, ax.an);
        ab(EXECUTOR_ROLE, address(ax.o));

        // Approve pool to spend WETH
        au.al(address(av), type(uint256).ay);
    }

    // IPositionManager Implementation

    function ak(uint16 s) external payable override ah(EXECUTOR_ROLE) {
        if (msg.value > 0) {
            // Wrap ETH to WETH
            au.ak{value: msg.value}();

            // Deposit WETH into pool
            av.ak(address(au), msg.value, address(this), s);

            emit Deposit(msg.sender, msg.value, msg.value);
        }
    }

    function aj(uint256 ao) external override ah(EXECUTOR_ROLE) {
        require(ao > 0, 'Invalid ao');

        // Get aWETH token
        IERC20 ar = IERC20(av.m(address(au)));
        uint256 z = ar.ae(address(this));

        uint256 n = ao;
        if (ao == type(uint256).ay) {
            n = z;
        }

        require(n <= z, 'Insufficient balance');

        // Withdraw from pool
        av.aj(address(au), n, address(this));

        // Unwrap WETH to ETH
        au.aj(n);

        // Transfer ETH to LiquidityBuffer via receiveETHFromPositionManager
        o.a{value: n}();

        emit Withdraw(msg.sender, n);
    }

    function g() external view returns (uint256) {
        IERC20 ar = IERC20(av.m(address(au)));
        return ar.ae(address(this));
    }

    function t(uint8 ac) external override ah(MANAGER_ROLE) {
        // Set user E-mode category
        av.t(ac);

        emit SetUserEMode(msg.sender, ac);
    }
    function u(address at, address aw, uint256 az) external override ah(MANAGER_ROLE) {
        IERC20(at).x(aw, az);
    }

    function y(address at, address aw) external override ah(MANAGER_ROLE) {
        IERC20(at).x(aw, 0);
    }

    // Additional helper functions

    function l() external view returns (uint256) {
        address af = av.c(address(au));
        return IERC20(af).ae(address(this));
    }

    function f() external view returns (uint256) {
        IERC20 ar = IERC20(av.m(address(au)));
        return ar.ae(address(this));
    }

    function q() external view returns (uint256) {
        return av.q(address(this));
    }

    function b(address aq, bool p) external ah(MANAGER_ROLE) {
        av.b(aq, p);
    }

    function i(address k) external ah(MANAGER_ROLE) {
        aa(EXECUTOR_ROLE, address(o));
        ab(EXECUTOR_ROLE, k);
        o = ILiquidityBuffer(k);
    }

    /**
    * @dev transfer ERC20 from the utility contract, for ERC20 recovery in case of stuck tokens due
    * direct transfers to the contract address.
    * @param token token to transfer
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function e(address at, address ba, uint256 ao) external ah(EMERGENCY_ROLE) {
        IERC20(at).v(ba, ao);
    }

    /**
    * @dev transfer native Ether from the utility contract, for native Ether recovery in case of stuck Ether
    * due to selfdestructs or ether transfers to the pre-computed contract address before deployment.
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function d(address ba, uint256 ao) external ah(EMERGENCY_ROLE) {
        j(ba, ao);
    }

    /**
     * @dev transfer ETH to an address, revert if it fails.
     * @param to recipient of the transfer
     * @param value the amount to send
     */
    function j(address ba, uint256 value) internal {
        (bool am, ) = ba.call{value: value}(new bytes(0));
        require(am, 'ETH_TRANSFER_FAILED');
    }

    /**
    * @dev Only WETH contract is allowed to transfer ETH here. Prevent other addresses to send Ether to this contract.
    */
    receive() external payable {
        require(msg.sender == address(au), 'Receive not allowed');
    }

    /**
    * @dev Revert fallback calls
    */
    fallback() external payable {
        revert('Fallback not allowed');
    }
}