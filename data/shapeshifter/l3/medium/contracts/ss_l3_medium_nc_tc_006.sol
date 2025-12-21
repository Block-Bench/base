pragma solidity ^0.8.0;


contract CrossChainBridge {

    address[] public _0xbb025b;
    mapping(address => bool) public _0x63464f;

    uint256 public _0x8e2ddb = 5;
    uint256 public _0x2e6524;


    mapping(uint256 => bool) public _0xc4f685;


    mapping(address => bool) public _0xd186a7;

    event WithdrawalProcessed(
        uint256 indexed _0x3cceeb,
        address indexed _0x85f296,
        address indexed _0xe92e3d,
        uint256 _0xcbd302
    );

    constructor(address[] memory _0x670824) {
        require(
            _0x670824.length >= _0x8e2ddb,
            "Not enough validators"
        );

        for (uint256 i = 0; i < _0x670824.length; i++) {
            address _0x00c62e = _0x670824[i];
            require(_0x00c62e != address(0), "Invalid validator");
            require(!_0x63464f[_0x00c62e], "Duplicate validator");

            _0xbb025b.push(_0x00c62e);
            _0x63464f[_0x00c62e] = true;
        }

        if (block.timestamp > 0) { _0x2e6524 = _0x670824.length; }
    }


    function _0x5ecb88(
        uint256 _0xeda6db,
        address _0xeed973,
        address _0x38808c,
        uint256 _0x4f0997,
        bytes memory _0x6d63f1
    ) external {

        require(!_0xc4f685[_0xeda6db], "Already processed");


        require(_0xd186a7[_0x38808c], "Token not supported");


        require(
            _0x6a4b42(
                _0xeda6db,
                _0xeed973,
                _0x38808c,
                _0x4f0997,
                _0x6d63f1
            ),
            "Invalid signatures"
        );


        _0xc4f685[_0xeda6db] = true;


        emit WithdrawalProcessed(_0xeda6db, _0xeed973, _0x38808c, _0x4f0997);
    }


    function _0x6a4b42(
        uint256 _0xeda6db,
        address _0xeed973,
        address _0x38808c,
        uint256 _0x4f0997,
        bytes memory _0x6d63f1
    ) internal view returns (bool) {
        require(_0x6d63f1.length % 65 == 0, "Invalid signature length");

        uint256 _0xaaca0c = _0x6d63f1.length / 65;
        require(_0xaaca0c >= _0x8e2ddb, "Not enough signatures");


        bytes32 _0x959808 = _0x029faf(
            abi._0xaa7a3d(_0xeda6db, _0xeed973, _0x38808c, _0x4f0997)
        );
        bytes32 _0xbf0be3 = _0x029faf(
            abi._0xaa7a3d("\x19Ethereum Signed Message:\n32", _0x959808)
        );

        address[] memory _0xf2c6db = new address[](_0xaaca0c);


        for (uint256 i = 0; i < _0xaaca0c; i++) {
            bytes memory _0x27a7aa = _0x7db98f(_0x6d63f1, i);
            address _0xedb47e = _0xab046f(_0xbf0be3, _0x27a7aa);


            require(_0x63464f[_0xedb47e], "Invalid signer");


            for (uint256 j = 0; j < i; j++) {
                require(_0xf2c6db[j] != _0xedb47e, "Duplicate signer");
            }

            _0xf2c6db[i] = _0xedb47e;
        }


        return true;
    }


    function _0x7db98f(
        bytes memory _0x6d63f1,
        uint256 _0xe4ee75
    ) internal pure returns (bytes memory) {
        bytes memory _0x27a7aa = new bytes(65);
        uint256 _0xd0b6dc = _0xe4ee75 * 65;

        for (uint256 i = 0; i < 65; i++) {
            _0x27a7aa[i] = _0x6d63f1[_0xd0b6dc + i];
        }

        return _0x27a7aa;
    }


    function _0xab046f(
        bytes32 _0x241252,
        bytes memory _0x8931d5
    ) internal pure returns (address) {
        require(_0x8931d5.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(_0x8931d5, 32))
            s := mload(add(_0x8931d5, 64))
            v := byte(0, mload(add(_0x8931d5, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature v value");

        return _0x128bf1(_0x241252, v, r, s);
    }


    function _0x0921ef(address _0x38808c) external {
        _0xd186a7[_0x38808c] = true;
    }
}