pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x87dc98, uint256 _0xc3d8a6) external returns (bool);

    function _0x2c4abb(
        address from,
        address _0x87dc98,
        uint256 _0xc3d8a6
    ) external returns (bool);

    function _0xbda8e3(address _0x301c03) external view returns (uint256);
}

interface IMarket {
    function _0x1f944d(
        address _0x301c03
    )
        external
        view
        returns (uint256 _0xc08c59, uint256 _0x4d985e, uint256 _0x4d6216);
}

contract DebtPreviewer {
    function _0xd59d6b(
        address _0x9ab45a,
        address _0x301c03
    )
        external
        view
        returns (
            uint256 _0x769e4b,
            uint256 _0x841c3b,
            uint256 _0x904089
        )
    {
        (uint256 _0xc08c59, uint256 _0x4d985e, uint256 _0x4d6216) = IMarket(
            _0x9ab45a
        )._0x1f944d(_0x301c03);

        _0x769e4b = (_0xc08c59 * _0x4d6216) / 1e18;
        _0x841c3b = _0x4d985e;

        if (_0x841c3b == 0) {
            _0x904089 = type(uint256)._0x66e9b1;
        } else {
            _0x904089 = (_0x769e4b * 1e18) / _0x841c3b;
        }

        return (_0x769e4b, _0x841c3b, _0x904089);
    }

    function _0xb1b693(
        address[] calldata _0xd03467,
        address _0x301c03
    )
        external
        view
        returns (
            uint256 _0x9cd3e2,
            uint256 _0x61f57b,
            uint256 _0x184ff6
        )
    {
        for (uint256 i = 0; i < _0xd03467.length; i++) {
            (uint256 _0xc08c59, uint256 _0x8ca4cc, ) = this._0xd59d6b(
                _0xd03467[i],
                _0x301c03
            );

            _0x9cd3e2 += _0xc08c59;
            _0x61f57b += _0x8ca4cc;
        }

        if (_0x61f57b == 0) {
            _0x184ff6 = type(uint256)._0x66e9b1;
        } else {
            _0x184ff6 = (_0x9cd3e2 * 1e18) / _0x61f57b;
        }

        return (_0x9cd3e2, _0x61f57b, _0x184ff6);
    }
}

contract ExactlyMarket {
    IERC20 public _0x204605;
    DebtPreviewer public _0x6b3d26;

    mapping(address => uint256) public _0x73e4a9;
    mapping(address => uint256) public _0x4d985e;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(address _0x70725e, address _0x3c0e22) {
        _0x204605 = IERC20(_0x70725e);
        _0x6b3d26 = DebtPreviewer(_0x3c0e22);
    }

    function _0x5c61b3(uint256 _0xc3d8a6) external {
        _0x204605._0x2c4abb(msg.sender, address(this), _0xc3d8a6);
        _0x73e4a9[msg.sender] += _0xc3d8a6;
    }

    function _0x6d43ce(uint256 _0xc3d8a6, address[] calldata _0xd03467) external {
        (uint256 _0x9cd3e2, uint256 _0x61f57b, ) = _0x6b3d26
            ._0xb1b693(_0xd03467, msg.sender);

        uint256 _0x6b9a89 = _0x61f57b + _0xc3d8a6;

        uint256 _0xa72e9c = (_0x9cd3e2 * COLLATERAL_FACTOR) / 100;
        require(_0x6b9a89 <= _0xa72e9c, "Insufficient collateral");

        _0x4d985e[msg.sender] += _0xc3d8a6;
        _0x204605.transfer(msg.sender, _0xc3d8a6);
    }

    function _0x1f944d(
        address _0x301c03
    )
        external
        view
        returns (uint256 _0xc08c59, uint256 _0x293ef6, uint256 _0x4d6216)
    {
        return (_0x73e4a9[_0x301c03], _0x4d985e[_0x301c03], 1e18);
    }
}