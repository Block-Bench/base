pragma solidity ^0.8.23;

import {ReentrancyGuardTrait} from "@gearbox-protocol/core-v3/contracts/traits/ReentrancyGuardTrait.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IMidasRedemptionVault} from "../../integrations/midas/IMidasRedemptionVault.sol";
import {IMidasRedemptionVaultGateway} from "../../interfaces/midas/IMidasRedemptionVaultGateway.sol";


contract MidasRedemptionVaultGateway is ReentrancyGuardTrait, IMidasRedemptionVaultGateway {
    using SafeERC20 for IERC20;

    bytes32 public constant override s = "GATEWAY::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override ag = 3_10;

    address public immutable d;
    address public immutable ah;

    mapping(address => PendingRedemption) public e;


    constructor(address c) {
        d = c;
        ah = IMidasRedemptionVault(c).ah();
    }


    function n(address ae, uint256 l, uint256 h) external t {
        IERC20(ah).f(msg.sender, address(this), l);

        uint256 p = IERC20(ae).z(address(this));

        IERC20(ah).u(d, l);
        IMidasRedemptionVault(d).n(ae, l, h);

        uint256 ai = IERC20(ae).z(address(this)) - p;

        IERC20(ae).q(msg.sender, ai);
    }


    function o(address ae, uint256 l) external t {
        if (e[msg.sender].ac) {
            revert("MidasRedemptionVaultGateway: user has a pending redemption");
        }

        uint256 x = IMidasRedemptionVault(d).g();

        IERC20(ah).f(msg.sender, address(this), l);

        IERC20(ah).u(d, l);
        IMidasRedemptionVault(d).m(ae, l);

        e[msg.sender] =
            PendingRedemption({ac: true, x: x, timestamp: block.timestamp, y: 0});
    }


    function ab(uint256 ai) external t {
        PendingRedemption memory af = e[msg.sender];

        if (!af.ac) {
            revert("MidasRedemptionVaultGateway: user does not have a pending redemption");
        }

        (
            address sender,
            address ae,
            uint8 aj,
            uint256 l,
            uint256 w,
            uint256 r
        ) = IMidasRedemptionVault(d).k(af.x);

        if (sender != address(this)) {
            revert("MidasRedemptionVaultGateway: invalid request");
        }

        if (aj != 1) {
            revert("MidasRedemptionVaultGateway: redemption not fulfilled");
        }

        uint256 i;

        if (af.y > 0) {
            i = af.y;
        } else {
            i = a(l, w, r, ae);
        }

        if (ai > i) {
            revert("MidasRedemptionVaultGateway: amount exceeds available");
        }

        if (ai == i) {
            delete e[msg.sender];
        } else {
            e[msg.sender].y = i - ai;
        }

        IERC20(ae).q(msg.sender, ai);
    }


    function b(address ak, address ae) external view returns (uint256) {
        PendingRedemption memory af = e[ak];

        if (!af.ac) {
            return 0;
        }

        (address sender, address j,, uint256 l, uint256 w, uint256 r) =
            IMidasRedemptionVault(d).k(af.x);

        if (sender != address(this) || j != ae) {
            return 0;
        }

        if (af.y > 0) {
            return af.y;
        } else {
            return a(l, w, r, ae);
        }
    }


    function a(
        uint256 l,
        uint256 w,
        uint256 r,
        address ae
    ) internal view returns (uint256) {
        uint256 v = (l * w) / r;

        uint256 aa = 10 ** IERC20Metadata(ae).ad();

        return v * aa / 1e18;
    }
}