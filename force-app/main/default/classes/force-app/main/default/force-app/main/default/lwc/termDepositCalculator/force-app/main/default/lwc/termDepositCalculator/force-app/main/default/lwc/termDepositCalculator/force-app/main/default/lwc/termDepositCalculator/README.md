# Term Deposit Calculator

An enterprise-grade Banking Term Deposit Calculation Engine built on Salesforce / nCino architecture. Features clean separation of concerns, defensive domain validation, precision currency rounding, an interactive Lightning Web Component (LWC) with custom banking styles, and 100% unit test coverage.

---

## 🛠️ Tech Stack & Architecture

- **Platform:** Salesforce / nCino (API 60.0+)
- **Backend:** Apex (`TermDepositCalculatorService`, `TermDepositCalculatorController`)
- **Frontend:** Lightning Web Components (LWC) with custom modern UI
- **Testing:** Apex Unit Tests with positive, negative, edge, and bulk validation scenarios

---

## 📐 Mathematical Formulation

### 1. Paid at Maturity (Simple Interest Reinvested)
$$A = P \times (1 + r \times t)$$

### 2. Periodic Compounding (Monthly, Quarterly, Annually)
$$A = P \times \left(1 + \frac{r}{n}\right)^{n \times t}$$

Where:
- $P$ = Principal Deposit Amount ($)
- $r$ = Annual nominal interest rate in decimal form
- $t$ = Term duration in years
- $n$ = Compounding frequency per year ($n=12$ monthly, $n=4$ quarterly, $n=1$ annually)

---

## 🚀 How to Install and Run

### Prerequisites
- [Salesforce CLI (`sf`)](https://developer.salesforce.com/tools/salesforcecli)
- An authorized Salesforce Developer Org or Scratch Org

### 1. Clone the Repository
```bash
git clone [https://github.com/](https://github.com/)<your-username>/term-deposit-calculator.git
cd term-deposit-calculator
