pragma solidity ^0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {AbstractAdapter} from "../AbstractAdapter.sol";
import {NotImplementedException} from "@gearbox-protocol/core-v3/contracts/interfaces/IExceptions.sol";

import {IMidasRedemptionVault} from "../../integrations/midas/IMidasRedemptionVault.sol";
import {IMidasRedemptionVaultAdapter} from "../../interfaces/midas/IMidasRedemptionVaultAdapter.sol";
import {IMidasRedemptionVaultGateway} from "../../interfaces/midas/IMidasRedemptionVaultGateway.sol";

import {WAD, RAY} from "@gearbox-protocol/core-v3/contracts/libraries/Constants.sol";


contract MidasRedemptionVaultAdapter is AbstractAdapter, IMidasRedemptionVaultAdapter {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant override ab = "ADAPTER::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override ap = 3_10;


    address public immutable override au;


    address public immutable override as;


    mapping(address => address) public b;


    mapping(address => address) public c;


    EnumerableSet.AddressSet internal n;


    constructor(address q, address ak) AbstractAdapter(q, ak) {
        as = ak;
        au = IMidasRedemptionVaultGateway(ak).au();

        h(au);
    }


    function y(address aj, uint256 t, uint256 k)
        external
        override
        i
        returns (bool)
    {
        if (!r(aj)) revert TokenNotAllowedException();

        m(aj, t, k);

        return false;
    }


    function g(address aj, uint256 s, uint256 ae)
        external
        override
        i
        returns (bool)
    {
        if (!r(aj)) revert TokenNotAllowedException();

        address x = p();

        uint256 balance = IERC20(au).ai(x);
        if (balance > s) {
            unchecked {
                uint256 av = balance - s;
                uint256 k = (av * ae) / RAY;
                m(aj, av, k);
            }
        }
        return false;
    }


    function m(address aj, uint256 t, uint256 k) internal {
        d(
            au,
            abi.ad(
                IMidasRedemptionVaultGateway.y,
                (aj, t, z(k, aj))
            )
        );
    }


    function w(address aj, uint256 t)
        external
        override
        i
        returns (bool)
    {
        if (!r(aj) || c[aj] == address(0)) {
            revert TokenNotAllowedException();
        }

        d(
            au, abi.ad(IMidasRedemptionVaultGateway.v, (aj, t))
        );
        return true;
    }


    function am(uint256 av) external override i returns (bool) {
        ag(av);
        return false;
    }


    function ag(uint256 av) internal {
        al(abi.ad(IMidasRedemptionVaultGateway.am, (av)));
    }


    function e(address az, uint256 av) external override i returns (bool) {
        if (b[az] == address(0)) revert IncorrectStakedPhantomTokenException();
        ag(av);
        return false;
    }


    function f(address, uint256) external pure override returns (bool) {
        revert NotImplementedException();
    }


    function z(uint256 av, address az) internal view returns (uint256) {
        uint256 af = 10 ** IERC20Metadata(az).ao();
        return av * WAD / af;
    }


    function r(address az) public view override returns (bool) {
        return n.an(az);
    }


    function aa() public view override returns (address[] memory) {
        return n.aw();
    }


    function a(MidasAllowedTokenStatus[] calldata aq)
        external
        override
        j
    {
        uint256 bb = aq.length;

        for (uint256 i; i < bb; ++i) {
            MidasAllowedTokenStatus memory ax = aq[i];

            if (ax.ar) {
                h(ax.az);
                n.ba(ax.az);

                if (ax.ac != address(0)) {
                    h(ax.ac);
                    b[ax.ac] = ax.az;
                    c[ax.az] = ax.ac;
                }
            } else {
                n.ay(ax.az);

                address ac = c[ax.az];

                if (ac != address(0)) {
                    delete c[ax.az];
                    delete b[ac];
                }
            }

            emit SetTokenAllowedStatus(ax.az, ax.ac, ax.ar);
        }
    }


    function ah() external view returns (bytes memory o) {
        o = abi.at(u, l, as, au, aa());
    }
}