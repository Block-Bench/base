pragma solidity ^0.8.0;


interface IOracle {
    function _0xb1f3c3(address _0xe0b250) external view returns (uint256);
}

interface ICToken {
    function _0x8d791c(uint256 _0xc843ec) external;

    function _0xca32bd(uint256 _0xf1d231) external;

    function _0xb78570(uint256 _0x43a682) external;

    function _0x86c0b4() external view returns (address);
}

contract LendingProtocol {

    IOracle public _0xb95b10;


    mapping(address => uint256) public _0x73175e;


    mapping(address => mapping(address => uint256)) public _0xdff225;


    mapping(address => mapping(address => uint256)) public _0x4b9ad2;


    mapping(address => bool) public _0xa99010;

    event Deposit(address indexed _0x6d12f2, address indexed _0xe0b250, uint256 _0xa36dfe);
    event Borrow(address indexed _0x6d12f2, address indexed _0xe0b250, uint256 _0xa36dfe);

    constructor(address _0x93d69f) {
        _0xb95b10 = IOracle(_0x93d69f);
    }


    function _0x8d791c(address _0xe0b250, uint256 _0xa36dfe) external {
        require(_0xa99010[_0xe0b250], "Market not supported");


        _0xdff225[msg.sender][_0xe0b250] += _0xa36dfe;

        emit Deposit(msg.sender, _0xe0b250, _0xa36dfe);
    }


    function _0xca32bd(address _0xe0b250, uint256 _0xa36dfe) external {
        require(_0xa99010[_0xe0b250], "Market not supported");


        uint256 _0xee644f = _0x939813(msg.sender);


        uint256 _0x0ec437 = _0x80ec52(msg.sender);


        uint256 _0xc2a8a0 = (_0xb95b10._0xb1f3c3(_0xe0b250) * _0xa36dfe) /
            1e18;


        require(
            _0x0ec437 + _0xc2a8a0 <= _0xee644f,
            "Insufficient collateral"
        );


        _0x4b9ad2[msg.sender][_0xe0b250] += _0xa36dfe;

        emit Borrow(msg.sender, _0xe0b250, _0xa36dfe);
    }


    function _0x939813(address _0x6d12f2) public view returns (uint256) {
        uint256 _0xc98f16 = 0;

        address[] memory _0x9ad5bf = new address[](2);

        for (uint256 i = 0; i < _0x9ad5bf.length; i++) {
            address _0xe0b250 = _0x9ad5bf[i];
            uint256 balance = _0xdff225[_0x6d12f2][_0xe0b250];

            if (balance > 0) {

                uint256 _0x15bc81 = _0xb95b10._0xb1f3c3(_0xe0b250);


                uint256 value = (balance * _0x15bc81) / 1e18;


                uint256 _0xab3dea = (value * _0x73175e[_0xe0b250]) / 1e18;

                _0xc98f16 += _0xab3dea;
            }
        }

        return _0xc98f16;
    }


    function _0x80ec52(address _0x6d12f2) public view returns (uint256) {
        uint256 _0x11b106 = 0;

        address[] memory _0x9ad5bf = new address[](2);

        for (uint256 i = 0; i < _0x9ad5bf.length; i++) {
            address _0xe0b250 = _0x9ad5bf[i];
            uint256 _0x827561 = _0x4b9ad2[_0x6d12f2][_0xe0b250];

            if (_0x827561 > 0) {
                uint256 _0x15bc81 = _0xb95b10._0xb1f3c3(_0xe0b250);
                uint256 value = (_0x827561 * _0x15bc81) / 1e18;
                _0x11b106 += value;
            }
        }

        return _0x11b106;
    }


    function _0x6f567e(address _0xe0b250, uint256 _0xee5d2c) external {
        _0xa99010[_0xe0b250] = true;
        _0x73175e[_0xe0b250] = _0xee5d2c;
    }
}