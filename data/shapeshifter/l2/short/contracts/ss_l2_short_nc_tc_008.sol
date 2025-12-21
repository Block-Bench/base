pragma solidity ^0.8.0;


interface IOracle {
    function c(address y) external view returns (uint256);
}

interface ICToken {
    function ad(uint256 q) external;

    function v(uint256 h) external;

    function x(uint256 i) external;

    function o() external view returns (address);
}

contract LendingProtocol {

    IOracle public z;


    mapping(address => uint256) public d;


    mapping(address => mapping(address => uint256)) public j;


    mapping(address => mapping(address => uint256)) public n;


    mapping(address => bool) public e;

    event Deposit(address indexed ac, address indexed y, uint256 w);
    event Borrow(address indexed ac, address indexed y, uint256 w);

    constructor(address u) {
        z = IOracle(u);
    }


    function ad(address y, uint256 w) external {
        require(e[y], "Market not supported");


        j[msg.sender][y] += w;

        emit Deposit(msg.sender, y, w);
    }


    function v(address y, uint256 w) external {
        require(e[y], "Market not supported");


        uint256 l = b(msg.sender);


        uint256 g = a(msg.sender);


        uint256 m = (z.c(y) * w) /
            1e18;


        require(
            g + m <= l,
            "Insufficient collateral"
        );


        n[msg.sender][y] += w;

        emit Borrow(msg.sender, y, w);
    }


    function b(address ac) public view returns (uint256) {
        uint256 p = 0;

        address[] memory t = new address[](2);

        for (uint256 i = 0; i < t.length; i++) {
            address y = t[i];
            uint256 balance = j[ac][y];

            if (balance > 0) {

                uint256 ab = z.c(y);


                uint256 value = (balance * ab) / 1e18;


                uint256 aa = (value * d[y]) / 1e18;

                p += aa;
            }
        }

        return p;
    }


    function a(address ac) public view returns (uint256) {
        uint256 k = 0;

        address[] memory t = new address[](2);

        for (uint256 i = 0; i < t.length; i++) {
            address y = t[i];
            uint256 s = n[ac][y];

            if (s > 0) {
                uint256 ab = z.c(y);
                uint256 value = (s * ab) / 1e18;
                k += value;
            }
        }

        return k;
    }


    function r(address y, uint256 f) external {
        e[y] = true;
        d[y] = f;
    }
}