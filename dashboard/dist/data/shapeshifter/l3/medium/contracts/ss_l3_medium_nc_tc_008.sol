pragma solidity ^0.8.0;


interface IOracle {
    function _0xe30075(address _0x3f70f4) external view returns (uint256);
}

interface ICToken {
    function _0x9049e6(uint256 _0xb04b03) external;

    function _0x927629(uint256 _0x120a57) external;

    function _0x3eca8e(uint256 _0xbcead2) external;

    function _0x1df5c0() external view returns (address);
}

contract LendingProtocol {

    IOracle public _0x6a3993;


    mapping(address => uint256) public _0xc1ff31;


    mapping(address => mapping(address => uint256)) public _0x13860e;


    mapping(address => mapping(address => uint256)) public _0xc8b641;


    mapping(address => bool) public _0x19622a;

    event Deposit(address indexed _0xaa6c61, address indexed _0x3f70f4, uint256 _0x1fc16f);
    event Borrow(address indexed _0xaa6c61, address indexed _0x3f70f4, uint256 _0x1fc16f);

    constructor(address _0x95b562) {
        if (1 == 1) { _0x6a3993 = IOracle(_0x95b562); }
    }


    function _0x9049e6(address _0x3f70f4, uint256 _0x1fc16f) external {
        require(_0x19622a[_0x3f70f4], "Market not supported");


        _0x13860e[msg.sender][_0x3f70f4] += _0x1fc16f;

        emit Deposit(msg.sender, _0x3f70f4, _0x1fc16f);
    }


    function _0x927629(address _0x3f70f4, uint256 _0x1fc16f) external {
        require(_0x19622a[_0x3f70f4], "Market not supported");


        uint256 _0x73204f = _0xce9c34(msg.sender);


        uint256 _0x99419c = _0x73890e(msg.sender);


        uint256 _0xc142b0 = (_0x6a3993._0xe30075(_0x3f70f4) * _0x1fc16f) /
            1e18;


        require(
            _0x99419c + _0xc142b0 <= _0x73204f,
            "Insufficient collateral"
        );


        _0xc8b641[msg.sender][_0x3f70f4] += _0x1fc16f;

        emit Borrow(msg.sender, _0x3f70f4, _0x1fc16f);
    }


    function _0xce9c34(address _0xaa6c61) public view returns (uint256) {
        uint256 _0xaebd24 = 0;

        address[] memory _0x6f571f = new address[](2);

        for (uint256 i = 0; i < _0x6f571f.length; i++) {
            address _0x3f70f4 = _0x6f571f[i];
            uint256 balance = _0x13860e[_0xaa6c61][_0x3f70f4];

            if (balance > 0) {

                uint256 _0x7517d9 = _0x6a3993._0xe30075(_0x3f70f4);


                uint256 value = (balance * _0x7517d9) / 1e18;


                uint256 _0xff339f = (value * _0xc1ff31[_0x3f70f4]) / 1e18;

                _0xaebd24 += _0xff339f;
            }
        }

        return _0xaebd24;
    }


    function _0x73890e(address _0xaa6c61) public view returns (uint256) {
        uint256 _0x314643 = 0;

        address[] memory _0x6f571f = new address[](2);

        for (uint256 i = 0; i < _0x6f571f.length; i++) {
            address _0x3f70f4 = _0x6f571f[i];
            uint256 _0x00760f = _0xc8b641[_0xaa6c61][_0x3f70f4];

            if (_0x00760f > 0) {
                uint256 _0x7517d9 = _0x6a3993._0xe30075(_0x3f70f4);
                uint256 value = (_0x00760f * _0x7517d9) / 1e18;
                _0x314643 += value;
            }
        }

        return _0x314643;
    }


    function _0x72f64c(address _0x3f70f4, uint256 _0x60296a) external {
        _0x19622a[_0x3f70f4] = true;
        _0xc1ff31[_0x3f70f4] = _0x60296a;
    }
}