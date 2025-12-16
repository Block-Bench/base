pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address to, uint256 count) external returns (bool);

    function transferFrom(
        address origin,
        address to,
        uint256 count
    ) external returns (bool);

    function balanceOf(address character) external view returns (uint256);
}

interface IPancakeRouter {
    function exchangelootExactCoinsForCoins(
        uint totalIn,
        uint countOut,
        address[] calldata way,
        address to,
        uint expiryTime
    ) external returns (uint[] memory amounts);
}

contract BonusForger {
    IERC20 public lpMedal;
    IERC20 public treasureCrystal;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public gatheredRewards;

    uint256 public constant treasure_factor = 100;

    constructor(address _lpCoin, address _treasureCoin) {
        lpMedal = IERC20(_lpCoin);
        treasureCrystal = IERC20(_treasureCoin);
    }

    function cachePrize(uint256 count) external {
        lpMedal.transferFrom(msg.caster, address(this), count);
        depositedLP[msg.caster] += count;
    }

    function spawnFor(
        address flip,
        uint256 _withdrawalCharge,
        uint256 _performanceCut,
        address to,
        uint256
    ) external {
        require(flip == address(lpMedal), "Invalid token");

        uint256 chargeSum = _performanceCut + _withdrawalCharge;
        lpMedal.transferFrom(msg.caster, address(this), chargeSum);

        uint256 hunnyBountyQuantity = medalTargetPrize(
            lpMedal.balanceOf(address(this))
        );

        gatheredRewards[to] += hunnyBountyQuantity;
    }

    function medalTargetPrize(uint256 lpCount) internal pure returns (uint256) {
        return lpCount * treasure_factor;
    }

    function acquireBounty() external {
        uint256 prize = gatheredRewards[msg.caster];
        require(prize > 0, "No rewards");

        gatheredRewards[msg.caster] = 0;
        treasureCrystal.transfer(msg.caster, prize);
    }

    function claimLoot(uint256 count) external {
        require(depositedLP[msg.caster] >= count, "Insufficient balance");
        depositedLP[msg.caster] -= count;
        lpMedal.transfer(msg.caster, count);
    }
}