pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ab, uint256 s) external returns (bool);

    function d(
        address from,
        address ab,
        uint256 s
    ) external returns (bool);

    function j(address r) external view returns (uint256);

    function q(address n, uint256 s) external returns (bool);
}

enum TokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address m;
    address u;
    uint256 s;
    uint256 z;
    TokenLockup f;
    bytes32 x;
}

struct ClaimLockup {
    address g;
    uint256 w;
    uint256 v;
    uint256 t;
    uint256 p;
}

struct Donation {
    address g;
    uint256 s;
    uint256 y;
    uint256 w;
    uint256 v;
    uint256 t;
}

contract HedgeyClaimCampaigns {
    mapping(bytes16 => Campaign) public i;

    function a(
        bytes16 aa,
        Campaign memory k,
        ClaimLockup memory e,
        Donation memory l
    ) external {
        require(i[aa].m == address(0), "Campaign exists");

        i[aa] = k;

        if (l.s > 0 && l.g != address(0)) {
            (bool o, ) = l.g.call(
                abi.b(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    k.u,
                    l.s,
                    l.w,
                    l.v,
                    l.y,
                    l.t
                )
            );

            require(o, "Token lock failed");
        }
    }

    function c(bytes16 h) external {
        require(i[h].m == msg.sender, "Not manager");
        delete i[h];
    }
}