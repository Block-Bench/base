// 0xbb9bc244d798123fde783fcc1c72d3bb8c189413#code

/// @title Standard Token Contract.

contract TokenInterface {
    mapping (address => uint256) _0xa5fef0;
    mapping (address => mapping (address => uint256)) _0x6087d5;

    /// Total amount of tokens
    uint256 public _0x00d7df;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function _0x4fdf0d(address _0x53f060) constant returns (uint256 balance);

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _0xfeb55c, uint256 _0x96453d) returns (bool _0x6bcaf6);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    /// is approved by `_from`
    /// @param _from The address of the origin of the transfer
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function _0x55621d(address _0x24798b, address _0xfeb55c, uint256 _0x96453d) returns (bool _0x6bcaf6);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    /// its behalf
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function _0x258a82(address _0x2b1af8, uint256 _0x96453d) returns (bool _0x6bcaf6);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    /// to spend
    function _0xaa268f(
        address _0x53f060,
        address _0x2b1af8
    ) constant returns (uint256 _0x1b1793);

    event Transfer(address indexed _0x24798b, address indexed _0xfeb55c, uint256 _0x96453d);
    event Approval(
        address indexed _0x53f060,
        address indexed _0x2b1af8,
        uint256 _0x96453d
    );
}

contract Token is TokenInterface {
    // Protects users by preventing the execution of method calls that
    // inadvertently also transferred ether
    modifier _0x082ce1() {if (msg.value > 0) throw; _;}

    function _0x4fdf0d(address _0x53f060) constant returns (uint256 balance) {
        return _0xa5fef0[_0x53f060];
    }

    function transfer(address _0xfeb55c, uint256 _0x96453d) _0x082ce1 returns (bool _0x6bcaf6) {
        if (_0xa5fef0[msg.sender] >= _0x96453d && _0x96453d > 0) {
            _0xa5fef0[msg.sender] -= _0x96453d;
            _0xa5fef0[_0xfeb55c] += _0x96453d;
            Transfer(msg.sender, _0xfeb55c, _0x96453d);
            return true;
        } else {
           return false;
        }
    }

    function _0x55621d(
        address _0x24798b,
        address _0xfeb55c,
        uint256 _0x96453d
    ) _0x082ce1 returns (bool _0x6bcaf6) {

        if (_0xa5fef0[_0x24798b] >= _0x96453d
            && _0x6087d5[_0x24798b][msg.sender] >= _0x96453d
            && _0x96453d > 0) {

            _0xa5fef0[_0xfeb55c] += _0x96453d;
            _0xa5fef0[_0x24798b] -= _0x96453d;
            _0x6087d5[_0x24798b][msg.sender] -= _0x96453d;
            Transfer(_0x24798b, _0xfeb55c, _0x96453d);
            return true;
        } else {
            return false;
        }
    }

    function _0x258a82(address _0x2b1af8, uint256 _0x96453d) returns (bool _0x6bcaf6) {
        _0x6087d5[msg.sender][_0x2b1af8] = _0x96453d;
        Approval(msg.sender, _0x2b1af8, _0x96453d);
        return true;
    }

    function _0xaa268f(address _0x53f060, address _0x2b1af8) constant returns (uint256 _0x1b1793) {
        return _0x6087d5[_0x53f060][_0x2b1af8];
    }
}

contract ManagedAccountInterface {
    // The only address with permission to withdraw from this account
    address public _0x25ab94;
    // If true, only the owner of the account can receive ether from it
    bool public _0x74772e;
    // The sum of ether (in wei) which has been sent to this contract
    uint public _0xb7e48b;

    /// @notice Sends `_amount` of wei to _recipient
    /// @param _amount The amount of wei to send to `_recipient`
    /// @param _recipient The address to receive `_amount` of wei
    /// @return True if the send completed
    function _0x2274a0(address _0xc91936, uint _0x96453d) returns (bool);

    event PayOut(address indexed _0xc91936, uint _0x96453d);
}

contract ManagedAccount is ManagedAccountInterface{

    // The constructor sets the owner of the account
    function ManagedAccount(address _0x53f060, bool _0x03de3c) {
        _0x25ab94 = _0x53f060;
        _0x74772e = _0x03de3c;
    }

    // When the contract receives a transaction without data this is called.
    // It counts the amount of ether it receives and stores it in
    // accumulatedInput.
    function() {
        _0xb7e48b += msg.value;
    }

    function _0x2274a0(address _0xc91936, uint _0x96453d) returns (bool) {
        if (msg.sender != _0x25ab94 || msg.value > 0 || (_0x74772e && _0xc91936 != _0x25ab94))
            throw;
        if (_0xc91936.call.value(_0x96453d)()) {
            PayOut(_0xc91936, _0x96453d);
            return true;
        } else {
            return false;
        }
    }
}

contract TokenCreationInterface {

    // End of token creation, in Unix time
    uint public _0x173be8;
    // Minimum fueling goal of the token creation, denominated in tokens to
    // be created
    uint public _0xed24bf;
    // True if the DAO reached its minimum fueling goal, false otherwise
    bool public _0x400a34;
    // For DAO splits - if privateCreation is 0, then it is a public token
    // creation, otherwise only the address stored in privateCreation is
    // allowed to create tokens
    address public _0x9c0b81;
    // hold extra ether which has been sent after the DAO token
    // creation rate has increased
    ManagedAccount public _0x35978f;
    // tracks the amount of wei given from each contributor (used for refund)
    mapping (address => uint256) _0x51b75c;

    /// @dev Constructor setting the minimum fueling goal and the
    /// end of the Token Creation
    /// @param _minTokensToCreate Minimum fueling goal in number of
    ///        Tokens to be created
    /// @param _closingTime Date (in Unix time) of the end of the Token Creation
    /// @param _privateCreation Zero means that the creation is public.  A
    /// non-zero address represents the only address that can create Tokens
    /// (the address can also create Tokens on behalf of other accounts)
    // This is the constructor: it can not be overloaded so it is commented out
    //  function TokenCreation(
        //  uint _minTokensTocreate,
        //  uint _closingTime,
        //  address _privateCreation
    //  );

    /// @notice Create Token with `_tokenHolder` as the initial owner of the Token
    /// @param _tokenHolder The address of the Tokens's recipient
    /// @return Whether the token creation was successful
    function _0x30a232(address _0x09814f) returns (bool _0x6bcaf6);

    /// @notice Refund `msg.sender` in the case the Token Creation did
    /// not reach its minimum fueling goal
    function _0xa726ef();

    /// @return The divisor used to calculate the token creation rate during
    /// the creation phase
    function _0xff8200() constant returns (uint _0xff8200);

    event FuelingToDate(uint value);
    event CreatedToken(address indexed _0xa5c68f, uint _0x3c667a);
    event Refund(address indexed _0xa5c68f, uint value);
}

contract TokenCreation is TokenCreationInterface, Token {
    function TokenCreation(
        uint _0x861886,
        uint _0x97b7f2,
        address _0xf84622) {

        _0x173be8 = _0x97b7f2;
        _0xed24bf = _0x861886;
        _0x9c0b81 = _0xf84622;
        _0x35978f = new ManagedAccount(address(this), true);
    }

    function _0x30a232(address _0x09814f) returns (bool _0x6bcaf6) {
        if (_0x7df41f < _0x173be8 && msg.value > 0
            && (_0x9c0b81 == 0 || _0x9c0b81 == msg.sender)) {

            uint _0xa35057 = (msg.value * 20) / _0xff8200();
            _0x35978f.call.value(msg.value - _0xa35057)();
            _0xa5fef0[_0x09814f] += _0xa35057;
            _0x00d7df += _0xa35057;
            _0x51b75c[_0x09814f] += msg.value;
            CreatedToken(_0x09814f, _0xa35057);
            if (_0x00d7df >= _0xed24bf && !_0x400a34) {
                _0x400a34 = true;
                FuelingToDate(_0x00d7df);
            }
            return true;
        }
        throw;
    }

    function _0xa726ef() _0x082ce1 {
        if (_0x7df41f > _0x173be8 && !_0x400a34) {
            // Get extraBalance - will only succeed when called for the first time
            if (_0x35978f.balance >= _0x35978f._0xb7e48b())
                _0x35978f._0x2274a0(address(this), _0x35978f._0xb7e48b());

            // Execute refund
            if (msg.sender.call.value(_0x51b75c[msg.sender])()) {
                Refund(msg.sender, _0x51b75c[msg.sender]);
                _0x00d7df -= _0xa5fef0[msg.sender];
                _0xa5fef0[msg.sender] = 0;
                _0x51b75c[msg.sender] = 0;
            }
        }
    }

    function _0xff8200() constant returns (uint _0xff8200) {
        // The number of (base unit) tokens per wei is calculated
        // as `msg.value` * 20 / `divisor`
        // The fueling period starts with a 1:1 ratio
        if (_0x173be8 - 2 weeks > _0x7df41f) {
            return 20;
        // Followed by 10 days with a daily creation rate increase of 5%
        } else if (_0x173be8 - 4 days > _0x7df41f) {
            return (20 + (_0x7df41f - (_0x173be8 - 2 weeks)) / (1 days));
        // The last 4 days there is a constant creation rate ratio of 1:1.5
        } else {
            return 30;
        }
    }
}

contract DAOInterface {

    // The amount of days for which people who try to participate in the
    // creation by calling the fallback function will still get their ether back
    uint constant _0x23f25f = 40 days;
    // The minimum debate period that a generic proposal can have
    uint constant _0x592eb3 = 2 weeks;
    // The minimum debate period that a split proposal can have
    uint constant _0x0a4cb4 = 1 weeks;
    // Period of days inside which it's possible to execute a DAO split
    uint constant _0xfc98f1 = 27 days;
    // Period of time after which the minimum Quorum is halved
    uint constant _0x7731f3 = 25 weeks;
    // Period after which a proposal is closed
    // (used in the case `executeProposal` fails because it throws)
    uint constant _0xc97abb = 10 days;
    // Denotes the maximum proposal deposit that can be given. It is given as
    // a fraction of total Ether spent plus balance of the DAO
    uint constant _0x548d38 = 100;

    // Proposals to spend the DAO's ether or to choose a new Curator
    Proposal[] public _0x19d63b;
    // The quorum needed for each proposal is partially calculated by
    // totalSupply / minQuorumDivisor
    uint public _0x038708;
    // The unix time of the last time quorum was reached on a proposal
    uint  public _0xdaab26;

    // Address of the curator
    address public _0x0049f8;
    // The whitelist: List of addresses the DAO is allowed to send ether to
    mapping (address => bool) public _0xf57526;

    // Tracks the addresses that own Reward Tokens. Those addresses can only be
    // DAOs that have split from the original DAO. Conceptually, Reward Tokens
    // represent the proportion of the rewards that the DAO has the right to
    // receive. These Reward Tokens are generated when the DAO spends ether.
    mapping (address => uint) public _0x7f48cb;
    // Total supply of rewardToken
    uint public _0x06309e;

    // The account used to manage the rewards which are to be distributed to the
    // DAO Token Holders of this DAO
    ManagedAccount public _0x12efa9;

    // The account used to manage the rewards which are to be distributed to
    // any DAO that holds Reward Tokens
    ManagedAccount public DAOrewardAccount;

    // Amount of rewards (in wei) already paid out to a certain DAO
    mapping (address => uint) public DAOpaidOut;

    // Amount of rewards (in wei) already paid out to a certain address
    mapping (address => uint) public _0x98ec85;
    // Map of addresses blocked during a vote (not allowed to transfer DAO
    // tokens). The address points to the proposal ID.
    mapping (address => uint) public _0xaedf88;

    // The minimum deposit (in wei) required to submit any proposal that is not
    // requesting a new Curator (no deposit is required for splits)
    uint public _0x4be998;

    // the accumulated sum of all current proposal deposits
    uint _0xfa9b57;

    // Contract that is able to create a new DAO (with the same code as
    // this one), used for splits
    DAO_Creator public _0x8b9098;

    // A proposal with `newCurator == false` represents a transaction
    // to be issued by this DAO
    // A proposal with `newCurator == true` represents a DAO split
    struct Proposal {
        // The address where the `amount` will go to if the proposal is accepted
        // or if `newCurator` is true, the proposed Curator of
        // the new DAO).
        address _0x4bbc61;
        // The amount to transfer to `recipient` if the proposal is accepted.
        uint _0x3c667a;
        // A plain text description of the proposal
        string _0xb4d89f;
        // A unix timestamp, denoting the end of the voting period
        uint _0x9a83e2;
        // True if the proposal's votes have yet to be counted, otherwise False
        bool _0x52a489;
        // True if quorum has been reached, the votes have been counted, and
        // the majority said yes
        bool _0xd5fed3;
        // A hash to check validity of a proposal
        bytes32 _0x7a5a22;
        // Deposit in wei the creator added when submitting their proposal. It
        // is taken from the msg.value of a newProposal call.
        uint _0x4be998;
        // True if this proposal is to assign a new Curator
        bool _0xce3f7c;
        // Data needed for splitting the DAO
        SplitData[] _0x34675a;
        // Number of Tokens in favor of the proposal
        uint _0x112988;
        // Number of Tokens opposed to the proposal
        uint _0xd5db1c;
        // Simple mapping to check if a shareholder has voted for it
        mapping (address => bool) _0xa6bb06;
        // Simple mapping to check if a shareholder has voted against it
        mapping (address => bool) _0xbf8295;
        // Address of the shareholder who created the proposal
        address _0xe34706;
    }

    // Used only in the case of a newCurator proposal.
    struct SplitData {
        // The balance of the current DAO minus the deposit at the time of split
        uint _0x2adf97;
        // The total amount of DAO Tokens in existence at the time of split.
        uint _0x00d7df;
        // Amount of Reward Tokens owned by the DAO at the time of split.
        uint _0x7f48cb;
        // The new DAO contract created at the time of split.
        DAO _0x2698b1;
    }

    // Used to restrict access to certain functions to only DAO Token Holders
    modifier _0xa1a3e0 {}

    /// @dev Constructor setting the Curator and the address
    /// for the contract able to create another DAO as well as the parameters
    /// for the DAO Token Creation
    /// @param _curator The Curator
    /// @param _daoCreator The contract able to (re)create this DAO
    /// @param _proposalDeposit The deposit to be paid for a regular proposal
    /// @param _minTokensToCreate Minimum required wei-equivalent tokens
    ///        to be created for a successful DAO Token Creation
    /// @param _closingTime Date (in Unix time) of the end of the DAO Token Creation
    /// @param _privateCreation If zero the DAO Token Creation is open to public, a
    /// non-zero address means that the DAO Token Creation is only for the address
    // This is the constructor: it can not be overloaded so it is commented out
    //  function DAO(
        //  address _curator,
        //  DAO_Creator _daoCreator,
        //  uint _proposalDeposit,
        //  uint _minTokensToCreate,
        //  uint _closingTime,
        //  address _privateCreation
    //  );

    /// @notice Create Token with `msg.sender` as the beneficiary
    /// @return Whether the token creation was successful
    function () returns (bool _0x6bcaf6);

    /// @dev This function is used to send ether back
    /// to the DAO, it can also be used to receive payments that should not be
    /// counted as rewards (donations, grants, etc.)
    /// @return Whether the DAO received the ether successfully
    function _0x791591() returns(bool);

    /// @notice `msg.sender` creates a proposal to send `_amount` Wei to
    /// `_recipient` with the transaction data `_transactionData`. If
    /// `_newCurator` is true, then this is a proposal that splits the
    /// DAO and sets `_recipient` as the new DAO's Curator.
    /// @param _recipient Address of the recipient of the proposed transaction
    /// @param _amount Amount of wei to be sent with the proposed transaction
    /// @param _description String describing the proposal
    /// @param _transactionData Data of the proposed transaction
    /// @param _debatingPeriod Time used for debating a proposal, at least 2
    /// weeks for a regular proposal, 10 days for new Curator proposal
    /// @param _newCurator Bool defining whether this proposal is about
    /// a new Curator or not
    /// @return The proposal ID. Needed for voting on the proposal
    function _0x8ace74(
        address _0xc91936,
        uint _0x96453d,
        string _0x6fe547,
        bytes _0x9e6d47,
        uint _0xf3cf88,
        bool _0xe5b72b
    ) _0xa1a3e0 returns (uint _0xbd5702);

    /// @notice Check that the proposal with the ID `_proposalID` matches the
    /// transaction which sends `_amount` with data `_transactionData`
    /// to `_recipient`
    /// @param _proposalID The proposal ID
    /// @param _recipient The recipient of the proposed transaction
    /// @param _amount The amount of wei to be sent in the proposed transaction
    /// @param _transactionData The data of the proposed transaction
    /// @return Whether the proposal ID matches the transaction data or not
    function _0x30d955(
        uint _0xbd5702,
        address _0xc91936,
        uint _0x96453d,
        bytes _0x9e6d47
    ) constant returns (bool _0x6e74f4);

    /// @notice Vote on proposal `_proposalID` with `_supportsProposal`
    /// @param _proposalID The proposal ID
    /// @param _supportsProposal Yes/No - support of the proposal
    /// @return The vote ID.
    function _0x6d14c4(
        uint _0xbd5702,
        bool _0x98a74f
    ) _0xa1a3e0 returns (uint _0x0a6e4e);

    /// @notice Checks whether proposal `_proposalID` with transaction data
    /// `_transactionData` has been voted for or rejected, and executes the
    /// transaction in the case it has been voted for.
    /// @param _proposalID The proposal ID
    /// @param _transactionData The data of the proposed transaction
    /// @return Whether the proposed transaction has been executed or not
    function _0x5cf638(
        uint _0xbd5702,
        bytes _0x9e6d47
    ) returns (bool _0x806d43);

    /// @notice ATTENTION! I confirm to move my remaining ether to a new DAO
    /// with `_newCurator` as the new Curator, as has been
    /// proposed in proposal `_proposalID`. This will burn my tokens. This can
    /// not be undone and will split the DAO into two DAO's, with two
    /// different underlying tokens.
    /// @param _proposalID The proposal ID
    /// @param _newCurator The new Curator of the new DAO
    /// @dev This function, when called for the first time for this proposal,
    /// will create a new DAO and send the sender's portion of the remaining
    /// ether and Reward Tokens to the new DAO. It will also burn the DAO Tokens
    /// of the sender.
    function _0x52b97c(
        uint _0xbd5702,
        address _0xe5b72b
    ) returns (bool _0x806d43);

    /// @dev can only be called by the DAO itself through a proposal
    /// updates the contract of the DAO by sending all ether and rewardTokens
    /// to the new DAO. The new DAO needs to be approved by the Curator
    /// @param _newContract the address of the new contract
    function _0xa6d423(address _0xad982e);

    /// @notice Add a new possible recipient `_recipient` to the whitelist so
    /// that the DAO can send transactions to them (using proposals)
    /// @param _recipient New recipient address
    /// @dev Can only be called by the current Curator
    /// @return Whether successful or not
    function _0xab29a1(address _0xc91936, bool _0x70fbf0) external returns (bool _0x806d43);

    /// @notice Change the minimum deposit required to submit a proposal
    /// @param _proposalDeposit The new proposal deposit
    /// @dev Can only be called by this DAO (through proposals with the
    /// recipient being this DAO itself)
    function _0xf71832(uint _0x4cfd2a) external;

    /// @notice Move rewards from the DAORewards managed account
    /// @param _toMembers If true rewards are moved to the actual reward account
    ///                   for the DAO. If not then it's moved to the DAO itself
    /// @return Whether the call was successful
    function _0x57c326(bool _0x3eb188) external returns (bool _0x806d43);

    /// @notice Get my portion of the reward that was sent to `rewardAccount`
    /// @return Whether the call was successful
    function _0x41e2f7() returns(bool _0x806d43);

    /// @notice Withdraw `_account`'s portion of the reward from `rewardAccount`
    /// to `_account`'s balance
    /// @return Whether the call was successful
    function _0xa1fc9f(address _0xd1c955) internal returns (bool _0x806d43);

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`. Prior to this
    /// getMyReward() is called.
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transfered
    /// @return Whether the transfer was successful or not
    function _0xd33f76(address _0xfeb55c, uint256 _0x96453d) returns (bool _0x6bcaf6);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    /// is approved by `_from`. Prior to this getMyReward() is called.
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transfered
    /// @return Whether the transfer was successful or not
    function _0x84f2c8(
        address _0x24798b,
        address _0xfeb55c,
        uint256 _0x96453d
    ) returns (bool _0x6bcaf6);

    /// @notice Doubles the 'minQuorumDivisor' in the case quorum has not been
    /// achieved in 52 weeks
    /// @return Whether the change was successful or not
    function _0x4bc37b() returns (bool _0x806d43);

    /// @return total number of proposals ever created
    function _0xcce393() constant returns (uint _0xb6b061);

    /// @param _proposalID Id of the new curator proposal
    /// @return Address of the new DAO
    function _0x6086a7(uint _0xbd5702) constant returns (address _0xc8a246);

    /// @param _account The address of the account which is checked.
    /// @return Whether the account is blocked (not allowed to transfer tokens) or not.
    function _0xd88836(address _0xd1c955) internal returns (bool);

    /// @notice If the caller is blocked by a proposal whose voting deadline
    /// has exprired then unblock him.
    /// @return Whether the account is blocked (not allowed to transfer tokens) or not.
    function _0x56bcee() returns (bool);

    event ProposalAdded(
        uint indexed _0x07b28a,
        address _0x4bbc61,
        uint _0x3c667a,
        bool _0xce3f7c,
        string _0xb4d89f
    );
    event Voted(uint indexed _0x07b28a, bool _0x0a70d9, address indexed _0x4c57fa);
    event ProposalTallied(uint indexed _0x07b28a, bool _0x517dea, uint _0x8efcc3);
    event NewCurator(address indexed _0xe5b72b);
    event AllowedRecipientChanged(address indexed _0xc91936, bool _0x70fbf0);
}

// The DAO contract itself
contract DAO is DAOInterface, Token, TokenCreation {

    // Modifier that allows only shareholders to vote and create new proposals
    modifier _0xa1a3e0 {
        if (_0x4fdf0d(msg.sender) == 0) throw;
            _;
    }

    function DAO(
        address _0x217c6c,
        DAO_Creator _0x9a82b9,
        uint _0x4cfd2a,
        uint _0x861886,
        uint _0x97b7f2,
        address _0xf84622
    ) TokenCreation(_0x861886, _0x97b7f2, _0xf84622) {

        _0x0049f8 = _0x217c6c;
        _0x8b9098 = _0x9a82b9;
        _0x4be998 = _0x4cfd2a;
        _0x12efa9 = new ManagedAccount(address(this), false);
        DAOrewardAccount = new ManagedAccount(address(this), false);
        if (address(_0x12efa9) == 0)
            throw;
        if (address(DAOrewardAccount) == 0)
            throw;
        _0xdaab26 = _0x7df41f;
        _0x038708 = 5; // sets the minimal quorum to 20%
        _0x19d63b.length = 1; // avoids a proposal with ID 0 because it is used

        _0xf57526[address(this)] = true;
        _0xf57526[_0x0049f8] = true;
    }

    function () returns (bool _0x6bcaf6) {
        if (_0x7df41f < _0x173be8 + _0x23f25f && msg.sender != address(_0x35978f))
            return _0x30a232(msg.sender);
        else
            return _0x791591();
    }

    function _0x791591() returns (bool) {
        return true;
    }

    function _0x8ace74(
        address _0xc91936,
        uint _0x96453d,
        string _0x6fe547,
        bytes _0x9e6d47,
        uint _0xf3cf88,
        bool _0xe5b72b
    ) _0xa1a3e0 returns (uint _0xbd5702) {

        // Sanity check
        if (_0xe5b72b && (
            _0x96453d != 0
            || _0x9e6d47.length != 0
            || _0xc91936 == _0x0049f8
            || msg.value > 0
            || _0xf3cf88 < _0x0a4cb4)) {
            throw;
        } else if (
            !_0xe5b72b
            && (!_0x99a601(_0xc91936) || (_0xf3cf88 <  _0x592eb3))
        ) {
            throw;
        }

        if (_0xf3cf88 > 8 weeks)
            throw;

        if (!_0x400a34
            || _0x7df41f < _0x173be8
            || (msg.value < _0x4be998 && !_0xe5b72b)) {

            throw;
        }

        if (_0x7df41f + _0xf3cf88 < _0x7df41f)
            throw;

        if (msg.sender == address(this))
            throw;

        _0xbd5702 = _0x19d63b.length++;
        Proposal p = _0x19d63b[_0xbd5702];
        p._0x4bbc61 = _0xc91936;
        p._0x3c667a = _0x96453d;
        p._0xb4d89f = _0x6fe547;
        p._0x7a5a22 = _0x83af1e(_0xc91936, _0x96453d, _0x9e6d47);
        p._0x9a83e2 = _0x7df41f + _0xf3cf88;
        p._0x52a489 = true;
        //p.proposalPassed = False; // that's default
        p._0xce3f7c = _0xe5b72b;
        if (_0xe5b72b)
            p._0x34675a.length++;
        p._0xe34706 = msg.sender;
        p._0x4be998 = msg.value;

        _0xfa9b57 += msg.value;

        ProposalAdded(
            _0xbd5702,
            _0xc91936,
            _0x96453d,
            _0xe5b72b,
            _0x6fe547
        );
    }

    function _0x30d955(
        uint _0xbd5702,
        address _0xc91936,
        uint _0x96453d,
        bytes _0x9e6d47
    ) _0x082ce1 constant returns (bool _0x6e74f4) {
        Proposal p = _0x19d63b[_0xbd5702];
        return p._0x7a5a22 == _0x83af1e(_0xc91936, _0x96453d, _0x9e6d47);
    }

    function _0x6d14c4(
        uint _0xbd5702,
        bool _0x98a74f
    ) _0xa1a3e0 _0x082ce1 returns (uint _0x0a6e4e) {

        Proposal p = _0x19d63b[_0xbd5702];
        if (p._0xa6bb06[msg.sender]
            || p._0xbf8295[msg.sender]
            || _0x7df41f >= p._0x9a83e2) {

            throw;
        }

        if (_0x98a74f) {
            p._0x112988 += _0xa5fef0[msg.sender];
            p._0xa6bb06[msg.sender] = true;
        } else {
            p._0xd5db1c += _0xa5fef0[msg.sender];
            p._0xbf8295[msg.sender] = true;
        }

        if (_0xaedf88[msg.sender] == 0) {
            _0xaedf88[msg.sender] = _0xbd5702;
        } else if (p._0x9a83e2 > _0x19d63b[_0xaedf88[msg.sender]]._0x9a83e2) {
            // this proposal's voting deadline is further into the future than
            // the proposal that blocks the sender so make it the blocker
            _0xaedf88[msg.sender] = _0xbd5702;
        }

        Voted(_0xbd5702, _0x98a74f, msg.sender);
    }

    function _0x5cf638(
        uint _0xbd5702,
        bytes _0x9e6d47
    ) _0x082ce1 returns (bool _0x806d43) {

        Proposal p = _0x19d63b[_0xbd5702];

        uint _0x4ee9d1 = p._0xce3f7c
            ? _0xfc98f1
            : _0xc97abb;
        // If we are over deadline and waiting period, assert proposal is closed
        if (p._0x52a489 && _0x7df41f > p._0x9a83e2 + _0x4ee9d1) {
            _0x03b6e7(_0xbd5702);
            return;
        }

        // Check if the proposal can be executed
        if (_0x7df41f < p._0x9a83e2  // has the voting deadline arrived?
            // Have the votes been counted?
            || !p._0x52a489
            // Does the transaction code match the proposal?
            || p._0x7a5a22 != _0x83af1e(p._0x4bbc61, p._0x3c667a, _0x9e6d47)) {

            throw;
        }

        // If the curator removed the recipient from the whitelist, close the proposal
        // in order to free the deposit and allow unblocking of voters
        if (!_0x99a601(p._0x4bbc61)) {
            _0x03b6e7(_0xbd5702);
            p._0xe34706.send(p._0x4be998);
            return;
        }

        bool _0xd9a92d = true;

        if (p._0x3c667a > _0xac9196())
            _0xd9a92d = false;

        uint _0x8efcc3 = p._0x112988 + p._0xd5db1c;

        // require 53% for calling newContract()
        if (_0x9e6d47.length >= 4 && _0x9e6d47[0] == 0x68
            && _0x9e6d47[1] == 0x37 && _0x9e6d47[2] == 0xff
            && _0x9e6d47[3] == 0x1e
            && _0x8efcc3 < _0x474bf2(_0xac9196() + _0x7f48cb[address(this)])) {

                _0xd9a92d = false;
        }

        if (_0x8efcc3 >= _0x474bf2(p._0x3c667a)) {
            if (!p._0xe34706.send(p._0x4be998))
                throw;

            _0xdaab26 = _0x7df41f;
            // set the minQuorum to 20% again, in the case it has been reached
            if (_0x8efcc3 > _0x00d7df / 5)
                _0x038708 = 5;
        }

        // Execute result
        if (_0x8efcc3 >= _0x474bf2(p._0x3c667a) && p._0x112988 > p._0xd5db1c && _0xd9a92d) {
            if (!p._0x4bbc61.call.value(p._0x3c667a)(_0x9e6d47))
                throw;

            p._0xd5fed3 = true;
            _0x806d43 = true;

            // only create reward tokens when ether is not sent to the DAO itself and
            // related addresses. Proxy addresses should be forbidden by the curator.
            if (p._0x4bbc61 != address(this) && p._0x4bbc61 != address(_0x12efa9)
                && p._0x4bbc61 != address(DAOrewardAccount)
                && p._0x4bbc61 != address(_0x35978f)
                && p._0x4bbc61 != address(_0x0049f8)) {

                _0x7f48cb[address(this)] += p._0x3c667a;
                _0x06309e += p._0x3c667a;
            }
        }

        _0x03b6e7(_0xbd5702);

        // Initiate event
        ProposalTallied(_0xbd5702, _0x806d43, _0x8efcc3);
    }

    function _0x03b6e7(uint _0xbd5702) internal {
        Proposal p = _0x19d63b[_0xbd5702];
        if (p._0x52a489)
            _0xfa9b57 -= p._0x4be998;
        p._0x52a489 = false;
    }

    function _0x52b97c(
        uint _0xbd5702,
        address _0xe5b72b
    ) _0x082ce1 _0xa1a3e0 returns (bool _0x806d43) {

        Proposal p = _0x19d63b[_0xbd5702];

        // Sanity check

        if (_0x7df41f < p._0x9a83e2  // has the voting deadline arrived?
            //The request for a split expires XX days after the voting deadline
            || _0x7df41f > p._0x9a83e2 + _0xfc98f1
            // Does the new Curator address match?
            || p._0x4bbc61 != _0xe5b72b
            // Is it a new curator proposal?
            || !p._0xce3f7c
            // Have you voted for this split?
            || !p._0xa6bb06[msg.sender]
            // Did you already vote on another proposal?
            || (_0xaedf88[msg.sender] != _0xbd5702 && _0xaedf88[msg.sender] != 0) )  {

            throw;
        }

        // If the new DAO doesn't exist yet, create the new DAO and store the
        // current split data
        if (address(p._0x34675a[0]._0x2698b1) == 0) {
            p._0x34675a[0]._0x2698b1 = _0x296b20(_0xe5b72b);
            // Call depth limit reached, etc.
            if (address(p._0x34675a[0]._0x2698b1) == 0)
                throw;
            // should never happen
            if (this.balance < _0xfa9b57)
                throw;
            p._0x34675a[0]._0x2adf97 = _0xac9196();
            p._0x34675a[0]._0x7f48cb = _0x7f48cb[address(this)];
            p._0x34675a[0]._0x00d7df = _0x00d7df;
            p._0xd5fed3 = true;
        }

        // Move ether and assign new Tokens
        uint _0x88998d =
            (_0xa5fef0[msg.sender] * p._0x34675a[0]._0x2adf97) /
            p._0x34675a[0]._0x00d7df;
        if (p._0x34675a[0]._0x2698b1._0x30a232.value(_0x88998d)(msg.sender) == false)
            throw;

        // Assign reward rights to new DAO
        uint _0x7b0b2a =
            (_0xa5fef0[msg.sender] * p._0x34675a[0]._0x7f48cb) /
            p._0x34675a[0]._0x00d7df;

        uint _0xffc33a = DAOpaidOut[address(this)] * _0x7b0b2a /
            _0x7f48cb[address(this)];

        _0x7f48cb[address(p._0x34675a[0]._0x2698b1)] += _0x7b0b2a;
        if (_0x7f48cb[address(this)] < _0x7b0b2a)
            throw;
        _0x7f48cb[address(this)] -= _0x7b0b2a;

        DAOpaidOut[address(p._0x34675a[0]._0x2698b1)] += _0xffc33a;
        if (DAOpaidOut[address(this)] < _0xffc33a)
            throw;
        DAOpaidOut[address(this)] -= _0xffc33a;

        // Burn DAO Tokens
        Transfer(msg.sender, 0, _0xa5fef0[msg.sender]);
        _0xa1fc9f(msg.sender); // be nice, and get his rewards
        _0x00d7df -= _0xa5fef0[msg.sender];
        _0xa5fef0[msg.sender] = 0;
        _0x98ec85[msg.sender] = 0;
        return true;
    }

    function _0xa6d423(address _0xad982e){
        if (msg.sender != address(this) || !_0xf57526[_0xad982e]) return;
        // move all ether
        if (!_0xad982e.call.value(address(this).balance)()) {
            throw;
        }

        //move all reward tokens
        _0x7f48cb[_0xad982e] += _0x7f48cb[address(this)];
        _0x7f48cb[address(this)] = 0;
        DAOpaidOut[_0xad982e] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function _0x57c326(bool _0x3eb188) external _0x082ce1 returns (bool _0x806d43) {
        DAO _0x99c383 = DAO(msg.sender);

        if ((_0x7f48cb[msg.sender] * DAOrewardAccount._0xb7e48b()) /
            _0x06309e < DAOpaidOut[msg.sender])
            throw;

        uint _0x575cff =
            (_0x7f48cb[msg.sender] * DAOrewardAccount._0xb7e48b()) /
            _0x06309e - DAOpaidOut[msg.sender];
        if(_0x3eb188) {
            if (!DAOrewardAccount._0x2274a0(_0x99c383._0x12efa9(), _0x575cff))
                throw;
            }
        else {
            if (!DAOrewardAccount._0x2274a0(_0x99c383, _0x575cff))
                throw;
        }
        DAOpaidOut[msg.sender] += _0x575cff;
        return true;
    }

    function _0x41e2f7() _0x082ce1 returns (bool _0x806d43) {
        return _0xa1fc9f(msg.sender);
    }

    function _0xa1fc9f(address _0xd1c955) _0x082ce1 internal returns (bool _0x806d43) {
        if ((_0x4fdf0d(_0xd1c955) * _0x12efa9._0xb7e48b()) / _0x00d7df < _0x98ec85[_0xd1c955])
            throw;

        uint _0x575cff =
            (_0x4fdf0d(_0xd1c955) * _0x12efa9._0xb7e48b()) / _0x00d7df - _0x98ec85[_0xd1c955];
        if (!_0x12efa9._0x2274a0(_0xd1c955, _0x575cff))
            throw;
        _0x98ec85[_0xd1c955] += _0x575cff;
        return true;
    }

    function transfer(address _0xfeb55c, uint256 _0xeeb6f7) returns (bool _0x6bcaf6) {
        if (_0x400a34
            && _0x7df41f > _0x173be8
            && !_0xd88836(msg.sender)
            && _0x965b24(msg.sender, _0xfeb55c, _0xeeb6f7)
            && super.transfer(_0xfeb55c, _0xeeb6f7)) {

            return true;
        } else {
            throw;
        }
    }

    function _0xd33f76(address _0xfeb55c, uint256 _0xeeb6f7) returns (bool _0x6bcaf6) {
        if (!_0x41e2f7())
            throw;
        return transfer(_0xfeb55c, _0xeeb6f7);
    }

    function _0x55621d(address _0x24798b, address _0xfeb55c, uint256 _0xeeb6f7) returns (bool _0x6bcaf6) {
        if (_0x400a34
            && _0x7df41f > _0x173be8
            && !_0xd88836(_0x24798b)
            && _0x965b24(_0x24798b, _0xfeb55c, _0xeeb6f7)
            && super._0x55621d(_0x24798b, _0xfeb55c, _0xeeb6f7)) {

            return true;
        } else {
            throw;
        }
    }

    function _0x84f2c8(
        address _0x24798b,
        address _0xfeb55c,
        uint256 _0xeeb6f7
    ) returns (bool _0x6bcaf6) {

        if (!_0xa1fc9f(_0x24798b))
            throw;
        return _0x55621d(_0x24798b, _0xfeb55c, _0xeeb6f7);
    }

    function _0x965b24(
        address _0x24798b,
        address _0xfeb55c,
        uint256 _0xeeb6f7
    ) internal returns (bool _0x6bcaf6) {

        uint _0x965b24 = _0x98ec85[_0x24798b] * _0xeeb6f7 / _0x4fdf0d(_0x24798b);
        if (_0x965b24 > _0x98ec85[_0x24798b])
            throw;
        _0x98ec85[_0x24798b] -= _0x965b24;
        _0x98ec85[_0xfeb55c] += _0x965b24;
        return true;
    }

    function _0xf71832(uint _0x4cfd2a) _0x082ce1 external {
        if (msg.sender != address(this) || _0x4cfd2a > (_0xac9196() + _0x7f48cb[address(this)])
            / _0x548d38) {

            throw;
        }
        _0x4be998 = _0x4cfd2a;
    }

    function _0xab29a1(address _0xc91936, bool _0x70fbf0) _0x082ce1 external returns (bool _0x806d43) {
        if (msg.sender != _0x0049f8)
            throw;
        _0xf57526[_0xc91936] = _0x70fbf0;
        AllowedRecipientChanged(_0xc91936, _0x70fbf0);
        return true;
    }

    function _0x99a601(address _0xc91936) internal returns (bool _0x02f8e2) {
        if (_0xf57526[_0xc91936]
            || (_0xc91936 == address(_0x35978f)
                // only allowed when at least the amount held in the
                // extraBalance account has been spent from the DAO
                && _0x06309e > _0x35978f._0xb7e48b()))
            return true;
        else
            return false;
    }

    function _0xac9196() constant returns (uint _0x5d62f0) {
        return this.balance - _0xfa9b57;
    }

    function _0x474bf2(uint _0xeeb6f7) internal constant returns (uint _0x13f202) {
        // minimum of 20% and maximum of 53.33%
        return _0x00d7df / _0x038708 +
            (_0xeeb6f7 * _0x00d7df) / (3 * (_0xac9196() + _0x7f48cb[address(this)]));
    }

    function _0x4bc37b() returns (bool _0x806d43) {
        // this can only be called after `quorumHalvingPeriod` has passed or at anytime
        // by the curator with a delay of at least `minProposalDebatePeriod` between the calls
        if ((_0xdaab26 < (_0x7df41f - _0x7731f3) || msg.sender == _0x0049f8)
            && _0xdaab26 < (_0x7df41f - _0x592eb3)) {
            _0xdaab26 = _0x7df41f;
            _0x038708 *= 2;
            return true;
        } else {
            return false;
        }
    }

    function _0x296b20(address _0xe5b72b) internal returns (DAO _0xc8a246) {
        NewCurator(_0xe5b72b);
        return _0x8b9098._0x6aefb5(_0xe5b72b, 0, 0, _0x7df41f + _0xfc98f1);
    }

    function _0xcce393() constant returns (uint _0xb6b061) {
        // Don't count index 0. It's used by isBlocked() and exists from start
        return _0x19d63b.length - 1;
    }

    function _0x6086a7(uint _0xbd5702) constant returns (address _0xc8a246) {
        return _0x19d63b[_0xbd5702]._0x34675a[0]._0x2698b1;
    }

    function _0xd88836(address _0xd1c955) internal returns (bool) {
        if (_0xaedf88[_0xd1c955] == 0)
            return false;
        Proposal p = _0x19d63b[_0xaedf88[_0xd1c955]];
        if (_0x7df41f > p._0x9a83e2) {
            _0xaedf88[_0xd1c955] = 0;
            return false;
        } else {
            return true;
        }
    }

    function _0x56bcee() returns (bool) {
        return _0xd88836(msg.sender);
    }
}

contract DAO_Creator {
    function _0x6aefb5(
        address _0x217c6c,
        uint _0x4cfd2a,
        uint _0x861886,
        uint _0x97b7f2
    ) returns (DAO _0xc8a246) {

        return new DAO(
            _0x217c6c,
            DAO_Creator(this),
            _0x4cfd2a,
            _0x861886,
            _0x97b7f2,
            msg.sender
        );
    }
}
