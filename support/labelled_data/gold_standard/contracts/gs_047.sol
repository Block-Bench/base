// SPDX-License-Identifier: BUSL-1.1
// Terms: https://liminal.money/xtokens/license

pragma solidity 0.8.28;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IPriceOracle} from "./interfaces/IPriceOracle.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IPyth} from "@pythnetwork/pyth-sdk-solidity/IPyth.sol";
import {PythStructs} from "@pythnetwork/pyth-sdk-solidity/PythStructs.sol";

/**
 * @title PythPriceOracle
 * @notice Oracle integration with Pyth Network price feeds
 * @dev Uses Pyth's pull-based price model with real-time updates
 */
contract PythPriceOracle is AccessControlUpgradeable, IPriceOracle {
    bytes32 public constant PRICE_MANAGER_ROLE = keccak256("PRICE_MANAGER_ROLE");

    uint256 public constant BASIS_POINTS = 10000;

    struct PythPriceOracleStorage {
        address timeLockController;
        mapping(address => bytes32) priceIds;
        mapping(address => uint8) assetDecimals;
        address underlyingAsset;
        IPyth pyth;
        uint96 maxPriceAge;
        uint256 maxConfidenceBps;
    }

    bytes32 private constant PYTH_PRICE_ORACLE_STORAGE_LOCATION =
        0x79f8fe64cf697304b8736b5ceebe50109f667154b58cb0fe6be0d930c76b5e00;

    function _getPythPriceOracleStorage() private pure returns (PythPriceOracleStorage storage $) {
        assembly {
            $.slot := PYTH_PRICE_ORACLE_STORAGE_LOCATION
        }
    }

    event PriceIdSet(address indexed asset, bytes32 priceId, uint8 decimals);
    event UnderlyingAssetSet(address indexed asset);
    event MaxPriceAgeUpdated(uint96 newMaxAge);
    event PythContractUpdated(address indexed newPyth);
    event TimelockControllerSet(address indexed oldTimelock, address indexed newTimelock);
    event MaxConfidenceBpsUpdated(uint256 newMaxConfidenceBps);

    modifier onlyTimelock() {
        PythPriceOracleStorage storage $ = _getPythPriceOracleStorage();
        require(msg.sender == $.timeLockController, "PythOracle: only timelock");
        _;
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _deployer,
        address _priceManager,
        address _pyth,
        address _underlyingAsset,
        address _timeLockController,
        uint256 _maxConfidenceBps
    ) external initializer {
        require(_deployer != address(0), "PythOracle: zero deployer");
        require(_priceManager != address(0), "PythOracle: zero manager");
        require(_pyth != address(0), "PythOracle: zero pyth");
        require(_underlyingAsset != address(0), "PythOracle: zero underlying");
        require(_timeLockController != address(0), "PythOracle: zero timelock");
        require(_maxConfidenceBps > 0, "PythOracle: zero confidence threshold");
        require(_maxConfidenceBps <= BASIS_POINTS, "PythOracle: confidence threshold too high");

        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, _deployer);
        _grantRole(PRICE_MANAGER_ROLE, _priceManager);

        PythPriceOracleStorage storage $ = _getPythPriceOracleStorage();
        $.pyth = IPyth(_pyth);
        $.underlyingAsset = _underlyingAsset;
        $.maxPriceAge = 3600;
        $.timeLockController = _timeLockController;
        $.maxConfidenceBps = _maxConfidenceBps;

        emit UnderlyingAssetSet(_underlyingAsset);
    }

    function setPriceId(address asset, bytes32 priceId, uint8 decimals) external onlyTimelock {
        require(asset != address(0), "PythOracle: zero asset");
        require(priceId != bytes32(0), "PythOracle: zero price ID");
        require(decimals <= 18, "PythOracle: invalid decimals");
        require(decimals == IERC20Metadata(asset).decimals(), "PythOracle: decimals mismatch");

        PythPriceOracleStorage storage $ = _getPythPriceOracleStorage();
        $.priceIds[asset] = priceId;
        $.assetDecimals[asset] = decimals;

        emit PriceIdSet(asset, priceId, decimals);
    }

    function setPriceIds(address[] calldata assets, bytes32[] calldata _priceIds, uint8[] calldata decimalsArray)
        external
        onlyTimelock
    {
        require(assets.length == _priceIds.length, "PythOracle: length mismatch");
        require(assets.length == decimalsArray.length, "PythOracle: decimals mismatch");

        PythPriceOracleStorage storage $ = _getPythPriceOracleStorage();
        for (uint256 i = 0; i < assets.length; i++) {
            require(assets[i] != address(0), "PythOracle: zero asset");
            require(_priceIds[i] != bytes32(0), "PythOracle: zero price ID");
            require(decimalsArray[i] <= 18, "PythOracle: invalid decimals");
            require(decimalsArray[i] == IERC20Metadata(assets[i]).decimals(), "PythOracle: decimals mismatch");

            $.priceIds[assets[i]] = _priceIds[i];
            $.assetDecimals[assets[i]] = decimalsArray[i];

            emit PriceIdSet(assets[i], _priceIds[i], decimalsArray[i]);
        }
    }

    function hasPriceFeed(address asset) external view returns (bool) {
        return _getPythPriceOracleStorage().priceIds[asset] != bytes32(0);
    }
}
