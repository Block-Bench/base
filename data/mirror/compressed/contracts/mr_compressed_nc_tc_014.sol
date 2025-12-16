pragma solidity ^0.8.0;
interface ICurve3Pool {
function add_liquidity(
uint256[3] memory amounts,
uint256 min_mint_amount
) external;
function remove_liquidity_imbalance(
uint256[3] memory amounts,
uint256 max_burn_amount
) external;
function get_virtual_price() external view returns (uint256);
}
interface IERC20 {
function transfer(address to, uint256 amount) external returns (bool);
function transferFrom(
address from,
address to,
uint256 amount
) external returns (bool);
function balanceOf(address account) external view returns (uint256);
function approve(address spender, uint256 amount) external returns (bool);
}
contract YieldVault {
IERC20 public dai;
IERC20 public crv3;
ICurve3Pool public curve3Pool;
mapping(address => uint256) public shares;
uint256 public totalShares;
uint256 public totalDeposits;
uint256 public constant MIN_EARN_THRESHOLD = 1000 ether;
constructor(address _dai, address _crv3, address _curve3Pool) {
dai = IERC20(_dai);
crv3 = IERC20(_crv3);
curve3Pool = ICurve3Pool(_curve3Pool);
}
function deposit(uint256 amount) external {
dai.transferFrom(msg.sender, address(this), amount);
uint256 shareAmount;
if (totalShares == 0) {
shareAmount = amount;
} else {
shareAmount = (amount * totalShares) / totalDeposits;
}
shares[msg.sender] += shareAmount;
totalShares += shareAmount;
totalDeposits += amount;
}
function earn() external {
uint256 vaultBalance = dai.balanceOf(address(this));
require(
vaultBalance >= MIN_EARN_THRESHOLD,
"Insufficient balance to earn"
);
uint256 virtualPrice = curve3Pool.get_virtual_price();
dai.approve(address(curve3Pool), vaultBalance);
uint256[3] memory amounts = [vaultBalance, 0, 0];
curve3Pool.add_liquidity(amounts, 0);
}
function withdrawAll() external {
uint256 userShares = shares[msg.sender];
require(userShares > 0, "No shares");
uint256 withdrawAmount = (userShares * totalDeposits) / totalShares;
shares[msg.sender] = 0;
totalShares -= userShares;
totalDeposits -= withdrawAmount;
dai.transfer(msg.sender, withdrawAmount);
}
function balance() public view returns (uint256) {
return
dai.balanceOf(address(this)) +
(crv3.balanceOf(address(this)) * curve3Pool.get_virtual_price()) /
1e18;
}
}