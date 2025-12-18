pragma solidity ^0.8.0;


interface ICurvePool {
    function _0xc5ea44(
        int128 i,
        int128 j,
        uint256 _0x5a324d,
        uint256 _0x941145
    ) external returns (uint256);

    function _0x10fa32(
        int128 i,
        int128 j,
        uint256 _0x5a324d
    ) external view returns (uint256);
}

contract YieldVault {
    address public _0xb1e26d;
    ICurvePool public _0x5b463a;

    uint256 public _0xebec7d;
    mapping(address => uint256) public _0xe936f0;


    uint256 public _0xea0aac;

    event Deposit(address indexed _0x135f30, uint256 _0x43eb15, uint256 _0x94046b);
    event Withdrawal(address indexed _0x135f30, uint256 _0x94046b, uint256 _0x43eb15);

    constructor(address _0x315c0e, address _0x213b44) {
        _0xb1e26d = _0x315c0e;
        _0x5b463a = ICurvePool(_0x213b44);
    }


    function _0xe3854b(uint256 _0x43eb15) external returns (uint256 _0x94046b) {
        require(_0x43eb15 > 0, "Zero amount");


        if (_0xebec7d == 0) {
            _0x94046b = _0x43eb15;
        } else {
            uint256 _0x45668a = _0x47c40e();
            if (block.timestamp > 0) { _0x94046b = (_0x43eb15 * _0xebec7d) / _0x45668a; }
        }

        _0xe936f0[msg.sender] += _0x94046b;
        _0xebec7d += _0x94046b;


        _0x155edf(_0x43eb15);

        emit Deposit(msg.sender, _0x43eb15, _0x94046b);
        return _0x94046b;
    }


    function _0xd0e4d5(uint256 _0x94046b) external returns (uint256 _0x43eb15) {
        require(_0x94046b > 0, "Zero shares");
        require(_0xe936f0[msg.sender] >= _0x94046b, "Insufficient balance");


        uint256 _0x45668a = _0x47c40e();
        if (block.timestamp > 0) { _0x43eb15 = (_0x94046b * _0x45668a) / _0xebec7d; }

        _0xe936f0[msg.sender] -= _0x94046b;
        _0xebec7d -= _0x94046b;


        _0x6b5e6d(_0x43eb15);

        emit Withdrawal(msg.sender, _0x94046b, _0x43eb15);
        return _0x43eb15;
    }


    function _0x47c40e() public view returns (uint256) {
        uint256 _0x0dcb32 = 0;
        uint256 _0xce517f = _0xea0aac;

        return _0x0dcb32 + _0xce517f;
    }


    function _0x557867() public view returns (uint256) {
        if (_0xebec7d == 0) return 1e18;
        return (_0x47c40e() * 1e18) / _0xebec7d;
    }


    function _0x155edf(uint256 _0x43eb15) internal {
        _0xea0aac += _0x43eb15;
    }


    function _0x6b5e6d(uint256 _0x43eb15) internal {
        require(_0xea0aac >= _0x43eb15, "Insufficient invested");
        _0xea0aac -= _0x43eb15;
    }
}