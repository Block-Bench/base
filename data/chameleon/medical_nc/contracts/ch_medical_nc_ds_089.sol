pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract AgreementTest is Test {
    BenefitId CreditCredentialPolicy;
    StakingRewards VulnStakingRewardsPolicy;
    StakingRewardsV2 FixedtakingRewardsAgreement;
    address alice = vm.addr(1);

    function collectionUp() public {
        CreditCredentialPolicy = new BenefitId();
        VulnStakingRewardsPolicy = new StakingRewards(
            address(CreditCredentialPolicy)
        );
        CreditCredentialPolicy.transfer(address(alice), 10000 ether);
        FixedtakingRewardsAgreement = new StakingRewardsV2(
            address(CreditCredentialPolicy)
        );

    }

    function testVulnStakingRewards() public {
        console.record(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            CreditCredentialPolicy.balanceOf(address(this))
        );
        vm.prank(alice);

        CreditCredentialPolicy.transfer(
            address(VulnStakingRewardsPolicy),
            10000 ether
        );

        VulnStakingRewardsPolicy.healErc20(
            address(CreditCredentialPolicy),
            1000 ether
        );
        console.record(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            CreditCredentialPolicy.balanceOf(address(this))
        );
    }

    function testFixedStakingRewards() public {
        console.record(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            CreditCredentialPolicy.balanceOf(address(this))
        );
        vm.prank(alice);

        CreditCredentialPolicy.transfer(
            address(FixedtakingRewardsAgreement),
            10000 ether
        );
        FixedtakingRewardsAgreement.healErc20(
            address(CreditCredentialPolicy),
            1000 ether
        );
        console.record(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            CreditCredentialPolicy.balanceOf(address(this))
        );
    }

    receive() external payable {}
}

contract StakingRewards {
    using SafeERC20 for IERC20;

    IERC20 public rewardsCredential;
    address public owner;

    event Recovered(address id, uint256 quantity);

    constructor(address _rewardsId) {
        rewardsCredential = IERC20(_rewardsId);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function healErc20(
        address badgeLocation,
        uint256 idMeasure
    ) public onlyOwner {
        IERC20(badgeLocation).secureReferral(owner, idMeasure);
        emit Recovered(badgeLocation, idMeasure);
    }
}

contract StakingRewardsV2 {
    using SafeERC20 for IERC20;

    IERC20 public rewardsCredential;
    address public owner;

    event Recovered(address id, uint256 quantity);

    constructor(address _rewardsId) {
        rewardsCredential = IERC20(_rewardsId);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function healErc20(
        address badgeLocation,
        uint256 idMeasure
    ) external onlyOwner {
        require(
            badgeLocation != address(rewardsCredential),
            "Cannot withdraw the rewardsToken"
        );
        IERC20(badgeLocation).secureReferral(owner, idMeasure);
        emit Recovered(badgeLocation, idMeasure);
    }
}

contract BenefitId is ERC20, Ownable {
    constructor() ERC20("Rewardoken", "Reward") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
}