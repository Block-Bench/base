// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


// ===== AUTO-GENERATED STUBS FOR STATIC ANALYSIS =====
interface IERC20 { function totalSupply() external view returns (uint256); function balanceOf(address) external view returns (uint256); function transfer(address, uint256) external returns (bool); function allowance(address, address) external view returns (uint256); function approve(address, uint256) external returns (bool); function transferFrom(address, address, uint256) external returns (bool); }
library SafeERC20 { function safeTransfer(IERC20 token, address to, uint256 value) internal {} function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {} function safeApprove(IERC20 token, address spender, uint256 value) internal {} }
abstract contract ERC20 { mapping(address => uint256) internal _balances; mapping(address => mapping(address => uint256)) internal _allowances; uint256 internal _totalSupply; string public name; string public symbol; uint8 public decimals; function totalSupply() public view virtual returns (uint256) { return _totalSupply; } function balanceOf(address account) public view virtual returns (uint256) { return _balances[account]; } function transfer(address to, uint256 amount) public virtual returns (bool) { return true; } function approve(address spender, uint256 amount) public virtual returns (bool) { return true; } function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) { return true; } }
abstract contract Ownable { address private _owner; modifier onlyOwner() { require(msg.sender == _owner); _; } function owner() public view returns (address) { return _owner; } function transferOwnership(address newOwner) public virtual onlyOwner { _owner = newOwner; } }
abstract contract Test {}
// ===== END STUBS =====


/*
Name: Incorrect implementation of the recoverERC20() function in the StakingRewards

Description:
The recoverERC20() function in StakingRewards.sol can potentially serve as a backdoor for the owner to retrieve rewardsToken.
There is no corresponding check against the rewardsToken. This creates an administrative privilege where the owner can sweep the rewards tokens, potentially using it as a means to exploit depositors.
It's similar to a forked issue if you forked vulnerable code.
 
Mitigation:  
disallowing recovery of the rewardToken within the recoverErc20 function

REF:
https://twitter.com/1nf0s3cpt/status/1680806251482189824
https://github.com/code-423n4/2022-02-concur-findings/issues/210
https://github.com/code-423n4/2022-09-y2k-finance-findings/issues/49
https://github.com/code-423n4/2022-10-paladin-findings/issues/40
https://blog.openzeppelin.com/across-token-and-token-distributor-audit#anyone-can-prevent-stakers-from-getting-their-rewards
*/

contract ContractTest is Test {
    RewardToken RewardTokenContract;
    VulnStakingRewards VulnStakingRewardsContract;
    FixedtakingRewards FixedtakingRewardsContract;
    address alice = vm.addr(1);

    function setUp() public {
        RewardTokenContract = new RewardToken();
        VulnStakingRewardsContract = new VulnStakingRewards(
            address(RewardTokenContract)
        );
        RewardTokenContract.transfer(address(alice), 10000 ether);
        FixedtakingRewardsContract = new FixedtakingRewards(
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

contract VulnStakingRewards {
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

contract FixedtakingRewards {
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