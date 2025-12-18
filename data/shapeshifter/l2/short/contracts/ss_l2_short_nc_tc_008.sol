pragma solidity ^0.8.0;


interface IOracle {
    function c(address z) external view returns (uint256);
}

interface ICToken {
    function ad(uint256 q) external;

    function y(uint256 i) external;

    function x(uint256 h) external;

    function p() external view returns (address);
}

contract LendingProtocol {

    IOracle public v;


    mapping(address => uint256) public d;


    mapping(address => mapping(address => uint256)) public k;


    mapping(address => mapping(address => uint256)) public l;


    mapping(address => bool) public e;

    event Deposit(address indexed ac, address indexed z, uint256 w);
    event Borrow(address indexed ac, address indexed z, uint256 w);

    constructor(address t) {
        v = IOracle(t);
    }


    function ad(address z, uint256 w) external {
        require(e[z], "Market not supported");


        k[msg.sender][z] += w;

        emit Deposit(msg.sender, z, w);
    }


    function y(address z, uint256 w) external {
        require(e[z], "Market not supported");


        uint256 m = b(msg.sender);


        uint256 g = a(msg.sender);


        uint256 n = (v.c(z) * w) /
            1e18;


        require(
            g + n <= m,
            "Insufficient collateral"
        );


        l[msg.sender][z] += w;

        emit Borrow(msg.sender, z, w);
    }


    function b(address ac) public view returns (uint256) {
        uint256 o = 0;

        address[] memory u = new address[](2);

        for (uint256 i = 0; i < u.length; i++) {
            address z = u[i];
            uint256 balance = k[ac][z];

            if (balance > 0) {

                uint256 aa = v.c(z);


                uint256 value = (balance * aa) / 1e18;


                uint256 ab = (value * d[z]) / 1e18;

                o += ab;
            }
        }

        return o;
    }


    function a(address ac) public view returns (uint256) {
        uint256 j = 0;

        address[] memory u = new address[](2);

        for (uint256 i = 0; i < u.length; i++) {
            address z = u[i];
            uint256 s = l[ac][z];

            if (s > 0) {
                uint256 aa = v.c(z);
                uint256 value = (s * aa) / 1e18;
                j += value;
            }
        }

        return j;
    }


    function r(address z, uint256 f) external {
        e[z] = true;
        d[z] = f;
    }
}