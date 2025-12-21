pragma solidity ^0.8.27;

import { Payload } from "../../modules/Payload.sol";
import { LibBytes } from "../../utils/LibBytes.sol";
import { LibOptim } from "../../utils/LibOptim.sol";
import { SessionErrors } from "./SessionErrors.sol";
import { SessionPermissions } from "./explicit/IExplicitSessionManager.sol";
import { LibPermission, Permission } from "./explicit/Permission.sol";
import { Attestation, LibAttestation } from "./implicit/Attestation.sol";

using LibBytes for bytes;
using LibAttestation for Attestation;


library SessionSig {

  uint256 internal constant FLAG_PERMISSIONS = 0;
  uint256 internal constant FLAG_NODE = 1;
  uint256 internal constant FLAG_BRANCH = 2;
  uint256 internal constant FLAG_BLACKLIST = 3;
  uint256 internal constant FLAG_IDENTITY_SIGNER = 4;

  uint256 internal constant MIN_ENCODED_PERMISSION_SIZE = 94;


  struct CallSignature {
    bool _0x30fa28;
    address _0x030911;
    uint8 _0x79318a;
    Attestation _0x322c3b;
  }


  struct DecodedSignature {
    bytes32 _0x697bf8;
    address _0x2c9a31;
    address[] _0x089804;
    SessionPermissions[] _0xc45713;
    CallSignature[] _0xd05543;
  }


  function _0xf34bbc(
    Payload.Decoded calldata _0xed17c8,
    bytes calldata _0x11aa01
  ) internal view returns (DecodedSignature memory sig) {
    uint256 _0xdeb2e6 = 0;
    bool _0x7bd7a1;


    {

      uint256 _0xac4f30;
      (_0xac4f30, _0xdeb2e6) = _0x11aa01._0x496675(_0xdeb2e6);


      (sig, _0x7bd7a1) = _0x65830f(_0x11aa01[_0xdeb2e6:_0xdeb2e6 + _0xac4f30]);
      _0xdeb2e6 += _0xac4f30;


      if (sig._0x2c9a31 == address(0)) {
        revert SessionErrors.InvalidIdentitySigner();
      }
    }


    Attestation[] memory _0x31ddcd;
    {
      uint8 _0x689e93;
      (_0x689e93, _0xdeb2e6) = _0x11aa01._0xcf2de8(_0xdeb2e6);
      _0x31ddcd = new Attestation[](_0x689e93);

      for (uint256 i = 0; i < _0x689e93; i++) {
        Attestation memory _0x481937;
        (_0x481937, _0xdeb2e6) = LibAttestation._0x0015e4(_0x11aa01, _0xdeb2e6);


        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xdeb2e6) = _0x11aa01._0x06bd70(_0xdeb2e6);


          bytes32 _0x03db27 = _0x481937._0x77f89c();
          address _0x693e50 = _0x6e3f10(_0x03db27, v, r, s);
          if (_0x693e50 != sig._0x2c9a31) {
            revert SessionErrors.InvalidIdentitySigner();
          }
        }

        _0x31ddcd[i] = _0x481937;
      }


      if (_0x689e93 > 0 && !_0x7bd7a1) {
        revert SessionErrors.InvalidBlacklist();
      }
    }


    {
      uint256 _0xa07aad = _0xed17c8._0x954326.length;
      sig._0xd05543 = new CallSignature[](_0xa07aad);

      for (uint256 i = 0; i < _0xa07aad; i++) {
        CallSignature memory _0x27592d;


        {
          uint8 _0xa57b01;
          (_0xa57b01, _0xdeb2e6) = _0x11aa01._0xcf2de8(_0xdeb2e6);
          _0x27592d._0x30fa28 = (_0xa57b01 & 0x80) != 0;

          if (_0x27592d._0x30fa28) {

            uint8 _0xf6396d = uint8(_0xa57b01 & 0x7f);


            if (_0xf6396d >= _0x31ddcd.length) {
              revert SessionErrors.InvalidAttestation();
            }


            _0x27592d._0x322c3b = _0x31ddcd[_0xf6396d];
          } else {

            _0x27592d._0x79318a = _0xa57b01;
          }
        }


        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0xdeb2e6) = _0x11aa01._0x06bd70(_0xdeb2e6);

          bytes32 _0x593cf0 = _0x107573(_0xed17c8, i);
          _0x27592d._0x030911 = _0x6e3f10(_0x593cf0, v, r, s);
          if (_0x27592d._0x030911 == address(0)) {
            revert SessionErrors.InvalidSessionSigner(address(0));
          }
        }

        sig._0xd05543[i] = _0x27592d;
      }
    }

    return sig;
  }


  function _0x65830f(
    bytes calldata _0xfb29fa
  ) internal pure returns (DecodedSignature memory sig, bool _0xe395ba) {
    uint256 _0xdeb2e6;
    uint256 _0x352daf;


    {
      uint256 _0xc290be = _0xfb29fa.length / MIN_ENCODED_PERMISSION_SIZE;
      sig._0xc45713 = new SessionPermissions[](_0xc290be);
    }

    while (_0xdeb2e6 < _0xfb29fa.length) {

      uint256 _0x741774;
      (_0x741774, _0xdeb2e6) = _0xfb29fa._0xcf2de8(_0xdeb2e6);

      uint256 _0xa57b01 = (_0x741774 & 0xf0) >> 4;


      if (_0xa57b01 == FLAG_PERMISSIONS) {
        SessionPermissions memory _0x1b090b;
        uint256 _0x44c66f = _0xdeb2e6;


        (_0x1b090b._0x72fdf8, _0xdeb2e6) = _0xfb29fa._0x7b868f(_0xdeb2e6);


        (_0x1b090b.chainId, _0xdeb2e6) = _0xfb29fa._0x451a61(_0xdeb2e6);


        (_0x1b090b._0x30c145, _0xdeb2e6) = _0xfb29fa._0x451a61(_0xdeb2e6);


        (_0x1b090b._0x94923b, _0xdeb2e6) = _0xfb29fa._0xf9fbb2(_0xdeb2e6);


        (_0x1b090b._0x8ef3b5, _0xdeb2e6) = _0x67cf0b(_0xfb29fa, _0xdeb2e6);


        {
          bytes32 _0x206b3c = _0x77bedf(_0xfb29fa[_0x44c66f:_0xdeb2e6]);
          sig._0x697bf8 =
            sig._0x697bf8 != bytes32(0) ? LibOptim._0x4bee35(sig._0x697bf8, _0x206b3c) : _0x206b3c;
        }


        sig._0xc45713[_0x352daf++] = _0x1b090b;
        continue;
      }


      if (_0xa57b01 == FLAG_NODE) {

        bytes32 _0x5f1a3e;
        (_0x5f1a3e, _0xdeb2e6) = _0xfb29fa._0x63bdfa(_0xdeb2e6);


        sig._0x697bf8 = sig._0x697bf8 != bytes32(0) ? LibOptim._0x4bee35(sig._0x697bf8, _0x5f1a3e) : _0x5f1a3e;

        continue;
      }


      if (_0xa57b01 == FLAG_BRANCH) {

        uint256 _0x820631;
        {
          uint256 _0x3985ce = uint8(_0x741774 & 0x0f);
          (_0x820631, _0xdeb2e6) = _0xfb29fa._0x120bbd(_0xdeb2e6, _0x3985ce);
        }

        uint256 _0x20ab9a = _0xdeb2e6 + _0x820631;
        (DecodedSignature memory _0xaf932a, bool _0x3b9146) = _0x65830f(_0xfb29fa[_0xdeb2e6:_0x20ab9a]);
        _0xdeb2e6 = _0x20ab9a;


        if (_0x3b9146) {
          if (_0xe395ba) {

            revert SessionErrors.InvalidBlacklist();
          }
          _0xe395ba = true;
          sig._0x089804 = _0xaf932a._0x089804;
        }


        if (_0xaf932a._0x2c9a31 != address(0)) {
          if (sig._0x2c9a31 != address(0)) {

            revert SessionErrors.InvalidIdentitySigner();
          }
          sig._0x2c9a31 = _0xaf932a._0x2c9a31;
        }


        for (uint256 i = 0; i < _0xaf932a._0xc45713.length; i++) {
          sig._0xc45713[_0x352daf++] = _0xaf932a._0xc45713[i];
        }


        sig._0x697bf8 =
          sig._0x697bf8 != bytes32(0) ? LibOptim._0x4bee35(sig._0x697bf8, _0xaf932a._0x697bf8) : _0xaf932a._0x697bf8;

        continue;
      }


      if (_0xa57b01 == FLAG_BLACKLIST) {
        if (_0xe395ba) {

          revert SessionErrors.InvalidBlacklist();
        }
        _0xe395ba = true;


        uint256 _0x7f6955 = uint256(_0x741774 & 0x0f);
        if (_0x7f6955 == 0x0f) {

          (_0x7f6955, _0xdeb2e6) = _0xfb29fa._0xa85aa6(_0xdeb2e6);
        }
        uint256 _0x44c66f = _0xdeb2e6;


        sig._0x089804 = new address[](_0x7f6955);
        address _0x87e477;
        for (uint256 i = 0; i < _0x7f6955; i++) {
          (sig._0x089804[i], _0xdeb2e6) = _0xfb29fa._0x7b868f(_0xdeb2e6);
          if (sig._0x089804[i] < _0x87e477) {
            revert SessionErrors.InvalidBlacklistUnsorted();
          }
          _0x87e477 = sig._0x089804[i];
        }


        bytes32 _0x7888da = _0xb9a294(_0xfb29fa[_0x44c66f:_0xdeb2e6]);
        sig._0x697bf8 = sig._0x697bf8 != bytes32(0) ? LibOptim._0x4bee35(sig._0x697bf8, _0x7888da) : _0x7888da;

        continue;
      }


      if (_0xa57b01 == FLAG_IDENTITY_SIGNER) {
        if (sig._0x2c9a31 != address(0)) {

          revert SessionErrors.InvalidIdentitySigner();
        }
        (sig._0x2c9a31, _0xdeb2e6) = _0xfb29fa._0x7b868f(_0xdeb2e6);


        bytes32 _0x753786 = _0x7e2f43(sig._0x2c9a31);
        sig._0x697bf8 =
          sig._0x697bf8 != bytes32(0) ? LibOptim._0x4bee35(sig._0x697bf8, _0x753786) : _0x753786;

        continue;
      }

      revert SessionErrors.InvalidNodeType(_0xa57b01);
    }

    {

      SessionPermissions[] memory _0x8ef3b5 = sig._0xc45713;
      assembly {
        mstore(_0x8ef3b5, _0x352daf)
      }
    }

    return (sig, _0xe395ba);
  }


  function _0x67cf0b(
    bytes calldata _0xfb29fa,
    uint256 _0xdeb2e6
  ) internal pure returns (Permission[] memory _0x8ef3b5, uint256 _0xf62b16) {
    uint256 length;
    (length, _0xdeb2e6) = _0xfb29fa._0xcf2de8(_0xdeb2e6);
    _0x8ef3b5 = new Permission[](length);
    for (uint256 i = 0; i < length; i++) {
      (_0x8ef3b5[i], _0xdeb2e6) = LibPermission._0xad1703(_0xfb29fa, _0xdeb2e6);
    }
    return (_0x8ef3b5, _0xdeb2e6);
  }


  function _0x77bedf(
    bytes calldata _0x476579
  ) internal pure returns (bytes32) {
    return _0x732aa6(abi._0x3621e3(uint8(FLAG_PERMISSIONS), _0x476579));
  }


  function _0xb9a294(
    bytes calldata _0x1a6fb1
  ) internal pure returns (bytes32) {
    return _0x732aa6(abi._0x3621e3(uint8(FLAG_BLACKLIST), _0x1a6fb1));
  }


  function _0x7e2f43(
    address _0x2c9a31
  ) internal pure returns (bytes32) {
    return _0x732aa6(abi._0x3621e3(uint8(FLAG_IDENTITY_SIGNER), _0x2c9a31));
  }


  function _0x107573(
    Payload.Decoded calldata _0xed17c8,
    uint256 _0xd988e4
  ) public view returns (bytes32 _0x593cf0) {
    return _0x732aa6(
      abi._0x3621e3(
        _0xed17c8._0x49d0b0 ? 0 : block.chainid,
        _0xed17c8._0xd568ed,
        _0xed17c8._0x0668eb,
        _0xd988e4,
        Payload._0xb3ca9c(_0xed17c8._0x954326[_0xd988e4])
      )
    );
  }

}