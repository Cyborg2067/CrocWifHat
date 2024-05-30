https://basescan.org/token/0x00C9C681d803d27d9c2e1E8612dE073Db0C5c390

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool success, uint256 c) {
        unchecked {
            c = a + b;
            if (c < a) c = 0;
            else success = true;
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool success, uint256 c) {
        unchecked {
            if (b <= a) {
                c = a - b;
                success = true;
            }
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool success, uint256 c) {
        unchecked {
            if (a == 0) success = true;
            else {
                c = a * b;
                if (c / a != b) {
                    c = 0;
                } else {
                    success = true;
                }
            }
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool success, uint256 c) {
        unchecked {
            if (b > 0) {
                c = a / b;
                success = true;
            }
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool success, uint256 c) {
        unchecked {
            if (b > 0) {
                c = a % b;
                success = true;
            }
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        unchecked {
            c = a + b;
            require(c >= a, "SafeMath: addition overflow");
        }
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        unchecked {
            require(b <= a, "SafeMath: subtraction overflow");
            c = a - b;
        }
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        unchecked {
            c = a * b;
            require(c / a == b, "SafeMath: multiplication overflow");
        }
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        unchecked {
            require(b > 0, "SafeMath: division by zero");
            c = a / b;
        }
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256 c) {
        unchecked {
            require(b > 0, "SafeMath: modulo by zero");
            return a % b;
        }
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256 c) {
        unchecked {
            require(b <= a, errorMessage);
            c = a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256 c) {
        unchecked {
            require(b > 0, errorMessage);
            c = a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256 c) {
        unchecked {
            require(b > 0, errorMessage);
            c = a % b;
        }
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    error OwnableUnauthorizedAccount(address account);

    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    modifier onlyOwner() virtual {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;
    uint256 private _status;

    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

contract CrocWifHat is Context, IERC20Metadata, Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => uint256) private _nonces; 

    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private constant _decimals = 18;

    constructor() Ownable(msg.sender) {
        _name = "CrocWifHat";
        _symbol = "CWH";
        _totalSupply = 21000000000 * 10 **18;
        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    modifier onlyOwner() override {
        require(msg.sender == owner(), "Only Owner");
        _;
    }

    modifier validRecipient(address recipient) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(recipient != address(this), "ERC20: transfer to the contract address");
        _;
    }

    modifier validNonce(address from, uint256 nonce) {
        require(nonce == _nonces[from], "Invalid nonce");
        _;
    }
  
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

   function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

   function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

   function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
    _transfer(sender, recipient, amount);

    uint256 currentAllowance = _allowances[sender][_msgSender()];
    require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {_approve(sender, _msgSender(), currentAllowance - amount);
    
    }

    return true;

    }

   function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {_approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {_balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
}

    function mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount, uint256 nonce) public virtual onlyOwner nonReentrant validNonce(_msgSender(), nonce) {
    address account = _msgSender();
    require(account != address(0), "ERC20: burn from the zero address");
    require(_balances[account] >= amount, "ERC20: burn amount exceeds balance");
        
    _incrementNonce(_msgSender());
    _beforeTokenTransfer(account, address(0), amount);
    _balances[account] -= amount;
    _totalSupply -= amount;

    emit Transfer(account, address(0), amount);
}

    function _approve(address owner, address spender, uint256 amount ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount ) internal virtual {}

    function _incrementNonce(address owner) private {_nonces[owner]++;

    }
}
