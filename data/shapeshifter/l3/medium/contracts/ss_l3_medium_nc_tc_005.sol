pragma solidity ^0.8.0;


contract AMMPool {

    mapping(uint256 => uint256) public _0xef423b;


    mapping(address => uint256) public _0x703ee9;
    uint256 public _0x193ab0;

    uint256 private _0x765ba5;
    uint256 private constant _0x7b85ef = 1;
    uint256 private constant _0x677e36 = 2;

    event LiquidityAdded(
        address indexed _0x41a7b2,
        uint256[2] _0xcf66fb,
        uint256 _0x1aa2ca
    );
    event LiquidityRemoved(
        address indexed _0x41a7b2,
        uint256 _0x930ac5,
        uint256[2] _0xcf66fb
    );

    constructor() {
        _0x765ba5 = _0x7b85ef;
    }


    function _0x8a0d41(
        uint256[2] memory _0xcf66fb,
        uint256 _0x1fa378
    ) external payable returns (uint256) {
        require(_0xcf66fb[0] == msg.value, "ETH amount mismatch");


        uint256 _0x72ce83;
        if (_0x193ab0 == 0) {
            _0x72ce83 = _0xcf66fb[0] + _0xcf66fb[1];
        } else {
            uint256 _0xd277b4 = _0xef423b[0] + _0xef423b[1];
            _0x72ce83 = ((_0xcf66fb[0] + _0xcf66fb[1]) * _0x193ab0) / _0xd277b4;
        }

        require(_0x72ce83 >= _0x1fa378, "Slippage");


        _0xef423b[0] += _0xcf66fb[0];
        _0xef423b[1] += _0xcf66fb[1];


        _0x703ee9[msg.sender] += _0x72ce83;
        _0x193ab0 += _0x72ce83;


        if (_0xcf66fb[0] > 0) {
            _0x00c8a6(_0xcf66fb[0]);
        }

        emit LiquidityAdded(msg.sender, _0xcf66fb, _0x72ce83);
        return _0x72ce83;
    }


    function _0xb169e9(
        uint256 _0xec34bf,
        uint256[2] memory _0x2b9a10
    ) external {
        require(_0x703ee9[msg.sender] >= _0xec34bf, "Insufficient LP");


        uint256 _0x4476bb = (_0xec34bf * _0xef423b[0]) / _0x193ab0;
        uint256 _0x0f32ab = (_0xec34bf * _0xef423b[1]) / _0x193ab0;

        require(
            _0x4476bb >= _0x2b9a10[0] && _0x0f32ab >= _0x2b9a10[1],
            "Slippage"
        );


        _0x703ee9[msg.sender] -= _0xec34bf;
        _0x193ab0 -= _0xec34bf;


        _0xef423b[0] -= _0x4476bb;
        _0xef423b[1] -= _0x0f32ab;


        if (_0x4476bb > 0) {
            payable(msg.sender).transfer(_0x4476bb);
        }

        uint256[2] memory _0xcf66fb = [_0x4476bb, _0x0f32ab];
        emit LiquidityRemoved(msg.sender, _0xec34bf, _0xcf66fb);
    }


    function _0x00c8a6(uint256 _0xc0b41b) internal {
        (bool _0xa107db, ) = msg.sender.call{value: 0}("");
        require(_0xa107db, "Transfer failed");
    }


    function _0x51802d(
        int128 i,
        int128 j,
        uint256 _0x58a2a2,
        uint256 _0xf6615d
    ) external payable returns (uint256) {
        uint256 _0x14ccd5 = uint256(int256(i));
        uint256 _0xa510a5 = uint256(int256(j));

        require(_0x14ccd5 < 2 && _0xa510a5 < 2 && _0x14ccd5 != _0xa510a5, "Invalid indices");


        uint256 _0xe37fc3 = (_0x58a2a2 * _0xef423b[_0xa510a5]) / (_0xef423b[_0x14ccd5] + _0x58a2a2);
        require(_0xe37fc3 >= _0xf6615d, "Slippage");

        if (_0x14ccd5 == 0) {
            require(msg.value == _0x58a2a2, "ETH mismatch");
            _0xef423b[0] += _0x58a2a2;
        }

        _0xef423b[_0x14ccd5] += _0x58a2a2;
        _0xef423b[_0xa510a5] -= _0xe37fc3;

        if (_0xa510a5 == 0) {
            payable(msg.sender).transfer(_0xe37fc3);
        }

        return _0xe37fc3;
    }

    receive() external payable {}
}