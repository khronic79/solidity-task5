# Задание 5. Проект по 5 модулю
## Цель:
1. Научиться создавать контракт
2. Разрабатывать стратегию для использования flashloans в AAVE
3. Написать и расширить JS-скрипт, взаимодействующий с вашим Ethereum контрактом


## Описание/Пошаговая инструкция выполнения домашнего задания:
1. Изучите протоколы Uniswap и 1INCH
2. Создайте контракт, использующий ChainLink как Oracle.
3. Разработайте стратегию для использования flashloans в AAVE.
4. Настройте окружение для работы с Web3.js.
5. Напишите JS-скрипт, взаимодействующий с вашим Ethereum контрактом.
6. Расширьте JS-скрипт запросами цены газа, баланса и функцией отправки эфира.
7. Создайте индексатор событий для TheGraph для вашего контракта.

## Что сделано
1. Создан контракт [UsdcDaiTokensExchange](./contracts/UsdcDaiTokensExchange.sol), который производит обмен токенов USDC и DAI друг на друга, имея на контрактов токенов ликвидность для проведения обмена. Контракт использует интерфейс оракула ChaiLink для получения данных о курсах. Описание контракта и функциональности находится в самом файле контракта в виде комментарие.
2. Контракт [UsdcDaiTokensExchange](./contracts/UsdcDaiTokensExchange.sol) опубликован и верифицирован в Sepolia Testnet. Публикацию можно посмотреть по [ссылке](https://sepolia.etherscan.io/address/0x85d37b1868667d0b35878f11c2417fc84d5bfe74).
3. Контракт [UsdcDaiTokensExchange](./contracts/UsdcDaiTokensExchange.sol) протестирован, тесты находятся по [ссылке](./test/UsdcDaiTokensExchange.ts). Для тестирования в целях исследования использовался VIEM, но к, сожалению, оказалось, что стандартные методы измерения газа не поддерживают эту библиотеку, поэтому в тестах нет возможности оценить газ методов контракта.
4. В тестах использовались моки контрактов:
    - [USDC ERC20](./contracts/test/MockERC20.sol),
    - [DAI ERC20](./contracts/test/MockERC20.sol)
    - [USDC Price Feed](./contracts/test/MockAggregatorV3.sol)
    - [DAI Price Feed](./contracts/test/MockAggregatorV3.sol).
5. Также мок контракты были опубликованы
    - [USDC ERC20](https://sepolia.etherscan.io/address/0xe63b7cdfebc0695c207cedec44142d23c7545d3a)
    - [DAI ERC20](https://sepolia.etherscan.io/address/0x38e8a2a03bf9bf54abf3add1defcd31e4b822df3)
    - [USDC Price Feed](https://sepolia.etherscan.io/address/0xc18c2a1717c494c563d71174c80a46f20bab3c97)
    - [DAI Price Feed](https://sepolia.etherscan.io/address/0x163027c44cf804e9f5391a21dec1f72cf9a2a5fa)
6. Контракты деплоились [скриптом VIEM](./scripts/deploy.ts)
7. Минтиг производился также скриптами:
    - [Минтинг ликвидности USDC на адрес контракта](./scripts/mintUSDCforExchangeContract.ts)
    - [Минтинг ликвидности DAI на адрес контракта](./scripts/mintDAIforExchangeContract.ts)
    - [Минтинг для пользователя средств USDC](./scripts/mintUSDCforRecipient.ts)
8. WEB3 JS установлено пакетом.
9. Скрипт для взаимодействия с контрактом по [ссылке](./web3js/interactionWithMyContract.js)
10. Скрипт с запросами цены газа, баланса и функцией отправки эфира по [ссылке](./web3js/sendTransaction.js). Тестовые транзакции, которые были выполнены этим скриптом можено посмотреть по [ссылке](https://sepolia.etherscan.io/address/0xA09eA8079E7eda7D5dfc0d147da88511627a5cdE)
11. Индексатор контракта был создан на его адрес в тестовой сети. Все файлы находтся в папке [thegraph](./thegraph/) в данном репозитории. Пример запроса к графу ниже в блоке кода:
```bash
curl -X POST \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer {api-key}" \
  -d '{"query": "{ contractPausedEvents(first: 5) { id paused blockNumber blockTimestamp } exchanges(first: 5) { id user fromToken fromAmount } }", "operationName": "Subgraphs", "variables": {}}' \
  https://api.studio.thegraph.com/query/110470/exchange-usdc-to-dai/version/latest
```

## Как запустить тесты и скрипты на локальной машине
Для запуска необходимо, чтобы на локальной машине было установлен программное обеспечение Node js.
1. Необходимо склонировать репозиторий:
```shell
git clone https://github.com/khronic79/solidity-task5.git
```
или
```shell
git clone git@github.com:khronic79/solidity-task5.git
```
2. Установить зависимости для Node js, например:
```shell
npn init
```
3. Запустить тест:
```shell
npx hardhat test
```
4. Запуск скриптов на viem (папка [scripts](./scripts/))
```shell
npx hardhat run scripts/deploy.ts
npx hardhat run scripts/mintDAIforExchangeContract.ts
npx hardhat run scripts/mintUSDCforExchangeContract.ts
npx hardhat run scripts/mintUSDCforRecipient.ts
```
5. Запуск скриптов на web3 js (папка [web3js](./web3js/))
```shell
node ./web3js/interactionWithMyContract.js
node ./web3js/sendTransaction.js
```