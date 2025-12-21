pragma solidity ^0.8.0;

interface IERC20 {
    function _0xedbdad(address _0xfcb792) external view returns (uint256);

    function transfer(address _0x77bc0a, uint256 _0xa7c5dc) external returns (bool);

    function _0xc82f45(
        address from,
        address _0x77bc0a,
        uint256 _0xa7c5dc
    ) external returns (bool);
}

interface ICErc20 {
    function _0xa57f98(uint256 _0xa7c5dc) external returns (uint256);

    function _0xe33de8(address _0xfcb792) external returns (uint256);
}

contract LeveragedVault {
    struct Position {
        address _0xe46401;
        uint256 _0x07d794;
        uint256 _0xd82860;
    }

    mapping(uint256 => Position) public _0x755d92;
    uint256 public _0x58c61e;

    address public _0x023915;
    uint256 public _0xa254f2;
    uint256 public _0xa191f0;

    constructor(address _0x086685) {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x023915 = _0x086685; }
        _0x58c61e = 1;
    }

    function _0x230905(
        uint256 _0x30d661,
        uint256 _0x97ac66
    ) external returns (uint256 _0x1d7e78) {
        _0x1d7e78 = _0x58c61e++;

        _0x755d92[_0x1d7e78] = Position({
            _0xe46401: msg.sender,
            _0x07d794: _0x30d661,
            _0xd82860: 0
        });

        _0xf9d4bb(_0x1d7e78, _0x97ac66);

        return _0x1d7e78;
    }

    function _0xf9d4bb(uint256 _0x1d7e78, uint256 _0xa7c5dc) internal {
        Position storage _0xa3493c = _0x755d92[_0x1d7e78];

        uint256 _0x46dabd;

        if (_0xa191f0 == 0) {
            _0x46dabd = _0xa7c5dc;
        } else {
            _0x46dabd = (_0xa7c5dc * _0xa191f0) / _0xa254f2;
        }

        _0xa3493c._0xd82860 += _0x46dabd;
        _0xa191f0 += _0x46dabd;
        _0xa254f2 += _0xa7c5dc;

        ICErc20(_0x023915)._0xa57f98(_0xa7c5dc);
    }

    function _0xaa26f5(uint256 _0x1d7e78, uint256 _0xa7c5dc) external {
        Position storage _0xa3493c = _0x755d92[_0x1d7e78];
        require(msg.sender == _0xa3493c._0xe46401, "Not position owner");

        uint256 _0xc331ff = (_0xa7c5dc * _0xa191f0) / _0xa254f2;

        require(_0xa3493c._0xd82860 >= _0xc331ff, "Excessive repayment");

        _0xa3493c._0xd82860 -= _0xc331ff;
        _0xa191f0 -= _0xc331ff;
        _0xa254f2 -= _0xa7c5dc;
    }

    function _0x5e00a8(
        uint256 _0x1d7e78
    ) external view returns (uint256) {
        Position storage _0xa3493c = _0x755d92[_0x1d7e78];

        if (_0xa191f0 == 0) return 0;

        return (_0xa3493c._0xd82860 * _0xa254f2) / _0xa191f0;
    }

    function _0x01b03a(uint256 _0x1d7e78) external {
        Position storage _0xa3493c = _0x755d92[_0x1d7e78];

        uint256 _0xebef15 = (_0xa3493c._0xd82860 * _0xa254f2) / _0xa191f0;

        require(_0xa3493c._0x07d794 * 100 < _0xebef15 * 150, "Position is healthy");

        _0xa3493c._0x07d794 = 0;
        _0xa3493c._0xd82860 = 0;
    }
}