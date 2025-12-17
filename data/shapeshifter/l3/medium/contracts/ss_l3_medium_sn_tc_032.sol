// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xa07b85, uint256 _0xd7799e) external returns (bool);

    function _0x96f41f(
        address from,
        address _0xa07b85,
        uint256 _0xd7799e
    ) external returns (bool);

    function _0x2d0687(address _0xb284f6) external view returns (uint256);

    function _0x943765(address _0xdb9494, uint256 _0xd7799e) external returns (bool);
}

interface IFlashLoanReceiver {
    function _0x1ffa4d(
        address[] calldata _0x3a05b9,
        uint256[] calldata _0x68212b,
        uint256[] calldata _0x3993e8,
        address _0x49d402,
        bytes calldata _0xf33544
    ) external returns (bool);
}

contract RadiantLendingPool {
    uint256 public constant RAY = 1e27;

    struct ReserveData {
        uint256 _0xbad296;
        uint256 _0x3308a3;
        address _0x467130;
    }

    mapping(address => ReserveData) public _0x928023;

    function _0x305314(
        address _0x23138d,
        uint256 _0xd7799e,
        address _0x4bc1db,
        uint16 _0xb60b18
    ) external {
        IERC20(_0x23138d)._0x96f41f(msg.sender, address(this), _0xd7799e);

        ReserveData storage _0x27b94f = _0x928023[_0x23138d];

        uint256 _0x31c58c = _0x27b94f._0xbad296;
        if (_0x31c58c == 0) {
            _0x31c58c = RAY;
        }

        _0x27b94f._0xbad296 =
            _0x31c58c +
            (_0xd7799e * RAY) /
            (_0x27b94f._0x3308a3 + 1);
        _0x27b94f._0x3308a3 += _0xd7799e;

        uint256 _0x655bc4 = _0x51024c(_0xd7799e, _0x27b94f._0xbad296);
        _0xda1634(_0x27b94f._0x467130, _0x4bc1db, _0x655bc4);
    }

    function _0x3c07dc(
        address _0x23138d,
        uint256 _0xd7799e,
        address _0xa07b85
    ) external returns (uint256) {
        ReserveData storage _0x27b94f = _0x928023[_0x23138d];

        uint256 _0xf748ee = _0x51024c(_0xd7799e, _0x27b94f._0xbad296);

        _0xc279c9(_0x27b94f._0x467130, msg.sender, _0xf748ee);

        _0x27b94f._0x3308a3 -= _0xd7799e;
        IERC20(_0x23138d).transfer(_0xa07b85, _0xd7799e);

        return _0xd7799e;
    }

    function _0x33d7d9(
        address _0x23138d,
        uint256 _0xd7799e,
        uint256 _0x4b1737,
        uint16 _0xb60b18,
        address _0x4bc1db
    ) external {
        IERC20(_0x23138d).transfer(_0x4bc1db, _0xd7799e);
    }

    function _0xe1f6d8(
        address _0xdd2690,
        address[] calldata _0x3a05b9,
        uint256[] calldata _0x68212b,
        uint256[] calldata _0xa699be,
        address _0x4bc1db,
        bytes calldata _0xf33544,
        uint16 _0xb60b18
    ) external {
        for (uint256 i = 0; i < _0x3a05b9.length; i++) {
            IERC20(_0x3a05b9[i]).transfer(_0xdd2690, _0x68212b[i]);
        }

        require(
            IFlashLoanReceiver(_0xdd2690)._0x1ffa4d(
                _0x3a05b9,
                _0x68212b,
                new uint256[](_0x3a05b9.length),
                msg.sender,
                _0xf33544
            ),
            "Flashloan callback failed"
        );

        for (uint256 i = 0; i < _0x3a05b9.length; i++) {
            IERC20(_0x3a05b9[i])._0x96f41f(
                _0xdd2690,
                address(this),
                _0x68212b[i]
            );
        }
    }

    function _0x51024c(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 _0xfeaf2c = b / 2;
        require(b != 0, "Division by zero");
        return (a * RAY + _0xfeaf2c) / b;
    }

    function _0xda1634(address _0xc159df, address _0xa07b85, uint256 _0xd7799e) internal {}

    function _0xc279c9(
        address _0xc159df,
        address from,
        uint256 _0xd7799e
    ) internal {}
}
