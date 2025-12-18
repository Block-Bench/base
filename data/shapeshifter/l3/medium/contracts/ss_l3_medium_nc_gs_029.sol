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


  error LowWeightChainedSignature(bytes _0x7319f8, uint256 _0xc2a8fb, uint256 _0x17e9c3);

  error InvalidERC1271Signature(bytes32 _0x7fc82c, address _0x57c263, bytes _0x7319f8);

  error WrongChainedCheckpointOrder(uint256 _0xd0d545, uint256 _0x16564f);

  error UnusedSnapshot(Snapshot _0xceef8f);

  error InvalidSignatureFlag(uint256 _0x607d8f);

  function _0x5d2bd0(address _0xd2cc0c, uint256 _0x17e9c3) internal pure returns (bytes32) {
    return _0xe12075(abi._0x17d9a1("Sequence signer:\n", _0xd2cc0c, _0x17e9c3));
  }

  function _0x5ae656(bytes32 _0x0dcd84, uint256 _0xc2a8fb, uint256 _0x17e9c3) internal pure returns (bytes32) {
    return _0xe12075(abi._0x17d9a1("Sequence nested config:\n", _0x0dcd84, _0xc2a8fb, _0x17e9c3));
  }

  function _0xbb2cfd(address _0xd2cc0c, uint256 _0x17e9c3, bytes32 _0x141173) internal pure returns (bytes32) {
    return _0xe12075(abi._0x17d9a1("Sequence sapient config:\n", _0xd2cc0c, _0x17e9c3, _0x141173));
  }

  function _0x91e238(
    bytes32 _0x044424
  ) internal pure returns (bytes32) {
    return _0xe12075(abi._0x17d9a1("Sequence static digest:\n", _0x044424));
  }

  function _0x9dfeb0(
    bytes32 _0xf819f6
  ) internal pure returns (bytes32) {
    return _0xe12075(abi._0x17d9a1("Sequence any address subdigest:\n", _0xf819f6));
  }

  function _0xba4c70(
    Payload.Decoded memory _0xdbbfa4,
    bytes calldata _0x7319f8,
    bool _0x02460c,
    address _0x0e2b9a
  ) internal view returns (uint256 _0xd64fa6, uint256 _0xb716fe, bytes32 _0x681937, uint256 _0x4acced, bytes32 _0x1b1f40) {

    (uint256 _0x588ce0, uint256 _0x74ffd1) = _0x7319f8._0x3d081c();


    Snapshot memory _0x9b890e;


    if (_0x588ce0 & 0x40 == 0x40 && _0x0e2b9a == address(0)) {


      (_0x0e2b9a, _0x74ffd1) = _0x7319f8._0xe0e6e3(_0x74ffd1);

      if (!_0x02460c) {

        uint256 _0x495820;
        (_0x495820, _0x74ffd1) = _0x7319f8._0x0fb28f(_0x74ffd1);


        bytes memory _0x413117 = _0x7319f8[_0x74ffd1:_0x74ffd1 + _0x495820];


        _0x9b890e = ICheckpointer(_0x0e2b9a)._0xa80e48(address(this), _0x413117);

        _0x74ffd1 += _0x495820;
      }
    }


    if (_0x588ce0 & 0x01 == 0x01) {
      return _0x11cabc(_0xdbbfa4, _0x0e2b9a, _0x9b890e, _0x7319f8[_0x74ffd1:]);
    }


    _0xdbbfa4._0xede620 = _0x588ce0 & 0x02 == 0x02;

    {

      uint256 _0x681b40 = (_0x588ce0 & 0x1c) >> 2;
      (_0x4acced, _0x74ffd1) = _0x7319f8._0x4fdfcb(_0x74ffd1, _0x681b40);
    }


    {
      uint256 _0x4c1013 = ((_0x588ce0 & 0x20) >> 5) + 1;
      (_0xd64fa6, _0x74ffd1) = _0x7319f8._0x4fdfcb(_0x74ffd1, _0x4c1013);
    }


    _0x1b1f40 = _0xdbbfa4._0xee5e4c();
    (_0xb716fe, _0x681937) = _0xe3dd1d(_0xdbbfa4, _0x1b1f40, _0x7319f8[_0x74ffd1:]);

    _0x681937 = LibOptim._0xf4c358(_0x681937, bytes32(_0xd64fa6));
    _0x681937 = LibOptim._0xf4c358(_0x681937, bytes32(_0x4acced));
    _0x681937 = LibOptim._0xf4c358(_0x681937, bytes32(uint256(uint160(_0x0e2b9a))));


    if (_0x9b890e._0x681937 != bytes32(0) && _0x9b890e._0x681937 != _0x681937 && _0x4acced <= _0x9b890e._0x4acced) {
      revert UnusedSnapshot(_0x9b890e);
    }
  }

  function _0x11cabc(
    Payload.Decoded memory _0xdbbfa4,
    address _0x0e2b9a,
    Snapshot memory _0xceef8f,
    bytes calldata _0x7319f8
  ) internal view returns (uint256 _0xd64fa6, uint256 _0xb716fe, bytes32 _0x681937, uint256 _0x4acced, bytes32 _0x1b1f40) {
    Payload.Decoded memory _0x9c327e;
    _0x9c327e._0xa0e7bb = Payload.KIND_CONFIG_UPDATE;

    uint256 _0x74ffd1;
    uint256 _0x40791d = type(uint256)._0x1249ab;

    while (_0x74ffd1 < _0x7319f8.length) {
      uint256 _0x24dbfc;

      {
        uint256 _0xacf8f6;
        (_0xacf8f6, _0x74ffd1) = _0x7319f8._0x0fb28f(_0x74ffd1);
        _0x24dbfc = _0xacf8f6 + _0x74ffd1;
      }

      address _0x63d771 = _0x24dbfc == _0x7319f8.length ? _0x0e2b9a : address(0);

      if (_0x40791d == type(uint256)._0x1249ab) {
        (_0xd64fa6, _0xb716fe, _0x681937, _0x4acced, _0x1b1f40) =
          _0xba4c70(_0xdbbfa4, _0x7319f8[_0x74ffd1:_0x24dbfc], true, _0x63d771);
      } else {
        (_0xd64fa6, _0xb716fe, _0x681937, _0x4acced,) =
          _0xba4c70(_0x9c327e, _0x7319f8[_0x74ffd1:_0x24dbfc], true, _0x63d771);
      }

      if (_0xb716fe < _0xd64fa6) {
        revert LowWeightChainedSignature(_0x7319f8[_0x74ffd1:_0x24dbfc], _0xd64fa6, _0xb716fe);
      }
      _0x74ffd1 = _0x24dbfc;

      if (_0xceef8f._0x681937 == _0x681937) {
        _0xceef8f._0x681937 = bytes32(0);
      }

      if (_0x4acced >= _0x40791d) {
        revert WrongChainedCheckpointOrder(_0x4acced, _0x40791d);
      }

      _0x9c327e._0x681937 = _0x681937;
      _0x40791d = _0x4acced;
    }

    if (_0xceef8f._0x681937 != bytes32(0) && _0x4acced <= _0xceef8f._0x4acced) {
      revert UnusedSnapshot(_0xceef8f);
    }
  }

  function _0xe3dd1d(
    Payload.Decoded memory _0xdbbfa4,
    bytes32 _0x7fc82c,
    bytes calldata _0x7319f8
  ) internal view returns (uint256 _0xb716fe, bytes32 _0xfc76eb) {
    unchecked {
      uint256 _0x74ffd1;


      while (_0x74ffd1 < _0x7319f8.length) {


        uint256 _0x918272;
        (_0x918272, _0x74ffd1) = _0x7319f8._0x718fd8(_0x74ffd1);


        uint256 _0xbf9046 = (_0x918272 & 0xf0) >> 4;


        if (_0xbf9046 == FLAG_SIGNATURE_HASH) {


          uint8 _0x29ea00 = uint8(_0x918272 & 0x0f);
          if (_0x29ea00 == 0) {
            (_0x29ea00, _0x74ffd1) = _0x7319f8._0x718fd8(_0x74ffd1);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0x74ffd1) = _0x7319f8._0x196757(_0x74ffd1);

          address _0x3ac542 = _0xc1d6bf(_0x7fc82c, v, r, s);

          _0xb716fe += _0x29ea00;
          bytes32 _0xfcf99b = _0x5d2bd0(_0x3ac542, _0x29ea00);
          _0xfc76eb = _0xfc76eb != bytes32(0) ? LibOptim._0xf4c358(_0xfc76eb, _0xfcf99b) : _0xfcf99b;
          continue;
        }


        if (_0xbf9046 == FLAG_ADDRESS) {


          uint8 _0x29ea00 = uint8(_0x918272 & 0x0f);
          if (_0x29ea00 == 0) {
            (_0x29ea00, _0x74ffd1) = _0x7319f8._0x718fd8(_0x74ffd1);
          }


          address _0x3ac542;
          (_0x3ac542, _0x74ffd1) = _0x7319f8._0xe0e6e3(_0x74ffd1);


          bytes32 _0xfcf99b = _0x5d2bd0(_0x3ac542, _0x29ea00);
          _0xfc76eb = _0xfc76eb != bytes32(0) ? LibOptim._0xf4c358(_0xfc76eb, _0xfcf99b) : _0xfcf99b;
          continue;
        }


        if (_0xbf9046 == FLAG_SIGNATURE_ERC1271) {


          uint8 _0x29ea00 = uint8(_0x918272 & 0x03);
          if (_0x29ea00 == 0) {
            (_0x29ea00, _0x74ffd1) = _0x7319f8._0x718fd8(_0x74ffd1);
          }


          address _0x3ac542;
          (_0x3ac542, _0x74ffd1) = _0x7319f8._0xe0e6e3(_0x74ffd1);


          uint256 _0xaff96b = uint8(_0x918272 & 0x0c) >> 2;
          uint256 _0xf9f1f4;
          (_0xf9f1f4, _0x74ffd1) = _0x7319f8._0x4fdfcb(_0x74ffd1, _0xaff96b);


          uint256 _0x24dbfc = _0x74ffd1 + _0xf9f1f4;


          if (IERC1271(_0x3ac542)._0xf1a1f7(_0x7fc82c, _0x7319f8[_0x74ffd1:_0x24dbfc]) != IERC1271_MAGIC_VALUE_HASH) {
            revert InvalidERC1271Signature(_0x7fc82c, _0x3ac542, _0x7319f8[_0x74ffd1:_0x24dbfc]);
          }
          _0x74ffd1 = _0x24dbfc;

          _0xb716fe += _0x29ea00;
          bytes32 _0xfcf99b = _0x5d2bd0(_0x3ac542, _0x29ea00);
          _0xfc76eb = _0xfc76eb != bytes32(0) ? LibOptim._0xf4c358(_0xfc76eb, _0xfcf99b) : _0xfcf99b;
          continue;
        }


        if (_0xbf9046 == FLAG_NODE) {


          bytes32 _0xfcf99b;
          (_0xfcf99b, _0x74ffd1) = _0x7319f8._0xa31dff(_0x74ffd1);
          _0xfc76eb = _0xfc76eb != bytes32(0) ? LibOptim._0xf4c358(_0xfc76eb, _0xfcf99b) : _0xfcf99b;
          continue;
        }


        if (_0xbf9046 == FLAG_BRANCH) {


          uint256 _0xaff96b = uint8(_0x918272 & 0x0f);
          uint256 _0xf9f1f4;
          (_0xf9f1f4, _0x74ffd1) = _0x7319f8._0x4fdfcb(_0x74ffd1, _0xaff96b);


          uint256 _0x24dbfc = _0x74ffd1 + _0xf9f1f4;

          (uint256 _0xa32526, bytes32 _0xfcf99b) = _0xe3dd1d(_0xdbbfa4, _0x7fc82c, _0x7319f8[_0x74ffd1:_0x24dbfc]);
          _0x74ffd1 = _0x24dbfc;

          _0xb716fe += _0xa32526;
          _0xfc76eb = LibOptim._0xf4c358(_0xfc76eb, _0xfcf99b);
          continue;
        }


        if (_0xbf9046 == FLAG_NESTED) {


          uint256 _0xe925a3 = uint8(_0x918272 & 0x0c) >> 2;
          if (_0xe925a3 == 0) {
            (_0xe925a3, _0x74ffd1) = _0x7319f8._0x718fd8(_0x74ffd1);
          }

          uint256 _0x4771dd = uint8(_0x918272 & 0x03);
          if (_0x4771dd == 0) {
            (_0x4771dd, _0x74ffd1) = _0x7319f8._0x47814a(_0x74ffd1);
          }

          uint256 _0xf9f1f4;
          (_0xf9f1f4, _0x74ffd1) = _0x7319f8._0x0fb28f(_0x74ffd1);
          uint256 _0x24dbfc = _0x74ffd1 + _0xf9f1f4;

          (uint256 _0x35ecec, bytes32 _0x1f96e8) = _0xe3dd1d(_0xdbbfa4, _0x7fc82c, _0x7319f8[_0x74ffd1:_0x24dbfc]);
          _0x74ffd1 = _0x24dbfc;

          if (_0x35ecec >= _0x4771dd) {
            _0xb716fe += _0xe925a3;
          }

          bytes32 _0xfcf99b = _0x5ae656(_0x1f96e8, _0x4771dd, _0xe925a3);
          _0xfc76eb = _0xfc76eb != bytes32(0) ? LibOptim._0xf4c358(_0xfc76eb, _0xfcf99b) : _0xfcf99b;
          continue;
        }


        if (_0xbf9046 == FLAG_SUBDIGEST) {


          bytes32 _0x46e996;
          (_0x46e996, _0x74ffd1) = _0x7319f8._0xa31dff(_0x74ffd1);
          if (_0x46e996 == _0x7fc82c) {
            _0xb716fe = type(uint256)._0x1249ab;
          }

          bytes32 _0xfcf99b = _0x91e238(_0x46e996);
          _0xfc76eb = _0xfc76eb != bytes32(0) ? LibOptim._0xf4c358(_0xfc76eb, _0xfcf99b) : _0xfcf99b;
          continue;
        }


        if (_0xbf9046 == FLAG_SIGNATURE_ETH_SIGN) {


          uint8 _0x29ea00 = uint8(_0x918272 & 0x0f);
          if (_0x29ea00 == 0) {
            (_0x29ea00, _0x74ffd1) = _0x7319f8._0x718fd8(_0x74ffd1);
          }

          bytes32 r;
          bytes32 s;
          uint8 v;
          (r, s, v, _0x74ffd1) = _0x7319f8._0x196757(_0x74ffd1);

          address _0x3ac542 = _0xc1d6bf(_0xe12075(abi._0x17d9a1("\x19Ethereum Signed Message:\n32", _0x7fc82c)), v, r, s);

          _0xb716fe += _0x29ea00;
          bytes32 _0xfcf99b = _0x5d2bd0(_0x3ac542, _0x29ea00);
          _0xfc76eb = _0xfc76eb != bytes32(0) ? LibOptim._0xf4c358(_0xfc76eb, _0xfcf99b) : _0xfcf99b;
          continue;
        }


        if (_0xbf9046 == FLAG_SIGNATURE_ANY_ADDRESS_SUBDIGEST) {


          bytes32 _0x46e996;
          (_0x46e996, _0x74ffd1) = _0x7319f8._0xa31dff(_0x74ffd1);
          bytes32 _0x03edf4 = _0xdbbfa4._0xec0dce(address(0));
          if (_0x46e996 == _0x03edf4) {
            _0xb716fe = type(uint256)._0x1249ab;
          }

          bytes32 _0xfcf99b = _0x9dfeb0(_0x46e996);
          _0xfc76eb = _0xfc76eb != bytes32(0) ? LibOptim._0xf4c358(_0xfc76eb, _0xfcf99b) : _0xfcf99b;
          continue;
        }


        if (_0xbf9046 == FLAG_SIGNATURE_SAPIENT) {


          uint8 _0x29ea00 = uint8(_0x918272 & 0x03);
          if (_0x29ea00 == 0) {
            (_0x29ea00, _0x74ffd1) = _0x7319f8._0x718fd8(_0x74ffd1);
          }

          address _0x3ac542;
          (_0x3ac542, _0x74ffd1) = _0x7319f8._0xe0e6e3(_0x74ffd1);


          uint256 _0xf9f1f4;
          {
            uint256 _0xaff96b = uint8(_0x918272 & 0x0c) >> 2;
            (_0xf9f1f4, _0x74ffd1) = _0x7319f8._0x4fdfcb(_0x74ffd1, _0xaff96b);
          }


          uint256 _0x24dbfc = _0x74ffd1 + _0xf9f1f4;


          bytes32 _0xe378d5 = ISapient(_0x3ac542)._0x09ce03(_0xdbbfa4, _0x7319f8[_0x74ffd1:_0x24dbfc]);
          _0x74ffd1 = _0x24dbfc;


          _0xb716fe += _0x29ea00;
          bytes32 _0xfcf99b = _0xbb2cfd(_0x3ac542, _0x29ea00, _0xe378d5);
          _0xfc76eb = _0xfc76eb != bytes32(0) ? LibOptim._0xf4c358(_0xfc76eb, _0xfcf99b) : _0xfcf99b;
          continue;
        }


        if (_0xbf9046 == FLAG_SIGNATURE_SAPIENT_COMPACT) {


          uint8 _0x29ea00 = uint8(_0x918272 & 0x03);
          if (_0x29ea00 == 0) {
            (_0x29ea00, _0x74ffd1) = _0x7319f8._0x718fd8(_0x74ffd1);
          }

          address _0x3ac542;
          (_0x3ac542, _0x74ffd1) = _0x7319f8._0xe0e6e3(_0x74ffd1);


          uint256 _0xaff96b = uint8(_0x918272 & 0x0c) >> 2;
          uint256 _0xf9f1f4;
          (_0xf9f1f4, _0x74ffd1) = _0x7319f8._0x4fdfcb(_0x74ffd1, _0xaff96b);


          uint256 _0x24dbfc = _0x74ffd1 + _0xf9f1f4;


          bytes32 _0xe378d5 =
            ISapientCompact(_0x3ac542)._0xe92b11(_0x7fc82c, _0x7319f8[_0x74ffd1:_0x24dbfc]);
          _0x74ffd1 = _0x24dbfc;

          _0xb716fe += _0x29ea00;
          bytes32 _0xfcf99b = _0xbb2cfd(_0x3ac542, _0x29ea00, _0xe378d5);
          _0xfc76eb = _0xfc76eb != bytes32(0) ? LibOptim._0xf4c358(_0xfc76eb, _0xfcf99b) : _0xfcf99b;
          continue;
        }

        revert InvalidSignatureFlag(_0xbf9046);
      }
    }
  }

}