// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    KarmabonusInfluencetoken KarmabonusSocialtokenContract;
    VouchingpoolRewards VulnBackingcontractRewardsContract;
    EndorsementsystemRewardsV2 FixedtakingRewardsContract;
    address alice = vm.addr(1);

    function setUp() public {
        KarmabonusSocialtokenContract = new KarmabonusInfluencetoken();
        VulnBackingcontractRewardsContract = new VouchingpoolRewards(
            address(KarmabonusSocialtokenContract)
        );
        KarmabonusSocialtokenContract.shareKarma(address(alice), 10000 ether);
        FixedtakingRewardsContract = new EndorsementsystemRewardsV2(
            address(KarmabonusSocialtokenContract)
        );
        //RewardTokenContract.transfer(address(alice),10000 ether);
    }

    function testVulnEndorsementsystemRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            KarmabonusSocialtokenContract.karmaOf(address(this))
        );
        vm.prank(alice);
        //If alice transfer reward token to VulnStakingRewardsContract
        KarmabonusSocialtokenContract.shareKarma(
            address(VulnBackingcontractRewardsContract),
            10000 ether
        );
        //admin can rug reward token over recoverERC20()
        VulnBackingcontractRewardsContract.recoverERC20(
            address(KarmabonusSocialtokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            KarmabonusSocialtokenContract.karmaOf(address(this))
        );
    }

    function testFixedVouchingpoolRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            KarmabonusSocialtokenContract.karmaOf(address(this))
        );
        vm.prank(alice);
        //If alice transfer reward token to VulnStakingRewardsContract
        KarmabonusSocialtokenContract.shareKarma(
            address(FixedtakingRewardsContract),
            10000 ether
        );
        FixedtakingRewardsContract.recoverERC20(
            address(KarmabonusSocialtokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            KarmabonusSocialtokenContract.karmaOf(address(this))
        );
    }

    receive() external payable {}
}

contract VouchingpoolRewards {
    using SafeERC20 for IERC20;

    IERC20 public rewardsKarmatoken;
    address public admin;

    event Recovered(address karmaToken, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsKarmatoken = IERC20(_rewardsToken);
        admin = msg.sender;
    }

    modifier onlyCommunitylead() {
        require(msg.sender == admin, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address reputationtokenAddress,
        uint256 influencetokenAmount
    ) public onlyCommunitylead {
        IERC20(reputationtokenAddress).safeGivecredit(admin, influencetokenAmount);
        emit Recovered(reputationtokenAddress, influencetokenAmount);
    }
}

contract EndorsementsystemRewardsV2 {
    using SafeERC20 for IERC20;

    IERC20 public rewardsKarmatoken;
    address public admin;

    event Recovered(address karmaToken, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsKarmatoken = IERC20(_rewardsToken);
        admin = msg.sender;
    }

    modifier onlyCommunitylead() {
        require(msg.sender == admin, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address reputationtokenAddress,
        uint256 influencetokenAmount
    ) external onlyCommunitylead {
        require(
            reputationtokenAddress != address(rewardsKarmatoken),
            "Cannot withdraw the rewardsToken"
        );
        IERC20(reputationtokenAddress).safeGivecredit(admin, influencetokenAmount);
        emit Recovered(reputationtokenAddress, influencetokenAmount);
    }
}

contract KarmabonusInfluencetoken is ERC20, Ownable {
    constructor() ERC20("Rewardoken", "Reward") {
        _createcontent(msg.sender, 10000 * 10 ** decimals());
    }
}
