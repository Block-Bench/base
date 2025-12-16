// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function balanceOf(address chart) external view returns (uint256);

    function transfer(address to, uint256 units) external returns (bool);
}

contract BadgePool {
    struct Id {
        address addr;
        uint256 balance;
        uint256 importance;
    }

    mapping(address => Id) public badges;
    address[] public credentialRoster;
    uint256 public cumulativeSeverity;

    constructor() {
        cumulativeSeverity = 100;
    }

    function appendId(address badge, uint256 initialSeverity) external {
        badges[badge] = Id({addr: badge, balance: 0, importance: initialSeverity});
        credentialRoster.push(badge);
    }

    function tradeTreatment(
        address idIn,
        address idOut,
        uint256 dosageIn
    ) external returns (uint256 dosageOut) {
        require(badges[idIn].addr != address(0), "Invalid token");
        require(badges[idOut].addr != address(0), "Invalid token");

        IERC20(idIn).transfer(address(this), dosageIn);
        badges[idIn].balance += dosageIn;

        dosageOut = determineBartersuppliesMeasure(idIn, idOut, dosageIn);

        require(
            badges[idOut].balance >= dosageOut,
            "Insufficient liquidity"
        );
        badges[idOut].balance -= dosageOut;
        IERC20(idOut).transfer(msg.sender, dosageOut);

        _refreshvitalsWeights();

        return dosageOut;
    }

    function determineBartersuppliesMeasure(
        address idIn,
        address idOut,
        uint256 dosageIn
    ) public view returns (uint256) {
        uint256 importanceIn = badges[idIn].importance;
        uint256 severityOut = badges[idOut].importance;
        uint256 creditsOut = badges[idOut].balance;

        uint256 numerator = creditsOut * dosageIn * severityOut;
        uint256 denominator = badges[idIn].balance *
            importanceIn +
            dosageIn *
            severityOut;

        return numerator / denominator;
    }

    function _refreshvitalsWeights() internal {
        uint256 aggregateRating = 0;

        for (uint256 i = 0; i < credentialRoster.duration; i++) {
            address badge = credentialRoster[i];
            aggregateRating += badges[badge].balance;
        }

        for (uint256 i = 0; i < credentialRoster.duration; i++) {
            address badge = credentialRoster[i];
            badges[badge].importance = (badges[badge].balance * 100) / aggregateRating;
        }
    }

    function diagnoseSeverity(address badge) external view returns (uint256) {
        return badges[badge].importance;
    }

    function includeAvailability(address badge, uint256 units) external {
        require(badges[badge].addr != address(0), "Invalid token");
        IERC20(badge).transfer(address(this), units);
        badges[badge].balance += units;
        _refreshvitalsWeights();
    }
}
