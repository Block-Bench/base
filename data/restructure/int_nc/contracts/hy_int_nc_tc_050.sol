pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract MunchablesLockManager {
    address public admin;
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
        admin = msg.sender;
        weth = IERC20(_weth);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }

    function lock(uint256 amount, uint256 duration) external {
        _LockImpl(msg.sender, amount, duration);
    }

    function _LockImpl(address _sender, uint256 amount, uint256 duration) internal {
        require(amount > 0, "Zero amount");
        weth.transferFrom(_sender, address(this), amount);
        playerBalances[_sender] += amount;
        playerSettings[_sender] = PlayerSettings({
        lockedAmount: amount,
        lockRecipient: _sender,
        lockDuration: duration,
        lockStartTime: block.timestamp
        });
        emit Locked(_sender, amount, _sender);
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

    function transferAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
    }
}