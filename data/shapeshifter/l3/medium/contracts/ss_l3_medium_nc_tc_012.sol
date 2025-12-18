pragma solidity ^0.8.0;


interface IComptroller {
    function _0x669d16(
        address[] memory _0x0ebf3f
    ) external returns (uint256[] memory);

    function _0x991155(address _0x8c8f8e) external returns (uint256);

    function _0xb9b911(
        address _0x5b2b4d
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
    IComptroller public _0x131409;

    mapping(address => uint256) public _0x7a5621;
    mapping(address => uint256) public _0x329677;
    mapping(address => bool) public _0x6f2f3a;

    uint256 public _0x622f75;
    uint256 public _0x310ab4;
    uint256 public constant COLLATERAL_FACTOR = 150;

    constructor(address _0xf94c6b) {
        _0x131409 = IComptroller(_0xf94c6b);
    }

    function _0x6dcf56() external payable {
        _0x7a5621[msg.sender] += msg.value;
        _0x622f75 += msg.value;
        _0x6f2f3a[msg.sender] = true;
    }

    function _0x65688d(
        address _0x5b2b4d,
        uint256 _0x6337ed
    ) public view returns (bool) {
        uint256 _0x9a4d00 = _0x329677[_0x5b2b4d] + _0x6337ed;
        if (_0x9a4d00 == 0) return true;

        if (!_0x6f2f3a[_0x5b2b4d]) return false;

        uint256 _0x74a398 = _0x7a5621[_0x5b2b4d];
        return _0x74a398 >= (_0x9a4d00 * COLLATERAL_FACTOR) / 100;
    }

    function _0x6af8ef(uint256 _0xdcee60) external {
        require(_0xdcee60 > 0, "Invalid amount");
        require(address(this).balance >= _0xdcee60, "Insufficient funds");

        require(_0x65688d(msg.sender, _0xdcee60), "Insufficient collateral");

        _0x329677[msg.sender] += _0xdcee60;
        _0x310ab4 += _0xdcee60;

        (bool _0x155063, ) = payable(msg.sender).call{value: _0xdcee60}("");
        require(_0x155063, "Transfer failed");

        require(_0x65688d(msg.sender, 0), "Health check failed");
    }

    function _0x991155() external {
        require(_0x329677[msg.sender] == 0, "Outstanding debt");
        _0x6f2f3a[msg.sender] = false;
    }

    function _0x62e6d1(uint256 _0xdcee60) external {
        require(_0x7a5621[msg.sender] >= _0xdcee60, "Insufficient deposits");
        require(!_0x6f2f3a[msg.sender], "Exit market first");

        _0x7a5621[msg.sender] -= _0xdcee60;
        _0x622f75 -= _0xdcee60;

        payable(msg.sender).transfer(_0xdcee60);
    }

    receive() external payable {}
}