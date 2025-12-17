// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x41ba3a, uint256 _0xbb9b6e) external returns (bool);

    function _0x184294(
        address from,
        address _0x41ba3a,
        uint256 _0xbb9b6e
    ) external returns (bool);

    function _0x786c9f(address _0x22c9fd) external view returns (uint256);

    function _0x8535eb(address _0x79c8fa, uint256 _0xbb9b6e) external returns (bool);
}

contract ShezmuCollateralToken is IERC20 {
    string public _0x42a4fb = "Shezmu Collateral Token";
    string public _0x253b05 = "SCT";
    uint8 public _0xe35a07 = 18;

    mapping(address => uint256) public _0x786c9f;
    mapping(address => mapping(address => uint256)) public _0x513b59;
    uint256 public _0x44e627;

    function _0x2dfe4a(address _0x41ba3a, uint256 _0xbb9b6e) external {
        _0x786c9f[_0x41ba3a] += _0xbb9b6e;
        _0x44e627 += _0xbb9b6e;
    }

    function transfer(
        address _0x41ba3a,
        uint256 _0xbb9b6e
    ) external override returns (bool) {
        require(_0x786c9f[msg.sender] >= _0xbb9b6e, "Insufficient balance");
        _0x786c9f[msg.sender] -= _0xbb9b6e;
        _0x786c9f[_0x41ba3a] += _0xbb9b6e;
        return true;
    }

    function _0x184294(
        address from,
        address _0x41ba3a,
        uint256 _0xbb9b6e
    ) external override returns (bool) {
        require(_0x786c9f[from] >= _0xbb9b6e, "Insufficient balance");
        require(
            _0x513b59[from][msg.sender] >= _0xbb9b6e,
            "Insufficient allowance"
        );
        _0x786c9f[from] -= _0xbb9b6e;
        _0x786c9f[_0x41ba3a] += _0xbb9b6e;
        _0x513b59[from][msg.sender] -= _0xbb9b6e;
        return true;
    }

    function _0x8535eb(
        address _0x79c8fa,
        uint256 _0xbb9b6e
    ) external override returns (bool) {
        _0x513b59[msg.sender][_0x79c8fa] = _0xbb9b6e;
        return true;
    }
}

contract ShezmuVault {
    IERC20 public _0x92319e;
    IERC20 public _0x08cdfa;

    mapping(address => uint256) public _0x5d990f;
    mapping(address => uint256) public _0x85692f;

    uint256 public constant COLLATERAL_RATIO = 150;
    uint256 public constant BASIS_POINTS = 100;

    constructor(address _0xb62d13, address _0xac6928) {
        _0x92319e = IERC20(_0xb62d13);
        _0x08cdfa = IERC20(_0xac6928);
    }

    function _0xad5b64(uint256 _0xbb9b6e) external {
        _0x92319e._0x184294(msg.sender, address(this), _0xbb9b6e);
        _0x5d990f[msg.sender] += _0xbb9b6e;
    }

    function _0x22a21f(uint256 _0xbb9b6e) external {
        uint256 _0x872843 = (_0x5d990f[msg.sender] * BASIS_POINTS) /
            COLLATERAL_RATIO;

        require(
            _0x85692f[msg.sender] + _0xbb9b6e <= _0x872843,
            "Insufficient collateral"
        );

        _0x85692f[msg.sender] += _0xbb9b6e;

        _0x08cdfa.transfer(msg.sender, _0xbb9b6e);
    }

    function _0x3f345d(uint256 _0xbb9b6e) external {
        require(_0x85692f[msg.sender] >= _0xbb9b6e, "Excessive repayment");
        _0x08cdfa._0x184294(msg.sender, address(this), _0xbb9b6e);
        _0x85692f[msg.sender] -= _0xbb9b6e;
    }

    function _0x4b3365(uint256 _0xbb9b6e) external {
        require(
            _0x5d990f[msg.sender] >= _0xbb9b6e,
            "Insufficient collateral"
        );
        uint256 _0xb20cdd = _0x5d990f[msg.sender] - _0xbb9b6e;
        uint256 _0xb4a3ea = (_0xb20cdd * BASIS_POINTS) /
            COLLATERAL_RATIO;
        require(
            _0x85692f[msg.sender] <= _0xb4a3ea,
            "Would be undercollateralized"
        );

        _0x5d990f[msg.sender] -= _0xbb9b6e;
        _0x92319e.transfer(msg.sender, _0xbb9b6e);
    }
}
