pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x7a9949, uint256 _0xf37177) external returns (bool);

    function _0x67bbc8(
        address from,
        address _0x7a9949,
        uint256 _0xf37177
    ) external returns (bool);

    function _0xba22cd(address _0x062264) external view returns (uint256);

    function _0xedbc2b(address _0x7196f0, uint256 _0xf37177) external returns (bool);
}

interface IFlashLoanReceiver {
    function _0xaaa37d(
        address[] calldata _0xfe1900,
        uint256[] calldata _0xe25bdd,
        uint256[] calldata _0x552897,
        address _0x8e241a,
        bytes calldata _0x83566a
    ) external returns (bool);
}

contract RadiantLendingPool {
    uint256 public constant RAY = 1e27;

    struct ReserveData {
        uint256 _0x39de3f;
        uint256 _0xbf6efe;
        address _0x246089;
    }

    mapping(address => ReserveData) public _0xf7c0d5;

    function _0x9b07ba(
        address _0x9c5afd,
        uint256 _0xf37177,
        address _0x489b97,
        uint16 _0x45d2a4
    ) external {
        IERC20(_0x9c5afd)._0x67bbc8(msg.sender, address(this), _0xf37177);

        ReserveData storage _0x46f2b8 = _0xf7c0d5[_0x9c5afd];

        uint256 _0x70f91f = _0x46f2b8._0x39de3f;
        if (_0x70f91f == 0) {
            _0x70f91f = RAY;
        }

        _0x46f2b8._0x39de3f =
            _0x70f91f +
            (_0xf37177 * RAY) /
            (_0x46f2b8._0xbf6efe + 1);
        _0x46f2b8._0xbf6efe += _0xf37177;

        uint256 _0x566dec = _0x9b5e85(_0xf37177, _0x46f2b8._0x39de3f);
        _0x1de508(_0x46f2b8._0x246089, _0x489b97, _0x566dec);
    }

    function _0x87484e(
        address _0x9c5afd,
        uint256 _0xf37177,
        address _0x7a9949
    ) external returns (uint256) {
        ReserveData storage _0x46f2b8 = _0xf7c0d5[_0x9c5afd];

        uint256 _0xd0d662 = _0x9b5e85(_0xf37177, _0x46f2b8._0x39de3f);

        _0x2ac212(_0x46f2b8._0x246089, msg.sender, _0xd0d662);

        _0x46f2b8._0xbf6efe -= _0xf37177;
        IERC20(_0x9c5afd).transfer(_0x7a9949, _0xf37177);

        return _0xf37177;
    }

    function _0x121b81(
        address _0x9c5afd,
        uint256 _0xf37177,
        uint256 _0xabaf0a,
        uint16 _0x45d2a4,
        address _0x489b97
    ) external {
        IERC20(_0x9c5afd).transfer(_0x489b97, _0xf37177);
    }

    function _0x073782(
        address _0x66d1e4,
        address[] calldata _0xfe1900,
        uint256[] calldata _0xe25bdd,
        uint256[] calldata _0x90801f,
        address _0x489b97,
        bytes calldata _0x83566a,
        uint16 _0x45d2a4
    ) external {
        for (uint256 i = 0; i < _0xfe1900.length; i++) {
            IERC20(_0xfe1900[i]).transfer(_0x66d1e4, _0xe25bdd[i]);
        }

        require(
            IFlashLoanReceiver(_0x66d1e4)._0xaaa37d(
                _0xfe1900,
                _0xe25bdd,
                new uint256[](_0xfe1900.length),
                msg.sender,
                _0x83566a
            ),
            "Flashloan callback failed"
        );

        for (uint256 i = 0; i < _0xfe1900.length; i++) {
            IERC20(_0xfe1900[i])._0x67bbc8(
                _0x66d1e4,
                address(this),
                _0xe25bdd[i]
            );
        }
    }

    function _0x9b5e85(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 _0x850e5a = b / 2;
        require(b != 0, "Division by zero");
        return (a * RAY + _0x850e5a) / b;
    }

    function _0x1de508(address _0x16bf9b, address _0x7a9949, uint256 _0xf37177) internal {}

    function _0x2ac212(
        address _0x16bf9b,
        address from,
        uint256 _0xf37177
    ) internal {}
}