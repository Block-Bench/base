pragma solidity ^0.8.13;

import {ILockManager} from "./interfaces/ILockManager.sol";
import {LockToGovernBase} from "./base/LockToGovernBase.sol";
import {ILockToVote} from "./interfaces/ILockToVote.sol";
import {IDAO} from "@aragon/osx-commons-contracts/src/dao/IDAO.sol";
import {Action} from "@aragon/osx-commons-contracts/src/executors/IExecutor.sol";
import {IPlugin} from "@aragon/osx-commons-contracts/src/plugin/IPlugin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IProposal} from "@aragon/osx-commons-contracts/src/plugin/extensions/proposal/IProposal.sol";
import {ERC165Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165Upgradeable.sol";
import {SafeCastUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {MajorityVotingBase} from "./base/MajorityVotingBase.sol";
import {ILockToGovernBase} from "./interfaces/ILockToGovernBase.sol";

contract LockToVotePlugin is ILockToVote, MajorityVotingBase, LockToGovernBase {
    using SafeCastUpgradeable for uint256;


    bytes4 internal constant LOCK_TO_VOTE_INTERFACE_ID =
        this._0x3b24eb.selector ^ this._0x900f32.selector;


    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0x113034("CREATE_PROPOSAL_PERMISSION");


    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0x113034("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0x5da080, address _0xa06e6d);

    error VoteRemovalForbidden(uint256 _0x5da080, address _0xa06e6d);


    function _0x4b9ad7(
        IDAO _0xd0d0c2,
        ILockManager _0x98767b,
        VotingSettings calldata _0xf56246,
        IPlugin.TargetConfig calldata _0x9bb0cf,
        bytes calldata _0x0485ca
    ) external _0x13e88b _0x9407a3(1) {
        __MajorityVotingBase_init(_0xd0d0c2, _0xf56246, _0x9bb0cf, _0x0485ca);
        __LockToGovernBase_init(_0x98767b);

        emit MembershipContractAnnounced({_0x4c053b: address(_0x98767b._0xf71937())});
    }


    function _0xc48b4f(bytes4 _0x5dbd24)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0x5dbd24 == LOCK_TO_VOTE_INTERFACE_ID || _0x5dbd24 == type(ILockToVote)._0x761d52
            || super._0xc48b4f(_0x5dbd24);
    }


    function _0xdb69ad() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }


    function _0x900f32(
        bytes calldata _0x701706,
        Action[] memory _0x626829,
        uint64 _0x67e5e9,
        uint64 _0x75ff80,
        bytes memory _0x7ab380
    ) external _0xd481dc(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0x5da080) {
        uint256 _0x7b6a2a;

        if (_0x7ab380.length != 0) {
            (_0x7b6a2a) = abi._0xf5cfe9(_0x7ab380, (uint256));
        }

        if (_0x539fd9() == 0) {
            revert NoVotingPower();
        }


        (_0x67e5e9, _0x75ff80) = _0xe8a8cf(_0x67e5e9, _0x75ff80);

        _0x5da080 = _0x8e536d(_0x113034(abi._0x357749(_0x626829, _0x701706)));

        if (_0x00f4d0(_0x5da080)) {
            revert ProposalAlreadyExists(_0x5da080);
        }


        Proposal storage _0x76e389 = _0x02fa14[_0x5da080];

        _0x76e389._0x04f007._0x4eaf05 = _0x4eaf05();
        _0x76e389._0x04f007._0x09ec1f = _0x09ec1f();
        _0x76e389._0x04f007._0x6808b6 = _0x67e5e9;
        _0x76e389._0x04f007._0xb786c5 = _0x75ff80;
        _0x76e389._0x04f007._0x3f0169 = _0x3f0169();
        _0x76e389._0x04f007._0x8f428f = _0x8f428f();

        _0x76e389._0x6af5de = _0x90d331();


        if (_0x7b6a2a != 0) {
            _0x76e389._0x6d01f3 = _0x7b6a2a;
        }

        for (uint256 i; i < _0x626829.length;) {
            _0x76e389._0xc41d83.push(_0x626829[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0x5da080, _0xa2593d(), _0x67e5e9, _0x75ff80, _0x701706, _0x626829, _0x7b6a2a);

        _0xc6006b._0x5aa3ce(_0x5da080);
    }


    function _0x190e0b(uint256 _0xa0d9cf, address _0x72cf12, VoteOption _0x0c42d6) public view returns (bool) {
        if (!_0x00f4d0(_0xa0d9cf)) {
            revert NonexistentProposal(_0xa0d9cf);
        }

        Proposal storage _0x76e389 = _0x02fa14[_0xa0d9cf];
        return _0x96354c(_0x76e389, _0x72cf12, _0x0c42d6, _0xc6006b._0x3e8f7d(_0x72cf12));
    }


    function _0xee8f98(uint256 _0xa0d9cf, address _0x72cf12, VoteOption _0x0c42d6, uint256 _0x519ce9)
        public
        override
        _0xd481dc(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x76e389 = _0x02fa14[_0xa0d9cf];

        if (!_0x96354c(_0x76e389, _0x72cf12, _0x0c42d6, _0x519ce9)) {
            revert VoteCastForbidden(_0xa0d9cf, _0x72cf12);
        }


        if (_0x0c42d6 == _0x76e389._0x139c57[_0x72cf12]._0xa9481a) {

            if (_0x519ce9 == _0x76e389._0x139c57[_0x72cf12]._0xf33c96) return;


            uint256 _0x611673 = _0x519ce9 - _0x76e389._0x139c57[_0x72cf12]._0xf33c96;
            _0x76e389._0x139c57[_0x72cf12]._0xf33c96 = _0x519ce9;

            if (_0x76e389._0x139c57[_0x72cf12]._0xa9481a == VoteOption.Yes) {
                _0x76e389._0xc149c7._0x1275a7 += _0x611673;
            } else if (_0x76e389._0x139c57[_0x72cf12]._0xa9481a == VoteOption.No) {
                _0x76e389._0xc149c7._0x14dd52 += _0x611673;
            } else {

                _0x76e389._0xc149c7._0x126215 += _0x611673;
            }
        } else {


            if (_0x76e389._0x139c57[_0x72cf12]._0xf33c96 > 0) {

                if (_0x76e389._0x139c57[_0x72cf12]._0xa9481a == VoteOption.Yes) {
                    _0x76e389._0xc149c7._0x1275a7 -= _0x76e389._0x139c57[_0x72cf12]._0xf33c96;
                } else if (_0x76e389._0x139c57[_0x72cf12]._0xa9481a == VoteOption.No) {
                    _0x76e389._0xc149c7._0x14dd52 -= _0x76e389._0x139c57[_0x72cf12]._0xf33c96;
                } else {

                    _0x76e389._0xc149c7._0x126215 -= _0x76e389._0x139c57[_0x72cf12]._0xf33c96;
                }
            }


            if (_0x0c42d6 == VoteOption.Yes) {
                _0x76e389._0xc149c7._0x1275a7 += _0x519ce9;
            } else if (_0x0c42d6 == VoteOption.No) {
                _0x76e389._0xc149c7._0x14dd52 += _0x519ce9;
            } else {

                _0x76e389._0xc149c7._0x126215 += _0x519ce9;
            }
            _0x76e389._0x139c57[_0x72cf12]._0xa9481a = _0x0c42d6;
            _0x76e389._0x139c57[_0x72cf12]._0xf33c96 = _0x519ce9;
        }

        emit VoteCast(_0xa0d9cf, _0x72cf12, _0x0c42d6, _0x519ce9);

        if (_0x76e389._0x04f007._0x4eaf05 == VotingMode.EarlyExecution) {
            _0xdc7049(_0xa0d9cf, _0xa2593d());
        }
    }


    function _0x2fea95(uint256 _0xa0d9cf, address _0x72cf12) external _0xd481dc(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x76e389 = _0x02fa14[_0xa0d9cf];
        if (!_0xa6306c(_0x76e389)) {
            revert VoteRemovalForbidden(_0xa0d9cf, _0x72cf12);
        } else if (_0x76e389._0x04f007._0x4eaf05 != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0xa0d9cf, _0x72cf12);
        } else if (_0x76e389._0x139c57[_0x72cf12]._0xf33c96 == 0) {

            return;
        }


        if (_0x76e389._0x139c57[_0x72cf12]._0xa9481a == VoteOption.Yes) {
            _0x76e389._0xc149c7._0x1275a7 -= _0x76e389._0x139c57[_0x72cf12]._0xf33c96;
        } else if (_0x76e389._0x139c57[_0x72cf12]._0xa9481a == VoteOption.No) {
            _0x76e389._0xc149c7._0x14dd52 -= _0x76e389._0x139c57[_0x72cf12]._0xf33c96;
        }

        else if (_0x76e389._0x139c57[_0x72cf12]._0xa9481a == VoteOption.Abstain) {
            _0x76e389._0xc149c7._0x126215 -= _0x76e389._0x139c57[_0x72cf12]._0xf33c96;
        }
        _0x76e389._0x139c57[_0x72cf12]._0xf33c96 = 0;

        emit VoteCleared(_0xa0d9cf, _0x72cf12);
    }


    function _0x723e2c(uint256 _0xa0d9cf) external view returns (bool) {
        Proposal storage _0x76e389 = _0x02fa14[_0xa0d9cf];
        return _0xa6306c(_0x76e389);
    }


    function _0x3b24eb() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x3b24eb();
    }


    function _0x539fd9() public view override returns (uint256) {
        return IERC20(_0xc6006b._0xf71937())._0x5e9fc8();
    }


    function _0x8bfff4(uint256 _0xa0d9cf, address _0x72cf12) public view returns (uint256) {
        return _0x02fa14[_0xa0d9cf]._0x139c57[_0x72cf12]._0xf33c96;
    }


    function _0x96354c(Proposal storage _0x76e389, address _0x72cf12, VoteOption _0x0c42d6, uint256 _0x519ce9)
        internal
        view
        returns (bool)
    {
        uint256 _0x52287a = _0x76e389._0x139c57[_0x72cf12]._0xf33c96;


        if (!_0xa6306c(_0x76e389)) {
            return false;
        } else if (_0x0c42d6 == VoteOption.None) {
            return false;
        }

        else if (_0x76e389._0x04f007._0x4eaf05 != VotingMode.VoteReplacement) {

            if (_0x519ce9 <= _0x52287a) {
                return false;
            }

            else if (
                _0x76e389._0x139c57[_0x72cf12]._0xa9481a != VoteOption.None
                    && _0x0c42d6 != _0x76e389._0x139c57[_0x72cf12]._0xa9481a
            ) {
                return false;
            }
        }

        else {

            if (_0x519ce9 == 0 || _0x519ce9 < _0x52287a) {
                return false;
            }

            else if (_0x519ce9 == _0x52287a && _0x0c42d6 == _0x76e389._0x139c57[_0x72cf12]._0xa9481a) {
                return false;
            }
        }

        return true;
    }

    function _0xdc7049(uint256 _0xa0d9cf, address _0x573193) internal {
        if (!_0x6d9a77(_0xa0d9cf)) {
            return;
        } else if (!_0xcf0aca()._0x79e940(address(this), _0x573193, EXECUTE_PROPOSAL_PERMISSION_ID, _0x22d4a6())) {
            return;
        }

        _0x81730d(_0xa0d9cf);
    }

    function _0x81730d(uint256 _0xa0d9cf) internal override {
        super._0x81730d(_0xa0d9cf);


        _0xc6006b._0xfe5ef2(_0xa0d9cf);
    }


    uint256[50] private __gap;
}