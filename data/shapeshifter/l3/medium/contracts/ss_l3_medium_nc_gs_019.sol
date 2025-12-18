pragma solidity ^0.8.23;

import {ReentrancyGuardTrait} from "@gearbox-protocol/core-v3/contracts/traits/ReentrancyGuardTrait.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IMidasRedemptionVault} from "../../integrations/midas/IMidasRedemptionVault.sol";
import {IMidasRedemptionVaultGateway} from "../../interfaces/midas/IMidasRedemptionVaultGateway.sol";


contract MidasRedemptionVaultGateway is ReentrancyGuardTrait, IMidasRedemptionVaultGateway {
    using SafeERC20 for IERC20;

    bytes32 public constant override _0xac1e0d = "GATEWAY::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override _0xa6f2f6 = 3_10;

    address public immutable _0xfb45c5;
    address public immutable _0xb6a9d2;

    mapping(address => PendingRedemption) public _0x247633;


    constructor(address _0xf2d210) {
        _0xfb45c5 = _0xf2d210;
        _0xb6a9d2 = IMidasRedemptionVault(_0xf2d210)._0xb6a9d2();
    }


    function _0x111f2d(address _0xbd24f2, uint256 _0x5c5a61, uint256 _0x555214) external _0xd974bd {
        IERC20(_0xb6a9d2)._0x1f9b3b(msg.sender, address(this), _0x5c5a61);

        uint256 _0xffcef3 = IERC20(_0xbd24f2)._0x00375c(address(this));

        IERC20(_0xb6a9d2)._0x7a3202(_0xfb45c5, _0x5c5a61);
        IMidasRedemptionVault(_0xfb45c5)._0x111f2d(_0xbd24f2, _0x5c5a61, _0x555214);

        uint256 _0xc71e20 = IERC20(_0xbd24f2)._0x00375c(address(this)) - _0xffcef3;

        IERC20(_0xbd24f2)._0xf7de8d(msg.sender, _0xc71e20);
    }


    function _0xb2ea8e(address _0xbd24f2, uint256 _0x5c5a61) external _0xd974bd {
        if (_0x247633[msg.sender]._0xaa9807) {
            revert("MidasRedemptionVaultGateway: user has a pending redemption");
        }

        uint256 _0x8a0551 = IMidasRedemptionVault(_0xfb45c5)._0xabbfb1();

        IERC20(_0xb6a9d2)._0x1f9b3b(msg.sender, address(this), _0x5c5a61);

        IERC20(_0xb6a9d2)._0x7a3202(_0xfb45c5, _0x5c5a61);
        IMidasRedemptionVault(_0xfb45c5)._0xcf1808(_0xbd24f2, _0x5c5a61);

        _0x247633[msg.sender] =
            PendingRedemption({_0xaa9807: true, _0x8a0551: _0x8a0551, timestamp: block.timestamp, _0xed94e6: 0});
    }


    function _0xef447d(uint256 _0xc71e20) external _0xd974bd {
        PendingRedemption memory _0xb68caf = _0x247633[msg.sender];

        if (!_0xb68caf._0xaa9807) {
            revert("MidasRedemptionVaultGateway: user does not have a pending redemption");
        }

        (
            address sender,
            address _0xbd24f2,
            uint8 _0x0e516b,
            uint256 _0x5c5a61,
            uint256 _0x57838e,
            uint256 _0xe463df
        ) = IMidasRedemptionVault(_0xfb45c5)._0x11857c(_0xb68caf._0x8a0551);

        if (sender != address(this)) {
            revert("MidasRedemptionVaultGateway: invalid request");
        }

        if (_0x0e516b != 1) {
            revert("MidasRedemptionVaultGateway: redemption not fulfilled");
        }

        uint256 _0x2039cd;

        if (_0xb68caf._0xed94e6 > 0) {
            _0x2039cd = _0xb68caf._0xed94e6;
        } else {
            _0x2039cd = _0x3b9b3b(_0x5c5a61, _0x57838e, _0xe463df, _0xbd24f2);
        }

        if (_0xc71e20 > _0x2039cd) {
            revert("MidasRedemptionVaultGateway: amount exceeds available");
        }

        if (_0xc71e20 == _0x2039cd) {
            delete _0x247633[msg.sender];
        } else {
            _0x247633[msg.sender]._0xed94e6 = _0x2039cd - _0xc71e20;
        }

        IERC20(_0xbd24f2)._0xf7de8d(msg.sender, _0xc71e20);
    }


    function _0x89055c(address _0x763db2, address _0xbd24f2) external view returns (uint256) {
        PendingRedemption memory _0xb68caf = _0x247633[_0x763db2];

        if (!_0xb68caf._0xaa9807) {
            return 0;
        }

        (address sender, address _0x4cca27,, uint256 _0x5c5a61, uint256 _0x57838e, uint256 _0xe463df) =
            IMidasRedemptionVault(_0xfb45c5)._0x11857c(_0xb68caf._0x8a0551);

        if (sender != address(this) || _0x4cca27 != _0xbd24f2) {
            return 0;
        }

        if (_0xb68caf._0xed94e6 > 0) {
            return _0xb68caf._0xed94e6;
        } else {
            return _0x3b9b3b(_0x5c5a61, _0x57838e, _0xe463df, _0xbd24f2);
        }
    }


    function _0x3b9b3b(
        uint256 _0x5c5a61,
        uint256 _0x57838e,
        uint256 _0xe463df,
        address _0xbd24f2
    ) internal view returns (uint256) {
        uint256 _0x89a766 = (_0x5c5a61 * _0x57838e) / _0xe463df;

        uint256 _0x02467d = 10 ** IERC20Metadata(_0xbd24f2)._0x6567b3();

        return _0x89a766 * _0x02467d / 1e18;
    }
}