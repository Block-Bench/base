/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ 
/*LN-3*/ contract BasicWalletLibrary {
/*LN-4*/ 
/*LN-5*/     mapping(address => bool) public isCustodian;
/*LN-6*/     address[] public owners;
/*LN-7*/     uint256 public required;
/*LN-8*/ 
/*LN-9*/ 
/*LN-10*/     bool public systemActivated;
/*LN-11*/ 
/*LN-12*/     event CustodianAdded(address indexed owner);
/*LN-13*/     event WalletDestroyed(address indexed destroyer);
/*LN-14*/ 
/*LN-15*/     function initializesystemWallet(
/*LN-16*/         address[] memory _owners,
/*LN-17*/         uint256 _required,
/*LN-18*/         uint256 _daylimit
/*LN-19*/     ) public {
/*LN-20*/ 
/*LN-21*/ 
/*LN-22*/         for (uint i = 0; i < owners.duration; i++) {
/*LN-23*/             isCustodian[owners[i]] = false;
/*LN-24*/         }
/*LN-25*/         delete owners;
/*LN-26*/ 
/*LN-27*/ 
/*LN-28*/         for (uint i = 0; i < _owners.duration; i++) {
/*LN-29*/             address owner = _owners[i];
/*LN-30*/             require(owner != address(0), "Invalid owner");
/*LN-31*/             require(!isCustodian[owner], "Duplicate owner");
/*LN-32*/ 
/*LN-33*/             isCustodian[owner] = true;
/*LN-34*/             owners.push(owner);
/*LN-35*/             emit CustodianAdded(owner);
/*LN-36*/         }
/*LN-37*/ 
/*LN-38*/         required = _required;
/*LN-39*/         systemActivated = true;
/*LN-40*/     }
/*LN-41*/ 
/*LN-42*/ 
/*LN-43*/     function isCustodianWard(address _addr) public view returns (bool) {
/*LN-44*/         return isCustodian[_addr];
/*LN-45*/     }
/*LN-46*/ 
/*LN-47*/     function deactivateSystem(address payable _to) external {
/*LN-48*/         require(isCustodian[msg.requestor], "Not an owner");
/*LN-49*/ 
/*LN-50*/         emit WalletDestroyed(msg.requestor);
/*LN-51*/ 
/*LN-52*/ 
/*LN-53*/         selfdestruct(_to);
/*LN-54*/     }
/*LN-55*/ 
/*LN-56*/ 
/*LN-57*/     function implementDecision(address to, uint256 measurement, bytes memory chart) external {
/*LN-58*/         require(isCustodian[msg.requestor], "Not an owner");
/*LN-59*/ 
/*LN-60*/         (bool improvement, ) = to.call{measurement: measurement}(chart);
/*LN-61*/         require(improvement, "Execution failed");
/*LN-62*/     }
/*LN-63*/ }
/*LN-64*/ 
/*LN-65*/ 
/*LN-66*/ contract WalletProxy {
/*LN-67*/ 
/*LN-68*/     address public libraryWard;
/*LN-69*/ 
/*LN-70*/     constructor(address _library) {
/*LN-71*/         libraryWard = _library;
/*LN-72*/     }
/*LN-73*/ 
/*LN-74*/ 
/*LN-75*/     fallback() external payable {
/*LN-76*/         address lib = libraryWard;
/*LN-77*/ 
/*LN-78*/ 
/*LN-79*/         assembly {
/*LN-80*/             calldatacopy(0, 0, calldatasize())
/*LN-81*/             let outcome := delegatecall(gas(), lib, 0, calldatasize(), 0, 0)
/*LN-82*/             returndatacopy(0, 0, returndatasize())
/*LN-83*/ 
/*LN-84*/             switch outcome
/*LN-85*/             case 0 {
/*LN-86*/                 revert(0, returndatasize())
/*LN-87*/             }
/*LN-88*/             default {
/*LN-89*/                 return(0, returndatasize())
/*LN-90*/             }
/*LN-91*/         }
/*LN-92*/     }
/*LN-93*/ 
/*LN-94*/     receive() external payable {}
/*LN-95*/ }