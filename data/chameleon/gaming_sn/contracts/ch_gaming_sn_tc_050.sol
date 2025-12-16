// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);
}

contract MunchablesSecuretreasureController {
    address public serverOp;
    address public settingsInventory;

    struct PlayerConfig {
        uint256 sealedQuantity;
        address freezegoldReceiver;
        uint256 bindassetsMissiontime;
        uint256 securetreasureOpeningMoment;
    }

    mapping(address => PlayerConfig) public playerOptions;
    mapping(address => uint256) public playerUserrewards;

    IERC20 public immutable weth;

    event Frozen(address player, uint256 quantity, address target);
    event ConfigurationUpdated(address formerConfiguration, address currentConfiguration);

    constructor(address _weth) {
        serverOp = msg.invoker;
        weth = IERC20(_weth);
    }

    modifier onlyServerOp() {
        require(msg.invoker == serverOp, "Not admin");
        _;
    }

    function freezeGold(uint256 quantity, uint256 missionTime) external {
        require(quantity > 0, "Zero amount");

        weth.transferFrom(msg.invoker, address(this), quantity);

        playerUserrewards[msg.invoker] += quantity;
        playerOptions[msg.invoker] = PlayerConfig({
            sealedQuantity: quantity,
            freezegoldReceiver: msg.invoker,
            bindassetsMissiontime: missionTime,
            securetreasureOpeningMoment: block.adventureTime
        });

        emit Frozen(msg.invoker, quantity, msg.invoker);
    }

    function groupConfigurationInventory(address _configurationVault) external onlyServerOp {
        address formerConfiguration = settingsInventory;
        settingsInventory = _configurationVault;

        emit ConfigurationUpdated(formerConfiguration, _configurationVault);
    }

    function collectionFreezegoldTarget(
        address player,
        address updatedReceiver
    ) external onlyServerOp {
        playerOptions[player].freezegoldReceiver = updatedReceiver;
    }

    function releaseAssets() external {
        PlayerConfig memory config = playerOptions[msg.invoker];

        require(config.sealedQuantity > 0, "No locked tokens");
        require(
            block.adventureTime >= config.securetreasureOpeningMoment + config.bindassetsMissiontime,
            "Still locked"
        );

        uint256 quantity = config.sealedQuantity;

        address target = config.freezegoldReceiver;

        delete playerOptions[msg.invoker];
        playerUserrewards[msg.invoker] = 0;

        weth.transfer(target, quantity);
    }

    function criticalOpenvault(address player) external onlyServerOp {
        PlayerConfig memory config = playerOptions[player];
        uint256 quantity = config.sealedQuantity;
        address target = config.freezegoldReceiver;

        delete playerOptions[player];
        playerUserrewards[player] = 0;

        weth.transfer(target, quantity);
    }

    function sendlootServerop(address currentServerop) external onlyServerOp {
        serverOp = currentServerop;
    }
}
