/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ contract BasicSwapPool {
/*LN-3*/     address public _0x961b76;
/*LN-4*/     address public _0xb92839;
/*LN-5*/     uint160 public _0x70dd97;
/*LN-6*/     int24 public _0xd860ea;
/*LN-7*/     uint128 public _0x2f7c62;
/*LN-8*/     mapping(int24 => int128) public _0xe5feba;
/*LN-9*/     struct Position {
/*LN-10*/         uint128 _0x2f7c62;
/*LN-11*/         int24 _0x6e3d9a;
/*LN-12*/         int24 _0xb7cc25;
/*LN-13*/     }
/*LN-14*/     mapping(bytes32 => Position) public _0xac561e;
/*LN-15*/     event Swap(
/*LN-16*/         address indexed sender,
/*LN-17*/         uint256 _0x3454e7,
/*LN-18*/         uint256 _0x3184cf,
/*LN-19*/         uint256 _0x8e4527,
/*LN-20*/         uint256 _0xae3550
/*LN-21*/     );
/*LN-22*/     event LiquidityAdded(
/*LN-23*/         address indexed _0x163f22,
/*LN-24*/         int24 _0x6e3d9a,
/*LN-25*/         int24 _0xb7cc25,
/*LN-26*/         uint128 _0x2f7c62
/*LN-27*/     );
/*LN-28*/     function _0xd6cb4d(
/*LN-29*/         int24 _0x6e3d9a,
/*LN-30*/         int24 _0xb7cc25,
/*LN-31*/         uint128 _0x771f54
/*LN-32*/     ) external returns (uint256 _0x28587f, uint256 _0xc1cf42) {
/*LN-33*/         require(_0x6e3d9a < _0xb7cc25, "Invalid ticks");
/*LN-34*/         require(_0x771f54 > 0, "Zero liquidity");
/*LN-35*/         bytes32 _0x51bedd = keccak256(
/*LN-36*/             abi._0x8e6f03(msg.sender, _0x6e3d9a, _0xb7cc25)
/*LN-37*/         );
/*LN-38*/         Position storage _0x876f47 = _0xac561e[_0x51bedd];
/*LN-39*/         _0x876f47._0x2f7c62 += _0x771f54;
/*LN-40*/         _0x876f47._0x6e3d9a = _0x6e3d9a;
/*LN-41*/         _0x876f47._0xb7cc25 = _0xb7cc25;
/*LN-42*/         _0xe5feba[_0x6e3d9a] += int128(_0x771f54);
/*LN-43*/         _0xe5feba[_0xb7cc25] -= int128(_0x771f54);
/*LN-44*/         if (_0xd860ea >= _0x6e3d9a && _0xd860ea < _0xb7cc25) {
/*LN-45*/             _0x2f7c62 += _0x771f54;
/*LN-46*/         }
/*LN-47*/         (_0x28587f, _0xc1cf42) = _0x347a3f(
/*LN-48*/             _0x70dd97,
/*LN-49*/             _0x6e3d9a,
/*LN-50*/             _0xb7cc25,
/*LN-51*/             int128(_0x771f54)
/*LN-52*/         );
/*LN-53*/         emit LiquidityAdded(msg.sender, _0x6e3d9a, _0xb7cc25, _0x771f54);
/*LN-54*/     }
/*LN-55*/     function _0x239cbb(
/*LN-56*/         bool _0x4f9b02,
/*LN-57*/         int256 _0x2ff8d2,
/*LN-58*/         uint160 _0x477183
/*LN-59*/     ) external returns (int256 _0x28587f, int256 _0xc1cf42) {
/*LN-60*/         require(_0x2ff8d2 != 0, "Zero amount");
/*LN-61*/         uint160 _0x2c833f = _0x70dd97;
/*LN-62*/         uint128 _0x65ce0c = _0x2f7c62;
/*LN-63*/         int24 _0x3fe936 = _0xd860ea;
/*LN-64*/         while (_0x2ff8d2 != 0) {
/*LN-65*/             (
/*LN-66*/                 uint256 _0xeb39bc,
/*LN-67*/                 uint256 _0xc285d4,
/*LN-68*/                 uint160 _0x7d6277
/*LN-69*/             ) = _0xd80623(
/*LN-70*/                     _0x2c833f,
/*LN-71*/                     _0x477183,
/*LN-72*/                     _0x65ce0c,
/*LN-73*/                     _0x2ff8d2
/*LN-74*/                 );
/*LN-75*/             _0x2c833f = _0x7d6277;
/*LN-76*/             int24 _0x0353ce = _0x0cce35(_0x2c833f);
/*LN-77*/             if (_0x0353ce != _0x3fe936) {
/*LN-78*/                 int128 _0x8cd0a4 = _0xe5feba[_0x0353ce];
/*LN-79*/                 if (_0x4f9b02) {
/*LN-80*/                     _0x8cd0a4 = -_0x8cd0a4;
/*LN-81*/                 }
/*LN-82*/                 _0x65ce0c = _0x0d961f(
/*LN-83*/                     _0x65ce0c,
/*LN-84*/                     _0x8cd0a4
/*LN-85*/                 );
/*LN-86*/                 _0x3fe936 = _0x0353ce;
/*LN-87*/             }
/*LN-88*/             if (_0x2ff8d2 > 0) {
/*LN-89*/                 _0x2ff8d2 -= int256(_0xeb39bc);
/*LN-90*/             } else {
/*LN-91*/                 _0x2ff8d2 += int256(_0xc285d4);
/*LN-92*/             }
/*LN-93*/         }
/*LN-94*/         _0x70dd97 = _0x2c833f;
/*LN-95*/         _0x2f7c62 = _0x65ce0c;
/*LN-96*/         _0xd860ea = _0x3fe936;
/*LN-97*/         return (_0x28587f, _0xc1cf42);
/*LN-98*/     }
/*LN-99*/     function _0x0d961f(
/*LN-100*/         uint128 x,
/*LN-101*/         int128 y
/*LN-102*/     ) internal pure returns (uint128 z) {
/*LN-103*/         if (y < 0) {
/*LN-104*/             z = x - uint128(-y);
/*LN-105*/         } else {
/*LN-106*/             z = x + uint128(y);
/*LN-107*/         }
/*LN-108*/     }
/*LN-109*/     function _0x347a3f(
/*LN-110*/         uint160 _0xb01af6,
/*LN-111*/         int24 _0x6e3d9a,
/*LN-112*/         int24 _0xb7cc25,
/*LN-113*/         int128 _0x771f54
/*LN-114*/     ) internal pure returns (uint256 _0x28587f, uint256 _0xc1cf42) {
/*LN-115*/         _0x28587f = uint256(uint128(_0x771f54)) / 2;
/*LN-116*/         _0xc1cf42 = uint256(uint128(_0x771f54)) / 2;
/*LN-117*/     }
/*LN-118*/     function _0xd80623(
/*LN-119*/         uint160 _0x390062,
/*LN-120*/         uint160 _0x7248ad,
/*LN-121*/         uint128 _0x0f4194,
/*LN-122*/         int256 _0x6ff151
/*LN-123*/     )
/*LN-124*/         internal
/*LN-125*/         pure
/*LN-126*/         returns (uint256 _0xeb39bc, uint256 _0xc285d4, uint160 _0x1045d1) {
/*LN-127*/         _0xeb39bc =
/*LN-128*/             uint256(_0x6ff151 > 0 ? _0x6ff151 : -_0x6ff151) /
/*LN-129*/             2;
/*LN-130*/         _0xc285d4 = _0xeb39bc;
/*LN-131*/         _0x1045d1 = _0x390062;
/*LN-132*/     }
/*LN-133*/     function _0x0cce35(
/*LN-134*/         uint160 _0x70dd97
/*LN-135*/     ) internal pure returns (int24 _0x6273a6) {
/*LN-136*/         return int24(int256(uint256(_0x70dd97 >> 96)));
/*LN-137*/     }
/*LN-138*/ }