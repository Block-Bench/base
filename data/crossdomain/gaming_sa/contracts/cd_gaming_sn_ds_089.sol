// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    QuestrewardRealmcoin QuestrewardQuesttokenContract;
    BettingpoolRewards VulnStakearenaRewardsContract;
    WagersystemRewardsV2 FixedtakingRewardsContract;
    address alice = vm.addr(1);

    function setUp() public {
        QuestrewardQuesttokenContract = new QuestrewardRealmcoin();
        VulnStakearenaRewardsContract = new BettingpoolRewards(
            address(QuestrewardQuesttokenContract)
        );
        QuestrewardQuesttokenContract.giveItems(address(alice), 10000 ether);
        FixedtakingRewardsContract = new WagersystemRewardsV2(
            address(QuestrewardQuesttokenContract)
        );
        //RewardTokenContract.transfer(address(alice),10000 ether);
    }

    function testVulnWagersystemRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            QuestrewardQuesttokenContract.goldholdingOf(address(this))
        );
        vm.prank(alice);
        //If alice transfer reward token to VulnStakingRewardsContract
        QuestrewardQuesttokenContract.giveItems(
            address(VulnStakearenaRewardsContract),
            10000 ether
        );
        //admin can rug reward token over recoverERC20()
        VulnStakearenaRewardsContract.recoverERC20(
            address(QuestrewardQuesttokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            QuestrewardQuesttokenContract.goldholdingOf(address(this))
        );
    }

    function testFixedBettingpoolRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            QuestrewardQuesttokenContract.goldholdingOf(address(this))
        );
        vm.prank(alice);
        //If alice transfer reward token to VulnStakingRewardsContract
        QuestrewardQuesttokenContract.giveItems(
            address(FixedtakingRewardsContract),
            10000 ether
        );
        FixedtakingRewardsContract.recoverERC20(
            address(QuestrewardQuesttokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            QuestrewardQuesttokenContract.goldholdingOf(address(this))
        );
    }

    receive() external payable {}
}

contract BettingpoolRewards {
    using SafeERC20 for IERC20;

    IERC20 public rewardsGamecoin;
    address public dungeonMaster;

    event Recovered(address gameCoin, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsGamecoin = IERC20(_rewardsToken);
        dungeonMaster = msg.sender;
    }

    modifier onlyGuildleader() {
        require(msg.sender == dungeonMaster, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address goldtokenAddress,
        uint256 realmcoinAmount
    ) public onlyGuildleader {
        IERC20(goldtokenAddress).safeTradeloot(dungeonMaster, realmcoinAmount);
        emit Recovered(goldtokenAddress, realmcoinAmount);
    }
}

contract WagersystemRewardsV2 {
    using SafeERC20 for IERC20;

    IERC20 public rewardsGamecoin;
    address public dungeonMaster;

    event Recovered(address gameCoin, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsGamecoin = IERC20(_rewardsToken);
        dungeonMaster = msg.sender;
    }

    modifier onlyGuildleader() {
        require(msg.sender == dungeonMaster, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address goldtokenAddress,
        uint256 realmcoinAmount
    ) external onlyGuildleader {
        require(
            goldtokenAddress != address(rewardsGamecoin),
            "Cannot withdraw the rewardsToken"
        );
        IERC20(goldtokenAddress).safeTradeloot(dungeonMaster, realmcoinAmount);
        emit Recovered(goldtokenAddress, realmcoinAmount);
    }
}

contract QuestrewardRealmcoin is ERC20, Ownable {
    constructor() ERC20("Rewardoken", "Reward") {
        _generateloot(msg.sender, 10000 * 10 ** decimals());
    }
}
