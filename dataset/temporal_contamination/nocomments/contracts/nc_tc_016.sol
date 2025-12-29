/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function balanceOf(address account) external view returns (uint256);
/*LN-7*/ }
/*LN-8*/ 
/*LN-9*/ contract BasicLoanToken {
/*LN-10*/     string public name = "iETH";
/*LN-11*/     string public symbol = "iETH";
/*LN-12*/ 
/*LN-13*/     mapping(address => uint256) public balances;
/*LN-14*/     uint256 public totalSupply;
/*LN-15*/     uint256 public totalAssetBorrow;
/*LN-16*/     uint256 public totalAssetSupply;
/*LN-17*/ 
/*LN-18*/ 
/*LN-19*/     function mintWithEther(
/*LN-20*/         address receiver
/*LN-21*/     ) external payable returns (uint256 mintAmount) {
/*LN-22*/         uint256 currentPrice = _tokenPrice();
/*LN-23*/         mintAmount = (msg.value * 1e18) / currentPrice;
/*LN-24*/ 
/*LN-25*/         balances[receiver] += mintAmount;
/*LN-26*/         totalSupply += mintAmount;
/*LN-27*/         totalAssetSupply += msg.value;
/*LN-28*/ 
/*LN-29*/         return mintAmount;
/*LN-30*/     }
/*LN-31*/ 
/*LN-32*/     function transfer(address to, uint256 amount) external returns (bool) {
/*LN-33*/         require(balances[msg.sender] >= amount, "Insufficient balance");
/*LN-34*/ 
/*LN-35*/         balances[msg.sender] -= amount;
/*LN-36*/         balances[to] += amount;
/*LN-37*/ 
/*LN-38*/         _notifyTransfer(msg.sender, to, amount);
/*LN-39*/ 
/*LN-40*/         return true;
/*LN-41*/     }
/*LN-42*/ 
/*LN-43*/     function _notifyTransfer(
/*LN-44*/         address from,
/*LN-45*/         address to,
/*LN-46*/         uint256 amount
/*LN-47*/     ) internal {
/*LN-48*/ 
/*LN-49*/ 
/*LN-50*/         if (_isContract(to)) {
/*LN-51*/ 
/*LN-52*/ 
/*LN-53*/             (bool success, ) = to.call("");
/*LN-54*/             success;
/*LN-55*/         }
/*LN-56*/     }
/*LN-57*/ 
/*LN-58*/ 
/*LN-59*/     function burnToEther(
/*LN-60*/         address receiver,
/*LN-61*/         uint256 amount
/*LN-62*/     ) external returns (uint256 ethAmount) {
/*LN-63*/         require(balances[msg.sender] >= amount, "Insufficient balance");
/*LN-64*/ 
/*LN-65*/         uint256 currentPrice = _tokenPrice();
/*LN-66*/         ethAmount = (amount * currentPrice) / 1e18;
/*LN-67*/ 
/*LN-68*/         balances[msg.sender] -= amount;
/*LN-69*/         totalSupply -= amount;
/*LN-70*/         totalAssetSupply -= ethAmount;
/*LN-71*/ 
/*LN-72*/         payable(receiver).transfer(ethAmount);
/*LN-73*/ 
/*LN-74*/         return ethAmount;
/*LN-75*/     }
/*LN-76*/ 
/*LN-77*/ 
/*LN-78*/     function _tokenPrice() internal view returns (uint256) {
/*LN-79*/         if (totalSupply == 0) {
/*LN-80*/             return 1e18;
/*LN-81*/         }
/*LN-82*/         return (totalAssetSupply * 1e18) / totalSupply;
/*LN-83*/     }
/*LN-84*/ 
/*LN-85*/ 
/*LN-86*/     function _isContract(address account) internal view returns (bool) {
/*LN-87*/         uint256 size;
/*LN-88*/         assembly {
/*LN-89*/             size := extcodesize(account)
/*LN-90*/         }
/*LN-91*/         return size > 0;
/*LN-92*/     }
/*LN-93*/ 
/*LN-94*/     function balanceOf(address account) external view returns (uint256) {
/*LN-95*/         return balances[account];
/*LN-96*/     }
/*LN-97*/ 
/*LN-98*/     receive() external payable {}
/*LN-99*/ }