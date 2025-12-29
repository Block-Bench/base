/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IERC20 {
/*LN-5*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-6*/ 
/*LN-7*/     function transferFrom(
/*LN-8*/         address from,
/*LN-9*/         address to,
/*LN-10*/         uint256 amount
/*LN-11*/     ) external returns (bool);
/*LN-12*/ 
/*LN-13*/     function balanceOf(address account) external view returns (uint256);
/*LN-14*/ 
/*LN-15*/     function approve(address spender, uint256 amount) external returns (bool);
/*LN-16*/ }
/*LN-17*/ 
/*LN-18*/ contract CollateralToken is IERC20 {
/*LN-19*/     string public name = "Shezmu Collateral Token";
/*LN-20*/     string public symbol = "SCT";
/*LN-21*/     uint8 public decimals = 18;
/*LN-22*/ 
/*LN-23*/     mapping(address => uint256) public balanceOf;
/*LN-24*/     mapping(address => mapping(address => uint256)) public allowance;
/*LN-25*/     uint256 public totalSupply;
/*LN-26*/ 
/*LN-27*/     function mint(address to, uint256 amount) external {
/*LN-28*/ 
/*LN-29*/         // Should have: require(msg.sender == owner, "Only owner");
/*LN-30*/         // or: require(hasRole(MINTER_ROLE, msg.sender), "Not authorized");
/*LN-31*/ 
/*LN-32*/         // Can mint type(uint128).max worth of tokens
/*LN-33*/ 
/*LN-34*/         balanceOf[to] += amount;
/*LN-35*/         totalSupply += amount;
/*LN-36*/     }
/*LN-37*/ 
/*LN-38*/     function transfer(
/*LN-39*/         address to,
/*LN-40*/         uint256 amount
/*LN-41*/     ) external override returns (bool) {
/*LN-42*/         require(balanceOf[msg.sender] >= amount, "Insufficient balance");
/*LN-43*/         balanceOf[msg.sender] -= amount;
/*LN-44*/         balanceOf[to] += amount;
/*LN-45*/         return true;
/*LN-46*/     }
/*LN-47*/ 
/*LN-48*/     function transferFrom(
/*LN-49*/         address from,
/*LN-50*/         address to,
/*LN-51*/         uint256 amount
/*LN-52*/     ) external override returns (bool) {
/*LN-53*/         require(balanceOf[from] >= amount, "Insufficient balance");
/*LN-54*/         require(
/*LN-55*/             allowance[from][msg.sender] >= amount,
/*LN-56*/             "Insufficient allowance"
/*LN-57*/         );
/*LN-58*/         balanceOf[from] -= amount;
/*LN-59*/         balanceOf[to] += amount;
/*LN-60*/         allowance[from][msg.sender] -= amount;
/*LN-61*/         return true;
/*LN-62*/     }
/*LN-63*/ 
/*LN-64*/     function approve(
/*LN-65*/         address spender,
/*LN-66*/         uint256 amount
/*LN-67*/     ) external override returns (bool) {
/*LN-68*/         allowance[msg.sender][spender] = amount;
/*LN-69*/         return true;
/*LN-70*/     }
/*LN-71*/ }
/*LN-72*/ 
/*LN-73*/ contract CollateralVault {
/*LN-74*/     IERC20 public collateralToken;
/*LN-75*/     IERC20 public shezUSD;
/*LN-76*/ 
/*LN-77*/     mapping(address => uint256) public collateralBalance;
/*LN-78*/     mapping(address => uint256) public debtBalance;
/*LN-79*/ 
/*LN-80*/     uint256 public constant COLLATERAL_RATIO = 150;
/*LN-81*/     uint256 public constant BASIS_POINTS = 100;
/*LN-82*/ 
/*LN-83*/     constructor(address _collateralToken, address _shezUSD) {
/*LN-84*/         collateralToken = IERC20(_collateralToken);
/*LN-85*/         shezUSD = IERC20(_shezUSD);
/*LN-86*/     }
/*LN-87*/ 
/*LN-88*/     /**
/*LN-89*/      * @notice Add collateral to vault
/*LN-90*/      */
/*LN-91*/     function addCollateral(uint256 amount) external {
/*LN-92*/         collateralToken.transferFrom(msg.sender, address(this), amount);
/*LN-93*/         collateralBalance[msg.sender] += amount;
/*LN-94*/     }
/*LN-95*/ 
/*LN-96*/     function borrow(uint256 amount) external {
/*LN-97*/ 
/*LN-98*/         // No way to validate if collateral was minted through proper channels
/*LN-99*/ 
/*LN-100*/         uint256 maxBorrow = (collateralBalance[msg.sender] * BASIS_POINTS) /
/*LN-101*/             COLLATERAL_RATIO;
/*LN-102*/ 
/*LN-103*/         require(
/*LN-104*/             debtBalance[msg.sender] + amount <= maxBorrow,
/*LN-105*/             "Insufficient collateral"
/*LN-106*/         );
/*LN-107*/ 
/*LN-108*/         debtBalance[msg.sender] += amount;
/*LN-109*/ 
/*LN-110*/         shezUSD.transfer(msg.sender, amount);
/*LN-111*/     }
/*LN-112*/ 
/*LN-113*/     function repay(uint256 amount) external {
/*LN-114*/         require(debtBalance[msg.sender] >= amount, "Excessive repayment");
/*LN-115*/         shezUSD.transferFrom(msg.sender, address(this), amount);
/*LN-116*/         debtBalance[msg.sender] -= amount;
/*LN-117*/     }
/*LN-118*/ 
/*LN-119*/     function withdrawCollateral(uint256 amount) external {
/*LN-120*/         require(
/*LN-121*/             collateralBalance[msg.sender] >= amount,
/*LN-122*/             "Insufficient collateral"
/*LN-123*/         );
/*LN-124*/         uint256 remainingCollateral = collateralBalance[msg.sender] - amount;
/*LN-125*/         uint256 maxDebt = (remainingCollateral * BASIS_POINTS) /
/*LN-126*/             COLLATERAL_RATIO;
/*LN-127*/         require(
/*LN-128*/             debtBalance[msg.sender] <= maxDebt,
/*LN-129*/             "Would be undercollateralized"
/*LN-130*/         );
/*LN-131*/ 
/*LN-132*/         collateralBalance[msg.sender] -= amount;
/*LN-133*/         collateralToken.transfer(msg.sender, amount);
/*LN-134*/     }
/*LN-135*/ }
/*LN-136*/ 
/*LN-137*/ 