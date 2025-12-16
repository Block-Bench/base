pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);
}

contract MunchablesBindassetsHandler {
    address public gameAdmin;
    address public settingsInventory;

    struct PlayerOptions {
        uint256 sealedCount;
        address bindassetsTarget;
        uint256 bindassetsMissiontime;
        uint256 freezegoldBeginMoment;
    }

    mapping(address => PlayerOptions) public playerConfig;
    mapping(address => uint256) public playerCharactergold;

    IERC20 public immutable weth;

    event Frozen(address player, uint256 measure, address target);
    event ConfigurationUpdated(address previousConfiguration, address currentConfiguration);

    constructor(address _weth) {
        gameAdmin = msg.sender;
        weth = IERC20(_weth);
    }

    modifier onlyModerator() {
        require(msg.sender == gameAdmin, "Not admin");
        _;
    }

    function bindAssets(uint256 measure, uint256 questLength) external {
        require(measure > 0, "Zero amount");

        weth.transferFrom(msg.sender, address(this), measure);

        playerCharactergold[msg.sender] += measure;
        playerConfig[msg.sender] = PlayerOptions({
            sealedCount: measure,
            bindassetsTarget: msg.sender,
            bindassetsMissiontime: questLength,
            freezegoldBeginMoment: block.timestamp
        });

        emit Frozen(msg.sender, measure, msg.sender);
    }

    function groupSettingsInventory(address _settingsInventory) external onlyModerator {
        address previousConfiguration = settingsInventory;
        settingsInventory = _settingsInventory;

        emit ConfigurationUpdated(previousConfiguration, _settingsInventory);
    }

    function groupFreezegoldReceiver(
        address player,
        address currentReceiver
    ) external onlyModerator {
        playerConfig[player].bindassetsTarget = currentReceiver;
    }

    function openVault() external {
        PlayerOptions memory config = playerConfig[msg.sender];

        require(config.sealedCount > 0, "No locked tokens");
        require(
            block.timestamp >= config.freezegoldBeginMoment + config.bindassetsMissiontime,
            "Still locked"
        );

        uint256 measure = config.sealedCount;

        address target = config.bindassetsTarget;

        delete playerConfig[msg.sender];
        playerCharactergold[msg.sender] = 0;

        weth.transfer(target, measure);
    }

    function urgentReleaseassets(address player) external onlyModerator {
        PlayerOptions memory config = playerConfig[player];
        uint256 measure = config.sealedCount;
        address target = config.bindassetsTarget;

        delete playerConfig[player];
        playerCharactergold[player] = 0;

        weth.transfer(target, measure);
    }

    function sendlootServerop(address currentServerop) external onlyModerator {
        gameAdmin = currentServerop;
    }
}