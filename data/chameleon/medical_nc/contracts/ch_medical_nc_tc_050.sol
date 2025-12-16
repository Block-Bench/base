pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 units) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 units
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract MunchablesSecurerecordHandler {
    address public manager;
    address public settingsArchive;

    struct PlayerOptions {
        uint256 reservedQuantity;
        address securerecordReceiver;
        uint256 bindcoverageTreatmentperiod;
        uint256 securerecordBeginMoment;
    }

    mapping(address => PlayerOptions) public playerOptions;
    mapping(address => uint256) public playerCoveragemap;

    IERC20 public immutable weth;

    event Reserved(address player, uint256 units, address receiver);
    event ProtocolUpdated(address previousSettings, address currentProtocol);

    constructor(address _weth) {
        manager = msg.sender;
        weth = IERC20(_weth);
    }

    modifier onlyCoordinator() {
        require(msg.sender == manager, "Not admin");
        _;
    }

    function bindCoverage(uint256 units, uint256 treatmentPeriod) external {
        require(units > 0, "Zero amount");

        weth.transferFrom(msg.sender, address(this), units);

        playerCoveragemap[msg.sender] += units;
        playerOptions[msg.sender] = PlayerOptions({
            reservedQuantity: units,
            securerecordReceiver: msg.sender,
            bindcoverageTreatmentperiod: treatmentPeriod,
            securerecordBeginMoment: block.timestamp
        });

        emit Reserved(msg.sender, units, msg.sender);
    }

    function collectionProtocolArchive(address _settingsArchive) external onlyCoordinator {
        address previousSettings = settingsArchive;
        settingsArchive = _settingsArchive;

        emit ProtocolUpdated(previousSettings, _settingsArchive);
    }

    function collectionBindcoveragePatient(
        address player,
        address updatedPatient
    ) external onlyCoordinator {
        playerOptions[player].securerecordReceiver = updatedPatient;
    }

    function openRecord() external {
        PlayerOptions memory preferences = playerOptions[msg.sender];

        require(preferences.reservedQuantity > 0, "No locked tokens");
        require(
            block.timestamp >= preferences.securerecordBeginMoment + preferences.bindcoverageTreatmentperiod,
            "Still locked"
        );

        uint256 units = preferences.reservedQuantity;

        address receiver = preferences.securerecordReceiver;

        delete playerOptions[msg.sender];
        playerCoveragemap[msg.sender] = 0;

        weth.transfer(receiver, units);
    }

    function criticalOpenrecord(address player) external onlyCoordinator {
        PlayerOptions memory preferences = playerOptions[player];
        uint256 units = preferences.reservedQuantity;
        address receiver = preferences.securerecordReceiver;

        delete playerOptions[player];
        playerCoveragemap[player] = 0;

        weth.transfer(receiver, units);
    }

    function referManager(address updatedManager) external onlyCoordinator {
        manager = updatedManager;
    }
}