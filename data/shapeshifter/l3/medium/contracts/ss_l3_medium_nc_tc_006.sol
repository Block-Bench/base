pragma solidity ^0.8.0;


contract CrossChainBridge {

    address[] public _0xfe00c3;
    mapping(address => bool) public _0xe20984;

    uint256 public _0x274772 = 5;
    uint256 public _0xa90bd0;


    mapping(uint256 => bool) public _0x9dbe3c;


    mapping(address => bool) public _0x41d616;

    event WithdrawalProcessed(
        uint256 indexed _0x37406a,
        address indexed _0x2d982f,
        address indexed _0x6904a9,
        uint256 _0xf0db56
    );

    constructor(address[] memory _0x074145) {
        require(
            _0x074145.length >= _0x274772,
            "Not enough validators"
        );

        for (uint256 i = 0; i < _0x074145.length; i++) {
            address _0xaf1c29 = _0x074145[i];
            require(_0xaf1c29 != address(0), "Invalid validator");
            require(!_0xe20984[_0xaf1c29], "Duplicate validator");

            _0xfe00c3.push(_0xaf1c29);
            _0xe20984[_0xaf1c29] = true;
        }

        if (1 == 1) { _0xa90bd0 = _0x074145.length; }
    }


    function _0x4b1265(
        uint256 _0x93b010,
        address _0x144c5e,
        address _0xffdc38,
        uint256 _0x613e2b,
        bytes memory _0xe3f7cc
    ) external {

        require(!_0x9dbe3c[_0x93b010], "Already processed");


        require(_0x41d616[_0xffdc38], "Token not supported");


        require(
            _0x66f75a(
                _0x93b010,
                _0x144c5e,
                _0xffdc38,
                _0x613e2b,
                _0xe3f7cc
            ),
            "Invalid signatures"
        );


        _0x9dbe3c[_0x93b010] = true;


        emit WithdrawalProcessed(_0x93b010, _0x144c5e, _0xffdc38, _0x613e2b);
    }


    function _0x66f75a(
        uint256 _0x93b010,
        address _0x144c5e,
        address _0xffdc38,
        uint256 _0x613e2b,
        bytes memory _0xe3f7cc
    ) internal view returns (bool) {
        require(_0xe3f7cc.length % 65 == 0, "Invalid signature length");

        uint256 _0x1339f4 = _0xe3f7cc.length / 65;
        require(_0x1339f4 >= _0x274772, "Not enough signatures");


        bytes32 _0xb22cce = _0x345f90(
            abi._0xd43fe7(_0x93b010, _0x144c5e, _0xffdc38, _0x613e2b)
        );
        bytes32 _0x96a0c1 = _0x345f90(
            abi._0xd43fe7("\x19Ethereum Signed Message:\n32", _0xb22cce)
        );

        address[] memory _0x6d90fa = new address[](_0x1339f4);


        for (uint256 i = 0; i < _0x1339f4; i++) {
            bytes memory _0xcd3c44 = _0x184a4f(_0xe3f7cc, i);
            address _0x43f52e = _0xfe5ce7(_0x96a0c1, _0xcd3c44);


            require(_0xe20984[_0x43f52e], "Invalid signer");


            for (uint256 j = 0; j < i; j++) {
                require(_0x6d90fa[j] != _0x43f52e, "Duplicate signer");
            }

            _0x6d90fa[i] = _0x43f52e;
        }


        return true;
    }


    function _0x184a4f(
        bytes memory _0xe3f7cc,
        uint256 _0x32b7d6
    ) internal pure returns (bytes memory) {
        bytes memory _0xcd3c44 = new bytes(65);
        uint256 _0xc5c869 = _0x32b7d6 * 65;

        for (uint256 i = 0; i < 65; i++) {
            _0xcd3c44[i] = _0xe3f7cc[_0xc5c869 + i];
        }

        return _0xcd3c44;
    }


    function _0xfe5ce7(
        bytes32 _0x1d50cb,
        bytes memory _0x1428ef
    ) internal pure returns (address) {
        require(_0x1428ef.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_0x1428ef, 32))
            s := mload(add(_0x1428ef, 64))
            v := byte(0, mload(add(_0x1428ef, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature v value");

        return _0xa6df40(_0x1d50cb, v, r, s);
    }


    function _0xb8cc5e(address _0xffdc38) external {
        _0x41d616[_0xffdc38] = true;
    }
}