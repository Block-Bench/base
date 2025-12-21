// 0xbb9bc244d798123fde783fcc1c72d3bb8c189413#code

/// @title Standard Token Contract.

contract TokenInterface {
    mapping (address => uint256) _0x00fb2c;
    mapping (address => mapping (address => uint256)) _0x2c62e7;

    /// Total amount of tokens
    uint256 public _0x65c7be;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function _0x04991d(address _0xf00075) constant returns (uint256 balance);

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _0xfe828f, uint256 _0x14e65a) returns (bool _0xba9c65);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    /// is approved by `_from`
    /// @param _from The address of the origin of the transfer
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function _0xa46180(address _0x448579, address _0xfe828f, uint256 _0x14e65a) returns (bool _0xba9c65);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    /// its behalf
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function _0x8da64f(address _0xec10eb, uint256 _0x14e65a) returns (bool _0xba9c65);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    /// to spend
    function _0x21f953(
        address _0xf00075,
        address _0xec10eb
    ) constant returns (uint256 _0x801c1f);

    event Transfer(address indexed _0x448579, address indexed _0xfe828f, uint256 _0x14e65a);
    event Approval(
        address indexed _0xf00075,
        address indexed _0xec10eb,
        uint256 _0x14e65a
    );
}

contract Token is TokenInterface {
    // Protects users by preventing the execution of method calls that
    // inadvertently also transferred ether
    modifier _0x5a6397() {if (msg.value > 0) throw; _;}

    function _0x04991d(address _0xf00075) constant returns (uint256 balance) {
        return _0x00fb2c[_0xf00075];
    }

    function transfer(address _0xfe828f, uint256 _0x14e65a) _0x5a6397 returns (bool _0xba9c65) {
        if (_0x00fb2c[msg.sender] >= _0x14e65a && _0x14e65a > 0) {
            _0x00fb2c[msg.sender] -= _0x14e65a;
            _0x00fb2c[_0xfe828f] += _0x14e65a;
            Transfer(msg.sender, _0xfe828f, _0x14e65a);
            return true;
        } else {
           return false;
        }
    }

    function _0xa46180(
        address _0x448579,
        address _0xfe828f,
        uint256 _0x14e65a
    ) _0x5a6397 returns (bool _0xba9c65) {

        if (_0x00fb2c[_0x448579] >= _0x14e65a
            && _0x2c62e7[_0x448579][msg.sender] >= _0x14e65a
            && _0x14e65a > 0) {

            _0x00fb2c[_0xfe828f] += _0x14e65a;
            _0x00fb2c[_0x448579] -= _0x14e65a;
            _0x2c62e7[_0x448579][msg.sender] -= _0x14e65a;
            Transfer(_0x448579, _0xfe828f, _0x14e65a);
            return true;
        } else {
            return false;
        }
    }

    function _0x8da64f(address _0xec10eb, uint256 _0x14e65a) returns (bool _0xba9c65) {
        _0x2c62e7[msg.sender][_0xec10eb] = _0x14e65a;
        Approval(msg.sender, _0xec10eb, _0x14e65a);
        return true;
    }

    function _0x21f953(address _0xf00075, address _0xec10eb) constant returns (uint256 _0x801c1f) {
        return _0x2c62e7[_0xf00075][_0xec10eb];
    }
}

contract ManagedAccountInterface {
    // The only address with permission to withdraw from this account
    address public _0xee21f3;
    // If true, only the owner of the account can receive ether from it
    bool public _0xdf45bb;
    // The sum of ether (in wei) which has been sent to this contract
    uint public _0x2040f0;

    /// @notice Sends `_amount` of wei to _recipient
    /// @param _amount The amount of wei to send to `_recipient`
    /// @param _recipient The address to receive `_amount` of wei
    /// @return True if the send completed
    function _0x2a427c(address _0xdf6be0, uint _0x14e65a) returns (bool);

    event PayOut(address indexed _0xdf6be0, uint _0x14e65a);
}

contract ManagedAccount is ManagedAccountInterface{

    // The constructor sets the owner of the account
    function ManagedAccount(address _0xf00075, bool _0x872b08) {
        if (block.timestamp > 0) { _0xee21f3 = _0xf00075; }
        _0xdf45bb = _0x872b08;
    }

    // When the contract receives a transaction without data this is called.
    // It counts the amount of ether it receives and stores it in
    // accumulatedInput.
    function() {
        _0x2040f0 += msg.value;
    }

    function _0x2a427c(address _0xdf6be0, uint _0x14e65a) returns (bool) {
        if (msg.sender != _0xee21f3 || msg.value > 0 || (_0xdf45bb && _0xdf6be0 != _0xee21f3))
            throw;
        if (_0xdf6be0.call.value(_0x14e65a)()) {
            PayOut(_0xdf6be0, _0x14e65a);
            return true;
        } else {
            return false;
        }
    }
}

contract TokenCreationInterface {

    // End of token creation, in Unix time
    uint public _0xc6634f;
    // Minimum fueling goal of the token creation, denominated in tokens to
    // be created
    uint public _0x0355dc;
    // True if the DAO reached its minimum fueling goal, false otherwise
    bool public _0x4207a7;
    // For DAO splits - if privateCreation is 0, then it is a public token
    // creation, otherwise only the address stored in privateCreation is
    // allowed to create tokens
    address public _0x74de6f;
    // hold extra ether which has been sent after the DAO token
    // creation rate has increased
    ManagedAccount public _0x1c7a69;
    // tracks the amount of wei given from each contributor (used for refund)
    mapping (address => uint256) _0xc86b83;

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
    function _0x21c554(address _0xeba002) returns (bool _0xba9c65);

    /// @notice Refund `msg.sender` in the case the Token Creation did
    /// not reach its minimum fueling goal
    function _0x3d10b4();

    /// @return The divisor used to calculate the token creation rate during
    /// the creation phase
    function _0x38d505() constant returns (uint _0x38d505);

    event FuelingToDate(uint value);
    event CreatedToken(address indexed _0x59448d, uint _0xb39768);
    event Refund(address indexed _0x59448d, uint value);
}

contract TokenCreation is TokenCreationInterface, Token {
    function TokenCreation(
        uint _0x4117a3,
        uint _0x4a2595,
        address _0x05a501) {

        _0xc6634f = _0x4a2595;
        _0x0355dc = _0x4117a3;
        _0x74de6f = _0x05a501;
        _0x1c7a69 = new ManagedAccount(address(this), true);
    }

    function _0x21c554(address _0xeba002) returns (bool _0xba9c65) {
        if (_0xcbb481 < _0xc6634f && msg.value > 0
            && (_0x74de6f == 0 || _0x74de6f == msg.sender)) {

            uint _0x2d0a48 = (msg.value * 20) / _0x38d505();
            _0x1c7a69.call.value(msg.value - _0x2d0a48)();
            _0x00fb2c[_0xeba002] += _0x2d0a48;
            _0x65c7be += _0x2d0a48;
            _0xc86b83[_0xeba002] += msg.value;
            CreatedToken(_0xeba002, _0x2d0a48);
            if (_0x65c7be >= _0x0355dc && !_0x4207a7) {
                _0x4207a7 = true;
                FuelingToDate(_0x65c7be);
            }
            return true;
        }
        throw;
    }

    function _0x3d10b4() _0x5a6397 {
        if (_0xcbb481 > _0xc6634f && !_0x4207a7) {
            // Get extraBalance - will only succeed when called for the first time
            if (_0x1c7a69.balance >= _0x1c7a69._0x2040f0())
                _0x1c7a69._0x2a427c(address(this), _0x1c7a69._0x2040f0());

            // Execute refund
            if (msg.sender.call.value(_0xc86b83[msg.sender])()) {
                Refund(msg.sender, _0xc86b83[msg.sender]);
                _0x65c7be -= _0x00fb2c[msg.sender];
                _0x00fb2c[msg.sender] = 0;
                _0xc86b83[msg.sender] = 0;
            }
        }
    }

    function _0x38d505() constant returns (uint _0x38d505) {
        // The number of (base unit) tokens per wei is calculated
        // as `msg.value` * 20 / `divisor`
        // The fueling period starts with a 1:1 ratio
        if (_0xc6634f - 2 weeks > _0xcbb481) {
            return 20;
        // Followed by 10 days with a daily creation rate increase of 5%
        } else if (_0xc6634f - 4 days > _0xcbb481) {
            return (20 + (_0xcbb481 - (_0xc6634f - 2 weeks)) / (1 days));
        // The last 4 days there is a constant creation rate ratio of 1:1.5
        } else {
            return 30;
        }
    }
}

contract DAOInterface {

    // The amount of days for which people who try to participate in the
    // creation by calling the fallback function will still get their ether back
    uint constant _0x47195d = 40 days;
    // The minimum debate period that a generic proposal can have
    uint constant _0x3ac53a = 2 weeks;
    // The minimum debate period that a split proposal can have
    uint constant _0x8c565a = 1 weeks;
    // Period of days inside which it's possible to execute a DAO split
    uint constant _0x30d997 = 27 days;
    // Period of time after which the minimum Quorum is halved
    uint constant _0x4e7ea2 = 25 weeks;
    // Period after which a proposal is closed
    // (used in the case `executeProposal` fails because it throws)
    uint constant _0xf46f6a = 10 days;
    // Denotes the maximum proposal deposit that can be given. It is given as
    // a fraction of total Ether spent plus balance of the DAO
    uint constant _0xb881ef = 100;

    // Proposals to spend the DAO's ether or to choose a new Curator
    Proposal[] public _0x6833df;
    // The quorum needed for each proposal is partially calculated by
    // totalSupply / minQuorumDivisor
    uint public _0x227f45;
    // The unix time of the last time quorum was reached on a proposal
    uint  public _0xda4f4d;

    // Address of the curator
    address public _0xf39aa1;
    // The whitelist: List of addresses the DAO is allowed to send ether to
    mapping (address => bool) public _0xd74f28;

    // Tracks the addresses that own Reward Tokens. Those addresses can only be
    // DAOs that have split from the original DAO. Conceptually, Reward Tokens
    // represent the proportion of the rewards that the DAO has the right to
    // receive. These Reward Tokens are generated when the DAO spends ether.
    mapping (address => uint) public _0x53460a;
    // Total supply of rewardToken
    uint public _0x90fbe4;

    // The account used to manage the rewards which are to be distributed to the
    // DAO Token Holders of this DAO
    ManagedAccount public _0x617363;

    // The account used to manage the rewards which are to be distributed to
    // any DAO that holds Reward Tokens
    ManagedAccount public DAOrewardAccount;

    // Amount of rewards (in wei) already paid out to a certain DAO
    mapping (address => uint) public DAOpaidOut;

    // Amount of rewards (in wei) already paid out to a certain address
    mapping (address => uint) public _0x1e231f;
    // Map of addresses blocked during a vote (not allowed to transfer DAO
    // tokens). The address points to the proposal ID.
    mapping (address => uint) public _0xf37388;

    // The minimum deposit (in wei) required to submit any proposal that is not
    // requesting a new Curator (no deposit is required for splits)
    uint public _0x4db59b;

    // the accumulated sum of all current proposal deposits
    uint _0x34ced8;

    // Contract that is able to create a new DAO (with the same code as
    // this one), used for splits
    DAO_Creator public _0x0492aa;

    // A proposal with `newCurator == false` represents a transaction
    // to be issued by this DAO
    // A proposal with `newCurator == true` represents a DAO split
    struct Proposal {
        // The address where the `amount` will go to if the proposal is accepted
        // or if `newCurator` is true, the proposed Curator of
        // the new DAO).
        address _0x3933b1;
        // The amount to transfer to `recipient` if the proposal is accepted.
        uint _0xb39768;
        // A plain text description of the proposal
        string _0xf0c0ad;
        // A unix timestamp, denoting the end of the voting period
        uint _0xec09f1;
        // True if the proposal's votes have yet to be counted, otherwise False
        bool _0x0daec4;
        // True if quorum has been reached, the votes have been counted, and
        // the majority said yes
        bool _0xefee8f;
        // A hash to check validity of a proposal
        bytes32 _0xf922fc;
        // Deposit in wei the creator added when submitting their proposal. It
        // is taken from the msg.value of a newProposal call.
        uint _0x4db59b;
        // True if this proposal is to assign a new Curator
        bool _0xe658d9;
        // Data needed for splitting the DAO
        SplitData[] _0xe89d83;
        // Number of Tokens in favor of the proposal
        uint _0xd97bef;
        // Number of Tokens opposed to the proposal
        uint _0x0b1fec;
        // Simple mapping to check if a shareholder has voted for it
        mapping (address => bool) _0xd089bd;
        // Simple mapping to check if a shareholder has voted against it
        mapping (address => bool) _0x3c3f4d;
        // Address of the shareholder who created the proposal
        address _0x40b282;
    }

    // Used only in the case of a newCurator proposal.
    struct SplitData {
        // The balance of the current DAO minus the deposit at the time of split
        uint _0x3577f0;
        // The total amount of DAO Tokens in existence at the time of split.
        uint _0x65c7be;
        // Amount of Reward Tokens owned by the DAO at the time of split.
        uint _0x53460a;
        // The new DAO contract created at the time of split.
        DAO _0xefe9c1;
    }

    // Used to restrict access to certain functions to only DAO Token Holders
    modifier _0x9c814d {}

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
    function () returns (bool _0xba9c65);

    /// @dev This function is used to send ether back
    /// to the DAO, it can also be used to receive payments that should not be
    /// counted as rewards (donations, grants, etc.)
    /// @return Whether the DAO received the ether successfully
    function _0xe7b97a() returns(bool);

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
    function _0x2bf0e1(
        address _0xdf6be0,
        uint _0x14e65a,
        string _0xed124e,
        bytes _0x1ec86f,
        uint _0x17066f,
        bool _0xa0c067
    ) _0x9c814d returns (uint _0x6ce912);

    /// @notice Check that the proposal with the ID `_proposalID` matches the
    /// transaction which sends `_amount` with data `_transactionData`
    /// to `_recipient`
    /// @param _proposalID The proposal ID
    /// @param _recipient The recipient of the proposed transaction
    /// @param _amount The amount of wei to be sent in the proposed transaction
    /// @param _transactionData The data of the proposed transaction
    /// @return Whether the proposal ID matches the transaction data or not
    function _0x4c4454(
        uint _0x6ce912,
        address _0xdf6be0,
        uint _0x14e65a,
        bytes _0x1ec86f
    ) constant returns (bool _0xdc5a95);

    /// @notice Vote on proposal `_proposalID` with `_supportsProposal`
    /// @param _proposalID The proposal ID
    /// @param _supportsProposal Yes/No - support of the proposal
    /// @return The vote ID.
    function _0x9dca67(
        uint _0x6ce912,
        bool _0x56f125
    ) _0x9c814d returns (uint _0x7a311a);

    /// @notice Checks whether proposal `_proposalID` with transaction data
    /// `_transactionData` has been voted for or rejected, and executes the
    /// transaction in the case it has been voted for.
    /// @param _proposalID The proposal ID
    /// @param _transactionData The data of the proposed transaction
    /// @return Whether the proposed transaction has been executed or not
    function _0xdeae60(
        uint _0x6ce912,
        bytes _0x1ec86f
    ) returns (bool _0x666330);

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
    function _0x2c9bcf(
        uint _0x6ce912,
        address _0xa0c067
    ) returns (bool _0x666330);

    /// @dev can only be called by the DAO itself through a proposal
    /// updates the contract of the DAO by sending all ether and rewardTokens
    /// to the new DAO. The new DAO needs to be approved by the Curator
    /// @param _newContract the address of the new contract
    function _0xb6ab1f(address _0xb0e571);

    /// @notice Add a new possible recipient `_recipient` to the whitelist so
    /// that the DAO can send transactions to them (using proposals)
    /// @param _recipient New recipient address
    /// @dev Can only be called by the current Curator
    /// @return Whether successful or not
    function _0xbcd432(address _0xdf6be0, bool _0x4e8d9e) external returns (bool _0x666330);

    /// @notice Change the minimum deposit required to submit a proposal
    /// @param _proposalDeposit The new proposal deposit
    /// @dev Can only be called by this DAO (through proposals with the
    /// recipient being this DAO itself)
    function _0x0cdf3e(uint _0x8efc40) external;

    /// @notice Move rewards from the DAORewards managed account
    /// @param _toMembers If true rewards are moved to the actual reward account
    ///                   for the DAO. If not then it's moved to the DAO itself
    /// @return Whether the call was successful
    function _0x6f979c(bool _0x701973) external returns (bool _0x666330);

    /// @notice Get my portion of the reward that was sent to `rewardAccount`
    /// @return Whether the call was successful
    function _0xef5fc0() returns(bool _0x666330);

    /// @notice Withdraw `_account`'s portion of the reward from `rewardAccount`
    /// to `_account`'s balance
    /// @return Whether the call was successful
    function _0x08710d(address _0x4de415) internal returns (bool _0x666330);

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`. Prior to this
    /// getMyReward() is called.
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transfered
    /// @return Whether the transfer was successful or not
    function _0x8e2cb4(address _0xfe828f, uint256 _0x14e65a) returns (bool _0xba9c65);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    /// is approved by `_from`. Prior to this getMyReward() is called.
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transfered
    /// @return Whether the transfer was successful or not
    function _0x0a9f44(
        address _0x448579,
        address _0xfe828f,
        uint256 _0x14e65a
    ) returns (bool _0xba9c65);

    /// @notice Doubles the 'minQuorumDivisor' in the case quorum has not been
    /// achieved in 52 weeks
    /// @return Whether the change was successful or not
    function _0xd84987() returns (bool _0x666330);

    /// @return total number of proposals ever created
    function _0xf761f2() constant returns (uint _0xb1dba5);

    /// @param _proposalID Id of the new curator proposal
    /// @return Address of the new DAO
    function _0xabb88e(uint _0x6ce912) constant returns (address _0x80ce34);

    /// @param _account The address of the account which is checked.
    /// @return Whether the account is blocked (not allowed to transfer tokens) or not.
    function _0x039886(address _0x4de415) internal returns (bool);

    /// @notice If the caller is blocked by a proposal whose voting deadline
    /// has exprired then unblock him.
    /// @return Whether the account is blocked (not allowed to transfer tokens) or not.
    function _0x6aa676() returns (bool);

    event ProposalAdded(
        uint indexed _0x5b189a,
        address _0x3933b1,
        uint _0xb39768,
        bool _0xe658d9,
        string _0xf0c0ad
    );
    event Voted(uint indexed _0x5b189a, bool _0x81fc9b, address indexed _0x0084fa);
    event ProposalTallied(uint indexed _0x5b189a, bool _0x6722ed, uint _0xf34f3c);
    event NewCurator(address indexed _0xa0c067);
    event AllowedRecipientChanged(address indexed _0xdf6be0, bool _0x4e8d9e);
}

// The DAO contract itself
contract DAO is DAOInterface, Token, TokenCreation {

    // Modifier that allows only shareholders to vote and create new proposals
    modifier _0x9c814d {
        if (_0x04991d(msg.sender) == 0) throw;
            _;
    }

    function DAO(
        address _0xdbe3a8,
        DAO_Creator _0xdd62cc,
        uint _0x8efc40,
        uint _0x4117a3,
        uint _0x4a2595,
        address _0x05a501
    ) TokenCreation(_0x4117a3, _0x4a2595, _0x05a501) {

        _0xf39aa1 = _0xdbe3a8;
        _0x0492aa = _0xdd62cc;
        _0x4db59b = _0x8efc40;
        _0x617363 = new ManagedAccount(address(this), false);
        DAOrewardAccount = new ManagedAccount(address(this), false);
        if (address(_0x617363) == 0)
            throw;
        if (address(DAOrewardAccount) == 0)
            throw;
        _0xda4f4d = _0xcbb481;
        _0x227f45 = 5; // sets the minimal quorum to 20%
        _0x6833df.length = 1; // avoids a proposal with ID 0 because it is used

        _0xd74f28[address(this)] = true;
        _0xd74f28[_0xf39aa1] = true;
    }

    function () returns (bool _0xba9c65) {
        if (_0xcbb481 < _0xc6634f + _0x47195d && msg.sender != address(_0x1c7a69))
            return _0x21c554(msg.sender);
        else
            return _0xe7b97a();
    }

    function _0xe7b97a() returns (bool) {
        return true;
    }

    function _0x2bf0e1(
        address _0xdf6be0,
        uint _0x14e65a,
        string _0xed124e,
        bytes _0x1ec86f,
        uint _0x17066f,
        bool _0xa0c067
    ) _0x9c814d returns (uint _0x6ce912) {

        // Sanity check
        if (_0xa0c067 && (
            _0x14e65a != 0
            || _0x1ec86f.length != 0
            || _0xdf6be0 == _0xf39aa1
            || msg.value > 0
            || _0x17066f < _0x8c565a)) {
            throw;
        } else if (
            !_0xa0c067
            && (!_0x67a1a9(_0xdf6be0) || (_0x17066f <  _0x3ac53a))
        ) {
            throw;
        }

        if (_0x17066f > 8 weeks)
            throw;

        if (!_0x4207a7
            || _0xcbb481 < _0xc6634f
            || (msg.value < _0x4db59b && !_0xa0c067)) {

            throw;
        }

        if (_0xcbb481 + _0x17066f < _0xcbb481)
            throw;

        if (msg.sender == address(this))
            throw;

        _0x6ce912 = _0x6833df.length++;
        Proposal p = _0x6833df[_0x6ce912];
        p._0x3933b1 = _0xdf6be0;
        p._0xb39768 = _0x14e65a;
        p._0xf0c0ad = _0xed124e;
        p._0xf922fc = _0x5fd524(_0xdf6be0, _0x14e65a, _0x1ec86f);
        p._0xec09f1 = _0xcbb481 + _0x17066f;
        p._0x0daec4 = true;
        //p.proposalPassed = False; // that's default
        p._0xe658d9 = _0xa0c067;
        if (_0xa0c067)
            p._0xe89d83.length++;
        p._0x40b282 = msg.sender;
        p._0x4db59b = msg.value;

        _0x34ced8 += msg.value;

        ProposalAdded(
            _0x6ce912,
            _0xdf6be0,
            _0x14e65a,
            _0xa0c067,
            _0xed124e
        );
    }

    function _0x4c4454(
        uint _0x6ce912,
        address _0xdf6be0,
        uint _0x14e65a,
        bytes _0x1ec86f
    ) _0x5a6397 constant returns (bool _0xdc5a95) {
        Proposal p = _0x6833df[_0x6ce912];
        return p._0xf922fc == _0x5fd524(_0xdf6be0, _0x14e65a, _0x1ec86f);
    }

    function _0x9dca67(
        uint _0x6ce912,
        bool _0x56f125
    ) _0x9c814d _0x5a6397 returns (uint _0x7a311a) {

        Proposal p = _0x6833df[_0x6ce912];
        if (p._0xd089bd[msg.sender]
            || p._0x3c3f4d[msg.sender]
            || _0xcbb481 >= p._0xec09f1) {

            throw;
        }

        if (_0x56f125) {
            p._0xd97bef += _0x00fb2c[msg.sender];
            p._0xd089bd[msg.sender] = true;
        } else {
            p._0x0b1fec += _0x00fb2c[msg.sender];
            p._0x3c3f4d[msg.sender] = true;
        }

        if (_0xf37388[msg.sender] == 0) {
            _0xf37388[msg.sender] = _0x6ce912;
        } else if (p._0xec09f1 > _0x6833df[_0xf37388[msg.sender]]._0xec09f1) {
            // this proposal's voting deadline is further into the future than
            // the proposal that blocks the sender so make it the blocker
            _0xf37388[msg.sender] = _0x6ce912;
        }

        Voted(_0x6ce912, _0x56f125, msg.sender);
    }

    function _0xdeae60(
        uint _0x6ce912,
        bytes _0x1ec86f
    ) _0x5a6397 returns (bool _0x666330) {

        Proposal p = _0x6833df[_0x6ce912];

        uint _0x75565c = p._0xe658d9
            ? _0x30d997
            : _0xf46f6a;
        // If we are over deadline and waiting period, assert proposal is closed
        if (p._0x0daec4 && _0xcbb481 > p._0xec09f1 + _0x75565c) {
            _0x3e6166(_0x6ce912);
            return;
        }

        // Check if the proposal can be executed
        if (_0xcbb481 < p._0xec09f1  // has the voting deadline arrived?
            // Have the votes been counted?
            || !p._0x0daec4
            // Does the transaction code match the proposal?
            || p._0xf922fc != _0x5fd524(p._0x3933b1, p._0xb39768, _0x1ec86f)) {

            throw;
        }

        // If the curator removed the recipient from the whitelist, close the proposal
        // in order to free the deposit and allow unblocking of voters
        if (!_0x67a1a9(p._0x3933b1)) {
            _0x3e6166(_0x6ce912);
            p._0x40b282.send(p._0x4db59b);
            return;
        }

        bool _0x24a2f2 = true;

        if (p._0xb39768 > _0x018f5b())
            _0x24a2f2 = false;

        uint _0xf34f3c = p._0xd97bef + p._0x0b1fec;

        // require 53% for calling newContract()
        if (_0x1ec86f.length >= 4 && _0x1ec86f[0] == 0x68
            && _0x1ec86f[1] == 0x37 && _0x1ec86f[2] == 0xff
            && _0x1ec86f[3] == 0x1e
            && _0xf34f3c < _0x969477(_0x018f5b() + _0x53460a[address(this)])) {

                _0x24a2f2 = false;
        }

        if (_0xf34f3c >= _0x969477(p._0xb39768)) {
            if (!p._0x40b282.send(p._0x4db59b))
                throw;

            _0xda4f4d = _0xcbb481;
            // set the minQuorum to 20% again, in the case it has been reached
            if (_0xf34f3c > _0x65c7be / 5)
                _0x227f45 = 5;
        }

        // Execute result
        if (_0xf34f3c >= _0x969477(p._0xb39768) && p._0xd97bef > p._0x0b1fec && _0x24a2f2) {
            if (!p._0x3933b1.call.value(p._0xb39768)(_0x1ec86f))
                throw;

            p._0xefee8f = true;
            _0x666330 = true;

            // only create reward tokens when ether is not sent to the DAO itself and
            // related addresses. Proxy addresses should be forbidden by the curator.
            if (p._0x3933b1 != address(this) && p._0x3933b1 != address(_0x617363)
                && p._0x3933b1 != address(DAOrewardAccount)
                && p._0x3933b1 != address(_0x1c7a69)
                && p._0x3933b1 != address(_0xf39aa1)) {

                _0x53460a[address(this)] += p._0xb39768;
                _0x90fbe4 += p._0xb39768;
            }
        }

        _0x3e6166(_0x6ce912);

        // Initiate event
        ProposalTallied(_0x6ce912, _0x666330, _0xf34f3c);
    }

    function _0x3e6166(uint _0x6ce912) internal {
        Proposal p = _0x6833df[_0x6ce912];
        if (p._0x0daec4)
            _0x34ced8 -= p._0x4db59b;
        p._0x0daec4 = false;
    }

    function _0x2c9bcf(
        uint _0x6ce912,
        address _0xa0c067
    ) _0x5a6397 _0x9c814d returns (bool _0x666330) {

        Proposal p = _0x6833df[_0x6ce912];

        // Sanity check

        if (_0xcbb481 < p._0xec09f1  // has the voting deadline arrived?
            //The request for a split expires XX days after the voting deadline
            || _0xcbb481 > p._0xec09f1 + _0x30d997
            // Does the new Curator address match?
            || p._0x3933b1 != _0xa0c067
            // Is it a new curator proposal?
            || !p._0xe658d9
            // Have you voted for this split?
            || !p._0xd089bd[msg.sender]
            // Did you already vote on another proposal?
            || (_0xf37388[msg.sender] != _0x6ce912 && _0xf37388[msg.sender] != 0) )  {

            throw;
        }

        // If the new DAO doesn't exist yet, create the new DAO and store the
        // current split data
        if (address(p._0xe89d83[0]._0xefe9c1) == 0) {
            p._0xe89d83[0]._0xefe9c1 = _0x026264(_0xa0c067);
            // Call depth limit reached, etc.
            if (address(p._0xe89d83[0]._0xefe9c1) == 0)
                throw;
            // should never happen
            if (this.balance < _0x34ced8)
                throw;
            p._0xe89d83[0]._0x3577f0 = _0x018f5b();
            p._0xe89d83[0]._0x53460a = _0x53460a[address(this)];
            p._0xe89d83[0]._0x65c7be = _0x65c7be;
            p._0xefee8f = true;
        }

        // Move ether and assign new Tokens
        uint _0x1c42aa =
            (_0x00fb2c[msg.sender] * p._0xe89d83[0]._0x3577f0) /
            p._0xe89d83[0]._0x65c7be;
        if (p._0xe89d83[0]._0xefe9c1._0x21c554.value(_0x1c42aa)(msg.sender) == false)
            throw;

        // Assign reward rights to new DAO
        uint _0x724aeb =
            (_0x00fb2c[msg.sender] * p._0xe89d83[0]._0x53460a) /
            p._0xe89d83[0]._0x65c7be;

        uint _0xb59190 = DAOpaidOut[address(this)] * _0x724aeb /
            _0x53460a[address(this)];

        _0x53460a[address(p._0xe89d83[0]._0xefe9c1)] += _0x724aeb;
        if (_0x53460a[address(this)] < _0x724aeb)
            throw;
        _0x53460a[address(this)] -= _0x724aeb;

        DAOpaidOut[address(p._0xe89d83[0]._0xefe9c1)] += _0xb59190;
        if (DAOpaidOut[address(this)] < _0xb59190)
            throw;
        DAOpaidOut[address(this)] -= _0xb59190;

        // Burn DAO Tokens
        Transfer(msg.sender, 0, _0x00fb2c[msg.sender]);
        _0x08710d(msg.sender); // be nice, and get his rewards
        _0x65c7be -= _0x00fb2c[msg.sender];
        _0x00fb2c[msg.sender] = 0;
        _0x1e231f[msg.sender] = 0;
        return true;
    }

    function _0xb6ab1f(address _0xb0e571){
        if (msg.sender != address(this) || !_0xd74f28[_0xb0e571]) return;
        // move all ether
        if (!_0xb0e571.call.value(address(this).balance)()) {
            throw;
        }

        //move all reward tokens
        _0x53460a[_0xb0e571] += _0x53460a[address(this)];
        _0x53460a[address(this)] = 0;
        DAOpaidOut[_0xb0e571] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function _0x6f979c(bool _0x701973) external _0x5a6397 returns (bool _0x666330) {
        DAO _0xb852fa = DAO(msg.sender);

        if ((_0x53460a[msg.sender] * DAOrewardAccount._0x2040f0()) /
            _0x90fbe4 < DAOpaidOut[msg.sender])
            throw;

        uint _0x2ada3c =
            (_0x53460a[msg.sender] * DAOrewardAccount._0x2040f0()) /
            _0x90fbe4 - DAOpaidOut[msg.sender];
        if(_0x701973) {
            if (!DAOrewardAccount._0x2a427c(_0xb852fa._0x617363(), _0x2ada3c))
                throw;
            }
        else {
            if (!DAOrewardAccount._0x2a427c(_0xb852fa, _0x2ada3c))
                throw;
        }
        DAOpaidOut[msg.sender] += _0x2ada3c;
        return true;
    }

    function _0xef5fc0() _0x5a6397 returns (bool _0x666330) {
        return _0x08710d(msg.sender);
    }

    function _0x08710d(address _0x4de415) _0x5a6397 internal returns (bool _0x666330) {
        if ((_0x04991d(_0x4de415) * _0x617363._0x2040f0()) / _0x65c7be < _0x1e231f[_0x4de415])
            throw;

        uint _0x2ada3c =
            (_0x04991d(_0x4de415) * _0x617363._0x2040f0()) / _0x65c7be - _0x1e231f[_0x4de415];
        if (!_0x617363._0x2a427c(_0x4de415, _0x2ada3c))
            throw;
        _0x1e231f[_0x4de415] += _0x2ada3c;
        return true;
    }

    function transfer(address _0xfe828f, uint256 _0x39982a) returns (bool _0xba9c65) {
        if (_0x4207a7
            && _0xcbb481 > _0xc6634f
            && !_0x039886(msg.sender)
            && _0x550e49(msg.sender, _0xfe828f, _0x39982a)
            && super.transfer(_0xfe828f, _0x39982a)) {

            return true;
        } else {
            throw;
        }
    }

    function _0x8e2cb4(address _0xfe828f, uint256 _0x39982a) returns (bool _0xba9c65) {
        if (!_0xef5fc0())
            throw;
        return transfer(_0xfe828f, _0x39982a);
    }

    function _0xa46180(address _0x448579, address _0xfe828f, uint256 _0x39982a) returns (bool _0xba9c65) {
        if (_0x4207a7
            && _0xcbb481 > _0xc6634f
            && !_0x039886(_0x448579)
            && _0x550e49(_0x448579, _0xfe828f, _0x39982a)
            && super._0xa46180(_0x448579, _0xfe828f, _0x39982a)) {

            return true;
        } else {
            throw;
        }
    }

    function _0x0a9f44(
        address _0x448579,
        address _0xfe828f,
        uint256 _0x39982a
    ) returns (bool _0xba9c65) {

        if (!_0x08710d(_0x448579))
            throw;
        return _0xa46180(_0x448579, _0xfe828f, _0x39982a);
    }

    function _0x550e49(
        address _0x448579,
        address _0xfe828f,
        uint256 _0x39982a
    ) internal returns (bool _0xba9c65) {

        uint _0x550e49 = _0x1e231f[_0x448579] * _0x39982a / _0x04991d(_0x448579);
        if (_0x550e49 > _0x1e231f[_0x448579])
            throw;
        _0x1e231f[_0x448579] -= _0x550e49;
        _0x1e231f[_0xfe828f] += _0x550e49;
        return true;
    }

    function _0x0cdf3e(uint _0x8efc40) _0x5a6397 external {
        if (msg.sender != address(this) || _0x8efc40 > (_0x018f5b() + _0x53460a[address(this)])
            / _0xb881ef) {

            throw;
        }
        _0x4db59b = _0x8efc40;
    }

    function _0xbcd432(address _0xdf6be0, bool _0x4e8d9e) _0x5a6397 external returns (bool _0x666330) {
        if (msg.sender != _0xf39aa1)
            throw;
        _0xd74f28[_0xdf6be0] = _0x4e8d9e;
        AllowedRecipientChanged(_0xdf6be0, _0x4e8d9e);
        return true;
    }

    function _0x67a1a9(address _0xdf6be0) internal returns (bool _0xf596ea) {
        if (_0xd74f28[_0xdf6be0]
            || (_0xdf6be0 == address(_0x1c7a69)
                // only allowed when at least the amount held in the
                // extraBalance account has been spent from the DAO
                && _0x90fbe4 > _0x1c7a69._0x2040f0()))
            return true;
        else
            return false;
    }

    function _0x018f5b() constant returns (uint _0x49ab13) {
        return this.balance - _0x34ced8;
    }

    function _0x969477(uint _0x39982a) internal constant returns (uint _0xb7cba4) {
        // minimum of 20% and maximum of 53.33%
        return _0x65c7be / _0x227f45 +
            (_0x39982a * _0x65c7be) / (3 * (_0x018f5b() + _0x53460a[address(this)]));
    }

    function _0xd84987() returns (bool _0x666330) {
        // this can only be called after `quorumHalvingPeriod` has passed or at anytime
        // by the curator with a delay of at least `minProposalDebatePeriod` between the calls
        if ((_0xda4f4d < (_0xcbb481 - _0x4e7ea2) || msg.sender == _0xf39aa1)
            && _0xda4f4d < (_0xcbb481 - _0x3ac53a)) {
            if (1 == 1) { _0xda4f4d = _0xcbb481; }
            _0x227f45 *= 2;
            return true;
        } else {
            return false;
        }
    }

    function _0x026264(address _0xa0c067) internal returns (DAO _0x80ce34) {
        NewCurator(_0xa0c067);
        return _0x0492aa._0x7a8b97(_0xa0c067, 0, 0, _0xcbb481 + _0x30d997);
    }

    function _0xf761f2() constant returns (uint _0xb1dba5) {
        // Don't count index 0. It's used by isBlocked() and exists from start
        return _0x6833df.length - 1;
    }

    function _0xabb88e(uint _0x6ce912) constant returns (address _0x80ce34) {
        return _0x6833df[_0x6ce912]._0xe89d83[0]._0xefe9c1;
    }

    function _0x039886(address _0x4de415) internal returns (bool) {
        if (_0xf37388[_0x4de415] == 0)
            return false;
        Proposal p = _0x6833df[_0xf37388[_0x4de415]];
        if (_0xcbb481 > p._0xec09f1) {
            _0xf37388[_0x4de415] = 0;
            return false;
        } else {
            return true;
        }
    }

    function _0x6aa676() returns (bool) {
        return _0x039886(msg.sender);
    }
}

contract DAO_Creator {
    function _0x7a8b97(
        address _0xdbe3a8,
        uint _0x8efc40,
        uint _0x4117a3,
        uint _0x4a2595
    ) returns (DAO _0x80ce34) {

        return new DAO(
            _0xdbe3a8,
            DAO_Creator(this),
            _0x8efc40,
            _0x4117a3,
            _0x4a2595,
            msg.sender
        );
    }
}
