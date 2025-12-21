pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x70bae9, uint256 _0xa66615) external returns (bool);

    function _0xd4b53a(
        address from,
        address _0x70bae9,
        uint256 _0xa66615
    ) external returns (bool);

    function _0x8d5ebe(address _0x6ab383) external view returns (uint256);

    function _0xfe00c2(address _0x6ab8cc, uint256 _0xa66615) external returns (bool);
}

interface IFlashLoanReceiver {
    function _0xd81711(
        address[] calldata _0x296bd8,
        uint256[] calldata _0x02c753,
        uint256[] calldata _0xd88873,
        address _0xf6ab68,
        bytes calldata _0x4a7191
    ) external returns (bool);
}

contract RadiantLendingPool {
    uint256 public constant RAY = 1e27;

    struct ReserveData {
        uint256 _0x0a8031;
        uint256 _0x946dc7;
        address _0x8a8d38;
    }

    mapping(address => ReserveData) public _0xf7aeed;

    function _0x701b75(
        address _0xd7b592,
        uint256 _0xa66615,
        address _0x75965c,
        uint16 _0x6765d5
    ) external {
        IERC20(_0xd7b592)._0xd4b53a(msg.sender, address(this), _0xa66615);

        ReserveData storage _0x5eb051 = _0xf7aeed[_0xd7b592];

        uint256 _0x66e253 = _0x5eb051._0x0a8031;
        if (_0x66e253 == 0) {
            _0x66e253 = RAY;
        }

        _0x5eb051._0x0a8031 =
            _0x66e253 +
            (_0xa66615 * RAY) /
            (_0x5eb051._0x946dc7 + 1);
        _0x5eb051._0x946dc7 += _0xa66615;

        uint256 _0x5dd938 = _0x878f45(_0xa66615, _0x5eb051._0x0a8031);
        _0xf9c055(_0x5eb051._0x8a8d38, _0x75965c, _0x5dd938);
    }

    function _0xc7e110(
        address _0xd7b592,
        uint256 _0xa66615,
        address _0x70bae9
    ) external returns (uint256) {
        ReserveData storage _0x5eb051 = _0xf7aeed[_0xd7b592];

        uint256 _0x5280db = _0x878f45(_0xa66615, _0x5eb051._0x0a8031);

        _0x22aaef(_0x5eb051._0x8a8d38, msg.sender, _0x5280db);

        _0x5eb051._0x946dc7 -= _0xa66615;
        IERC20(_0xd7b592).transfer(_0x70bae9, _0xa66615);

        return _0xa66615;
    }

    function _0xd46ed8(
        address _0xd7b592,
        uint256 _0xa66615,
        uint256 _0x21ae80,
        uint16 _0x6765d5,
        address _0x75965c
    ) external {
        IERC20(_0xd7b592).transfer(_0x75965c, _0xa66615);
    }

    function _0xd261e6(
        address _0xa57aa9,
        address[] calldata _0x296bd8,
        uint256[] calldata _0x02c753,
        uint256[] calldata _0x8314ae,
        address _0x75965c,
        bytes calldata _0x4a7191,
        uint16 _0x6765d5
    ) external {
        for (uint256 i = 0; i < _0x296bd8.length; i++) {
            IERC20(_0x296bd8[i]).transfer(_0xa57aa9, _0x02c753[i]);
        }

        require(
            IFlashLoanReceiver(_0xa57aa9)._0xd81711(
                _0x296bd8,
                _0x02c753,
                new uint256[](_0x296bd8.length),
                msg.sender,
                _0x4a7191
            ),
            "Flashloan callback failed"
        );

        for (uint256 i = 0; i < _0x296bd8.length; i++) {
            IERC20(_0x296bd8[i])._0xd4b53a(
                _0xa57aa9,
                address(this),
                _0x02c753[i]
            );
        }
    }

    function _0x878f45(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 _0xfcd3ca = b / 2;
        require(b != 0, "Division by zero");
        return (a * RAY + _0xfcd3ca) / b;
    }

    function _0xf9c055(address _0xfbba32, address _0x70bae9, uint256 _0xa66615) internal {}

    function _0x22aaef(
        address _0xfbba32,
        address from,
        uint256 _0xa66615
    ) internal {}
}