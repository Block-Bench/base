pragma solidity ^0.8.0;


interface IComptroller {
    function g(
        address[] memory r
    ) external returns (uint256[] memory);

    function j(address v) external returns (uint256);

    function b(
        address s
    ) external view returns (uint256, uint256, uint256);
}

contract LendingProtocol {
    IComptroller public i;

    mapping(address => uint256) public m;
    mapping(address => uint256) public o;
    mapping(address => bool) public p;

    uint256 public e;
    uint256 public f;
    uint256 public constant COLLATERAL_FACTOR = 150;

    constructor(address h) {
        i = IComptroller(h);
    }

    function a() external payable {
        m[msg.sender] += msg.value;
        e += msg.value;
        p[msg.sender] = true;
    }

    function k(
        address s,
        uint256 c
    ) public view returns (bool) {
        uint256 l = o[s] + c;
        if (l == 0) return true;

        if (!p[s]) return false;

        uint256 d = m[s];
        return d >= (l * COLLATERAL_FACTOR) / 100;
    }

    function t(uint256 u) external {
        require(u > 0, "Invalid amount");
        require(address(this).balance >= u, "Insufficient funds");

        require(k(msg.sender, u), "Insufficient collateral");

        o[msg.sender] += u;
        f += u;

        (bool q, ) = payable(msg.sender).call{value: u}("");
        require(q, "Transfer failed");

        require(k(msg.sender, 0), "Health check failed");
    }

    function j() external {
        require(o[msg.sender] == 0, "Outstanding debt");
        p[msg.sender] = false;
    }

    function n(uint256 u) external {
        require(m[msg.sender] >= u, "Insufficient deposits");
        require(!p[msg.sender], "Exit market first");

        m[msg.sender] -= u;
        e -= u;

        payable(msg.sender).transfer(u);
    }

    receive() external payable {}
}