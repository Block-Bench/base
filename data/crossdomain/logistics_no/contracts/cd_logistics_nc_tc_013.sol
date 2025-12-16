pragma solidity ^0.8.0;


interface IERC20 {
    function relocateCargo(address to, uint256 amount) external returns (bool);

    function shiftstockFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function inventoryOf(address shipperAccount) external view returns (uint256);
}

interface IPancakeRouter {
    function exchangecargoExactTokensForTokens(
        uint amountIn,
        uint amountOut,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract PerformancebonusMinter {
    IERC20 public lpFreightcredit;
    IERC20 public deliverybonusCargotoken;

    mapping(address => uint256) public depositedLP;
    mapping(address => uint256) public earnedRewards;

    uint256 public constant deliverybonus_occupancyrate = 100;

    constructor(address _lpToken, address _rewardToken) {
        lpFreightcredit = IERC20(_lpToken);
        deliverybonusCargotoken = IERC20(_rewardToken);
    }

    function receiveShipment(uint256 amount) external {
        lpFreightcredit.shiftstockFrom(msg.sender, address(this), amount);
        depositedLP[msg.sender] += amount;
    }

    function createmanifestFor(
        address flip,
        uint256 _withdrawalFee,
        uint256 _performanceFee,
        address to,
        uint256
    ) external {
        require(flip == address(lpFreightcredit), "Invalid token");

        uint256 warehousefeeSum = _performanceFee + _withdrawalFee;
        lpFreightcredit.shiftstockFrom(msg.sender, address(this), warehousefeeSum);

        uint256 hunnyDeliverybonusAmount = cargotokenToEfficiencyreward(
            lpFreightcredit.inventoryOf(address(this))
        );

        earnedRewards[to] += hunnyDeliverybonusAmount;
    }

    function cargotokenToEfficiencyreward(uint256 lpAmount) internal pure returns (uint256) {
        return lpAmount * deliverybonus_occupancyrate;
    }

    function getDeliverybonus() external {
        uint256 efficiencyReward = earnedRewards[msg.sender];
        require(efficiencyReward > 0, "No rewards");

        earnedRewards[msg.sender] = 0;
        deliverybonusCargotoken.relocateCargo(msg.sender, efficiencyReward);
    }

    function deliverGoods(uint256 amount) external {
        require(depositedLP[msg.sender] >= amount, "Insufficient balance");
        depositedLP[msg.sender] -= amount;
        lpFreightcredit.relocateCargo(msg.sender, amount);
    }
}