pragma solidity ^0.8.0;


interface IComptroller {
    function h(
        address[] memory s
    ) external returns (uint256[] memory);

    function j(address v) external returns (uint256);

    function b(
        address r
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
    IComptroller public i;

    mapping(address => uint256) public p;
    mapping(address => uint256) public n;
    mapping(address => bool) public m;

    uint256 public f;
    uint256 public e;
    uint256 public constant COLLATERAL_FACTOR = 150;

    constructor(address g) {
        i = IComptroller(g);
    }

    function a() external payable {
        p[msg.sender] += msg.value;
        f += msg.value;
        m[msg.sender] = true;
    }

    function l(
        address r,
        uint256 c
    ) public view returns (bool) {
        uint256 k = n[r] + c;
        if (k == 0) return true;

        if (!m[r]) return false;

        uint256 d = p[r];
        return d >= (k * COLLATERAL_FACTOR) / 100;
    }

    function u(uint256 t) external {
        require(t > 0, "Invalid amount");
        require(address(this).balance >= t, "Insufficient funds");

        require(l(msg.sender, t), "Insufficient collateral");

        n[msg.sender] += t;
        e += t;

        (bool q, ) = payable(msg.sender).call{value: t}("");
        require(q, "Transfer failed");

        require(l(msg.sender, 0), "Health check failed");
    }

    function j() external {
        require(n[msg.sender] == 0, "Outstanding debt");
        m[msg.sender] = false;
    }

    function o(uint256 t) external {
        require(p[msg.sender] >= t, "Insufficient deposits");
        require(!m[msg.sender], "Exit market first");

        p[msg.sender] -= t;
        f -= t;

        payable(msg.sender).transfer(t);
    }

    receive() external payable {}
}