pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ab, uint256 s) external returns (bool);

    function d(
        address from,
        address ab,
        uint256 s
    ) external returns (bool);

    function j(address r) external view returns (uint256);

    function n(address p, uint256 s) external returns (bool);
}

enum TokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address q;
    address u;
    uint256 s;
    uint256 z;
    TokenLockup e;
    bytes32 y;
}

struct ClaimLockup {
    address g;
    uint256 v;
    uint256 w;
    uint256 t;
    uint256 m;
}

struct Donation {
    address g;
    uint256 s;
    uint256 x;
    uint256 v;
    uint256 w;
    uint256 t;
}

contract HedgeyClaimCampaigns {
    mapping(bytes16 => Campaign) public i;

    function a(
        bytes16 aa,
        Campaign memory l,
        ClaimLockup memory f,
        Donation memory k
    ) external {
        require(i[aa].q == address(0), "Campaign exists");

        i[aa] = l;

        if (k.s > 0 && k.g != address(0)) {
            (bool o, ) = k.g.call(
                abi.b(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    l.u,
                    k.s,
                    k.v,
                    k.w,
                    k.x,
                    k.t
                )
            );

            require(o, "Token lock failed");
        }
    }

    function c(bytes16 h) external {
        require(i[h].q == msg.sender, "Not manager");
        delete i[h];
    }
}