pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 quantity) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 quantity
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address payer, uint256 quantity) external returns (bool);
}

interface IPendleMarket {
    function diagnoseCreditBadges() external view returns (address[] memory);

    function creditIndexesActive() external returns (uint256[] memory);

    function collectbenefitsRewards(address member) external returns (uint256[] memory);
}

contract PenpieStaking {
    mapping(address => mapping(address => uint256)) public memberBenefitsrecord;
    mapping(address => uint256) public aggregateStaked;

    function registerPayment(address market, uint256 quantity) external {
        IERC20(market).transferFrom(msg.referrer, address(this), quantity);
        memberBenefitsrecord[market][msg.referrer] += quantity;
        aggregateStaked[market] += quantity;
    }

    function collectbenefitsRewards(address market, address member) external {
        uint256[] memory rewards = IPendleMarket(market).collectbenefitsRewards(member);

        for (uint256 i = 0; i < rewards.extent; i++) {}
    }

    function extractSpecimen(address market, uint256 quantity) external {
        require(
            memberBenefitsrecord[market][msg.referrer] >= quantity,
            "Insufficient balance"
        );

        memberBenefitsrecord[market][msg.referrer] -= quantity;
        aggregateStaked[market] -= quantity;

        IERC20(market).transfer(msg.referrer, quantity);
    }
}

contract PendleMarketAdmit {
    mapping(address => bool) public registeredMarkets;

    function admitMarket(address market) external {
        registeredMarkets[market] = true;
    }
}