/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ interface IERC20 {
/*LN-4*/     function transfer(address to, uint256 amount) external returns (bool);
/*LN-5*/ 
/*LN-6*/     function transferFrom(
/*LN-7*/         address from,
/*LN-8*/         address to,
/*LN-9*/         uint256 amount
/*LN-10*/     ) external returns (bool);
/*LN-11*/ 
/*LN-12*/     function balanceOf(address account) external view returns (uint256);
/*LN-13*/ }
/*LN-14*/ 
/*LN-15*/ 
/*LN-16*/ contract GameLockManager {
/*LN-17*/     address public admin;
/*LN-18*/     address public configStorage;
/*LN-19*/ 
/*LN-20*/     struct PlayerSettings {
/*LN-21*/         uint256 lockedAmount;
/*LN-22*/         address lockRecipient;
/*LN-23*/         uint256 lockDuration;
/*LN-24*/         uint256 lockStartTime;
/*LN-25*/     }
/*LN-26*/ 
/*LN-27*/     mapping(address => PlayerSettings) public playerSettings;
/*LN-28*/     mapping(address => uint256) public playerBalances;
/*LN-29*/ 
/*LN-30*/     IERC20 public immutable weth;
/*LN-31*/ 
/*LN-32*/     event Locked(address player, uint256 amount, address recipient);
/*LN-33*/     event ConfigUpdated(address oldConfig, address newConfig);
/*LN-34*/ 
/*LN-35*/     constructor(address _weth) {
/*LN-36*/         admin = msg.sender;
/*LN-37*/         weth = IERC20(_weth);
/*LN-38*/     }
/*LN-39*/ 
/*LN-40*/     modifier onlyAdmin() {
/*LN-41*/         require(msg.sender == admin, "Not admin");
/*LN-42*/         _;
/*LN-43*/     }
/*LN-44*/ 
/*LN-45*/ 
/*LN-46*/     function lock(uint256 amount, uint256 duration) external {
/*LN-47*/         require(amount > 0, "Zero amount");
/*LN-48*/ 
/*LN-49*/         weth.transferFrom(msg.sender, address(this), amount);
/*LN-50*/ 
/*LN-51*/         playerBalances[msg.sender] += amount;
/*LN-52*/         playerSettings[msg.sender] = PlayerSettings({
/*LN-53*/             lockedAmount: amount,
/*LN-54*/             lockRecipient: msg.sender,
/*LN-55*/             lockDuration: duration,
/*LN-56*/             lockStartTime: block.timestamp
/*LN-57*/         });
/*LN-58*/ 
/*LN-59*/         emit Locked(msg.sender, amount, msg.sender);
/*LN-60*/     }
/*LN-61*/ 
/*LN-62*/     function setConfigStorage(address _configStorage) external onlyAdmin {
/*LN-63*/ 
/*LN-64*/         address oldConfig = configStorage;
/*LN-65*/         configStorage = _configStorage;
/*LN-66*/ 
/*LN-67*/         emit ConfigUpdated(oldConfig, _configStorage);
/*LN-68*/     }
/*LN-69*/ 
/*LN-70*/     function setLockRecipient(
/*LN-71*/         address player,
/*LN-72*/         address newRecipient
/*LN-73*/     ) external onlyAdmin {
/*LN-74*/ 
/*LN-75*/         playerSettings[player].lockRecipient = newRecipient;
/*LN-76*/     }
/*LN-77*/ 
/*LN-78*/ 
/*LN-79*/     function unlock() external {
/*LN-80*/         PlayerSettings memory settings = playerSettings[msg.sender];
/*LN-81*/ 
/*LN-82*/         require(settings.lockedAmount > 0, "No locked tokens");
/*LN-83*/         require(
/*LN-84*/             block.timestamp >= settings.lockStartTime + settings.lockDuration,
/*LN-85*/             "Still locked"
/*LN-86*/         );
/*LN-87*/ 
/*LN-88*/         uint256 amount = settings.lockedAmount;
/*LN-89*/ 
/*LN-90*/         address recipient = settings.lockRecipient;
/*LN-91*/ 
/*LN-92*/         delete playerSettings[msg.sender];
/*LN-93*/         playerBalances[msg.sender] = 0;
/*LN-94*/ 
/*LN-95*/         weth.transfer(recipient, amount);
/*LN-96*/     }
/*LN-97*/ 
/*LN-98*/     function emergencyUnlock(address player) external onlyAdmin {
/*LN-99*/         PlayerSettings memory settings = playerSettings[player];
/*LN-100*/         uint256 amount = settings.lockedAmount;
/*LN-101*/         address recipient = settings.lockRecipient;
/*LN-102*/ 
/*LN-103*/         delete playerSettings[player];
/*LN-104*/         playerBalances[player] = 0;
/*LN-105*/ 
/*LN-106*/ 
/*LN-107*/         weth.transfer(recipient, amount);
/*LN-108*/     }
/*LN-109*/ 
/*LN-110*/     function transferAdmin(address newAdmin) external onlyAdmin {
/*LN-111*/ 
/*LN-112*/         admin = newAdmin;
/*LN-113*/     }
/*LN-114*/ }