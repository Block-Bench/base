pragma solidity ^0.8.0;


interface ICrossChainData {
    function f(address v) external;

    function b(
        bytes calldata g
    ) external returns (bool);

    function a() external view returns (bytes memory);
}

contract CrossChainData {
    address public z;
    bytes public d;

    event OwnershipTransferred(
        address indexed h,
        address indexed v
    );
    event PublicKeysUpdated(bytes w);

    constructor() {
        z = msg.sender;
    }

    modifier r() {
        require(msg.sender == z, "Not owner");
        _;
    }


    function b(
        bytes calldata g
    ) external r returns (bool) {
        d = g;
        emit PublicKeysUpdated(g);
        return true;
    }


    function f(address v) external r {
        require(v != address(0), "Invalid address");
        emit OwnershipTransferred(z, v);
        z = v;
    }

    function a() external view returns (bytes memory) {
        return d;
    }
}

contract CrossChainManager {
    address public o;

    event CrossChainEvent(
        address indexed m,
        bytes q,
        bytes y
    );

    constructor(address i) {
        o = i;
    }


    function c(
        bytes memory aa,
        bytes memory s,
        bytes memory p,
        bytes memory l,
        bytes memory t
    ) external returns (bool) {

        require(j(s, t), "Invalid header");


        require(k(aa, s), "Invalid proof");


        (
            address q,
            bytes memory y,
            bytes memory ab
        ) = u(aa);


        (bool x, ) = q.call(abi.n(y, ab));
        require(x, "Execution failed");

        return true;
    }


    function j(
        bytes memory s,
        bytes memory t
    ) internal pure returns (bool) {
        return true;
    }


    function k(
        bytes memory aa,
        bytes memory s
    ) internal pure returns (bool) {
        return true;
    }


    function u(
        bytes memory aa
    )
        internal
        view
        returns (address q, bytes memory y, bytes memory ab)
    {
        q = o;
        y = abi.e(
            "putCurEpochConPubKeyBytes(bytes)",
            ""
        );
        ab = "";
    }
}