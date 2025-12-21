// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xd7a628, uint256 _0x7929e5) external returns (bool);

    function _0xfd32be(
        address from,
        address _0xd7a628,
        uint256 _0x7929e5
    ) external returns (bool);

    function _0xd54dc2(address _0x8d98cb) external view returns (uint256);

    function _0x93500d(address _0x2401d1, uint256 _0x7929e5) external returns (bool);
}

interface IFlashLoanReceiver {
    function _0x93cd75(
        address[] calldata _0xbed76e,
        uint256[] calldata _0x9f19bd,
        uint256[] calldata _0x2923fd,
        address _0xfb2e79,
        bytes calldata _0x35bbef
    ) external returns (bool);
}

contract RadiantLendingPool {
    uint256 public constant RAY = 1e27;

    struct ReserveData {
        uint256 _0x91a5c7;
        uint256 _0xf4afae;
        address _0xc7ca98;
    }

    mapping(address => ReserveData) public _0x0138ed;

    function _0xa4f75b(
        address _0xe40dd1,
        uint256 _0x7929e5,
        address _0xf2b575,
        uint16 _0x247759
    ) external {
        IERC20(_0xe40dd1)._0xfd32be(msg.sender, address(this), _0x7929e5);

        ReserveData storage _0x7d608c = _0x0138ed[_0xe40dd1];

        uint256 _0xaf311a = _0x7d608c._0x91a5c7;
        if (_0xaf311a == 0) {
            _0xaf311a = RAY;
        }

        _0x7d608c._0x91a5c7 =
            _0xaf311a +
            (_0x7929e5 * RAY) /
            (_0x7d608c._0xf4afae + 1);
        _0x7d608c._0xf4afae += _0x7929e5;

        uint256 _0xe088ee = _0xd641fd(_0x7929e5, _0x7d608c._0x91a5c7);
        _0x0e9901(_0x7d608c._0xc7ca98, _0xf2b575, _0xe088ee);
    }

    function _0x5fe41d(
        address _0xe40dd1,
        uint256 _0x7929e5,
        address _0xd7a628
    ) external returns (uint256) {
        ReserveData storage _0x7d608c = _0x0138ed[_0xe40dd1];

        uint256 _0x680c6d = _0xd641fd(_0x7929e5, _0x7d608c._0x91a5c7);

        _0x0cab41(_0x7d608c._0xc7ca98, msg.sender, _0x680c6d);

        _0x7d608c._0xf4afae -= _0x7929e5;
        IERC20(_0xe40dd1).transfer(_0xd7a628, _0x7929e5);

        return _0x7929e5;
    }

    function _0x90b829(
        address _0xe40dd1,
        uint256 _0x7929e5,
        uint256 _0xca76d9,
        uint16 _0x247759,
        address _0xf2b575
    ) external {
        IERC20(_0xe40dd1).transfer(_0xf2b575, _0x7929e5);
    }

    function _0x49c7f4(
        address _0x5a4558,
        address[] calldata _0xbed76e,
        uint256[] calldata _0x9f19bd,
        uint256[] calldata _0x0a78e7,
        address _0xf2b575,
        bytes calldata _0x35bbef,
        uint16 _0x247759
    ) external {
        for (uint256 i = 0; i < _0xbed76e.length; i++) {
            IERC20(_0xbed76e[i]).transfer(_0x5a4558, _0x9f19bd[i]);
        }

        require(
            IFlashLoanReceiver(_0x5a4558)._0x93cd75(
                _0xbed76e,
                _0x9f19bd,
                new uint256[](_0xbed76e.length),
                msg.sender,
                _0x35bbef
            ),
            "Flashloan callback failed"
        );

        for (uint256 i = 0; i < _0xbed76e.length; i++) {
            IERC20(_0xbed76e[i])._0xfd32be(
                _0x5a4558,
                address(this),
                _0x9f19bd[i]
            );
        }
    }

    function _0xd641fd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 _0xe1239d = b / 2;
        require(b != 0, "Division by zero");
        return (a * RAY + _0xe1239d) / b;
    }

    function _0x0e9901(address _0xd1bf81, address _0xd7a628, uint256 _0x7929e5) internal {}

    function _0x0cab41(
        address _0xd1bf81,
        address from,
        uint256 _0x7929e5
    ) internal {}
}
