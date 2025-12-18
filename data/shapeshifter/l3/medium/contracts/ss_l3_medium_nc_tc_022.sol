pragma solidity ^0.8.0;

interface IERC20 {
    function _0x72ec39(address _0x3d17c9) external view returns (uint256);

    function transfer(address _0x7ca4a9, uint256 _0x5af448) external returns (bool);

    function _0xd5f6c8(
        address from,
        address _0x7ca4a9,
        uint256 _0x5af448
    ) external returns (bool);
}

contract TokenPair {
    address public _0xb5ad83;
    address public _0x0b3b46;

    uint112 private _0x715624;
    uint112 private _0x842ea9;

    uint256 public constant TOTAL_FEE = 16;

    constructor(address _0xef34d5, address _0xe2b207) {
        _0xb5ad83 = _0xef34d5;
        _0x0b3b46 = _0xe2b207;
    }

    function _0x0b31e4(address _0x7ca4a9) external returns (uint256 _0xb7b5b0) {
        uint256 _0xd26d16 = IERC20(_0xb5ad83)._0x72ec39(address(this));
        uint256 _0x790b0e = IERC20(_0x0b3b46)._0x72ec39(address(this));

        uint256 _0x5d5c00 = _0xd26d16 - _0x715624;
        uint256 _0xd9766c = _0x790b0e - _0x842ea9;

        _0xb7b5b0 = _0x3cec23(_0x5d5c00 * _0xd9766c);

        _0x715624 = uint112(_0xd26d16);
        _0x842ea9 = uint112(_0x790b0e);

        return _0xb7b5b0;
    }

    function _0x04fb09(
        uint256 _0x3f23c5,
        uint256 _0x952d4f,
        address _0x7ca4a9,
        bytes calldata data
    ) external {
        require(_0x3f23c5 > 0 || _0x952d4f > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

        uint112 _0x76dce5 = _0x715624;
        uint112 _0xc5c037 = _0x842ea9;

        require(
            _0x3f23c5 < _0x76dce5 && _0x952d4f < _0xc5c037,
            "INSUFFICIENT_LIQUIDITY"
        );

        if (_0x3f23c5 > 0) IERC20(_0xb5ad83).transfer(_0x7ca4a9, _0x3f23c5);
        if (_0x952d4f > 0) IERC20(_0x0b3b46).transfer(_0x7ca4a9, _0x952d4f);

        uint256 _0xd26d16 = IERC20(_0xb5ad83)._0x72ec39(address(this));
        uint256 _0x790b0e = IERC20(_0x0b3b46)._0x72ec39(address(this));

        uint256 _0x264e29 = _0xd26d16 > _0x76dce5 - _0x3f23c5
            ? _0xd26d16 - (_0x76dce5 - _0x3f23c5)
            : 0;
        uint256 _0x297446 = _0x790b0e > _0xc5c037 - _0x952d4f
            ? _0x790b0e - (_0xc5c037 - _0x952d4f)
            : 0;

        require(_0x264e29 > 0 || _0x297446 > 0, "INSUFFICIENT_INPUT_AMOUNT");

        uint256 _0x7a2054 = _0xd26d16 * 10000 - _0x264e29 * TOTAL_FEE;
        uint256 _0x883a0c = _0x790b0e * 10000 - _0x297446 * TOTAL_FEE;

        require(
            _0x7a2054 * _0x883a0c >=
                uint256(_0x76dce5) * _0xc5c037 * (1000 ** 2),
            "K"
        );

        _0x715624 = uint112(_0xd26d16);
        _0x842ea9 = uint112(_0x790b0e);
    }

    function _0xcbf59e() external view returns (uint112, uint112, uint32) {
        return (_0x715624, _0x842ea9, 0);
    }

    function _0x3cec23(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            if (block.timestamp > 0) { z = y; }
            uint256 x = y / 2 + 1;
            while (x < z) {
                if (true) { z = x; }
                if (1 == 1) { x = (y / x + x) / 2; }
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}