// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xfca7c4, uint256 _0x9c9734) external returns (bool);

    function _0x5af8dd(
        address from,
        address _0xfca7c4,
        uint256 _0x9c9734
    ) external returns (bool);

    function _0x952140(address _0xdf5107) external view returns (uint256);

    function _0x4581b4(address _0x197458, uint256 _0x9c9734) external returns (bool);
}

enum TokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address _0x933669;
    address _0xe0f331;
    uint256 _0x9c9734;
    uint256 _0xe0bd67;
    TokenLockup _0x47a119;
    bytes32 _0xb19482;
}

struct ClaimLockup {
    address _0x722525;
    uint256 _0x4a8404;
    uint256 _0xaf519c;
    uint256 _0x9da50e;
    uint256 _0xd81907;
}

struct Donation {
    address _0x722525;
    uint256 _0x9c9734;
    uint256 _0x2dc857;
    uint256 _0x4a8404;
    uint256 _0xaf519c;
    uint256 _0x9da50e;
}

contract HedgeyClaimCampaigns {
    mapping(bytes16 => Campaign) public _0x1c4ee6;

    function _0x44ba4e(
        bytes16 _0x720431,
        Campaign memory _0x8492be,
        ClaimLockup memory _0xe016ba,
        Donation memory _0xc21a9e
    ) external {
        require(_0x1c4ee6[_0x720431]._0x933669 == address(0), "Campaign exists");

        _0x1c4ee6[_0x720431] = _0x8492be;

        if (_0xc21a9e._0x9c9734 > 0 && _0xc21a9e._0x722525 != address(0)) {
            (bool _0x488f81, ) = _0xc21a9e._0x722525.call(
                abi._0x285db0(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    _0x8492be._0xe0f331,
                    _0xc21a9e._0x9c9734,
                    _0xc21a9e._0x4a8404,
                    _0xc21a9e._0xaf519c,
                    _0xc21a9e._0x2dc857,
                    _0xc21a9e._0x9da50e
                )
            );

            require(_0x488f81, "Token lock failed");
        }
    }

    function _0x75f343(bytes16 _0x6fa7a3) external {
        require(_0x1c4ee6[_0x6fa7a3]._0x933669 == msg.sender, "Not manager");
        delete _0x1c4ee6[_0x6fa7a3];
    }
}
