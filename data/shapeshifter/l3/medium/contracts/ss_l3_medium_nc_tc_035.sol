pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x18dd72, uint256 _0x024494) external returns (bool);

    function _0xbe9b43(
        address from,
        address _0x18dd72,
        uint256 _0x024494
    ) external returns (bool);

    function _0x46ea69(address _0xd995cf) external view returns (uint256);

    function _0xe274d7(address _0xc7dcfc, uint256 _0x024494) external returns (bool);
}

interface IERC721 {
    function _0xbe9b43(address from, address _0x18dd72, uint256 _0xeaded1) external;

    function _0xa1e096(uint256 _0xeaded1) external view returns (address);
}

contract WiseLending {
    struct PoolData {
        uint256 _0x3647f7;
        uint256 _0x4a256f;
        uint256 _0xf0fc87;
        uint256 _0xdce8b1;
    }

    mapping(address => PoolData) public _0x268429;
    mapping(uint256 => mapping(address => uint256)) public _0x2a3074;
    mapping(uint256 => mapping(address => uint256)) public _0x24567b;

    IERC721 public _0xb3e041;
    uint256 public _0xa1da0b;

    function _0x5ee3d4() external returns (uint256) {
        uint256 _0xe8423e = ++_0xa1da0b;
        return _0xe8423e;
    }

    function _0x7e0fba(
        uint256 _0x74a467,
        address _0x7681b2,
        uint256 _0xd38ffb
    ) external returns (uint256 _0x6e380b) {
        IERC20(_0x7681b2)._0xbe9b43(msg.sender, address(this), _0xd38ffb);

        PoolData storage _0xb75023 = _0x268429[_0x7681b2];

        if (_0xb75023._0x4a256f == 0) {
            _0x6e380b = _0xd38ffb;
            _0xb75023._0x4a256f = _0xd38ffb;
        } else {
            _0x6e380b =
                (_0xd38ffb * _0xb75023._0x4a256f) /
                _0xb75023._0x3647f7;
            _0xb75023._0x4a256f += _0x6e380b;
        }

        _0xb75023._0x3647f7 += _0xd38ffb;
        _0x2a3074[_0x74a467][_0x7681b2] += _0x6e380b;

        return _0x6e380b;
    }

    function _0xf69855(
        uint256 _0x74a467,
        address _0x7681b2,
        uint256 _0x7c384c
    ) external returns (uint256 _0x0dcfda) {
        require(
            _0x2a3074[_0x74a467][_0x7681b2] >= _0x7c384c,
            "Insufficient shares"
        );

        PoolData storage _0xb75023 = _0x268429[_0x7681b2];

        _0x0dcfda =
            (_0x7c384c * _0xb75023._0x3647f7) /
            _0xb75023._0x4a256f;

        _0x2a3074[_0x74a467][_0x7681b2] -= _0x7c384c;
        _0xb75023._0x4a256f -= _0x7c384c;
        _0xb75023._0x3647f7 -= _0x0dcfda;

        IERC20(_0x7681b2).transfer(msg.sender, _0x0dcfda);

        return _0x0dcfda;
    }

    function _0x3ee531(
        uint256 _0x74a467,
        address _0x7681b2,
        uint256 _0x10fa25
    ) external returns (uint256 _0x8f9c36) {
        PoolData storage _0xb75023 = _0x268429[_0x7681b2];

        _0x8f9c36 =
            (_0x10fa25 * _0xb75023._0x4a256f) /
            _0xb75023._0x3647f7;

        require(
            _0x2a3074[_0x74a467][_0x7681b2] >= _0x8f9c36,
            "Insufficient shares"
        );

        _0x2a3074[_0x74a467][_0x7681b2] -= _0x8f9c36;
        _0xb75023._0x4a256f -= _0x8f9c36;
        _0xb75023._0x3647f7 -= _0x10fa25;

        IERC20(_0x7681b2).transfer(msg.sender, _0x10fa25);

        return _0x8f9c36;
    }

    function _0x969665(
        uint256 _0x74a467,
        address _0x7681b2
    ) external view returns (uint256) {
        return _0x2a3074[_0x74a467][_0x7681b2];
    }

    function _0x7daed0(address _0x7681b2) external view returns (uint256) {
        return _0x268429[_0x7681b2]._0x3647f7;
    }
}