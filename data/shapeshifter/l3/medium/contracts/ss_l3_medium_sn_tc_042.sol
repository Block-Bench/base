// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x44e4ec, uint256 _0xddea38) external returns (bool);

    function _0x2b01a1(
        address from,
        address _0x44e4ec,
        uint256 _0xddea38
    ) external returns (bool);

    function _0xf31820(address _0x5ad34c) external view returns (uint256);

    function _0x23c1e2(address _0xdc18c5, uint256 _0xddea38) external returns (bool);
}

enum TokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address _0x0722ba;
    address _0x79c728;
    uint256 _0xddea38;
    uint256 _0xe3900f;
    TokenLockup _0xf9726e;
    bytes32 _0x42ba4a;
}

struct ClaimLockup {
    address _0x7162b4;
    uint256 _0x95f168;
    uint256 _0x39d7bb;
    uint256 _0x498ea5;
    uint256 _0x12b900;
}

struct Donation {
    address _0x7162b4;
    uint256 _0xddea38;
    uint256 _0x5a2df1;
    uint256 _0x95f168;
    uint256 _0x39d7bb;
    uint256 _0x498ea5;
}

contract HedgeyClaimCampaigns {
    mapping(bytes16 => Campaign) public _0xa1ae12;

    function _0xa20137(
        bytes16 _0xee2cd9,
        Campaign memory _0xef7d79,
        ClaimLockup memory _0x638d69,
        Donation memory _0x398010
    ) external {
        require(_0xa1ae12[_0xee2cd9]._0x0722ba == address(0), "Campaign exists");

        _0xa1ae12[_0xee2cd9] = _0xef7d79;

        if (_0x398010._0xddea38 > 0 && _0x398010._0x7162b4 != address(0)) {
            (bool _0xd47b0a, ) = _0x398010._0x7162b4.call(
                abi._0xab74e9(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    _0xef7d79._0x79c728,
                    _0x398010._0xddea38,
                    _0x398010._0x95f168,
                    _0x398010._0x39d7bb,
                    _0x398010._0x5a2df1,
                    _0x398010._0x498ea5
                )
            );

            require(_0xd47b0a, "Token lock failed");
        }
    }

    function _0x96b12b(bytes16 _0x6b6683) external {
        require(_0xa1ae12[_0x6b6683]._0x0722ba == msg.sender, "Not manager");
        delete _0xa1ae12[_0x6b6683];
    }
}
