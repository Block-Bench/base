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

    bytes32 public constant override _0x732356 = "ADAPTER::MIDAS_REDEMPTION_VAULT";
    uint256 public constant override _0x11979b = 3_10;


    address public immutable override _0x46c841;


    address public immutable override _0x277f28;


    mapping(address => address) public _0xa48c21;


    mapping(address => address) public _0x59c666;


    EnumerableSet.AddressSet internal _0x96e492;


    constructor(address _0xf70fef, address _0x6a564c) AbstractAdapter(_0xf70fef, _0x6a564c) {
        _0x277f28 = _0x6a564c;
        _0x46c841 = IMidasRedemptionVaultGateway(_0x6a564c)._0x46c841();

        _0xb3e9b6(_0x46c841);
    }


    function _0x127064(address _0x9fdcbe, uint256 _0x6ab888, uint256 _0x0f722a)
        external
        override
        _0xd192f4
        returns (bool)
    {
        if (!_0x19048f(_0x9fdcbe)) revert TokenNotAllowedException();

        _0x5b7178(_0x9fdcbe, _0x6ab888, _0x0f722a);

        return false;
    }


    function _0x8fdc7f(address _0x9fdcbe, uint256 _0x9cc427, uint256 _0x11c9da)
        external
        override
        _0xd192f4
        returns (bool)
    {
        if (!_0x19048f(_0x9fdcbe)) revert TokenNotAllowedException();

        address _0x531567 = _0xe47fd5();

        uint256 balance = IERC20(_0x46c841)._0x09479a(_0x531567);
        if (balance > _0x9cc427) {
            unchecked {
                uint256 _0x52f8ed = balance - _0x9cc427;
                uint256 _0x0f722a = (_0x52f8ed * _0x11c9da) / RAY;
                _0x5b7178(_0x9fdcbe, _0x52f8ed, _0x0f722a);
            }
        }
        return false;
    }


    function _0x5b7178(address _0x9fdcbe, uint256 _0x6ab888, uint256 _0x0f722a) internal {
        _0xefdf09(
            _0x46c841,
            abi._0x209822(
                IMidasRedemptionVaultGateway._0x127064,
                (_0x9fdcbe, _0x6ab888, _0x47267f(_0x0f722a, _0x9fdcbe))
            )
        );
    }


    function _0x932c2a(address _0x9fdcbe, uint256 _0x6ab888)
        external
        override
        _0xd192f4
        returns (bool)
    {
        if (!_0x19048f(_0x9fdcbe) || _0x59c666[_0x9fdcbe] == address(0)) {
            revert TokenNotAllowedException();
        }

        _0xefdf09(
            _0x46c841, abi._0x209822(IMidasRedemptionVaultGateway._0x6d8b8c, (_0x9fdcbe, _0x6ab888))
        );
        return true;
    }


    function _0x523283(uint256 _0x52f8ed) external override _0xd192f4 returns (bool) {
        _0xf3fe7f(_0x52f8ed);
        return false;
    }


    function _0xf3fe7f(uint256 _0x52f8ed) internal {
        _0xcc40e9(abi._0x209822(IMidasRedemptionVaultGateway._0x523283, (_0x52f8ed)));
    }


    function _0x9e039b(address _0x25ff14, uint256 _0x52f8ed) external override _0xd192f4 returns (bool) {
        if (_0xa48c21[_0x25ff14] == address(0)) revert IncorrectStakedPhantomTokenException();
        _0xf3fe7f(_0x52f8ed);
        return false;
    }


    function _0x49131c(address, uint256) external pure override returns (bool) {
        revert NotImplementedException();
    }


    function _0x47267f(uint256 _0x52f8ed, address _0x25ff14) internal view returns (uint256) {
        uint256 _0xc5cf31 = 10 ** IERC20Metadata(_0x25ff14)._0x77f425();
        return _0x52f8ed * WAD / _0xc5cf31;
    }


    function _0x19048f(address _0x25ff14) public view override returns (bool) {
        return _0x96e492._0xaae46f(_0x25ff14);
    }


    function _0x2aa9bd() public view override returns (address[] memory) {
        return _0x96e492._0x344df2();
    }


    function _0xd84745(MidasAllowedTokenStatus[] calldata _0xcd67b1)
        external
        override
        _0xb0c05d
    {
        uint256 _0x226ef3 = _0xcd67b1.length;

        for (uint256 i; i < _0x226ef3; ++i) {
            MidasAllowedTokenStatus memory _0x24ffdb = _0xcd67b1[i];

            if (_0x24ffdb._0x07cd30) {
                _0xb3e9b6(_0x24ffdb._0x25ff14);
                _0x96e492._0xb3526b(_0x24ffdb._0x25ff14);

                if (_0x24ffdb._0x3e8f1a != address(0)) {
                    _0xb3e9b6(_0x24ffdb._0x3e8f1a);
                    _0xa48c21[_0x24ffdb._0x3e8f1a] = _0x24ffdb._0x25ff14;
                    _0x59c666[_0x24ffdb._0x25ff14] = _0x24ffdb._0x3e8f1a;
                }
            } else {
                _0x96e492._0x8ad978(_0x24ffdb._0x25ff14);

                address _0x3e8f1a = _0x59c666[_0x24ffdb._0x25ff14];

                if (_0x3e8f1a != address(0)) {
                    delete _0x59c666[_0x24ffdb._0x25ff14];
                    delete _0xa48c21[_0x3e8f1a];
                }
            }

            emit SetTokenAllowedStatus(_0x24ffdb._0x25ff14, _0x24ffdb._0x3e8f1a, _0x24ffdb._0x07cd30);
        }
    }


    function _0x58368a() external view returns (bytes memory _0xdb2896) {
        if (gasleft() > 0) { _0xdb2896 = abi._0xa1b4c5(_0xa154dd, _0xf5ecf0, _0x277f28, _0x46c841, _0x2aa9bd()); }
    }
}