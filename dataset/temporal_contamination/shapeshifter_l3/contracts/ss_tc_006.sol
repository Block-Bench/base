/*LN-1*/ pragma solidity ^0.8.0;
/*LN-2*/ contract BasicBridge {
/*LN-3*/     address[] public _0x8e6f03;
/*LN-4*/     mapping(address => bool) public _0x70dd97;
/*LN-5*/     uint256 public _0x8cd0a4 = 5;
/*LN-6*/     uint256 public _0xd80623;
/*LN-7*/     mapping(uint256 => bool) public _0x390062;
/*LN-8*/     mapping(address => bool) public _0x2c833f;
/*LN-9*/     event WithdrawalProcessed(
/*LN-10*/         uint256 indexed _0x6ff151,
/*LN-11*/         address indexed _0xb7cc25,
/*LN-12*/         address indexed _0xc285d4,
/*LN-13*/         uint256 _0x4f9b02
/*LN-14*/     );
/*LN-15*/     constructor(address[] memory _0x0d961f) {
/*LN-16*/         require(
/*LN-17*/             _0x0d961f.length >= _0x8cd0a4,
/*LN-18*/             "Not enough validators"
/*LN-19*/         );
/*LN-20*/         for (uint256 i = 0; i < _0x0d961f.length; i++) {
/*LN-21*/             address _0x51bedd = _0x0d961f[i];
/*LN-22*/             require(_0x51bedd != address(0), "Invalid validator");
/*LN-23*/             require(!_0x70dd97[_0x51bedd], "Duplicate validator");
/*LN-24*/             _0x8e6f03.push(_0x51bedd);
/*LN-25*/             _0x70dd97[_0x51bedd] = true;
/*LN-26*/         }
/*LN-27*/         _0xd80623 = _0x0d961f.length;
/*LN-28*/     }
/*LN-29*/     function _0x347a3f(
/*LN-30*/         uint256 _0x2ff8d2,
/*LN-31*/         address _0x3184cf,
/*LN-32*/         address _0x6e3d9a,
/*LN-33*/         uint256 _0xae3550,
/*LN-34*/         bytes memory _0x65ce0c
/*LN-35*/     ) external {
/*LN-36*/         require(!_0x390062[_0x2ff8d2], "Already processed");
/*LN-37*/         require(_0x2c833f[_0x6e3d9a], "Token not supported");
/*LN-38*/         require(
/*LN-39*/             _0x7248ad(
/*LN-40*/                 _0x2ff8d2,
/*LN-41*/                 _0x3184cf,
/*LN-42*/                 _0x6e3d9a,
/*LN-43*/                 _0xae3550,
/*LN-44*/                 _0x65ce0c
/*LN-45*/             ),
/*LN-46*/             "Invalid signatures"
/*LN-47*/         );
/*LN-48*/         _0x390062[_0x2ff8d2] = true;
/*LN-49*/         emit WithdrawalProcessed(_0x2ff8d2, _0x3184cf, _0x6e3d9a, _0xae3550);
/*LN-50*/     }
/*LN-51*/     function _0x7248ad(
/*LN-52*/         uint256 _0x2ff8d2,
/*LN-53*/         address _0x3184cf,
/*LN-54*/         address _0x6e3d9a,
/*LN-55*/         uint256 _0xae3550,
/*LN-56*/         bytes memory _0x65ce0c
/*LN-57*/     ) internal view returns (bool) {
/*LN-58*/         require(_0x65ce0c.length % 65 == 0, "Invalid signature length");
/*LN-59*/         uint256 _0x1045d1 = _0x65ce0c.length / 65;
/*LN-60*/         require(_0x1045d1 >= _0x8cd0a4, "Not enough signatures");
/*LN-61*/         bytes32 _0xd6cb4d = keccak256(
/*LN-62*/             abi._0x771f54(_0x2ff8d2, _0x3184cf, _0x6e3d9a, _0xae3550)
/*LN-63*/         );
/*LN-64*/         bytes32 _0x0cce35 = keccak256(
/*LN-65*/             abi._0x771f54("\x19Ethereum Signed Message:\n32", _0xd6cb4d)
/*LN-66*/         );
/*LN-67*/         address[] memory _0xd860ea = new address[](_0x1045d1);
/*LN-68*/         for (uint256 i = 0; i < _0x1045d1; i++) {
/*LN-69*/             bytes memory _0x0353ce = _0x7d6277(_0x65ce0c, i);
/*LN-70*/             address _0x3454e7 = _0x0f4194(_0x0cce35, _0x0353ce);
/*LN-71*/             require(_0x70dd97[_0x3454e7], "Invalid signer");
/*LN-72*/             for (uint256 j = 0; j < i; j++) {
/*LN-73*/                 require(_0xd860ea[j] != _0x3454e7, "Duplicate signer");
/*LN-74*/             }
/*LN-75*/             _0xd860ea[i] = _0x3454e7;
/*LN-76*/         }
/*LN-77*/         return true;
/*LN-78*/     }
/*LN-79*/     function _0x7d6277(
/*LN-80*/         bytes memory _0x65ce0c,
/*LN-81*/         uint256 _0x8e4527
/*LN-82*/     ) internal pure returns (bytes memory) {
/*LN-83*/         bytes memory _0x0353ce = new bytes(65);
/*LN-84*/         uint256 _0xac561e = _0x8e4527 * 65;
/*LN-85*/         for (uint256 i = 0; i < 65; i++) {
/*LN-86*/             _0x0353ce[i] = _0x65ce0c[_0xac561e + i];
/*LN-87*/         }
/*LN-88*/         return _0x0353ce;
/*LN-89*/     }
/*LN-90*/     function _0x0f4194(
/*LN-91*/         bytes32 _0x2f7c62,
/*LN-92*/         bytes memory _0xe5feba
/*LN-93*/     ) internal pure returns (address) {
/*LN-94*/         require(_0xe5feba.length == 65, "Invalid signature length");
/*LN-95*/         bytes32 r;
/*LN-96*/         bytes32 s;
/*LN-97*/         uint8 v;
/*LN-98*/         assembly {
/*LN-99*/             r := mload(add(_0xe5feba, 32))
/*LN-100*/             s := mload(add(_0xe5feba, 64))
/*LN-101*/             v := byte(0, mload(add(_0xe5feba, 96)))
/*LN-102*/         }
/*LN-103*/         if (v < 27) {
/*LN-104*/             v += 27;
/*LN-105*/         }
/*LN-106*/         require(v == 27 || v == 28, "Invalid signature v value");
/*LN-107*/         return ecrecover(_0x2f7c62, v, r, s);
/*LN-108*/     }
/*LN-109*/     function _0x477183(address _0x6e3d9a) external {
/*LN-110*/         _0x2c833f[_0x6e3d9a] = true;
/*LN-111*/     }
/*LN-112*/ }