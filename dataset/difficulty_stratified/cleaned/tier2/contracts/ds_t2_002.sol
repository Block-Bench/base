// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ContractTest is Test {
    RewardToken RewardTokenContract;
    StakingRewards VulnStakingRewardsContract;
    StakingRewardsV2 FixedtakingRewardsContract;
    address alice = vm.addr(1);

    function setUp() public {
        RewardTokenContract = new RewardToken();
        VulnStakingRewardsContract = new StakingRewards(
            address(RewardTokenContract)
        );
        RewardTokenContract.transfer(address(alice), 10000 ether);
        FixedtakingRewardsContract = new StakingRewardsV2(
            address(RewardTokenContract)
        );
        //RewardTokenContract.transfer(address(alice),10000 ether);
    }

    function testVulnStakingRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            RewardTokenContract.balanceOf(address(this))
        );
        vm.prank(alice);
        //If alice transfer reward token to VulnStakingRewardsContract
        RewardTokenContract.transfer(
            address(VulnStakingRewardsContract),
            10000 ether
        );
        //admin can rug reward token over recoverERC20()
        VulnStakingRewardsContract.recoverERC20(
            address(RewardTokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            RewardTokenContract.balanceOf(address(this))
        );
    }

    function testFixedStakingRewards() public {
        console.log(
            "Before rug RewardToken balance in VulnStakingRewardsContract",
            RewardTokenContract.balanceOf(address(this))
        );
        vm.prank(alice);
        //If alice transfer reward token to VulnStakingRewardsContract
        RewardTokenContract.transfer(
            address(FixedtakingRewardsContract),
            10000 ether
        );
        FixedtakingRewardsContract.recoverERC20(
            address(RewardTokenContract),
            1000 ether
        );
        console.log(
            "After rug RewardToken balance in VulnStakingRewardsContract",
            RewardTokenContract.balanceOf(address(this))
        );
    }

    receive() external payable {}
}

contract StakingRewards {
    using SafeERC20 for IERC20;

    IERC20 public rewardsToken;
    address public owner;

    event Recovered(address token, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsToken = IERC20(_rewardsToken);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    ) public onlyOwner {
        IERC20(tokenAddress).safeTransfer(owner, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }
}

contract StakingRewardsV2 {
    using SafeERC20 for IERC20;

    IERC20 public rewardsToken;
    address public owner;

    event Recovered(address token, uint256 amount);

    constructor(address _rewardsToken) {
        rewardsToken = IERC20(_rewardsToken);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function recoverERC20(
        address tokenAddress,
        uint256 tokenAmount
    ) external onlyOwner {
        require(
            tokenAddress != address(rewardsToken),
            "Cannot withdraw the rewardsToken"
        );
        IERC20(tokenAddress).safeTransfer(owner, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }
}

contract RewardToken is ERC20, Ownable {
    constructor() ERC20("Rewardoken", "Reward") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
}