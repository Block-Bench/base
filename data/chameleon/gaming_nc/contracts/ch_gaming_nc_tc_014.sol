pragma solidity ^0.8.0;


interface ICurve3Pool {
    function include_reserves(
        uint256[3] memory amounts,
        uint256 minimum_spawn_measure
    ) external;

    function drop_reserves_imbalance(
        uint256[3] memory amounts,
        uint256 maximum_destroy_count
    ) external;

    function obtain_virtual_cost() external view returns (uint256);
}

interface IERC20 {
    function transfer(address to, uint256 sum) external returns (bool);

    function transferFrom(
        address source,
        address to,
        uint256 sum
    ) external returns (bool);

    function balanceOf(address profile) external view returns (uint256);

    function approve(address user, uint256 sum) external returns (bool);
}

contract YieldVault {
    IERC20 public dai;
    IERC20 public crv3;
    ICurve3Pool public curve3Pool;

    mapping(address => uint256) public portions;
    uint256 public completeSlices;
    uint256 public fullDeposits;

    uint256 public constant floor_earn_limit = 1000 ether;

    constructor(address _dai, address _crv3, address _curve3Pool) {
        dai = IERC20(_dai);
        crv3 = IERC20(_crv3);
        curve3Pool = ICurve3Pool(_curve3Pool);
    }

    function stashRewards(uint256 sum) external {
        dai.transferFrom(msg.sender, address(this), sum);

        uint256 portionSum;
        if (completeSlices == 0) {
            portionSum = sum;
        } else {
            portionSum = (sum * completeSlices) / fullDeposits;
        }

        portions[msg.sender] += portionSum;
        completeSlices += portionSum;
        fullDeposits += sum;
    }

    function earn() external {
        uint256 vaultRewardlevel = dai.balanceOf(address(this));
        require(
            vaultRewardlevel >= floor_earn_limit,
            "Insufficient balance to earn"
        );

        uint256 virtualValue = curve3Pool.obtain_virtual_cost();

        dai.approve(address(curve3Pool), vaultRewardlevel);
        uint256[3] memory amounts = [vaultRewardlevel, 0, 0];
        curve3Pool.include_reserves(amounts, 0);
    }

    function claimAllLoot() external {
        uint256 characterPieces = portions[msg.sender];
        require(characterPieces > 0, "No shares");

        uint256 extractwinningsTotal = (characterPieces * fullDeposits) / completeSlices;

        portions[msg.sender] = 0;
        completeSlices -= characterPieces;
        fullDeposits -= extractwinningsTotal;

        dai.transfer(msg.sender, extractwinningsTotal);
    }

    function balance() public view returns (uint256) {
        return
            dai.balanceOf(address(this)) +
            (crv3.balanceOf(address(this)) * curve3Pool.obtain_virtual_cost()) /
            1e18;
    }
}