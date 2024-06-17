# Tik: Proof-of-Time Based Cryptocurrency

## Summary

Tik is a Proof-of-Time based cryptocurrency with a fair launch, open to anyone for mining. Our goal is to create a mining environment that is fair and inclusive, where everyone has the opportunity to earn rewards through mining. Additionally, Tik has a very rare supply, minting only one Tik per hour.

## 1. Introduction
### 1.1 Background
With the rise of cryptocurrencies, more and more people aspire to participate. However, many existing cryptocurrencies suffer from unfair distribution mechanisms at launch and excessively high participation costs, accompanied by significant energy consumption. We aim to change this status quo with Tik.

### 1.2 Goals
Tik aims to ensure all participants have a fair opportunity in mining and earnings through its Proof-of-Time mechanism, while increasing its value through scarcity.

## 2. Project Overview
### 2.1 What is Tik?
Tik is an innovative cryptocurrency that employs a Proof-of-Time mechanism to ensure equitable mining opportunities and rewards for all participants. Moreover, Tik's supply is extremely rare, with only one Tik minted per hour, thereby enhancing its scarcity and value.

### 2.2 Key Features
- Fair Launch: No pre-allocation, everyone starts from the same point.
- Mineable: Anyone can participate in mining without special hardware.
- Rare Supply: Only one Tik is generated per hour, increasing its scarcity and value.
- Reward Mechanism: Rewards are distributed fairly based on mining time and contribution.

## 3. Technical Architecture
### 3.1 Proof-of-Time mechanism
Tik employs a unique Proof-of-Time mechanism where each second is treated as an epoch, offering everyone an opportunity for validation. Validation involves current time, miner's address, and current difficulty. Miners who successfully validate receive Tik rewards fairly based on their share. Specifically, Tik is supplied at a rate of 2.7777778*10^-4 per second.

### 3.1.1 Validation algorithm
Compute the hash of the timestamp and miner's address using blake2b256, then perform modulo operation with the difficulty. A result of 0 indicates a successful validation (hit).

     (blake2b256(timestamp&address) as u128) mod difficulty == 0

### 3.1.2 Difficulty calculation
The number of miners who successfully mined in the 30th epoch prior to the current epoch, divided by 1000, plus 24. 

     (miners / 1000) + 24

### 3.1.3 Share 
Each miner has a base share of 10 for each successful hit, which can be increased through 'lock'. Each day of locking increases the share by 1, up to a maximum of 60.

### 3.1.4 Reward
The reward for each hit is calculated as the miner's share divided by the total shares, multiplied by 2.7777778*10^-4.

     Reward=share/totalshare*2.7777778*10^-4

### 3.2 Node structure
Tik is built on the Sui (A layer 1 blockchain designed to make digital asset ownership fast, private, secure, and accessible to everyone.), utilizing a smart contract-based mining approach to ensure fairness and transparency. This structure supports various types of nodes, promoting network diversity and stability.

## 4. Market analysis
### 4.1 Target market
The primary target market for Tik includes individuals and groups interested in cryptocurrency mining but constrained by existing mechanisms, especially those lacking high-performance computing hardware.

### 4.2 Market demand
The current market has a strong demand for fair and transparent cryptocurrencies. Tik meets this demand through its Proof-of-Time mechanism, scarce supply, and easy accessibility, satisfying these requirements.

### 4.3 Competitive analysis
Despite the presence of many cryptocurrencies in the market, Tik stands out with its unique mechanisms, offering significant advantages in fairness, accessibility, and scarcity. It is currently the only cryptocurrency of its kind in the market.

## 5. Tokenomics
### 5.1 token allocation
The distribution of Tik tokens relies entirely on mining, ensuring there is no pre-allocation or pre-mining. All tokens are generated through a fair mining mechanism. 99% goes to miners, and 1% goes to the community.

### 5.2 Supply
Tik has an extremely rare supply, with only one Tik generated per hour until the end of time. The TIK mainnet genesis is scheduled for June 10, 2024, at 00:00:00 UTC. The total supply is calculated based on the difference between the current time and the genesis time, multiplied by 2.7777778*10^-4 Tik per second. The circulating supply refers to the total amount claimed by all miners.

### 5.3 Use cases
The Tik token can be used for trading, payments, and other functions within the network.

## 6. Roadmap
### 6.1 Short-term goals
- 2024 Q2：Mainnet launch
- 2024 Q3：Launch global marketing campaign
- 2024 Q4：List on major exchanges
### 6.2 Long-term goals
- 2025 Q2：Expand into additional use cases, enhance token liquidity

## 7. Legal compliance
Tik adheres strictly to laws and regulations in all countries, ensuring the project's legality and transparency.

## 8. Risk disclaimer
Despite Tik's unique advantages, investing and participating in cryptocurrency projects involve certain risks. Potential participants should thoroughly understand these risks before committing and make informed decisions.

## 9. Conclusion
Tik is a cryptocurrency project committed to fairness and transparency, providing equal opportunities to all participants through its Proof-of-Time mechanism. Moreover, its rare supply enhances its market value. We believe Tik will be a significant innovation in the cryptocurrency space, driving the healthy development of the entire industry.



