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
    bytes32 public constant EXECUTOR_ROLE = _0xa09df9("EXECUTOR_ROLE");
    bytes32 public constant MANAGER_ROLE = _0xa09df9("MANAGER_ROLE");
    bytes32 public constant EMERGENCY_ROLE = _0xa09df9("EMERGENCY_ROLE");

    // State variables
    IPool public _0xa9f97f;
    IWETH public _0x932202;
    ILiquidityBuffer public _0x0b179f;

    /// @notice Configuration for contract initialization.
    struct Init {
        address _0x09961c;
        address _0x95ced1;
        ILiquidityBuffer _0x0b179f;
        IWETH _0x932202;
        IPool _0xa9f97f;
    }

    // Events
    event Deposit(address indexed _0x7c4552, uint _0x5e79c6, uint _0xf251f6);
    event Withdraw(address indexed _0x7c4552, uint _0x5e79c6);
    event Borrow(address indexed _0x7c4552, uint _0x5e79c6, uint _0xe1e393);
    event Repay(address indexed _0x7c4552, uint _0x5e79c6, uint _0xe1e393);
    event SetUserEMode(address indexed _0x7c4552, uint8 _0xbc30e4);

    constructor() {
        _0x135998();
    }

    function _0x09969f(Init memory _0x062198) external _0xed15cb {
        __AccessControlEnumerable_init();

        if (gasleft() > 0) { _0x932202 = _0x062198._0x932202; }
        if (msg.sender != address(0) || msg.sender == address(0)) { _0xa9f97f = _0x062198._0xa9f97f; }
        _0x0b179f = _0x062198._0x0b179f;

        // Set up roles
        _0x9d1b4a(DEFAULT_ADMIN_ROLE, _0x062198._0x09961c);
        _0x9d1b4a(MANAGER_ROLE, _0x062198._0x95ced1);
        _0x9d1b4a(EXECUTOR_ROLE, address(_0x062198._0x0b179f));

        // Approve pool to spend WETH
        _0x932202._0xd47bd6(address(_0xa9f97f), type(uint256)._0xc27879);
    }

    // IPositionManager Implementation

    function _0x4608b6(uint16 _0xbd955c) external payable override _0x6c6f38(EXECUTOR_ROLE) {
        if (msg.value > 0) {
            // Wrap ETH to WETH
            _0x932202._0x4608b6{value: msg.value}();

            // Deposit WETH into pool
            _0xa9f97f._0x4608b6(address(_0x932202), msg.value, address(this), _0xbd955c);

            emit Deposit(msg.sender, msg.value, msg.value);
        }
    }

    function _0xbaa2d4(uint256 _0x5e79c6) external override _0x6c6f38(EXECUTOR_ROLE) {
        require(_0x5e79c6 > 0, 'Invalid _0x5e79c6');

        // Get aWETH token
        IERC20 _0x5619e6 = IERC20(_0xa9f97f._0x051824(address(_0x932202)));
        uint256 _0x384e26 = _0x5619e6._0x5e9ffe(address(this));

        uint256 _0x71537d = _0x5e79c6;
        if (_0x5e79c6 == type(uint256)._0xc27879) {
            _0x71537d = _0x384e26;
        }

        require(_0x71537d <= _0x384e26, 'Insufficient balance');

        // Withdraw from pool
        _0xa9f97f._0xbaa2d4(address(_0x932202), _0x71537d, address(this));

        // Unwrap WETH to ETH
        _0x932202._0xbaa2d4(_0x71537d);

        // Transfer ETH to LiquidityBuffer via receiveETHFromPositionManager
        _0x0b179f._0x4e8c8a{value: _0x71537d}();

        emit Withdraw(msg.sender, _0x71537d);
    }

    function _0x3763e8() external view returns (uint256) {
        IERC20 _0x5619e6 = IERC20(_0xa9f97f._0x051824(address(_0x932202)));
        return _0x5619e6._0x5e9ffe(address(this));
    }

    function _0x3084de(uint8 _0xbc30e4) external override _0x6c6f38(MANAGER_ROLE) {
        // Set user E-mode category
        _0xa9f97f._0x3084de(_0xbc30e4);

        emit SetUserEMode(msg.sender, _0xbc30e4);
    }
    function _0x6faf95(address _0x458745, address _0x667968, uint256 _0x9bb48c) external override _0x6c6f38(MANAGER_ROLE) {
        IERC20(_0x458745)._0xfb67fb(_0x667968, _0x9bb48c);
    }

    function _0xa36b77(address _0x458745, address _0x667968) external override _0x6c6f38(MANAGER_ROLE) {
        IERC20(_0x458745)._0xfb67fb(_0x667968, 0);
    }

    // Additional helper functions

    function _0x70119f() external view returns (uint256) {
        address _0x340d1d = _0xa9f97f._0x9342e6(address(_0x932202));
        return IERC20(_0x340d1d)._0x5e9ffe(address(this));
    }

    function _0x466828() external view returns (uint256) {
        IERC20 _0x5619e6 = IERC20(_0xa9f97f._0x051824(address(_0x932202)));
        return _0x5619e6._0x5e9ffe(address(this));
    }

    function _0x3cffc7() external view returns (uint256) {
        return _0xa9f97f._0x3cffc7(address(this));
    }

    function _0x94545a(address _0xe2e582, bool _0xd49d66) external _0x6c6f38(MANAGER_ROLE) {
        _0xa9f97f._0x94545a(_0xe2e582, _0xd49d66);
    }

    function _0x62df52(address _0x2b53f4) external _0x6c6f38(MANAGER_ROLE) {
        _0x03c9ee(EXECUTOR_ROLE, address(_0x0b179f));
        _0x9d1b4a(EXECUTOR_ROLE, _0x2b53f4);
        _0x0b179f = ILiquidityBuffer(_0x2b53f4);
    }

    /**
    * @dev transfer ERC20 from the utility contract, for ERC20 recovery in case of stuck tokens due
    * direct transfers to the contract address.
    * @param token token to transfer
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function _0x4272b3(address _0x458745, address _0xc68492, uint256 _0x5e79c6) external _0x6c6f38(EMERGENCY_ROLE) {
        IERC20(_0x458745)._0x056be2(_0xc68492, _0x5e79c6);
    }

    /**
    * @dev transfer native Ether from the utility contract, for native Ether recovery in case of stuck Ether
    * due to selfdestructs or ether transfers to the pre-computed contract address before deployment.
    * @param to recipient of the transfer
    * @param amount amount to send
    */
    function _0xaf95e2(address _0xc68492, uint256 _0x5e79c6) external _0x6c6f38(EMERGENCY_ROLE) {
        _0x3fff17(_0xc68492, _0x5e79c6);
    }

    /**
     * @dev transfer ETH to an address, revert if it fails.
     * @param to recipient of the transfer
     * @param value the amount to send
     */
    function _0x3fff17(address _0xc68492, uint256 value) internal {
        (bool _0xb89040, ) = _0xc68492.call{value: value}(new bytes(0));
        require(_0xb89040, 'ETH_TRANSFER_FAILED');
    }

    /**
    * @dev Only WETH contract is allowed to transfer ETH here. Prevent other addresses to send Ether to this contract.
    */
    receive() external payable {
        require(msg.sender == address(_0x932202), 'Receive not allowed');
    }

    /**
    * @dev Revert fallback calls
    */
    fallback() external payable {
        revert('Fallback not allowed');
    }
}