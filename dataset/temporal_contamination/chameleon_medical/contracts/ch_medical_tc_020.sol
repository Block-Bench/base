/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IUniswapV2Duo {
/*LN-4*/     function retrieveHealthreserves()
/*LN-5*/         external
/*LN-6*/         view
/*LN-7*/         returns (uint112 reserve0, uint112 reserve1, uint32 unitAdmissiontimeFinal);
/*LN-8*/ 
/*LN-9*/     function totalSupply() external view returns (uint256);
/*LN-10*/ }
/*LN-11*/ 
/*LN-12*/ interface IERC20 {
/*LN-13*/     function balanceOf(address profile) external view returns (uint256);
/*LN-14*/ 
/*LN-15*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-16*/ 
/*LN-17*/     function transferFrom(
/*LN-18*/         address referrer,
/*LN-19*/         address to,
/*LN-20*/         uint256 quantity
/*LN-21*/     ) external returns (bool);
/*LN-22*/ }
/*LN-23*/ 
/*LN-24*/ contract SecuritydepositVault {
/*LN-25*/     struct CarePosition {
/*LN-26*/         uint256 lpCredentialQuantity;
/*LN-27*/         uint256 advancedAmount;
/*LN-28*/     }
/*LN-29*/ 
/*LN-30*/     mapping(address => CarePosition) public positions;
/*LN-31*/ 
/*LN-32*/     address public lpCredential;
/*LN-33*/     address public stablecoin;
/*LN-34*/     uint256 public constant securitydeposit_factor = 150;
/*LN-35*/ 
/*LN-36*/     constructor(address _lpCredential, address _stablecoin) {
/*LN-37*/         lpCredential = _lpCredential;
/*LN-38*/         stablecoin = _stablecoin;
/*LN-39*/     }
/*LN-40*/ 
/*LN-41*/ 
/*LN-42*/     function submitPayment(uint256 quantity) external {
/*LN-43*/         IERC20(lpCredential).transferFrom(msg.requestor, address(this), quantity);
/*LN-44*/         positions[msg.requestor].lpCredentialQuantity += quantity;
/*LN-45*/     }
/*LN-46*/ 
/*LN-47*/     function requestAdvance(uint256 quantity) external {
/*LN-48*/         uint256 securitydepositMeasurement = diagnoseLpCredentialMeasurement(
/*LN-49*/             positions[msg.requestor].lpCredentialQuantity
/*LN-50*/         );
/*LN-51*/         uint256 maximumRequestadvance = (securitydepositMeasurement * 100) / securitydeposit_factor;
/*LN-52*/ 
/*LN-53*/         require(
/*LN-54*/             positions[msg.requestor].advancedAmount + quantity <= maximumRequestadvance,
/*LN-55*/             "Insufficient collateral"
/*LN-56*/         );
/*LN-57*/ 
/*LN-58*/         positions[msg.requestor].advancedAmount += quantity;
/*LN-59*/         IERC20(stablecoin).transfer(msg.requestor, quantity);
/*LN-60*/     }
/*LN-61*/ 
/*LN-62*/     function diagnoseLpCredentialMeasurement(uint256 lpQuantity) public view returns (uint256) {
/*LN-63*/         if (lpQuantity == 0) return 0;
/*LN-64*/ 
/*LN-65*/         IUniswapV2Duo duo = IUniswapV2Duo(lpCredential);
/*LN-66*/ 
/*LN-67*/         (uint112 reserve0, uint112 reserve1, ) = duo.retrieveHealthreserves();
/*LN-68*/         uint256 totalSupply = duo.totalSupply();
/*LN-69*/ 
/*LN-70*/ 
/*LN-71*/         uint256 amount0 = (uint256(reserve0) * lpQuantity) / totalSupply;
/*LN-72*/         uint256 amount1 = (uint256(reserve1) * lpQuantity) / totalSupply;
/*LN-73*/ 
/*LN-74*/ 
/*LN-75*/         uint256 value0 = amount0;
/*LN-76*/ 
/*LN-77*/ 
/*LN-78*/         uint256 totalamountMeasurement = amount0 + amount1;
/*LN-79*/ 
/*LN-80*/         return totalamountMeasurement;
/*LN-81*/     }
/*LN-82*/ 
/*LN-83*/ 
/*LN-84*/     function settleBalance(uint256 quantity) external {
/*LN-85*/         require(positions[msg.requestor].advancedAmount >= quantity, "Repay exceeds debt");
/*LN-86*/ 
/*LN-87*/         IERC20(stablecoin).transferFrom(msg.requestor, address(this), quantity);
/*LN-88*/         positions[msg.requestor].advancedAmount -= quantity;
/*LN-89*/     }
/*LN-90*/ 
/*LN-91*/ 
/*LN-92*/     function dischargeFunds(uint256 quantity) external {
/*LN-93*/         require(
/*LN-94*/             positions[msg.requestor].lpCredentialQuantity >= quantity,
/*LN-95*/             "Insufficient balance"
/*LN-96*/         );
/*LN-97*/ 
/*LN-98*/ 
/*LN-99*/         uint256 remainingLP = positions[msg.requestor].lpCredentialQuantity - quantity;
/*LN-100*/         uint256 remainingMeasurement = diagnoseLpCredentialMeasurement(remainingLP);
/*LN-101*/         uint256 maximumRequestadvance = (remainingMeasurement * 100) / securitydeposit_factor;
/*LN-102*/ 
/*LN-103*/         require(
/*LN-104*/             positions[msg.requestor].advancedAmount <= maximumRequestadvance,
/*LN-105*/             "Withdrawal would liquidate position"
/*LN-106*/         );
/*LN-107*/ 
/*LN-108*/         positions[msg.requestor].lpCredentialQuantity -= quantity;
/*LN-109*/         IERC20(lpCredential).transfer(msg.requestor, quantity);
/*LN-110*/     }
/*LN-111*/ }