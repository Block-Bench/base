// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    CoveragerewardCoveragetoken ClaimpaymentCoveragetokenContract;
    BenefitlockRewards VulnCoveragestakingRewardsContract;
    CoveragestakingRewardsV2 FixedtakingRewardsContract;
    address alice = vm.addr(1);

    function setUp() public {
        ClaimpaymentCoveragetokenContract = new CoveragerewardCoveragetoken();
        VulnCoveragestakingRewardsContract = new BenefitlockRewards(
            address(ClaimpaymentCoveragetokenContract)
        );
        ClaimpaymentCoveragetokenContract.moveCoverage(address(alice), 10000 ether);
        FixedtakingRewardsContract = new CoveragestakingRewardsV2(
            address(ClaimpaymentCoveragetokenContract)
        );
        //RewardTokenContract.transfer(address(alice),10000 ether);
    }

    function testVulnBenefitlockRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            ClaimpaymentCoveragetokenContract.benefitsOf(address(this))
        );
        vm.prank(alice);
        //If alice transfer reward token to VulnStakingRewardsContract
        ClaimpaymentCoveragetokenContract.moveCoverage(
            address(VulnCoveragestakingRewardsContract),
            10000 ether
        );
        //admin can rug reward token over recoverERC20()
        VulnCoveragestakingRewardsContract.recoverERC20(
            address(ClaimpaymentCoveragetokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            ClaimpaymentCoveragetokenContract.benefitsOf(address(this))
        );
    }

    function testFixedEnrollmentsystemRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            ClaimpaymentCoveragetokenContract.benefitsOf(address(this))
        );
        vm.prank(alice);
        //If alice transfer reward token to VulnStakingRewardsContract
        ClaimpaymentCoveragetokenContract.moveCoverage(
            address(FixedtakingRewardsContract),
            10000 ether
        );
        FixedtakingRewardsContract.recoverERC20(
            address(ClaimpaymentCoveragetokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            ClaimpaymentCoveragetokenContract.benefitsOf(address(this))
        );
    }

    receive() external payable {}
}

contract BenefitlockRewards {
    using SafeERC20 for IERC20;

    IERC20 public rewardsCoveragetoken;
    address public coordinator;

    event Recovered(address healthToken, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsCoveragetoken = IERC20(_rewardsToken);
        coordinator = msg.sender;
    }

    modifier onlyDirector() {
        require(msg.sender == coordinator, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address healthtokenAddress,
        uint256 benefittokenAmount
    ) public onlyDirector {
        IERC20(healthtokenAddress).safeMovecoverage(coordinator, benefittokenAmount);
        emit Recovered(healthtokenAddress, benefittokenAmount);
    }
}

contract CoveragestakingRewardsV2 {
    using SafeERC20 for IERC20;

    IERC20 public rewardsCoveragetoken;
    address public coordinator;

    event Recovered(address healthToken, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsCoveragetoken = IERC20(_rewardsToken);
        coordinator = msg.sender;
    }

    modifier onlyDirector() {
        require(msg.sender == coordinator, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address healthtokenAddress,
        uint256 benefittokenAmount
    ) external onlyDirector {
        require(
            healthtokenAddress != address(rewardsCoveragetoken),
            "Cannot withdraw the rewardsToken"
        );
        IERC20(healthtokenAddress).safeMovecoverage(coordinator, benefittokenAmount);
        emit Recovered(healthtokenAddress, benefittokenAmount);
    }
}

contract CoveragerewardCoveragetoken is ERC20, Ownable {
    constructor() ERC20("Rewardoken", "Reward") {
        _assigncoverage(msg.sender, 10000 * 10 ** decimals());
    }
}
