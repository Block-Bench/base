pragma solidity ^0.8.0;


contract CrossChainBridge {

    address[] public t;
    mapping(address => bool) public q;

    uint256 public c = 5;
    uint256 public j;


    mapping(uint256 => bool) public b;


    mapping(address => bool) public h;

    event WithdrawalProcessed(
        uint256 indexed m,
        address indexed ai,
        address indexed ag,
        uint256 ab
    );

    constructor(address[] memory r) {
        require(
            r.length >= c,
            "Not enough validators"
        );

        for (uint256 i = 0; i < r.length; i++) {
            address x = r[i];
            require(x != address(0), "Invalid validator");
            require(!q[x], "Duplicate validator");

            t.push(x);
            q[x] = true;
        }

        j = r.length;
    }


    function g(
        uint256 l,
        address ah,
        address ac,
        uint256 z,
        bytes memory p
    ) external {

        require(!b[l], "Already processed");


        require(h[ac], "Token not supported");


        require(
            d(
                l,
                ah,
                ac,
                z,
                p
            ),
            "Invalid signatures"
        );


        b[l] = true;


        emit WithdrawalProcessed(l, ah, ac, z);
    }


    function d(
        uint256 l,
        address ah,
        address ac,
        uint256 z,
        bytes memory p
    ) internal view returns (bool) {
        require(p.length % 65 == 0, "Invalid signature length");

        uint256 i = p.length / 65;
        require(i >= c, "Not enough signatures");


        bytes32 o = v(
            abi.n(l, ah, ac, z)
        );
        bytes32 a = v(
            abi.n("\x19Ethereum Signed Message:\n32", o)
        );

        address[] memory y = new address[](i);


        for (uint256 i = 0; i < i; i++) {
            bytes memory w = e(p, i);
            address aa = k(a, w);


            require(q[aa], "Invalid signer");


            for (uint256 j = 0; j < i; j++) {
                require(y[j] != aa, "Duplicate signer");
            }

            y[i] = aa;
        }


        return true;
    }


    function e(
        bytes memory p,
        uint256 ad
    ) internal pure returns (bytes memory) {
        bytes memory w = new bytes(65);
        uint256 ae = ad * 65;

        for (uint256 i = 0; i < 65; i++) {
            w[i] = p[ae + i];
        }

        return w;
    }


    function k(
        bytes32 af,
        bytes memory s
    ) internal pure returns (address) {
        require(s.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(s, 32))
            s := mload(add(s, 64))
            v := byte(0, mload(add(s, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature v value");

        return u(af, v, r, s);
    }


    function f(address ac) external {
        h[ac] = true;
    }
}