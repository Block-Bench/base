// 0xbb9bc244d798123fde783fcc1c72d3bb8c189413#code

/// @title Standard Token Contract.

contract TokenInterface {
    mapping (address => uint256) _0xdd94a7;
    mapping (address => mapping (address => uint256)) _0x164afe;

    /// Total amount of tokens
    uint256 public _0x443869;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function _0x531eea(address _0x2fd574) constant returns (uint256 balance);

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _0x6cad2a, uint256 _0x91cc45) returns (bool _0x67128b);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    /// is approved by `_from`
    /// @param _from The address of the origin of the transfer
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function _0xe1f49f(address _0xd0fe77, address _0x6cad2a, uint256 _0x91cc45) returns (bool _0x67128b);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    /// its behalf
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function _0x671a0b(address _0xeb66c6, uint256 _0x91cc45) returns (bool _0x67128b);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    /// to spend
    function _0x59f101(
        address _0x2fd574,
        address _0xeb66c6
    ) constant returns (uint256 _0x450c8e);

    event Transfer(address indexed _0xd0fe77, address indexed _0x6cad2a, uint256 _0x91cc45);
    event Approval(
        address indexed _0x2fd574,
        address indexed _0xeb66c6,
        uint256 _0x91cc45
    );
}

contract Token is TokenInterface {
    // Protects users by preventing the execution of method calls that
    // inadvertently also transferred ether
    modifier _0xc6f04b() {if (msg.value > 0) throw; _;}

    function _0x531eea(address _0x2fd574) constant returns (uint256 balance) {
        return _0xdd94a7[_0x2fd574];
    }

    function transfer(address _0x6cad2a, uint256 _0x91cc45) _0xc6f04b returns (bool _0x67128b) {
        if (_0xdd94a7[msg.sender] >= _0x91cc45 && _0x91cc45 > 0) {
            _0xdd94a7[msg.sender] -= _0x91cc45;
            _0xdd94a7[_0x6cad2a] += _0x91cc45;
            Transfer(msg.sender, _0x6cad2a, _0x91cc45);
            return true;
        } else {
           return false;
        }
    }

    function _0xe1f49f(
        address _0xd0fe77,
        address _0x6cad2a,
        uint256 _0x91cc45
    ) _0xc6f04b returns (bool _0x67128b) {

        if (_0xdd94a7[_0xd0fe77] >= _0x91cc45
            && _0x164afe[_0xd0fe77][msg.sender] >= _0x91cc45
            && _0x91cc45 > 0) {

            _0xdd94a7[_0x6cad2a] += _0x91cc45;
            _0xdd94a7[_0xd0fe77] -= _0x91cc45;
            _0x164afe[_0xd0fe77][msg.sender] -= _0x91cc45;
            Transfer(_0xd0fe77, _0x6cad2a, _0x91cc45);
            return true;
        } else {
            return false;
        }
    }

    function _0x671a0b(address _0xeb66c6, uint256 _0x91cc45) returns (bool _0x67128b) {
        _0x164afe[msg.sender][_0xeb66c6] = _0x91cc45;
        Approval(msg.sender, _0xeb66c6, _0x91cc45);
        return true;
    }

    function _0x59f101(address _0x2fd574, address _0xeb66c6) constant returns (uint256 _0x450c8e) {
        return _0x164afe[_0x2fd574][_0xeb66c6];
    }
}

contract ManagedAccountInterface {
    // The only address with permission to withdraw from this account
    address public _0x50695d;
    // If true, only the owner of the account can receive ether from it
    bool public _0x957040;
    // The sum of ether (in wei) which has been sent to this contract
    uint public _0x5af08d;

    /// @notice Sends `_amount` of wei to _recipient
    /// @param _amount The amount of wei to send to `_recipient`
    /// @param _recipient The address to receive `_amount` of wei
    /// @return True if the send completed
    function _0x23074c(address _0xe28eb3, uint _0x91cc45) returns (bool);

    event PayOut(address indexed _0xe28eb3, uint _0x91cc45);
}

contract ManagedAccount is ManagedAccountInterface{

    // The constructor sets the owner of the account
    function ManagedAccount(address _0x2fd574, bool _0x8c0b13) {
        _0x50695d = _0x2fd574;
        if (true) { _0x957040 = _0x8c0b13; }
    }

    // When the contract receives a transaction without data this is called.
    // It counts the amount of ether it receives and stores it in
    // accumulatedInput.
    function() {
        _0x5af08d += msg.value;
    }

    function _0x23074c(address _0xe28eb3, uint _0x91cc45) returns (bool) {
        if (msg.sender != _0x50695d || msg.value > 0 || (_0x957040 && _0xe28eb3 != _0x50695d))
            throw;
        if (_0xe28eb3.call.value(_0x91cc45)()) {
            PayOut(_0xe28eb3, _0x91cc45);
            return true;
        } else {
            return false;
        }
    }
}

contract TokenCreationInterface {

    // End of token creation, in Unix time
    uint public _0x42441d;
    // Minimum fueling goal of the token creation, denominated in tokens to
    // be created
    uint public _0x1a2025;
    // True if the DAO reached its minimum fueling goal, false otherwise
    bool public _0x9d43e9;
    // For DAO splits - if privateCreation is 0, then it is a public token
    // creation, otherwise only the address stored in privateCreation is
    // allowed to create tokens
    address public _0x57f4a9;
    // hold extra ether which has been sent after the DAO token
    // creation rate has increased
    ManagedAccount public _0x628860;
    // tracks the amount of wei given from each contributor (used for refund)
    mapping (address => uint256) _0x7244c3;

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
    function _0xed4392(address _0x81c990) returns (bool _0x67128b);

    /// @notice Refund `msg.sender` in the case the Token Creation did
    /// not reach its minimum fueling goal
    function _0xaacac5();

    /// @return The divisor used to calculate the token creation rate during
    /// the creation phase
    function _0xb6a70e() constant returns (uint _0xb6a70e);

    event FuelingToDate(uint value);
    event CreatedToken(address indexed _0x052b0d, uint _0xfc0f9f);
    event Refund(address indexed _0x052b0d, uint value);
}

contract TokenCreation is TokenCreationInterface, Token {
    function TokenCreation(
        uint _0xfe52ba,
        uint _0xdbaa42,
        address _0xb96e79) {

        _0x42441d = _0xdbaa42;
        _0x1a2025 = _0xfe52ba;
        _0x57f4a9 = _0xb96e79;
        _0x628860 = new ManagedAccount(address(this), true);
    }

    function _0xed4392(address _0x81c990) returns (bool _0x67128b) {
        if (_0x37c01f < _0x42441d && msg.value > 0
            && (_0x57f4a9 == 0 || _0x57f4a9 == msg.sender)) {

            uint _0x14b361 = (msg.value * 20) / _0xb6a70e();
            _0x628860.call.value(msg.value - _0x14b361)();
            _0xdd94a7[_0x81c990] += _0x14b361;
            _0x443869 += _0x14b361;
            _0x7244c3[_0x81c990] += msg.value;
            CreatedToken(_0x81c990, _0x14b361);
            if (_0x443869 >= _0x1a2025 && !_0x9d43e9) {
                if (msg.sender != address(0) || msg.sender == address(0)) { _0x9d43e9 = true; }
                FuelingToDate(_0x443869);
            }
            return true;
        }
        throw;
    }

    function _0xaacac5() _0xc6f04b {
        if (_0x37c01f > _0x42441d && !_0x9d43e9) {
            // Get extraBalance - will only succeed when called for the first time
            if (_0x628860.balance >= _0x628860._0x5af08d())
                _0x628860._0x23074c(address(this), _0x628860._0x5af08d());

            // Execute refund
            if (msg.sender.call.value(_0x7244c3[msg.sender])()) {
                Refund(msg.sender, _0x7244c3[msg.sender]);
                _0x443869 -= _0xdd94a7[msg.sender];
                _0xdd94a7[msg.sender] = 0;
                _0x7244c3[msg.sender] = 0;
            }
        }
    }

    function _0xb6a70e() constant returns (uint _0xb6a70e) {
        // The number of (base unit) tokens per wei is calculated
        // as `msg.value` * 20 / `divisor`
        // The fueling period starts with a 1:1 ratio
        if (_0x42441d - 2 weeks > _0x37c01f) {
            return 20;
        // Followed by 10 days with a daily creation rate increase of 5%
        } else if (_0x42441d - 4 days > _0x37c01f) {
            return (20 + (_0x37c01f - (_0x42441d - 2 weeks)) / (1 days));
        // The last 4 days there is a constant creation rate ratio of 1:1.5
        } else {
            return 30;
        }
    }
}

contract DAOInterface {

    // The amount of days for which people who try to participate in the
    // creation by calling the fallback function will still get their ether back
    uint constant _0xacc5a1 = 40 days;
    // The minimum debate period that a generic proposal can have
    uint constant _0x2b3b5a = 2 weeks;
    // The minimum debate period that a split proposal can have
    uint constant _0x3c5af7 = 1 weeks;
    // Period of days inside which it's possible to execute a DAO split
    uint constant _0xb8a430 = 27 days;
    // Period of time after which the minimum Quorum is halved
    uint constant _0x07dc43 = 25 weeks;
    // Period after which a proposal is closed
    // (used in the case `executeProposal` fails because it throws)
    uint constant _0x0377ac = 10 days;
    // Denotes the maximum proposal deposit that can be given. It is given as
    // a fraction of total Ether spent plus balance of the DAO
    uint constant _0xb8b320 = 100;

    // Proposals to spend the DAO's ether or to choose a new Curator
    Proposal[] public _0x996d69;
    // The quorum needed for each proposal is partially calculated by
    // totalSupply / minQuorumDivisor
    uint public _0x96bf8e;
    // The unix time of the last time quorum was reached on a proposal
    uint  public _0xd828da;

    // Address of the curator
    address public _0x24939c;
    // The whitelist: List of addresses the DAO is allowed to send ether to
    mapping (address => bool) public _0x291aee;

    // Tracks the addresses that own Reward Tokens. Those addresses can only be
    // DAOs that have split from the original DAO. Conceptually, Reward Tokens
    // represent the proportion of the rewards that the DAO has the right to
    // receive. These Reward Tokens are generated when the DAO spends ether.
    mapping (address => uint) public _0x2d01c3;
    // Total supply of rewardToken
    uint public _0xf4aa7a;

    // The account used to manage the rewards which are to be distributed to the
    // DAO Token Holders of this DAO
    ManagedAccount public _0x3ff763;

    // The account used to manage the rewards which are to be distributed to
    // any DAO that holds Reward Tokens
    ManagedAccount public DAOrewardAccount;

    // Amount of rewards (in wei) already paid out to a certain DAO
    mapping (address => uint) public DAOpaidOut;

    // Amount of rewards (in wei) already paid out to a certain address
    mapping (address => uint) public _0x969628;
    // Map of addresses blocked during a vote (not allowed to transfer DAO
    // tokens). The address points to the proposal ID.
    mapping (address => uint) public _0x18527c;

    // The minimum deposit (in wei) required to submit any proposal that is not
    // requesting a new Curator (no deposit is required for splits)
    uint public _0xf22c15;

    // the accumulated sum of all current proposal deposits
    uint _0xa4e2fc;

    // Contract that is able to create a new DAO (with the same code as
    // this one), used for splits
    DAO_Creator public _0xe7d8b9;

    // A proposal with `newCurator == false` represents a transaction
    // to be issued by this DAO
    // A proposal with `newCurator == true` represents a DAO split
    struct Proposal {
        // The address where the `amount` will go to if the proposal is accepted
        // or if `newCurator` is true, the proposed Curator of
        // the new DAO).
        address _0xa9a83f;
        // The amount to transfer to `recipient` if the proposal is accepted.
        uint _0xfc0f9f;
        // A plain text description of the proposal
        string _0x169875;
        // A unix timestamp, denoting the end of the voting period
        uint _0x325a30;
        // True if the proposal's votes have yet to be counted, otherwise False
        bool _0x37f477;
        // True if quorum has been reached, the votes have been counted, and
        // the majority said yes
        bool _0x4b4015;
        // A hash to check validity of a proposal
        bytes32 _0xd156f7;
        // Deposit in wei the creator added when submitting their proposal. It
        // is taken from the msg.value of a newProposal call.
        uint _0xf22c15;
        // True if this proposal is to assign a new Curator
        bool _0xbe0682;
        // Data needed for splitting the DAO
        SplitData[] _0x472a6d;
        // Number of Tokens in favor of the proposal
        uint _0x889e06;
        // Number of Tokens opposed to the proposal
        uint _0xe34ccd;
        // Simple mapping to check if a shareholder has voted for it
        mapping (address => bool) _0x3d0cc8;
        // Simple mapping to check if a shareholder has voted against it
        mapping (address => bool) _0x9d6db5;
        // Address of the shareholder who created the proposal
        address _0x7a0578;
    }

    // Used only in the case of a newCurator proposal.
    struct SplitData {
        // The balance of the current DAO minus the deposit at the time of split
        uint _0xd6fc4b;
        // The total amount of DAO Tokens in existence at the time of split.
        uint _0x443869;
        // Amount of Reward Tokens owned by the DAO at the time of split.
        uint _0x2d01c3;
        // The new DAO contract created at the time of split.
        DAO _0x7b5108;
    }

    // Used to restrict access to certain functions to only DAO Token Holders
    modifier _0xff24a6 {}

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
    function () returns (bool _0x67128b);

    /// @dev This function is used to send ether back
    /// to the DAO, it can also be used to receive payments that should not be
    /// counted as rewards (donations, grants, etc.)
    /// @return Whether the DAO received the ether successfully
    function _0x3095af() returns(bool);

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
    function _0x298ace(
        address _0xe28eb3,
        uint _0x91cc45,
        string _0xf3a1ea,
        bytes _0x039eaa,
        uint _0x16c1c6,
        bool _0xadff87
    ) _0xff24a6 returns (uint _0xf8b8c5);

    /// @notice Check that the proposal with the ID `_proposalID` matches the
    /// transaction which sends `_amount` with data `_transactionData`
    /// to `_recipient`
    /// @param _proposalID The proposal ID
    /// @param _recipient The recipient of the proposed transaction
    /// @param _amount The amount of wei to be sent in the proposed transaction
    /// @param _transactionData The data of the proposed transaction
    /// @return Whether the proposal ID matches the transaction data or not
    function _0x7ef678(
        uint _0xf8b8c5,
        address _0xe28eb3,
        uint _0x91cc45,
        bytes _0x039eaa
    ) constant returns (bool _0xf7519a);

    /// @notice Vote on proposal `_proposalID` with `_supportsProposal`
    /// @param _proposalID The proposal ID
    /// @param _supportsProposal Yes/No - support of the proposal
    /// @return The vote ID.
    function _0x2740e7(
        uint _0xf8b8c5,
        bool _0x006f6f
    ) _0xff24a6 returns (uint _0x0a55c2);

    /// @notice Checks whether proposal `_proposalID` with transaction data
    /// `_transactionData` has been voted for or rejected, and executes the
    /// transaction in the case it has been voted for.
    /// @param _proposalID The proposal ID
    /// @param _transactionData The data of the proposed transaction
    /// @return Whether the proposed transaction has been executed or not
    function _0x70fc6d(
        uint _0xf8b8c5,
        bytes _0x039eaa
    ) returns (bool _0xe498bd);

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
    function _0xfbb0a1(
        uint _0xf8b8c5,
        address _0xadff87
    ) returns (bool _0xe498bd);

    /// @dev can only be called by the DAO itself through a proposal
    /// updates the contract of the DAO by sending all ether and rewardTokens
    /// to the new DAO. The new DAO needs to be approved by the Curator
    /// @param _newContract the address of the new contract
    function _0x4bac90(address _0xb636b6);

    /// @notice Add a new possible recipient `_recipient` to the whitelist so
    /// that the DAO can send transactions to them (using proposals)
    /// @param _recipient New recipient address
    /// @dev Can only be called by the current Curator
    /// @return Whether successful or not
    function _0x93d88d(address _0xe28eb3, bool _0x76b35f) external returns (bool _0xe498bd);

    /// @notice Change the minimum deposit required to submit a proposal
    /// @param _proposalDeposit The new proposal deposit
    /// @dev Can only be called by this DAO (through proposals with the
    /// recipient being this DAO itself)
    function _0xb59321(uint _0xc6fcc9) external;

    /// @notice Move rewards from the DAORewards managed account
    /// @param _toMembers If true rewards are moved to the actual reward account
    ///                   for the DAO. If not then it's moved to the DAO itself
    /// @return Whether the call was successful
    function _0x84c016(bool _0x303318) external returns (bool _0xe498bd);

    /// @notice Get my portion of the reward that was sent to `rewardAccount`
    /// @return Whether the call was successful
    function _0x9f2918() returns(bool _0xe498bd);

    /// @notice Withdraw `_account`'s portion of the reward from `rewardAccount`
    /// to `_account`'s balance
    /// @return Whether the call was successful
    function _0x1f5b75(address _0x45ade4) internal returns (bool _0xe498bd);

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`. Prior to this
    /// getMyReward() is called.
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transfered
    /// @return Whether the transfer was successful or not
    function _0xb6fd3d(address _0x6cad2a, uint256 _0x91cc45) returns (bool _0x67128b);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    /// is approved by `_from`. Prior to this getMyReward() is called.
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transfered
    /// @return Whether the transfer was successful or not
    function _0x0309db(
        address _0xd0fe77,
        address _0x6cad2a,
        uint256 _0x91cc45
    ) returns (bool _0x67128b);

    /// @notice Doubles the 'minQuorumDivisor' in the case quorum has not been
    /// achieved in 52 weeks
    /// @return Whether the change was successful or not
    function _0xc6c962() returns (bool _0xe498bd);

    /// @return total number of proposals ever created
    function _0x3f435b() constant returns (uint _0x1760fa);

    /// @param _proposalID Id of the new curator proposal
    /// @return Address of the new DAO
    function _0xd42df3(uint _0xf8b8c5) constant returns (address _0x98c960);

    /// @param _account The address of the account which is checked.
    /// @return Whether the account is blocked (not allowed to transfer tokens) or not.
    function _0xf1489d(address _0x45ade4) internal returns (bool);

    /// @notice If the caller is blocked by a proposal whose voting deadline
    /// has exprired then unblock him.
    /// @return Whether the account is blocked (not allowed to transfer tokens) or not.
    function _0xd22089() returns (bool);

    event ProposalAdded(
        uint indexed _0x6b4c42,
        address _0xa9a83f,
        uint _0xfc0f9f,
        bool _0xbe0682,
        string _0x169875
    );
    event Voted(uint indexed _0x6b4c42, bool _0x18d326, address indexed _0xf45239);
    event ProposalTallied(uint indexed _0x6b4c42, bool _0x43ea18, uint _0x9c0b1e);
    event NewCurator(address indexed _0xadff87);
    event AllowedRecipientChanged(address indexed _0xe28eb3, bool _0x76b35f);
}

// The DAO contract itself
contract DAO is DAOInterface, Token, TokenCreation {

    // Modifier that allows only shareholders to vote and create new proposals
    modifier _0xff24a6 {
        if (_0x531eea(msg.sender) == 0) throw;
            _;
    }

    function DAO(
        address _0xf115ea,
        DAO_Creator _0xc959fa,
        uint _0xc6fcc9,
        uint _0xfe52ba,
        uint _0xdbaa42,
        address _0xb96e79
    ) TokenCreation(_0xfe52ba, _0xdbaa42, _0xb96e79) {

        _0x24939c = _0xf115ea;
        _0xe7d8b9 = _0xc959fa;
        _0xf22c15 = _0xc6fcc9;
        _0x3ff763 = new ManagedAccount(address(this), false);
        DAOrewardAccount = new ManagedAccount(address(this), false);
        if (address(_0x3ff763) == 0)
            throw;
        if (address(DAOrewardAccount) == 0)
            throw;
        _0xd828da = _0x37c01f;
        _0x96bf8e = 5; // sets the minimal quorum to 20%
        _0x996d69.length = 1; // avoids a proposal with ID 0 because it is used

        _0x291aee[address(this)] = true;
        _0x291aee[_0x24939c] = true;
    }

    function () returns (bool _0x67128b) {
        if (_0x37c01f < _0x42441d + _0xacc5a1 && msg.sender != address(_0x628860))
            return _0xed4392(msg.sender);
        else
            return _0x3095af();
    }

    function _0x3095af() returns (bool) {
        return true;
    }

    function _0x298ace(
        address _0xe28eb3,
        uint _0x91cc45,
        string _0xf3a1ea,
        bytes _0x039eaa,
        uint _0x16c1c6,
        bool _0xadff87
    ) _0xff24a6 returns (uint _0xf8b8c5) {

        // Sanity check
        if (_0xadff87 && (
            _0x91cc45 != 0
            || _0x039eaa.length != 0
            || _0xe28eb3 == _0x24939c
            || msg.value > 0
            || _0x16c1c6 < _0x3c5af7)) {
            throw;
        } else if (
            !_0xadff87
            && (!_0x0a3a41(_0xe28eb3) || (_0x16c1c6 <  _0x2b3b5a))
        ) {
            throw;
        }

        if (_0x16c1c6 > 8 weeks)
            throw;

        if (!_0x9d43e9
            || _0x37c01f < _0x42441d
            || (msg.value < _0xf22c15 && !_0xadff87)) {

            throw;
        }

        if (_0x37c01f + _0x16c1c6 < _0x37c01f)
            throw;

        if (msg.sender == address(this))
            throw;

        _0xf8b8c5 = _0x996d69.length++;
        Proposal p = _0x996d69[_0xf8b8c5];
        p._0xa9a83f = _0xe28eb3;
        p._0xfc0f9f = _0x91cc45;
        p._0x169875 = _0xf3a1ea;
        p._0xd156f7 = _0x506d5d(_0xe28eb3, _0x91cc45, _0x039eaa);
        p._0x325a30 = _0x37c01f + _0x16c1c6;
        p._0x37f477 = true;
        //p.proposalPassed = False; // that's default
        p._0xbe0682 = _0xadff87;
        if (_0xadff87)
            p._0x472a6d.length++;
        p._0x7a0578 = msg.sender;
        p._0xf22c15 = msg.value;

        _0xa4e2fc += msg.value;

        ProposalAdded(
            _0xf8b8c5,
            _0xe28eb3,
            _0x91cc45,
            _0xadff87,
            _0xf3a1ea
        );
    }

    function _0x7ef678(
        uint _0xf8b8c5,
        address _0xe28eb3,
        uint _0x91cc45,
        bytes _0x039eaa
    ) _0xc6f04b constant returns (bool _0xf7519a) {
        Proposal p = _0x996d69[_0xf8b8c5];
        return p._0xd156f7 == _0x506d5d(_0xe28eb3, _0x91cc45, _0x039eaa);
    }

    function _0x2740e7(
        uint _0xf8b8c5,
        bool _0x006f6f
    ) _0xff24a6 _0xc6f04b returns (uint _0x0a55c2) {

        Proposal p = _0x996d69[_0xf8b8c5];
        if (p._0x3d0cc8[msg.sender]
            || p._0x9d6db5[msg.sender]
            || _0x37c01f >= p._0x325a30) {

            throw;
        }

        if (_0x006f6f) {
            p._0x889e06 += _0xdd94a7[msg.sender];
            p._0x3d0cc8[msg.sender] = true;
        } else {
            p._0xe34ccd += _0xdd94a7[msg.sender];
            p._0x9d6db5[msg.sender] = true;
        }

        if (_0x18527c[msg.sender] == 0) {
            _0x18527c[msg.sender] = _0xf8b8c5;
        } else if (p._0x325a30 > _0x996d69[_0x18527c[msg.sender]]._0x325a30) {
            // this proposal's voting deadline is further into the future than
            // the proposal that blocks the sender so make it the blocker
            _0x18527c[msg.sender] = _0xf8b8c5;
        }

        Voted(_0xf8b8c5, _0x006f6f, msg.sender);
    }

    function _0x70fc6d(
        uint _0xf8b8c5,
        bytes _0x039eaa
    ) _0xc6f04b returns (bool _0xe498bd) {

        Proposal p = _0x996d69[_0xf8b8c5];

        uint _0x482ffb = p._0xbe0682
            ? _0xb8a430
            : _0x0377ac;
        // If we are over deadline and waiting period, assert proposal is closed
        if (p._0x37f477 && _0x37c01f > p._0x325a30 + _0x482ffb) {
            _0x8f3b63(_0xf8b8c5);
            return;
        }

        // Check if the proposal can be executed
        if (_0x37c01f < p._0x325a30  // has the voting deadline arrived?
            // Have the votes been counted?
            || !p._0x37f477
            // Does the transaction code match the proposal?
            || p._0xd156f7 != _0x506d5d(p._0xa9a83f, p._0xfc0f9f, _0x039eaa)) {

            throw;
        }

        // If the curator removed the recipient from the whitelist, close the proposal
        // in order to free the deposit and allow unblocking of voters
        if (!_0x0a3a41(p._0xa9a83f)) {
            _0x8f3b63(_0xf8b8c5);
            p._0x7a0578.send(p._0xf22c15);
            return;
        }

        bool _0x5171e0 = true;

        if (p._0xfc0f9f > _0x7871dc())
            _0x5171e0 = false;

        uint _0x9c0b1e = p._0x889e06 + p._0xe34ccd;

        // require 53% for calling newContract()
        if (_0x039eaa.length >= 4 && _0x039eaa[0] == 0x68
            && _0x039eaa[1] == 0x37 && _0x039eaa[2] == 0xff
            && _0x039eaa[3] == 0x1e
            && _0x9c0b1e < _0x062d2d(_0x7871dc() + _0x2d01c3[address(this)])) {

                _0x5171e0 = false;
        }

        if (_0x9c0b1e >= _0x062d2d(p._0xfc0f9f)) {
            if (!p._0x7a0578.send(p._0xf22c15))
                throw;

            _0xd828da = _0x37c01f;
            // set the minQuorum to 20% again, in the case it has been reached
            if (_0x9c0b1e > _0x443869 / 5)
                _0x96bf8e = 5;
        }

        // Execute result
        if (_0x9c0b1e >= _0x062d2d(p._0xfc0f9f) && p._0x889e06 > p._0xe34ccd && _0x5171e0) {
            if (!p._0xa9a83f.call.value(p._0xfc0f9f)(_0x039eaa))
                throw;

            p._0x4b4015 = true;
            _0xe498bd = true;

            // only create reward tokens when ether is not sent to the DAO itself and
            // related addresses. Proxy addresses should be forbidden by the curator.
            if (p._0xa9a83f != address(this) && p._0xa9a83f != address(_0x3ff763)
                && p._0xa9a83f != address(DAOrewardAccount)
                && p._0xa9a83f != address(_0x628860)
                && p._0xa9a83f != address(_0x24939c)) {

                _0x2d01c3[address(this)] += p._0xfc0f9f;
                _0xf4aa7a += p._0xfc0f9f;
            }
        }

        _0x8f3b63(_0xf8b8c5);

        // Initiate event
        ProposalTallied(_0xf8b8c5, _0xe498bd, _0x9c0b1e);
    }

    function _0x8f3b63(uint _0xf8b8c5) internal {
        Proposal p = _0x996d69[_0xf8b8c5];
        if (p._0x37f477)
            _0xa4e2fc -= p._0xf22c15;
        p._0x37f477 = false;
    }

    function _0xfbb0a1(
        uint _0xf8b8c5,
        address _0xadff87
    ) _0xc6f04b _0xff24a6 returns (bool _0xe498bd) {

        Proposal p = _0x996d69[_0xf8b8c5];

        // Sanity check

        if (_0x37c01f < p._0x325a30  // has the voting deadline arrived?
            //The request for a split expires XX days after the voting deadline
            || _0x37c01f > p._0x325a30 + _0xb8a430
            // Does the new Curator address match?
            || p._0xa9a83f != _0xadff87
            // Is it a new curator proposal?
            || !p._0xbe0682
            // Have you voted for this split?
            || !p._0x3d0cc8[msg.sender]
            // Did you already vote on another proposal?
            || (_0x18527c[msg.sender] != _0xf8b8c5 && _0x18527c[msg.sender] != 0) )  {

            throw;
        }

        // If the new DAO doesn't exist yet, create the new DAO and store the
        // current split data
        if (address(p._0x472a6d[0]._0x7b5108) == 0) {
            p._0x472a6d[0]._0x7b5108 = _0x7e7e59(_0xadff87);
            // Call depth limit reached, etc.
            if (address(p._0x472a6d[0]._0x7b5108) == 0)
                throw;
            // should never happen
            if (this.balance < _0xa4e2fc)
                throw;
            p._0x472a6d[0]._0xd6fc4b = _0x7871dc();
            p._0x472a6d[0]._0x2d01c3 = _0x2d01c3[address(this)];
            p._0x472a6d[0]._0x443869 = _0x443869;
            p._0x4b4015 = true;
        }

        // Move ether and assign new Tokens
        uint _0x0c4235 =
            (_0xdd94a7[msg.sender] * p._0x472a6d[0]._0xd6fc4b) /
            p._0x472a6d[0]._0x443869;
        if (p._0x472a6d[0]._0x7b5108._0xed4392.value(_0x0c4235)(msg.sender) == false)
            throw;

        // Assign reward rights to new DAO
        uint _0x4dd430 =
            (_0xdd94a7[msg.sender] * p._0x472a6d[0]._0x2d01c3) /
            p._0x472a6d[0]._0x443869;

        uint _0xf65909 = DAOpaidOut[address(this)] * _0x4dd430 /
            _0x2d01c3[address(this)];

        _0x2d01c3[address(p._0x472a6d[0]._0x7b5108)] += _0x4dd430;
        if (_0x2d01c3[address(this)] < _0x4dd430)
            throw;
        _0x2d01c3[address(this)] -= _0x4dd430;

        DAOpaidOut[address(p._0x472a6d[0]._0x7b5108)] += _0xf65909;
        if (DAOpaidOut[address(this)] < _0xf65909)
            throw;
        DAOpaidOut[address(this)] -= _0xf65909;

        // Burn DAO Tokens
        Transfer(msg.sender, 0, _0xdd94a7[msg.sender]);
        _0x1f5b75(msg.sender); // be nice, and get his rewards
        _0x443869 -= _0xdd94a7[msg.sender];
        _0xdd94a7[msg.sender] = 0;
        _0x969628[msg.sender] = 0;
        return true;
    }

    function _0x4bac90(address _0xb636b6){
        if (msg.sender != address(this) || !_0x291aee[_0xb636b6]) return;
        // move all ether
        if (!_0xb636b6.call.value(address(this).balance)()) {
            throw;
        }

        //move all reward tokens
        _0x2d01c3[_0xb636b6] += _0x2d01c3[address(this)];
        _0x2d01c3[address(this)] = 0;
        DAOpaidOut[_0xb636b6] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function _0x84c016(bool _0x303318) external _0xc6f04b returns (bool _0xe498bd) {
        DAO _0x77e276 = DAO(msg.sender);

        if ((_0x2d01c3[msg.sender] * DAOrewardAccount._0x5af08d()) /
            _0xf4aa7a < DAOpaidOut[msg.sender])
            throw;

        uint _0x9e1932 =
            (_0x2d01c3[msg.sender] * DAOrewardAccount._0x5af08d()) /
            _0xf4aa7a - DAOpaidOut[msg.sender];
        if(_0x303318) {
            if (!DAOrewardAccount._0x23074c(_0x77e276._0x3ff763(), _0x9e1932))
                throw;
            }
        else {
            if (!DAOrewardAccount._0x23074c(_0x77e276, _0x9e1932))
                throw;
        }
        DAOpaidOut[msg.sender] += _0x9e1932;
        return true;
    }

    function _0x9f2918() _0xc6f04b returns (bool _0xe498bd) {
        return _0x1f5b75(msg.sender);
    }

    function _0x1f5b75(address _0x45ade4) _0xc6f04b internal returns (bool _0xe498bd) {
        if ((_0x531eea(_0x45ade4) * _0x3ff763._0x5af08d()) / _0x443869 < _0x969628[_0x45ade4])
            throw;

        uint _0x9e1932 =
            (_0x531eea(_0x45ade4) * _0x3ff763._0x5af08d()) / _0x443869 - _0x969628[_0x45ade4];
        if (!_0x3ff763._0x23074c(_0x45ade4, _0x9e1932))
            throw;
        _0x969628[_0x45ade4] += _0x9e1932;
        return true;
    }

    function transfer(address _0x6cad2a, uint256 _0xc4c422) returns (bool _0x67128b) {
        if (_0x9d43e9
            && _0x37c01f > _0x42441d
            && !_0xf1489d(msg.sender)
            && _0xc8db17(msg.sender, _0x6cad2a, _0xc4c422)
            && super.transfer(_0x6cad2a, _0xc4c422)) {

            return true;
        } else {
            throw;
        }
    }

    function _0xb6fd3d(address _0x6cad2a, uint256 _0xc4c422) returns (bool _0x67128b) {
        if (!_0x9f2918())
            throw;
        return transfer(_0x6cad2a, _0xc4c422);
    }

    function _0xe1f49f(address _0xd0fe77, address _0x6cad2a, uint256 _0xc4c422) returns (bool _0x67128b) {
        if (_0x9d43e9
            && _0x37c01f > _0x42441d
            && !_0xf1489d(_0xd0fe77)
            && _0xc8db17(_0xd0fe77, _0x6cad2a, _0xc4c422)
            && super._0xe1f49f(_0xd0fe77, _0x6cad2a, _0xc4c422)) {

            return true;
        } else {
            throw;
        }
    }

    function _0x0309db(
        address _0xd0fe77,
        address _0x6cad2a,
        uint256 _0xc4c422
    ) returns (bool _0x67128b) {

        if (!_0x1f5b75(_0xd0fe77))
            throw;
        return _0xe1f49f(_0xd0fe77, _0x6cad2a, _0xc4c422);
    }

    function _0xc8db17(
        address _0xd0fe77,
        address _0x6cad2a,
        uint256 _0xc4c422
    ) internal returns (bool _0x67128b) {

        uint _0xc8db17 = _0x969628[_0xd0fe77] * _0xc4c422 / _0x531eea(_0xd0fe77);
        if (_0xc8db17 > _0x969628[_0xd0fe77])
            throw;
        _0x969628[_0xd0fe77] -= _0xc8db17;
        _0x969628[_0x6cad2a] += _0xc8db17;
        return true;
    }

    function _0xb59321(uint _0xc6fcc9) _0xc6f04b external {
        if (msg.sender != address(this) || _0xc6fcc9 > (_0x7871dc() + _0x2d01c3[address(this)])
            / _0xb8b320) {

            throw;
        }
        _0xf22c15 = _0xc6fcc9;
    }

    function _0x93d88d(address _0xe28eb3, bool _0x76b35f) _0xc6f04b external returns (bool _0xe498bd) {
        if (msg.sender != _0x24939c)
            throw;
        _0x291aee[_0xe28eb3] = _0x76b35f;
        AllowedRecipientChanged(_0xe28eb3, _0x76b35f);
        return true;
    }

    function _0x0a3a41(address _0xe28eb3) internal returns (bool _0x46d551) {
        if (_0x291aee[_0xe28eb3]
            || (_0xe28eb3 == address(_0x628860)
                // only allowed when at least the amount held in the
                // extraBalance account has been spent from the DAO
                && _0xf4aa7a > _0x628860._0x5af08d()))
            return true;
        else
            return false;
    }

    function _0x7871dc() constant returns (uint _0x31d8c1) {
        return this.balance - _0xa4e2fc;
    }

    function _0x062d2d(uint _0xc4c422) internal constant returns (uint _0x79d07a) {
        // minimum of 20% and maximum of 53.33%
        return _0x443869 / _0x96bf8e +
            (_0xc4c422 * _0x443869) / (3 * (_0x7871dc() + _0x2d01c3[address(this)]));
    }

    function _0xc6c962() returns (bool _0xe498bd) {
        // this can only be called after `quorumHalvingPeriod` has passed or at anytime
        // by the curator with a delay of at least `minProposalDebatePeriod` between the calls
        if ((_0xd828da < (_0x37c01f - _0x07dc43) || msg.sender == _0x24939c)
            && _0xd828da < (_0x37c01f - _0x2b3b5a)) {
            _0xd828da = _0x37c01f;
            _0x96bf8e *= 2;
            return true;
        } else {
            return false;
        }
    }

    function _0x7e7e59(address _0xadff87) internal returns (DAO _0x98c960) {
        NewCurator(_0xadff87);
        return _0xe7d8b9._0x4822e6(_0xadff87, 0, 0, _0x37c01f + _0xb8a430);
    }

    function _0x3f435b() constant returns (uint _0x1760fa) {
        // Don't count index 0. It's used by isBlocked() and exists from start
        return _0x996d69.length - 1;
    }

    function _0xd42df3(uint _0xf8b8c5) constant returns (address _0x98c960) {
        return _0x996d69[_0xf8b8c5]._0x472a6d[0]._0x7b5108;
    }

    function _0xf1489d(address _0x45ade4) internal returns (bool) {
        if (_0x18527c[_0x45ade4] == 0)
            return false;
        Proposal p = _0x996d69[_0x18527c[_0x45ade4]];
        if (_0x37c01f > p._0x325a30) {
            _0x18527c[_0x45ade4] = 0;
            return false;
        } else {
            return true;
        }
    }

    function _0xd22089() returns (bool) {
        return _0xf1489d(msg.sender);
    }
}

contract DAO_Creator {
    function _0x4822e6(
        address _0xf115ea,
        uint _0xc6fcc9,
        uint _0xfe52ba,
        uint _0xdbaa42
    ) returns (DAO _0x98c960) {

        return new DAO(
            _0xf115ea,
            DAO_Creator(this),
            _0xc6fcc9,
            _0xfe52ba,
            _0xdbaa42,
            msg.sender
        );
    }
}
