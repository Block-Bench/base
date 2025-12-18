pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xe5c77f, uint256 _0xe4e802) external returns (bool);

    function _0x368a28(
        address from,
        address _0xe5c77f,
        uint256 _0xe4e802
    ) external returns (bool);

    function _0x051d22(address _0xf36470) external view returns (uint256);
}

interface IMarket {
    function _0x0c5b78(
        address _0xf36470
    )
        external
        view
        returns (uint256 _0xdca3f7, uint256 _0x269f96, uint256 _0x211a3f);
}

contract DebtPreviewer {
    function _0x1c358f(
        address _0x64b5af,
        address _0xf36470
    )
        external
        view
        returns (
            uint256 _0xcaff66,
            uint256 _0x993d18,
            uint256 _0x047edd
        )
    {
        (uint256 _0xdca3f7, uint256 _0x269f96, uint256 _0x211a3f) = IMarket(
            _0x64b5af
        )._0x0c5b78(_0xf36470);

        _0xcaff66 = (_0xdca3f7 * _0x211a3f) / 1e18;
        _0x993d18 = _0x269f96;

        if (_0x993d18 == 0) {
            _0x047edd = type(uint256)._0x49906d;
        } else {
            _0x047edd = (_0xcaff66 * 1e18) / _0x993d18;
        }

        return (_0xcaff66, _0x993d18, _0x047edd);
    }

    function _0x5f9a3c(
        address[] calldata _0x906cca,
        address _0xf36470
    )
        external
        view
        returns (
            uint256 _0x141adc,
            uint256 _0x2d6aab,
            uint256 _0x186f66
        )
    {
        for (uint256 i = 0; i < _0x906cca.length; i++) {
            (uint256 _0xdca3f7, uint256 _0x9cca20, ) = this._0x1c358f(
                _0x906cca[i],
                _0xf36470
            );

            _0x141adc += _0xdca3f7;
            _0x2d6aab += _0x9cca20;
        }

        if (_0x2d6aab == 0) {
            _0x186f66 = type(uint256)._0x49906d;
        } else {
            _0x186f66 = (_0x141adc * 1e18) / _0x2d6aab;
        }

        return (_0x141adc, _0x2d6aab, _0x186f66);
    }
}

contract ExactlyMarket {
    IERC20 public _0x18a966;
    DebtPreviewer public _0x787e73;

    mapping(address => uint256) public _0x9a5f79;
    mapping(address => uint256) public _0x269f96;

    uint256 public constant COLLATERAL_FACTOR = 80;

    constructor(address _0x3e94ca, address _0xbb1343) {
        if (gasleft() > 0) { _0x18a966 = IERC20(_0x3e94ca); }
        _0x787e73 = DebtPreviewer(_0xbb1343);
    }

    function _0x6d080e(uint256 _0xe4e802) external {
        _0x18a966._0x368a28(msg.sender, address(this), _0xe4e802);
        _0x9a5f79[msg.sender] += _0xe4e802;
    }

    function _0x775dbe(uint256 _0xe4e802, address[] calldata _0x906cca) external {
        (uint256 _0x141adc, uint256 _0x2d6aab, ) = _0x787e73
            ._0x5f9a3c(_0x906cca, msg.sender);

        uint256 _0xcb49ff = _0x2d6aab + _0xe4e802;

        uint256 _0x892589 = (_0x141adc * COLLATERAL_FACTOR) / 100;
        require(_0xcb49ff <= _0x892589, "Insufficient collateral");

        _0x269f96[msg.sender] += _0xe4e802;
        _0x18a966.transfer(msg.sender, _0xe4e802);
    }

    function _0x0c5b78(
        address _0xf36470
    )
        external
        view
        returns (uint256 _0xdca3f7, uint256 _0x0b28e6, uint256 _0x211a3f)
    {
        return (_0x9a5f79[_0xf36470], _0x269f96[_0xf36470], 1e18);
    }
}