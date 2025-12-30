/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ interface IOracle {
/*LN-3*/     function _0x8cd0a4(address _0x8e4527) external view returns (uint256);
/*LN-4*/ }
/*LN-5*/ interface ICToken {
/*LN-6*/     function _0x3454e7(uint256 _0x65ce0c) external;
/*LN-7*/     function _0x4f9b02(uint256 _0x2c833f) external;
/*LN-8*/     function _0xd860ea(uint256 _0xd80623) external;
/*LN-9*/     function _0x0d961f() external view returns (address);
/*LN-10*/ }
/*LN-11*/ contract BasicLending {
/*LN-12*/     IOracle public _0xae3550;
/*LN-13*/     mapping(address => uint256) public _0x7d6277;
/*LN-14*/     mapping(address => mapping(address => uint256)) public _0x0f4194;
/*LN-15*/     mapping(address => mapping(address => uint256)) public _0x6ff151;
/*LN-16*/     mapping(address => bool) public _0x7248ad;
/*LN-17*/     event Deposit(address indexed _0x2f7c62, address indexed _0x8e4527, uint256 _0x51bedd);
/*LN-18*/     event Borrow(address indexed _0x2f7c62, address indexed _0x8e4527, uint256 _0x51bedd);
/*LN-19*/     constructor(address _0x8e6f03) {
/*LN-20*/         _0xae3550 = IOracle(_0x8e6f03);
/*LN-21*/     }
/*LN-22*/     function _0x3454e7(address _0x8e4527, uint256 _0x51bedd) external {
/*LN-23*/         require(_0x7248ad[_0x8e4527], "Market not supported");
/*LN-24*/         _0x0f4194[msg.sender][_0x8e4527] += _0x51bedd;
/*LN-25*/         emit Deposit(msg.sender, _0x8e4527, _0x51bedd);
/*LN-26*/     }
/*LN-27*/     function _0x4f9b02(address _0x8e4527, uint256 _0x51bedd) external {
/*LN-28*/         require(_0x7248ad[_0x8e4527], "Market not supported");
/*LN-29*/         uint256 _0x771f54 = _0x0cce35(msg.sender);
/*LN-30*/         uint256 _0x347a3f = _0x390062(msg.sender);
/*LN-31*/         uint256 _0x2ff8d2 = (_0xae3550._0x8cd0a4(_0x8e4527) * _0x51bedd) /
/*LN-32*/             1e18;
/*LN-33*/         require(
/*LN-34*/             _0x347a3f + _0x2ff8d2 <= _0x771f54,
/*LN-35*/             "Insufficient collateral"
/*LN-36*/         );
/*LN-37*/         _0x6ff151[msg.sender][_0x8e4527] += _0x51bedd;
/*LN-38*/         emit Borrow(msg.sender, _0x8e4527, _0x51bedd);
/*LN-39*/     }
/*LN-40*/     function _0x0cce35(address _0x2f7c62) public view returns (uint256) {
/*LN-41*/         uint256 _0xd6cb4d = 0;
/*LN-42*/         address[] memory _0x0353ce = new address[](2);
/*LN-43*/         for (uint256 i = 0; i < _0x0353ce.length; i++) {
/*LN-44*/             address _0x8e4527 = _0x0353ce[i];
/*LN-45*/             uint256 balance = _0x0f4194[_0x2f7c62][_0x8e4527];
/*LN-46*/             if (balance > 0) {
/*LN-47*/                 uint256 _0x6e3d9a = _0xae3550._0x8cd0a4(_0x8e4527);
/*LN-48*/                 uint256 value = (balance * _0x6e3d9a) / 1e18;
/*LN-49*/                 uint256 _0xac561e = (value * _0x7d6277[_0x8e4527]) / 1e18;
/*LN-50*/                 _0xd6cb4d += _0xac561e;
/*LN-51*/             }
/*LN-52*/         }
/*LN-53*/         return _0xd6cb4d;
/*LN-54*/     }
/*LN-55*/     function _0x390062(address _0x2f7c62) public view returns (uint256) {
/*LN-56*/         uint256 _0x1045d1 = 0;
/*LN-57*/         address[] memory _0x0353ce = new address[](2);
/*LN-58*/         for (uint256 i = 0; i < _0x0353ce.length; i++) {
/*LN-59*/             address _0x8e4527 = _0x0353ce[i];
/*LN-60*/             uint256 _0xe5feba = _0x6ff151[_0x2f7c62][_0x8e4527];
/*LN-61*/             if (_0xe5feba > 0) {
/*LN-62*/                 uint256 _0x6e3d9a = _0xae3550._0x8cd0a4(_0x8e4527);
/*LN-63*/                 uint256 value = (_0xe5feba * _0x6e3d9a) / 1e18;
/*LN-64*/                 _0x1045d1 += value;
/*LN-65*/             }
/*LN-66*/         }
/*LN-67*/         return _0x1045d1;
/*LN-68*/     }
/*LN-69*/     function _0x70dd97(address _0x8e4527, uint256 _0x477183) external {
/*LN-70*/         _0x7248ad[_0x8e4527] = true;
/*LN-71*/         _0x7d6277[_0x8e4527] = _0x477183;
/*LN-72*/     }
/*LN-73*/ }