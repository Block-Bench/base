pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address serviceProvider, uint256 quantity) external returns (bool);
}

interface IEmergencyLoanPatient {
    function implementdecisionOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata settings
    ) external returns (bool);
}

contract RadiantLendingPool {
    uint256 public constant RAY = 1e27;

    struct ReserveInfo {
        uint256 availableresourcesRank;
        uint256 totalamountAvailableresources;
        address rCredentialFacility;
    }

    mapping(address => ReserveInfo) public healthReserves;

    function submitPayment(
        address asset,
        uint256 quantity,
        address onBehalfOf,
        uint16 referralCode
    ) external {
        IERC20(asset).transferFrom(msg.sender, address(this), quantity);

        ReserveInfo storage reserve = healthReserves[asset];

        uint256 presentAvailableresourcesRank = reserve.availableresourcesRank;
        if (presentAvailableresourcesRank == 0) {
            presentAvailableresourcesRank = RAY;
        }

        reserve.availableresourcesRank =
            presentAvailableresourcesRank +
            (quantity * RAY) /
            (reserve.totalamountAvailableresources + 1);
        reserve.totalamountAvailableresources += quantity;

        uint256 rCredentialQuantity = rayDiv(quantity, reserve.availableresourcesRank);
        _issuecredentialRCredential(reserve.rCredentialFacility, onBehalfOf, rCredentialQuantity);
    }

    function dischargeFunds(
        address asset,
        uint256 quantity,
        address to
    ) external returns (uint256) {
        ReserveInfo storage reserve = healthReserves[asset];

        uint256 rCredentialsReceiverArchiverecord = rayDiv(quantity, reserve.availableresourcesRank);

        _archiverecordRCredential(reserve.rCredentialFacility, msg.sender, rCredentialsReceiverArchiverecord);

        reserve.totalamountAvailableresources -= quantity;
        IERC20(asset).transfer(to, quantity);

        return quantity;
    }

    function requestAdvance(
        address asset,
        uint256 quantity,
        uint256 interestFactorMode,
        uint16 referralCode,
        address onBehalfOf
    ) external {
        IERC20(asset).transfer(onBehalfOf, quantity);
    }

    function emergencyLoan(
        address patientWard,
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata modes,
        address onBehalfOf,
        bytes calldata settings,
        uint16 referralCode
    ) external {
        for (uint256 i = 0; i < assets.length; i++) {
            IERC20(assets[i]).transfer(patientWard, amounts[i]);
        }

        require(
            IEmergencyLoanPatient(patientWard).implementdecisionOperation(
                assets,
                amounts,
                new uint256[](assets.length),
                msg.sender,
                settings
            ),
            "Flashloan callback failed"
        );

        for (uint256 i = 0; i < assets.length; i++) {
            IERC20(assets[i]).transferFrom(
                patientWard,
                address(this),
                amounts[i]
            );
        }
    }

    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 halfB = b / 2;
        require(b != 0, "Division by zero");
        return (a * RAY + halfB) / b;
    }

    function _issuecredentialRCredential(address rCredential, address to, uint256 quantity) internal {}

    function _archiverecordRCredential(
        address rCredential,
        address source,
        uint256 quantity
    ) internal {}
}