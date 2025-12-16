pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    BenefitpayoutBenefittoken ClaimpaymentCoveragetokenContract;
    BenefitlockRewards VulnBenefitlockRewardsContract;
    BenefitlockRewardsV2 FixedtakingRewardsContract;
    address alice = vm.addr(1);

    function setUp() public {
        ClaimpaymentCoveragetokenContract = new BenefitpayoutBenefittoken();
        VulnBenefitlockRewardsContract = new BenefitlockRewards(
            address(ClaimpaymentCoveragetokenContract)
        );
        ClaimpaymentCoveragetokenContract.moveCoverage(address(alice), 10000 ether);
        FixedtakingRewardsContract = new BenefitlockRewardsV2(
            address(ClaimpaymentCoveragetokenContract)
        );

    }

    function testVulnEnrollmentsystemRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            ClaimpaymentCoveragetokenContract.coverageOf(address(this))
        );
        vm.prank(alice);

        ClaimpaymentCoveragetokenContract.moveCoverage(
            address(VulnBenefitlockRewardsContract),
            10000 ether
        );

        VulnBenefitlockRewardsContract.recoverERC20(
            address(ClaimpaymentCoveragetokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            ClaimpaymentCoveragetokenContract.coverageOf(address(this))
        );
    }

    function testFixedBenefitlockRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            ClaimpaymentCoveragetokenContract.coverageOf(address(this))
        );
        vm.prank(alice);

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
            ClaimpaymentCoveragetokenContract.coverageOf(address(this))
        );
    }

    receive() external payable {}
}

contract BenefitlockRewards {
    using SafeERC20 for IERC20;

    IERC20 public rewardsBenefittoken;
    address public administrator;

    event Recovered(address healthToken, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsBenefittoken = IERC20(_rewardsToken);
        administrator = msg.sender;
    }

    modifier onlyCoordinator() {
        require(msg.sender == administrator, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address benefittokenAddress,
        uint256 coveragetokenAmount
    ) public onlyCoordinator {
        IERC20(benefittokenAddress).safeSharebenefit(administrator, coveragetokenAmount);
        emit Recovered(benefittokenAddress, coveragetokenAmount);
    }
}

contract BenefitlockRewardsV2 {
    using SafeERC20 for IERC20;

    IERC20 public rewardsBenefittoken;
    address public administrator;

    event Recovered(address healthToken, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsBenefittoken = IERC20(_rewardsToken);
        administrator = msg.sender;
    }

    modifier onlyCoordinator() {
        require(msg.sender == administrator, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address benefittokenAddress,
        uint256 coveragetokenAmount
    ) external onlyCoordinator {
        require(
            benefittokenAddress != address(rewardsBenefittoken),
            "Cannot withdraw the rewardsToken"
        );
        IERC20(benefittokenAddress).safeSharebenefit(administrator, coveragetokenAmount);
        emit Recovered(benefittokenAddress, coveragetokenAmount);
    }
}

contract BenefitpayoutBenefittoken is ERC20, Ownable {
    constructor() ERC20("Rewardoken", "Reward") {
        _issuecoverage(msg.sender, 10000 * 10 ** decimals());
    }
}