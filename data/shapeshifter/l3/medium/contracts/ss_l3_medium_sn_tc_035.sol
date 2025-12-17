// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x900aa6, uint256 _0xa92f31) external returns (bool);

    function _0xc97266(
        address from,
        address _0x900aa6,
        uint256 _0xa92f31
    ) external returns (bool);

    function _0xfc5bac(address _0xa9187d) external view returns (uint256);

    function _0x2dac12(address _0xddd6e0, uint256 _0xa92f31) external returns (bool);
}

interface IERC721 {
    function _0xc97266(address from, address _0x900aa6, uint256 _0x83c8ce) external;

    function _0x771f76(uint256 _0x83c8ce) external view returns (address);
}

contract WiseLending {
    struct PoolData {
        uint256 _0x443195;
        uint256 _0x318792;
        uint256 _0x2d1e47;
        uint256 _0x18a471;
    }

    mapping(address => PoolData) public _0x3f1d96;
    mapping(uint256 => mapping(address => uint256)) public _0x27e78e;
    mapping(uint256 => mapping(address => uint256)) public _0x327a7e;

    IERC721 public _0x486cf3;
    uint256 public _0x47d01b;

    function _0x0c2df0() external returns (uint256) {
        uint256 _0xe76609 = ++_0x47d01b;
        return _0xe76609;
    }

    function _0xbd6473(
        uint256 _0x13dff2,
        address _0x633665,
        uint256 _0xde7f5a
    ) external returns (uint256 _0x31fc28) {
        IERC20(_0x633665)._0xc97266(msg.sender, address(this), _0xde7f5a);

        PoolData storage _0xbae547 = _0x3f1d96[_0x633665];

        if (_0xbae547._0x318792 == 0) {
            _0x31fc28 = _0xde7f5a;
            _0xbae547._0x318792 = _0xde7f5a;
        } else {
            _0x31fc28 =
                (_0xde7f5a * _0xbae547._0x318792) /
                _0xbae547._0x443195;
            _0xbae547._0x318792 += _0x31fc28;
        }

        _0xbae547._0x443195 += _0xde7f5a;
        _0x27e78e[_0x13dff2][_0x633665] += _0x31fc28;

        return _0x31fc28;
    }

    function _0x9f3967(
        uint256 _0x13dff2,
        address _0x633665,
        uint256 _0xf89207
    ) external returns (uint256 _0x4fe56e) {
        require(
            _0x27e78e[_0x13dff2][_0x633665] >= _0xf89207,
            "Insufficient shares"
        );

        PoolData storage _0xbae547 = _0x3f1d96[_0x633665];

        _0x4fe56e =
            (_0xf89207 * _0xbae547._0x443195) /
            _0xbae547._0x318792;

        _0x27e78e[_0x13dff2][_0x633665] -= _0xf89207;
        _0xbae547._0x318792 -= _0xf89207;
        _0xbae547._0x443195 -= _0x4fe56e;

        IERC20(_0x633665).transfer(msg.sender, _0x4fe56e);

        return _0x4fe56e;
    }

    function _0xfdacb3(
        uint256 _0x13dff2,
        address _0x633665,
        uint256 _0x3133aa
    ) external returns (uint256 _0xd92b3b) {
        PoolData storage _0xbae547 = _0x3f1d96[_0x633665];

        _0xd92b3b =
            (_0x3133aa * _0xbae547._0x318792) /
            _0xbae547._0x443195;

        require(
            _0x27e78e[_0x13dff2][_0x633665] >= _0xd92b3b,
            "Insufficient shares"
        );

        _0x27e78e[_0x13dff2][_0x633665] -= _0xd92b3b;
        _0xbae547._0x318792 -= _0xd92b3b;
        _0xbae547._0x443195 -= _0x3133aa;

        IERC20(_0x633665).transfer(msg.sender, _0x3133aa);

        return _0xd92b3b;
    }

    function _0xdbad45(
        uint256 _0x13dff2,
        address _0x633665
    ) external view returns (uint256) {
        return _0x27e78e[_0x13dff2][_0x633665];
    }

    function _0x91b4c4(address _0x633665) external view returns (uint256) {
        return _0x3f1d96[_0x633665]._0x443195;
    }
}
