import { LightningElement, track } from 'lwc';
import calculateBalance from '@salesforce/apex/TermDepositCalculatorService.calculateBalance';

export default class TermDepositCalculator extends LightningElement {
    @track principal = '';
    @track interestRate = '';
    @track termYears = '';
    @track interestPaid = 'AT_MATURITY';
    @track result;
    @track errorMessage;

    frequencies = [
        { label: 'Monthly', value: 'MONTHLY' },
        { label: 'Quarterly', value: 'QUARTERLY' },
        { label: 'Annually', value: 'ANNUALLY' },
        { label: 'At Maturity', value: 'AT_MATURITY' }
    ];

    // Removed auto-execution on page load

    get frequencyPills() {
        return this.frequencies.map(f => ({
            ...f,
            className: f.value === this.interestPaid ? 'pill-button active' : 'pill-button'
        }));
    }

    get selectedFrequencyLabel() {
        const found = this.frequencies.find(f => f.value === this.interestPaid);
        return found ? found.label : 'At Maturity';
    }

    get principalFormatted() {
        const val = parseFloat(this.principal);
        if (isNaN(val) || val <= 0) {
            return '0.00';
        }
        return val.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    }

    get termDisplay() {
        return this.termYears ? `${this.termYears} Year(s)` : '0 Year(s)';
    }

    handleChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
    }

    handlePillSelect(event) {
        this.interestPaid = event.currentTarget.dataset.value;
    }

    handleCalculate() {
        this.errorMessage = undefined;

        const p = parseFloat(this.principal);
        const r = parseFloat(this.interestRate);
        const t = parseFloat(this.termYears);

        // Client-side guard check before calling backend
        if (isNaN(p) || p <= 0) {
            this.errorMessage = 'Please enter a start deposit amount greater than zero.';
            this.result = undefined;
            return;
        }
        if (isNaN(r) || r < 0) {
            this.errorMessage = 'Please enter a valid non-negative interest rate.';
            this.result = undefined;
            return;
        }
        if (isNaN(t) || t <= 0) {
            this.errorMessage = 'Please enter an investment term of at least 1 year.';
            this.result = undefined;
            return;
        }

        calculateBalance({
            principal: p,
            interestRate: r,
            termYears: t,
            interestPaid: this.interestPaid
        })
            .then((data) => {
                this.result = data;
            })
            .catch((error) => {
                this.errorMessage = error?.body?.message || 'An error occurred during calculation.';
                this.result = undefined;
            });
    }
}
