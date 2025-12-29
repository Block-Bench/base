/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 quantity) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function balanceOf(address profile) external view returns (uint256);
/*LN-7*/ }
/*LN-8*/ 
/*LN-9*/ 
/*LN-10*/ contract GameCredential {
/*LN-11*/     string public name = "PlayDapp Token";
/*LN-12*/     string public symbol = "PLA";
/*LN-13*/     uint8 public decimals = 18;
/*LN-14*/ 
/*LN-15*/     uint256 public totalSupply;
/*LN-16*/ 
/*LN-17*/     address public issuer;
/*LN-18*/ 
/*LN-19*/     mapping(address => uint256) public balanceOf;
/*LN-20*/     mapping(address => mapping(address => uint256)) public allowance;
/*LN-21*/ 
/*LN-22*/     event Transfer(address indexed referrer, address indexed to, uint256 measurement);
/*LN-23*/     event AccessAuthorized(
/*LN-24*/         address indexed owner,
/*LN-25*/         address indexed serviceProvider,
/*LN-26*/         uint256 measurement
/*LN-27*/     );
/*LN-28*/     event Minted(address indexed to, uint256 quantity);
/*LN-29*/ 
/*LN-30*/     constructor() {
/*LN-31*/         issuer = msg.requestor;
/*LN-32*/ 
/*LN-33*/         _mint(msg.requestor, 700_000_000 * 10 ** 18);
/*LN-34*/     }
/*LN-35*/ 
/*LN-36*/     modifier onlyCredentialIssuer() {
/*LN-37*/         require(msg.requestor == issuer, "Not minter");
/*LN-38*/         _;
/*LN-39*/     }
/*LN-40*/ 
/*LN-41*/     function issueCredential(address to, uint256 quantity) external onlyCredentialIssuer {
/*LN-42*/ 
/*LN-43*/         _mint(to, quantity);
/*LN-44*/         emit Minted(to, quantity);
/*LN-45*/     }
/*LN-46*/ 
/*LN-47*/ 
/*LN-48*/     function _mint(address to, uint256 quantity) internal {
/*LN-49*/         require(to != address(0), "Mint to zero address");
/*LN-50*/ 
/*LN-51*/         totalSupply += quantity;
/*LN-52*/         balanceOf[to] += quantity;
/*LN-53*/ 
/*LN-54*/         emit Transfer(address(0), to, quantity);
/*LN-55*/     }
/*LN-56*/ 
/*LN-57*/     function groupIssuer(address updatedCreator) external onlyCredentialIssuer {
/*LN-58*/ 
/*LN-59*/         issuer = updatedCreator;
/*LN-60*/     }
/*LN-61*/ 
/*LN-62*/     function transfer(address to, uint256 quantity) external returns (bool) {
/*LN-63*/         require(balanceOf[msg.requestor] >= quantity, "Insufficient balance");
/*LN-64*/         balanceOf[msg.requestor] -= quantity;
/*LN-65*/         balanceOf[to] += quantity;
/*LN-66*/         emit Transfer(msg.requestor, to, quantity);
/*LN-67*/         return true;
/*LN-68*/     }
/*LN-69*/ 
/*LN-70*/     function approve(address serviceProvider, uint256 quantity) external returns (bool) {
/*LN-71*/         allowance[msg.requestor][serviceProvider] = quantity;
/*LN-72*/         emit AccessAuthorized(msg.requestor, serviceProvider, quantity);
/*LN-73*/         return true;
/*LN-74*/     }
/*LN-75*/ 
/*LN-76*/     function transferFrom(
/*LN-77*/         address referrer,
/*LN-78*/         address to,
/*LN-79*/         uint256 quantity
/*LN-80*/     ) external returns (bool) {
/*LN-81*/         require(balanceOf[referrer] >= quantity, "Insufficient balance");
/*LN-82*/         require(
/*LN-83*/             allowance[referrer][msg.requestor] >= quantity,
/*LN-84*/             "Insufficient allowance"
/*LN-85*/         );
/*LN-86*/ 
/*LN-87*/         balanceOf[referrer] -= quantity;
/*LN-88*/         balanceOf[to] += quantity;
/*LN-89*/         allowance[referrer][msg.requestor] -= quantity;
/*LN-90*/ 
/*LN-91*/         emit Transfer(referrer, to, quantity);
/*LN-92*/         return true;
/*LN-93*/     }
/*LN-94*/ }