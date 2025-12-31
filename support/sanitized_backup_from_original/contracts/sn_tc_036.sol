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
/*LN-18*/ interface IBorrowerOperations {
/*LN-19*/     function setDelegateApproval(address _delegate, bool _isApproved) external;
/*LN-20*/ 
/*LN-21*/     function openTrove(
/*LN-22*/         address troveManager,
/*LN-23*/         address account,
/*LN-24*/         uint256 _maxFeePercentage,
/*LN-25*/         uint256 _collateralAmount,
/*LN-26*/         uint256 _debtAmount,
/*LN-27*/         address _upperHint,
/*LN-28*/         address _lowerHint
/*LN-29*/     ) external;
/*LN-30*/ 
/*LN-31*/     function closeTrove(address troveManager, address account) external;
/*LN-32*/ }
/*LN-33*/ 
/*LN-34*/ interface ITroveManager {
/*LN-35*/     function getTroveCollAndDebt(
/*LN-36*/         address _borrower
/*LN-37*/     ) external view returns (uint256 coll, uint256 debt);
/*LN-38*/ 
/*LN-39*/     function liquidate(address _borrower) external;
/*LN-40*/ }
/*LN-41*/ 
/*LN-42*/ contract MigrateTroveZap {
/*LN-43*/     IBorrowerOperations public borrowerOperations;
/*LN-44*/     address public wstETH;
/*LN-45*/     address public mkUSD;
/*LN-46*/ 
/*LN-47*/     constructor(address _borrowerOperations, address _wstETH, address _mkUSD) {
/*LN-48*/         borrowerOperations = _borrowerOperations;
/*LN-49*/         wstETH = _wstETH;
/*LN-50*/         mkUSD = _mkUSD;
/*LN-51*/     }
/*LN-52*/ 
/*LN-53*/     function openTroveAndMigrate(
/*LN-54*/         address troveManager,
/*LN-55*/         address account,
/*LN-56*/         uint256 maxFeePercentage,
/*LN-57*/         uint256 collateralAmount,
/*LN-58*/         uint256 debtAmount,
/*LN-59*/         address upperHint,
/*LN-60*/         address lowerHint
/*LN-61*/     ) external {
/*LN-62*/ 
/*LN-63*/         // If that user previously approved this contract as delegate, it can act on their behalf
/*LN-64*/ 
/*LN-65*/         // Transfer collateral from msg.sender
/*LN-66*/         IERC20(wstETH).transferFrom(
/*LN-67*/             msg.sender,
/*LN-68*/             address(this),
/*LN-69*/             collateralAmount
/*LN-70*/         );
/*LN-71*/ 
/*LN-72*/         // If victim approved this contract, this call succeeds
/*LN-73*/ 
/*LN-74*/         IERC20(wstETH).approve(address(borrowerOperations), collateralAmount);
/*LN-75*/ 
/*LN-76*/         borrowerOperations.openTrove(
/*LN-77*/             troveManager,
/*LN-78*/             account,
/*LN-79*/             maxFeePercentage,
/*LN-80*/             collateralAmount,
/*LN-81*/             debtAmount,
/*LN-82*/             upperHint,
/*LN-83*/             lowerHint
/*LN-84*/         );
/*LN-85*/ 
/*LN-86*/         IERC20(mkUSD).transfer(msg.sender, debtAmount);
/*LN-87*/     }
/*LN-88*/ 
/*LN-89*/     function closeTroveFor(address troveManager, address account) external {
/*LN-90*/ 
/*LN-91*/         // And extract the collateral
/*LN-92*/ 
/*LN-93*/         borrowerOperations.closeTrove(troveManager, account);
/*LN-94*/     }
/*LN-95*/ }
/*LN-96*/ 
/*LN-97*/ contract BorrowerOperations {
/*LN-98*/     mapping(address => mapping(address => bool)) public delegates;
/*LN-99*/     ITroveManager public troveManager;
/*LN-100*/ 
/*LN-101*/     /**
/*LN-102*/      * @notice Set delegate approval
/*LN-103*/      * @dev Users can approve contracts to act on their behalf
/*LN-104*/      */
/*LN-105*/     function setDelegateApproval(address _delegate, bool _isApproved) external {
/*LN-106*/         delegates[msg.sender][_delegate] = _isApproved;
/*LN-107*/     }
/*LN-108*/ 
/*LN-109*/     function openTrove(
/*LN-110*/         address _troveManager,
/*LN-111*/         address account,
/*LN-112*/         uint256 _maxFeePercentage,
/*LN-113*/         uint256 _collateralAmount,
/*LN-114*/         uint256 _debtAmount,
/*LN-115*/         address _upperHint,
/*LN-116*/         address _lowerHint
/*LN-117*/     ) external {
/*LN-118*/ 
/*LN-119*/         // Only checks if msg.sender is approved delegate
/*LN-120*/         // Doesn't validate that delegate should be able to open troves on behalf of account
/*LN-121*/         require(
/*LN-122*/             msg.sender == account || delegates[account][msg.sender],
/*LN-123*/             "Not authorized"
/*LN-124*/         );
/*LN-125*/ 
/*LN-126*/         // Open trove logic (simplified)
/*LN-127*/         // Creates debt position for 'account' with provided collateral
/*LN-128*/     }
/*LN-129*/ 
/*LN-130*/     /**
/*LN-131*/      * @notice Close a trove
/*LN-132*/      */
/*LN-133*/     function closeTrove(address _troveManager, address account) external {
/*LN-134*/         require(
/*LN-135*/             msg.sender == account || delegates[account][msg.sender],
/*LN-136*/             "Not authorized"
/*LN-137*/         );
/*LN-138*/ 
/*LN-139*/         // Close trove logic (simplified)
/*LN-140*/     }
/*LN-141*/ }
/*LN-142*/ 
/*LN-143*/ 