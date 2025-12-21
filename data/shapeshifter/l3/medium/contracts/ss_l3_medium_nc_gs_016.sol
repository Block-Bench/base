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
        this._0x09c45f.selector ^ this._0x971a0f.selector;


    bytes32 public constant CREATE_PROPOSAL_PERMISSION_ID = _0x240be4("CREATE_PROPOSAL_PERMISSION");


    bytes32 public constant LOCK_MANAGER_PERMISSION_ID = _0x240be4("LOCK_MANAGER_PERMISSION");

    event VoteCleared(uint256 _0xbd030d, address _0x17e303);

    error VoteRemovalForbidden(uint256 _0xbd030d, address _0x17e303);


    function _0x9b1b92(
        IDAO _0x0a01d4,
        ILockManager _0xaef3ab,
        VotingSettings calldata _0x21bf8d,
        IPlugin.TargetConfig calldata _0xc7d1ea,
        bytes calldata _0xcac5da
    ) external _0xd7e6ca _0x633a02(1) {
        __MajorityVotingBase_init(_0x0a01d4, _0x21bf8d, _0xc7d1ea, _0xcac5da);
        __LockToGovernBase_init(_0xaef3ab);

        emit MembershipContractAnnounced({_0x4ca00e: address(_0xaef3ab._0x52ca51())});
    }


    function _0xdb3f71(bytes4 _0x45dfac)
        public
        view
        virtual
        override(MajorityVotingBase, LockToGovernBase)
        returns (bool)
    {
        return _0x45dfac == LOCK_TO_VOTE_INTERFACE_ID || _0x45dfac == type(ILockToVote)._0x929b83
            || super._0xdb3f71(_0x45dfac);
    }


    function _0x5482d6() external pure override returns (string memory) {
        return "(uint256 allowFailureMap)";
    }


    function _0x971a0f(
        bytes calldata _0xda98d1,
        Action[] memory _0x12d8e8,
        uint64 _0x071b34,
        uint64 _0x383637,
        bytes memory _0x0bac09
    ) external _0xdd0034(CREATE_PROPOSAL_PERMISSION_ID) returns (uint256 _0xbd030d) {
        uint256 _0xa1a789;

        if (_0x0bac09.length != 0) {
            (_0xa1a789) = abi._0x9d6646(_0x0bac09, (uint256));
        }

        if (_0x847b2f() == 0) {
            revert NoVotingPower();
        }


        (_0x071b34, _0x383637) = _0x363325(_0x071b34, _0x383637);

        _0xbd030d = _0x4c4fc1(_0x240be4(abi._0xb317a5(_0x12d8e8, _0xda98d1)));

        if (_0x02aacf(_0xbd030d)) {
            revert ProposalAlreadyExists(_0xbd030d);
        }


        Proposal storage _0x10cbf5 = _0x6f90ec[_0xbd030d];

        _0x10cbf5._0xdcfb6e._0x875171 = _0x875171();
        _0x10cbf5._0xdcfb6e._0x8d4624 = _0x8d4624();
        _0x10cbf5._0xdcfb6e._0x379adc = _0x071b34;
        _0x10cbf5._0xdcfb6e._0xb668f9 = _0x383637;
        _0x10cbf5._0xdcfb6e._0x3739ce = _0x3739ce();
        _0x10cbf5._0xdcfb6e._0xc52335 = _0xc52335();

        _0x10cbf5._0x5f2346 = _0x2eb9d6();


        if (_0xa1a789 != 0) {
            _0x10cbf5._0x38cd9d = _0xa1a789;
        }

        for (uint256 i; i < _0x12d8e8.length;) {
            _0x10cbf5._0x4a7a15.push(_0x12d8e8[i]);
            unchecked {
                ++i;
            }
        }

        emit ProposalCreated(_0xbd030d, _0x04b826(), _0x071b34, _0x383637, _0xda98d1, _0x12d8e8, _0xa1a789);

        _0x957761._0x8b3c39(_0xbd030d);
    }


    function _0x84bdca(uint256 _0x536f19, address _0x53809f, VoteOption _0x994d19) public view returns (bool) {
        if (!_0x02aacf(_0x536f19)) {
            revert NonexistentProposal(_0x536f19);
        }

        Proposal storage _0x10cbf5 = _0x6f90ec[_0x536f19];
        return _0x1eb085(_0x10cbf5, _0x53809f, _0x994d19, _0x957761._0x72a687(_0x53809f));
    }


    function _0x23a08e(uint256 _0x536f19, address _0x53809f, VoteOption _0x994d19, uint256 _0xd8608a)
        public
        override
        _0xdd0034(LOCK_MANAGER_PERMISSION_ID)
    {
        Proposal storage _0x10cbf5 = _0x6f90ec[_0x536f19];

        if (!_0x1eb085(_0x10cbf5, _0x53809f, _0x994d19, _0xd8608a)) {
            revert VoteCastForbidden(_0x536f19, _0x53809f);
        }


        if (_0x994d19 == _0x10cbf5._0x99a5e3[_0x53809f]._0x943744) {

            if (_0xd8608a == _0x10cbf5._0x99a5e3[_0x53809f]._0x668df7) return;


            uint256 _0xd1f106 = _0xd8608a - _0x10cbf5._0x99a5e3[_0x53809f]._0x668df7;
            _0x10cbf5._0x99a5e3[_0x53809f]._0x668df7 = _0xd8608a;

            if (_0x10cbf5._0x99a5e3[_0x53809f]._0x943744 == VoteOption.Yes) {
                _0x10cbf5._0x706b20._0x24e82f += _0xd1f106;
            } else if (_0x10cbf5._0x99a5e3[_0x53809f]._0x943744 == VoteOption.No) {
                _0x10cbf5._0x706b20._0x0ea7cf += _0xd1f106;
            } else {

                _0x10cbf5._0x706b20._0x64653d += _0xd1f106;
            }
        } else {


            if (_0x10cbf5._0x99a5e3[_0x53809f]._0x668df7 > 0) {

                if (_0x10cbf5._0x99a5e3[_0x53809f]._0x943744 == VoteOption.Yes) {
                    _0x10cbf5._0x706b20._0x24e82f -= _0x10cbf5._0x99a5e3[_0x53809f]._0x668df7;
                } else if (_0x10cbf5._0x99a5e3[_0x53809f]._0x943744 == VoteOption.No) {
                    _0x10cbf5._0x706b20._0x0ea7cf -= _0x10cbf5._0x99a5e3[_0x53809f]._0x668df7;
                } else {

                    _0x10cbf5._0x706b20._0x64653d -= _0x10cbf5._0x99a5e3[_0x53809f]._0x668df7;
                }
            }


            if (_0x994d19 == VoteOption.Yes) {
                _0x10cbf5._0x706b20._0x24e82f += _0xd8608a;
            } else if (_0x994d19 == VoteOption.No) {
                _0x10cbf5._0x706b20._0x0ea7cf += _0xd8608a;
            } else {

                _0x10cbf5._0x706b20._0x64653d += _0xd8608a;
            }
            _0x10cbf5._0x99a5e3[_0x53809f]._0x943744 = _0x994d19;
            _0x10cbf5._0x99a5e3[_0x53809f]._0x668df7 = _0xd8608a;
        }

        emit VoteCast(_0x536f19, _0x53809f, _0x994d19, _0xd8608a);

        if (_0x10cbf5._0xdcfb6e._0x875171 == VotingMode.EarlyExecution) {
            _0xbd85d8(_0x536f19, _0x04b826());
        }
    }


    function _0x43e496(uint256 _0x536f19, address _0x53809f) external _0xdd0034(LOCK_MANAGER_PERMISSION_ID) {
        Proposal storage _0x10cbf5 = _0x6f90ec[_0x536f19];
        if (!_0x8d74c3(_0x10cbf5)) {
            revert VoteRemovalForbidden(_0x536f19, _0x53809f);
        } else if (_0x10cbf5._0xdcfb6e._0x875171 != VotingMode.VoteReplacement) {
            revert VoteRemovalForbidden(_0x536f19, _0x53809f);
        } else if (_0x10cbf5._0x99a5e3[_0x53809f]._0x668df7 == 0) {

            return;
        }


        if (_0x10cbf5._0x99a5e3[_0x53809f]._0x943744 == VoteOption.Yes) {
            _0x10cbf5._0x706b20._0x24e82f -= _0x10cbf5._0x99a5e3[_0x53809f]._0x668df7;
        } else if (_0x10cbf5._0x99a5e3[_0x53809f]._0x943744 == VoteOption.No) {
            _0x10cbf5._0x706b20._0x0ea7cf -= _0x10cbf5._0x99a5e3[_0x53809f]._0x668df7;
        }

        else if (_0x10cbf5._0x99a5e3[_0x53809f]._0x943744 == VoteOption.Abstain) {
            _0x10cbf5._0x706b20._0x64653d -= _0x10cbf5._0x99a5e3[_0x53809f]._0x668df7;
        }
        _0x10cbf5._0x99a5e3[_0x53809f]._0x668df7 = 0;

        emit VoteCleared(_0x536f19, _0x53809f);
    }


    function _0x939887(uint256 _0x536f19) external view returns (bool) {
        Proposal storage _0x10cbf5 = _0x6f90ec[_0x536f19];
        return _0x8d74c3(_0x10cbf5);
    }


    function _0x09c45f() public view override(ILockToGovernBase, MajorityVotingBase) returns (uint256) {
        return MajorityVotingBase._0x09c45f();
    }


    function _0x847b2f() public view override returns (uint256) {
        return IERC20(_0x957761._0x52ca51())._0x55b245();
    }


    function _0x21735d(uint256 _0x536f19, address _0x53809f) public view returns (uint256) {
        return _0x6f90ec[_0x536f19]._0x99a5e3[_0x53809f]._0x668df7;
    }


    function _0x1eb085(Proposal storage _0x10cbf5, address _0x53809f, VoteOption _0x994d19, uint256 _0xd8608a)
        internal
        view
        returns (bool)
    {
        uint256 _0xf7be0e = _0x10cbf5._0x99a5e3[_0x53809f]._0x668df7;


        if (!_0x8d74c3(_0x10cbf5)) {
            return false;
        } else if (_0x994d19 == VoteOption.None) {
            return false;
        }

        else if (_0x10cbf5._0xdcfb6e._0x875171 != VotingMode.VoteReplacement) {

            if (_0xd8608a <= _0xf7be0e) {
                return false;
            }

            else if (
                _0x10cbf5._0x99a5e3[_0x53809f]._0x943744 != VoteOption.None
                    && _0x994d19 != _0x10cbf5._0x99a5e3[_0x53809f]._0x943744
            ) {
                return false;
            }
        }

        else {

            if (_0xd8608a == 0 || _0xd8608a < _0xf7be0e) {
                return false;
            }

            else if (_0xd8608a == _0xf7be0e && _0x994d19 == _0x10cbf5._0x99a5e3[_0x53809f]._0x943744) {
                return false;
            }
        }

        return true;
    }

    function _0xbd85d8(uint256 _0x536f19, address _0x2b2fab) internal {
        if (!_0x377192(_0x536f19)) {
            return;
        } else if (!_0x7b2d21()._0xdac345(address(this), _0x2b2fab, EXECUTE_PROPOSAL_PERMISSION_ID, _0x89b96d())) {
            return;
        }

        _0x8d73e2(_0x536f19);
    }

    function _0x8d73e2(uint256 _0x536f19) internal override {
        super._0x8d73e2(_0x536f19);


        _0x957761._0x1e5118(_0x536f19);
    }


    uint256[50] private __gap;
}