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
        this._0x7c1b21.selector ^ this._0x266f1f.selector;


    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0xd7736b("CREATE_PROPOSAL_PERMISSION");


    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0xd7736b("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0x585094, address _0x6357eb);

    error VoteRemovalForbidden(uint256 _0x585094, address _0x6357eb);


    function _0x3c43d8(
        IDAO _0x7c4941,
        ILockManager _0x9a7b1f,
        VotingSettings calldata _0x084530,
        IPlugin.TargetConfig calldata _0x34e29d,
        bytes calldata _0xf48287
    ) external _0x4400c0 _0x434c63(1) {
        __MajorityVotingBase_init(_0x7c4941, _0x084530, _0x34e29d, _0xf48287);
        __LockToGovernBase_init(_0x9a7b1f);

        emit MembershipContractAnnounced({_0x07be87: address(_0x9a7b1f._0xfad7b1())});
    }


    function _0x9a8901(bytes4 _0xb72613)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0xb72613 == LOCK_TO_VOTE_INTERFACE_ID || _0xb72613 == type(ILockToVote)._0x0ac61d
            || super._0x9a8901(_0xb72613);
    }


    function _0xc05529() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }


    function _0x266f1f(
        bytes calldata _0x066aea,
        Action[] memory _0x13859d,
        uint64 _0xf0ff82,
        uint64 _0x5b87bc,
        bytes memory _0xb5d3f2
    ) external _0x69611f(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0x585094) {
        uint256 _0x40867f;

        if (_0xb5d3f2.length != 0) {
            (_0x40867f) = abi._0x1e5331(_0xb5d3f2, (uint256));
        }

        if (_0x5af4ab() == 0) {
            revert NoVotingPower();
        }


        (_0xf0ff82, _0x5b87bc) = _0xbdaf24(_0xf0ff82, _0x5b87bc);

        _0x585094 = _0x07d960(_0xd7736b(abi._0x63f8a5(_0x13859d, _0x066aea)));

        if (_0x5275a6(_0x585094)) {
            revert ProposalAlreadyExists(_0x585094);
        }


        Proposal storage _0x2b038e = _0x350d1b[_0x585094];

        _0x2b038e._0x32efd7._0x38750c = _0x38750c();
        _0x2b038e._0x32efd7._0x49bae6 = _0x49bae6();
        _0x2b038e._0x32efd7._0x738bb1 = _0xf0ff82;
        _0x2b038e._0x32efd7._0x1d1424 = _0x5b87bc;
        _0x2b038e._0x32efd7._0x48b41a = _0x48b41a();
        _0x2b038e._0x32efd7._0x098034 = _0x098034();

        _0x2b038e._0x9564bb = _0x1b6a47();


        if (_0x40867f != 0) {
            _0x2b038e._0xba6e90 = _0x40867f;
        }

        for (uint256 i; i < _0x13859d.length;) {
            _0x2b038e._0x0e2ffa.push(_0x13859d[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0x585094, _0xe7f1d1(), _0xf0ff82, _0x5b87bc, _0x066aea, _0x13859d, _0x40867f);

        _0xb22aa6._0x881221(_0x585094);
    }


    function _0xdf263d(uint256 _0x9a2e0a, address _0x0599b8, VoteOption _0x731621) public view returns (bool) {
        if (!_0x5275a6(_0x9a2e0a)) {
            revert NonexistentProposal(_0x9a2e0a);
        }

        Proposal storage _0x2b038e = _0x350d1b[_0x9a2e0a];
        return _0x389068(_0x2b038e, _0x0599b8, _0x731621, _0xb22aa6._0x4b76b9(_0x0599b8));
    }


    function _0xc1792d(uint256 _0x9a2e0a, address _0x0599b8, VoteOption _0x731621, uint256 _0x591781)
        public
        override
        _0x69611f(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x2b038e = _0x350d1b[_0x9a2e0a];

        if (!_0x389068(_0x2b038e, _0x0599b8, _0x731621, _0x591781)) {
            revert VoteCastForbidden(_0x9a2e0a, _0x0599b8);
        }


        if (_0x731621 == _0x2b038e._0x89cdd3[_0x0599b8]._0x399aa4) {

            if (_0x591781 == _0x2b038e._0x89cdd3[_0x0599b8]._0x79855c) return;


            uint256 _0x9ce3f4 = _0x591781 - _0x2b038e._0x89cdd3[_0x0599b8]._0x79855c;
            _0x2b038e._0x89cdd3[_0x0599b8]._0x79855c = _0x591781;

            if (_0x2b038e._0x89cdd3[_0x0599b8]._0x399aa4 == VoteOption.Yes) {
                _0x2b038e._0xf2f4fb._0xc4088c += _0x9ce3f4;
            } else if (_0x2b038e._0x89cdd3[_0x0599b8]._0x399aa4 == VoteOption.No) {
                _0x2b038e._0xf2f4fb._0xb38a11 += _0x9ce3f4;
            } else {

                _0x2b038e._0xf2f4fb._0x7e8660 += _0x9ce3f4;
            }
        } else {


            if (_0x2b038e._0x89cdd3[_0x0599b8]._0x79855c > 0) {

                if (_0x2b038e._0x89cdd3[_0x0599b8]._0x399aa4 == VoteOption.Yes) {
                    _0x2b038e._0xf2f4fb._0xc4088c -= _0x2b038e._0x89cdd3[_0x0599b8]._0x79855c;
                } else if (_0x2b038e._0x89cdd3[_0x0599b8]._0x399aa4 == VoteOption.No) {
                    _0x2b038e._0xf2f4fb._0xb38a11 -= _0x2b038e._0x89cdd3[_0x0599b8]._0x79855c;
                } else {

                    _0x2b038e._0xf2f4fb._0x7e8660 -= _0x2b038e._0x89cdd3[_0x0599b8]._0x79855c;
                }
            }


            if (_0x731621 == VoteOption.Yes) {
                _0x2b038e._0xf2f4fb._0xc4088c += _0x591781;
            } else if (_0x731621 == VoteOption.No) {
                _0x2b038e._0xf2f4fb._0xb38a11 += _0x591781;
            } else {

                _0x2b038e._0xf2f4fb._0x7e8660 += _0x591781;
            }
            _0x2b038e._0x89cdd3[_0x0599b8]._0x399aa4 = _0x731621;
            _0x2b038e._0x89cdd3[_0x0599b8]._0x79855c = _0x591781;
        }

        emit VoteCast(_0x9a2e0a, _0x0599b8, _0x731621, _0x591781);

        if (_0x2b038e._0x32efd7._0x38750c == VotingMode.EarlyExecution) {
            _0xc126ef(_0x9a2e0a, _0xe7f1d1());
        }
    }


    function _0xaeda22(uint256 _0x9a2e0a, address _0x0599b8) external _0x69611f(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x2b038e = _0x350d1b[_0x9a2e0a];
        if (!_0x7c66e3(_0x2b038e)) {
            revert VoteRemovalForbidden(_0x9a2e0a, _0x0599b8);
        } else if (_0x2b038e._0x32efd7._0x38750c != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0x9a2e0a, _0x0599b8);
        } else if (_0x2b038e._0x89cdd3[_0x0599b8]._0x79855c == 0) {

            return;
        }


        if (_0x2b038e._0x89cdd3[_0x0599b8]._0x399aa4 == VoteOption.Yes) {
            _0x2b038e._0xf2f4fb._0xc4088c -= _0x2b038e._0x89cdd3[_0x0599b8]._0x79855c;
        } else if (_0x2b038e._0x89cdd3[_0x0599b8]._0x399aa4 == VoteOption.No) {
            _0x2b038e._0xf2f4fb._0xb38a11 -= _0x2b038e._0x89cdd3[_0x0599b8]._0x79855c;
        }

        else if (_0x2b038e._0x89cdd3[_0x0599b8]._0x399aa4 == VoteOption.Abstain) {
            _0x2b038e._0xf2f4fb._0x7e8660 -= _0x2b038e._0x89cdd3[_0x0599b8]._0x79855c;
        }
        _0x2b038e._0x89cdd3[_0x0599b8]._0x79855c = 0;

        emit VoteCleared(_0x9a2e0a, _0x0599b8);
    }


    function _0x9024ac(uint256 _0x9a2e0a) external view returns (bool) {
        Proposal storage _0x2b038e = _0x350d1b[_0x9a2e0a];
        return _0x7c66e3(_0x2b038e);
    }


    function _0x7c1b21() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x7c1b21();
    }


    function _0x5af4ab() public view override returns (uint256) {
        return IERC20(_0xb22aa6._0xfad7b1())._0xa6270c();
    }


    function _0xe38cf9(uint256 _0x9a2e0a, address _0x0599b8) public view returns (uint256) {
        return _0x350d1b[_0x9a2e0a]._0x89cdd3[_0x0599b8]._0x79855c;
    }


    function _0x389068(Proposal storage _0x2b038e, address _0x0599b8, VoteOption _0x731621, uint256 _0x591781)
        internal
        view
        returns (bool)
    {
        uint256 _0x0561ae = _0x2b038e._0x89cdd3[_0x0599b8]._0x79855c;


        if (!_0x7c66e3(_0x2b038e)) {
            return false;
        } else if (_0x731621 == VoteOption.None) {
            return false;
        }

        else if (_0x2b038e._0x32efd7._0x38750c != VotingMode.VoteReplacement) {

            if (_0x591781 <= _0x0561ae) {
                return false;
            }

            else if (
                _0x2b038e._0x89cdd3[_0x0599b8]._0x399aa4 != VoteOption.None
                    && _0x731621 != _0x2b038e._0x89cdd3[_0x0599b8]._0x399aa4
            ) {
                return false;
            }
        }

        else {

            if (_0x591781 == 0 || _0x591781 < _0x0561ae) {
                return false;
            }

            else if (_0x591781 == _0x0561ae && _0x731621 == _0x2b038e._0x89cdd3[_0x0599b8]._0x399aa4) {
                return false;
            }
        }

        return true;
    }

    function _0xc126ef(uint256 _0x9a2e0a, address _0x69bab6) internal {
        if (!_0xeacd50(_0x9a2e0a)) {
            return;
        } else if (!_0xce3cc4()._0xb46e8a(address(this), _0x69bab6, EXECUTE_PROPOSAL_PERMISSION_ID, _0x04fbbd())) {
            return;
        }

        _0x59db86(_0x9a2e0a);
    }

    function _0x59db86(uint256 _0x9a2e0a) internal override {
        super._0x59db86(_0x9a2e0a);


        _0xb22aa6._0x4ed9c8(_0x9a2e0a);
    }


    uint256[50] private __gap;
}