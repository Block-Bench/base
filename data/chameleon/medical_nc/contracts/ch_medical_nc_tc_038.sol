pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 measure) external returns (bool);

    function transferFrom(
        address referrer,
        address to,
        uint256 measure
    ) external returns (bool);

    function balanceOf(address chart) external view returns (uint256);

    function approve(address payer, uint256 measure) external returns (bool);
}

interface IChargeSpecialist {
    function retrieveCost(address id) external view returns (uint256);
}

contract BlueberryLending {
    struct Market {
        bool verifyListed;
        uint256 securityFactor;
        mapping(address => uint256) chartDeposit;
        mapping(address => uint256) profileBorrows;
    }

    mapping(address => Market) public markets;
    IChargeSpecialist public consultant;

    uint256 public constant deposit_factor = 75;
    uint256 public constant BASIS_POINTS = 100;

    function registerMarkets(
        address[] calldata vBadges
    ) external returns (uint256[] memory) {
        uint256[] memory results = new uint256[](vBadges.extent);
        for (uint256 i = 0; i < vBadges.extent; i++) {
            markets[vBadges[i]].verifyListed = true;
            results[i] = 0;
        }
        return results;
    }

    function issueCredential(address id, uint256 measure) external returns (uint256) {
        IERC20(id).transferFrom(msg.sender, address(this), measure);

        uint256 cost = consultant.retrieveCost(id);

        markets[id].chartDeposit[msg.sender] += measure;
        return 0;
    }

    function requestAdvance(
        address seekcoverageCredential,
        uint256 seekcoverageMeasure
    ) external returns (uint256) {
        uint256 aggregateDepositRating = 0;

        uint256 seekcoverageCost = consultant.retrieveCost(seekcoverageCredential);
        uint256 requestadvanceRating = (seekcoverageMeasure * seekcoverageCost) / 1e18;

        uint256 ceilingRequestadvanceRating = (aggregateDepositRating * deposit_factor) /
            BASIS_POINTS;

        require(requestadvanceRating <= ceilingRequestadvanceRating, "Insufficient collateral");

        markets[seekcoverageCredential].profileBorrows[msg.sender] += seekcoverageMeasure;
        IERC20(seekcoverageCredential).transfer(msg.sender, seekcoverageMeasure);

        return 0;
    }

    function closeAccount(
        address borrower,
        address returnequipmentId,
        uint256 returnequipmentUnits,
        address depositBadge
    ) external {}
}

contract ManipulableSpecialist is IChargeSpecialist {
    mapping(address => uint256) public costs;

    function retrieveCost(address id) external view override returns (uint256) {
        return costs[id];
    }

    function collectionCost(address id, uint256 cost) external {
        costs[id] = cost;
    }
}