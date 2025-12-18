pragma solidity ^0.8.0;

interface IERC20 {
    function _0xfc9841(address _0xbc60a6) external view returns (uint256);

    function transfer(address _0xb96426, uint256 _0x55b74d) external returns (bool);
}

contract TokenPool {
    struct Token {
        address _0x2bca2b;
        uint256 balance;
        uint256 _0x90d7cd;
    }

    mapping(address => Token) public _0xc37ce2;
    address[] public _0xb7c424;
    uint256 public _0xcebf29;

    constructor() {
        _0xcebf29 = 100;
    }

    function _0x480c13(address _0x873e7d, uint256 _0xc247b9) external {
        _0xc37ce2[_0x873e7d] = Token({_0x2bca2b: _0x873e7d, balance: 0, _0x90d7cd: _0xc247b9});
        _0xb7c424.push(_0x873e7d);
    }

    function _0x8cd0f9(
        address _0x4ed277,
        address _0xde1a54,
        uint256 _0x3a5f77
    ) external returns (uint256 _0x946cef) {
        require(_0xc37ce2[_0x4ed277]._0x2bca2b != address(0), "Invalid token");
        require(_0xc37ce2[_0xde1a54]._0x2bca2b != address(0), "Invalid token");

        IERC20(_0x4ed277).transfer(address(this), _0x3a5f77);
        _0xc37ce2[_0x4ed277].balance += _0x3a5f77;

        _0x946cef = _0x616aae(_0x4ed277, _0xde1a54, _0x3a5f77);

        require(
            _0xc37ce2[_0xde1a54].balance >= _0x946cef,
            "Insufficient liquidity"
        );
        _0xc37ce2[_0xde1a54].balance -= _0x946cef;
        IERC20(_0xde1a54).transfer(msg.sender, _0x946cef);

        _0x409d82();

        return _0x946cef;
    }

    function _0x616aae(
        address _0x4ed277,
        address _0xde1a54,
        uint256 _0x3a5f77
    ) public view returns (uint256) {
        uint256 _0xa1d28b = _0xc37ce2[_0x4ed277]._0x90d7cd;
        uint256 _0x6cdcb1 = _0xc37ce2[_0xde1a54]._0x90d7cd;
        uint256 _0x52351d = _0xc37ce2[_0xde1a54].balance;

        uint256 _0x03706c = _0x52351d * _0x3a5f77 * _0x6cdcb1;
        uint256 _0x66ced0 = _0xc37ce2[_0x4ed277].balance *
            _0xa1d28b +
            _0x3a5f77 *
            _0x6cdcb1;

        return _0x03706c / _0x66ced0;
    }

    function _0x409d82() internal {
        uint256 _0x817680 = 0;

        for (uint256 i = 0; i < _0xb7c424.length; i++) {
            address _0x873e7d = _0xb7c424[i];
            _0x817680 += _0xc37ce2[_0x873e7d].balance;
        }

        for (uint256 i = 0; i < _0xb7c424.length; i++) {
            address _0x873e7d = _0xb7c424[i];
            _0xc37ce2[_0x873e7d]._0x90d7cd = (_0xc37ce2[_0x873e7d].balance * 100) / _0x817680;
        }
    }

    function _0x553497(address _0x873e7d) external view returns (uint256) {
        return _0xc37ce2[_0x873e7d]._0x90d7cd;
    }

    function _0xce1f73(address _0x873e7d, uint256 _0x55b74d) external {
        require(_0xc37ce2[_0x873e7d]._0x2bca2b != address(0), "Invalid token");
        IERC20(_0x873e7d).transfer(address(this), _0x55b74d);
        _0xc37ce2[_0x873e7d].balance += _0x55b74d;
        _0x409d82();
    }
}