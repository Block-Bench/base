pragma solidity ^0.8.23;

import {ReentrancyGuardTrait} from "@gearbox-protocol/core-v3/contracts/traits/ReentrancyGuardTrait.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IMidasRedemptionVault} from "../../integrations/midas/IMidasRedemptionVault.sol";
import {IMidasRedemptionVaultGateway} from "../../interfaces/midas/IMidasRedemptionVaultGateway.sol";


contract MidasRedemptionVaultGateway is ReentrancyGuardTrait, IMidasRedemptionVaultGateway {
    using SafeERC20 for IERC20;

    bytes32 public constant override r = "GATEWAY::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override ag = 3_10;

    address public immutable d;
    address public immutable ah;

    mapping(address => PendingRedemption) public e;


    constructor(address c) {
        d = c;
        ah = IMidasRedemptionVault(c).ah();
    }


    function p(address ab, uint256 l, uint256 f) external t {
        IERC20(ah).g(msg.sender, address(this), l);

        uint256 m = IERC20(ab).z(address(this));

        IERC20(ah).u(d, l);
        IMidasRedemptionVault(d).p(ab, l, f);

        uint256 ai = IERC20(ab).z(address(this)) - m;

        IERC20(ab).q(msg.sender, ai);
    }


    function n(address ab, uint256 l) external t {
        if (e[msg.sender].ad) {
            revert("MidasRedemptionVaultGateway: user has a pending redemption");
        }

        uint256 x = IMidasRedemptionVault(d).h();

        IERC20(ah).g(msg.sender, address(this), l);

        IERC20(ah).u(d, l);
        IMidasRedemptionVault(d).o(ab, l);

        e[msg.sender] =
            PendingRedemption({ad: true, x: x, timestamp: block.timestamp, aa: 0});
    }


    function ac(uint256 ai) external t {
        PendingRedemption memory af = e[msg.sender];

        if (!af.ad) {
            revert("MidasRedemptionVaultGateway: user does not have a pending redemption");
        }

        (
            address sender,
            address ab,
            uint8 aj,
            uint256 l,
            uint256 w,
            uint256 s
        ) = IMidasRedemptionVault(d).k(af.x);

        if (sender != address(this)) {
            revert("MidasRedemptionVaultGateway: invalid request");
        }

        if (aj != 1) {
            revert("MidasRedemptionVaultGateway: redemption not fulfilled");
        }

        uint256 i;

        if (af.aa > 0) {
            i = af.aa;
        } else {
            i = a(l, w, s, ab);
        }

        if (ai > i) {
            revert("MidasRedemptionVaultGateway: amount exceeds available");
        }

        if (ai == i) {
            delete e[msg.sender];
        } else {
            e[msg.sender].aa = i - ai;
        }

        IERC20(ab).q(msg.sender, ai);
    }


    function b(address ak, address ab) external view returns (uint256) {
        PendingRedemption memory af = e[ak];

        if (!af.ad) {
            return 0;
        }

        (address sender, address j,, uint256 l, uint256 w, uint256 s) =
            IMidasRedemptionVault(d).k(af.x);

        if (sender != address(this) || j != ab) {
            return 0;
        }

        if (af.aa > 0) {
            return af.aa;
        } else {
            return a(l, w, s, ab);
        }
    }


    function a(
        uint256 l,
        uint256 w,
        uint256 s,
        address ab
    ) internal view returns (uint256) {
        uint256 v = (l * w) / s;

        uint256 y = 10 ** IERC20Metadata(ab).ae();

        return v * y / 1e18;
    }
}