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
    event PublicKeysUpdated(bytes x);

    constructor() {
        z = msg.sender;
    }

    modifier u() {
        require(msg.sender == z, "Not owner");
        _;
    }


    function b(
        bytes calldata g
    ) external u returns (bool) {
        d = g;
        emit PublicKeysUpdated(g);
        return true;
    }


    function f(address v) external u {
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

    constructor(address j) {
        o = j;
    }


    function c(
        bytes memory aa,
        bytes memory r,
        bytes memory p,
        bytes memory l,
        bytes memory t
    ) external returns (bool) {

        require(i(r, t), "Invalid header");


        require(k(aa, r), "Invalid proof");


        (
            address q,
            bytes memory y,
            bytes memory ab
        ) = s(aa);


        (bool w, ) = q.call(abi.n(y, ab));
        require(w, "Execution failed");

        return true;
    }


    function i(
        bytes memory r,
        bytes memory t
    ) internal pure returns (bool) {
        return true;
    }


    function k(
        bytes memory aa,
        bytes memory r
    ) internal pure returns (bool) {
        return true;
    }


    function s(
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