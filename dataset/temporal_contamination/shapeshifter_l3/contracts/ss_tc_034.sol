/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ interface IERC20 {
/*LN-3*/     function transfer(address _0x163f22, uint256 _0x6e3d9a) external returns (bool);
/*LN-4*/     function _0x2c833f(
/*LN-5*/         address from,
/*LN-6*/         address _0x163f22,
/*LN-7*/         uint256 _0x6e3d9a
/*LN-8*/     ) external returns (bool);
/*LN-9*/     function _0x65ce0c(address _0x51bedd) external view returns (uint256);
/*LN-10*/     function _0x4f9b02(address _0xd860ea, uint256 _0x6e3d9a) external returns (bool);
/*LN-11*/ }
/*LN-12*/ interface IUniswapV3Pool {
/*LN-13*/     function _0x876f47(
/*LN-14*/         address _0x2ff8d2,
/*LN-15*/         bool _0x0f4194,
/*LN-16*/         int256 _0x8cd0a4,
/*LN-17*/         uint160 _0x390062,
/*LN-18*/         bytes calldata data
/*LN-19*/     ) external returns (int256 _0x8e4527, int256 _0x0353ce);
/*LN-20*/     function _0xb7cc25(
/*LN-21*/         address _0x2ff8d2,
/*LN-22*/         uint256 _0x8e4527,
/*LN-23*/         uint256 _0x0353ce,
/*LN-24*/         bytes calldata data
/*LN-25*/     ) external;
/*LN-26*/ }
/*LN-27*/ contract LiquidityHypervisor {
/*LN-28*/     IERC20 public _0xc285d4;
/*LN-29*/     IERC20 public _0x3184cf;
/*LN-30*/     IUniswapV3Pool public _0xb01af6;
/*LN-31*/     uint256 public _0x1045d1;
/*LN-32*/     mapping(address => uint256) public _0x65ce0c;
/*LN-33*/     struct Position {
/*LN-34*/         uint128 _0x0d961f;
/*LN-35*/         int24 _0x6ff151;
/*LN-36*/         int24 _0xd6cb4d;
/*LN-37*/     }
/*LN-38*/     Position public _0xd80623;
/*LN-39*/     Position public _0x477183;
/*LN-40*/     function _0xae3550(
/*LN-41*/         uint256 _0x70dd97,
/*LN-42*/         uint256 _0xe5feba,
/*LN-43*/         address _0x163f22
/*LN-44*/     ) external returns (uint256 _0xac561e) {
/*LN-45*/         uint256 _0x3454e7 = _0xc285d4._0x65ce0c(address(this));
/*LN-46*/         uint256 _0x2f7c62 = _0x3184cf._0x65ce0c(address(this));
/*LN-47*/         _0xc285d4._0x2c833f(msg.sender, address(this), _0x70dd97);
/*LN-48*/         _0x3184cf._0x2c833f(msg.sender, address(this), _0xe5feba);
/*LN-49*/         if (_0x1045d1 == 0) {
/*LN-50*/             _0xac561e = _0x70dd97 + _0xe5feba;
/*LN-51*/         } else {
/*LN-52*/             uint256 _0x7248ad = _0x3454e7 + _0x70dd97;
/*LN-53*/             uint256 _0x7d6277 = _0x2f7c62 + _0xe5feba;
/*LN-54*/             _0xac561e = (_0x1045d1 * (_0x70dd97 + _0xe5feba)) / (_0x3454e7 + _0x2f7c62);
/*LN-55*/         }
/*LN-56*/         _0x65ce0c[_0x163f22] += _0xac561e;
/*LN-57*/         _0x1045d1 += _0xac561e;
/*LN-58*/         _0x347a3f(_0x70dd97, _0xe5feba);
/*LN-59*/     }
/*LN-60*/     function _0x8e6f03(
/*LN-61*/         uint256 _0xac561e,
/*LN-62*/         address _0x163f22
/*LN-63*/     ) external returns (uint256 _0x8e4527, uint256 _0x0353ce) {
/*LN-64*/         require(_0x65ce0c[msg.sender] >= _0xac561e, "Insufficient balance");
/*LN-65*/         uint256 _0x3454e7 = _0xc285d4._0x65ce0c(address(this));
/*LN-66*/         uint256 _0x2f7c62 = _0x3184cf._0x65ce0c(address(this));
/*LN-67*/         _0x8e4527 = (_0xac561e * _0x3454e7) / _0x1045d1;
/*LN-68*/         _0x0353ce = (_0xac561e * _0x2f7c62) / _0x1045d1;
/*LN-69*/         _0x65ce0c[msg.sender] -= _0xac561e;
/*LN-70*/         _0x1045d1 -= _0xac561e;
/*LN-71*/         _0xc285d4.transfer(_0x163f22, _0x8e4527);
/*LN-72*/         _0x3184cf.transfer(_0x163f22, _0x0353ce);
/*LN-73*/     }
/*LN-74*/     function _0x771f54() external {
/*LN-75*/         _0x0cce35(_0xd80623._0x0d961f);
/*LN-76*/         _0x347a3f(
/*LN-77*/             _0xc285d4._0x65ce0c(address(this)),
/*LN-78*/             _0x3184cf._0x65ce0c(address(this))
/*LN-79*/         );
/*LN-80*/     }
/*LN-81*/     function _0x347a3f(uint256 _0x8e4527, uint256 _0x0353ce) internal {
/*LN-82*/     }
/*LN-83*/     function _0x0cce35(uint128 _0x0d961f) internal {
/*LN-84*/     }
/*LN-85*/ }