public with sharing class TermDepositCalculatorController {

    @AuraEnabled(cacheable=true)
    public static TermDepositCalculatorService.CalculationResult calculateBalance(
        Decimal principal,
        Decimal interestRate,
        Decimal termYears,
        String interestPaid
    ) {
        try {
            TermDepositCalculatorService.CalculationRequest req = new TermDepositCalculatorService.CalculationRequest();
            req.principal = principal;
            req.annualInterestRate = interestRate;
            req.termYears = termYears;
            req.interestPaidFrequency = interestPaid;

            return TermDepositCalculatorService.calculate(req);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}