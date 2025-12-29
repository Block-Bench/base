/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IERC20 {
/*LN-5*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-6*/ 
/*LN-7*/     function balanceOf(address account) external view returns (uint256);
/*LN-8*/ }
/*LN-9*/ 
/*LN-10*/ contract BasicLoanToken {
/*LN-11*/     string public name = "iETH";
/*LN-12*/     string public symbol = "iETH";
/*LN-13*/ 
/*LN-14*/     mapping(address => uint256) public balances;
/*LN-15*/     uint256 public totalSupply;
/*LN-16*/     uint256 public totalAssetBorrow;
/*LN-17*/     uint256 public totalAssetSupply;
/*LN-18*/ 
/*LN-19*/     /**
/*LN-20*/      * @notice Mint loan tokens by depositing ETH
/*LN-21*/      */
/*LN-22*/     function mintWithEther(
/*LN-23*/         address receiver
/*LN-24*/     ) external payable returns (uint256 mintAmount) {
/*LN-25*/         uint256 currentPrice = _tokenPrice();
/*LN-26*/         mintAmount = (msg.value * 1e18) / currentPrice;
/*LN-27*/ 
/*LN-28*/         balances[receiver] += mintAmount;
/*LN-29*/         totalSupply += mintAmount;
/*LN-30*/         totalAssetSupply += msg.value;
/*LN-31*/ 
/*LN-32*/         return mintAmount;
/*LN-33*/     }
/*LN-34*/ 
/*LN-35*/     function transfer(address to, uint256 amount) external returns (bool) {
/*LN-36*/         require(balances[msg.sender] >= amount, "Insufficient balance");
/*LN-37*/ 
/*LN-38*/         balances[msg.sender] -= amount;
/*LN-39*/         balances[to] += amount;
/*LN-40*/ 
/*LN-41*/         _notifyTransfer(msg.sender, to, amount);
/*LN-42*/ 
/*LN-43*/         return true;
/*LN-44*/     }
/*LN-45*/ 
/*LN-46*/     function _notifyTransfer(
/*LN-47*/         address from,
/*LN-48*/         address to,
/*LN-49*/         uint256 amount
/*LN-50*/     ) internal {
/*LN-51*/         // If 'to' is a contract, it might have a callback
/*LN-52*/         // During this callback, contract state is inconsistent
/*LN-53*/ 
/*LN-54*/         // Simulate callback by calling a function on recipient if it's a contract
/*LN-55*/         if (_isContract(to)) {
/*LN-56*/             // This would trigger fallback/receive on recipient
/*LN-57*/             // During that callback, recipient can call transfer() again
/*LN-58*/             (bool success, ) = to.call("");
/*LN-59*/             success; // Suppress warning
/*LN-60*/         }
/*LN-61*/     }
/*LN-62*/ 
/*LN-63*/     /**
/*LN-64*/      * @notice Burn tokens back to ETH
/*LN-65*/      */
/*LN-66*/     function burnToEther(
/*LN-67*/         address receiver,
/*LN-68*/         uint256 amount
/*LN-69*/     ) external returns (uint256 ethAmount) {
/*LN-70*/         require(balances[msg.sender] >= amount, "Insufficient balance");
/*LN-71*/ 
/*LN-72*/         uint256 currentPrice = _tokenPrice();
/*LN-73*/         ethAmount = (amount * currentPrice) / 1e18;
/*LN-74*/ 
/*LN-75*/         balances[msg.sender] -= amount;
/*LN-76*/         totalSupply -= amount;
/*LN-77*/         totalAssetSupply -= ethAmount;
/*LN-78*/ 
/*LN-79*/         payable(receiver).transfer(ethAmount);
/*LN-80*/ 
/*LN-81*/         return ethAmount;
/*LN-82*/     }
/*LN-83*/ 
/*LN-84*/     /**
/*LN-85*/      * @notice Calculate current token price
/*LN-86*/      * @dev Price is based on total supply and total assets
/*LN-87*/      */
/*LN-88*/     function _tokenPrice() internal view returns (uint256) {
/*LN-89*/         if (totalSupply == 0) {
/*LN-90*/             return 1e18; // Initial price 1:1
/*LN-91*/         }
/*LN-92*/         return (totalAssetSupply * 1e18) / totalSupply;
/*LN-93*/     }
/*LN-94*/ 
/*LN-95*/     /**
/*LN-96*/      * @notice Check if address is a contract
/*LN-97*/      */
/*LN-98*/     function _isContract(address account) internal view returns (bool) {
/*LN-99*/         uint256 size;
/*LN-100*/         assembly {
/*LN-101*/             size := extcodesize(account)
/*LN-102*/         }
/*LN-103*/         return size > 0;
/*LN-104*/     }
/*LN-105*/ 
/*LN-106*/     function balanceOf(address account) external view returns (uint256) {
/*LN-107*/         return balances[account];
/*LN-108*/     }
/*LN-109*/ 
/*LN-110*/     receive() external payable {}
/*LN-111*/ }
/*LN-112*/ 
/*LN-113*/ 