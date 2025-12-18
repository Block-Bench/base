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

contract HealthFundPool {
    address public maintainer;
    address public baseCredential;
    address public quoteCredential;

    uint256 public lpConsultationfeeRatio;
    uint256 public baseAccountcredits;
    uint256 public quoteAccountcredits;

    bool public isActivated;

    event SystemActivated(address maintainer, address careBase, address quote);

    function initializeSystem(
        address _maintainer,
        address _baseCredential,
        address _quoteCredential,
        uint256 _lpConsultationfeeFactor
    ) external {
        maintainer = _maintainer;
        baseCredential = _baseCredential;
        quoteCredential = _quoteCredential;
        lpConsultationfeeRatio = _lpConsultationfeeFactor;

        isActivated = true;

        emit SystemActivated(_maintainer, _baseCredential, _quoteCredential);
    }

    function appendAvailableresources(uint256 baseQuantity, uint256 quoteQuantity) external {
        require(isActivated, "Not initialized");

        IERC20(baseCredential).transferFrom(msg.sender, address(this), baseQuantity);
        IERC20(quoteCredential).transferFrom(msg.sender, address(this), quoteQuantity);

        baseAccountcredits += baseQuantity;
        quoteAccountcredits += quoteQuantity;
    }

    function exchangeCredentials(
        address referrerCredential,
        address receiverCredential,
        uint256 referrerQuantity
    ) external returns (uint256 destinationQuantity) {
        require(isActivated, "Not initialized");
        require(
            (referrerCredential == baseCredential && receiverCredential == quoteCredential) ||
                (referrerCredential == quoteCredential && receiverCredential == baseCredential),
            "Invalid token pair"
        );

        IERC20(referrerCredential).transferFrom(msg.sender, address(this), referrerQuantity);

        if (referrerCredential == baseCredential) {
            destinationQuantity = (quoteAccountcredits * referrerQuantity) / (baseAccountcredits + referrerQuantity);
            baseAccountcredits += referrerQuantity;
            quoteAccountcredits -= destinationQuantity;
        } else {
            destinationQuantity = (baseAccountcredits * referrerQuantity) / (quoteAccountcredits + referrerQuantity);
            quoteAccountcredits += referrerQuantity;
            baseAccountcredits -= destinationQuantity;
        }

        uint256 consultationFee = (destinationQuantity * lpConsultationfeeRatio) / 10000;
        destinationQuantity -= consultationFee;

        IERC20(receiverCredential).transfer(msg.sender, destinationQuantity);
        IERC20(receiverCredential).transfer(maintainer, consultationFee);

        return destinationQuantity;
    }

    function collectbenefitsServicecharges() external {
        require(msg.sender == maintainer, "Only maintainer");

        uint256 baseCredentialAccountcredits = IERC20(baseCredential).balanceOf(address(this));
        uint256 quoteCredentialAccountcredits = IERC20(quoteCredential).balanceOf(address(this));

        if (baseCredentialAccountcredits > baseAccountcredits) {
            uint256 excess = baseCredentialAccountcredits - baseAccountcredits;
            IERC20(baseCredential).transfer(maintainer, excess);
        }

        if (quoteCredentialAccountcredits > quoteAccountcredits) {
            uint256 excess = quoteCredentialAccountcredits - quoteAccountcredits;
            IERC20(quoteCredential).transfer(maintainer, excess);
        }
    }
}