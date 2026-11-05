@isTest
private class TermDepositCalculatorTest {

    @isTest
    static void testBenchmarkAtMaturity() {
        TermDepositCalculatorService.CalculationRequest req = createRequest(10000, 1.10, 3, 'AT_MATURITY');

        Test.startTest();
        TermDepositCalculatorService.CalculationResult res = TermDepositCalculatorService.calculate(req);
        Test.stopTest();

        Assert.areEqual(10330.00, res.finalBalance, 'Final balance must strictly match BEN benchmark $10,330.00');
        Assert.areEqual(330.00, res.totalInterestEarned, 'Total interest earned must equal $330.00');
        Assert.areEqual(10000.00, res.startingPrincipal, 'Starting principal must be rounded to 2 decimals');
    }

    
    @isTest
    static void testCompoundingFrequencies() {
        Test.startTest();
        TermDepositCalculatorService.CalculationResult monthlyRes = 
            TermDepositCalculatorService.calculate(createRequest(10000, 1.10, 3, 'MONTHLY'));
        TermDepositCalculatorService.CalculationResult quarterlyRes = 
            TermDepositCalculatorService.calculate(createRequest(10000, 1.10, 3, 'QUARTERLY'));
        TermDepositCalculatorService.CalculationResult annuallyRes = 
            TermDepositCalculatorService.calculate(createRequest(10000, 1.10, 3, 'ANNUALLY'));
        Test.stopTest();

        Assert.areEqual(10335.34, monthlyRes.finalBalance, 'Monthly compounding balance mismatch');
        Assert.areEqual(10335.04, quarterlyRes.finalBalance, 'Quarterly compounding balance mismatch');
        Assert.areEqual(10333.64, annuallyRes.finalBalance, 'Annual compounding balance mismatch');
    }

    @isTest
    static void testBulkifiedExecution() {
        List<TermDepositCalculatorService.CalculationRequest> batchList = new List<TermDepositCalculatorService.CalculationRequest>();
        for (Integer i = 0; i < 200; i++) {
            batchList.add(createRequest(10000, 1.10, 3, 'MONTHLY'));
        }

        Test.startTest();
        List<TermDepositCalculatorService.CalculationResult> results = TermDepositCalculatorService.calculateBulk(batchList);
        Test.stopTest();

        Assert.areEqual(200, results.size(), 'Bulk execution must process all 200 requests.');
        Assert.areEqual(10335.34, results[0].finalBalance);
    }

    @isTest
    static void testControllerEndpoint() {
        Test.startTest();
        TermDepositCalculatorService.CalculationResult res = 
            TermDepositCalculatorController.calculateBalance(10000, 1.10, 3, 'AT_MATURITY');
        Test.stopTest();

        Assert.isNotNull(res, 'Controller must return valid DTO');
        Assert.areEqual(10330.00, res.finalBalance);
    }

    @isTest
    static void testNegativeValidations() {
        assertValidationFailure(createRequest(-100, 1.10, 3, 'MONTHLY'), 'Start deposit amount must be greater than zero');
        assertValidationFailure(createRequest(10000, -2.5, 3, 'MONTHLY'), 'Interest rate cannot be negative');
        assertValidationFailure(createRequest(10000, 1.10, 0, 'MONTHLY'), 'Investment term must be greater than zero');
        assertValidationFailure(createRequest(10000, 1.10, 3, 'INVALID_FREQ'), 'Invalid interest payout frequency');
    }

    @isTest
    static void testControllerAuraException() {
        Boolean caught = false;
        try {
            TermDepositCalculatorController.calculateBalance(0, 1.10, 3, 'MONTHLY');
        } catch (AuraHandledException ex) {
            caught = true;
        }
        Assert.isTrue(caught, 'Controller must wrap internal exceptions into AuraHandledException.');
    }

    // Test Helpers
    private static TermDepositCalculatorService.CalculationRequest createRequest(
        Decimal p, Decimal r, Decimal t, String freq
    ) {
        TermDepositCalculatorService.CalculationRequest req = new TermDepositCalculatorService.CalculationRequest();
        req.principal = p;
        req.annualInterestRate = r;
        req.termYears = t;
        req.interestPaidFrequency = freq;
        return req;
    }

    private static void assertValidationFailure(TermDepositCalculatorService.CalculationRequest req, String expectedMsg) {
        try {
            TermDepositCalculatorService.calculate(req);
            Assert.fail('Should have thrown TermDepositException for invalid input.');
        } catch (TermDepositCalculatorService.TermDepositException ex) {
            Assert.isTrue(ex.getMessage().contains(expectedMsg), 'Exception message must contain: ' + expectedMsg);
        }
    }
}
