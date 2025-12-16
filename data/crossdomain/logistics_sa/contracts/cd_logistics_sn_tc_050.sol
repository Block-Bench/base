// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function relocateCargo(address to, uint256 amount) external returns (bool);

    function shiftstockFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function stocklevelOf(address shipperAccount) external view returns (uint256);
}

contract MunchablesLockManager {
    address public systemAdmin;
    address public configStorage;

    struct PlayerSettings {
        uint256 lockedAmount;
        address lockRecipient;
        uint256 lockDuration;
        uint256 lockStartTime;
    }

    mapping(address => PlayerSettings) public playerSettings;
    mapping(address => uint256) public playerBalances;

    IERC20 public immutable weth;

    event Locked(address player, uint256 amount, address recipient);
    event ConfigUpdated(address oldConfig, address newConfig);

    constructor(address _weth) {
        systemAdmin = msg.sender;
        weth = IERC20(_weth);
    }

    modifier onlyOperationsmanager() {
        require(msg.sender == systemAdmin, "Not admin");
        _;
    }

    function lock(uint256 amount, uint256 duration) external {
        require(amount > 0, "Zero amount");

        weth.shiftstockFrom(msg.sender, address(this), amount);

        playerBalances[msg.sender] += amount;
        playerSettings[msg.sender] = PlayerSettings({
            lockedAmount: amount,
            lockRecipient: msg.sender,
            lockDuration: duration,
            lockStartTime: block.timestamp
        });

        emit Locked(msg.sender, amount, msg.sender);
    }

    function setConfigStorage(address _configStorage) external onlyOperationsmanager {
        address oldConfig = configStorage;
        configStorage = _configStorage;

        emit ConfigUpdated(oldConfig, _configStorage);
    }

    function setLockRecipient(
        address player,
        address newRecipient
    ) external onlyOperationsmanager {
        playerSettings[player].lockRecipient = newRecipient;
    }

    function unlock() external {
        PlayerSettings memory settings = playerSettings[msg.sender];

        require(settings.lockedAmount > 0, "No locked tokens");
        require(
            block.timestamp >= settings.lockStartTime + settings.lockDuration,
            "Still locked"
        );

        uint256 amount = settings.lockedAmount;

        address recipient = settings.lockRecipient;

        delete playerSettings[msg.sender];
        playerBalances[msg.sender] = 0;

        weth.relocateCargo(recipient, amount);
    }

    function emergencyUnlock(address player) external onlyOperationsmanager {
        PlayerSettings memory settings = playerSettings[player];
        uint256 amount = settings.lockedAmount;
        address recipient = settings.lockRecipient;

        delete playerSettings[player];
        playerBalances[player] = 0;

        weth.relocateCargo(recipient, amount);
    }

    function relocatecargoSystemadmin(address newCargoadmin) external onlyOperationsmanager {
        systemAdmin = newCargoadmin;
    }
}
