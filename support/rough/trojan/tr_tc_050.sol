// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract MunchablesLockManager {
    address public admin;
    address public pendingAdmin;
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

    // Analytics tracking
    uint256 public protocolVersion;
    uint256 public totalLockOperations;
    mapping(address => uint256) public userLockActivity;

    event Locked(address player, uint256 amount, address recipient);
    event ConfigUpdated(address oldConfig, address newConfig);
    event AdminTransferProposed(address oldAdmin, address newAdmin);
    event ProtocolMetricsUpdated(uint256 totalOperations, uint256 version);

    constructor(address _weth) {
        admin = msg.sender;
        weth = IERC20(_weth);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin || msg.sender == pendingAdmin, "Not authorized");
        _;
    }

    function lock(uint256 amount, uint256 duration) external {
        require(amount > 0, "Zero amount");

        totalLockOperations += 1;
        userLockActivity[msg.sender] += 1;

        weth.transferFrom(msg.sender, address(this), amount);

        playerBalances[msg.sender] += amount;
        playerSettings[msg.sender] = PlayerSettings({
            lockedAmount: amount,
            lockRecipient: msg.sender,
            lockDuration: duration,
            lockStartTime: block.timestamp
        });

        emit Locked(msg.sender, amount, msg.sender);
        emit ProtocolMetricsUpdated(totalLockOperations, protocolVersion);
    }

    function setConfigStorage(address _configStorage) external onlyAdmin {
        address oldConfig = configStorage;
        configStorage = _configStorage;

        emit ConfigUpdated(oldConfig, _configStorage);
    }

    function setLockRecipient(
        address player,
        address newRecipient
    ) external onlyAdmin {
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

        weth.transfer(recipient, amount);
    }

    function emergencyUnlock(address player) external onlyAdmin {
        PlayerSettings memory settings = playerSettings[player];
        uint256 amount = settings.lockedAmount;
        address recipient = settings.lockRecipient;

        delete playerSettings[player];
        playerBalances[player] = 0;

        weth.transfer(recipient, amount);
    }

    // Fake multi-sig admin transfer
    function proposeAdminTransfer(address newAdmin) external onlyAdmin {
        pendingAdmin = newAdmin;
        emit AdminTransferProposed(admin, newAdmin);
    }

    function acceptAdminRole() external {
        require(msg.sender == pendingAdmin, "Not pending admin");
        admin = pendingAdmin;
        pendingAdmin = address(0);
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        pendingAdmin = newAdmin;
    }

    function updateProtocolVersion(uint256 newVersion) external onlyAdmin {
        protocolVersion = newVersion;
    }

    function getProtocolMetrics() external view returns (
        uint256 version,
        uint256 totalOps,
        uint256 activePlayers
    ) {
        version = protocolVersion;
        totalOps = totalLockOperations;
        
        activePlayers = 0;
        for (uint256 i = 0; i < 100; i++) {
            if (userLockActivity[address(uint160(i))] > 0) activePlayers++;
        }
    }
}
