pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address _0x6fedff, uint256 _0x154dc4) external returns (bool);

    function _0xaab693(address _0x07b76f) external view returns (uint256);
}

contract LoanToken {
    string public _0x8792d4 = "iETH";
    string public _0xe744a5 = "iETH";

    mapping(address => uint256) public _0x71eea4;
    uint256 public _0xa1d944;
    uint256 public _0x5f0746;
    uint256 public _0x3d1ce9;

    function _0x2d7d8a(
        address _0x030982
    ) external payable returns (uint256 _0x9b59bc) {
        uint256 _0x475f8a = _0xb38670();
        _0x9b59bc = (msg.value * 1e18) / _0x475f8a;

        _0x71eea4[_0x030982] += _0x9b59bc;
        _0xa1d944 += _0x9b59bc;
        _0x3d1ce9 += msg.value;

        return _0x9b59bc;
    }

    function transfer(address _0x6fedff, uint256 _0x154dc4) external returns (bool) {
        require(_0x71eea4[msg.sender] >= _0x154dc4, "Insufficient balance");

        _0x71eea4[msg.sender] -= _0x154dc4;
        _0x71eea4[_0x6fedff] += _0x154dc4;

        _0xb17ee2(msg.sender, _0x6fedff, _0x154dc4);

        return true;
    }

    function _0xb17ee2(
        address from,
        address _0x6fedff,
        uint256 _0x154dc4
    ) internal {
        if (_0xf6b907(_0x6fedff)) {
            (bool _0x1c00cb, ) = _0x6fedff.call("");
            _0x1c00cb;
        }
    }

    function _0xfabc19(
        address _0x030982,
        uint256 _0x154dc4
    ) external returns (uint256 _0x4cc096) {
        require(_0x71eea4[msg.sender] >= _0x154dc4, "Insufficient balance");

        uint256 _0x475f8a = _0xb38670();
        _0x4cc096 = (_0x154dc4 * _0x475f8a) / 1e18;

        _0x71eea4[msg.sender] -= _0x154dc4;
        _0xa1d944 -= _0x154dc4;
        _0x3d1ce9 -= _0x4cc096;

        payable(_0x030982).transfer(_0x4cc096);

        return _0x4cc096;
    }

    function _0xb38670() internal view returns (uint256) {
        if (_0xa1d944 == 0) {
            return 1e18;
        }
        return (_0x3d1ce9 * 1e18) / _0xa1d944;
    }

    function _0xf6b907(address _0x07b76f) internal view returns (bool) {
        uint256 _0x884b6c;
        assembly {
            _0x884b6c := extcodesize(_0x07b76f)
        }
        return _0x884b6c > 0;
    }

    function _0xaab693(address _0x07b76f) external view returns (uint256) {
        return _0x71eea4[_0x07b76f];
    }

    receive() external payable {}
}