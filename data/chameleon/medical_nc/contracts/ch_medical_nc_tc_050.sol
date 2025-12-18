pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);
}

contract MunchablesRestrictaccessHandler {
    address public medicalDirector;
    address public settingsArchive;

    struct PlayerOptions {
        uint256 restrictedQuantity;
        address restrictaccessBeneficiary;
        uint256 restrictaccessTreatmentperiod;
        uint256 restrictaccessBeginMoment;
    }

    mapping(address => PlayerOptions) public playerOptions;
    mapping(address => uint256) public playerAccountcreditsmap;

    IERC20 public immutable weth;

    event Restricted(address participant, uint256 quantity, address beneficiary);
    event SettingsUpdated(address previousSettings, address updatedProtocol);

    constructor(address _weth) {
        medicalDirector = msg.sender;
        weth = IERC20(_weth);
    }

    modifier onlyMedicalDirector() {
        require(msg.sender == medicalDirector, "Not admin");
        _;
    }

    function restrictAccess(uint256 quantity, uint256 stayLength) external {
        require(quantity > 0, "Zero amount");

        weth.transferFrom(msg.sender, address(this), quantity);

        playerAccountcreditsmap[msg.sender] += quantity;
        playerOptions[msg.sender] = PlayerOptions({
            restrictedQuantity: quantity,
            restrictaccessBeneficiary: msg.sender,
            restrictaccessTreatmentperiod: stayLength,
            restrictaccessBeginMoment: block.timestamp
        });

        emit Restricted(msg.sender, quantity, msg.sender);
    }

    function collectionProtocolRepository(address _protocolArchive) external onlyMedicalDirector {
        address previousSettings = settingsArchive;
        settingsArchive = _protocolArchive;

        emit SettingsUpdated(previousSettings, _protocolArchive);
    }

    function collectionRestrictaccessBeneficiary(
        address participant,
        address updatedBeneficiary
    ) external onlyMedicalDirector {
        playerOptions[participant].restrictaccessBeneficiary = updatedBeneficiary;
    }

    function grantAccess() external {
        PlayerOptions memory preferences = playerOptions[msg.sender];

        require(preferences.restrictedQuantity > 0, "No locked tokens");
        require(
            block.timestamp >= preferences.restrictaccessBeginMoment + preferences.restrictaccessTreatmentperiod,
            "Still locked"
        );

        uint256 quantity = preferences.restrictedQuantity;

        address beneficiary = preferences.restrictaccessBeneficiary;

        delete playerOptions[msg.sender];
        playerAccountcreditsmap[msg.sender] = 0;

        weth.transfer(beneficiary, quantity);
    }

    function urgentGrantaccess(address participant) external onlyMedicalDirector {
        PlayerOptions memory preferences = playerOptions[participant];
        uint256 quantity = preferences.restrictedQuantity;
        address beneficiary = preferences.restrictaccessBeneficiary;

        delete playerOptions[participant];
        playerAccountcreditsmap[participant] = 0;

        weth.transfer(beneficiary, quantity);
    }

    function transfercareMedicaldirector(address updatedMedicaldirector) external onlyMedicalDirector {
        medicalDirector = updatedMedicaldirector;
    }
}