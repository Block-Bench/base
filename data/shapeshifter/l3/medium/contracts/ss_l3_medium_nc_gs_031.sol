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
    bool _0xde95bc;
    address _0x41cad9;
    uint8 _0x1ca8fc;
    Attestation _0x3673e3;
  }


  struct DecodedSignature {
    bytes32 _0xf10729;
    address _0x3fdc00;
    address[] _0xe9da3e;
    SessionPermissions[] _0x262088;
    CallSignature[] _0x2d3f15;
  }


  function _0x9add0a(
    Payload.Decoded calldata _0xc36f38,
    bytes calldata _0x6c515b
  ) internal view returns (DecodedSignature memory sig) {
    uint256 _0x8d1332 = 0;
    bool _0x74bff9;


    {

      uint256 _0x113603;
      (_0x113603, _0x8d1332) = _0x6c515b._0xc4a030(_0x8d1332);


      (sig, _0x74bff9) = _0x131c46(_0x6c515b[_0x8d1332:_0x8d1332 + _0x113603]);
      _0x8d1332 += _0x113603;


      if (sig._0x3fdc00 == address(0)) {
        revert SessionErrors.InvalidIdentitySigner();
      }
    }


    Attestation[] memory _0x5ef981;
    {
      uint8 _0x7af2a9;
      (_0x7af2a9, _0x8d1332) = _0x6c515b._0x62be0c(_0x8d1332);
      _0x5ef981 = new Attestation[](_0x7af2a9);

      for (uint256 i = 0; i < _0x7af2a9; i++) {
        Attestation memory _0xad67a7;
        (_0xad67a7, _0x8d1332) = LibAttestation._0x83232d(_0x6c515b, _0x8d1332);


        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0x8d1332) = _0x6c515b._0xf1cf38(_0x8d1332);


          bytes32 _0x22d023 = _0xad67a7._0xc195e8();
          address _0x2b19c2 = _0x5ad469(_0x22d023, v, r, s);
          if (_0x2b19c2 != sig._0x3fdc00) {
            revert SessionErrors.InvalidIdentitySigner();
          }
        }

        _0x5ef981[i] = _0xad67a7;
      }


      if (_0x7af2a9 > 0 && !_0x74bff9) {
        revert SessionErrors.InvalidBlacklist();
      }
    }


    {
      uint256 _0xa6ea03 = _0xc36f38._0x0dc4da.length;
      sig._0x2d3f15 = new CallSignature[](_0xa6ea03);

      for (uint256 i = 0; i < _0xa6ea03; i++) {
        CallSignature memory _0xd7b662;


        {
          uint8 _0xf93727;
          (_0xf93727, _0x8d1332) = _0x6c515b._0x62be0c(_0x8d1332);
          _0xd7b662._0xde95bc = (_0xf93727 & 0x80) != 0;

          if (_0xd7b662._0xde95bc) {

            uint8 _0x37f6cc = uint8(_0xf93727 & 0x7f);


            if (_0x37f6cc >= _0x5ef981.length) {
              revert SessionErrors.InvalidAttestation();
            }


            _0xd7b662._0x3673e3 = _0x5ef981[_0x37f6cc];
          } else {

            _0xd7b662._0x1ca8fc = _0xf93727;
          }
        }


        {
          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0x8d1332) = _0x6c515b._0xf1cf38(_0x8d1332);

          bytes32 _0x8e58b4 = _0x905ff1(_0xc36f38, i);
          _0xd7b662._0x41cad9 = _0x5ad469(_0x8e58b4, v, r, s);
          if (_0xd7b662._0x41cad9 == address(0)) {
            revert SessionErrors.InvalidSessionSigner(address(0));
          }
        }

        sig._0x2d3f15[i] = _0xd7b662;
      }
    }

    return sig;
  }


  function _0x131c46(
    bytes calldata _0xb02d78
  ) internal pure returns (DecodedSignature memory sig, bool _0x9cf568) {
    uint256 _0x8d1332;
    uint256 _0xfdbe0f;


    {
      uint256 _0x600066 = _0xb02d78.length / MIN_ENCODED_PERMISSION_SIZE;
      sig._0x262088 = new SessionPermissions[](_0x600066);
    }

    while (_0x8d1332 < _0xb02d78.length) {

      uint256 _0xe2e41c;
      (_0xe2e41c, _0x8d1332) = _0xb02d78._0x62be0c(_0x8d1332);

      uint256 _0xf93727 = (_0xe2e41c & 0xf0) >> 4;


      if (_0xf93727 == FLAG_PERMISSIONS) {
        SessionPermissions memory _0x1f206c;
        uint256 _0x53875e = _0x8d1332;


        (_0x1f206c._0x6814ba, _0x8d1332) = _0xb02d78._0x6a243f(_0x8d1332);


        (_0x1f206c.chainId, _0x8d1332) = _0xb02d78._0x6e6604(_0x8d1332);


        (_0x1f206c._0x36bdef, _0x8d1332) = _0xb02d78._0x6e6604(_0x8d1332);


        (_0x1f206c._0xae868f, _0x8d1332) = _0xb02d78._0xc92363(_0x8d1332);


        (_0x1f206c._0xc5a922, _0x8d1332) = _0xb62f6f(_0xb02d78, _0x8d1332);


        {
          bytes32 _0x05948a = _0x11328d(_0xb02d78[_0x53875e:_0x8d1332]);
          sig._0xf10729 =
            sig._0xf10729 != bytes32(0) ? LibOptim._0x28a623(sig._0xf10729, _0x05948a) : _0x05948a;
        }


        sig._0x262088[_0xfdbe0f++] = _0x1f206c;
        continue;
      }


      if (_0xf93727 == FLAG_NODE) {

        bytes32 _0x0b38d8;
        (_0x0b38d8, _0x8d1332) = _0xb02d78._0x125f5a(_0x8d1332);


        sig._0xf10729 = sig._0xf10729 != bytes32(0) ? LibOptim._0x28a623(sig._0xf10729, _0x0b38d8) : _0x0b38d8;

        continue;
      }


      if (_0xf93727 == FLAG_BRANCH) {

        uint256 _0x83b149;
        {
          uint256 _0x60c92f = uint8(_0xe2e41c & 0x0f);
          (_0x83b149, _0x8d1332) = _0xb02d78._0xbd5679(_0x8d1332, _0x60c92f);
        }

        uint256 _0xe65e76 = _0x8d1332 + _0x83b149;
        (DecodedSignature memory _0x8b7a63, bool _0x523f3c) = _0x131c46(_0xb02d78[_0x8d1332:_0xe65e76]);
        _0x8d1332 = _0xe65e76;


        if (_0x523f3c) {
          if (_0x9cf568) {

            revert SessionErrors.InvalidBlacklist();
          }
          _0x9cf568 = true;
          sig._0xe9da3e = _0x8b7a63._0xe9da3e;
        }


        if (_0x8b7a63._0x3fdc00 != address(0)) {
          if (sig._0x3fdc00 != address(0)) {

            revert SessionErrors.InvalidIdentitySigner();
          }
          sig._0x3fdc00 = _0x8b7a63._0x3fdc00;
        }


        for (uint256 i = 0; i < _0x8b7a63._0x262088.length; i++) {
          sig._0x262088[_0xfdbe0f++] = _0x8b7a63._0x262088[i];
        }


        sig._0xf10729 =
          sig._0xf10729 != bytes32(0) ? LibOptim._0x28a623(sig._0xf10729, _0x8b7a63._0xf10729) : _0x8b7a63._0xf10729;

        continue;
      }


      if (_0xf93727 == FLAG_BLACKLIST) {
        if (_0x9cf568) {

          revert SessionErrors.InvalidBlacklist();
        }
        _0x9cf568 = true;


        uint256 _0xafc35a = uint256(_0xe2e41c & 0x0f);
        if (_0xafc35a == 0x0f) {

          (_0xafc35a, _0x8d1332) = _0xb02d78._0x8c4e42(_0x8d1332);
        }
        uint256 _0x53875e = _0x8d1332;


        sig._0xe9da3e = new address[](_0xafc35a);
        address _0x460c62;
        for (uint256 i = 0; i < _0xafc35a; i++) {
          (sig._0xe9da3e[i], _0x8d1332) = _0xb02d78._0x6a243f(_0x8d1332);
          if (sig._0xe9da3e[i] < _0x460c62) {
            revert SessionErrors.InvalidBlacklistUnsorted();
          }
          _0x460c62 = sig._0xe9da3e[i];
        }


        bytes32 _0x500a8c = _0x338d22(_0xb02d78[_0x53875e:_0x8d1332]);
        sig._0xf10729 = sig._0xf10729 != bytes32(0) ? LibOptim._0x28a623(sig._0xf10729, _0x500a8c) : _0x500a8c;

        continue;
      }


      if (_0xf93727 == FLAG_IDENTITY_SIGNER) {
        if (sig._0x3fdc00 != address(0)) {

          revert SessionErrors.InvalidIdentitySigner();
        }
        (sig._0x3fdc00, _0x8d1332) = _0xb02d78._0x6a243f(_0x8d1332);


        bytes32 _0x5ce66d = _0xe866f4(sig._0x3fdc00);
        sig._0xf10729 =
          sig._0xf10729 != bytes32(0) ? LibOptim._0x28a623(sig._0xf10729, _0x5ce66d) : _0x5ce66d;

        continue;
      }

      revert SessionErrors.InvalidNodeType(_0xf93727);
    }

    {

      SessionPermissions[] memory _0xc5a922 = sig._0x262088;
      assembly {
        mstore(_0xc5a922, _0xfdbe0f)
      }
    }

    return (sig, _0x9cf568);
  }


  function _0xb62f6f(
    bytes calldata _0xb02d78,
    uint256 _0x8d1332
  ) internal pure returns (Permission[] memory _0xc5a922, uint256 _0xbcf098) {
    uint256 length;
    (length, _0x8d1332) = _0xb02d78._0x62be0c(_0x8d1332);
    _0xc5a922 = new Permission[](length);
    for (uint256 i = 0; i < length; i++) {
      (_0xc5a922[i], _0x8d1332) = LibPermission._0xe3467b(_0xb02d78, _0x8d1332);
    }
    return (_0xc5a922, _0x8d1332);
  }


  function _0x11328d(
    bytes calldata _0xd740c1
  ) internal pure returns (bytes32) {
    return _0x9ef234(abi._0x4074d6(uint8(FLAG_PERMISSIONS), _0xd740c1));
  }


  function _0x338d22(
    bytes calldata _0x79ee85
  ) internal pure returns (bytes32) {
    return _0x9ef234(abi._0x4074d6(uint8(FLAG_BLACKLIST), _0x79ee85));
  }


  function _0xe866f4(
    address _0x3fdc00
  ) internal pure returns (bytes32) {
    return _0x9ef234(abi._0x4074d6(uint8(FLAG_IDENTITY_SIGNER), _0x3fdc00));
  }


  function _0x905ff1(
    Payload.Decoded calldata _0xc36f38,
    uint256 _0x09b81a
  ) public view returns (bytes32 _0x8e58b4) {
    return _0x9ef234(
      abi._0x4074d6(
        _0xc36f38._0xcd8501 ? 0 : block.chainid,
        _0xc36f38._0x4d52ea,
        _0xc36f38._0x29ffa9,
        _0x09b81a,
        Payload._0xa82121(_0xc36f38._0x0dc4da[_0x09b81a])
      )
    );
  }

}