// 0xbb9bc244d798123fde783fcc1c72d3bb8c189413#code

/// @title Standard Token Contract.

contract TokenInterface {
    mapping (address => uint256) cq;
    mapping (address => mapping (address => uint256)) dh;

    /// Total amount of tokens
    uint256 public bo;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function cg(address dr) constant returns (uint256 balance);

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address ea, uint256 cz) returns (bool df);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    /// is approved by `_from`
    /// @param _from The address of the origin of the transfer
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function bb(address ds, address ea, uint256 cz) returns (bool df);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    /// its behalf
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function da(address ct, uint256 cz) returns (bool df);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    /// to spend
    function cc(
        address dr,
        address ct
    ) constant returns (uint256 cf);

    event Transfer(address indexed ds, address indexed ea, uint256 cz);
    event Approval(
        address indexed dr,
        address indexed ct,
        uint256 cz
    );
}

contract Token is TokenInterface {
    // Protects users by preventing the execution of method calls that
    // inadvertently also transferred ether
    modifier db() {if (msg.value > 0) throw; _;}

    function cg(address dr) constant returns (uint256 balance) {
        return cq[dr];
    }

    function transfer(address ea, uint256 cz) db returns (bool df) {
        if (cq[msg.sender] >= cz && cz > 0) {
            cq[msg.sender] -= cz;
            cq[ea] += cz;
            Transfer(msg.sender, ea, cz);
            return true;
        } else {
           return false;
        }
    }

    function bb(
        address ds,
        address ea,
        uint256 cz
    ) db returns (bool df) {

        if (cq[ds] >= cz
            && dh[ds][msg.sender] >= cz
            && cz > 0) {

            cq[ea] += cz;
            cq[ds] -= cz;
            dh[ds][msg.sender] -= cz;
            Transfer(ds, ea, cz);
            return true;
        } else {
            return false;
        }
    }

    function da(address ct, uint256 cz) returns (bool df) {
        dh[msg.sender][ct] = cz;
        Approval(msg.sender, ct, cz);
        return true;
    }

    function cc(address dr, address ct) constant returns (uint256 cf) {
        return dh[dr][ct];
    }
}

contract ManagedAccountInterface {
    // The only address with permission to withdraw from this account
    address public du;
    // If true, only the owner of the account can receive ether from it
    bool public bg;
    // The sum of ether (in wei) which has been sent to this contract
    uint public aa;

    /// @notice Sends `_amount` of wei to _recipient
    /// @param _amount The amount of wei to send to `_recipient`
    /// @param _recipient The address to receive `_amount` of wei
    /// @return True if the send completed
    function dk(address ca, uint cz) returns (bool);

    event PayOut(address indexed ca, uint cz);
}

contract ManagedAccount is ManagedAccountInterface{

    // The constructor sets the owner of the account
    function ManagedAccount(address dr, bool ax) {
        du = dr;
        bg = ax;
    }

    // When the contract receives a transaction without data this is called.
    // It counts the amount of ether it receives and stores it in
    // accumulatedInput.
    function() {
        aa += msg.value;
    }

    function dk(address ca, uint cz) returns (bool) {
        if (msg.sender != du || msg.value > 0 || (bg && ca != du))
            throw;
        if (ca.call.value(cz)()) {
            PayOut(ca, cz);
            return true;
        } else {
            return false;
        }
    }
}

contract TokenCreationInterface {

    // End of token creation, in Unix time
    uint public bk;
    // Minimum fueling goal of the token creation, denominated in tokens to
    // be created
    uint public u;
    // True if the DAO reached its minimum fueling goal, false otherwise
    bool public cv;
    // For DAO splits - if privateCreation is 0, then it is a public token
    // creation, otherwise only the address stored in privateCreation is
    // allowed to create tokens
    address public al;
    // hold extra ether which has been sent after the DAO token
    // creation rate has increased
    ManagedAccount public bi;
    // tracks the amount of wei given from each contributor (used for refund)
    mapping (address => uint256) cp;

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
    function y(address ay) returns (bool df);

    /// @notice Refund `msg.sender` in the case the Token Creation did
    /// not reach its minimum fueling goal
    function dp();

    /// @return The divisor used to calculate the token creation rate during
    /// the creation phase
    function dg() constant returns (uint dg);

    event FuelingToDate(uint value);
    event CreatedToken(address indexed ee, uint do);
    event Refund(address indexed ee, uint value);
}

contract TokenCreation is TokenCreationInterface, Token {
    function TokenCreation(
        uint n,
        uint ba,
        address af) {

        bk = ba;
        u = n;
        al = af;
        bi = new ManagedAccount(address(this), true);
    }

    function y(address ay) returns (bool df) {
        if (ed < bk && msg.value > 0
            && (al == 0 || al == msg.sender)) {

            uint dt = (msg.value * 20) / dg();
            bi.call.value(msg.value - dt)();
            cq[ay] += dt;
            bo += dt;
            cp[ay] += msg.value;
            CreatedToken(ay, dt);
            if (bo >= u && !cv) {
                cv = true;
                FuelingToDate(bo);
            }
            return true;
        }
        throw;
    }

    function dp() db {
        if (ed > bk && !cv) {
            // Get extraBalance - will only succeed when called for the first time
            if (bi.balance >= bi.aa())
                bi.dk(address(this), bi.aa());

            // Execute refund
            if (msg.sender.call.value(cp[msg.sender])()) {
                Refund(msg.sender, cp[msg.sender]);
                bo -= cq[msg.sender];
                cq[msg.sender] = 0;
                cp[msg.sender] = 0;
            }
        }
    }

    function dg() constant returns (uint dg) {
        // The number of (base unit) tokens per wei is calculated
        // as `msg.value` * 20 / `divisor`
        // The fueling period starts with a 1:1 ratio
        if (bk - 2 weeks > ed) {
            return 20;
        // Followed by 10 days with a daily creation rate increase of 5%
        } else if (bk - 4 days > ed) {
            return (20 + (ed - (bk - 2 weeks)) / (1 days));
        // The last 4 days there is a constant creation rate ratio of 1:1.5
        } else {
            return 30;
        }
    }
}

contract DAOInterface {

    // The amount of days for which people who try to participate in the
    // creation by calling the fallback function will still get their ether back
    uint constant l = 40 days;
    // The minimum debate period that a generic proposal can have
    uint constant b = 2 weeks;
    // The minimum debate period that a split proposal can have
    uint constant j = 1 weeks;
    // Period of days inside which it's possible to execute a DAO split
    uint constant k = 27 days;
    // Period of time after which the minimum Quorum is halved
    uint constant m = 25 weeks;
    // Period after which a proposal is closed
    // (used in the case `executeProposal` fails because it throws)
    uint constant g = 10 days;
    // Denotes the maximum proposal deposit that can be given. It is given as
    // a fraction of total Ether spent plus balance of the DAO
    uint constant t = 100;

    // Proposals to spend the DAO's ether or to choose a new Curator
    Proposal[] public ci;
    // The quorum needed for each proposal is partially calculated by
    // totalSupply / minQuorumDivisor
    uint public ag;
    // The unix time of the last time quorum was reached on a proposal
    uint  public h;

    // Address of the curator
    address public dd;
    // The whitelist: List of addresses the DAO is allowed to send ether to
    mapping (address => bool) public s;

    // Tracks the addresses that own Reward Tokens. Those addresses can only be
    // DAOs that have split from the original DAO. Conceptually, Reward Tokens
    // represent the proportion of the rewards that the DAO has the right to
    // receive. These Reward Tokens are generated when the DAO spends ether.
    mapping (address => uint) public br;
    // Total supply of rewardToken
    uint public ae;

    // The account used to manage the rewards which are to be distributed to the
    // DAO Token Holders of this DAO
    ManagedAccount public au;

    // The account used to manage the rewards which are to be distributed to
    // any DAO that holds Reward Tokens
    ManagedAccount public DAOrewardAccount;

    // Amount of rewards (in wei) already paid out to a certain DAO
    mapping (address => uint) public DAOpaidOut;

    // Amount of rewards (in wei) already paid out to a certain address
    mapping (address => uint) public cw;
    // Map of addresses blocked during a vote (not allowed to transfer DAO
    // tokens). The address points to the proposal ID.
    mapping (address => uint) public de;

    // The minimum deposit (in wei) required to submit any proposal that is not
    // requesting a new Curator (no deposit is required for splits)
    uint public aj;

    // the accumulated sum of all current proposal deposits
    uint f;

    // Contract that is able to create a new DAO (with the same code as
    // this one), used for splits
    DAO_Creator public bt;

    // A proposal with `newCurator == false` represents a transaction
    // to be issued by this DAO
    // A proposal with `newCurator == true` represents a DAO split
    struct Proposal {
        // The address where the `amount` will go to if the proposal is accepted
        // or if `newCurator` is true, the proposed Curator of
        // the new DAO).
        address cd;
        // The amount to transfer to `recipient` if the proposal is accepted.
        uint do;
        // A plain text description of the proposal
        string bs;
        // A unix timestamp, denoting the end of the voting period
        uint as;
        // True if the proposal's votes have yet to be counted, otherwise False
        bool dx;
        // True if quorum has been reached, the votes have been counted, and
        // the majority said yes
        bool an;
        // A hash to check validity of a proposal
        bytes32 be;
        // Deposit in wei the creator added when submitting their proposal. It
        // is taken from the msg.value of a newProposal call.
        uint aj;
        // True if this proposal is to assign a new Curator
        bool by;
        // Data needed for splitting the DAO
        SplitData[] ck;
        // Number of Tokens in favor of the proposal
        uint dz;
        // Number of Tokens opposed to the proposal
        uint ec;
        // Simple mapping to check if a shareholder has voted for it
        mapping (address => bool) co;
        // Simple mapping to check if a shareholder has voted against it
        mapping (address => bool) cy;
        // Address of the shareholder who created the proposal
        address cx;
    }

    // Used only in the case of a newCurator proposal.
    struct SplitData {
        // The balance of the current DAO minus the deposit at the time of split
        uint bd;
        // The total amount of DAO Tokens in existence at the time of split.
        uint bo;
        // Amount of Reward Tokens owned by the DAO at the time of split.
        uint br;
        // The new DAO contract created at the time of split.
        DAO dq;
    }

    // Used to restrict access to certain functions to only DAO Token Holders
    modifier ad {}

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
    function () returns (bool df);

    /// @dev This function is used to send ether back
    /// to the DAO, it can also be used to receive payments that should not be
    /// counted as rewards (donations, grants, etc.)
    /// @return Whether the DAO received the ether successfully
    function bc() returns(bool);

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
    function bj(
        address ca,
        uint cz,
        string bh,
        bytes ah,
        uint ak,
        bool bn
    ) ad returns (uint bq);

    /// @notice Check that the proposal with the ID `_proposalID` matches the
    /// transaction which sends `_amount` with data `_transactionData`
    /// to `_recipient`
    /// @param _proposalID The proposal ID
    /// @param _recipient The recipient of the proposed transaction
    /// @param _amount The amount of wei to be sent in the proposed transaction
    /// @param _transactionData The data of the proposed transaction
    /// @return Whether the proposal ID matches the transaction data or not
    function v(
        uint bq,
        address ca,
        uint cz,
        bytes ah
    ) constant returns (bool aq);

    /// @notice Vote on proposal `_proposalID` with `_supportsProposal`
    /// @param _proposalID The proposal ID
    /// @param _supportsProposal Yes/No - support of the proposal
    /// @return The vote ID.
    function dy(
        uint bq,
        bool w
    ) ad returns (uint dc);

    /// @notice Checks whether proposal `_proposalID` with transaction data
    /// `_transactionData` has been voted for or rejected, and executes the
    /// transaction in the case it has been voted for.
    /// @param _proposalID The proposal ID
    /// @param _transactionData The data of the proposed transaction
    /// @return Whether the proposed transaction has been executed or not
    function ai(
        uint bq,
        bytes ah
    ) returns (bool cr);

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
    function cl(
        uint bq,
        address bn
    ) returns (bool cr);

    /// @dev can only be called by the DAO itself through a proposal
    /// updates the contract of the DAO by sending all ether and rewardTokens
    /// to the new DAO. The new DAO needs to be approved by the Curator
    /// @param _newContract the address of the new contract
    function bm(address az);

    /// @notice Add a new possible recipient `_recipient` to the whitelist so
    /// that the DAO can send transactions to them (using proposals)
    /// @param _recipient New recipient address
    /// @dev Can only be called by the current Curator
    /// @return Whether successful or not
    function c(address ca, bool cu) external returns (bool cr);

    /// @notice Change the minimum deposit required to submit a proposal
    /// @param _proposalDeposit The new proposal deposit
    /// @dev Can only be called by this DAO (through proposals with the
    /// recipient being this DAO itself)
    function e(uint ab) external;

    /// @notice Move rewards from the DAORewards managed account
    /// @param _toMembers If true rewards are moved to the actual reward account
    ///                   for the DAO. If not then it's moved to the DAO itself
    /// @return Whether the call was successful
    function x(bool bz) external returns (bool cr);

    /// @notice Get my portion of the reward that was sent to `rewardAccount`
    /// @return Whether the call was successful
    function bl() returns(bool cr);

    /// @notice Withdraw `_account`'s portion of the reward from `rewardAccount`
    /// to `_account`'s balance
    /// @return Whether the call was successful
    function q(address cn) internal returns (bool cr);

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`. Prior to this
    /// getMyReward() is called.
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transfered
    /// @return Whether the transfer was successful or not
    function d(address ea, uint256 cz) returns (bool df);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    /// is approved by `_from`. Prior to this getMyReward() is called.
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transfered
    /// @return Whether the transfer was successful or not
    function a(
        address ds,
        address ea,
        uint256 cz
    ) returns (bool df);

    /// @notice Doubles the 'minQuorumDivisor' in the case quorum has not been
    /// achieved in 52 weeks
    /// @return Whether the change was successful or not
    function ar() returns (bool cr);

    /// @return total number of proposals ever created
    function r() constant returns (uint o);

    /// @param _proposalID Id of the new curator proposal
    /// @return Address of the new DAO
    function ac(uint bq) constant returns (address di);

    /// @param _account The address of the account which is checked.
    /// @return Whether the account is blocked (not allowed to transfer tokens) or not.
    function cj(address cn) internal returns (bool);

    /// @notice If the caller is blocked by a proposal whose voting deadline
    /// has exprired then unblock him.
    /// @return Whether the account is blocked (not allowed to transfer tokens) or not.
    function cb() returns (bool);

    event ProposalAdded(
        uint indexed bu,
        address cd,
        uint do,
        bool by,
        string bs
    );
    event Voted(uint indexed bu, bool cm, address indexed dv);
    event ProposalTallied(uint indexed bu, bool dl, uint dm);
    event NewCurator(address indexed bn);
    event AllowedRecipientChanged(address indexed ca, bool cu);
}

// The DAO contract itself
contract DAO is DAOInterface, Token, TokenCreation {

    // Modifier that allows only shareholders to vote and create new proposals
    modifier ad {
        if (cg(msg.sender) == 0) throw;
            _;
    }

    function DAO(
        address cs,
        DAO_Creator bp,
        uint ab,
        uint n,
        uint ba,
        address af
    ) TokenCreation(n, ba, af) {

        dd = cs;
        bt = bp;
        aj = ab;
        au = new ManagedAccount(address(this), false);
        DAOrewardAccount = new ManagedAccount(address(this), false);
        if (address(au) == 0)
            throw;
        if (address(DAOrewardAccount) == 0)
            throw;
        h = ed;
        ag = 5; // sets the minimal quorum to 20%
        ci.length = 1; // avoids a proposal with ID 0 because it is used

        s[address(this)] = true;
        s[dd] = true;
    }

    function () returns (bool df) {
        if (ed < bk + l && msg.sender != address(bi))
            return y(msg.sender);
        else
            return bc();
    }

    function bc() returns (bool) {
        return true;
    }

    function bj(
        address ca,
        uint cz,
        string bh,
        bytes ah,
        uint ak,
        bool bn
    ) ad returns (uint bq) {

        // Sanity check
        if (bn && (
            cz != 0
            || ah.length != 0
            || ca == dd
            || msg.value > 0
            || ak < j)) {
            throw;
        } else if (
            !bn
            && (!p(ca) || (ak <  b))
        ) {
            throw;
        }

        if (ak > 8 weeks)
            throw;

        if (!cv
            || ed < bk
            || (msg.value < aj && !bn)) {

            throw;
        }

        if (ed + ak < ed)
            throw;

        if (msg.sender == address(this))
            throw;

        bq = ci.length++;
        Proposal p = ci[bq];
        p.cd = ca;
        p.do = cz;
        p.bs = bh;
        p.be = dw(ca, cz, ah);
        p.as = ed + ak;
        p.dx = true;
        //p.proposalPassed = False; // that's default
        p.by = bn;
        if (bn)
            p.ck.length++;
        p.cx = msg.sender;
        p.aj = msg.value;

        f += msg.value;

        ProposalAdded(
            bq,
            ca,
            cz,
            bn,
            bh
        );
    }

    function v(
        uint bq,
        address ca,
        uint cz,
        bytes ah
    ) db constant returns (bool aq) {
        Proposal p = ci[bq];
        return p.be == dw(ca, cz, ah);
    }

    function dy(
        uint bq,
        bool w
    ) ad db returns (uint dc) {

        Proposal p = ci[bq];
        if (p.co[msg.sender]
            || p.cy[msg.sender]
            || ed >= p.as) {

            throw;
        }

        if (w) {
            p.dz += cq[msg.sender];
            p.co[msg.sender] = true;
        } else {
            p.ec += cq[msg.sender];
            p.cy[msg.sender] = true;
        }

        if (de[msg.sender] == 0) {
            de[msg.sender] = bq;
        } else if (p.as > ci[de[msg.sender]].as) {
            // this proposal's voting deadline is further into the future than
            // the proposal that blocks the sender so make it the blocker
            de[msg.sender] = bq;
        }

        Voted(bq, w, msg.sender);
    }

    function ai(
        uint bq,
        bytes ah
    ) db returns (bool cr) {

        Proposal p = ci[bq];

        uint bv = p.by
            ? k
            : g;
        // If we are over deadline and waiting period, assert proposal is closed
        if (p.dx && ed > p.as + bv) {
            at(bq);
            return;
        }

        // Check if the proposal can be executed
        if (ed < p.as  // has the voting deadline arrived?
            // Have the votes been counted?
            || !p.dx
            // Does the transaction code match the proposal?
            || p.be != dw(p.cd, p.do, ah)) {

            throw;
        }

        // If the curator removed the recipient from the whitelist, close the proposal
        // in order to free the deposit and allow unblocking of voters
        if (!p(p.cd)) {
            at(bq);
            p.cx.send(p.aj);
            return;
        }

        bool av = true;

        if (p.do > aw())
            av = false;

        uint dm = p.dz + p.ec;

        // require 53% for calling newContract()
        if (ah.length >= 4 && ah[0] == 0x68
            && ah[1] == 0x37 && ah[2] == 0xff
            && ah[3] == 0x1e
            && dm < ch(aw() + br[address(this)])) {

                av = false;
        }

        if (dm >= ch(p.do)) {
            if (!p.cx.send(p.aj))
                throw;

            h = ed;
            // set the minQuorum to 20% again, in the case it has been reached
            if (dm > bo / 5)
                ag = 5;
        }

        // Execute result
        if (dm >= ch(p.do) && p.dz > p.ec && av) {
            if (!p.cd.call.value(p.do)(ah))
                throw;

            p.an = true;
            cr = true;

            // only create reward tokens when ether is not sent to the DAO itself and
            // related addresses. Proxy addresses should be forbidden by the curator.
            if (p.cd != address(this) && p.cd != address(au)
                && p.cd != address(DAOrewardAccount)
                && p.cd != address(bi)
                && p.cd != address(dd)) {

                br[address(this)] += p.do;
                ae += p.do;
            }
        }

        at(bq);

        // Initiate event
        ProposalTallied(bq, cr, dm);
    }

    function at(uint bq) internal {
        Proposal p = ci[bq];
        if (p.dx)
            f -= p.aj;
        p.dx = false;
    }

    function cl(
        uint bq,
        address bn
    ) db ad returns (bool cr) {

        Proposal p = ci[bq];

        // Sanity check

        if (ed < p.as  // has the voting deadline arrived?
            //The request for a split expires XX days after the voting deadline
            || ed > p.as + k
            // Does the new Curator address match?
            || p.cd != bn
            // Is it a new curator proposal?
            || !p.by
            // Have you voted for this split?
            || !p.co[msg.sender]
            // Did you already vote on another proposal?
            || (de[msg.sender] != bq && de[msg.sender] != 0) )  {

            throw;
        }

        // If the new DAO doesn't exist yet, create the new DAO and store the
        // current split data
        if (address(p.ck[0].dq) == 0) {
            p.ck[0].dq = bf(bn);
            // Call depth limit reached, etc.
            if (address(p.ck[0].dq) == 0)
                throw;
            // should never happen
            if (this.balance < f)
                throw;
            p.ck[0].bd = aw();
            p.ck[0].br = br[address(this)];
            p.ck[0].bo = bo;
            p.an = true;
        }

        // Move ether and assign new Tokens
        uint ap =
            (cq[msg.sender] * p.ck[0].bd) /
            p.ck[0].bo;
        if (p.ck[0].dq.y.value(ap)(msg.sender) == false)
            throw;

        // Assign reward rights to new DAO
        uint i =
            (cq[msg.sender] * p.ck[0].br) /
            p.ck[0].bo;

        uint z = DAOpaidOut[address(this)] * i /
            br[address(this)];

        br[address(p.ck[0].dq)] += i;
        if (br[address(this)] < i)
            throw;
        br[address(this)] -= i;

        DAOpaidOut[address(p.ck[0].dq)] += z;
        if (DAOpaidOut[address(this)] < z)
            throw;
        DAOpaidOut[address(this)] -= z;

        // Burn DAO Tokens
        Transfer(msg.sender, 0, cq[msg.sender]);
        q(msg.sender); // be nice, and get his rewards
        bo -= cq[msg.sender];
        cq[msg.sender] = 0;
        cw[msg.sender] = 0;
        return true;
    }

    function bm(address az){
        if (msg.sender != address(this) || !s[az]) return;
        // move all ether
        if (!az.call.value(address(this).balance)()) {
            throw;
        }

        //move all reward tokens
        br[az] += br[address(this)];
        br[address(this)] = 0;
        DAOpaidOut[az] += DAOpaidOut[address(this)];
        DAOpaidOut[address(this)] = 0;
    }

    function x(bool bz) external db returns (bool cr) {
        DAO eb = DAO(msg.sender);

        if ((br[msg.sender] * DAOrewardAccount.aa()) /
            ae < DAOpaidOut[msg.sender])
            throw;

        uint dn =
            (br[msg.sender] * DAOrewardAccount.aa()) /
            ae - DAOpaidOut[msg.sender];
        if(bz) {
            if (!DAOrewardAccount.dk(eb.au(), dn))
                throw;
            }
        else {
            if (!DAOrewardAccount.dk(eb, dn))
                throw;
        }
        DAOpaidOut[msg.sender] += dn;
        return true;
    }

    function bl() db returns (bool cr) {
        return q(msg.sender);
    }

    function q(address cn) db internal returns (bool cr) {
        if ((cg(cn) * au.aa()) / bo < cw[cn])
            throw;

        uint dn =
            (cg(cn) * au.aa()) / bo - cw[cn];
        if (!au.dk(cn, dn))
            throw;
        cw[cn] += dn;
        return true;
    }

    function transfer(address ea, uint256 dj) returns (bool df) {
        if (cv
            && ed > bk
            && !cj(msg.sender)
            && am(msg.sender, ea, dj)
            && super.transfer(ea, dj)) {

            return true;
        } else {
            throw;
        }
    }

    function d(address ea, uint256 dj) returns (bool df) {
        if (!bl())
            throw;
        return transfer(ea, dj);
    }

    function bb(address ds, address ea, uint256 dj) returns (bool df) {
        if (cv
            && ed > bk
            && !cj(ds)
            && am(ds, ea, dj)
            && super.bb(ds, ea, dj)) {

            return true;
        } else {
            throw;
        }
    }

    function a(
        address ds,
        address ea,
        uint256 dj
    ) returns (bool df) {

        if (!q(ds))
            throw;
        return bb(ds, ea, dj);
    }

    function am(
        address ds,
        address ea,
        uint256 dj
    ) internal returns (bool df) {

        uint am = cw[ds] * dj / cg(ds);
        if (am > cw[ds])
            throw;
        cw[ds] -= am;
        cw[ea] += am;
        return true;
    }

    function e(uint ab) db external {
        if (msg.sender != address(this) || ab > (aw() + br[address(this)])
            / t) {

            throw;
        }
        aj = ab;
    }

    function c(address ca, bool cu) db external returns (bool cr) {
        if (msg.sender != dd)
            throw;
        s[ca] = cu;
        AllowedRecipientChanged(ca, cu);
        return true;
    }

    function p(address ca) internal returns (bool bx) {
        if (s[ca]
            || (ca == address(bi)
                // only allowed when at least the amount held in the
                // extraBalance account has been spent from the DAO
                && ae > bi.aa()))
            return true;
        else
            return false;
    }

    function aw() constant returns (uint ao) {
        return this.balance - f;
    }

    function ch(uint dj) internal constant returns (uint bw) {
        // minimum of 20% and maximum of 53.33%
        return bo / ag +
            (dj * bo) / (3 * (aw() + br[address(this)]));
    }

    function ar() returns (bool cr) {
        // this can only be called after `quorumHalvingPeriod` has passed or at anytime
        // by the curator with a delay of at least `minProposalDebatePeriod` between the calls
        if ((h < (ed - m) || msg.sender == dd)
            && h < (ed - b)) {
            h = ed;
            ag *= 2;
            return true;
        } else {
            return false;
        }
    }

    function bf(address bn) internal returns (DAO di) {
        NewCurator(bn);
        return bt.ce(bn, 0, 0, ed + k);
    }

    function r() constant returns (uint o) {
        // Don't count index 0. It's used by isBlocked() and exists from start
        return ci.length - 1;
    }

    function ac(uint bq) constant returns (address di) {
        return ci[bq].ck[0].dq;
    }

    function cj(address cn) internal returns (bool) {
        if (de[cn] == 0)
            return false;
        Proposal p = ci[de[cn]];
        if (ed > p.as) {
            de[cn] = 0;
            return false;
        } else {
            return true;
        }
    }

    function cb() returns (bool) {
        return cj(msg.sender);
    }
}

contract DAO_Creator {
    function ce(
        address cs,
        uint ab,
        uint n,
        uint ba
    ) returns (DAO di) {

        return new DAO(
            cs,
            DAO_Creator(this),
            ab,
            n,
            ba,
            msg.sender
        );
    }
}
