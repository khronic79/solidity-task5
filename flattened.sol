// Sources flattened with hardhat v2.23.0 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.3.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.3.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.3.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol@v5.3.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface for the optional metadata functions from the ERC-20 standard.
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}


// File @chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol@v1.3.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable-next-line interface-starts-with-i
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(
    uint80 _roundId
  ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

  function latestRoundData()
    external
    view
    returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
}


// File contracts/UsdcDaiTokensExchange.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity 0.8.28;




/*
- Контракт предполагает возможность обмена DAI токена на USDC или наоборот.
- Ликвидность для обмена предоставляет владелец контракта,
т.е. пользователь предоставляет токен для обмена, а нужный ему токен предоставляется
данным контрактом в соответствии с курсом за вычетом комиссионных.
- Курс для расчета обмена получаем из chainlink
*/

// Контракт наследуется от Ownable.sol библиотеки openzeppelin
contract UsdcDaiTokensExchange is Ownable {
    // Адреса Price Feeds - устанавливаются при деплое контракта
    AggregatorV3Interface public usdcUsdPriceFeed;
    AggregatorV3Interface public daiUsdPriceFeed;

    // Адреса токенов ERC20 - устанавливаются при деплое контракта
    IERC20 public usdcToken;
    IERC20 public daiToken;

    // Десятичные знаки - устанавливаются при деплое контракта
    uint8 public usdcDecimals;
    uint8 public daiDecimals;
    uint8 public usdDecimals;

    // Комиссия за обмен (возможно изменить отдельной функцией)
    uint256 public exchangeFeePercentage = 50;
    uint256 public constant FEE_DENOMINATOR = 10000;
    
    // Состояние контракта - контракт можно поставить на паузу в случае каких-либо непредвиденных ситуаций
    bool public paused;

    // Кастомные ошибки
    error ZeroAddress();
    error AllowanceTooLow();
    error TransferFailed();
    error InsufficientBalance();
    error PriceFeedInvalid();
    error PriceFeedStale();
    error ContractPaused();
    error InvalidTokens();
    error FeeTooHigh();
    error SameTokens();
    error InvalidTokenAddress();

    // События контракта
    event Exchange(
        address indexed user,
        address fromToken,
        uint256 fromAmount,
        address toToken,
        uint256 toAmount,
        uint256 feeAmount
    );
    event FeeUpdated(uint256 newFee);
    event ContractPausedEvent(bool paused);

    // Модификатор, который не позволяет запускать функцию, если контракт установлен на паузу
    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    constructor(
        address _usdcUsdPriceFeed,
        address _daiUsdPriceFeed,
        address _usdcToken,
        address _daiToken
    // Контракт инициирует родительский конструктор адресом, с которого деплоится контракт
    // Назначая владельце этот адрес
    ) Ownable(msg.sender) {
        // Проверка, что адрес источника цены USDC не равен нулевому адресу
        if (_usdcUsdPriceFeed == address(0)) revert ZeroAddress();
        // Проверка, что адрес источника цены DAI не равен нулевому адресу
        if (_daiUsdPriceFeed == address(0)) revert ZeroAddress();
        // Проверка, что адрес контракта USDC не равен нулевому адресу
        if (_usdcToken == address(0)) revert ZeroAddress();
        // Проверка, что адрес контракта DAI не равен нулевому адресу
        if (_daiToken == address(0)) revert ZeroAddress();
        
        // Инициализация контракта оракула для получения цены USDC
        usdcUsdPriceFeed = AggregatorV3Interface(_usdcUsdPriceFeed);
        // Инициализация контракта оракула для получения цены DAI
        daiUsdPriceFeed = AggregatorV3Interface(_daiUsdPriceFeed);
        // Инициализация контракта USDC
        usdcToken = IERC20(_usdcToken);
        // Инициализация контракта DAI
        daiToken = IERC20(_daiToken);

        // Установка количества десятичных знаков (decimals) токена USDC
        usdcDecimals = IERC20Metadata(_usdcToken).decimals();
        // Установка количества десятичных знаков (decimals) токена DAI
        daiDecimals = IERC20Metadata(_daiToken).decimals();
        // Установка количества десятичных знаков (decimals) для доллара в ChainLink
        usdDecimals = usdcUsdPriceFeed.decimals();
    }

    // Функция обмена USDC на DAI
    // DAI предоставляет настоящий контракт
    function exchangeUsdcForDai(uint256 _usdcAmount) external whenNotPaused {
        _exchange(true, _usdcAmount);
    }

    // Функция обмена DAI на USDC
    // USDC предоставляет настоящий контракт
    function exchangeDaiForUsdc(uint256 _daiAmount) external whenNotPaused {
        _exchange(false, _daiAmount);
    }

    // Общая функция обмена
    function _exchange(bool isUsdcToDai, uint256 _fromAmount) internal {

        // Выбор контракта для получения стоимости токен, который планируется менять
        AggregatorV3Interface fromPriceFeed = isUsdcToDai ? usdcUsdPriceFeed : daiUsdPriceFeed;
        // Выбор контракта для получения стоимости токен, на который планируется менять
        AggregatorV3Interface toPriceFeed = isUsdcToDai ? daiUsdPriceFeed : usdcUsdPriceFeed;
        // Выбор кол-ва десятичных знаков для токена, который планируется менять
        uint8 fromDecimals = isUsdcToDai ? usdcDecimals : daiDecimals;
        // Выбор кол-ва десятичных знаков для токена, на который планируется менять
        uint8 toDecimals = isUsdcToDai ? daiDecimals : usdcDecimals;
        // Инициализация интерфейса токена, который меняется
        IERC20 fromToken = isUsdcToDai ? usdcToken : daiToken;
        // Инициализация интерфейса токена, на который меняется 
        IERC20 toToken = isUsdcToDai ? daiToken : usdcToken;
        
        // Получение цены токена, который планируется менять
        uint256 fromPrice = getLatestPrice(fromPriceFeed);
        // Получение цены токена, на который планируется менять
        uint256 toPrice = getLatestPrice(toPriceFeed);

        // Расчет стоимости токенов, которые предстоит поменять, в USD
        uint256 usdValue = (_fromAmount * fromPrice) / (10 ** fromDecimals);
        // Расчет общей токена, на который нужно поменять, исходя из его цены в USD
        uint256 toAmountWithoutFee = (usdValue * (10 ** toDecimals)) / toPrice;
        // Расчет комиссии обмена от общей суммы
        uint256 feeAmount = (toAmountWithoutFee * exchangeFeePercentage) / FEE_DENOMINATOR;
        // Учет комиссии в сумме целевого токена
        uint256 toAmount = toAmountWithoutFee - feeAmount;

        // Проверка разрешения на перевод средств от имени настоящего контракта
        if (fromToken.allowance(msg.sender, address(this)) < _fromAmount) {
            revert AllowanceTooLow();
        }
        // Перевод средств на адрес настоящего контракта
        bool success = fromToken.transferFrom(msg.sender, address(this), _fromAmount);
        if (!success) revert TransferFailed();

        // Проверка баланса целевого токена на адресе настоящего контракта
        if (toToken.balanceOf(address(this)) < toAmount) {
            revert InsufficientBalance();
        }
        
        // Перевод целевого токена в адрес пользователя за вычетом комиссии
        success = toToken.transfer(msg.sender, toAmount);
        if (!success) revert TransferFailed();

        emit Exchange(msg.sender, address(fromToken), _fromAmount, address(toToken), toAmount, feeAmount);
    }

    // Функция предварительного расчета комиссии и суммы обмена
    function calculateExchange(
        bool isUsdcToDai,
        uint256 amount
    ) external view returns (uint256 resultAmount, uint256 feeAmount) {

        // Выбор контракта для получения стоимости токен, который планируется менять
        AggregatorV3Interface fromPriceFeed = isUsdcToDai ? usdcUsdPriceFeed : daiUsdPriceFeed;
        // Выбор контракта для получения стоимости токен, на который планируется менять
        AggregatorV3Interface toPriceFeed = isUsdcToDai ? daiUsdPriceFeed : usdcUsdPriceFeed;
        // Выбор кол-ва десятичных знаков для токена, который планируется менять
        uint8 fromDecimals = isUsdcToDai ? usdcDecimals : daiDecimals;
        // Выбор кол-ва десятичных знаков для токена, на который планируется менять
        uint8 toDecimals = isUsdcToDai ? daiDecimals : usdcDecimals;

        // Получение цены токена, который планируется менять
        uint256 fromPrice = getLatestPrice(fromPriceFeed);
        // Получение цены токена, на который планируется менять
        uint256 toPrice = getLatestPrice(toPriceFeed);

        // Расчет стоимости токенов, которые предстоит поменять, в USD
        uint256 usdValue = (amount * fromPrice) / (10 ** fromDecimals);
        // Расчет общей токена, на который нужно поменять, исходя из его цены в USD
        uint256 amountWithoutFee = (usdValue * (10 ** toDecimals)) / toPrice;
        
        // Стоимость комиссии
        feeAmount = (amountWithoutFee * exchangeFeePercentage) / FEE_DENOMINATOR;
        // Финальная сумма целевого токена, которая вернется после обмена
        resultAmount = amountWithoutFee - feeAmount;
    }

    // Получение стоимости токена от оракула
    function getLatestPrice(AggregatorV3Interface _priceFeed) public view returns (uint256) {
        // Получение и деструктуризация данных стоимости токена
        (
            ,
            int256 price,
            ,
            uint256 updatedAt,
            
        ) = _priceFeed.latestRoundData();
        
        // Проверка что цена не нулевая или не меньше нуля
        if (price <= 0) revert PriceFeedInvalid();
        // Проверка, что время последнего апдейта цены не более суток
        if (block.timestamp - updatedAt > 24 hours) revert PriceFeedStale();
        
        return uint256(price);
    }
    
    //Функция изменения комисси за обмен
    function setExchangeFee(uint256 _newFee) external onlyOwner {
        // Нельзя устанавливать комиссию более 5%
        if (_newFee > 500) revert FeeTooHigh();
        exchangeFeePercentage = _newFee;
        emit FeeUpdated(_newFee);
    }

    // Возможность приостановить работу контракта в случае непредвиденных операций
    function pause() external onlyOwner {
        paused = true;
        emit ContractPausedEvent(true);
    }

    // Возможность запустить функциональность контракта после приостановки
    function unpause() external onlyOwner {
        paused = false;
        emit ContractPausedEvent(false);
    }
    
    // Функция для вывода средств с контракта на адрес владельца
    function withdrawToken(address _token, uint256 _amount) external onlyOwner {
        IERC20(_token).transfer(owner(), _amount);
    }
}
