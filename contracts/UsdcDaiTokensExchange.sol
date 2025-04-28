// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
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