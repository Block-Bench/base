pragma solidity ^0.8.0;


contract ConcentratedLiquidityPool {

    address public _0xcd988c;
    address public _0x614c8e;


    uint160 public _0x111790;
    int24 public _0x160fa4;
    uint128 public _0xe98092;


    mapping(int24 => int128) public _0x2a72ae;


    struct Position {
        uint128 _0xe98092;
        int24 _0x88d511;
        int24 _0x870e38;
    }

    mapping(bytes32 => Position) public _0xd6fea7;

    event Swap(
        address indexed sender,
        uint256 _0x71db00,
        uint256 _0xb989a9,
        uint256 _0x30a617,
        uint256 _0x69c8fc
    );

    event LiquidityAdded(
        address indexed _0x5eb46b,
        int24 _0x88d511,
        int24 _0x870e38,
        uint128 _0xe98092
    );


    function _0xd74028(
        int24 _0x88d511,
        int24 _0x870e38,
        uint128 _0x729aff
    ) external returns (uint256 _0xa31881, uint256 _0x526523) {
        require(_0x88d511 < _0x870e38, "Invalid ticks");
        require(_0x729aff > 0, "Zero liquidity");


        bytes32 _0xf38f58 = _0xc37866(
            abi._0x9413ce(msg.sender, _0x88d511, _0x870e38)
        );


        Position storage _0xe1517e = _0xd6fea7[_0xf38f58];
        _0xe1517e._0xe98092 += _0x729aff;
        _0xe1517e._0x88d511 = _0x88d511;
        _0xe1517e._0x870e38 = _0x870e38;


        _0x2a72ae[_0x88d511] += int128(_0x729aff);
        _0x2a72ae[_0x870e38] -= int128(_0x729aff);


        if (_0x160fa4 >= _0x88d511 && _0x160fa4 < _0x870e38) {
            _0xe98092 += _0x729aff;
        }


        (_0xa31881, _0x526523) = _0x191bdb(
            _0x111790,
            _0x88d511,
            _0x870e38,
            int128(_0x729aff)
        );

        emit LiquidityAdded(msg.sender, _0x88d511, _0x870e38, _0x729aff);
    }


    function _0x771263(
        bool _0x96ef6b,
        int256 _0x1cd573,
        uint160 _0x1d5cfd
    ) external returns (int256 _0xa31881, int256 _0x526523) {
        require(_0x1cd573 != 0, "Zero amount");


        uint160 _0xe32d51 = _0x111790;
        uint128 _0xce10be = _0xe98092;
        int24 _0xc208a9 = _0x160fa4;


        while (_0x1cd573 != 0) {

            (
                uint256 _0x9c826a,
                uint256 _0x2e9d37,
                uint160 _0x2c0369
            ) = _0x552144(
                    _0xe32d51,
                    _0x1d5cfd,
                    _0xce10be,
                    _0x1cd573
                );


            _0xe32d51 = _0x2c0369;


            int24 _0x89dfdc = _0x1d1c93(_0xe32d51);
            if (_0x89dfdc != _0xc208a9) {

                int128 _0x7cb0b7 = _0x2a72ae[_0x89dfdc];

                if (_0x96ef6b) {
                    _0x7cb0b7 = -_0x7cb0b7;
                }

                _0xce10be = _0x1b85bf(
                    _0xce10be,
                    _0x7cb0b7
                );

                _0xc208a9 = _0x89dfdc;
            }


            if (_0x1cd573 > 0) {
                _0x1cd573 -= int256(_0x9c826a);
            } else {
                _0x1cd573 += int256(_0x2e9d37);
            }
        }


        _0x111790 = _0xe32d51;
        _0xe98092 = _0xce10be;
        _0x160fa4 = _0xc208a9;

        return (_0xa31881, _0x526523);
    }


    function _0x1b85bf(
        uint128 x,
        int128 y
    ) internal pure returns (uint128 z) {
        if (y < 0) {
            z = x - uint128(-y);
        } else {
            z = x + uint128(y);
        }
    }


    function _0x191bdb(
        uint160 _0x725b0c,
        int24 _0x88d511,
        int24 _0x870e38,
        int128 _0x729aff
    ) internal pure returns (uint256 _0xa31881, uint256 _0x526523) {
        _0xa31881 = uint256(uint128(_0x729aff)) / 2;
        _0x526523 = uint256(uint128(_0x729aff)) / 2;
    }


    function _0x552144(
        uint160 _0x178b50,
        uint160 _0x87b616,
        uint128 _0x0959e5,
        int256 _0x60395c
    )
        internal
        pure
        returns (uint256 _0x9c826a, uint256 _0x2e9d37, uint160 _0x55f6f1)
    {
        _0x9c826a =
            uint256(_0x60395c > 0 ? _0x60395c : -_0x60395c) /
            2;
        _0x2e9d37 = _0x9c826a;
        _0x55f6f1 = _0x178b50;
    }


    function _0x1d1c93(
        uint160 _0x111790
    ) internal pure returns (int24 _0x00ab6d) {
        return int24(int256(uint256(_0x111790 >> 96)));
    }
}