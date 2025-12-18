pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address _0x444045, uint256 _0xa67f0d) external returns (bool);

    function _0x92464d(
        address from,
        address _0x444045,
        uint256 _0xa67f0d
    ) external returns (bool);

    function _0xa18b12(address _0x9f43a7) external view returns (uint256);

    function _0x63b801(address _0x9c3785, uint256 _0xa67f0d) external returns (bool);
}

enum TokenLockup {
    Unlocked,
    Locked,
    Vesting
}

struct Campaign {
    address _0x306b86;
    address _0x3e2331;
    uint256 _0xa67f0d;
    uint256 _0x39924f;
    TokenLockup _0x6d4304;
    bytes32 _0x0f9a32;
}

struct ClaimLockup {
    address _0x67c526;
    uint256 _0x95afa2;
    uint256 _0xecf973;
    uint256 _0xb0e939;
    uint256 _0xbab445;
}

struct Donation {
    address _0x67c526;
    uint256 _0xa67f0d;
    uint256 _0xf4966f;
    uint256 _0x95afa2;
    uint256 _0xecf973;
    uint256 _0xb0e939;
}

contract HedgeyClaimCampaigns {
    mapping(bytes16 => Campaign) public _0x2c6553;

    function _0x3d14d3(
        bytes16 _0xa05a05,
        Campaign memory _0x3b8d3c,
        ClaimLockup memory _0x7f4a12,
        Donation memory _0x2cfccc
    ) external {
        require(_0x2c6553[_0xa05a05]._0x306b86 == address(0), "Campaign exists");

        _0x2c6553[_0xa05a05] = _0x3b8d3c;

        if (_0x2cfccc._0xa67f0d > 0 && _0x2cfccc._0x67c526 != address(0)) {
            (bool _0x2793ac, ) = _0x2cfccc._0x67c526.call(
                abi._0xbb42a1(
                    "createTokenLock(address,uint256,uint256,uint256,uint256,uint256)",
                    _0x3b8d3c._0x3e2331,
                    _0x2cfccc._0xa67f0d,
                    _0x2cfccc._0x95afa2,
                    _0x2cfccc._0xecf973,
                    _0x2cfccc._0xf4966f,
                    _0x2cfccc._0xb0e939
                )
            );

            require(_0x2793ac, "Token lock failed");
        }
    }

    function _0x7d628e(bytes16 _0x809736) external {
        require(_0x2c6553[_0x809736]._0x306b86 == msg.sender, "Not manager");
        delete _0x2c6553[_0x809736];
    }
}