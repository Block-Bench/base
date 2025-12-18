pragma solidity ^0.8.0;


contract CrossChainBridge {

    address[] public t;
    mapping(address => bool) public o;

    uint256 public c = 5;
    uint256 public i;


    mapping(uint256 => bool) public b;


    mapping(address => bool) public h;

    event WithdrawalProcessed(
        uint256 indexed m,
        address indexed ai,
        address indexed ah,
        uint256 ab
    );

    constructor(address[] memory r) {
        require(
            r.length >= c,
            "Not enough validators"
        );

        for (uint256 i = 0; i < r.length; i++) {
            address w = r[i];
            require(w != address(0), "Invalid validator");
            require(!o[w], "Duplicate validator");

            t.push(w);
            o[w] = true;
        }

        i = r.length;
    }


    function g(
        uint256 l,
        address ag,
        address ae,
        uint256 z,
        bytes memory p
    ) external {

        require(!b[l], "Already processed");


        require(h[ae], "Token not supported");


        require(
            f(
                l,
                ag,
                ae,
                z,
                p
            ),
            "Invalid signatures"
        );


        b[l] = true;


        emit WithdrawalProcessed(l, ag, ae, z);
    }


    function f(
        uint256 l,
        address ag,
        address ae,
        uint256 z,
        bytes memory p
    ) internal view returns (bool) {
        require(p.length % 65 == 0, "Invalid signature length");

        uint256 k = p.length / 65;
        require(k >= c, "Not enough signatures");


        bytes32 q = x(
            abi.n(l, ag, ae, z)
        );
        bytes32 a = x(
            abi.n("\x19Ethereum Signed Message:\n32", q)
        );

        address[] memory y = new address[](k);


        for (uint256 i = 0; i < k; i++) {
            bytes memory v = e(p, i);
            address aa = j(a, v);


            require(o[aa], "Invalid signer");


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
        bytes memory v = new bytes(65);
        uint256 ac = ad * 65;

        for (uint256 i = 0; i < 65; i++) {
            v[i] = p[ac + i];
        }

        return v;
    }


    function j(
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


    function d(address ae) external {
        h[ae] = true;
    }
}