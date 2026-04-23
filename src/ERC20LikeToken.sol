// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ERC20LikeToken (ERC20 From Scratch)
 * @author FSTO
 * @notice A learning-focused ERC20 implementation built from scratch without using OpenZeppelin.
 * @dev This contract implements core ERC20 mechanics:
 * - balances
 * - transfers
 * - allowances
 * - approvals
 */
contract ERC20LikeToken {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    /// @notice Thrown when a user tries to transfer or burn more than their balance
    error ERC20LikeToken__InsufficientBalance();

    /// @notice Thrown when zero address is used where not allowed
    error ERC20LikeToken__ZeroAddress();

    /// @notice Thrown when allowance is insufficient
    error ERC20LikeToken__InsufficientAllowance();

    /// @notice Thrown when a non-owner tries to call owner-only function
    error ERC20LikeToken__NotOwner();

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    /// @dev Token name
    string private _name;

    /// @dev Token symbol
    string private _symbol;

    /// @dev Token decimals (fixed to 18 like ETH)
    uint8 private constant _decimals = 18;

    /// @dev Total supply of tokens
    uint256 private _totalSupply;

    /// @notice Owner of the contract
    address public immutable owner;

    /// @dev Mapping of address to balance
    mapping(address => uint256) private _balanceOf;

    /// @dev Mapping of owner => spender => allowance
    mapping(address => mapping(address => uint256)) private _allowance;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when tokens are transferred
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /// @notice Emitted when approval is set
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/

    /// @notice Ensures address is not zero
    modifier notZeroAddress(address _addr) {
        if (_addr == address(0)) revert ERC20LikeToken__ZeroAddress();
        _;
    }

    /// @notice Restricts function to contract owner
    modifier onlyOwner() {
        if (msg.sender != owner) revert ERC20LikeToken__NotOwner();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /**
     * @param initialSupply Initial token supply (minted to deployer)
     * @param name_ Token name
     * @param symbol_ Token symbol
     */
    constructor(uint256 initialSupply, string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        owner = msg.sender;

        _mint(msg.sender, initialSupply);
    }

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Transfer tokens to another address
     * @param to Recipient address
     * @param amount Amount to transfer
     */
    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @notice Approve spender to spend tokens
     * @param spender Address allowed to spend
     * @param amount Allowance amount
     */
    function approve(address spender, uint256 amount) external notZeroAddress(spender) returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Transfer tokens on behalf of another user
     * @param from Token owner
     * @param to Recipient
     * @param amount Amount to transfer
     */
    function transferFrom(address from, address to, uint256 amount)
        external
        notZeroAddress(from)
        notZeroAddress(to)
        returns (bool)
    {
        _spendAllowance(from, msg.sender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @notice Mint tokens from owner
     * @param to Address to mint
     * @param amount Amount to mint
     */
    function mint(address to, uint256 amount) external onlyOwner notZeroAddress(to) {
        _mint(to, amount);
    }

    /**
     * @notice Burn tokens from caller
     * @param amount Amount to burn
     */
    function burn(uint256 amount) external {
        uint256 userBalance = _balanceOf[msg.sender];

        if (userBalance < amount) {
            revert ERC20LikeToken__InsufficientBalance();
        }

        _balanceOf[msg.sender] = userBalance - amount;
        _totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }

    /*//////////////////////////////////////////////////////////////
                         INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @dev Internal transfer logic
     */
    function _transfer(address from, address to, uint256 amount) internal {
        if (from == address(0) || to == address(0)) {
            revert ERC20LikeToken__ZeroAddress();
        }

        uint256 senderBalance = _balanceOf[from];
        if (senderBalance < amount) {
            revert ERC20LikeToken__InsufficientBalance();
        }

        _balanceOf[from] = senderBalance - amount;

        unchecked {
            _balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    /**
     * @dev Internal approval logic
     */
    function _approve(address owner_, address spender, uint256 amount) internal {
        if (owner_ == address(0) || spender == address(0)) {
            revert ERC20LikeToken__ZeroAddress();
        }

        _allowance[owner_][spender] = amount;
        emit Approval(owner_, spender, amount);
    }

    /**
     * @dev Internal spendAllowance logic
     */
    function _spendAllowance(address owner_, address spender, uint256 amount) internal {
        uint256 currentAllowance = _allowance[owner_][spender];

        if (currentAllowance < amount) {
            revert ERC20LikeToken__InsufficientAllowance();
        }

        _allowance[owner_][spender] = currentAllowance - amount;

        emit Approval(owner_, spender, _allowance[owner_][spender]);
    }

    /**
     * @dev Internal spendAllowance logic
     */
    function _mint(address to, uint256 amount) internal notZeroAddress(to) {
        _totalSupply += amount;

        unchecked {
            _balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    /*//////////////////////////////////////////////////////////////
                          ALLOWANCE EXTENSIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Increase allowance safely
     */
    function increaseAllowance(address spender, uint256 incAllowance) external notZeroAddress(spender) returns (bool) {
        _approve(msg.sender, spender, _allowance[msg.sender][spender] + incAllowance);
        return true;
    }

    /**
     * @notice Decrease allowance safely
     */
    function decreaseAllowance(address spender, uint256 decAllowance) external notZeroAddress(spender) returns (bool) {
        uint256 current = _allowance[msg.sender][spender];

        if (current < decAllowance) revert ERC20LikeToken__InsufficientAllowance();

        _approve(msg.sender, spender, current - decAllowance);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns token name
    function name() external view returns (string memory) {
        return _name;
    }

    /// @notice Returns token symbol
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /// @notice Returns decimals (always 18)
    function decimals() external pure returns (uint8) {
        return _decimals;
    }

    /// @notice Returns total supply
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /// @notice Returns balance of an account
    function balanceOf(address account) external view returns (uint256) {
        return _balanceOf[account];
    }

    /// @notice Returns allowance from owner to spender
    function allowance(address owner_, address spender) external view returns (uint256) {
        return _allowance[owner_][spender];
    }
}
