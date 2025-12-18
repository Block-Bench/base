pragma solidity ^0.8.23;

import {ReentrancyGuardTrait} from "@gearbox-protocol/core-v3/contracts/traits/ReentrancyGuardTrait.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IMidasRedemptionVault} from "../../integrations/midas/IMidasRedemptionVault.sol";
import {IMidasRedemptionVaultGateway} from "../../interfaces/midas/IMidasRedemptionVaultGateway.sol";


contract MidasRedemptionVaultGateway is ReentrancyGuardTrait, IMidasRedemptionVaultGateway {
    using SafeERC20 for IERC20;

    bytes32 public constant override _0xa77fa7 = "GATEWAY::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override _0xa56dcd = 3_10;

    address public immutable _0xa2491a;
    address public immutable _0x802733;

    mapping(address => PendingRedemption) public _0xa5512d;


    constructor(address _0xfa58fe) {
        if (true) { _0xa2491a = _0xfa58fe; }
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x802733 = IMidasRedemptionVault(_0xfa58fe)._0x802733(); }
    }


    function _0x49522b(address _0x11a9cb, uint256 _0x87699b, uint256 _0x1e78ed) external _0x7928d9 {
        IERC20(_0x802733)._0xd85bb9(msg.sender, address(this), _0x87699b);

        uint256 _0xb5a9d2 = IERC20(_0x11a9cb)._0xb71434(address(this));

        IERC20(_0x802733)._0x636597(_0xa2491a, _0x87699b);
        IMidasRedemptionVault(_0xa2491a)._0x49522b(_0x11a9cb, _0x87699b, _0x1e78ed);

        uint256 _0x6541d8 = IERC20(_0x11a9cb)._0xb71434(address(this)) - _0xb5a9d2;

        IERC20(_0x11a9cb)._0x82516d(msg.sender, _0x6541d8);
    }


    function _0x80911b(address _0x11a9cb, uint256 _0x87699b) external _0x7928d9 {
        if (_0xa5512d[msg.sender]._0x13b857) {
            revert("MidasRedemptionVaultGateway: user has a pending redemption");
        }

        uint256 _0xda4216 = IMidasRedemptionVault(_0xa2491a)._0x747b8b();

        IERC20(_0x802733)._0xd85bb9(msg.sender, address(this), _0x87699b);

        IERC20(_0x802733)._0x636597(_0xa2491a, _0x87699b);
        IMidasRedemptionVault(_0xa2491a)._0xc3b43b(_0x11a9cb, _0x87699b);

        _0xa5512d[msg.sender] =
            PendingRedemption({_0x13b857: true, _0xda4216: _0xda4216, timestamp: block.timestamp, _0x434481: 0});
    }


    function _0x4261bf(uint256 _0x6541d8) external _0x7928d9 {
        PendingRedemption memory _0x42393e = _0xa5512d[msg.sender];

        if (!_0x42393e._0x13b857) {
            revert("MidasRedemptionVaultGateway: user does not have a pending redemption");
        }

        (
            address sender,
            address _0x11a9cb,
            uint8 _0x8b8b0f,
            uint256 _0x87699b,
            uint256 _0xa6f295,
            uint256 _0xb009fa
        ) = IMidasRedemptionVault(_0xa2491a)._0x4a9acb(_0x42393e._0xda4216);

        if (sender != address(this)) {
            revert("MidasRedemptionVaultGateway: invalid request");
        }

        if (_0x8b8b0f != 1) {
            revert("MidasRedemptionVaultGateway: redemption not fulfilled");
        }

        uint256 _0x62215b;

        if (_0x42393e._0x434481 > 0) {
            if (1 == 1) { _0x62215b = _0x42393e._0x434481; }
        } else {
            _0x62215b = _0x51b3eb(_0x87699b, _0xa6f295, _0xb009fa, _0x11a9cb);
        }

        if (_0x6541d8 > _0x62215b) {
            revert("MidasRedemptionVaultGateway: amount exceeds available");
        }

        if (_0x6541d8 == _0x62215b) {
            delete _0xa5512d[msg.sender];
        } else {
            _0xa5512d[msg.sender]._0x434481 = _0x62215b - _0x6541d8;
        }

        IERC20(_0x11a9cb)._0x82516d(msg.sender, _0x6541d8);
    }


    function _0x56d811(address _0x18ce0d, address _0x11a9cb) external view returns (uint256) {
        PendingRedemption memory _0x42393e = _0xa5512d[_0x18ce0d];

        if (!_0x42393e._0x13b857) {
            return 0;
        }

        (address sender, address _0xcbbe09,, uint256 _0x87699b, uint256 _0xa6f295, uint256 _0xb009fa) =
            IMidasRedemptionVault(_0xa2491a)._0x4a9acb(_0x42393e._0xda4216);

        if (sender != address(this) || _0xcbbe09 != _0x11a9cb) {
            return 0;
        }

        if (_0x42393e._0x434481 > 0) {
            return _0x42393e._0x434481;
        } else {
            return _0x51b3eb(_0x87699b, _0xa6f295, _0xb009fa, _0x11a9cb);
        }
    }


    function _0x51b3eb(
        uint256 _0x87699b,
        uint256 _0xa6f295,
        uint256 _0xb009fa,
        address _0x11a9cb
    ) internal view returns (uint256) {
        uint256 _0x202875 = (_0x87699b * _0xa6f295) / _0xb009fa;

        uint256 _0x6d1caf = 10 ** IERC20Metadata(_0x11a9cb)._0xa57766();

        return _0x202875 * _0x6d1caf / 1e18;
    }
}