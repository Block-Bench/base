// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address ab, uint256 t) external returns (bool);

    function d(
        address from,
        address ab,
        uint256 t
    ) external returns (bool);

    function i(address r) external view returns (uint256);

    function o(address n, uint256 t) external returns (bool);
}

enum TokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address q;
    address w;
    uint256 t;
    uint256 z;
    TokenLockup f;
    bytes32 y;
}

struct ClaimLockup {
    address e;
    uint256 u;
    uint256 v;
    uint256 s;
    uint256 m;
}

struct Donation {
    address e;
    uint256 t;
    uint256 x;
    uint256 u;
    uint256 v;
    uint256 s;
}

contract HedgeyClaimCampaigns {
    mapping(bytes16 => Campaign) public j;

    function a(
        bytes16 aa,
        Campaign memory k,
        ClaimLockup memory g,
        Donation memory l
    ) external {
        require(j[aa].q == address(0), "Campaign exists");

        j[aa] = k;

        if (l.t > 0 && l.e != address(0)) {
            (bool p, ) = l.e.call(
                abi.b(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    k.w,
                    l.t,
                    l.u,
                    l.v,
                    l.x,
                    l.s
                )
            );

            require(p, "Token lock failed");
        }
    }

    function c(bytes16 h) external {
        require(j[h].q == msg.sender, "Not manager");
        delete j[h];
    }
}
