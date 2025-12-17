// 0xbb9bc244d798123fde783fcc1c72d3bb8c189413#code

/// @title Standard Token Contract.

contract TokenInterface {
    mapping (address => uint256) _0x0c2f1d;
    mapping (address => mapping (address => uint256)) _0xa8843b;

    /// Total amount of tokens
    uint256 public _0xe90ca9;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function _0xf06056(address _0xdc7af5) constant returns (uint256 balance);

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _0x4ecdd8, uint256 _0xe1f257) returns (bool _0xde260f);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    /// is approved by `_from`
    /// @param _from The address of the origin of the transfer
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function _0xdcc9dc(address _0xac3031, address _0x4ecdd8, uint256 _0xe1f257) returns (bool _0xde260f);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    /// its behalf
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function _0xe9ed2a(address _0xa17e1e, uint256 _0xe1f257) returns (bool _0xde260f);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    /// to spend
    function _0x200f84(
        address _0xdc7af5,
        address _0xa17e1e
    ) constant returns (uint256 _0x08ecc4);

    event Transfer(address indexed _0xac3031, address indexed _0x4ecdd8, uint256 _0xe1f257);
    event Approval(
        address indexed _0xdc7af5,
        address indexed _0xa17e1e,
        uint256 _0xe1f257
    );
}

contract Token is TokenInterface {
    // Protects users by preventing the execution of method calls that
    // inadvertently also transferred ether
    modifier _0xe5b5da() {if (msg.value > 0) throw; _;}

    function _0xf06056(address _0xdc7af5) constant returns (uint256 balance) {
        return _0x0c2f1d[_0xdc7af5];
    }

    function transfer(address _0x4ecdd8, uint256 _0xe1f257) _0xe5b5da returns (bool _0xde260f) {
        if (_0x0c2f1d[msg.sender] >= _0xe1f257 && _0xe1f257 > 0) {
            _0x0c2f1d[msg.sender] -= _0xe1f257;
            _0x0c2f1d[_0x4ecdd8] += _0xe1f257;
            Transfer(msg.sender, _0x4ecdd8, _0xe1f257);
            return true;
        } else {
           return false;
        }
    }

    function _0xdcc9dc(
        address _0xac3031,
        address _0x4ecdd8,
        uint256 _0xe1f257
    ) _0xe5b5da returns (bool _0xde260f) {

        if (_0x0c2f1d[_0xac3031] >= _0xe1f257
            && _0xa8843b[_0xac3031][msg.sender] >= _0xe1f257
            && _0xe1f257 > 0) {

            _0x0c2f1d[_0x4ecdd8] += _0xe1f257;
            _0x0c2f1d[_0xac3031] -= _0xe1f257;
            _0xa8843b[_0xac3031][msg.sender] -= _0xe1f257;
            Transfer(_0xac3031, _0x4ecdd8, _0xe1f257);
            return true;
        } else {
            return false;
        }
    }

    function _0xe9ed2a(address _0xa17e1e, uint256 _0xe1f257) returns (bool _0xde260f) {
        _0xa8843b[msg.sender][_0xa17e1e] = _0xe1f257;
        Approval(msg.sender, _0xa17e1e, _0xe1f257);
        return true;
    }

    function _0x200f84(address _0xdc7af5, address _0xa17e1e) constant returns (uint256 _0x08ecc4) {
        return _0xa8843b[_0xdc7af5][_0xa17e1e];
    }
}

contract ManagedAccountInterface {
    // The only address with permission to withdraw from this account
    address public _0xa92fda;
    // If true, only the owner of the account can receive ether from it
    bool public _0x014b70;
    // The sum of ether (in wei) which has been sent to this contract
    uint public _0x4edb1b;

    /// @notice Sends `_amount` of wei to _recipient
    /// @param _amount The amount of wei to send to `_recipient`
    /// @param _recipient The address to receive `_amount` of wei
    /// @return True if the send completed
    function _0xa1d745(address _0x76f85f, uint _0xe1f257) returns (bool);

    event PayOut(address indexed _0x76f85f, uint _0xe1f257);
}

contract ManagedAccount is ManagedAccountInterface{

    // The constructor sets the owner of the account
    function ManagedAccount(address _0xdc7af5, bool _0x3f4ff8) {
        _0xa92fda = _0xdc7af5;
        _0x014b70 = _0x3f4ff8;
    }

    // When the contract receives a transaction without data this is called.
    // It counts the amount of ether it receives and stores it in
    // accumulatedInput.
    function() {
        _0x4edb1b += msg.value;
    }

    function _0xa1d745(address _0x76f85f, uint _0xe1f257) returns (bool) {
        if (msg.sender != _0xa92fda || msg.value > 0 || (_0x014b70 && _0x76f85f != _0xa92fda))
            throw;
        if (_0x76f85f.call.value(_0xe1f257)()) {
            PayOut(_0x76f85f, _0xe1f257);
            return true;
        } else {
            return false;
        }
    }
}

contract TokenCreationInterface {

    // End of token creation, in Unix time
    uint public _0x6873fa;
    // Minimum fueling goal of the token creation, denominated in tokens to
    // be created
    uint public _0x51c8a5;
    // True if the DAO reached its minimum fueling goal, false otherwise
    bool public _0xbe2a20;
    // For DAO splits - if privateCreation is 0, then it is a public token
    // creation, otherwise only the address stored in privateCreation is
    // allowed to create tokens
    address public _0xf0746b;
    // hold extra ether which has been sent after the DAO token
    // creation rate has increased
    ManagedAccount public _0xe206d9;
    // tracks the amount of wei given from each contributor (used for refund)
    mapping (address => uint256) _0x6304f1;

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
    function _0xbbfb49(address _0xdfbeb9) returns (bool _0xde260f);

    /// @notice Refund `msg.sender` in the case the Token Creation did
    /// not reach its minimum fueling goal
    function _0xbcfb63();

    /// @return The divisor used to calculate the token creation rate during
    /// the creation phase
    function _0x3c32e6() constant returns (uint _0x3c32e6);

    event FuelingToDate(uint value);
    event CreatedToken(address indexed _0x40c5b0, uint _0x19be9d);
    event Refund(address indexed _0x40c5b0, uint value);
}

contract TokenCreation is TokenCreationInterface, Token {
    function TokenCreation(
        uint _0xe0641a,
        uint _0xd42887,
        address _0xa5f5d6) {

        _0x6873fa = _0xd42887;
        _0x51c8a5 = _0xe0641a;
        _0xf0746b = _0xa5f5d6;
        _0xe206d9 = new ManagedAccount(address(this), true);
    }

    function _0xbbfb49(address _0xdfbeb9) returns (bool _0xde260f) {
        if (_0x161ca9 < _0x6873fa && msg.value > 0
            && (_0xf0746b == 0 || _0xf0746b == msg.sender)) {

            uint _0xb71683 = (msg.value * 20) / _0x3c32e6();
            _0xe206d9.call.value(msg.value - _0xb71683)();
            _0x0c2f1d[_0xdfbeb9] += _0xb71683;
            _0xe90ca9 += _0xb71683;
            _0x6304f1[_0xdfbeb9] += msg.value;
            CreatedToken(_0xdfbeb9, _0xb71683);
            if (_0xe90ca9 >= _0x51c8a5 && !_0xbe2a20) {
                _0xbe2a20 = true;
                FuelingToDate(_0xe90ca9);
            }
            return true;
        }
        throw;
    }

    function _0xbcfb63() _0xe5b5da {
        if (_0x161ca9 > _0x6873fa && !_0xbe2a20) {
            // Get extraBalance - will only succeed when called for the first time
            if (_0xe206d9.balance >= _0xe206d9._0x4edb1b())
                _0xe206d9._0xa1d745(address(this), _0xe206d9._0x4edb1b());

            // Execute refund
            if (msg.sender.call.value(_0x6304f1[msg.sender])()) {
                Refund(msg.sender, _0x6304f1[msg.sender]);
                _0xe90ca9 -= _0x0c2f1d[msg.sender];
                _0x0c2f1d[msg.sender] = 0;
                _0x6304f1[msg.sender] = 0;
            }
        }
    }

    function _0x3c32e6() constant returns (uint _0x3c32e6) {
        // The number of (base unit) tokens per wei is calculated
        // as `msg.value` * 20 / `divisor`
        // The fueling period starts with a 1:1 ratio
        if (_0x6873fa - 2 weeks > _0x161ca9) {
            return 20;
        // Followed by 10 days with a daily creation rate increase of 5%
        } else if (_0x6873fa - 4 days > _0x161ca9) {
            return (20 + (_0x161ca9 - (_0x6873fa - 2 weeks)) / (1 days));
        // The last 4 days there is a constant creation rate ratio of 1:1.5
        } else {
            return 30;
        }
    }
}

contract DAOInterface {

    // The amount of days for which people who try to participate in the
    // creation by calling the fallback function will still get their ether back
    uint constant _0x28a77a = 40 days;
    // The minimum debate period that a generic proposal can have
    uint constant _0x90e2de = 2 weeks;
    // The minimum debate period that a split proposal can have
    uint constant _0x3af767 = 1 weeks;
    // Period of days inside which it's possible to execute a DAO split
    uint constant _0x49ce24 = 27 days;
    // Period of time after which the minimum Quorum is halved
    uint constant _0x622a4d = 25 weeks;
    // Period after which a proposal is closed
    // (used in the case `executeProposal` fails because it throws)
    uint constant _0x800f67 = 10 days;
    // Denotes the maximum proposal deposit that can be given. It is given as
    // a fraction of total Ether spent plus balance of the DAO
    uint constant _0x860c40 = 100;

    // Proposals to spend the DAO's ether or to choose a new Curator
    Proposal[] public _0x116b51;
    // The quorum needed for each proposal is partially calculated by
    // totalSupply / minQuorumDivisor
    uint public _0xe76d34;
    // The unix time of the last time quorum was reached on a proposal
    uint  public _0x094540;

    // Address of the curator
    address public _0xdd2d3a;
    // The whitelist: List of addresses the DAO is allowed to send ether to
    mapping (address => bool) public _0x6e1876;

    // Tracks the addresses that own Reward Tokens. Those addresses can only be
    // DAOs that have split from the original DAO. Conceptually, Reward Tokens
    // represent the proportion of the rewards that the DAO has the right to
    // receive. These Reward Tokens are generated when the DAO spends ether.
    mapping (address => uint) public _0x4386bd;
    // Total supply of rewardToken
    uint public _0x7b56f6;

    // The account used to manage the rewards which are to be distributed to the
    // DAO Token Holders of this DAO
    ManagedAccount public _0xd2e8fe;

    // The account used to manage the rewards which are to be distributed to
    // any DAO that holds Reward Tokens
    ManagedAccount public DAOrewardAccount;

    // Amount of rewards (in wei) already paid out to a certain DAO
    mapping (address => uint) public DAOpaidOut;

    // Amount of rewards (in wei) already paid out to a certain address
    mapping (address => uint) public _0x20fc25;
    // Map of addresses blocked during a vote (not allowed to transfer DAO
    // tokens). The address points to the proposal ID.
    mapping (address => uint) public _0xa8738c;

    // The minimum deposit (in wei) required to submit any proposal that is not
    // requesting a new Curator (no deposit is required for splits)
    uint public _0x6c3814;

    // the accumulated sum of all current proposal deposits
    uint _0x53a418;

    // Contract that is able to create a new DAO (with the same code as
    // this one), used for splits
    DAO_Creator public _0x6ebd70;

    // A proposal with `newCurator == false` represents a transaction
    // to be issued by this DAO
    // A proposal with `newCurator == true` represents a DAO split
    struct Proposal {
        // The address where the `amount` will go to if the proposal is accepted
        // or if `newCurator` is true, the proposed Curator of
        // the new DAO).
        address _0xc4e315;
        // The amount to transfer to `recipient` if the proposal is accepted.
        uint _0x19be9d;
        // A plain text description of the proposal
        string _0x2846f7;
        // A unix timestamp, denoting the end of the voting period
        uint _0xa0f12b;
        // True if the proposal's votes have yet to be counted, otherwise False
        bool _0xce28ae;
        // True if quorum has been reached, the votes have been counted, and
        // the majority said yes
        bool _0x8f4228;
        // A hash to check validity of a proposal
        bytes32 _0xa42223;
        // Deposit in wei the creator added when submitting their proposal. It
        // is taken from the msg.value of a newProposal call.
        uint _0x6c3814;
        // True if this proposal is to assign a new Curator
        bool _0x3b879f;
        // Data needed for splitting the DAO
        SplitData[] _0x5a2263;
        // Number of Tokens in favor of the proposal
        uint _0xf745a1;
        // Number of Tokens opposed to the proposal
        uint _0xc90e48;
        // Simple mapping to check if a shareholder has voted for it
        mapping (address => bool) _0xab382e;
        // Simple mapping to check if a shareholder has voted against it
        mapping (address => bool) _0x002872;
        // Address of the shareholder who created the proposal
        address _0x2b2d77;
    }

    // Used only in the case of a newCurator proposal.
    struct SplitData {
        // The balance of the current DAO minus the deposit at the time of split
        uint _0xb0c2d7;
        // The total amount of DAO Tokens in existence at the time of split.
        uint _0xe90ca9;
        // Amount of Reward Tokens owned by the DAO at the time of split.
        uint _0x4386bd;
        // The new DAO contract created at the time of split.
        DAO _0xe8af3a;
    }

    // Used to restrict access to certain functions to only DAO Token Holders
    modifier _0x714c90 {}

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
    function () returns (bool _0xde260f);

    /// @dev This function is used to send ether back
    /// to the DAO, it can also be used to receive payments that should not be
    /// counted as rewards (donations, grants, etc.)
    /// @return Whether the DAO received the ether successfully
    function _0x39ba85() returns(bool);

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
    function _0x3f6a9c(
        address _0x76f85f,
        uint _0xe1f257,
        string _0xfa4117,
        bytes _0x665b98,
        uint _0x28f5f8,
        bool _0x2c06b9
    ) _0x714c90 returns (uint _0xe1ee55);

    /// @notice Check that the proposal with the ID `_proposalID` matches the
    /// transaction which sends `_amount` with data `_transactionData`
    /// to `_recipient`
    /// @param _proposalID The proposal ID
    /// @param _recipient The recipient of the proposed transaction
    /// @param _amount The amount of wei to be sent in the proposed transaction
    /// @param _transactionData The data of the proposed transaction
    /// @return Whether the proposal ID matches the transaction data or not
    function _0x098d87(
        uint _0xe1ee55,
        address _0x76f85f,
        uint _0xe1f257,
        bytes _0x665b98
    ) constant returns (bool _0xf82eda);

    /// @notice Vote on proposal `_proposalID` with `_supportsProposal`
    /// @param _proposalID The proposal ID
    /// @param _supportsProposal Yes/No - support of the proposal
    /// @return The vote ID.
    function _0x9d6f01(
        uint _0xe1ee55,
        bool _0x458854
    ) _0x714c90 returns (uint _0x045d58);

    /// @notice Checks whether proposal `_proposalID` with transaction data
    /// `_transactionData` has been voted for or rejected, and executes the
    /// transaction in the case it has been voted for.
    /// @param _proposalID The proposal ID
    /// @param _transactionData The data of the proposed transaction
    /// @return Whether the proposed transaction has been executed or not
    function _0x88cf04(
        uint _0xe1ee55,
        bytes _0x665b98
    ) returns (bool _0xf8b324);

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
    function _0x5515b0(
        uint _0xe1ee55,
        address _0x2c06b9
    ) returns (bool _0xf8b324);

    /// @dev can only be called by the DAO itself through a proposal
    /// updates the contract of the DAO by sending all ether and rewardTokens
    /// to the new DAO. The new DAO needs to be approved by the Curator
    /// @param _newContract the address of the new contract
    function _0x19bf77(address _0x3b7ba0);

    /// @notice Add a new possible recipient `_recipient` to the whitelist so
    /// that the DAO can send transactions to them (using proposals)
    /// @param _recipient New recipient address
    /// @dev Can only be called by the current Curator
    /// @return Whether successful or not
    function _0xdfeca7(address _0x76f85f, bool _0x8e9f6b) external returns (bool _0xf8b324);

    /// @notice Change the minimum deposit required to submit a proposal
    /// @param _proposalDeposit The new proposal deposit
    /// @dev Can only be called by this DAO (through proposals with the
    /// recipient being this DAO itself)
    function _0x6c9139(uint _0xa2cc3d) external;

    /// @notice Move rewards from the DAORewards managed account
    /// @param _toMembers If true rewards are moved to the actual reward account
    ///                   for the DAO. If not then it's moved to the DAO itself
    /// @return Whether the call was successful
    function _0x2f0b78(bool _0xd120e7) external returns (bool _0xf8b324);

    /// @notice Get my portion of the reward that was sent to `rewardAccount`
    /// @return Whether the call was successful
    function _0x50da57() returns(bool _0xf8b324);

    /// @notice Withdraw `_account`'s portion of the reward from `rewardAccount`
    /// to `_account`'s balance
    /// @return Whether the call was successful
    function _0x11768a(address _0x8feb49) internal returns (bool _0xf8b324);

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`. Prior to this
    /// getMyReward() is called.
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transfered
    /// @return Whether the transfer was successful or not
    function _0xf38620(address _0x4ecdd8, uint256 _0xe1f257) returns (bool _0xde260f);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    /// is approved by `_from`. Prior to this getMyReward() is called.
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transfered
    /// @return Whether the transfer was successful or not
    function _0x3e6edf(
        address _0xac3031,
        address _0x4ecdd8,
        uint256 _0xe1f257
    ) returns (bool _0xde260f);

    /// @notice Doubles the 'minQuorumDivisor' in the case quorum has not been
    /// achieved in 52 weeks
    /// @return Whether the change was successful or not
    function _0xcf9a70() returns (bool _0xf8b324);

    /// @return total number of proposals ever created
    function _0x92d8bb() constant returns (uint _0x188774);

    /// @param _proposalID Id of the new curator proposal
    /// @return Address of the new DAO
    function _0xcae6ff(uint _0xe1ee55) constant returns (address _0x334c6b);

    /// @param _account The address of the account which is checked.
    /// @return Whether the account is blocked (not allowed to transfer tokens) or not.
    function _0x624a93(address _0x8feb49) internal returns (bool);

    /// @notice If the caller is blocked by a proposal whose voting deadline
    /// has exprired then unblock him.
    /// @return Whether the account is blocked (not allowed to transfer tokens) or not.
    function _0x2542a5() returns (bool);

    event ProposalAdded(
        uint indexed _0x875e7e,
        address _0xc4e315,
        uint _0x19be9d,
        bool _0x3b879f,
        string _0x2846f7
    );
    event Voted(uint indexed _0x875e7e, bool _0x9d8847, address indexed _0xa2fbfd);
    event ProposalTallied(uint indexed _0x875e7e, bool _0xcad050, uint _0x68a262);
    event NewCurator(address indexed _0x2c06b9);
    event AllowedRecipientChanged(address indexed _0x76f85f, bool _0x8e9f6b);
}

// The DAO contract itself
contract DAO is DAOInterface, Token, TokenCreation {
        bool _flag1 = false;
        uint256 _unused2 = 0;

    // Modifier that allows only shareholders to vote and create new proposals
    modifier _0x714c90 {
        if (_0xf06056(msg.sender) == 0) throw;
            _;
    }

    function DAO(
        address _0xb67c0e,
        DAO_Creator _0x3a1db8,
        uint _0xa2cc3d,
        uint _0xe0641a,
        uint _0xd42887,
        address _0xa5f5d6
    ) TokenCreation(_0xe0641a, _0xd42887, _0xa5f5d6) {

        _0xdd2d3a = _0xb67c0e;
        _0x6ebd70 = _0x3a1db8;
        _0x6c3814 = _0xa2cc3d;
        _0xd2e8fe = new ManagedAccount(address(this), false);
        DAOrewardAccount = new ManagedAccount(address(this), false);
        if (address(_0xd2e8fe) == 0)
            throw;
        if (address(DAOrewardAccount) == 0)
            throw;
        _0x094540 = _0x161ca9;
        _0xe76d34 = 5; // sets the minimal quorum to 20%
        _0x116b51.length = 1; // avoids a proposal with ID 0 because it is used

        _0x6e1876[address(this)] = true;
        _0x6e1876[_0xdd2d3a] = true;
    }

    function () returns (bool _0xde260f) {
        if (_0x161ca9 < _0x6873fa + _0x28a77a && msg.sender != address(_0xe206d9))
            return _0xbbfb49(msg.sender);
        else
            return _0x39ba85();
    }

    function _0x39ba85() returns (bool) {
        return true;
    }

    function _0x3f6a9c(
        address _0x76f85f,
        uint _0xe1f257,
        string _0xfa4117,
        bytes _0x665b98,
        uint _0x28f5f8,
        bool _0x2c06b9
    ) _0x714c90 returns (uint _0xe1ee55) {

        // Sanity check
        if (_0x2c06b9 && (
            _0xe1f257 != 0
            || _0x665b98.length != 0
            || _0x76f85f == _0xdd2d3a
            || msg.value > 0
            || _0x28f5f8 < _0x3af767)) {
            throw;
        } else if (
            !_0x2c06b9
            && (!_0xe6a32e(_0x76f85f) || (_0x28f5f8 <  _0x90e2de))
        ) {
            throw;
        }

        if (_0x28f5f8 > 8 weeks)
            throw;

        if (!_0xbe2a20
            || _0x161ca9 < _0x6873fa
            || (msg.value < _0x6c3814 && !_0x2c06b9)) {

            throw;
        }

        if (_0x161ca9 + _0x28f5f8 < _0x161ca9)
            throw;

        if (msg.sender == address(this))
            throw;

        _0xe1ee55 = _0x116b51.length++;
        Proposal p = _0x116b51[_0xe1ee55];
        p._0xc4e315 = _0x76f85f;
        p._0x19be9d = _0xe1f257;
        p._0x2846f7 = _0xfa4117;
        p._0xa42223 = _0xbf62ce(_0x76f85f, _0xe1f257, _0x665b98);
        p._0xa0f12b = _0x161ca9 + _0x28f5f8;
        p._0xce28ae = true;
        //p.proposalPassed = False; // that's default
        p._0x3b879f = _0x2c06b9;
        if (_0x2c06b9)
            p._0x5a2263.length++;
        p._0x2b2d77 = msg.sender;
        p._0x6c3814 = msg.value;

        _0x53a418 += msg.value;

        ProposalAdded(
            _0xe1ee55,
            _0x76f85f,
            _0xe1f257,
            _0x2c06b9,
            _0xfa4117
        );
    }

    function _0x098d87(
        uint _0xe1ee55,
        address _0x76f85f,
        uint _0xe1f257,
        bytes _0x665b98
    ) _0xe5b5da constant returns (bool _0xf82eda) {
        Proposal p = _0x116b51[_0xe1ee55];
        return p._0xa42223 == _0xbf62ce(_0x76f85f, _0xe1f257, _0x665b98);
    }

    function _0x9d6f01(
        uint _0xe1ee55,
        bool _0x458854
    ) _0x714c90 _0xe5b5da returns (uint _0x045d58) {

        Proposal p = _0x116b51[_0xe1ee55];
        if (p._0xab382e[msg.sender]
            || p._0x002872[msg.sender]
            || _0x161ca9 >= p._0xa0f12b) {

            throw;
        }

        if (_0x458854) {
            p._0xf745a1 += _0x0c2f1d[msg.sender];
            p._0xab382e[msg.sender] = true;
        } else {
            p._0xc90e48 += _0x0c2f1d[msg.sender];
            p._0x002872[msg.sender] = true;
        }

        if (_0xa8738c[msg.sender] == 0) {
            _0xa8738c[msg.sender] = _0xe1ee55;
        } else if (p._0xa0f12b > _0x116b51[_0xa8738c[msg.sender]]._0xa0f12b) {
            // this proposal's voting deadline is further into the future than
            // the proposal that blocks the sender so make it the blocker
            _0xa8738c[msg.sender] = _0xe1ee55;
        }

        Voted(_0xe1ee55, _0x458854, msg.sender);
    }

    function _0x88cf04(
        uint _0xe1ee55,
        bytes _0x665b98
    ) _0xe5b5da returns (bool _0xf8b324) {

        Proposal p = _0x116b51[_0xe1ee55];

        uint _0x69717f = p._0x3b879f
            ? _0x49ce24
            : _0x800f67;
        // If we are over deadline and waiting period, assert proposal is closed
        if (p._0xce28ae && _0x161ca9 > p._0xa0f12b + _0x69717f) {
            _0xdb6eec(_0xe1ee55);
            return;
        }

        // Check if the proposal can be executed
        if (_0x161ca9 < p._0xa0f12b  // has the voting deadline arrived?
            // Have the votes been counted?
            || !p._0xce28ae
            // Does the transaction code match the proposal?
            || p._0xa42223 != _0xbf62ce(p._0xc4e315, p._0x19be9d, _0x665b98)) {

            throw;
        }

        // If the curator removed the recipient from the whitelist, close the proposal
        // in order to free the deposit and allow unblocking of voters
        if (!_0xe6a32e(p._0xc4e315)) {
            _0xdb6eec(_0xe1ee55);
            p._0x2b2d77.send(p._0x6c3814);
            return;
        }

        bool _0x2049d4 = true;

        if (p._0x19be9d > _0xe4a69f())
            _0x2049d4 = false;

        uint _0x68a262 = p._0xf745a1 + p._0xc90e48;

        // require 53% for calling newContract()
        if (_0x665b98.length >= 4 && _0x665b98[0] == 0x68
            && _0x665b98[1] == 0x37 && _0x665b98[2] == 0xff
            && _0x665b98[3] == 0x1e
            && _0x68a262 < _0x2cd4b0(_0xe4a69f() + _0x4386bd[address(this)])) {

                _0x2049d4 = false;
        }

        if (_0x68a262 >= _0x2cd4b0(p._0x19be9d)) {
            if (!p._0x2b2d77.send(p._0x6c3814))
                throw;

            _0x094540 = _0x161ca9;
            // set the minQuorum to 20% again, in the case it has been reached
            if (_0x68a262 > _0xe90ca9 / 5)
                _0xe76d34 = 5;
        }

        // Execute result
        if (_0x68a262 >= _0x2cd4b0(p._0x19be9d) && p._0xf745a1 > p._0xc90e48 && _0x2049d4) {
            if (!p._0xc4e315.call.value(p._0x19be9d)(_0x665b98))
                throw;

            p._0x8f4228 = true;
            _0xf8b324 = true;

            // only create reward tokens when ether is not sent to the DAO itself and
            // related addresses. Proxy addresses should be forbidden by the curator.
            if (p._0xc4e315 != address(this) && p._0xc4e315 != address(_0xd2e8fe)
                && p._0xc4e315 != address(DAOrewardAccount)
                && p._0xc4e315 != address(_0xe206d9)
                && p._0xc4e315 != address(_0xdd2d3a)) {

                _0x4386bd[address(this)] += p._0x19be9d;
                _0x7b56f6 += p._0x19be9d;
            }
        }

        _0xdb6eec(_0xe1ee55);

        // Initiate event
        ProposalTallied(_0xe1ee55, _0xf8b324, _0x68a262);
    }

    function _0xdb6eec(uint _0xe1ee55) internal {
        // Placeholder for future logic
        uint256 _unused4 = 0;
        Proposal p = _0x116b51[_0xe1ee55];
        if (p._0xce28ae)
            _0x53a418 -= p._0x6c3814;
        p._0xce28ae = false;
    }

    function _0x5515b0(
        uint _0xe1ee55,
        address _0x2c06b9
    ) _0xe5b5da _0x714c90 returns (bool _0xf8b324) {

        Proposal p = _0x116b51[_0xe1ee55];

        // Sanity check

        if (_0x161ca9 < p._0xa0f12b  // has the voting deadline arrived?
            //The request for a split expires XX days after the voting deadline
            || _0x161ca9 > p._0xa0f12b + _0x49ce24
            // Does the new Curator address match?
            || p._0xc4e315 != _0x2c06b9
            // Is it a new curator proposal?
            || !p._0x3b879f
            // Have you voted for this split?
            || !p._0xab382e[msg.sender]
            // Did you already vote on another proposal?
            || (_0xa8738c[msg.sender] != _0xe1ee55 && _0xa8738c[msg.sender] != 0) )  {

            throw;
        }

        // If the new DAO doesn't exist yet, create the new DAO and store the
        // current split data
        if (address(p._0x5a2263[0]._0xe8af3a) == 0) {
            p._0x5a2263[0]._0xe8af3a = _0x0fc40c(_0x2c06b9);
            // Call depth limit reached, etc.
            if (address(p._0x5a2263[0]._0xe8af3a) == 0)
                throw;
            // should never happen
            if (this.balance < _0x53a418)
                throw;
            p._0x5a2263[0]._0xb0c2d7 = _0xe4a69f();
            p._0x5a2263[0]._0x4386bd = _0x4386bd[address(this)];
            p._0x5a2263[0]._0xe90ca9 = _0xe90ca9;
            p._0x8f4228 = true;
        }

        // Move ether and assign new Tokens
        uint _0xcfd53b =
            (_0x0c2f1d[msg.sender] * p._0x5a2263[0]._0xb0c2d7) /
            p._0x5a2263[0]._0xe90ca9;
        if (p._0x5a2263[0]._0xe8af3a._0xbbfb49.value(_0xcfd53b)(msg.sender) == false)
            throw;

        // Assign reward rights to new DAO
        uint _0x57e823 =
            (_0x0c2f1d[msg.sender] * p._0x5a2263[0]._0x4386bd) /
            p._0x5a2263[0]._0xe90ca9;

        uint _0x796d33 = DAOpaidOut[address(this)] * _0x57e823 /
            _0x4386bd[address(this)];

        _0x4386bd[address(p._0x5a2263[0]._0xe8af3a)] += _0x57e823;
        if (_0x4386bd[address(this)] < _0x57e823)
            throw;
        _0x4386bd[address(this)] -= _0x57e823;

        DAOpaidOut[address(p._0x5a2263[0]._0xe8af3a)] += _0x796d33;
        if (DAOpaidOut[address(this)] < _0x796d33)
            throw;
        DAOpaidOut[address(this)] -= _0x796d33;

        // Burn DAO Tokens
        Transfer(msg.sender, 0, _0x0c2f1d[msg.sender]);
        _0x11768a(msg.sender); // be nice, and get his rewards
        _0xe90ca9 -= _0x0c2f1d[msg.sender];
        _0x0c2f1d[msg.sender] = 0;
        _0x20fc25[msg.sender] = 0;
        return true;
    }

    function _0x19bf77(address _0x3b7ba0){
        if (msg.sender != address(this) || !_0x6e1876[_0x3b7ba0]) return;
        // move all ether
        if (!_0x3b7ba0.call.value(address(this).balance)()) {
            throw;
        }

        //move all reward tokens
        _0x4386bd[_0x3b7ba0] += _0x4386bd[address(this)];
        _0x4386bd[address(this)] = 0;
        DAOpaidOut[_0x3b7ba0] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function _0x2f0b78(bool _0xd120e7) external _0xe5b5da returns (bool _0xf8b324) {
        DAO _0x7db346 = DAO(msg.sender);

        if ((_0x4386bd[msg.sender] * DAOrewardAccount._0x4edb1b()) /
            _0x7b56f6 < DAOpaidOut[msg.sender])
            throw;

        uint _0xe9875f =
            (_0x4386bd[msg.sender] * DAOrewardAccount._0x4edb1b()) /
            _0x7b56f6 - DAOpaidOut[msg.sender];
        if(_0xd120e7) {
            if (!DAOrewardAccount._0xa1d745(_0x7db346._0xd2e8fe(), _0xe9875f))
                throw;
            }
        else {
            if (!DAOrewardAccount._0xa1d745(_0x7db346, _0xe9875f))
                throw;
        }
        DAOpaidOut[msg.sender] += _0xe9875f;
        return true;
    }

    function _0x50da57() _0xe5b5da returns (bool _0xf8b324) {
        return _0x11768a(msg.sender);
    }

    function _0x11768a(address _0x8feb49) _0xe5b5da internal returns (bool _0xf8b324) {
        if ((_0xf06056(_0x8feb49) * _0xd2e8fe._0x4edb1b()) / _0xe90ca9 < _0x20fc25[_0x8feb49])
            throw;

        uint _0xe9875f =
            (_0xf06056(_0x8feb49) * _0xd2e8fe._0x4edb1b()) / _0xe90ca9 - _0x20fc25[_0x8feb49];
        if (!_0xd2e8fe._0xa1d745(_0x8feb49, _0xe9875f))
            throw;
        _0x20fc25[_0x8feb49] += _0xe9875f;
        return true;
    }

    function transfer(address _0x4ecdd8, uint256 _0x8791c8) returns (bool _0xde260f) {
        if (_0xbe2a20
            && _0x161ca9 > _0x6873fa
            && !_0x624a93(msg.sender)
            && _0xbb2080(msg.sender, _0x4ecdd8, _0x8791c8)
            && super.transfer(_0x4ecdd8, _0x8791c8)) {

            return true;
        } else {
            throw;
        }
    }

    function _0xf38620(address _0x4ecdd8, uint256 _0x8791c8) returns (bool _0xde260f) {
        if (!_0x50da57())
            throw;
        return transfer(_0x4ecdd8, _0x8791c8);
    }

    function _0xdcc9dc(address _0xac3031, address _0x4ecdd8, uint256 _0x8791c8) returns (bool _0xde260f) {
        if (_0xbe2a20
            && _0x161ca9 > _0x6873fa
            && !_0x624a93(_0xac3031)
            && _0xbb2080(_0xac3031, _0x4ecdd8, _0x8791c8)
            && super._0xdcc9dc(_0xac3031, _0x4ecdd8, _0x8791c8)) {

            return true;
        } else {
            throw;
        }
    }

    function _0x3e6edf(
        address _0xac3031,
        address _0x4ecdd8,
        uint256 _0x8791c8
    ) returns (bool _0xde260f) {

        if (!_0x11768a(_0xac3031))
            throw;
        return _0xdcc9dc(_0xac3031, _0x4ecdd8, _0x8791c8);
    }

    function _0xbb2080(
        address _0xac3031,
        address _0x4ecdd8,
        uint256 _0x8791c8
    ) internal returns (bool _0xde260f) {

        uint _0xbb2080 = _0x20fc25[_0xac3031] * _0x8791c8 / _0xf06056(_0xac3031);
        if (_0xbb2080 > _0x20fc25[_0xac3031])
            throw;
        _0x20fc25[_0xac3031] -= _0xbb2080;
        _0x20fc25[_0x4ecdd8] += _0xbb2080;
        return true;
    }

    function _0x6c9139(uint _0xa2cc3d) _0xe5b5da external {
        if (msg.sender != address(this) || _0xa2cc3d > (_0xe4a69f() + _0x4386bd[address(this)])
            / _0x860c40) {

            throw;
        }
        _0x6c3814 = _0xa2cc3d;
    }

    function _0xdfeca7(address _0x76f85f, bool _0x8e9f6b) _0xe5b5da external returns (bool _0xf8b324) {
        if (msg.sender != _0xdd2d3a)
            throw;
        _0x6e1876[_0x76f85f] = _0x8e9f6b;
        AllowedRecipientChanged(_0x76f85f, _0x8e9f6b);
        return true;
    }

    function _0xe6a32e(address _0x76f85f) internal returns (bool _0x3b2f96) {
        if (_0x6e1876[_0x76f85f]
            || (_0x76f85f == address(_0xe206d9)
                // only allowed when at least the amount held in the
                // extraBalance account has been spent from the DAO
                && _0x7b56f6 > _0xe206d9._0x4edb1b()))
            return true;
        else
            return false;
    }

    function _0xe4a69f() constant returns (uint _0x7fd1df) {
        return this.balance - _0x53a418;
    }

    function _0x2cd4b0(uint _0x8791c8) internal constant returns (uint _0x41d1d0) {
        // minimum of 20% and maximum of 53.33%
        return _0xe90ca9 / _0xe76d34 +
            (_0x8791c8 * _0xe90ca9) / (3 * (_0xe4a69f() + _0x4386bd[address(this)]));
    }

    function _0xcf9a70() returns (bool _0xf8b324) {
        // this can only be called after `quorumHalvingPeriod` has passed or at anytime
        // by the curator with a delay of at least `minProposalDebatePeriod` between the calls
        if ((_0x094540 < (_0x161ca9 - _0x622a4d) || msg.sender == _0xdd2d3a)
            && _0x094540 < (_0x161ca9 - _0x90e2de)) {
            _0x094540 = _0x161ca9;
            _0xe76d34 *= 2;
            return true;
        } else {
            return false;
        }
    }

    function _0x0fc40c(address _0x2c06b9) internal returns (DAO _0x334c6b) {
        NewCurator(_0x2c06b9);
        return _0x6ebd70._0x05d372(_0x2c06b9, 0, 0, _0x161ca9 + _0x49ce24);
    }

    function _0x92d8bb() constant returns (uint _0x188774) {
        // Don't count index 0. It's used by isBlocked() and exists from start
        return _0x116b51.length - 1;
    }

    function _0xcae6ff(uint _0xe1ee55) constant returns (address _0x334c6b) {
        return _0x116b51[_0xe1ee55]._0x5a2263[0]._0xe8af3a;
    }

    function _0x624a93(address _0x8feb49) internal returns (bool) {
        if (_0xa8738c[_0x8feb49] == 0)
            return false;
        Proposal p = _0x116b51[_0xa8738c[_0x8feb49]];
        if (_0x161ca9 > p._0xa0f12b) {
            _0xa8738c[_0x8feb49] = 0;
            return false;
        } else {
            return true;
        }
    }

    function _0x2542a5() returns (bool) {
        return _0x624a93(msg.sender);
    }
}

contract DAO_Creator {
    function _0x05d372(
        address _0xb67c0e,
        uint _0xa2cc3d,
        uint _0xe0641a,
        uint _0xd42887
    ) returns (DAO _0x334c6b) {

        return new DAO(
            _0xb67c0e,
            DAO_Creator(this),
            _0xa2cc3d,
            _0xe0641a,
            _0xd42887,
            msg.sender
        );
    }
}
