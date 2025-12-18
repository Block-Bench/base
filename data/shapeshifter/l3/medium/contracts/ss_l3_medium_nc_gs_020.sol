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

    bytes32 public constant override _0x0151dd = "ADAPTER::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override _0x66d8de = 3_10;


    address public immutable override _0x10746f;


    address public immutable override _0x39bb1d;


    mapping(address => address) public _0xb6b597;


    mapping(address => address) public _0xe9a8cf;


    EnumerableSet.AddressSet internal _0xe48037;


    constructor(address _0x878afd, address _0x176bf9) AbstractAdapter(_0x878afd, _0x176bf9) {
        _0x39bb1d = _0x176bf9;
        _0x10746f = IMidasRedemptionVaultGateway(_0x176bf9)._0x10746f();

        _0x37ecc4(_0x10746f);
    }


    function _0x37a7c9(address _0x3da561, uint256 _0x3eb62b, uint256 _0xed0063)
        external
        override
        _0x07c91d
        returns (bool)
    {
        if (!_0x0daf4f(_0x3da561)) revert TokenNotAllowedException();

        _0xbfdace(_0x3da561, _0x3eb62b, _0xed0063);

        return false;
    }


    function _0x4e3e78(address _0x3da561, uint256 _0x068da5, uint256 _0x734b85)
        external
        override
        _0x07c91d
        returns (bool)
    {
        if (!_0x0daf4f(_0x3da561)) revert TokenNotAllowedException();

        address _0xbce334 = _0x78d77c();

        uint256 balance = IERC20(_0x10746f)._0x4dcc21(_0xbce334);
        if (balance > _0x068da5) {
            unchecked {
                uint256 _0x49c04b = balance - _0x068da5;
                uint256 _0xed0063 = (_0x49c04b * _0x734b85) / RAY;
                _0xbfdace(_0x3da561, _0x49c04b, _0xed0063);
            }
        }
        return false;
    }


    function _0xbfdace(address _0x3da561, uint256 _0x3eb62b, uint256 _0xed0063) internal {
        _0x8647e3(
            _0x10746f,
            abi._0xb9990d(
                IMidasRedemptionVaultGateway._0x37a7c9,
                (_0x3da561, _0x3eb62b, _0xf4f8c8(_0xed0063, _0x3da561))
            )
        );
    }


    function _0x2e57a4(address _0x3da561, uint256 _0x3eb62b)
        external
        override
        _0x07c91d
        returns (bool)
    {
        if (!_0x0daf4f(_0x3da561) || _0xe9a8cf[_0x3da561] == address(0)) {
            revert TokenNotAllowedException();
        }

        _0x8647e3(
            _0x10746f, abi._0xb9990d(IMidasRedemptionVaultGateway._0x810377, (_0x3da561, _0x3eb62b))
        );
        return true;
    }


    function _0x663658(uint256 _0x49c04b) external override _0x07c91d returns (bool) {
        _0xc953d4(_0x49c04b);
        return false;
    }


    function _0xc953d4(uint256 _0x49c04b) internal {
        _0x02ea80(abi._0xb9990d(IMidasRedemptionVaultGateway._0x663658, (_0x49c04b)));
    }


    function _0x922299(address _0x193d73, uint256 _0x49c04b) external override _0x07c91d returns (bool) {
        if (_0xb6b597[_0x193d73] == address(0)) revert IncorrectStakedPhantomTokenException();
        _0xc953d4(_0x49c04b);
        return false;
    }


    function _0x8b6e8d(address, uint256) external pure override returns (bool) {
        revert NotImplementedException();
    }


    function _0xf4f8c8(uint256 _0x49c04b, address _0x193d73) internal view returns (uint256) {
        uint256 _0x063794 = 10 ** IERC20Metadata(_0x193d73)._0x1af76c();
        return _0x49c04b * WAD / _0x063794;
    }


    function _0x0daf4f(address _0x193d73) public view override returns (bool) {
        return _0xe48037._0x21106c(_0x193d73);
    }


    function _0x92c27a() public view override returns (address[] memory) {
        return _0xe48037._0x6d43ce();
    }


    function _0xcc9706(MidasAllowedTokenStatus[] calldata _0x8cc03b)
        external
        override
        _0x3c09b6
    {
        uint256 _0x61f67b = _0x8cc03b.length;

        for (uint256 i; i < _0x61f67b; ++i) {
            MidasAllowedTokenStatus memory _0xf1931e = _0x8cc03b[i];

            if (_0xf1931e._0x32e856) {
                _0x37ecc4(_0xf1931e._0x193d73);
                _0xe48037._0x6a6f30(_0xf1931e._0x193d73);

                if (_0xf1931e._0x67d3f0 != address(0)) {
                    _0x37ecc4(_0xf1931e._0x67d3f0);
                    _0xb6b597[_0xf1931e._0x67d3f0] = _0xf1931e._0x193d73;
                    _0xe9a8cf[_0xf1931e._0x193d73] = _0xf1931e._0x67d3f0;
                }
            } else {
                _0xe48037._0x234dcb(_0xf1931e._0x193d73);

                address _0x67d3f0 = _0xe9a8cf[_0xf1931e._0x193d73];

                if (_0x67d3f0 != address(0)) {
                    delete _0xe9a8cf[_0xf1931e._0x193d73];
                    delete _0xb6b597[_0x67d3f0];
                }
            }

            emit SetTokenAllowedStatus(_0xf1931e._0x193d73, _0xf1931e._0x67d3f0, _0xf1931e._0x32e856);
        }
    }


    function _0x1b4c89() external view returns (bytes memory _0x69cdf7) {
        if (msg.sender != address(0) || msg.sender == address(0)) { _0x69cdf7 = abi._0x961c5e(_0x73f484, _0xb4345f, _0x39bb1d, _0x10746f, _0x92c27a()); }
    }
}