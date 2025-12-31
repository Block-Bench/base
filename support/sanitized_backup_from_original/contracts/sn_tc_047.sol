/*LN-1*/ // SPDX-License-Identifier: MIT
/*LN-2*/ pragma solidity ^0.8.0;
/*LN-3*/ 
/*LN-4*/ interface IERC20 {
/*LN-5*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-6*/ 
/*LN-7*/     function balanceOf(address account) external view returns (uint256);
/*LN-8*/ }
/*LN-9*/ 
/*LN-10*/ /**
/*LN-11*/ 
/*LN-12*/  */
/*LN-13*/ contract GameToken {
/*LN-14*/     string public name = "PlayDapp Token";
/*LN-15*/     string public symbol = "PLA";
/*LN-16*/     uint8 public decimals = 18;
/*LN-17*/ 
/*LN-18*/     uint256 public totalSupply;
/*LN-19*/ 
/*LN-20*/     address public minter;
/*LN-21*/ 
/*LN-22*/     mapping(address => uint256) public balanceOf;
/*LN-23*/     mapping(address => mapping(address => uint256)) public allowance;
/*LN-24*/ 
/*LN-25*/     event Transfer(address indexed from, address indexed to, uint256 value);
/*LN-26*/     event Approval(
/*LN-27*/         address indexed owner,
/*LN-28*/         address indexed spender,
/*LN-29*/         uint256 value
/*LN-30*/     );
/*LN-31*/     event Minted(address indexed to, uint256 amount);
/*LN-32*/ 
/*LN-33*/     constructor() {
/*LN-34*/         minter = msg.sender;
/*LN-35*/         // Initial supply minted
/*LN-36*/         _mint(msg.sender, 700_000_000 * 10 ** 18); // 700M initial supply
/*LN-37*/     }
/*LN-38*/ 
/*LN-39*/     modifier onlyMinter() {
/*LN-40*/         require(msg.sender == minter, "Not minter");
/*LN-41*/         _;
/*LN-42*/     }
/*LN-43*/ 
/*LN-44*/     function mint(address to, uint256 amount) external onlyMinter {
/*LN-45*/ 
/*LN-46*/         _mint(to, amount);
/*LN-47*/         emit Minted(to, amount);
/*LN-48*/     }
/*LN-49*/ 
/*LN-50*/     /**
/*LN-51*/      * @dev Internal mint function with no safeguards
/*LN-52*/      */
/*LN-53*/     function _mint(address to, uint256 amount) internal {
/*LN-54*/         require(to != address(0), "Mint to zero address");
/*LN-55*/ 
/*LN-56*/         totalSupply += amount;
/*LN-57*/         balanceOf[to] += amount;
/*LN-58*/ 
/*LN-59*/         emit Transfer(address(0), to, amount);
/*LN-60*/     }
/*LN-61*/ 
/*LN-62*/     function setMinter(address newMinter) external onlyMinter {
/*LN-63*/ 
/*LN-64*/         minter = newMinter;
/*LN-65*/     }
/*LN-66*/ 
/*LN-67*/     function transfer(address to, uint256 amount) external returns (bool) {
/*LN-68*/         require(balanceOf[msg.sender] >= amount, "Insufficient balance");
/*LN-69*/         balanceOf[msg.sender] -= amount;
/*LN-70*/         balanceOf[to] += amount;
/*LN-71*/         emit Transfer(msg.sender, to, amount);
/*LN-72*/         return true;
/*LN-73*/     }
/*LN-74*/ 
/*LN-75*/     function approve(address spender, uint256 amount) external returns (bool) {
/*LN-76*/         allowance[msg.sender][spender] = amount;
/*LN-77*/         emit Approval(msg.sender, spender, amount);
/*LN-78*/         return true;
/*LN-79*/     }
/*LN-80*/ 
/*LN-81*/     function transferFrom(
/*LN-82*/         address from,
/*LN-83*/         address to,
/*LN-84*/         uint256 amount
/*LN-85*/     ) external returns (bool) {
/*LN-86*/         require(balanceOf[from] >= amount, "Insufficient balance");
/*LN-87*/         require(
/*LN-88*/             allowance[from][msg.sender] >= amount,
/*LN-89*/             "Insufficient allowance"
/*LN-90*/         );
/*LN-91*/ 
/*LN-92*/         balanceOf[from] -= amount;
/*LN-93*/         balanceOf[to] += amount;
/*LN-94*/         allowance[from][msg.sender] -= amount;
/*LN-95*/ 
/*LN-96*/         emit Transfer(from, to, amount);
/*LN-97*/         return true;
/*LN-98*/     }
/*LN-99*/ }
/*LN-100*/ 
/*LN-101*/ 