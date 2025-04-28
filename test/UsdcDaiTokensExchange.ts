import { expect } from 'chai';
import hre from 'hardhat';
import { parseEther, parseUnits } from 'viem';
import { getAddress } from 'viem';

describe('UsdcDaiTokensExchange', () => {
  // Функция для перевода числа в формат токена USDC
  const formatUSDC = (amount: number) => parseUnits(amount.toString(), 6);
  // Функция для перевода числа в формат токена DAI
  const formatDAI = (amount: number) => parseEther(amount.toString());

  async function deployContracts() {
    const [owner, user] = await hre.viem.getWalletClients();

    // Деплой mock контракта токена USDC
    const usdc = await hre.viem.deployContract('MockERC20', ['USDC', 'USDC', 6]);
    // Деплой mock контракта токена DAI
    const dai = await hre.viem.deployContract('MockERC20', ['DAI', 'DAI', 18]);

    // Деплой mock контракта price feeds для USDC
    const usdcPriceFeed = await hre.viem.deployContract('MockAggregatorV3' as never, [8, 1e8]);
    // Деплой mock контракта price feeds для DAI
    const daiPriceFeed = await hre.viem.deployContract('MockAggregatorV3' as never, [8, 1e8]);

    // Деплой основного контракта
    const exchange = await hre.viem.deployContract('UsdcDaiTokensExchange', [
      usdcPriceFeed.address,
      daiPriceFeed.address,
      usdc.address,
      dai.address
    ]);

    // Минт токенов USDC пользователю
    await usdc.write.mint([user.account.address, formatUSDC(1000)]);
    // Минт токенов DAI пользователю
    await dai.write.mint([user.account.address, formatDAI(1000)]);
    // Минт токенов USDC в адрес контракта
    await usdc.write.mint([exchange.address, formatUSDC(10000)]);
    // Минт токенов DAI в адрес контракта
    await dai.write.mint([exchange.address, formatDAI(10000)]);

    return {
      exchange,
      usdc,
      dai,
      usdcPriceFeed,
      daiPriceFeed,
      owner,
      user
    };
  }

  describe('Деплой контракта', () => {
    it('Корректная установка все инициируемых значений', async () => {
      const { exchange, usdc, dai, usdcPriceFeed, daiPriceFeed } = await deployContracts();

      expect(await exchange.read.usdcToken()).to.equal(getAddress(usdc.address));
      expect(await exchange.read.daiToken()).to.equal(getAddress(dai.address));
      expect(await exchange.read.usdcUsdPriceFeed()).to.equal(getAddress(usdcPriceFeed.address));
      expect(await exchange.read.daiUsdPriceFeed()).to.equal(getAddress(daiPriceFeed.address));
      expect(await exchange.read.exchangeFeePercentage()).to.equal(50n);
      expect(await exchange.read.paused()).to.equal(false);
    });
  });

  describe('Расчет обмена', () => {
    it('Корректный расчет обмена из USDC в DAI', async () => {
      const { exchange } = await deployContracts();
      const amount = formatUSDC(100);
      
      const [daiAmount, fee] = await exchange.read.calculateExchange([true, amount]);

      expect(daiAmount).to.equal(formatDAI(99.5));
      expect(fee).to.equal(formatDAI(0.5));
    });

    it('Корректный расчет обмена из DAY в USDC', async () => {
      const { exchange } = await deployContracts();
      const amount = formatDAI(100);
      
      const [usdcAmount, fee] = await exchange.read.calculateExchange([false, amount]);

      expect(usdcAmount).to.equal(formatUSDC(99.5));
      expect(fee).to.equal(formatUSDC(0.5));
    });
  });

  describe('Обмен токенов', () => {
    it('Корректный обмен USDC на DAI', async () => {
      const { exchange, usdc, dai, user, owner } = await deployContracts();
      const amount = formatUSDC(100);

      await usdc.write.approve([exchange.address, amount], { 
        account: user.account 
      });

      const initialDaiBalance = await dai.read.balanceOf([user.account.address]);

      await exchange.write.exchangeUsdcForDai([amount], {
        account: user.account
      });

      const finalDaiBalance = await dai.read.balanceOf([user.account.address]);
      expect(finalDaiBalance - initialDaiBalance).to.equal(formatDAI(99.5));
    });

    it('Корректный обмен DAI на USDC', async () => {
      const { exchange, usdc, dai, user } = await deployContracts();
      const amount = formatDAI(100);

      await dai.write.approve([exchange.address, amount], { 
        account: user.account 
      });

      const initialUsdcBalance = await usdc.read.balanceOf([user.account.address]);

      await exchange.write.exchangeDaiForUsdc([amount], {
        account: user.account
      });

      const finalUsdcBalance = await usdc.read.balanceOf([user.account.address]);
      expect(finalUsdcBalance - initialUsdcBalance).to.equal(formatUSDC(99.5));
    });

    it('Пользователь не может совершить обмен, если не дал разрешение на трансфер', async () => {
      const { exchange, user } = await deployContracts();
      
      await expect(
        exchange.write.exchangeUsdcForDai([formatUSDC(100)], {
          account: user.account
        })
      ).to.be.rejectedWith('AllowanceTooLow');
    });

    it('Обмен не должен состояться, если контракт на паузе', async () => {
      const { exchange, usdc, owner, user } = await deployContracts();
      
      await exchange.write.pause({ account: owner.account });

      await usdc.write.approve([exchange.address, formatUSDC(100)], { 
        account: user.account 
      });

      await expect(
        exchange.write.exchangeUsdcForDai([formatUSDC(100)], {
          account: user.account
        })
      ).to.be.rejectedWith('ContractPaused');
    });
  });

  describe('Функции администратора контракта', () => {
    it('Владелец может менять комиссию', async () => {
      const { exchange, owner } = await deployContracts();
      
      await exchange.write.setExchangeFee([100n], { 
        account: owner.account 
      });

      expect(await exchange.read.exchangeFeePercentage()).to.equal(100n);
    });

    it('Невладелец не может менять комиссию', async () => {
      const { exchange, user } = await deployContracts();
      
      await expect(
        exchange.write.setExchangeFee([100n], {
          account: user.account
        })
      ).to.be.rejectedWith('OwnableUnauthorizedAccount');
    });

    it('Владелец может снять токены с контракта', async () => {
      const { exchange, usdc, dai, owner, user } = await deployContracts();

      const startContractDaiBalance = await dai.read.balanceOf([exchange.address]);
      
      const [ resultAmount ] = await exchange.read.calculateExchange([true, formatUSDC(100)]);
      
      await usdc.write.approve([exchange.address, formatUSDC(100)], { 
        account: user.account 
      });
      await exchange.write.exchangeUsdcForDai([formatUSDC(100)], {
        account: user.account
      });

      const contractDaiBalance = await dai.read.balanceOf([exchange.address]);

      expect(contractDaiBalance).to.equal(startContractDaiBalance - resultAmount);

      await exchange.write.withdrawToken([dai.address, contractDaiBalance], {
        account: owner.account
      });

      expect(await dai.read.balanceOf([exchange.address])).to.equal(0n);
    });
  });
});