// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract MunchablesSecurerecordCoordinator {
    address public administrator;
    address public settingsRepository;

    struct PlayerPreferences {
        uint256 committedQuantity;
        address freezeaccountReceiver;
        uint256 freezeaccountStaylength;
        uint256 freezeaccountBeginMoment;
    }

    mapping(address => PlayerPreferences) public playerOptions;
    mapping(address => uint256) public playerPatientaccounts;

    IERC20 public immutable weth;

    event Committed(address player, uint256 measure, address receiver);
    event ProtocolUpdated(address previousSettings, address currentProtocol);

    constructor(address _weth) {
        administrator = msg.sender;
        weth = IERC20(_weth);
    }

    modifier onlyManager() {
        require(msg.sender == administrator, "Not admin");
        _;
    }

    function freezeAccount(uint256 measure, uint256 treatmentPeriod) external {
        require(measure > 0, "Zero amount");

        weth.transferFrom(msg.sender, address(this), measure);

        playerPatientaccounts[msg.sender] += measure;
        playerOptions[msg.sender] = PlayerPreferences({
            committedQuantity: measure,
            freezeaccountReceiver: msg.sender,
            freezeaccountStaylength: treatmentPeriod,
            freezeaccountBeginMoment: block.timestamp
        });

        emit Committed(msg.sender, measure, msg.sender);
    }

    function collectionSettingsRepository(address _settingsArchive) external onlyManager {
        address previousSettings = settingsRepository;
        settingsRepository = _settingsArchive;

        emit ProtocolUpdated(previousSettings, _settingsArchive);
    }

    function groupSecurerecordReceiver(
        address player,
        address updatedPatient
    ) external onlyManager {
        playerOptions[player].freezeaccountReceiver = updatedPatient;
    }

    function openRecord() external {
        PlayerPreferences memory options = playerOptions[msg.sender];

        require(options.committedQuantity > 0, "No locked tokens");
        require(
            block.timestamp >= options.freezeaccountBeginMoment + options.freezeaccountStaylength,
            "Still locked"
        );

        uint256 measure = options.committedQuantity;

        address receiver = options.freezeaccountReceiver;

        delete playerOptions[msg.sender];
        playerPatientaccounts[msg.sender] = 0;

        weth.transfer(receiver, measure);
    }

    function urgentReleasecoverage(address player) external onlyManager {
        PlayerPreferences memory options = playerOptions[player];
        uint256 measure = options.committedQuantity;
        address receiver = options.freezeaccountReceiver;

        delete playerOptions[player];
        playerPatientaccounts[player] = 0;

        weth.transfer(receiver, measure);
    }

    function relocatepatientManager(address currentManager) external onlyManager {
        administrator = currentManager;
    }
}
