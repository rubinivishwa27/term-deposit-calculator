public inherited sharing class TermDepositCalculatorService {

    public class CalculationRequest {
        @AuraEnabled public Decimal principal;
        @AuraEnabled public Decimal annualInterestRate;
        @AuraEnabled public Decimal termYears;
        @AuraEnabled public String interestPaidFrequency;
    }

    public class CalculationResult {
        @AuraEnabled public Decimal startingPrincipal;
        @AuraEnabled public Decimal finalBalance;
        @AuraEnabled public Decimal totalInterestEarned;

        public CalculationResult(Decimal principal, Decimal balance) {
            this.startingPrincipal = principal.setScale(2, System.RoundingMode.HALF_UP);
            this.finalBalance = balance.setScale(2, System.RoundingMode.HALF_UP);
            this.totalInterestEarned = (this.finalBalance - this.startingPrincipal).setScale(2, System.RoundingMode.HALF_UP);
        }
    }

    public class TermDepositException extends Exception {}

    @AuraEnabled(cacheable=true)
    public static CalculationResult calculateBalance(
        Decimal principal,
        Decimal interestRate,
        Decimal termYears,
        String interestPaid
    ) {
        try {
            CalculationRequest req = new CalculationRequest();
            req.principal = principal;
            req.annualInterestRate = interestRate;
            req.termYears = termYears;
            req.interestPaidFrequency = interestPaid;

            return calculate(req);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public static CalculationResult calculate(CalculationRequest req) {
        validateInputs(req);

        Decimal principal = req.principal;
        Decimal rateDecimal = req.annualInterestRate / 100.0;
        Decimal term = req.termYears;
        String freqUpper = req.interestPaidFrequency.trim().toUpperCase().replace(' ', '_');

        Decimal finalAmount;

        if (freqUpper == 'AT_MATURITY') {
            // Simple interest at maturity: A = P * (1 + r * t)
            finalAmount = principal * (1.0 + (rateDecimal * term));
        } else {
            Integer n = getFrequencyCount(freqUpper);
            // Compound interest: A = P * (1 + r/n)^(n*t)
            Double baseVal = (Double)(1.0 + (rateDecimal / n));
            Double exponent = (Double)(n * term);
            Double compoundFactor = Math.pow(baseVal, exponent);
            finalAmount = principal * (Decimal)compoundFactor;
        }

        return new CalculationResult(principal, finalAmount);
    }

    private static Integer getFrequencyCount(String frequency) {
        switch on frequency {
            when 'MONTHLY' { return 12; }
            when 'QUARTERLY' { return 4; }
            when 'ANNUALLY' { return 1; }
            when else {
                throw new TermDepositException('Invalid interest payout frequency: ' + frequency);
            }
        }
    }

    private static void validateInputs(CalculationRequest req) {
        if (req == null) {
            throw new TermDepositException('Calculation request cannot be null.');
        }
        if (req.principal == null || req.principal <= 0) {
            throw new TermDepositException('Start deposit amount must be greater than zero.');
        }
        if (req.annualInterestRate == null || req.annualInterestRate < 0) {
            throw new TermDepositException('Interest rate cannot be negative or null.');
        }
        if (req.termYears == null || req.termYears <= 0) {
            throw new TermDepositException('Investment term must be greater than zero.');
        }
        if (String.isBlank(req.interestPaidFrequency)) {
            throw new TermDepositException('Interest payout frequency is required.');
        }
    }
}