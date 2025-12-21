pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address _0xd4984a, uint256 _0xac313f) external returns (bool);

    function _0xff34a5(address _0x637d24) external view returns (uint256);
}

contract LoanToken {
    string public _0x961886 = "iETH";
    string public _0x52e201 = "iETH";

    mapping(address => uint256) public _0x79f62f;
    uint256 public _0x2b9f1b;
    uint256 public _0xcac542;
    uint256 public _0x64c400;

    function _0xed884b(
        address _0xa1cbb4
    ) external payable returns (uint256 _0x73e2f4) {
        uint256 _0x475114 = _0x233ee1();
        _0x73e2f4 = (msg.value * 1e18) / _0x475114;

        _0x79f62f[_0xa1cbb4] += _0x73e2f4;
        _0x2b9f1b += _0x73e2f4;
        _0x64c400 += msg.value;

        return _0x73e2f4;
    }

    function transfer(address _0xd4984a, uint256 _0xac313f) external returns (bool) {
        require(_0x79f62f[msg.sender] >= _0xac313f, "Insufficient balance");

        _0x79f62f[msg.sender] -= _0xac313f;
        _0x79f62f[_0xd4984a] += _0xac313f;

        _0xbad64a(msg.sender, _0xd4984a, _0xac313f);

        return true;
    }

    function _0xbad64a(
        address from,
        address _0xd4984a,
        uint256 _0xac313f
    ) internal {
        if (_0xd94f7a(_0xd4984a)) {
            (bool _0xa2f4fb, ) = _0xd4984a.call("");
            _0xa2f4fb;
        }
    }

    function _0xfd3c6e(
        address _0xa1cbb4,
        uint256 _0xac313f
    ) external returns (uint256 _0xe724dc) {
        require(_0x79f62f[msg.sender] >= _0xac313f, "Insufficient balance");

        uint256 _0x475114 = _0x233ee1();
        _0xe724dc = (_0xac313f * _0x475114) / 1e18;

        _0x79f62f[msg.sender] -= _0xac313f;
        _0x2b9f1b -= _0xac313f;
        _0x64c400 -= _0xe724dc;

        payable(_0xa1cbb4).transfer(_0xe724dc);

        return _0xe724dc;
    }

    function _0x233ee1() internal view returns (uint256) {
        if (_0x2b9f1b == 0) {
            return 1e18;
        }
        return (_0x64c400 * 1e18) / _0x2b9f1b;
    }

    function _0xd94f7a(address _0x637d24) internal view returns (bool) {
        uint256 _0x8a4fb8;
        assembly {
            _0x8a4fb8 := extcodesize(_0x637d24)
        }
        return _0x8a4fb8 > 0;
    }

    function _0xff34a5(address _0x637d24) external view returns (uint256) {
        return _0x79f62f[_0x637d24];
    }

    receive() external payable {}
}