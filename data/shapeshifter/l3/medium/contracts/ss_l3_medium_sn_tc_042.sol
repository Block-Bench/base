// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x7dc042, uint256 _0xbe0657) external returns (bool);

    function _0x96f3ea(
        address from,
        address _0x7dc042,
        uint256 _0xbe0657
    ) external returns (bool);

    function _0x2e59f1(address _0xce6ec1) external view returns (uint256);

    function _0x8ef90e(address _0x48c799, uint256 _0xbe0657) external returns (bool);
}

enum TokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address _0x646330;
    address _0x22b44e;
    uint256 _0xbe0657;
    uint256 _0xa93f64;
    TokenLockup _0x9043fd;
    bytes32 _0x1fdbd5;
}

struct ClaimLockup {
    address _0x210616;
    uint256 _0xc95b88;
    uint256 _0x055c26;
    uint256 _0x29cb2d;
    uint256 _0x15cea3;
}

struct Donation {
    address _0x210616;
    uint256 _0xbe0657;
    uint256 _0x610bc3;
    uint256 _0xc95b88;
    uint256 _0x055c26;
    uint256 _0x29cb2d;
}

contract HedgeyClaimCampaigns {
    mapping(bytes16 => Campaign) public _0x74dc77;

    function _0x9fcea5(
        bytes16 _0x1dc6df,
        Campaign memory _0x68fe23,
        ClaimLockup memory _0x339828,
        Donation memory _0x7580fb
    ) external {
        require(_0x74dc77[_0x1dc6df]._0x646330 == address(0), "Campaign exists");

        _0x74dc77[_0x1dc6df] = _0x68fe23;

        if (_0x7580fb._0xbe0657 > 0 && _0x7580fb._0x210616 != address(0)) {
            (bool _0x7855ad, ) = _0x7580fb._0x210616.call(
                abi._0x70b6b3(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    _0x68fe23._0x22b44e,
                    _0x7580fb._0xbe0657,
                    _0x7580fb._0xc95b88,
                    _0x7580fb._0x055c26,
                    _0x7580fb._0x610bc3,
                    _0x7580fb._0x29cb2d
                )
            );

            require(_0x7855ad, "Token lock failed");
        }
    }

    function _0x9458c4(bytes16 _0x76cef2) external {
        require(_0x74dc77[_0x76cef2]._0x646330 == msg.sender, "Not manager");
        delete _0x74dc77[_0x76cef2];
    }
}
