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

    bytes32 public constant override ac = "ADAPTER::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override ap = 3_10;


    address public immutable override au;


    address public immutable override as;


    mapping(address => address) public c;


    mapping(address => address) public b;


    EnumerableSet.AddressSet internal m;


    constructor(address p, address al) AbstractAdapter(p, al) {
        as = al;
        au = IMidasRedemptionVaultGateway(al).au();

        i(au);
    }


    function z(address am, uint256 t, uint256 j)
        external
        override
        k
        returns (bool)
    {
        if (!n(am)) revert TokenNotAllowedException();

        o(am, t, j);

        return false;
    }


    function g(address am, uint256 q, uint256 ae)
        external
        override
        k
        returns (bool)
    {
        if (!n(am)) revert TokenNotAllowedException();

        address y = r();

        uint256 balance = IERC20(au).ag(y);
        if (balance > q) {
            unchecked {
                uint256 av = balance - q;
                uint256 j = (av * ae) / RAY;
                o(am, av, j);
            }
        }
        return false;
    }


    function o(address am, uint256 t, uint256 j) internal {
        d(
            au,
            abi.ad(
                IMidasRedemptionVaultGateway.z,
                (am, t, v(j, am))
            )
        );
    }


    function u(address am, uint256 t)
        external
        override
        k
        returns (bool)
    {
        if (!n(am) || b[am] == address(0)) {
            revert TokenNotAllowedException();
        }

        d(
            au, abi.ad(IMidasRedemptionVaultGateway.aa, (am, t))
        );
        return true;
    }


    function aj(uint256 av) external override k returns (bool) {
        af(av);
        return false;
    }


    function af(uint256 av) internal {
        ao(abi.ad(IMidasRedemptionVaultGateway.aj, (av)));
    }


    function e(address az, uint256 av) external override k returns (bool) {
        if (c[az] == address(0)) revert IncorrectStakedPhantomTokenException();
        af(av);
        return false;
    }


    function f(address, uint256) external pure override returns (bool) {
        revert NotImplementedException();
    }


    function v(uint256 av, address az) internal view returns (uint256) {
        uint256 ah = 10 ** IERC20Metadata(az).ak();
        return av * WAD / ah;
    }


    function n(address az) public view override returns (bool) {
        return m.an(az);
    }


    function w() public view override returns (address[] memory) {
        return m.ay();
    }


    function a(MidasAllowedTokenStatus[] calldata aq)
        external
        override
        h
    {
        uint256 ba = aq.length;

        for (uint256 i; i < ba; ++i) {
            MidasAllowedTokenStatus memory ax = aq[i];

            if (ax.ar) {
                i(ax.az);
                m.bb(ax.az);

                if (ax.ab != address(0)) {
                    i(ax.ab);
                    c[ax.ab] = ax.az;
                    b[ax.az] = ax.ab;
                }
            } else {
                m.aw(ax.az);

                address ab = b[ax.az];

                if (ab != address(0)) {
                    delete b[ax.az];
                    delete c[ab];
                }
            }

            emit SetTokenAllowedStatus(ax.az, ax.ab, ax.ar);
        }
    }


    function ai() external view returns (bytes memory l) {
        l = abi.at(x, s, as, au, w());
    }
}