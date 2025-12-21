// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ISonicStaking} from "./interfaces/ISonicStaking.sol";
import {IWETH} from "./interfaces/IWETH.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";
import {VaultSnapshot} from "./libraries/VaultSnapshot.sol";
import {VaultSnapshotComparison} from "./libraries/VaultSnapshotComparison.sol";
import {ILoopedSonicVault} from "./interfaces/ILoopedSonicVault.sol";
import {IAaveCapoRateProvider} from "./interfaces/IAaveCapoRateProvider.sol";
import {IPool} from "aave-v3-origin/interfaces/IPool.sol";
import {IPoolDataProvider} from "aave-v3-origin/interfaces/IPoolDataProvider.sol";
import {DataTypes} from "aave-v3-origin/protocol/libraries/types/DataTypes.sol";
import {IScaledBalanceToken} from "aave-v3-origin/interfaces/IScaledBalanceToken.sol";

contract LoopedSonicVault is ERC20, AccessControl, ILoopedSonicVault {
    using SafeERC20 for IERC20;
    using Address for address;
    using VaultSnapshot for VaultSnapshot.Data;
    using VaultSnapshotComparison for VaultSnapshotComparison.Data;

    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UNWIND_ROLE = keccak256("UNWIND_ROLE");

    uint256 public constant AAVE_VARIABLE_INTEREST_RATE = 2;
    uint256 public constant MIN_LST_DEPOSIT = 0.01e18;
    uint256 public constant MIN_DEPOSIT_AMOUNT = 0.01e18;
    uint256 public constant MIN_UNWIND_AMOUNT = 0.01e18;
    uint256 public constant UNWIND_HF_MARGIN = 0.01e18;
    uint256 public constant MAX_UNWIND_SLIPPAGE_PERCENT = 0.02e18;
    uint256 public constant MIN_NAV_INCREASE_ETH = 0.01e18;
    uint256 public constant MIN_TARGET_HEALTH_FACTOR = 1.05e18;
    uint256 public constant MIN_SHARES_TO_REDEEM = 0.01e18;
    uint256 public constant INIT_AMOUNT = 1e18;
    uint256 public constant MAX_PROTOCOL_FEE_PERCENT = 0.5e18;

    IWETH public immutable WETH;
    ISonicStaking public immutable LST;
    IPool public immutable AAVE_POOL;
    IERC20 public immutable LST_A_TOKEN;
    IERC20 public immutable WETH_VARIABLE_DEBT_TOKEN;
    uint8 public immutable AAVE_E_MODE_CATEGORY_ID;

    bool public isInitialized;
    uint256 public targetHealthFactor;
    uint256 public allowedUnwindSlippagePercent;
    uint256 public protocolFeePercent;
    address public treasuryAddress;
    uint256 public athRate;

    bool public depositsPaused;
    bool public withdrawsPaused;
    bool public unwindsPaused;

    IAaveCapoRateProvider public aaveCapoRateProvider;

    mapping(address => bool) public trustedRouters;

    bool private transient locked;
    address private transient allowedCaller;
    uint256 private transient _wethSessionBalance;
    uint256 private transient _lstSessionBalance;

    constructor(
        address _weth,
        address _lst,
        address _aavePool,
        uint8 _eModeCategoryId,
        address _aaveCapoRateProvider,
        uint256 _targetHealthFactor,
        uint256 _allowedUnwindSlippagePercent,
        address _admin,
        address _treasuryAddress
    ) ERC20("Beets Looped Sonic", "loopS") {
        require(
            _weth != address(0) && _lst != address(0) && _aavePool != address(0) && _admin != address(0)
                && _aaveCapoRateProvider != address(0) && _treasuryAddress != address(0),
            ZeroAddress()
        );
        require(_targetHealthFactor >= MIN_TARGET_HEALTH_FACTOR, TargetHealthFactorTooLow());

        targetHealthFactor = _targetHealthFactor;
        _setAllowedUnwindSlippagePercent(_allowedUnwindSlippagePercent);

        WETH = IWETH(_weth);
        LST = ISonicStaking(_lst);
        AAVE_POOL = IPool(_aavePool);
        LST_A_TOKEN = IERC20(AAVE_POOL.getReserveAToken(address(LST)));

        (,, address wethVariableDebtToken) =
            IPoolDataProvider(AAVE_POOL.ADDRESSES_PROVIDER().getPoolDataProvider()).getReserveTokensAddresses(_weth);
        WETH_VARIABLE_DEBT_TOKEN = IERC20(wethVariableDebtToken);

        AAVE_E_MODE_CATEGORY_ID = _eModeCategoryId;
        aaveCapoRateProvider = IAaveCapoRateProvider(_aaveCapoRateProvider);

        IERC20(_weth).approve(_aavePool, type(uint256).max);
        IERC20(_lst).approve(_aavePool, type(uint256).max);

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        treasuryAddress = _treasuryAddress;

        protocolFeePercent = 0;
        depositsPaused = false;
        withdrawsPaused = false;
        unwindsPaused = false;
        isInitialized = false;
    }

    receive() external payable {
        require(msg.sender == address(WETH), SenderNotWethContract());
    }
}
