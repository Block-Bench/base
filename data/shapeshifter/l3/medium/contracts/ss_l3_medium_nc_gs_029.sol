pragma solidity ^0.8.27;

import { LibBytes } from "../../utils/LibBytes.sol";
import { LibOptim } from "../../utils/LibOptim.sol";
import { Payload } from "../Payload.sol";

import { ICheckpointer, Snapshot } from "../interfaces/ICheckpointer.sol";
import { IERC1271, IERC1271_MAGIC_VALUE_HASH } from "../interfaces/IERC1271.sol";
import { ISapient, ISapientCompact } from "../interfaces/ISapient.sol";

using LibBytes for bytes;
using Payload for Payload.Decoded;


library BaseSig {

  uint256 internal constant FLAG_SIGNATURE_HASH = 0;
  uint256 internal constant FLAG_ADDRESS = 1;
  uint256 internal constant FLAG_SIGNATURE_ERC1271 = 2;
  uint256 internal constant FLAG_NODE = 3;
  uint256 internal constant FLAG_BRANCH = 4;
  uint256 internal constant FLAG_SUBDIGEST = 5;
  uint256 internal constant FLAG_NESTED = 6;
  uint256 internal constant FLAG_SIGNATURE_ETH_SIGN = 7;
  uint256 internal constant FLAG_SIGNATURE_ANY_ADDRESS_SUBDIGEST = 8;
  uint256 internal constant FLAG_SIGNATURE_SAPIENT = 9;
  uint256 internal constant FLAG_SIGNATURE_SAPIENT_COMPACT = 10;


  error LowWeightChainedSignature(bytes _0xb1eb5a, uint256 _0xac1ce7, uint256 _0x52c9e5);

  error InvalidERC1271Signature(bytes32 _0xcbe659, address _0xcb6ddb, bytes _0xb1eb5a);

  error WrongChainedCheckpointOrder(uint256 _0xf36d62, uint256 _0x6be0f3);

  error UnusedSnapshot(Snapshot _0x38708e);

  error InvalidSignatureFlag(uint256 _0x4b2f8e);

  function _0x5c6207(address _0x13d7b8, uint256 _0x52c9e5) internal pure returns (bytes32) {
    return _0xda2471(abi._0xa300a4("Sequence signer:\n", _0x13d7b8, _0x52c9e5));
  }

  function _0xed9a6f(bytes32 _0x6ef57f, uint256 _0xac1ce7, uint256 _0x52c9e5) internal pure returns (bytes32) {
    return _0xda2471(abi._0xa300a4("Sequence nested config:\n", _0x6ef57f, _0xac1ce7, _0x52c9e5));
  }

  function _0x44a00c(address _0x13d7b8, uint256 _0x52c9e5, bytes32 _0x7581da) internal pure returns (bytes32) {
    return _0xda2471(abi._0xa300a4("Sequence sapient config:\n", _0x13d7b8, _0x52c9e5, _0x7581da));
  }

  function _0x481225(
    bytes32 _0xa1cdfb
  ) internal pure returns (bytes32) {
    return _0xda2471(abi._0xa300a4("Sequence static digest:\n", _0xa1cdfb));
  }

  function _0x073340(
    bytes32 _0x8285f0
  ) internal pure returns (bytes32) {
    return _0xda2471(abi._0xa300a4("Sequence any address subdigest:\n", _0x8285f0));
  }

  function _0xbe1154(
    Payload.Decoded memory _0x403d04,
    bytes calldata _0xb1eb5a,
    bool _0x4080b6,
    address _0x5025ac
  ) internal view returns (uint256 _0x73495a, uint256 _0x360649, bytes32 _0xae0b57, uint256 _0xa2c14a, bytes32 _0xe652a1) {

    (uint256 _0x060b09, uint256 _0x97031c) = _0xb1eb5a._0x8b7054();


    Snapshot memory _0x5e8f8f;


    if (_0x060b09 & 0x40 == 0x40 && _0x5025ac == address(0)) {


      (_0x5025ac, _0x97031c) = _0xb1eb5a._0x6e10a7(_0x97031c);

      if (!_0x4080b6) {

        uint256 _0xd4617e;
        (_0xd4617e, _0x97031c) = _0xb1eb5a._0xf28e4b(_0x97031c);


        bytes memory _0xf2ef79 = _0xb1eb5a[_0x97031c:_0x97031c + _0xd4617e];


        _0x5e8f8f = ICheckpointer(_0x5025ac)._0xbf4dc2(address(this), _0xf2ef79);

        _0x97031c += _0xd4617e;
      }
    }


    if (_0x060b09 & 0x01 == 0x01) {
      return _0x5555f5(_0x403d04, _0x5025ac, _0x5e8f8f, _0xb1eb5a[_0x97031c:]);
    }


    _0x403d04._0x2be713 = _0x060b09 & 0x02 == 0x02;

    {

      uint256 _0xfce6fd = (_0x060b09 & 0x1c) >> 2;
      (_0xa2c14a, _0x97031c) = _0xb1eb5a._0x937971(_0x97031c, _0xfce6fd);
    }


    {
      uint256 _0xfe6906 = ((_0x060b09 & 0x20) >> 5) + 1;
      (_0x73495a, _0x97031c) = _0xb1eb5a._0x937971(_0x97031c, _0xfe6906);
    }


    _0xe652a1 = _0x403d04._0x870950();
    (_0x360649, _0xae0b57) = _0x04dd5b(_0x403d04, _0xe652a1, _0xb1eb5a[_0x97031c:]);

    _0xae0b57 = LibOptim._0x04ba0d(_0xae0b57, bytes32(_0x73495a));
    _0xae0b57 = LibOptim._0x04ba0d(_0xae0b57, bytes32(_0xa2c14a));
    _0xae0b57 = LibOptim._0x04ba0d(_0xae0b57, bytes32(uint256(uint160(_0x5025ac))));


    if (_0x5e8f8f._0xae0b57 != bytes32(0) && _0x5e8f8f._0xae0b57 != _0xae0b57 && _0xa2c14a <= _0x5e8f8f._0xa2c14a) {
      revert UnusedSnapshot(_0x5e8f8f);
    }
  }

  function _0x5555f5(
    Payload.Decoded memory _0x403d04,
    address _0x5025ac,
    Snapshot memory _0x38708e,
    bytes calldata _0xb1eb5a
  ) internal view returns (uint256 _0x73495a, uint256 _0x360649, bytes32 _0xae0b57, uint256 _0xa2c14a, bytes32 _0xe652a1) {
    Payload.Decoded memory _0x1bcf31;
    _0x1bcf31._0x9f5efb = Payload.KIND_CONFIG_UPDATE;

    uint256 _0x97031c;
    uint256 _0xf73029 = type(uint256)._0x56e29c;

    while (_0x97031c < _0xb1eb5a.length) {
      uint256 _0x79ab36;

      {
        uint256 _0xb3f891;
        (_0xb3f891, _0x97031c) = _0xb1eb5a._0xf28e4b(_0x97031c);
        _0x79ab36 = _0xb3f891 + _0x97031c;
      }

      address _0xbf1242 = _0x79ab36 == _0xb1eb5a.length ? _0x5025ac : address(0);

      if (_0xf73029 == type(uint256)._0x56e29c) {
        (_0x73495a, _0x360649, _0xae0b57, _0xa2c14a, _0xe652a1) =
          _0xbe1154(_0x403d04, _0xb1eb5a[_0x97031c:_0x79ab36], true, _0xbf1242);
      } else {
        (_0x73495a, _0x360649, _0xae0b57, _0xa2c14a,) =
          _0xbe1154(_0x1bcf31, _0xb1eb5a[_0x97031c:_0x79ab36], true, _0xbf1242);
      }

      if (_0x360649 < _0x73495a) {
        revert LowWeightChainedSignature(_0xb1eb5a[_0x97031c:_0x79ab36], _0x73495a, _0x360649);
      }
      _0x97031c = _0x79ab36;

      if (_0x38708e._0xae0b57 == _0xae0b57) {
        _0x38708e._0xae0b57 = bytes32(0);
      }

      if (_0xa2c14a >= _0xf73029) {
        revert WrongChainedCheckpointOrder(_0xa2c14a, _0xf73029);
      }

      _0x1bcf31._0xae0b57 = _0xae0b57;
      _0xf73029 = _0xa2c14a;
    }

    if (_0x38708e._0xae0b57 != bytes32(0) && _0xa2c14a <= _0x38708e._0xa2c14a) {
      revert UnusedSnapshot(_0x38708e);
    }
  }

  function _0x04dd5b(
    Payload.Decoded memory _0x403d04,
    bytes32 _0xcbe659,
    bytes calldata _0xb1eb5a
  ) internal view returns (uint256 _0x360649, bytes32 _0xe09dff) {
    unchecked {
      uint256 _0x97031c;


      while (_0x97031c < _0xb1eb5a.length) {


        uint256 _0xc5cd48;
        (_0xc5cd48, _0x97031c) = _0xb1eb5a._0xa6aaa4(_0x97031c);


        uint256 _0x93bcc3 = (_0xc5cd48 & 0xf0) >> 4;


        if (_0x93bcc3 == FLAG_SIGNATURE_HASH) {


          uint8 _0xeb31dd = uint8(_0xc5cd48 & 0x0f);
          if (_0xeb31dd == 0) {
            (_0xeb31dd, _0x97031c) = _0xb1eb5a._0xa6aaa4(_0x97031c);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0x97031c) = _0xb1eb5a._0x74a72d(_0x97031c);

          address _0xdedbea = _0x0247f9(_0xcbe659, v, r, s);

          _0x360649 += _0xeb31dd;
          bytes32 _0x96e2ac = _0x5c6207(_0xdedbea, _0xeb31dd);
          _0xe09dff = _0xe09dff != bytes32(0) ? LibOptim._0x04ba0d(_0xe09dff, _0x96e2ac) : _0x96e2ac;
          continue;
        }


        if (_0x93bcc3 == FLAG_ADDRESS) {


          uint8 _0xeb31dd = uint8(_0xc5cd48 & 0x0f);
          if (_0xeb31dd == 0) {
            (_0xeb31dd, _0x97031c) = _0xb1eb5a._0xa6aaa4(_0x97031c);
          }


          address _0xdedbea;
          (_0xdedbea, _0x97031c) = _0xb1eb5a._0x6e10a7(_0x97031c);


          bytes32 _0x96e2ac = _0x5c6207(_0xdedbea, _0xeb31dd);
          _0xe09dff = _0xe09dff != bytes32(0) ? LibOptim._0x04ba0d(_0xe09dff, _0x96e2ac) : _0x96e2ac;
          continue;
        }


        if (_0x93bcc3 == FLAG_SIGNATURE_ERC1271) {


          uint8 _0xeb31dd = uint8(_0xc5cd48 & 0x03);
          if (_0xeb31dd == 0) {
            (_0xeb31dd, _0x97031c) = _0xb1eb5a._0xa6aaa4(_0x97031c);
          }


          address _0xdedbea;
          (_0xdedbea, _0x97031c) = _0xb1eb5a._0x6e10a7(_0x97031c);


          uint256 _0xc747d4 = uint8(_0xc5cd48 & 0x0c) >> 2;
          uint256 _0xecfdd8;
          (_0xecfdd8, _0x97031c) = _0xb1eb5a._0x937971(_0x97031c, _0xc747d4);


          uint256 _0x79ab36 = _0x97031c + _0xecfdd8;


          if (IERC1271(_0xdedbea)._0xf1ece8(_0xcbe659, _0xb1eb5a[_0x97031c:_0x79ab36]) != IERC1271_MAGIC_VALUE_HASH) {
            revert InvalidERC1271Signature(_0xcbe659, _0xdedbea, _0xb1eb5a[_0x97031c:_0x79ab36]);
          }
          _0x97031c = _0x79ab36;

          _0x360649 += _0xeb31dd;
          bytes32 _0x96e2ac = _0x5c6207(_0xdedbea, _0xeb31dd);
          _0xe09dff = _0xe09dff != bytes32(0) ? LibOptim._0x04ba0d(_0xe09dff, _0x96e2ac) : _0x96e2ac;
          continue;
        }


        if (_0x93bcc3 == FLAG_NODE) {


          bytes32 _0x96e2ac;
          (_0x96e2ac, _0x97031c) = _0xb1eb5a._0x92dcde(_0x97031c);
          _0xe09dff = _0xe09dff != bytes32(0) ? LibOptim._0x04ba0d(_0xe09dff, _0x96e2ac) : _0x96e2ac;
          continue;
        }


        if (_0x93bcc3 == FLAG_BRANCH) {


          uint256 _0xc747d4 = uint8(_0xc5cd48 & 0x0f);
          uint256 _0xecfdd8;
          (_0xecfdd8, _0x97031c) = _0xb1eb5a._0x937971(_0x97031c, _0xc747d4);


          uint256 _0x79ab36 = _0x97031c + _0xecfdd8;

          (uint256 _0x46a37d, bytes32 _0x96e2ac) = _0x04dd5b(_0x403d04, _0xcbe659, _0xb1eb5a[_0x97031c:_0x79ab36]);
          _0x97031c = _0x79ab36;

          _0x360649 += _0x46a37d;
          _0xe09dff = LibOptim._0x04ba0d(_0xe09dff, _0x96e2ac);
          continue;
        }


        if (_0x93bcc3 == FLAG_NESTED) {


          uint256 _0x3c083d = uint8(_0xc5cd48 & 0x0c) >> 2;
          if (_0x3c083d == 0) {
            (_0x3c083d, _0x97031c) = _0xb1eb5a._0xa6aaa4(_0x97031c);
          }

          uint256 _0x32b41d = uint8(_0xc5cd48 & 0x03);
          if (_0x32b41d == 0) {
            (_0x32b41d, _0x97031c) = _0xb1eb5a._0xe28fa7(_0x97031c);
          }

          uint256 _0xecfdd8;
          (_0xecfdd8, _0x97031c) = _0xb1eb5a._0xf28e4b(_0x97031c);
          uint256 _0x79ab36 = _0x97031c + _0xecfdd8;

          (uint256 _0xf06bf5, bytes32 _0x0bd117) = _0x04dd5b(_0x403d04, _0xcbe659, _0xb1eb5a[_0x97031c:_0x79ab36]);
          _0x97031c = _0x79ab36;

          if (_0xf06bf5 >= _0x32b41d) {
            _0x360649 += _0x3c083d;
          }

          bytes32 _0x96e2ac = _0xed9a6f(_0x0bd117, _0x32b41d, _0x3c083d);
          _0xe09dff = _0xe09dff != bytes32(0) ? LibOptim._0x04ba0d(_0xe09dff, _0x96e2ac) : _0x96e2ac;
          continue;
        }


        if (_0x93bcc3 == FLAG_SUBDIGEST) {


          bytes32 _0x05224d;
          (_0x05224d, _0x97031c) = _0xb1eb5a._0x92dcde(_0x97031c);
          if (_0x05224d == _0xcbe659) {
            _0x360649 = type(uint256)._0x56e29c;
          }

          bytes32 _0x96e2ac = _0x481225(_0x05224d);
          _0xe09dff = _0xe09dff != bytes32(0) ? LibOptim._0x04ba0d(_0xe09dff, _0x96e2ac) : _0x96e2ac;
          continue;
        }


        if (_0x93bcc3 == FLAG_SIGNATURE_ETH_SIGN) {


          uint8 _0xeb31dd = uint8(_0xc5cd48 & 0x0f);
          if (_0xeb31dd == 0) {
            (_0xeb31dd, _0x97031c) = _0xb1eb5a._0xa6aaa4(_0x97031c);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0x97031c) = _0xb1eb5a._0x74a72d(_0x97031c);

          address _0xdedbea = _0x0247f9(_0xda2471(abi._0xa300a4("\x19Ethereum Signed Message:\n32", _0xcbe659)), v, r, s);

          _0x360649 += _0xeb31dd;
          bytes32 _0x96e2ac = _0x5c6207(_0xdedbea, _0xeb31dd);
          _0xe09dff = _0xe09dff != bytes32(0) ? LibOptim._0x04ba0d(_0xe09dff, _0x96e2ac) : _0x96e2ac;
          continue;
        }


        if (_0x93bcc3 == FLAG_SIGNATURE_ANY_ADDRESS_SUBDIGEST) {


          bytes32 _0x05224d;
          (_0x05224d, _0x97031c) = _0xb1eb5a._0x92dcde(_0x97031c);
          bytes32 _0xefa18e = _0x403d04._0xbe8da2(address(0));
          if (_0x05224d == _0xefa18e) {
            _0x360649 = type(uint256)._0x56e29c;
          }

          bytes32 _0x96e2ac = _0x073340(_0x05224d);
          _0xe09dff = _0xe09dff != bytes32(0) ? LibOptim._0x04ba0d(_0xe09dff, _0x96e2ac) : _0x96e2ac;
          continue;
        }


        if (_0x93bcc3 == FLAG_SIGNATURE_SAPIENT) {


          uint8 _0xeb31dd = uint8(_0xc5cd48 & 0x03);
          if (_0xeb31dd == 0) {
            (_0xeb31dd, _0x97031c) = _0xb1eb5a._0xa6aaa4(_0x97031c);
          }

          address _0xdedbea;
          (_0xdedbea, _0x97031c) = _0xb1eb5a._0x6e10a7(_0x97031c);


          uint256 _0xecfdd8;
          {
            uint256 _0xc747d4 = uint8(_0xc5cd48 & 0x0c) >> 2;
            (_0xecfdd8, _0x97031c) = _0xb1eb5a._0x937971(_0x97031c, _0xc747d4);
          }


          uint256 _0x79ab36 = _0x97031c + _0xecfdd8;


          bytes32 _0x2df693 = ISapient(_0xdedbea)._0xd49dd5(_0x403d04, _0xb1eb5a[_0x97031c:_0x79ab36]);
          _0x97031c = _0x79ab36;


          _0x360649 += _0xeb31dd;
          bytes32 _0x96e2ac = _0x44a00c(_0xdedbea, _0xeb31dd, _0x2df693);
          _0xe09dff = _0xe09dff != bytes32(0) ? LibOptim._0x04ba0d(_0xe09dff, _0x96e2ac) : _0x96e2ac;
          continue;
        }


        if (_0x93bcc3 == FLAG_SIGNATURE_SAPIENT_COMPACT) {


          uint8 _0xeb31dd = uint8(_0xc5cd48 & 0x03);
          if (_0xeb31dd == 0) {
            (_0xeb31dd, _0x97031c) = _0xb1eb5a._0xa6aaa4(_0x97031c);
          }

          address _0xdedbea;
          (_0xdedbea, _0x97031c) = _0xb1eb5a._0x6e10a7(_0x97031c);


          uint256 _0xc747d4 = uint8(_0xc5cd48 & 0x0c) >> 2;
          uint256 _0xecfdd8;
          (_0xecfdd8, _0x97031c) = _0xb1eb5a._0x937971(_0x97031c, _0xc747d4);


          uint256 _0x79ab36 = _0x97031c + _0xecfdd8;


          bytes32 _0x2df693 =
            ISapientCompact(_0xdedbea)._0xa6c83d(_0xcbe659, _0xb1eb5a[_0x97031c:_0x79ab36]);
          _0x97031c = _0x79ab36;

          _0x360649 += _0xeb31dd;
          bytes32 _0x96e2ac = _0x44a00c(_0xdedbea, _0xeb31dd, _0x2df693);
          _0xe09dff = _0xe09dff != bytes32(0) ? LibOptim._0x04ba0d(_0xe09dff, _0x96e2ac) : _0x96e2ac;
          continue;
        }

        revert InvalidSignatureFlag(_0x93bcc3);
      }
    }
  }

}