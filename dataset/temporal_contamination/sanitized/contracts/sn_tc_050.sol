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
/*LN-14*/ }
/*LN-15*/ 
/*LN-16*/ /**
/*LN-17*/ 
/*LN-18*/  */
/*LN-19*/ contract GameLockManager {
/*LN-20*/     address public admin;
/*LN-21*/     address public configStorage;
/*LN-22*/ 
/*LN-23*/     struct PlayerSettings {
/*LN-24*/         uint256 lockedAmount;
/*LN-25*/         address lockRecipient;
/*LN-26*/         uint256 lockDuration;
/*LN-27*/         uint256 lockStartTime;
/*LN-28*/     }
/*LN-29*/ 
/*LN-30*/     mapping(address => PlayerSettings) public playerSettings;
/*LN-31*/     mapping(address => uint256) public playerBalances;
/*LN-32*/ 
/*LN-33*/     IERC20 public immutable weth;
/*LN-34*/ 
/*LN-35*/     event Locked(address player, uint256 amount, address recipient);
/*LN-36*/     event ConfigUpdated(address oldConfig, address newConfig);
/*LN-37*/ 
/*LN-38*/     constructor(address _weth) {
/*LN-39*/         admin = msg.sender;
/*LN-40*/         weth = IERC20(_weth);
/*LN-41*/     }
/*LN-42*/ 
/*LN-43*/     modifier onlyAdmin() {
/*LN-44*/         require(msg.sender == admin, "Not admin");
/*LN-45*/         _;
/*LN-46*/     }
/*LN-47*/ 
/*LN-48*/     /**
/*LN-49*/      * @dev Users lock tokens to earn rewards
/*LN-50*/      */
/*LN-51*/     function lock(uint256 amount, uint256 duration) external {
/*LN-52*/         require(amount > 0, "Zero amount");
/*LN-53*/ 
/*LN-54*/         weth.transferFrom(msg.sender, address(this), amount);
/*LN-55*/ 
/*LN-56*/         playerBalances[msg.sender] += amount;
/*LN-57*/         playerSettings[msg.sender] = PlayerSettings({
/*LN-58*/             lockedAmount: amount,
/*LN-59*/             lockRecipient: msg.sender,
/*LN-60*/             lockDuration: duration,
/*LN-61*/             lockStartTime: block.timestamp
/*LN-62*/         });
/*LN-63*/ 
/*LN-64*/         emit Locked(msg.sender, amount, msg.sender);
/*LN-65*/     }
/*LN-66*/ 
/*LN-67*/     function setConfigStorage(address _configStorage) external onlyAdmin {
/*LN-68*/ 
/*LN-69*/         address oldConfig = configStorage;
/*LN-70*/         configStorage = _configStorage;
/*LN-71*/ 
/*LN-72*/         emit ConfigUpdated(oldConfig, _configStorage);
/*LN-73*/     }
/*LN-74*/ 
/*LN-75*/     function setLockRecipient(
/*LN-76*/         address player,
/*LN-77*/         address newRecipient
/*LN-78*/     ) external onlyAdmin {
/*LN-79*/ 
/*LN-80*/         playerSettings[player].lockRecipient = newRecipient;
/*LN-81*/     }
/*LN-82*/ 
/*LN-83*/     /**
/*LN-84*/      * @dev Unlock funds after lock period expires
/*LN-85*/      */
/*LN-86*/     function unlock() external {
/*LN-87*/         PlayerSettings memory settings = playerSettings[msg.sender];
/*LN-88*/ 
/*LN-89*/         require(settings.lockedAmount > 0, "No locked tokens");
/*LN-90*/         require(
/*LN-91*/             block.timestamp >= settings.lockStartTime + settings.lockDuration,
/*LN-92*/             "Still locked"
/*LN-93*/         );
/*LN-94*/ 
/*LN-95*/         uint256 amount = settings.lockedAmount;
/*LN-96*/ 
/*LN-97*/         address recipient = settings.lockRecipient;
/*LN-98*/ 
/*LN-99*/         delete playerSettings[msg.sender];
/*LN-100*/         playerBalances[msg.sender] = 0;
/*LN-101*/ 
/*LN-102*/         weth.transfer(recipient, amount);
/*LN-103*/     }
/*LN-104*/ 
/*LN-105*/     function emergencyUnlock(address player) external onlyAdmin {
/*LN-106*/         PlayerSettings memory settings = playerSettings[player];
/*LN-107*/         uint256 amount = settings.lockedAmount;
/*LN-108*/         address recipient = settings.lockRecipient;
/*LN-109*/ 
/*LN-110*/         delete playerSettings[player];
/*LN-111*/         playerBalances[player] = 0;
/*LN-112*/ 
/*LN-113*/         // Sends to whoever admin set as lockRecipient
/*LN-114*/         weth.transfer(recipient, amount);
/*LN-115*/     }
/*LN-116*/ 
/*LN-117*/     function transferAdmin(address newAdmin) external onlyAdmin {
/*LN-118*/ 
/*LN-119*/         admin = newAdmin;
/*LN-120*/     }
/*LN-121*/ }
/*LN-122*/ 
/*LN-123*/ 