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
        serverOp = msg.sender;
        weth = IERC20(_weth);
    }

    modifier onlyServerOp() {
        require(msg.sender == serverOp, "Not admin");
        _;
    }

    function freezeGold(uint256 quantity, uint256 missionTime) external {
        require(quantity > 0, "Zero amount");

        weth.transferFrom(msg.sender, address(this), quantity);

        playerUserrewards[msg.sender] += quantity;
        playerOptions[msg.sender] = PlayerConfig({
            sealedQuantity: quantity,
            freezegoldReceiver: msg.sender,
            bindassetsMissiontime: missionTime,
            securetreasureOpeningMoment: block.timestamp
        });

        emit Frozen(msg.sender, quantity, msg.sender);
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
        PlayerConfig memory config = playerOptions[msg.sender];

        require(config.sealedQuantity > 0, "No locked tokens");
        require(
            block.timestamp >= config.securetreasureOpeningMoment + config.bindassetsMissiontime,
            "Still locked"
        );

        uint256 quantity = config.sealedQuantity;

        address target = config.freezegoldReceiver;

        delete playerOptions[msg.sender];
        playerUserrewards[msg.sender] = 0;

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
