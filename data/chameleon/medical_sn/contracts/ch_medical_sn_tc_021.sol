// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address profile) external view returns (uint256);

    function transfer(address to, uint256 dosage) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 dosage
    ) external returns (bool);
}

contract ResourcesPool {
    address public maintainer;
    address public baseBadge;
    address public quoteCredential;

    uint256 public lpChargeRatio;
    uint256 public baseFunds;
    uint256 public quoteCredits;

    bool public verifyInitialized;

    event CaseOpened(address maintainer, address careBase, address quote);

    function init(
        address _maintainer,
        address _baseCredential,
        address _quoteId,
        uint256 _lpPremiumFrequency
    ) external {
        maintainer = _maintainer;
        baseBadge = _baseCredential;
        quoteCredential = _quoteId;
        lpChargeRatio = _lpPremiumFrequency;

        verifyInitialized = true;

        emit CaseOpened(_maintainer, _baseCredential, _quoteId);
    }

    function includeAvailability(uint256 baseQuantity, uint256 quoteUnits) external {
        require(verifyInitialized, "Not initialized");

        IERC20(baseBadge).transferFrom(msg.sender, address(this), baseQuantity);
        IERC20(quoteCredential).transferFrom(msg.sender, address(this), quoteUnits);

        baseFunds += baseQuantity;
        quoteCredits += quoteUnits;
    }

    function tradeTreatment(
        address referrerBadge,
        address destinationBadge,
        uint256 referrerUnits
    ) external returns (uint256 receiverDosage) {
        require(verifyInitialized, "Not initialized");
        require(
            (referrerBadge == baseBadge && destinationBadge == quoteCredential) ||
                (referrerBadge == quoteCredential && destinationBadge == baseBadge),
            "Invalid token pair"
        );

        IERC20(referrerBadge).transferFrom(msg.sender, address(this), referrerUnits);

        if (referrerBadge == baseBadge) {
            receiverDosage = (quoteCredits * referrerUnits) / (baseFunds + referrerUnits);
            baseFunds += referrerUnits;
            quoteCredits -= receiverDosage;
        } else {
            receiverDosage = (baseFunds * referrerUnits) / (quoteCredits + referrerUnits);
            quoteCredits += referrerUnits;
            baseFunds -= receiverDosage;
        }

        uint256 premium = (receiverDosage * lpChargeRatio) / 10000;
        receiverDosage -= premium;

        IERC20(destinationBadge).transfer(msg.sender, receiverDosage);
        IERC20(destinationBadge).transfer(maintainer, premium);

        return receiverDosage;
    }

    function getcareFees() external {
        require(msg.sender == maintainer, "Only maintainer");

        uint256 baseBadgeFunds = IERC20(baseBadge).balanceOf(address(this));
        uint256 quoteBadgeCoverage = IERC20(quoteCredential).balanceOf(address(this));

        if (baseBadgeFunds > baseFunds) {
            uint256 excess = baseBadgeFunds - baseFunds;
            IERC20(baseBadge).transfer(maintainer, excess);
        }

        if (quoteBadgeCoverage > quoteCredits) {
            uint256 excess = quoteBadgeCoverage - quoteCredits;
            IERC20(quoteCredential).transfer(maintainer, excess);
        }
    }
}
