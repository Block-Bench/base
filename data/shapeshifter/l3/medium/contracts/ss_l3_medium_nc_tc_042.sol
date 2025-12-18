pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0xbb2971, uint256 _0xc2f506) external returns (bool);

    function _0x669281(
        address from,
        address _0xbb2971,
        uint256 _0xc2f506
    ) external returns (bool);

    function _0xe835fa(address _0x9404fd) external view returns (uint256);

    function _0x5bc797(address _0x771665, uint256 _0xc2f506) external returns (bool);
}

enum TokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address _0x00cf3f;
    address _0x9e33c7;
    uint256 _0xc2f506;
    uint256 _0x9f06a3;
    TokenLockup _0xdb0836;
    bytes32 _0x41ce07;
}

struct ClaimLockup {
    address _0x7caef8;
    uint256 _0x5d31c4;
    uint256 _0x835b99;
    uint256 _0x689d58;
    uint256 _0x824557;
}

struct Donation {
    address _0x7caef8;
    uint256 _0xc2f506;
    uint256 _0x31b8f1;
    uint256 _0x5d31c4;
    uint256 _0x835b99;
    uint256 _0x689d58;
}

contract HedgeyClaimCampaigns {
    mapping(bytes16 => Campaign) public _0x43ac4a;

    function _0xec6138(
        bytes16 _0x921ffb,
        Campaign memory _0xa9e8ae,
        ClaimLockup memory _0x491934,
        Donation memory _0xc4b5bf
    ) external {
        require(_0x43ac4a[_0x921ffb]._0x00cf3f == address(0), "Campaign exists");

        _0x43ac4a[_0x921ffb] = _0xa9e8ae;

        if (_0xc4b5bf._0xc2f506 > 0 && _0xc4b5bf._0x7caef8 != address(0)) {
            (bool _0x9a661e, ) = _0xc4b5bf._0x7caef8.call(
                abi._0xfa9525(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    _0xa9e8ae._0x9e33c7,
                    _0xc4b5bf._0xc2f506,
                    _0xc4b5bf._0x5d31c4,
                    _0xc4b5bf._0x835b99,
                    _0xc4b5bf._0x31b8f1,
                    _0xc4b5bf._0x689d58
                )
            );

            require(_0x9a661e, "Token lock failed");
        }
    }

    function _0xed76dc(bytes16 _0x2ae50f) external {
        require(_0x43ac4a[_0x2ae50f]._0x00cf3f == msg.sender, "Not manager");
        delete _0x43ac4a[_0x2ae50f];
    }
}