pragma solidity ^0.8.0;


contract ConcentratedLiquidityPool {

    address public _0xa67b32;
    address public _0xe94063;


    uint160 public _0xe27e1c;
    int24 public _0xbdc9e0;
    uint128 public _0x4af2be;


    mapping(int24 => int128) public _0x490348;


    struct Position {
        uint128 _0x4af2be;
        int24 _0xa3ecbe;
        int24 _0x3c332e;
    }

    mapping(bytes32 => Position) public _0x10266e;

    event Swap(
        address indexed sender,
        uint256 _0x5fb8ba,
        uint256 _0xae6936,
        uint256 _0x5e6336,
        uint256 _0x074396
    );

    event LiquidityAdded(
        address indexed _0x32769f,
        int24 _0xa3ecbe,
        int24 _0x3c332e,
        uint128 _0x4af2be
    );


    function _0x61e33c(
        int24 _0xa3ecbe,
        int24 _0x3c332e,
        uint128 _0x833313
    ) external returns (uint256 _0x68fa38, uint256 _0x3c8c40) {
        require(_0xa3ecbe < _0x3c332e, "Invalid ticks");
        require(_0x833313 > 0, "Zero liquidity");


        bytes32 _0x8ef0f8 = _0xa96a0d(
            abi._0xa27d14(msg.sender, _0xa3ecbe, _0x3c332e)
        );


        Position storage _0xd781bd = _0x10266e[_0x8ef0f8];
        _0xd781bd._0x4af2be += _0x833313;
        _0xd781bd._0xa3ecbe = _0xa3ecbe;
        _0xd781bd._0x3c332e = _0x3c332e;


        _0x490348[_0xa3ecbe] += int128(_0x833313);
        _0x490348[_0x3c332e] -= int128(_0x833313);


        if (_0xbdc9e0 >= _0xa3ecbe && _0xbdc9e0 < _0x3c332e) {
            _0x4af2be += _0x833313;
        }


        (_0x68fa38, _0x3c8c40) = _0x2b9aa6(
            _0xe27e1c,
            _0xa3ecbe,
            _0x3c332e,
            int128(_0x833313)
        );

        emit LiquidityAdded(msg.sender, _0xa3ecbe, _0x3c332e, _0x833313);
    }


    function _0x31f3a6(
        bool _0x3e4cec,
        int256 _0x0ae93a,
        uint160 _0x4efe30
    ) external returns (int256 _0x68fa38, int256 _0x3c8c40) {
        require(_0x0ae93a != 0, "Zero amount");


        uint160 _0x4bff4e = _0xe27e1c;
        uint128 _0xda7185 = _0x4af2be;
        int24 _0x3ca066 = _0xbdc9e0;


        while (_0x0ae93a != 0) {

            (
                uint256 _0x609385,
                uint256 _0xf00bd1,
                uint160 _0x2f2de9
            ) = _0xc2bed6(
                    _0x4bff4e,
                    _0x4efe30,
                    _0xda7185,
                    _0x0ae93a
                );


            _0x4bff4e = _0x2f2de9;


            int24 _0xabc39f = _0x3f3aba(_0x4bff4e);
            if (_0xabc39f != _0x3ca066) {

                int128 _0x96d143 = _0x490348[_0xabc39f];

                if (_0x3e4cec) {
                    _0x96d143 = -_0x96d143;
                }

                _0xda7185 = _0xc21a33(
                    _0xda7185,
                    _0x96d143
                );

                _0x3ca066 = _0xabc39f;
            }


            if (_0x0ae93a > 0) {
                _0x0ae93a -= int256(_0x609385);
            } else {
                _0x0ae93a += int256(_0xf00bd1);
            }
        }


        _0xe27e1c = _0x4bff4e;
        _0x4af2be = _0xda7185;
        _0xbdc9e0 = _0x3ca066;

        return (_0x68fa38, _0x3c8c40);
    }


    function _0xc21a33(
        uint128 x,
        int128 y
    ) internal pure returns (uint128 z) {
        if (y < 0) {
            z = x - uint128(-y);
        } else {
            z = x + uint128(y);
        }
    }


    function _0x2b9aa6(
        uint160 _0x07defb,
        int24 _0xa3ecbe,
        int24 _0x3c332e,
        int128 _0x833313
    ) internal pure returns (uint256 _0x68fa38, uint256 _0x3c8c40) {
        _0x68fa38 = uint256(uint128(_0x833313)) / 2;
        _0x3c8c40 = uint256(uint128(_0x833313)) / 2;
    }


    function _0xc2bed6(
        uint160 _0x108bf5,
        uint160 _0x62d705,
        uint128 _0xb5de87,
        int256 _0xc04950
    )
        internal
        pure
        returns (uint256 _0x609385, uint256 _0xf00bd1, uint160 _0xcc13f7)
    {
        _0x609385 =
            uint256(_0xc04950 > 0 ? _0xc04950 : -_0xc04950) /
            2;
        _0xf00bd1 = _0x609385;
        _0xcc13f7 = _0x108bf5;
    }


    function _0x3f3aba(
        uint160 _0xe27e1c
    ) internal pure returns (int24 _0xedad78) {
        return int24(int256(uint256(_0xe27e1c >> 96)));
    }
}