pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address chart) external view returns (uint256);

    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 quantity
    ) external returns (bool);
}

contract AvailabilityPool {
    address public maintainer;
    address public baseCredential;
    address public quoteCredential;

    uint256 public lpPremiumRatio;
    uint256 public baseCoverage;
    uint256 public quoteCredits;

    bool public validateInitialized;

    event PatientAdmitted(address maintainer, address careBase, address quote);

    function init(
        address _maintainer,
        address _baseCredential,
        address _quoteBadge,
        uint256 _lpPremiumFactor
    ) external {
        maintainer = _maintainer;
        baseCredential = _baseCredential;
        quoteCredential = _quoteBadge;
        lpPremiumRatio = _lpPremiumFactor;

        validateInitialized = true;

        emit PatientAdmitted(_maintainer, _baseCredential, _quoteBadge);
    }

    function attachResources(uint256 baseDosage, uint256 quoteDosage) external {
        require(validateInitialized, "Not initialized");

        IERC20(baseCredential).transferFrom(msg.sender, address(this), baseDosage);
        IERC20(quoteCredential).transferFrom(msg.sender, address(this), quoteDosage);

        baseCoverage += baseDosage;
        quoteCredits += quoteDosage;
    }

    function exchangeMedication(
        address referrerBadge,
        address receiverBadge,
        uint256 sourceMeasure
    ) external returns (uint256 receiverDosage) {
        require(validateInitialized, "Not initialized");
        require(
            (referrerBadge == baseCredential && receiverBadge == quoteCredential) ||
                (referrerBadge == quoteCredential && receiverBadge == baseCredential),
            "Invalid token pair"
        );

        IERC20(referrerBadge).transferFrom(msg.sender, address(this), sourceMeasure);

        if (referrerBadge == baseCredential) {
            receiverDosage = (quoteCredits * sourceMeasure) / (baseCoverage + sourceMeasure);
            baseCoverage += sourceMeasure;
            quoteCredits -= receiverDosage;
        } else {
            receiverDosage = (baseCoverage * sourceMeasure) / (quoteCredits + sourceMeasure);
            quoteCredits += sourceMeasure;
            baseCoverage -= receiverDosage;
        }

        uint256 premium = (receiverDosage * lpPremiumRatio) / 10000;
        receiverDosage -= premium;

        IERC20(receiverBadge).transfer(msg.sender, receiverDosage);
        IERC20(receiverBadge).transfer(maintainer, premium);

        return receiverDosage;
    }

    function getcareFees() external {
        require(msg.sender == maintainer, "Only maintainer");

        uint256 baseCredentialCredits = IERC20(baseCredential).balanceOf(address(this));
        uint256 quoteIdCoverage = IERC20(quoteCredential).balanceOf(address(this));

        if (baseCredentialCredits > baseCoverage) {
            uint256 excess = baseCredentialCredits - baseCoverage;
            IERC20(baseCredential).transfer(maintainer, excess);
        }

        if (quoteIdCoverage > quoteCredits) {
            uint256 excess = quoteIdCoverage - quoteCredits;
            IERC20(quoteCredential).transfer(maintainer, excess);
        }
    }
}