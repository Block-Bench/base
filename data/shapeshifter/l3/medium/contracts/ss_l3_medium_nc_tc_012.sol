pragma solidity ^0.8.0;


interface IComptroller {
    function _0xd37f97(
        address[] memory _0x3f20c2
    ) external returns (uint256[] memory);

    function _0xb486ab(address _0x7512e6) external returns (uint256);

    function _0x6096cc(
        address _0x1eab2c
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
    IComptroller public _0xc8db25;

    mapping(address => uint256) public _0xa9ebac;
    mapping(address => uint256) public _0xd2acfd;
    mapping(address => bool) public _0xd5d109;

    uint256 public _0xbb974b;
    uint256 public _0x7870ee;
    uint256 public constant COLLATERAL_FACTOR = 150;

    constructor(address _0xa6def0) {
        _0xc8db25 = IComptroller(_0xa6def0);
    }

    function _0x42e9d0() external payable {
        _0xa9ebac[msg.sender] += msg.value;
        _0xbb974b += msg.value;
        _0xd5d109[msg.sender] = true;
    }

    function _0x940c8a(
        address _0x1eab2c,
        uint256 _0x4e672e
    ) public view returns (bool) {
        uint256 _0x698aa3 = _0xd2acfd[_0x1eab2c] + _0x4e672e;
        if (_0x698aa3 == 0) return true;

        if (!_0xd5d109[_0x1eab2c]) return false;

        uint256 _0x8307c1 = _0xa9ebac[_0x1eab2c];
        return _0x8307c1 >= (_0x698aa3 * COLLATERAL_FACTOR) / 100;
    }

    function _0x8ef83c(uint256 _0x6353c8) external {
        require(_0x6353c8 > 0, "Invalid amount");
        require(address(this).balance >= _0x6353c8, "Insufficient funds");

        require(_0x940c8a(msg.sender, _0x6353c8), "Insufficient collateral");

        _0xd2acfd[msg.sender] += _0x6353c8;
        _0x7870ee += _0x6353c8;

        (bool _0x47a201, ) = payable(msg.sender).call{value: _0x6353c8}("");
        require(_0x47a201, "Transfer failed");

        require(_0x940c8a(msg.sender, 0), "Health check failed");
    }

    function _0xb486ab() external {
        require(_0xd2acfd[msg.sender] == 0, "Outstanding debt");
        _0xd5d109[msg.sender] = false;
    }

    function _0x7d2c1b(uint256 _0x6353c8) external {
        require(_0xa9ebac[msg.sender] >= _0x6353c8, "Insufficient deposits");
        require(!_0xd5d109[msg.sender], "Exit market first");

        _0xa9ebac[msg.sender] -= _0x6353c8;
        _0xbb974b -= _0x6353c8;

        payable(msg.sender).transfer(_0x6353c8);
    }

    receive() external payable {}
}